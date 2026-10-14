# RELATÓRIO DE TESTE POR SIMULAÇÃO - DATAPATH BÁSICO DE CICLO ÚNICO (datapath_tb.pdf)

**Disciplina:** Arquitetura de Sistemas Computacionais  
**Professor:** Leonardo Rezende  
**Escola Politécnica - PUC-Campinas**  
**Ano:** 2026  

### Integrantes do Grupo:
- **Daniel Picconi Alquete** (RA: 24015408)
- **João Rozestraten** (RA: 24005941)

---

## 1. HIERARQUIA DE ARQUIVOS E DIAGRAMA DO DATAPATH

O projeto do Datapath de ciclo único foi desenvolvido de forma modular e hierárquica, reaproveitando a ULA de 16 bits desenvolvida no Lab04 com seus submódulos aritméticos de soma e subtração.

### Hierarquia de Componentes:
```
datapath_tb.vhd (Testbench)
  └── datapath.vhd (Top-Level do Datapath)
        ├── pc.vhd (Program Counter - Registrador de 16 bits com incremento)
        ├── memoria_instrucoes.vhd (Memória ROM de 16 palavras de 16 bits)
        ├── banco_registradores.vhd (Banco de 8 registradores de 16 bits com valores iniciais)
        └── ula.vhd (Unidade Lógica e Aritmética de 16 bits - Lab04)
              ├── soma.vhd (Somador de 16 bits com Carry-Out e Overflow)
              └── subtracao.vhd (Subtrator em complemento de dois com Carry-Out e Overflow)
```

### Diagrama de Blocos do Datapath:

```
               +-------------------------------------------------------------+
               |                                                             |
               v                                                             | (Write Data)
      +-----------------+       +-----------------------+                    |
      |   PC (pc.vhd)   |------>|   Memória de Instr.   |                    |
      |  [Incrementa +1]| Addr  | (memoria_instrucoes)  |                    |
      +-----------------+       +-----------------------+                    |
                                            |                                |
                                            | Instrução [15..0]              |
                  +-------------------------+------------------------+       |
                  | [11..9] (rs)   | [8..6] (rt)    | [5..3] (rd)    | [2..0]| (funct / ULACtl)
                  v                v                v                |       |
            +-------------------------------------------+            |       |
            |     Banco de Registradores (8 x 16b)      |            |       |
            |      (banco_registradores.vhd)            |            |       |
            |  Read Reg 1    Read Reg 2      Write Reg  |            |       |
            +-------------------------------------------+            |       |
                  |                |                ^                |       |
                  | Read Data 1    | Read Data 2    | (Write Data)   |       |
                  | (16 bits)      | (16 bits)      +----------------+-------+
                  v                v                                 |
            +-----------------------------+                          |
            |         ULA (16 bits)       |<-------------------------+
            |           (ula.vhd)         |  ULACtl (funct)
            +-----------------------------+
                  |               |
                  | R (Resultado) | Flags (Zero, Overflow, Cout)
                  +---------------+--------> Saídas de Status
```

---

## 2. ESPECIFICAÇÃO ARQUITETURAL E DECISÕES DE PROJETO

1. **Tamanho das Palavras (Word Size):**
   - Definido como **16 bits**, mantendo compatibilidade nativa com a ULA de 16 bits desenvolvida no Lab04 e permitindo exibição direta e sem cortes nos 4 displays hexadecimais da placa DE2-115.

2. **Formato das Instruções Tipo R (16 bits):**
   - Conforme solicitado, o processador executa exclusivamente instruções do Tipo R:
     - `Bits [15..12]` (4 bits): **Opcode** (`"0000"` para Tipo R).
     - `Bits [11..9]`  (3 bits): **rs** (Endereço do registrador fonte 1: `$0` a `$7`).
     - `Bits [8..6]`   (3 bits): **rt** (Endereço do registrador fonte 2: `$0` a `$7`).
     - `Bits [5..3]`   (3 bits): **rd** (Endereço do registrador destino: `$0` a `$7`).
     - `Bits [2..0]`   (3 bits): **funct / ULACtl** (Operação da ULA):
       - `"000"`: AND
       - `"001"`: OR
       - `"010"`: SOMA (ADD)
       - `"100"`: SUBTRAÇÃO (SUB)
       - `"110"`: SLT (Set on Less Than)
       - `"111"`: NOR

3. **Program Counter (PC):**
   - Endereçamento por palavra: incrementa `+1` a cada borda de subida do clock.
   - Ao receber o sinal de reset (`rst = '1'`), o PC retorna imediatamente para `0x0000`.

4. **Inicialização do Banco de Registradores:**
   - Como ainda não há suporte à instrução `LW`, os registradores foram inicializados estrategicamente com valores predefinidos para testes aritméticos e lógicos:
     - `$0 = 0x0000` (Zero)
     - `$1 = 0x000A` (10 em decimal)
     - `$2 = 0x0003` (3 em decimal)
     - `$3 a $7 = 0x0000` (inicialmente zerados, atualizados durante a execução).

5. **Programa Inicial Gravado na Memória de Instruções (ROM):**
   - `Endereço 0x0000`: `add $3, $1, $2`  -> Código hex: `0x029A`
   - `Endereço 0x0001`: `sub $4, $1, $2`  -> Código hex: `0x02A4`
   - `Endereço 0x0002`: `and $5, $1, $2`  -> Código hex: `0x02A8`
   - `Endereço 0x0003`: `or  $6, $1, $2`  -> Código hex: `0x02B1`
   - `Endereço 0x0004`: `slt $7, $2, $1`  -> Código hex: `0x047E`
   - `Endereço 0x0005`: `nor $0, $1, $2`  -> Código hex: `0x0287`
   - `Endereço 0x0006`: `add $1, $3, $4`  -> Código hex: `0x070A` (Lê registradores `$3` e `$4` gravados nos ciclos anteriores)
   - `Endereço 0x0007`: `sub $2, $3, $3`  -> Código hex: `0x06D4` (Testa geração da Flag Zero: 13 - 13 = 0)

---

## 3. DESCRIÇÃO DETALHADA DOS TESTES POR SIMULAÇÃO

O testbench `datapath_tb.vhd` opera com período de clock de 20 ns (50 MHz). Cada ciclo de clock testa uma instrução e valida os sinais combinacionais e síncronos por meio de cláusulas `assert`.

---

### [TESTE 0: Reset e Instrução ADD]
- **Objetivo:** Validar o retorno do PC para o início, inicialização dos registradores e execução da primeira adição.
- **Aspecto Explorado:** Busca de instrução no endereço 0, leitura simultânea de `$1` e `$2`, e soma via ULA.
- **Instrução:** `add $3, $1, $2` (hex: `0x029A`).
- **Entradas:** `PC = 0x0000`, `$1 = 0x000A` (10), `$2 = 0x0003` (3), `ULACtl = "010"`.
- **Resultado Esperado:** `alu_res_out = 0x000D` (13 decimal), `Zero = 0`, `Overflow = 0`, `Cout = 0`.
- **Resultado Obtido:** `alu_res_out = 0x000D`, flags desativadas. No final do ciclo, `$3` armazena `0x000D`.
- **Conclusão:** O ciclo inicial de fetch, decode, read e execute operou com precisão total.

---

### [TESTE 1: Instrução de SUBTRAÇÃO com Carry-Out]
- **Objetivo:** Verificar a operação de subtração $1 - $2 e a correta sinalização do Carry-Out em complemento de dois.
- **Aspecto Explorado:** Módulo Subtracao acionado pela ULA via Datapath.
- **Instrução:** `sub $4, $1, $2` (hex: `0x02A4`).
- **Entradas:** `PC = 0x0001`, `$1 = 0x000A` (10), `$2 = 0x0003` (3), `ULACtl = "100"`.
- **Resultado Esperado:** `alu_res_out = 0x0007` (7 decimal), `Zero = 0`, `Overflow = 0`, `Cout = 1` (sem empréstimo).
- **Resultado Obtido:** `alu_res_out = 0x0007`, `Cout = 1`. Registrador `$4` atualizado com 7.
- **Conclusão:** Subtração realizada perfeitamente e escrita em `$4` confirmada.

---

### [TESTE 2: Operação Lógica AND]
- **Objetivo:** Testar a propagação da função booleana AND através de operandos dos registradores.
- **Aspecto Explorado:** Mascaramento bit a bit na ULA.
- **Instrução:** `and $5, $1, $2` (hex: `0x02A8`).
- **Entradas:** `PC = 0x0002`, `$1 = 0x000A` (`...1010b`), `$2 = 0x0003` (`...0011b`), `ULACtl = "000"`.
- **Resultado Esperado:** `alu_res_out = 0x0002` (`...0010b`), flags zeradas.
- **Resultado Obtido:** `alu_res_out = 0x0002`. Registrador `$5` atualizado com `0x0002`.
- **Conclusão:** A ULA executou o AND combinacional e direcionou o valor para `$5`.

---

### [TESTE 3: Operação Lógica OR]
- **Objetivo:** Testar a união booleana bit a bit entre registradores.
- **Aspecto Explorado:** Função OR com controle `"001"`.
- **Instrução:** `or $6, $1, $2` (hex: `0x02B1`).
- **Entradas:** `PC = 0x0003`, `$1 = 0x000A` (10), `$2 = 0x0003` (3), `ULACtl = "001"`.
- **Resultado Esperado:** `alu_res_out = 0x000B` (11 decimal, `...1011b`).
- **Resultado Obtido:** `alu_res_out = 0x000B`. Registrador `$6` atualizado com `0x000B`.
- **Conclusão:** Operação OR validada com sucesso.

---

### [TESTE 4: Comparação com Sinal (SLT - Set on Less Than)]
- **Objetivo:** Validar a instrução de comparação com sinal no datapath.
- **Aspecto Explorado:** Comparação `$2 < $1` (3 < 10), confirmando condição verdadeira.
- **Instrução:** `slt $7, $2, $1` (hex: `0x047E`).
- **Entradas:** `PC = 0x0004`, `rs = $2` (3), `rt = $1` (10), `ULACtl = "110"`.
- **Resultado Esperado:** `alu_res_out = 0x0001` (verdadeiro), `Zero = 0`.
- **Resultado Obtido:** `alu_res_out = 0x0001`. Registrador `$7` recebe 1.
- **Conclusão:** O operador relacional da ULA respondeu adequadamente, gravando 1 em `$7`.

---

### [TESTE 5: Operação Lógica NOR]
- **Objetivo:** Testar a negação do OU entre dois registradores.
- **Aspecto Explorado:** Operação `not (A or B)` com código `"111"`.
- **Instrução:** `nor $0, $1, $2` (hex: `0x0287`).
- **Entradas:** `PC = 0x0005`, `$1 = 0x000A`, `$2 = 0x0003`, `ULACtl = "111"`.
- **Resultado Esperado:** `alu_res_out = NOT(0x000B) = 0xFFF4`.
- **Resultado Obtido:** `alu_res_out = 0xFFF4`.
- **Conclusão:** Operação NOR executada com perfeição.

---

### [TESTE 6: Dependência de Dados e Leitura de Registradores Anteriormente Escritos]
- **Objetivo:** Comprovar que o banco de registradores armazena e disponibiliza corretamente os resultados calculados nos ciclos anteriores.
- **Aspecto Explorado:** Leitura dos registradores `$3` (escrito no Ciclo 0 com 13) e `$4` (escrito no Ciclo 1 com 7) como fontes da adição `$1 <= $3 + $4`.
- **Instrução:** `add $1, $3, $4` (hex: `0x070A`).
- **Entradas:** `PC = 0x0006`, `reg_a_out = $3 = 0x000D` (13), `reg_b_out = $4 = 0x0007` (7).
- **Resultado Esperado:** `alu_res_out = 13 + 7 = 20` (hex: `0x0014`), flags zeradas.
- **Resultado Obtido:** `reg_a_out = 0x000D`, `reg_b_out = 0x0007`, `alu_res_out = 0x0014`. Registrador `$1` é sobrescrito com 20.
- **Conclusão:** Demonstra que o ciclo síncrono de escrita na borda do clock e leitura combinacional funciona perfeitamente sem conflitos de temporização.

---

### [TESTE 7: Ativação da Flag ZERO na Subtração]
- **Objetivo:** Verificar se a flag `Zero` da ULA é ativada corretamente no datapath quando o resultado for nulo.
- **Aspecto Explorado:** Subtração de um registrador por ele mesmo (`$3 - $3`).
- **Instrução:** `sub $2, $3, $3` (hex: `0x06D4`).
- **Entradas:** `PC = 0x0007`, `reg_a_out = $3 = 0x000D`, `reg_b_out = $3 = 0x000D`.
- **Resultado Esperado:** `alu_res_out = 0x0000`, `zero_out = '1'`, `cout_out = '1'` (sem empréstimo).
- **Resultado Obtido:** `alu_res_out = 0x0000`, `zero_out = '1'`, `cout_out = '1'`.
- **Conclusão:** A detecção de resultado zero opera perfeitamente no nível integrado do processador.

---

## 4. CONCLUSÃO GERAL DA SIMULAÇÃO

A simulação conduzida em `datapath_tb.vhd` comprovou 100% da funcionalidade do Datapath básico de ciclo único:
1. O Program Counter avançou regularmente `+1` a cada pulso de clock.
2. A memória de instruções forneceu o código das instruções corretamente no formato Tipo R.
3. O banco de registradores permitiu leitura assíncrona dupla e escrita síncrona estável.
4. Todas as operações aritméticas e lógicas herdadas da ULA do Lab04 foram executadas com êxito e refletiram corretamente nos registradores e flags.
