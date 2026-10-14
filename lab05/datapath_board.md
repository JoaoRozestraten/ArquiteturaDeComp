# RELATÓRIO DE TESTE NA PLACA DE2-115 - DATAPATH BÁSICO DE CICLO ÚNICO (datapath_board.pdf)

**Disciplina:** Arquitetura de Sistemas Computacionais  
**Professor:** Leonardo Rezende  
**Escola Politécnica - PUC-Campinas**  
**Ano:** 2026  

### Integrantes do Grupo:
- **Daniel Picconi Alquete** (RA: 24015408)
- **João Rozestraten** (RA: 24005941)

---

## 1. HIERARQUIA DE ARQUIVOS E FLUXOGRAMA DE HARDWARE

Para síntese e execução física na placa de desenvolvimento Altera/Intel FPGA Cyclone IV DE2-115, a entidade de topo `datapath_board.vhd` atua como interface entre os periféricos da placa (botões, chaves, LEDs e displays de 7 segmentos) e o núcleo do processador (`datapath.vhd`).

### Hierarquia de Arquivos:
```
datapath_board.vhd (Módulo de topo da placa com debouncer e conversor 7-segmentos)
  └── datapath.vhd (Top-Level do Datapath)
        ├── pc.vhd (Program Counter)
        ├── memoria_instrucoes.vhd (ROM de Instruções)
        ├── banco_registradores.vhd (Banco de Registradores)
        └── ula.vhd (Unidade Lógica e Aritmética)
              ├── soma.vhd (Módulo de Adição)
              └── subtracao.vhd (Módulo de Subtração)
```

### Diagrama de Interligação de Hardware na Placa DE2-115:

```
  +-------------------------------------------------------------------------+
  |                             PLACA DE2-115                               |
  |                                                                         |
  |  [CLOCK_50] (50 MHz) ---------> [Filtro Debouncer]                      |
  |  [KEY(0)]   (Botão Clock) ----> [10 ms / 500k ciclos] ---> CLK Datapath |
  |  [KEY(1)]   (Botão Reset) ----> (Inversor) -------------> RST Datapath |
  |                                                                         |
  |                                 +-----------------------+               |
  |                                 |     datapath.vhd      |               |
  |                                 | - PC                  |               |
  |                                 | - Memória ROM         |               |
  |                                 | - Banco Regs (8x16b)  |               |
  |                                 | - ULA (Lab04)         |               |
  |                                 +-----------+-----------+               |
  |                                             |                           |
  |                 +---------------------------+                           |
  |                 | Sinais Internos (PC, Instr, RegA, RegB, ALU_R, Flags) |
  |                 v                                                       |
  |  [SW(1..0)] --> [Multiplexador] --> [hex_to_7seg] --> [HEX3..HEX0]     |
  |                                                      (Displays 7-Seg)   |
  |                                                                         |
  |  PC(3..0) ------------------------------------------> [LEDR(3..0)]     |
  |  CLK debounced -------------------------------------> [LEDR(4)]        |
  |  Flags: Zero, Overflow, Cout -----------------------> [LEDR(17..15)]   |
  +-------------------------------------------------------------------------+
```

---

## 2. MAPEAMENTO DETALHADO DOS PINOS NA PLACA DE2-115

1. **Sinal de Clock Principal (`CLOCK_50`):**
   - Pino de entrada conectado ao oscilador interno de 50 MHz da placa (Pino `PIN_Y2`).
   - Utilizado como referência de amostragem temporal para o circuito de debouncing digital.

2. **Botões de Pressão (Pushbuttons `KEY`):**
   - **`KEY(0)` (Pino `PIN_M23` - Canto inferior direito):** Usado como botão manual de avanço passo a passo (Clock do Datapath). Cada pressionamento avança rigorosamente um ciclo de instrução.
   - **`KEY(1)` (Pino `PIN_M21`):** Usado como Reset geral assíncrono. Como os botões da placa DE2-115 são ativos em nível baixo (`'0'` quando pressionados), o sinal é invertido internamente para ativar o reset em lógica positiva (`sys_rst <= not KEY(1)`).

3. **Chaves Deslizantes de Seleção de Exibição (`SW(1..0)`):**
   - As chaves `SW(1)` e `SW(0)` controlam qual palavra de 16 bits do processador é decodificada e exibida nos displays `HEX3..HEX0`:
     - `SW(1..0) = "00"`: Exibe o **Resultado R da ULA** (`alu_res_out`).
     - `SW(1..0) = "01"`: Exibe o código da **Instrução de 16 bits atual** (`instr_out`).
     - `SW(1..0) = "10"`: Exibe o conteúdo do **Registrador Fonte A** (`reg_a_out`).
     - `SW(1..0) = "11"`: Exibe o conteúdo do **Registrador Fonte B** (`reg_b_out`).

4. **LEDs Vermelhos de Monitoramento (`LEDR`):**
   - `LEDR(3 downto 0)`: Endereço atual do Program Counter (`PC(3..0)`), indicando visualmente qual instrução (de 0 a 15) está sendo processada.
   - `LEDR(4)`: Eco visual do sinal de clock debounced (acende quando o botão manual está pressionado).
   - `LEDR(15)`: Flag **Zero** da ULA (acende quando o resultado da operação atual for igual a `0x0000`).
   - `LEDR(16)`: Flag **Overflow** da ULA (acende em caso de transbordamento de inteiros sinalizados).
   - `LEDR(17)`: Flag **Cout** (Carry-Out) da ULA (acende quando há transporte no bit 16).

5. **Displays de Sete Segmentos (`HEX3` a `HEX0`):**
   - Displays ativos em nível baixo (`'0'` acende o segmento), idênticos aos utilizados no Lab04:
     - `HEX0` (Pinos `PIN_G18` a `PIN_U24`): Exibe o dígito hexadecimal menos significativo `[3..0]`.
     - `HEX1` (Pinos `PIN_M24` a `PIN_W28`): Exibe o dígito `[7..4]`.
     - `HEX2` (Pinos `PIN_W21` a `PIN_V21`): Exibe o dígito `[11..8]`.
     - `HEX3` (Pinos `PIN_V21` a `PIN_W28` / Banco 3): Exibe o dígito mais significativo `[15..12]`.

---

## 3. TRATAMENTO DO EFEITO DE BOUNCING (FILTRO DIGITAL)

### O Problema do Bouncing:
Chaves mecânicas e pushbuttons não efetuam uma transição limpa imediata. Ao pressionar ou soltar `KEY(0)`, os contatos metálicos vibram eletromecanicamente por um período de 5 ms a 20 ms, gerando dezenas de transições espúrias de subida e descida. Sem tratamento, um único toque físico no botão faria o PC avançar de 10 a 50 instruções de uma só vez.

### A Solução Implementada no `datapath_board.vhd`:
1. **Sincronizador de 2 Estágios:** A entrada assíncrona `KEY(0)` passa por dois flip-flops em cascata (`ff1` e `ff2`) acionados pelo clock de 50 MHz, eliminando riscos de metaestabilidade.
2. **Temporizador de Estabilidade (Debouncer):** Um contador monitora a permanência do sinal no novo nível lógico. O novo estado só é aceito e propagado se permanecer estável continuamente por **500.000 ciclos de 50 MHz** (exatamente 10 milissegundos).
3. **Sinal Limpo de Clock:** A saída invertida `clk_debounced <= not state_reg` gera uma única borda de subida limpa e livre de ruídos por clique, permitindo a execução manual e pausada do Datapath na placa com total precisão.

---

## 4. TESTES EFETUADOS NA PLACA E RESULTADOS

---

### [TESTE 1: Reset Geral e Execução da Primeira Instrução (ADD)]
- **Objetivo:** Verificar a inicialização do hardware e a primeira operação no endereço 0 do PC.
- **Procedimento:** Pressionar `KEY(1)` para aplicar reset e soltá-lo.
- **Configuração:** `SW(1..0) = "00"` (modo Resultado da ULA).
- **Resultados Observados:**
  - `LEDR(3..0)` exibindo `0000` (PC = 0).
  - Displays `HEX3..HEX0` exibindo exatamente `000D` (hexadecimal de 13, resultado de 10 + 3).
  - Flags nos LEDs: `LEDR(17..15) = 000` (todos apagados).
  - Alternando `SW(1..0)` para `"01"`: displays exibem `029A` (código da instrução `add $3, $1, $2`).
  - Alternando para `"10"` e `"11"`: displays exibem `000A` ($1 = 10) e `0003` ($2 = 3).
- **Validação:** Comprova o reset correto do PC e dos registradores e a decodificação imediata da adição nos displays.

---

### [TESTE 2: Passo de Clock Manual e Subtração]
- **Objetivo:** Verificar a transição controlada de ciclo de clock via `KEY(0)` e a execução da subtração.
- **Procedimento:** Pressionar o botão `KEY(0)` uma única vez.
- **Configuração:** `SW(1..0) = "00"`.
- **Resultados Observados:**
  - `LEDR(3..0)` avança de `0000` para `0001` (PC = 1).
  - `LEDR(4)` pisca sincronizado com o toque físico.
  - Displays `HEX3..HEX0` atualizam instantaneamente para `0007` (10 - 3 = 7).
  - `LEDR(17)` (Cout) acende, indicando ausência de empréstimo na subtração em complemento de dois.
- **Validação:** Confirma que o filtro antirruído (debouncing) operou com eficácia, permitindo o avanço de rigorosamente uma instrução.

---

### [TESTE 3: Execução das Operações Lógicas (AND, OR, SLT e NOR)]
- **Procedimento:** Pressionar `KEY(0)` sucessivamente para avançar pelos endereços 2, 3, 4 e 5.
- **Resultados Observados:**
  - **PC = 2 (`and $5, $1, $2`):** Displays exibem `0002`. LEDs de flags apagados.
  - **PC = 3 (`or  $6, $1, $2`):** Displays exibem `000B`. LEDs de flags apagados.
  - **PC = 4 (`slt $7, $2, $1`):** Displays exibem `0001` (confirmando 3 < 10).
  - **PC = 5 (`nor $0, $1, $2`):** Displays exibem `FFF4` (resultado de `NOT(0x000B)`).
- **Validação:** Todas as funções lógicas e relacionais foram calculadas e exibidas com fidelidade nos visores da placa.

---

### [TESTE 4: Encadeamento de Dados (Leitura de Registradores Anteriormente Gravados)]
- **Objetivo:** Comprovar no hardware físico que registradores escritos em ciclos passados mantêm seus dados e podem ser lidos por instruções subsequentes.
- **Procedimento:** Pressionar `KEY(0)` para atingir o endereço `PC = 6`.
- **Instrução:** `add $1, $3, $4` (utiliza `$3 = 13` calculado no ciclo 0 e `$4 = 7` calculado no ciclo 1).
- **Resultados Observados:**
  - `LEDR(3..0)` exibindo `0110` (PC = 6).
  - `SW(1..0) = "10"`: Displays exibem `000D` (valor de `$3`).
  - `SW(1..0) = "11"`: Displays exibem `0007` (valor de `$4`).
  - `SW(1..0) = "00"`: Displays exibem `0014` (20 em decimal, resultado da soma de 13 + 7).
- **Validação:** Confirma o ciclo completo de write-back e read-after-write no banco de registradores da FPGA.

---

### [TESTE 5: Detecção e Ativação da Flag ZERO na Placa]
- **Objetivo:** Testar o acionamento físico do LED indicador da Flag Zero (`LEDR(15)`).
- **Procedimento:** Pressionar `KEY(0)` para avançar para o endereço `PC = 7` (`sub $2, $3, $3`).
- **Resultados Observados:**
  - `LEDR(3..0)` exibindo `0111` (PC = 7).
  - Displays `HEX3..HEX0` exibindo `0000`.
  - `LEDR(15)` (Flag Zero) aceso.
  - `LEDR(17)` (Cout) aceso.
- **Validação:** Demonstra que o detector combinacional de zero atua diretamente sobre os acionadores físicos de LED da placa.

---

## 5. CONCLUSÃO

A implementação física do Datapath de ciclo único na placa Altera/Intel DE2-115 foi plenamente bem-sucedida:
1. O filtro de debouncing eliminou completamente repetições indevidas de clock provocadas por repiques mecânicos.
2. A multiplexação das chaves `SW(1..0)` permitiu inspeção completa e em tempo real dos sinais internos do processador (Instrução, Operandos A e B, e Resultado da ULA).
3. O comportamento na FPGA reproduziu com fidelidade absoluta as previsões teóricas e os resultados obtidos na simulação.
