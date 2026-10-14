-- GRUPO: DANIEL PICCONI ALQUETE 24015408 E JOAO ROZESTRANTEN 24005941

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Soma is
    Port (
        A        : in  STD_LOGIC_VECTOR(15 downto 0);
        B        : in  STD_LOGIC_VECTOR(15 downto 0);
        R        : out STD_LOGIC_VECTOR(15 downto 0);
        Overflow : out STD_LOGIC;
        Cout     : out STD_LOGIC
    );
end Soma;

architecture Behavioral of Soma is
begin

    process(A, B)

        variable soma_var : unsigned(16 downto 0);
        variable resultado : std_logic_vector(15 downto 0);

    begin

        -- Soma utilizando 17 bits para preservar o carry-out
        soma_var :=
            resize(unsigned(A), 17) +
            resize(unsigned(B), 17);

        -- Resultado de 16 bits
        resultado := std_logic_vector(soma_var(15 downto 0));

        R <= resultado;

        -- Carry-out
        Cout <= soma_var(16);

        -- Overflow em soma com sinal:
        -- ocorre quando A e B possuem o mesmo sinal
        -- e o resultado possui sinal diferente.
        if (A(15) = B(15)) and
           (resultado(15) /= A(15)) then

            Overflow <= '1';

        else

            Overflow <= '0';

        end if;

    end process;

end Behavioral;
