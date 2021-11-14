.data
.align 2

array:
  .word 3,4,21,5,6 # array of integers
 
.text

la $s0, array # load array into register s0
addi $a0, $0, 0 # for loop lower bound
addi $a1, $0, 4 # for loop upper bound
lw $k1, 0($s0) # register k1 stores the maximum, first value declared as max
  	
for:
	beq $a0, $a1, done # for loop condition
	addi $s0 $s0, 4 # increment offset to move to point to next value in the array
	lw $k0, 0($s0) # load the current value into register k0
	slt $v0, $k0, $k1 # compare k0 and the current max
	addi $a0, $a0, 1 # for loop ++
	beq $v0, $0, max # if the current max is less than k0 then update the max
	j for
max:
	add $k1, $k0, $0 # swap the current max k1 to be the value of k0
	j for

done:

  
