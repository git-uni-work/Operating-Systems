addi $v0, $0, 5 # no. of items in the array 
addi $v1, $0, 36 # addy where the array starts

sw $v0, 8($0) # no. stored @ 0x00000008
sw $v1, 12($0) # array start stored @ 0x0000000C

lw $a0, 8($0) # 1st argument loaded for the no. of items
lw $a1, 12($0) # 2nd argument loaded for the address of the array start

# fill the address with unsorted values 
addi $v0, $0, 3
sw $v0, ($v1)
addi $v1, $v1, 4
addi $v0, $0, 4
sw $v0, ($v1)
addi $v1, $v1, 4
addi $v0, $0, 21
sw $v0, ($v1)
addi $v1, $v1, 4
addi $v0, $0, 2
sw $v0, ($v1)
addi $v1, $v1, 4
addi $v0, $0, 1
sw $v0, ($v1)
addi $v1, $v1, 4

# " SORTING "

addi $t4, $0, 0 # X = 0 for loop 1
addi $t5, $0, 0 # Y = 0 for loop 2
add $t0, $0, $a0 # (N) no. of items, for loop upper bound

for1:
	addi $t4, $t4, 1 # x++
	add $t5, $0, $0 # y = 0
	add $s0, $0, $a1 # address of the 1st item
	beq $t4, $t0, done # if x == N 
	for2:
		sub $t1, $t0, $t4 # y = n - x
		beq $t5, $t1, for1 # if y == n - x : break
		lw $t6, ($s0) # array [ y ]
		addi $s0, $s0, 4 # shifting to next address
		lw $t7, ($s0) # array [ y + 1 ]
		slt $t3, $t6, $t7 # if array [ y ] < array [ y + 1 ] : t3 = 1 else t3 = 0 
		addi $t5, $t5, 1 # y++
		beq $t3, $0, swap # if t3 == 0 swap array [ y ] & array [ y + 1 ]
		jal for2
	jal for1

swap:
	add $s3, $0, $t6 # tmp = array [ y ]
	add $t6, $0, $t7 # array [ y ] = array [ y + 1 ]
	add $t7, $0, $s3 # array [ y + 1 ] = tmp
	sub $s4, $s0, 4 # memory address at array [ y ]
	sw $t6, ($s4) # update memory value at array [ y ]
	addi $s4, $s4, 4 # memory address at array [ y  + 1 ]
	sw $t7, ($s4) # update memory value at array [ y + 1 ]
	jal for2

done:
	