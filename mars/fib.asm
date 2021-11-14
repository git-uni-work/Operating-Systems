addi $t0, $0, 10 # index of fibonacci no
addi $s0, $0, 0 # 1st fibonacci no
addi $s1, $0, 1 # 2nd fibonacci no

addi $t1, $0, 2 # for loop lower bound
addi $t0, $t0, 1 # for loop upper bound
for :
	beq $t0, $t1, done # for loop condition
	add $t2, $s0, $s1 # add the previous two fibonacci no's
	add $s0, $s1, $0 # update the position of the 1st fibonacci no
	add $s1, $t2, $0 # update the position of the 2nd fibonacci no
	addi $t1, $t1, 1 # for loop ++
	beq $0, $0, for # always true

done:
