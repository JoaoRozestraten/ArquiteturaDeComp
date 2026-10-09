-- GRUPO: DANIEL PICCONI ALQUETE 24015408 E JOAO ROZESTRANTEN 24005941

-- Mapeamento:
--
-- SW(17..15) -> ULACtl
-- SW(13..7)  -> A
-- SW(6..0)   -> B
--
-- LEDR(0) -> Zero
-- LEDR(1) -> Overflow
-- LEDR(2) -> Cout
--
-- HEX3..HEX0 -> R em hexadecimal

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ula_board is
    Port (
        SW   : in  STD_LOGIC_VECTOR(17 downto 0);

        LEDR : out STD_LOGIC_VECTOR(2 downto 0);

        HEX0 : out STD_LOGIC_VECTOR(6 downto 0);
        HEX1 : out STD_LOGIC_VECTOR(6 downto 0);
        HEX2 : out STD_LOGIC_VECTOR(6 downto 0);
        HEX3 : out STD_LOGIC_VECTOR(6 downto 0)
    );
end ula_board;

architecture Behavioral of ula_board is

    
    -- Componente ULA
    

    component ULA
        Port (
            A        : in  STD_LOGIC_VECTOR(15 downto 0);
            B        : in  STD_LOGIC_VECTOR(15 downto 0);
            ULACtl   : in  STD_LOGIC_VECTOR(2 downto 0);

            R        : out STD_LOGIC_VECTOR(15 downto 0);
            Zero     : out STD_LOGIC;
            Overflow : out STD_LOGIC;
            Cout     : out STD_LOGIC
        );
    end component;

    
    -- Sinais internos
    

    signal sig_A        : std_logic_vector(15 downto 0);
    signal sig_B        : std_logic_vector(15 downto 0);
    signal sig_ULACtl   : std_logic_vector(2 downto 0);

    signal sig_R        : std_logic_vector(15 downto 0);

    signal sig_Zero     : std_logic;
    signal sig_Overflow : std_logic;
    signal sig_Cout     : std_logic;


    
    -- Conversor hexadecimal para display de 7 segmentos
    --
    -- DE2-115 utiliza displays ativos em nível baixo:
    -- 0 = segmento aceso
    

    function hex_to_7seg (
        hex_digit : std_logic_vector(3 downto 0)
    )
    return std_logic_vector is

        variable seg : std_logic_vector(6 downto 0);

    begin

        case hex_digit is

            when "0000" =>
                seg := "1000000"; -- 0

            when "0001" =>
                seg := "1111001"; -- 1

            when "0010" =>
                seg := "0100100"; -- 2

            when "0011" =>
                seg := "0110000"; -- 3

            when "0100" =>
                seg := "0011001"; -- 4

            when "0101" =>
                seg := "0010010"; -- 5

            when "0110" =>
                seg := "0000010"; -- 6

            when "0111" =>
                seg := "1111000"; -- 7

            when "1000" =>
                seg := "0000000"; -- 8

            when "1001" =>
                seg := "0010000"; -- 9

            when "1010" =>
                seg := "0001000"; -- A

            when "1011" =>
                seg := "0000011"; -- b

            when "1100" =>
                seg := "1000110"; -- C

            when "1101" =>
                seg := "0100001"; -- d

            when "1110" =>
                seg := "0000110"; -- E

            when "1111" =>
                seg := "0001110"; -- F

            when others =>
                seg := "1111111"; -- apagado

        end case;

        return seg;

    end function;

begin

    
    -- Entradas da placa
    

    -- A possui 7 bits.
    -- O bit mais significativo SW(13) é repetido
    -- para realizar extensão de sinal até 16 bits.

    sig_A <= (15 downto 7 => SW(13)) &
             SW(13 downto 7);


    -- B possui 7 bits.
    -- O bit mais significativo SW(6) é repetido
    -- para realizar extensão de sinal até 16 bits.

    sig_B <= (15 downto 7 => SW(6)) &
             SW(6 downto 0);


    -- Controle da operação

    sig_ULACtl <= SW(17 downto 15);


    
    -- Instância da ULA
    

    inst_ULA : ULA

        port map (
            A        => sig_A,
            B        => sig_B,
            ULACtl   => sig_ULACtl,

            R        => sig_R,
            Zero     => sig_Zero,
            Overflow => sig_Overflow,
            Cout     => sig_Cout
        );


    
    -- Flags nos LEDs
    

    LEDR(0) <= sig_Zero;
    LEDR(1) <= sig_Overflow;
    LEDR(2) <= sig_Cout;


    
    -- Resultado nos displays
    --
    -- HEX0 = 4 bits menos significativos
    -- HEX3 = 4 bits mais significativos
   

    HEX0 <= hex_to_7seg(sig_R(3 downto 0));

    HEX1 <= hex_to_7seg(sig_R(7 downto 4));

    HEX2 <= hex_to_7seg(sig_R(11 downto 8));

    HEX3 <= hex_to_7seg(sig_R(15 downto 12));

end Behavioral;
