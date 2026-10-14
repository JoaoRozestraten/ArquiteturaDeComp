-- GRUPO: DANIEL PICCONI ALQUETE 24015408 E JOAO ROZESTRATEN 24005941

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Datapath_tb is
end Datapath_tb;

architecture behavior of Datapath_tb is

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

    -- Sinais de estímulo
    signal clk          : STD_LOGIC := '0';
    signal rst          : STD_LOGIC := '0';

    -- Sinais de monitoramento
    signal pc_out       : STD_LOGIC_VECTOR(15 downto 0);
    signal instr_out    : STD_LOGIC_VECTOR(15 downto 0);
    signal reg_a_out    : STD_LOGIC_VECTOR(15 downto 0);
    signal reg_b_out    : STD_LOGIC_VECTOR(15 downto 0);
    signal alu_res_out  : STD_LOGIC_VECTOR(15 downto 0);
    signal zero_out     : STD_LOGIC;
    signal overflow_out : STD_LOGIC;
    signal cout_out     : STD_LOGIC;

    constant clk_period : time := 20 ns;

begin

    -- Instanciação do Datapath
    uut : Datapath
        port map (
            clk          => clk,
            rst          => rst,
            pc_out       => pc_out,
            instr_out    => instr_out,
            reg_a_out    => reg_a_out,
            reg_b_out    => reg_b_out,
            alu_res_out  => alu_res_out,
            zero_out     => zero_out,
            overflow_out => overflow_out,
            cout_out     => cout_out
        );

    -- Geração do sinal de Clock (período = 20 ns)
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Processo de estímulos e validação com asserções
    stim_proc : process
    begin

        -- ============================================================
        -- FASE 1: Reset do Sistema
        -- ============================================================
        report "Iniciando simulacao do Datapath..." severity note;
        rst <= '1';
        wait for clk_period * 2;
        rst <= '0';
        wait for 1 ns; -- Pequeno atraso para estabilização combinacional

        -- ============================================================
        -- CICLO 0: Endereço 0x0000 -> add $3, $1, $2
        -- Operação: $3 <= $1 (10) + $2 (3) = 13 (0x000D)
        -- ============================================================
        assert pc_out = x"0000"
            report "Erro Ciclo 0: PC incorreto!" severity error;
        assert instr_out = x"029A"
            report "Erro Ciclo 0: Instrucao add incorreta!" severity error;
        assert reg_a_out = x"000A"
            report "Erro Ciclo 0: reg_a deve ser 10!" severity error;
        assert reg_b_out = x"0003"
            report "Erro Ciclo 0: reg_b deve ser 3!" severity error;
        assert alu_res_out = x"000D"
            report "Erro Ciclo 0: Resultado da soma deve ser 13 (0x000D)!" severity error;
        assert zero_out = '0'
            report "Erro Ciclo 0: Zero deve ser 0!" severity error;

        report "Ciclo 0 OK: add $3, $1, $2 -> R = 13 (0x000D)" severity note;
        wait for clk_period;

        -- ============================================================
        -- CICLO 1: Endereço 0x0001 -> sub $4, $1, $2
        -- Operação: $4 <= $1 (10) - $2 (3) = 7 (0x0007)
        -- ============================================================
        assert pc_out = x"0001"
            report "Erro Ciclo 1: PC incorreto!" severity error;
        assert instr_out = x"02A4"
            report "Erro Ciclo 1: Instrucao sub incorreta!" severity error;
        assert reg_a_out = x"000A"
            report "Erro Ciclo 1: reg_a deve ser 10!" severity error;
        assert reg_b_out = x"0003"
            report "Erro Ciclo 1: reg_b deve ser 3!" severity error;
        assert alu_res_out = x"0007"
            report "Erro Ciclo 1: Resultado da subtracao deve ser 7 (0x0007)!" severity error;
        assert cout_out = '1'
            report "Erro Ciclo 1: Cout deve ser 1 (sem emprestimo)!" severity error;

        report "Ciclo 1 OK: sub $4, $1, $2 -> R = 7 (0x0007)" severity note;
        wait for clk_period;

        -- ============================================================
        -- CICLO 2: Endereço 0x0002 -> and $5, $1, $2
        -- Operação: $5 <= 10 (1010b) AND 3 (0011b) = 2 (0x0002)
        -- ============================================================
        assert pc_out = x"0002"
            report "Erro Ciclo 2: PC incorreto!" severity error;
        assert instr_out = x"02A8"
            report "Erro Ciclo 2: Instrucao and incorreta!" severity error;
        assert alu_res_out = x"0002"
            report "Erro Ciclo 2: Resultado AND deve ser 2!" severity error;

        report "Ciclo 2 OK: and $5, $1, $2 -> R = 2 (0x0002)" severity note;
        wait for clk_period;

        -- ============================================================
        -- CICLO 3: Endereço 0x0003 -> or $6, $1, $2
        -- Operação: $6 <= 10 (1010b) OR 3 (0011b) = 11 (0x000B)
        -- ============================================================
        assert pc_out = x"0003"
            report "Erro Ciclo 3: PC incorreto!" severity error;
        assert instr_out = x"02B1"
            report "Erro Ciclo 3: Instrucao or incorreta!" severity error;
        assert alu_res_out = x"000B"
            report "Erro Ciclo 3: Resultado OR deve ser 11 (0x000B)!" severity error;

        report "Ciclo 3 OK: or $6, $1, $2 -> R = 11 (0x000B)" severity note;
        wait for clk_period;

        -- ============================================================
        -- CICLO 4: Endereço 0x0004 -> slt $7, $2, $1
        -- Operação: $7 <= (3 < 10) ? 1 : 0 = 1 (0x0001)
        -- ============================================================
        assert pc_out = x"0004"
            report "Erro Ciclo 4: PC incorreto!" severity error;
        assert instr_out = x"047E"
            report "Erro Ciclo 4: Instrucao slt incorreta!" severity error;
        assert reg_a_out = x"0003"
            report "Erro Ciclo 4: reg_a deve ser 3!" severity error;
        assert reg_b_out = x"000A"
            report "Erro Ciclo 4: reg_b deve ser 10!" severity error;
        assert alu_res_out = x"0001"
            report "Erro Ciclo 4: Resultado SLT deve ser 1!" severity error;

        report "Ciclo 4 OK: slt $7, $2, $1 -> R = 1 (0x0001)" severity note;
        wait for clk_period;

        -- ============================================================
        -- CICLO 5: Endereço 0x0005 -> nor $0, $1, $2
        -- Operação: $0 <= NOT(10 OR 3) = NOT(0x000B) = 0xFFF4
        -- ============================================================
        assert pc_out = x"0005"
            report "Erro Ciclo 5: PC incorreto!" severity error;
        assert instr_out = x"0287"
            report "Erro Ciclo 5: Instrucao nor incorreta!" severity error;
        assert alu_res_out = x"FFF4"
            report "Erro Ciclo 5: Resultado NOR deve ser 0xFFF4!" severity error;

        report "Ciclo 5 OK: nor $0, $1, $2 -> R = 0xFFF4" severity note;
        wait for clk_period;

        -- ============================================================
        -- CICLO 6: Endereço 0x0006 -> add $1, $3, $4
        -- Validação de escrita e leitura de registradores atualizados:
        -- $3 foi escrito no ciclo 0 com 13 (0x000D)
        -- $4 foi escrito no ciclo 1 com 7 (0x0007)
        -- Operação: $1 <= $3 (13) + $4 (7) = 20 (0x0014)
        -- ============================================================
        assert pc_out = x"0006"
            report "Erro Ciclo 6: PC incorreto!" severity error;
        assert instr_out = x"070A"
            report "Erro Ciclo 6: Instrucao add $1, $3, $4 incorreta!" severity error;
        assert reg_a_out = x"000D"
            report "Erro Ciclo 6: reg_a ($3) deve ser 13 (escrito no ciclo 0)!" severity error;
        assert reg_b_out = x"0007"
            report "Erro Ciclo 6: reg_b ($4) deve ser 7 (escrito no ciclo 1)!" severity error;
        assert alu_res_out = x"0014"
            report "Erro Ciclo 6: Resultado deve ser 20 (0x0014)!" severity error;

        report "Ciclo 6 OK: add $1, $3, $4 -> R = 20 (0x0014) [Escrita anterior validada]" severity note;
        wait for clk_period;

        -- ============================================================
        -- CICLO 7: Endereço 0x0007 -> sub $2, $3, $3
        -- Validação da Flag ZERO:
        -- Operação: $2 <= $3 (13) - $3 (13) = 0 (0x0000)
        -- ============================================================
        assert pc_out = x"0007"
            report "Erro Ciclo 7: PC incorreto!" severity error;
        assert instr_out = x"06D4"
            report "Erro Ciclo 7: Instrucao sub $2, $3, $3 incorreta!" severity error;
        assert alu_res_out = x"0000"
            report "Erro Ciclo 7: Resultado deve ser 0 (0x0000)!" severity error;
        assert zero_out = '1'
            report "Erro Ciclo 7: Flag ZERO deve estar ativada ('1')!" severity error;

        report "Ciclo 7 OK: sub $2, $3, $3 -> R = 0 (0x0000) com Flag Zero = 1" severity note;
        wait for clk_period;

        -- ============================================================
        -- FINALIZAÇÃO
        -- ============================================================
        report "============================================================" severity note;
        report "TODOS OS TESTES DO DATAPATH PASSARAM COM 100% DE SUCESSO!" severity note;
        report "============================================================" severity note;

        wait;

    end process;

end behavior;
