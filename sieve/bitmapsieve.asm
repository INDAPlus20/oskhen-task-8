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

.macro SQRT (%reg)

    li $t8 1
    sqrtloop:
         addi $t8 $t8 1
         mul $t9 $t8 $t8
         slt $t7 $t9 %reg
         bne $t7 $zero sqrtloop
     move %reg $t8

.end_macro

.data
space:		.asciiz " "

.text

main: #Takes input and does some initial setup
li $t6 1 # $t6 is constantly 1, for bitshift
## Input - Skips validation
li $v0 5
syscall
move $a2 $v0 # $a2 contains size of array (in bits)
SQRT($v0)
move $t1 $v0 # $t1 = sqrt(size) = limit for stepsize
## Dynamically allocates memory (input / 8) bytes, or 1 byte per 8 numbers in input
srl $a0 $a2 3
li $v0 9
syscall
move $a1 $v0 # $a1 contains pointer to start of array
li $a0 1 #Starts stepsize at 1 (+1 in steploop)
j step_loop
nop




step_loop:
addi $a0 $a0 1 #a0 += 1
slt $s0 $t1 $a0
bne $s0 $zero exit_program#print_primes
move $a3 $a0
jal read_bit
nop
beq $v0 $zero mark_loop
nop
j step_loop
nop


mark_loop: #Assumes $a0 is stepsize, $a1 is pointer to start address (does not mark 0 but rather first 0 + stepsize), $a2 is size of array (i.e we want to find primes up to (excluding) $a2). $a3 = i, should start to be = $a0
add $a3 $a3 $a0 # a3 += stepsize
slt $t8 $a3 $a2
beq $t8 $zero step_loop
nop
srl $t3 $a3 3 # t3 = i >> 3 = i//8, which find the correct byte offset.
add $t7 $a1 $t3 #Sets $t7 to startaddress + offset, i.e correct byte to operate on
lb $t4 ($t7) #Loads the byte into $t4
PUSH($ra) #Saves $ra then restores in order to work with nested jals.
jal setbit
nop
POP($ra)
sb $t4 ($t7) #Stores shifted byte into address
j mark_loop # Loops
nop

read_bit: #Assumes $a0 is the ith bit from $a1, returns in $v0 1/0 depending on the value of the bit
PUSH($t0)
PUSH($t1)
PUSH($t2)
PUSH($t3)
PUSH($t4)
srl $t0 $a0 3 # t0 = i >> 3 = i//8, which find the correct byte offset.
add $t1 $a1 $t0 # Sets $t1 to address + offset, i.e correct byte
lb $t2 ($t1) #Loads byte
andi $t3 $a0 7 # t3 = i mod 8, i.e correct bit in byte
srlv $t4 $t2 $t3 # (Byte >> Bit) & 1
andi $t4 $t4 1
move $v0 $t4
POP($t4)
POP($t3)
POP($t2)
POP($t1)
POP($t0)
jr $ra
nop

print_primes: # a1 points to start of array, a2 is size in bits
li $t2 1
print_primes_loop:
addi $t2 $t2 1
slt $t3 $t2 $a2
beq $t3 $zero exit_program
move $a0 $t2
jal read_bit
nop
beq $v0 $zero print_v0
nop
j print_primes_loop

print_v0:
move $a0 $t2
li $v0 1
syscall
la $a0 space
li $v0 4
syscall
j print_primes_loop



setbit: #Marks the ith ($a3) bit (Set it to 1) given that the correct byte is loaded into $t4 (Note: only changes register $t4, need to store byte in byteloop.
# A := A | (1 << (B & 00000111)) where B is bitcounter ($a3) and A is the correct byte ($t4)
andi $t5 $a3 7 # (B & 00000111) (Mod 8)
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
