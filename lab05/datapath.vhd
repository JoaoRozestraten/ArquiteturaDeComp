-- GRUPO: DANIEL PICCONI ALQUETE 24015408 E JOAO ROZESTRATEN 24005941

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Datapath is
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
end Datapath;

architecture Structural of Datapath is

    -- ================================================================
    -- Componentes
    -- ================================================================

    component PC
        Port (
            clk    : in  STD_LOGIC;
            rst    : in  STD_LOGIC;
            pc_out : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

    component MemoriaInstrucoes
        Port (
            endereco  : in  STD_LOGIC_VECTOR(15 downto 0);
            instrucao : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

    component BancoRegistradores
        Port (
            clk        : in  STD_LOGIC;
            rst        : in  STD_LOGIC;
            reg_write  : in  STD_LOGIC;
            read_reg1  : in  STD_LOGIC_VECTOR(2 downto 0);
            read_reg2  : in  STD_LOGIC_VECTOR(2 downto 0);
            write_reg  : in  STD_LOGIC_VECTOR(2 downto 0);
            write_data : in  STD_LOGIC_VECTOR(15 downto 0);
            read_data1 : out STD_LOGIC_VECTOR(15 downto 0);
            read_data2 : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

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

    -- ================================================================
    -- Sinais Internos
    -- ================================================================

    signal sig_pc         : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_instr      : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_read_data1 : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_read_data2 : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_alu_res    : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_zero       : STD_LOGIC;
    signal sig_overflow   : STD_LOGIC;
    signal sig_cout       : STD_LOGIC;

begin

    -- 1. Program Counter (PC)
    inst_PC : PC
        port map (
            clk    => clk,
            rst    => rst,
            pc_out => sig_pc
        );

    -- 2. Memória de Instruções (ROM)
    inst_Mem : MemoriaInstrucoes
        port map (
            endereco  => sig_pc,
            instrucao => sig_instr
        );

    -- 3. Banco de Registradores
    -- Formato Tipo R:
    -- rs = sig_instr(11 downto 9)
    -- rt = sig_instr(8 downto 6)
    -- rd = sig_instr(5 downto 3)
    -- RegWrite ativo ('1') para instruções tipo R
    inst_Banco : BancoRegistradores
        port map (
            clk        => clk,
            rst        => rst,
            reg_write  => '1',
            read_reg1  => sig_instr(11 downto 9),
            read_reg2  => sig_instr(8 downto 6),
            write_reg  => sig_instr(5 downto 3),
            write_data => sig_alu_res,
            read_data1 => sig_read_data1,
            read_data2 => sig_read_data2
        );

    -- 4. Unidade Lógica e Aritmética (ULA do Lab04)
    -- ULACtl = funct = sig_instr(2 downto 0)
    inst_ULA : ULA
        port map (
            A        => sig_read_data1,
            B        => sig_read_data2,
            ULACtl   => sig_instr(2 downto 0),
            R        => sig_alu_res,
            Zero     => sig_zero,
            Overflow => sig_overflow,
            Cout     => sig_cout
        );

    -- ================================================================
    -- Atribuição das Saídas de Monitoramento
    -- ================================================================
    pc_out       <= sig_pc;
    instr_out    <= sig_instr;
    reg_a_out    <= sig_read_data1;
    reg_b_out    <= sig_read_data2;
    alu_res_out  <= sig_alu_res;
    zero_out     <= sig_zero;
    overflow_out <= sig_overflow;
    cout_out     <= sig_cout;

end Structural;
