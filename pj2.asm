.data
	inputA: .asciiz "Please input vector A:\n\0"
	inputB: .asciiz "Please input vector B:\n\0"
	stringA: .space 1024
	stringB: .space 1024
	newline: .asciiz "\n\0"
	vectorA: .word 0,0,0,0,0,0,0,0
	vectorB: .word 0,0,0,0,0,0,0,0
	Add: .word 0,0,0,0,0,0,0,0
	Sub: .word 0,0,0,0,0,0,0,0
	Mul: .word 0,0,0,0,0,0,0,0
	Addtext: .asciiz "A+B = (\0"
	Subtext: .asciiz "A-B = (\0"
	Multext: .asciiz "A*B = \0"
	brackets: .asciiz ")\n\0"
	comma: .asciiz ",\0"
.text
	# print "Please input vector A:"
	li $v0, 4
	la $a0, inputA
	syscall
	
	# read stringA
	li $v0, 8
	la $a0, stringA
	li $a1, 32
	syscall
	
	# set t0 = stringA
	la $t0, stringA
	la $t1, vectorA
loadA:
	# load one byte of stringA
	lb $s0, ($t0)
	# if stringA[i] == '\n', break
	beq $s0, 10, ExitA
	# if stringA[i] == ' , ' , go to commaA 
	beq $s0, 44, commaA
	
	# convert this byte to 'int'
	addi $s0, $s0, -48
	
	# if s0 < 0
	beq $s0, -3, negativeA
	
	# store number to vectorA and index++
	sw $s0, ($t1)
	addi $t1, $t1, 4
	
	# t0++
	addi $t0, $t0, 1
	j loadA
	
negativeA:
	# if t0 == '-', then go on and read next number
	addi $t0, $t0, 1
	# read one byte
	lb $s0, ($t0)
	# convert to int
	addi $s0, $s0, -48
	# convert to negative
	sub $s0, $zero, $s0
	
	# store this number
	sw $s0, ($t1)
	addi $t1, $t1, 4
	
	addi $t0, $t0, 1
	j loadA
commaA:
	# if t0 == ',', then just move to next
	addi $t0, $t0, 1
	j loadA
ExitA:
	# print "Please input vectorB"
	li $v0, 4
	la $a0, inputB
	syscall
	
	# read stringB
	li $v0, 8
	la $a0, stringB
	li $a1, 32
	syscall
	
	# set t0 = stringB
	la $t0, stringB
	la $t1, vectorB
loadB:
	# load one byte of stringB
	lb $s0, ($t0)
	# if stringB[i] == '\n', break
	beq $s0, 10, ExitB
	beq $s0, 44, commaB
	
	# convert this byte to 'int'
	addi $s0, $s0, -48
	
	# if s0 < 0
	beq $s0, -3, negativeB
	
	sw $s0, ($t1)
	addi $t1, $t1, 4
	
	# t0++
	addi $t0, $t0, 1
	j loadB
	
negativeB:
	# if t0 == '-', then go on and read next number
	addi $t0, $t0, 1
	# read one byte
	lb $s0, ($t0)
	# convert to int
	addi $s0, $s0, -48
	# convert to negative
	sub $s0, $zero, $s0
	
	# store this number
	sw $s0, ($t1)
	addi $t1, $t1, 4

	addi $t0, $t0, 1
	j loadB
commaB:
	# if t0 == ',', then just move to next
	addi $t0, $t0, 1
	j loadB
ExitB:
	# print "A+B =("
	li $v0, 4
	la $a0, Addtext
	syscall
	
	# set counter t0 = 0
	li $t0, 0
	# load adderss
	la $t1, vectorA
	la $t2, vectorB
	la $t3, Add
	la $t4, Sub
	# set sum = 0
	li $t5, 0 
CalculateLoop:
	# if t0 == 8, then break
	beq $t0, 8 ExitCal
	
	# load vectorA[i] and vectorB[i]
	lw $s1, ($t1)
	lw $s2, ($t2)
	
	# Add[i] = vectorA[i] + VectorB[i]
	add $s0, $s1, $s2
	sw $s0, ($t3)
	
	# Sub[i] = vectorA[i] - vectorB[i]
	sub $s0, $s1, $s2
	sw $s0, ($t4)
	
	# Mul += vectorA[i] * vectorB[i]
	mul $s3, $s1, $s2
	add $t5, $t5, $s3

	# move to next index value	
	addi $t1, $t1, 4
	addi $t2, $t2, 4
	addi $t3, $t3, 4
	addi $t4, $t4, 4
	addi $t0, $t0, 1
	j CalculateLoop
ExitCal:
	# set counter t0 = 0
	li $t0, 0
	# load address
	la $t1, Add
outputAdd:
	# if t0 == 7, then break
	beq $t0, 7, EndAdd
	
	# read Add[i] and print it
	lw $s0, ($t1)
	move $a0, $s0
	li $v0, 1
	syscall
	
	# print ','
	li $v0, 4
	la $a0,comma
	syscall
	
	# go to next index value
	addi $t1, $t1, 4
	addi $t0, $t0, 1
	j outputAdd
EndAdd:
	# print the last number in vector
	lw $s0, ($t1)
	move $a0, $s0
	li $v0, 1
	syscall
	
	# print ')'
	li $v0, 4
	la $a0,brackets
	syscall
	
	# print "A-B = "
	li $v0, 4
	la $a0, Subtext
	syscall
	
	# set counter t0 = 0
	li $t0, 0
	# load address
	la $t1, Sub
outputSub:
	# if t0 == 7, then break
	beq $t0, 7, EndSub
	
	# read Sub[i] and print it
	lw $s0, ($t1)
	move $a0, $s0
	li $v0, 1
	syscall
	
	# print ','
	li $v0, 4
	la $a0,comma
	syscall
	
	# go to next index value
	addi $t1, $t1, 4
	addi $t0, $t0, 1
	j outputSub
EndSub:
	# print the last number in vector
	lw $s0, ($t1)
	move $a0, $s0
	li $v0, 1
	syscall
	
	# print ')'
	li $v0, 4
	la $a0,brackets
	syscall

outputMul:
	# print "A*B = "
	li $v0, 4
	la $a0, Multext
	syscall
	
	# print mul
	li $v0, 1
	move $a0, $t5
	syscall
