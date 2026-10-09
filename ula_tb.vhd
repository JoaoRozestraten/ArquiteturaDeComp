-- GRUPO: DANIEL PICCONI ALQUETE 24015408 E JOAO ROZESTRANTEN 24005941

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ULA_tb is
end ULA_tb;

architecture behavior of ULA_tb is

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

    signal A        : std_logic_vector(15 downto 0) := (others => '0');
    signal B        : std_logic_vector(15 downto 0) := (others => '0');
    signal ULACtl   : std_logic_vector(2 downto 0) := (others => '0');

    signal R        : std_logic_vector(15 downto 0);
    signal Zero     : std_logic;
    signal Overflow : std_logic;
    signal Cout     : std_logic;

    constant period : time := 20 ns;

begin

    uut : ULA
        port map (
            A        => A,
            B        => B,
            ULACtl   => ULACtl,
            R        => R,
            Zero     => Zero,
            Overflow => Overflow,
            Cout     => Cout
        );

    stim_proc : process
    begin

        
        -- TESTE 1: AND
        -- FF00 AND F0F0 = F000
        
        ULACtl <= "000";
        A      <= x"FF00";
        B      <= x"F0F0";

        wait for period;

        assert R = x"F000"
            report "ERRO TESTE 1: AND"
            severity error;

        assert Zero = '0'
            report "ERRO TESTE 1: Zero deveria ser 0"
            severity error;

        assert Overflow = '0'
            report "ERRO TESTE 1: Overflow deveria ser 0"
            severity error;

        assert Cout = '0'
            report "ERRO TESTE 1: Cout deveria ser 0"
            severity error;


        
        -- TESTE 2: OR
        -- F000 OR 000F = F00F
        

        ULACtl <= "001";
        A      <= x"F000";
        B      <= x"000F";

        wait for period;

        assert R = x"F00F"
            report "ERRO TESTE 2: OR"
            severity error;


      
        -- TESTE 3: SOMA 0 + 0
        -- Resultado = 0
        -- Zero = 1
       

        ULACtl <= "010";
        A      <= x"0000";
        B      <= x"0000";

        wait for period;

        assert R = x"0000"
            report "ERRO TESTE 3: Soma 0 + 0"
            severity error;

        assert Zero = '1'
            report "ERRO TESTE 3: Zero deveria ser 1"
            severity error;

        assert Overflow = '0'
            report "ERRO TESTE 3: Overflow deveria ser 0"
            severity error;

        assert Cout = '0'
            report "ERRO TESTE 3: Cout deveria ser 0"
            severity error;


  
        -- TESTE 4: SOMA COM CARRY
        -- FFFF + 0001 = 0000
        -- Cout = 1
        -- Zero = 1
        

        ULACtl <= "010";
        A      <= x"FFFF";
        B      <= x"0001";

        wait for period;

        assert R = x"0000"
            report "ERRO TESTE 4: Soma com carry"
            severity error;

        assert Zero = '1'
            report "ERRO TESTE 4: Zero deveria ser 1"
            severity error;

        assert Cout = '1'
            report "ERRO TESTE 4: Cout deveria ser 1"
            severity error;

        assert Overflow = '0'
            report "ERRO TESTE 4: Overflow deveria ser 0"
            severity error;


    
        -- TESTE 5: SOMA COM OVERFLOW
        -- 7FFF + 0001 = 8000
        -- Overflow = 1
        

        ULACtl <= "010";
        A      <= x"7FFF";
        B      <= x"0001";

        wait for period;

        assert R = x"8000"
            report "ERRO TESTE 5: Soma com overflow"
            severity error;

        assert Overflow = '1'
            report "ERRO TESTE 5: Overflow deveria ser 1"
            severity error;

        assert Zero = '0'
            report "ERRO TESTE 5: Zero deveria ser 0"
            severity error;


        
        -- TESTE 6: SUBTRAÇÃO NORMAL
        -- 000A - 0003 = 0007
        -- Cout = 1
        

        ULACtl <= "100";
        A      <= x"000A";
        B      <= x"0003";

        wait for period;

        assert R = x"0007"
            report "ERRO TESTE 6: Subtracao normal"
            severity error;

        assert Cout = '1'
            report "ERRO TESTE 6: Cout deveria ser 1"
            severity error;

        assert Overflow = '0'
            report "ERRO TESTE 6: Overflow deveria ser 0"
            severity error;


        
        -- TESTE 7: SUBTRAÇÃO COM OVERFLOW
        -- 8000 - 0001 = 7FFF
        -- Overflow = 1
       
        ULACtl <= "100";
        A      <= x"8000";
        B      <= x"0001";

        wait for period;

        assert R = x"7FFF"
            report "ERRO TESTE 7: Subtracao com overflow"
            severity error;

        assert Overflow = '1'
            report "ERRO TESTE 7: Overflow deveria ser 1"
            severity error;


       
        -- TESTE 8: SLT COM SINAL
        -- FFFF = -1
        -- 0001 = 1
        -- -1 < 1
        -- R = 0001
        

        ULACtl <= "110";
        A      <= x"FFFF";
        B      <= x"0001";

        wait for period;

        assert R = x"0001"
            report "ERRO TESTE 8: SLT"
            severity error;

        assert Zero = '0'
            report "ERRO TESTE 8: Zero deveria ser 0"
            severity error;


        
        -- TESTE 9: SLT
        -- 5 < 2 = falso
        -- R = 0000
        -- Zero = 1
     

        ULACtl <= "110";
        A      <= x"0005";
        B      <= x"0002";

        wait for period;

        assert R = x"0000"
            report "ERRO TESTE 9: SLT"
            severity error;

        assert Zero = '1'
            report "ERRO TESTE 9: Zero deveria ser 1"
            severity error;



        -- TESTE 10: NOR
        -- NOT(0000 OR 0000) = FFFF


        ULACtl <= "111";
        A      <= x"0000";
        B      <= x"0000";

        wait for period;

        assert R = x"FFFF"
            report "ERRO TESTE 10: NOR"
            severity error;

        assert Zero = '0'
            report "ERRO TESTE 10: Zero deveria ser 0"
            severity error;


       
        -- TESTE 11: NOR
        -- NOT(FFFF OR 0000) = 0000
        -- Zero = 1
       

        ULACtl <= "111";
        A      <= x"FFFF";
        B      <= x"0000";

        wait for period;

        assert R = x"0000"
            report "ERRO TESTE 11: NOR"
            severity error;

        assert Zero = '1'
            report "ERRO TESTE 11: Zero deveria ser 1"
            severity error;


        
        -- FIM
       

        report "TODOS OS TESTES DA ULA FORAM CONCLUIDOS."
            severity note;

        wait;

    end process;

end behavior;
