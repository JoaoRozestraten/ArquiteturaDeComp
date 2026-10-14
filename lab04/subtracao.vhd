-- GRUPO: DANIEL PICCONI ALQUETE 24015408 E JOAO ROZESTRANTEN 24005941

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Subtracao is
    Port (
        A        : in  STD_LOGIC_VECTOR(15 downto 0);
        B        : in  STD_LOGIC_VECTOR(15 downto 0);
        R        : out STD_LOGIC_VECTOR(15 downto 0);
        Overflow : out STD_LOGIC;
        Cout     : out STD_LOGIC
    );
end Subtracao;

architecture Behavioral of Subtracao is
begin

    process(A, B)

        variable sub_var : unsigned(16 downto 0);
        variable resultado : std_logic_vector(15 downto 0);

    begin

        -- Subtração através do complemento de dois:
        -- A - B = A + NOT(B) + 1
        sub_var :=
            resize(unsigned(A), 17) +
            resize(unsigned(not B), 17) +
            1;

        -- Resultado de 16 bits
        resultado := std_logic_vector(sub_var(15 downto 0));

        R <= resultado;

        -- Na subtração, Cout = 1 significa que não houve empréstimo
        Cout <= sub_var(16);

        -- Overflow em subtração com sinal:
        -- ocorre quando A e B possuem sinais diferentes
        -- e o resultado possui sinal diferente de A.
        if (A(15) /= B(15)) and
           (resultado(15) /= A(15)) then

            Overflow <= '1';

        else

            Overflow <= '0';

        end if;

    end process;

end Behavioral;
