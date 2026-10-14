# RA: 24005941 Nome: João Guadagnucci Rozestraten

.data
msg1:    .asciiz "\nDigite um inteiro"  #Definindo as strings
msg2:    .asciiz "\nSeu numero e: "

.text
main:   addi    $v0, $zero, 4           # syscall 4 = print string
        la      $a0, msg1               # carregar um endereço       
        syscall

        addi    $v0, $zero, 5   # mesma função do li mas apenas com
                                # 16b menos significativos (lui e ori para 32)
        syscall

        add     $t0, $zero, $v0         # guarda o valor de v0 em t0 pois
                                        # ainda vai ter o print de uma string

        addi    $v0, $zero, 4        
        la      $a0, msg2       #poderia ser substituido com lui e ori de msg
        syscall                 #a0 recebe a string e a syscall e chamada

        addi    $v0, $zero, 1           #v0 recebe o valor para print int
        add     $a0, $zero, $t0         #a0 recebe o numero digitado
        syscall                         #syscall 1 = print de a0

        addi    $v0,$zero, 10         # syscall 10 = exit
        syscall
