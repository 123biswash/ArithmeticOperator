.text
.globl main
main:
	addi $sp, $sp, -4

	sw $ra, 0($sp)

	# 1. Print the following prompt message:
	# Please enter an integer:
	li $v0, 4
	la $a0, enter_int
	syscall
	
	# 2. Read an integer from user.
	li $v0, 5
	syscall
	move $s0, $v0

	# 3. Print the following prompt message:
	# Please enter an operator (+, -, *, /):
	li $v0, 4
	la $a0, enter_op
	syscall
	
	# 4. Read a character from user.
	li $v0, 12
	syscall
	move $s1, $v0

	# print newline
	li $v0, 4
	la $a0, newline
	syscall

	# 5. Print the following prompt message:
	# Please enter an integer:
	li $v0, 4
	la $a0, enter_int
	syscall
	
	# 6. Read an integer from user.
	li $v0, 5
	syscall
	move $s2, $v0

	# 7. Call do_math. Pass the two integers and the operator using registers.
	move $a0, $s0	#first int
	move $a1, $s1	#operator
	move $a2, $s2	#second int
	jal do_math
done:
	lw $ra, 0($sp)

	addi $sp, $sp, 4
	
	# 8. Return 0 from main using jr (do not use the 'exit' syscall).
	add $v0, $0, $0
	jr $ra

do_math:
	jr $ra

.data
	enter_int: .asciiz "Please enter an integer: "
	enter_op: .asciiz "Please enter an operator (+, -, *, /): "
	newline: .asciiz "\n"
