##################################################################
#
#   Template for subassignment "Inbyggda System-mastern, här kommer jag!"
#
#   Author: Viola Söderlund <violaso@kth.se>
#
#   Created: 2020-10-25
#
#   See: MARS Syscall Sheet (https://courses.missouristate.edu/KenVollmar/mars/Help/SyscallHelp.html)
#   See: MIPS Instruction Sheet (https://www.kth.se/social/files/563c63c9f276547044e8695f/mips-ref-sheet.pdf)
#   See: Sieve of Eratosthenes (https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes)
#
##################################################################

### Data Declaration Section ###

.data

err_msg:	.asciiz "Invalid input! Expected integer n, where 1 < n < 65536.\n"
newline:	.asciiz "\n"
space:		.asciiz " "

### Executable Code Section ###

.text

main:
    # get input
    li      $v0,5                   # set system call code to "read integer"
    syscall                         # read integer from standard input stream to $v0

    # validate input
    li 	    $t0,65536                # $t0 = 1001
    slt	    $t1,$v0,$t0		        # $t1 = input < 1001
    beq     $t1,$zero,invalid_input # if !(input < 1001), jump to invalid_input
    nop
    li	    $t0,1                   # $t0 = 1
    slt     $t1,$t0,$v0		        # $t1 = 1 < input
    beq     $t1,$zero,invalid_input # if !(1 < input), jump to invalid_input
    nop
    
    # initialise primes array
    move    $t1,$v0		    # $t1 = Limit for sieve, optimally sqrt(prime_size), currently just n
    li 	    $t2,2		    # $t2 = Counter, the i in primes[i]. Modified from template to start at 2.
    li	    $t3,1		    # $t3 = 1, used to mark i as not prime.
    
    # Dynamically allocate memory
    move $a0 $v0
    move $s6 $v0 # Save size of array in $s6
    li $v0 9
    syscall
    move $t0 $v0
    move $s5 $v0 # Extra storage since $t0 changes, to start of array
    
    addi    $t0 $t0 2		    # If counter starts at 2, prime array should match.
outer_loop:
    move $s0 $t0    # Save pointer before calling inner loop
    move $t4 $t2    # $t4 used in inner_loop as local counter up to n, while $t2 are the size of steps.
    jal inner_loop
    move $t0 $s0    # Restore pointer
    addi $t2 $t2 1
    addi $t0 $t0 1
    bne $t2 $t1 outer_loop
    nop
    j print_primes
    nop 
inner_loop:
    add     $t0 $t0 $t2
    add     $t4 $t4 $t2
    slt     $t5 $t1 $t4 # $t5 == 1 if n < counter
    bne     $t5 $zero return_register # Returns if $t4 > $t1, i.e counter > n
    sb	    $t3, ($t0)              # primes[i] = 1
    j inner_loop

return_register: #Because jeq isn't a thing
    jr $ra
    nop


print_primes:
    move $t0 $s5    # set $t0 to start of primearray
    addi $t0 $t0 2   # But actually +2 since 0 and 1 are not prime
    move $t1 $s6     # set $t1 to size of primearray
    move $t4 $zero   # $t4 used as local counter up to $t1
    addi $t4 $t4 2
    print_loop:
        beq $t4 $t1 exit_program
        lb $t5 ($t0)
        addi $t0 $t0 1
        move $a0 $t4
        addi $t4 $t4 1
        beq $t5 $t3 print_loop
        nop 
        li $v0 1
        syscall
        jal print_space
        j print_loop
invalid_input:
    # print error message
    li      $v0, 4                  # set system call code "print string"
    la      $a0, err_msg            # load address of string err_msg into the system call argument registry
    syscall                         # print the message to standard output stream

exit_program:
    # exit program
    li $v0, 10                      # set system call code to "terminate program"
    syscall                         # exit program
print_newline:
    li $v0 4
    la $a0 newline
    syscall
    jr $ra
print_space:
    li $v0 4
    la $a0 space
    syscall
    jr $ra
