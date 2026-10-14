-- GRUPO: DANIEL PICCONI ALQUETE 24015408 E JOAO ROZESTRATEN 24005941

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC is
    Port (
        clk    : in  STD_LOGIC;
        rst    : in  STD_LOGIC;
        pc_out : out STD_LOGIC_VECTOR(15 downto 0)
    );
end PC;

architecture Behavioral of PC is
    signal pc_reg : unsigned(15 downto 0) := (others => '0');
begin

    process(clk, rst)
    begin
        if rst = '1' then
            pc_reg <= (others => '0');
        elsif rising_edge(clk) then
            pc_reg <= pc_reg + 1;
        end if;
    end process;

    pc_out <= std_logic_vector(pc_reg);

end Behavioral;
