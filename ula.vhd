-- GRUPO: DANIEL PICCONI ALQUETE 24015408 E JOAO ROZESTRANTEN 24005941

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ULA is
    Port (
        A        : in  STD_LOGIC_VECTOR(15 downto 0);
        B        : in  STD_LOGIC_VECTOR(15 downto 0);
        ULACtl   : in  STD_LOGIC_VECTOR(2 downto 0);
        R        : out STD_LOGIC_VECTOR(15 downto 0);
        Zero     : out STD_LOGIC;
        Overflow : out STD_LOGIC;
        Cout     : out STD_LOGIC
    );
end ULA;

architecture Behavioral of ULA is

    -- ================================================================
    -- Componentes auxiliares
    -- ================================================================

    component Soma
        Port (
            A        : in  STD_LOGIC_VECTOR(15 downto 0);
            B        : in  STD_LOGIC_VECTOR(15 downto 0);
            R        : out STD_LOGIC_VECTOR(15 downto 0);
            Overflow : out STD_LOGIC;
            Cout     : out STD_LOGIC
        );
    end component;

    component Subtracao
        Port (
            A        : in  STD_LOGIC_VECTOR(15 downto 0);
            B        : in  STD_LOGIC_VECTOR(15 downto 0);
            R        : out STD_LOGIC_VECTOR(15 downto 0);
            Overflow : out STD_LOGIC;
            Cout     : out STD_LOGIC
        );
    end component;

    -- Resultados dos módulos auxiliares
    signal soma_R        : std_logic_vector(15 downto 0);
    signal soma_Overflow : std_logic;
    signal soma_Cout     : std_logic;

    signal sub_R        : std_logic_vector(15 downto 0);
    signal sub_Overflow : std_logic;
    signal sub_Cout     : std_logic;

begin

    -- ================================================================
    -- Instância da soma
    -- ================================================================

    inst_Soma : Soma
        port map (
            A        => A,
            B        => B,
            R        => soma_R,
            Overflow => soma_Overflow,
            Cout     => soma_Cout
        );

    -- ================================================================
    -- Instância da subtração
    -- ================================================================

    inst_Subtracao : Subtracao
        port map (
            A        => A,
            B        => B,
            R        => sub_R,
            Overflow => sub_Overflow,
            Cout     => sub_Cout
        );

    -- ================================================================
    -- Seleção da operação
    -- ================================================================

    process(A, B, ULACtl, soma_R, soma_Overflow, soma_Cout,
            sub_R, sub_Overflow, sub_Cout)

        variable res_var : std_logic_vector(15 downto 0);
        variable c_var   : std_logic;
        variable v_var   : std_logic;

    begin

        -- Valores padrão
        res_var := (others => '0');
        c_var   := '0';
        v_var   := '0';

        case ULACtl is

            -- ========================================================
            -- 000 : AND
            -- ========================================================

            when "000" =>

                res_var := A and B;
                c_var   := '0';
                v_var   := '0';

            -- ========================================================
            -- 001 : OR
            -- ========================================================

            when "001" =>

                res_var := A or B;
                c_var   := '0';
                v_var   := '0';

            -- ========================================================
            -- 010 : SOMA
            -- ========================================================

            when "010" =>

                res_var := soma_R;
                c_var   := soma_Cout;
                v_var   := soma_Overflow;

            -- ========================================================
            -- 100 : SUBTRAÇÃO
            -- ========================================================

            when "100" =>

                res_var := sub_R;
                c_var   := sub_Cout;
                v_var   := sub_Overflow;

            -- ========================================================
            -- 110 : SLT
            -- ========================================================

            when "110" =>

                if signed(A) < signed(B) then

                    res_var := x"0001";

                else

                    res_var := x"0000";

                end if;

                c_var := '0';
                v_var := '0';

            -- ========================================================
            -- 111 : NOR
            -- ========================================================

            when "111" =>

                res_var := not (A or B);
                c_var   := '0';
                v_var   := '0';

            -- ========================================================
            -- 011 e 101
            -- O enunciado permite qualquer saída.
            -- ========================================================

            when others =>

                res_var := (others => '0');
                c_var   := '0';
                v_var   := '0';

        end case;

        -- ============================================================
        -- Saídas
        -- ============================================================

        R        <= res_var;
        Cout     <= c_var;
        Overflow <= v_var;

        -- ============================================================
        -- Flag Zero
        -- ============================================================

        if res_var = x"0000" then

            Zero <= '1';

        else

            Zero <= '0';

        end if;

    end process;

end Behavioral;
