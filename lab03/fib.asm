# RA: 24005941 Nome: Joao Guadagnucci Rozestraten
# Lab 03
# Fibonacci

.data
msg1:   .asciiz "\nSequencia de fibonacci começando por 1 (12 vezes): "
x:      .word 0 #criando uma variavel
pula:   .asciiz "\n"
.text
main:
        la $s0, x #passando o endereço de x para s0
        addi $t0, $t0, 1
        sw $t0, 0($s0) #guarda o primeiro elemento que é 1
        addi $s2, $s2, 1 #proximo elemento é 1

        addi    $v0, $zero, 4       # syscall 4 = print string
        la      $a0, msg1
        syscall

        addi    $s1, $zero, 12  #definindo o numero de repetições 

        jal Fib #chama a função

        addi    $v0, $zero, 10      # syscall 10 = exit
        syscall


Fib:
        addi $sp, $sp, -4 #para adicionar o end de retorno na pilha
        sw   $ra, 0($sp)  #guarda
        beq  $s1, $zero, fim #se foram 12 numeros sai
        addi $s1, $s1, -1

        addi    $v0, $zero, 4       # PULA LINHA
        la      $a0, pula
        syscall

        lw $t0, 0($s0)  #t1 recebe o valor da variavel
        sw $s2, 0($s0)  #guarda na memoria
        add $s2, $s2, $t0       #soma o passado com o atual pra dar o proximo

        #print
        addi    $v0, $zero, 1           #v0 recebe o valor para print int
        add     $a0, $zero, $t0         #a0 recebe o numero que sera printado
        syscall

        jal Fib

fim:
        lw $ra, 0($sp) #carrega a info da pilha
        addi $sp, $sp, 4 #tira da pliha
        jr $ra #chama rec


