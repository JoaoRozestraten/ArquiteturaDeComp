# RA: 24005941 Nome: Joao Guadagnucci Rozestraten
# Lab 03
# Fatorial

.data
msg1:   .asciiz "\nDigite um inteiro: "
msg2:   .asciiz "\nO fatorial eh: "
msg3:   .asciiz "\nPressione Enter para continuar..."
buffer: .space 10

.text
main:

        addi    $v0, $zero, 4       # syscall 4 = print string
        la      $a0, msg1
        syscall

        addi    $v0, $zero, 5       # syscall 5 = read integer
        syscall

        add     $s1, $zero, $v0     #Passa v0 para s1 para guardar o valor

        jal Fat #chama a função e guarda o valor do retorno em $ra

        addi $v0, $zero, 4 #printar a terceira msg
        la   $a0, msg3
        syscall

        addi $v0, $zero, 8 #LER UMA STRING (num)
        la   $a0, buffer   #passa o endereço
        addi $a1, $zero, 10 #quantos bytes podem ser colocados 
        syscall
                
        add $t0, $zero, $s2

        addi    $v0, $zero, 4       # syscall 4 = print string
        la      $a0, msg2
        syscall

        addi     $v0, $zero, 1
        add      $a0, $zero, $t0
        syscall

        addi    $v0, $zero, 10      # syscall 10 = exit
        syscall

Fat:
    addi $sp, $sp, -8   #ganha tamnaho para + 2 palavras na pilha
    sw   $ra, 0($sp)    #guarda o endereço de retorno prara a recurção
    sw   $s1, 4($sp)    #guarda o número pára o calculo do fatorial

    addi $s2, $zero, 1  #coloca 1 em S2

    beq  $s1, $zero, fim        #se s1 for zero sai 
    addi $t0, $zero, 1
    beq  $s1, $t0, fim  #se s1 for 1 acabaou a rec

    addi $s1, $s1, -1   #subtraindo para a proxima etapa
    jal  Fat

    lw   $t0, 4($sp)    #tira o numero empilhado
    mult $s2, $t0       #multiplicando o anterior com o que foi tirado da pilha
    mflo $s2    #passando a resposta de ate 32b pra s2

fim:
    lw   $s1, 4($sp)  #coloca o numero em uma variavel S pq t é temporario
    lw   $ra, 0($sp)    #passa o endereço da função que chamou e foi empilhada
    addi $sp, $sp, 8    #remove da pilha mudando o enderço dela 
    jr   $ra    #volta pra quem chamou


