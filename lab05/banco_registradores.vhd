-- GRUPO: DANIEL PICCONI ALQUETE 24015408 E JOAO ROZESTRATEN 24005941

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BancoRegistradores is
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
end BancoRegistradores;

architecture Behavioral of BancoRegistradores is

    type reg_array is array (0 to 7) of STD_LOGIC_VECTOR(15 downto 0);

    -- Valores iniciais pré-carregados (conforme solicitado no enunciado)
    constant INIT_REGS : reg_array := (
        0 => x"0000", -- $0: 0
        1 => x"000A", -- $1: 10
        2 => x"0003", -- $2: 3
        3 => x"0000", -- $3: 0
        4 => x"0000", -- $4: 0
        5 => x"0000", -- $5: 0
        6 => x"0000", -- $6: 0
        7 => x"0000"  -- $7: 0
    );

    signal regs : reg_array := INIT_REGS;

begin

    -- Escrita síncrona com clock e reset síncrono/assíncrono
    process(clk, rst)
    begin
        if rst = '1' then
            regs <= INIT_REGS;
        elsif rising_edge(clk) then
            if reg_write = '1' then
                regs(to_integer(unsigned(write_reg))) <= write_data;
            end if;
        end if;
    end process;

    -- Leitura combinacional (assíncrona) das duas portas
    read_data1 <= regs(to_integer(unsigned(read_reg1)));
    read_data2 <= regs(to_integer(unsigned(read_reg2)));

end Behavioral;
