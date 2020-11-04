main:

    li $v0 5 #Syscall load integer
    syscall
    move $a0 $v0
    
    jal faculty
    
    move $a0 $v0
    li $v0 1 # Prints $a0
    syscall
    
    li $v0 10 # Syscall exit
    syscall
    

multiplication: # i = $t0, sum = $t1
    move $t0 $0
    move $t1 $0

    mloop:
        add $t1 $t1 $a1
        addi $t0 $t0 1
        slt $t3 $t0 $a0
        bne $t3 $0 mloop
        nop

    move $v0 $t1
    jr $ra

faculty: # i = $s0, sum = $s1
    li $s1 1
    move $s0 $a0
    
    floop:
        move $a0 $s1
        move $a1 $s0
        move $s3 $ra #Global variables suck
        jal multiplication
        move $ra $s3
        move $s1 $v0
        addi $s0 $s0 -1
        bne $s0 1 floop
        nop
    move $v0 $s1
    jr $ra
        
    