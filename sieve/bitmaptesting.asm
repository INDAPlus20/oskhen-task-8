.data
primes:		.space  1000

.text
la $t0 primes # $t0 points to start of array
li $t1 0 # $t1 acts as (byte)counter, or i//8 in primes[i]
li $t2 0 # $t2 acts as global (bit)counter, or the i in primes[i]
li $t6 1 # $t6 is constantly 1, for bitshift

byteloop:
li $t7 0 # $t7 acts as local (bit)counter, we only want to do the bitloop 7 times
add $t3 $t0 $t1 #Sets $t3 to correct byte(address)
lb $t4 ($t3) #Loads the byte into $t4

bitloop:
# A := A | (1 << (B & 00000111)) where B is bitcounter ($t2) and A is the correct byte ($t4)
## Insert condition here
andi $t5 $t2 7 # (B & 00000111)
sllv $t5 $t6 $t5 # (1 << (B & 00000111))
or $t4 $t4 $t5 # A := A | (1 << (B & 00000111))
addi $t2 $t2 1 # Increases global bitcounter
addi $t7 $t7 1 #Increases local bitcounter
bne $t7 8 bitloop
nop
j byteloop
nop

