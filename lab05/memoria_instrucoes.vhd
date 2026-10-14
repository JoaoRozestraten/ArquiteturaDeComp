-- GRUPO: DANIEL PICCONI ALQUETE 24015408 E JOAO ROZESTRATEN 24005941

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MemoriaInstrucoes is
    Port (
        endereco  : in  STD_LOGIC_VECTOR(15 downto 0);
        instrucao : out STD_LOGIC_VECTOR(15 downto 0)
    );
end MemoriaInstrucoes;

architecture Behavioral of MemoriaInstrucoes is

    -- Memória ROM com 16 instruções de 16 bits
    -- Formato de Instrução Tipo R:
    -- [15..12] : Opcode ("0000" = Tipo R)
    -- [11..9]  : rs (Registrador fonte 1)
    -- [8..6]   : rt (Registrador fonte 2)
    -- [5..3]   : rd (Registrador destino)
    -- [2..0]   : funct / ULACtl ("000"=AND, "001"=OR, "010"=ADD, "100"=SUB, "110"=SLT, "111"=NOR)

    type rom_type is array (0 to 15) of STD_LOGIC_VECTOR(15 downto 0);

    constant ROM : rom_type := (
        0  => x"029A", -- add $3, $1, $2  ($3 = 10 + 3 = 13 [0x000D])
        1  => x"02A4", -- sub $4, $1, $2  ($4 = 10 - 3 = 7  [0x0007])
        2  => x"02A8", -- and $5, $1, $2  ($5 = 10 AND 3 = 2 [0x0002])
        3  => x"02B1", -- or  $6, $1, $2  ($6 = 10 OR 3 = 11 [0x000B])
        4  => x"047E", -- slt $7, $2, $1  ($7 = (3 < 10) = 1 [0x0001])
        5  => x"0287", -- nor $0, $1, $2  ($0 = NOT(10 OR 3) = 0xFFF4)
        6  => x"070A", -- add $1, $3, $4  ($1 = 13 + 7 = 20 [0x0014])
        7  => x"06D4", -- sub $2, $3, $3  ($2 = 13 - 13 = 0 [0x0000] -> Zero=1)
        others => x"0000" -- NOP (and $0, $0, $0)
    );

begin

    -- Leitura combinacional utilizando os 4 bits menos significativos do PC
    instrucao <= ROM(to_integer(unsigned(endereco(3 downto 0))));

end Behavioral;
