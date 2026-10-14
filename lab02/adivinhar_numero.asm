# RA: 24005941 Nome: João Guadagnucci Rozestraten

#Lab 02

.data

msg1:    .asciiz "\nDigite um inteiro entre 0 e 100: "  # Definindo as strings
msg2:    .asciiz "\nDigite o mesmo número: "

.text

main:   

Leitura1:
        addi    $v0, $zero, 4           # syscall 4 = print string
        la      $a0, msg1               # carregar um endereço
        syscall

        addi    $v0, $zero, 5           # syscall 5 = read integer
        syscall

        add     $s0, $zero, $v0         # guarda o valor de v0 em s0

        addi    $t0, $zero, 100         # coloca 100 em t0
        slt     $t1, $s0, $zero         # verifica se s0 < 0
        bne     $t1, $zero, Leitura1    # se s0 < 0, volta para Leitura1

        slt     $t1, $t0, $s0           # verifica se 100 < s0
        bne     $t1, $zero, Leitura1    # se 100 < s0, volta para Leitura1

Leitura2:
        addi    $v0, $zero, 4        
        la      $a0, msg2               # poderia ser substituido com lui e ori de msg
        syscall                         # a0 recebe a string e a syscall e chamada

        addi    $v0, $zero, 5            # syscall 5 = read integer
        syscall

        add     $s1, $zero, $v0

        bne     $s1, $s0, Leitura2     # repete enquanto os números forem diferentes

        addi    $v0, $zero, 10          # syscall 10 = exit
        syscall