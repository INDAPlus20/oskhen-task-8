##
# Push value to application stack.
# PARAM: Registry with value.
##
.macro	PUSH (%reg)
	addi	$sp,$sp,-4              # decrement stack pointer (stack builds "downwards" in memory)
	sw	    %reg,0($sp)             # save value to stack
.end_macro

##
# Pop value from application stack.
# PARAM: Registry which to save value to.
##
.macro	POP (%reg)
	lw	    %reg,0($sp)             # load value from stack to given registry
	addi	$sp,$sp,4               # increment stack pointer (stack builds "downwards" in memory)
.end_macro

.data
primes:		.space  1000

.text
#la $t0 primes # $t0 points to start of array
#li $t1 0 # $t1 acts as (byte)counter, or i//8 in primes[i]
#li $t2 0 # $t2 acts as global (bit)counter, or the i in primes[i]
li $t6 1 # $t6 is constantly 1, for bitshift
li $a0 2
la $a1 primes
li $a2 100
move $a3 $a0
jal byteloop
nop
j exit_program


byteloop: #Assumes $a0 is stepsize, $a1 is pointer to start address (does not mark 0 but rather first 0 + stepsize), $a2 is size of array (i.e we want to find primes up to (excluding) $a2). $a3 = i, should start to be = $a0
add $a3 $a3 $a0 # t2 += stepsize
slt $t8 $a3 $a2
beq $t8 $zero return_register
nop
srl $t3 $a3 3 # t3 = i >> 3 = i//8, which find the correct byte offset.
add $t7 $a1 $t3 #Sets $t7 to startaddress + offset, i.e correct byte to operate on
lb $t4 ($t7) #Loads the byte into $t4
PUSH($ra) #Saves $ra then restores in order to work with nested jals.
jal bitshift
nop
POP($ra)
sb $t4 ($t7) #Stores shifted byte into address
j byteloop # Loops


bitshift: #Shifts the ith ($a3) bit given that the correct byte is loaded into $t4 (Note: only changes register $t4, need to store byte in byteloop.
# A := A | (1 << (B & 00000111)) where B is bitcounter ($a3) and A is the correct byte ($t4)
andi $t5 $a3 7 # (B & 00000111)
sllv $t5 $t6 $t5 # (1 << (B & 00000111))
or $t4 $t4 $t5 # A := A | (1 << (B & 00000111))
jr $ra
nop

return_register: #Because jeq isn't a thing
    jr $ra
    nop
exit_program:
    # exit program
    li $v0, 10                      # set system call code to "terminate program"
    syscall                         # exit program
