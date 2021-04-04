.data
	inputMsgA: .asciiz "Please input array A:\n\0"
	inputMsgKey: .asciiz "Please input a key value:\n\0"
	inputA: .space 400
	arrayA: .space 1024
	arraySize: .word 0
	newline: .asciiz "\n\0"
	errorMsg: .asciiz "Error! The array is not sorted.\n\0"
	notFdMsg: .asciiz ": Not found!\n\0"
	step: .asciiz "Step \0"
	arrAMsg: .asciiz ": A[\0"
	bigMsg: .asciiz "] > \0"
	lessMsg: .asciiz "] < \0"
	equalMsg: .asciiz "] = \0"
.text
	# print "Please input array A:\n\0"
	li $v0, 4
	la $a0, inputMsgA
	syscall
	
	# read string
	li $v0, 8
	la $a0, inputA
	li $a1, 1024 # max allowance
	syscall
	
	# set t0 = string 
	move $t0, $a0
	# set s1 = 0
	li $s1, 0
	# t1 record number is negative or not
	li $t1, 0
	# set t2 = arrayA
	la $t2, arrayA
	# t3 = array size
	li $t3, 0
###########################
loadA:
	# load one byte
	lb $s0, ($t0)
	# if input[i] == '\0', break
	beq $s0, 10, comma
	# if input[i] == ',' , go to comma label
	beq $s0, 44, comma
	# if input[i] == '- ', go to negative label
	beq $s0, 45, negative
	
	# convert input[i] to int
	addi $s0, $s0, -48
	
	# number = number*10 + input[i]
	mul $s1, $s1, 10
	add $s1, $s1, $s0
	
	# next iteration
	addi $t0, $t0, 1
	j loadA
############################
comma:
	# if t1 = 0, the number doesn't need to convert
	beq $t1, 0, positive
	# set s1 = - s1
	sub $s1, $zero, $s1
	
positive:
	# store the number into array
	sw $s1, ($t2)
	addi $t2, $t2, 4
	
	# set flag again
	li $t1, 0
	li $s1, 0
	addi $t0, $t0, 1
	
	# size++
	addi $t3, $t3, 1
	
	# if string end, then exit the loop
	beq $s0, 10, exitLoadA
	
	j loadA
#############################
negative:
	# set flag = true ( is negative)
	li $t1, 1
	addi $t0, $t0, 1
	j loadA
############################
exitLoadA:
	# arraySize = t3
	la $t4, arraySize
	sw $t3, ($t4)
	
############################
	# start to check increasing or decreasing sequence
	la $t0, arrayA
	lw $t1, 0($t0) # t1 = array[1]
	lw $t2, 4($t0) # t2 = array[2]
	li $s0, 1 # counter = 1
	move $s1, $t3 # arraySize = s1
	li $s5, 0 # flag = 0
	
	bgt $t1, $t2, decreasing # if t1 > t2,  go to decreasing
	li $s5, 1 # if increasing, then flag = 1
	
	# test if the sequence is increasing or decreasing or unsorted
increasing:
	beq $s0, $s1, sorted # if counter == arraySize, then this is a sorted array and go to sorted label
	
	lw $t1, 0($t0) # t1 = array[i]
	lw $t2, 4($t0) # t2 = array[i+1]
	bgt $t1, $t2, unsorted # if t1 > t2, unsorted
	
	addi $t0, $t0, 4 # go to next word
	addi $s0, $s0, 1 # counter++
	j increasing
decreasing:
	beq $s0, $s1, sorted # if counter == arraySize, then this is a sorted array and go to sorted label
	
	lw $t1, 0($t0) # t1 = array[i]
	lw $t2, 4($t0) # t2 = array[i+1]
	blt $t1, $t2, unsorted # if t1 < t2, unsorted
	
	addi $t0, $t0, 4 # go to next word
	addi $s0, $s0, 1 # counter++
	j decreasing
	
unsorted:
	# print error message and end the program
	li $v0, 4
	la $a0, errorMsg
	syscall
	j endProgram
sorted:
	# print "Please input a key value:"
	li $v0, 4
	la $a0, inputMsgKey
	syscall
	
	# read input key
	li $v0, 5
	syscall
	move $s0, $v0 # s0 = key
###########################
binarySearch:
	la $t0, arrayA # array[0] address
	li $t1, 0 # t1 = start index
	lw $t2, arraySize
	addi $t2, $t2, -1 # t2 = end index
	li $t3,  0 # counter = 0
loop:
	addi $t3, $t3, 1 # counter++
	
	# print "Step "
	li $v0, 4 
	la $a0, step
	syscall
	
	# print step number
	li $v0, 1
	move $a0, $t3
	syscall
	
	# while(start <= end)
	bgt $t1, $t2, notFound # if start > end, then number not exist
	
	# mid = (start + end) / 2
	add $t4, $t1, $t2
	div $t4, $t4, 2
	
	# t5 = array[mid]
	mul $t6, $t4, 4
	add $t6, $t0, $t6 # arrar[mid] address
	lw $t5, 0($t6) # array[mid]
	
	# three case: bigger, smaller, eual
	beq $s0, $t5, equal # if key == array[mid]
	blt $s0, $t5, less # if key < array[mid]
	# else key > array[mid]
	
	# print ": A["
	li $v0, 4
	la $a0, arrAMsg
	syscall
	
	# print index
	li $v0, 1
	move $a0, $t4
	syscall
	
	# print "] < "
	li $v0, 4
	la $a0, lessMsg
	syscall
	
	#print key
	li $v0, 1
	move $a0, $s0
	syscall
	
	# print new line
	li $v0, 4
	la $a0, newline
	syscall
	
	# set start and end value
	beq $s5, $zero, large_decrease
	addi $t1, $t4, 1 # start = mid + 1
	j loop
	large_decrease:
	addi $t2, $t4, -1 # end = mid  - 1
	j loop
less:
	# print ": A["
	li $v0, 4
	la $a0, arrAMsg
	syscall
	
	# print index
	li $v0, 1
	move $a0, $t4
	syscall
	
	# print "] > "
	li $v0, 4
	la $a0, bigMsg
	syscall
	
	# print key
	li $v0, 1
	move $a0, $s0
	syscall
	
	# print newline
	li $v0, 4
	la $a0, newline
	syscall
	
	# set start and end
	beq $s5, $zero, less_decrease
	addi $t2, $t4, -1 # end = mid - 1
	j loop
	less_decrease:
	addi $t1, $t4, 1
	j loop

equal:
	# print ": A["
	li $v0, 4
	la $a0, arrAMsg
	syscall
	
	# print index
	li $v0, 1
	move $a0, $t4
	syscall
	
	# print "] = "
	li $v0, 4
	la $a0, equalMsg
	syscall
	
	# print key
	li $v0, 1
	move $a0, $s0
	syscall
	
	# end the program
	j endProgram
	
notFound:
	# print "Not Found!"
	li $v0, 4
	la $a0, notFdMsg
	syscall
#########################
endProgram:
	# end the program
	li $v0, 10
	syscall
