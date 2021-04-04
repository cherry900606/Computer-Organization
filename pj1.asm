.data
	string1: .asciiz "Please input your weight in kilogram:\n\0"
	string2: .asciiz "Please input your height in centimeter:\n\0"
	string3: .asciiz "Your BMI is \0"
	string4: .asciiz " You are overweight.\n\0"
	string5: .asciiz " You are underweight\n\0"
	dot: .asciiz ".\0"
	overweight: .word 23
	underweight: .word 19
.text
main:
	# print the text
	li $v0, 4
	la $a0, string1
	syscall
	# get weight
	li $v0 , 5
	syscall
	move $s0, $v0
	
	# print the text
	li $v0, 4
	la $a0, string2
	syscall
	#get height
	li $v0, 5
	syscall
	move $s1, $v0
	
	#calculate bmi
	mul $s0, $s0, 10000 # weight *= 10000
	mul $s1, $s1, $s1 # height *=  height
	div $s0, $s0, $s1 # bmi = weight*10000/height^2
	
	#output bmi
	li $v0, 4
	la $a0, string3
	syscall # your bmi is
	li $v0, 1
	move $a0, $s0
	syscall # bmi
	li $v0, 4
	la $a0, dot
	syscall # .
	
	# load word
	lw $t0, overweight
	lw $t1, underweight
	
	# check overweight or underweight
IF:
	slt $t2, $t1, $s0 # if 19 > bmi, then  bmi <= 18
	beq $t2, 1, ELSE # if not , then check if bmi >=24
	
	li $v0, 4 # underweight
	la $a0, string5 
	syscall
	j END
ELSE:	
	slt $t2, $s0, $t0 # if bmi > 23 , then bmi >=24
	beq $t2, 1, END # if not, then do nothing

	li $v0, 4
	la $a0, string4 # overweight
	syscall
	j END
	
END:
	li $v0, 10
	syscall