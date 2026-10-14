-- GRUPO: DANIEL PICCONI ALQUETE 24015408 E JOAO ROZESTRATEN 24005941

-- Mapeamento na Placa Altera/Intel DE2-115:
--
-- CLOCK_50 -> Clock de 50 MHz da placa (utilizado para o filtro de debouncing)
-- KEY(0)   -> Botão de clock manual do Datapath (canto inferior direito, com debouncing)
-- KEY(1)   -> Reset geral do Datapath (ativo em nível baixo '0')
--
-- SW(1..0) -> Seletor de visualização nos displays HEX3..HEX0:
--   "00" : Resultado R da ULA (alu_res_out)
--   "01" : Instrução de 16 bits atual (instr_out)
--   "10" : Registrador fonte A lido (reg_a_out)
--   "11" : Registrador fonte B lido (reg_b_out)
--
-- LEDR(3..0)   -> Endereço atual do Program Counter (PC)
-- LEDR(4)      -> Indicador visual do sinal de clock debounced
-- LEDR(15)     -> Flag Zero
-- LEDR(16)     -> Flag Overflow
-- LEDR(17)     -> Flag Cout
--
-- HEX3..HEX0   -> Valor de 16 bits selecionado exibido em hexadecimal

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath_board is
    Port (
        CLOCK_50 : in  STD_LOGIC;
        KEY      : in  STD_LOGIC_VECTOR(3 downto 0);
        SW       : in  STD_LOGIC_VECTOR(17 downto 0);

        LEDR     : out STD_LOGIC_VECTOR(17 downto 0);

        HEX0     : out STD_LOGIC_VECTOR(6 downto 0);
        HEX1     : out STD_LOGIC_VECTOR(6 downto 0);
        HEX2     : out STD_LOGIC_VECTOR(6 downto 0);
        HEX3     : out STD_LOGIC_VECTOR(6 downto 0)
    );
end datapath_board;

architecture Behavioral of datapath_board is

    -- ================================================================
    -- Componente Datapath
    -- ================================================================

    component Datapath
        Port (
            clk          : in  STD_LOGIC;
            rst          : in  STD_LOGIC;
            pc_out       : out STD_LOGIC_VECTOR(15 downto 0);
            instr_out    : out STD_LOGIC_VECTOR(15 downto 0);
            reg_a_out    : out STD_LOGIC_VECTOR(15 downto 0);
            reg_b_out    : out STD_LOGIC_VECTOR(15 downto 0);
            alu_res_out  : out STD_LOGIC_VECTOR(15 downto 0);
            zero_out     : out STD_LOGIC;
            overflow_out : out STD_LOGIC;
            cout_out     : out STD_LOGIC
        );
    end component;

    -- ================================================================
    -- Sinais Internos e Debouncing
    -- ================================================================

    -- Filtro de debounce para KEY(0) (10 ms a 50 MHz = 500.000 ciclos)
    signal ff1, ff2      : STD_LOGIC := '1';
    signal state_reg     : STD_LOGIC := '1';
    signal counter       : integer range 0 to 500000 := 0;
    signal clk_debounced : STD_LOGIC := '0';

    -- Reset do sistema (KEY(1) ativo em '0')
    signal sys_rst       : STD_LOGIC;

    -- Sinais de monitoramento do Datapath
    signal sig_pc        : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_instr     : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_reg_a     : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_reg_b     : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_alu_res   : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_zero      : STD_LOGIC;
    signal sig_overflow  : STD_LOGIC;
    signal sig_cout      : STD_LOGIC;

    -- Palavra de 16 bits multiplexada para os displays
    signal display_word  : STD_LOGIC_VECTOR(15 downto 0);

    -- ================================================================
    -- Conversor Hexadecimal para 7 Segmentos (Ativo Baixo / DE2-115)
    -- ================================================================
    function hex_to_7seg (
        hex_digit : std_logic_vector(3 downto 0)
    )
    return std_logic_vector is
        variable seg : std_logic_vector(6 downto 0);
    begin
        case hex_digit is
            when "0000" => seg := "1000000"; -- 0
            when "0001" => seg := "1111001"; -- 1
            when "0010" => seg := "0100100"; -- 2
            when "0011" => seg := "0110000"; -- 3
            when "0100" => seg := "0011001"; -- 4
            when "0101" => seg := "0010010"; -- 5
            when "0110" => seg := "0000010"; -- 6
            when "0111" => seg := "1111000"; -- 7
            when "1000" => seg := "0000000"; -- 8
            when "1001" => seg := "0010000"; -- 9
            when "1010" => seg := "0001000"; -- A
            when "1011" => seg := "0000011"; -- b
            when "1100" => seg := "1000110"; -- C
            when "1101" => seg := "0100001"; -- d
            when "1110" => seg := "0000110"; -- E
            when "1111" => seg := "0001110"; -- F
            when others => seg := "1111111"; -- apagado
        end case;
        return seg;
    end function;

begin

    -- Reset invertido para lógica positiva
    sys_rst <= not KEY(1);

    -- ================================================================
    -- Debouncing de KEY(0) usando CLOCK_50
    -- ================================================================
    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            -- Sincronizador de 2 estágios
            ff1 <= KEY(0);
            ff2 <= ff1;

            if ff2 /= state_reg then
                if counter = 500000 then
                    state_reg <= ff2;
                    counter   <= 0;
                else
                    counter <= counter + 1;
                end if;
            else
                counter <= 0;
            end if;
        end if;
    end process;

    -- Botão KEY(0) em repouso = '1', ao ser pressionado = '0'
    -- Ao inverter, temos nível alto ('1') e borda de subida ao pressionar
    clk_debounced <= not state_reg;

    -- ================================================================
    -- Instância do Datapath de Ciclo Único
    -- ================================================================
    inst_Datapath : Datapath
        port map (
            clk          => clk_debounced,
            rst          => sys_rst,
            pc_out       => sig_pc,
            instr_out    => sig_instr,
            reg_a_out    => sig_reg_a,
            reg_b_out    => sig_reg_b,
            alu_res_out  => sig_alu_res,
            zero_out     => sig_zero,
            overflow_out => sig_overflow,
            cout_out     => sig_cout
        );

    -- ================================================================
    -- Multiplexador de Exibição via SW(1..0)
    -- ================================================================
    process(SW(1 downto 0), sig_alu_res, sig_instr, sig_reg_a, sig_reg_b)
    begin
        case SW(1 downto 0) is
            when "00" =>
                display_word <= sig_alu_res; -- Resultado da ULA
            when "01" =>
                display_word <= sig_instr;   -- Instrução em execução
            when "10" =>
                display_word <= sig_reg_a;   -- Operando A
            when "11" =>
                display_word <= sig_reg_b;   -- Operando B
            when others =>
                display_word <= sig_alu_res;
        end case;
    end process;

    -- Displays de 7 segmentos HEX3..HEX0
    HEX0 <= hex_to_7seg(display_word(3 downto 0));
    HEX1 <= hex_to_7seg(display_word(7 downto 4));
    HEX2 <= hex_to_7seg(display_word(11 downto 8));
    HEX3 <= hex_to_7seg(display_word(15 downto 12));

    -- LEDs
    LEDR(3 downto 0)   <= sig_pc(3 downto 0); -- PC exibido nos 4 LEDs da direita
    LEDR(4)            <= clk_debounced;      -- Indicador do botão de clock
    LEDR(14 downto 5)  <= (others => '0');
    LEDR(15)           <= sig_zero;           -- LEDR(15) = Flag Zero
    LEDR(16)           <= sig_overflow;       -- LEDR(16) = Flag Overflow
    LEDR(17)           <= sig_cout;           -- LEDR(17) = Flag Cout

end Behavioral;
