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
    move $a0, $s0    #first int
    move $a1, $s1    #operator
    move $a2, $s2    #second int
    jal do_math
done:
    lw $ra, 0($sp)

    addi $sp, $sp, 4

    # 8. Return 0 from main using jr (do not use the 'exit' syscall).
    add $v0, $0, $0
    jr $ra

do_math:
# TODO: make sure $a0, $a1 and $a2 aren't being overwritten before they're used
    addi $sp, $sp, -36
    sw $s0, -32($sp)
    sw $s1, -28($sp)
    sw $s2, -24($sp)
    sw $s3, -20($sp)
    sw $s4, -16($sp)
    sw $s5, -12($sp)
    sw $s6, -8($sp)
    sw $s7, -4($sp)
    sw $ra, 0($sp)

    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    lb $s3, add_op
    lb $s4, sub_op
    lb $s5, mul_op
    lb $s6, div_op

    # The do_math function takes as argument three registers and does the following:

#check_op1:
    # 1. If the operator register contains '+', call do_add passing the two integers in
    # registers and receiving the return values in two registers.

    bne $s3, $s1, check_op2
    move $a0, $s0    #set arguments
    move $a1, $s2
    jal do_add
    move $t0, $v0    #move result into $t0

    #PRINT RESULT
    li $v0, 1
    move $a0, $s0    #print X
    syscall
    li $v0, 4
    la $a0, str_add    #print +
    syscall
    li $v0, 1
    move $a0, $s2    #print Y
    syscall
    li $v0, 4 
    la $a0, equal_sign    #print =
    syscall
    li $v0, 1
    move $a0, $t0    #print result
    syscall
    j finish_do_math

check_op2:
    # 2. Otherwise, if the operator register contains '-', call do_subtract passing the
    # two integers in registers and receiving the return values in two registers.
    
    bne $s4, $s1, check_op3
    move $a0, $s0    #set arguments
    move $a1, $s2
    jal do_sub
    move $t0, $v0    #move result into $t0
    
    #PRINT RESULT
    li $v0, 1
    move $a0, $s0    #print X
    syscall
    li $v0, 4
    la $a0, str_sub    #print +
    syscall
    li $v0, 1
    move $a0, $s2    #print Y
    syscall
    li $v0, 4
    la $a0, equal_sign    #print =
    syscall
    li $v0, 1
    move $a0, $t0    #print result
    syscall
    j finish_do_math

check_op3:
    # 3. Otherwise, if the operator register contains '*', call do_multiply passing
    # the two integers in registers and receiving the return values in two registers.
    bne $s5, $s1, check_op4
    move $a0, $s0    #set arguments
    move $a1, $s2
    jal do_mul
    move $t0, $v0    #move lower 32 bits of product into $v0
    move $t1, $v1    #move upper 32 bits of product into $v1

    #PRINT RESULT
    li $v0, 1
    move $a0, $s0    #print X
    syscall
    li $v0, 4
    la $a0, str_mul    #print *
    syscall
    li $v0, 1
    move $a0, $s2    #print Y
    syscall
    li $v0, 4 
    la $a0, equal_sign    #print =
    syscall
    beq $v1, $zero, print_small_result
    li $v0, 1
    move $a0, $t1    #print higher 32 bits of result
    syscall
    li $v0, 4
    la $a0, str_big_result
    syscall
print_small_result:
    li $v0, 1
    move $a0, $t0    #print lower 32 bits of result
    syscall
    j finish_do_math

check_op4:
    # 4. Otherwise, if the operator register contains '/', call do_divide passing the
    # two integers in registers and receiving the return values in two registers.
    bne $s6, $s1, default
    move $a0, $s0    #set arguments
    move $a1, $s2
    jal do_div
    move $t0, $v0    #move result into $t0
    move $t1, $v1    #move remainder into $t1

    #PRINT RESULT
    li $v0, 1
    move $a0, $s0    #print X
    syscall
    li $v0, 4
    la $a0, str_div    #print /
    syscall
    li $v0, 1
    move $a0, $s2    #print Y
    syscall
    li $v0, 4
    la $a0, equal_sign    #print =
    syscall
    li $v0, 1
    move $a0, $t0    #print result
    syscall
    li $v0, 4
    la $a0, str_remainder
    syscall
    li $v0, 1
    move $a0, $t1    #print remainder
    syscall
    j finish_do_math

default:
    # 5. Otherwise, print the following error message, replacing OP with the character
    # stored in the operator register, and exit the program.
    # Error: invalid arithmetic operation 'OP'.
    li $v0, 4
    la $a0, invalid_op
    syscall
    li $v0, 11    #print char op
    move $a0, $a1
    syscall
    li $v0, 4
    la $a0, end_invalid_op
    syscall
    j finish_do_math
show_result:
    # TODO:
    # 6. Print the following message:
    # X OP Y = Z.
    # Where Z is the arithmetical result of the operation OP conducted on the two
    # integers input from the user, X and Y.

    # If OP is '/' you should replace Z with Q remainder R, where Q is the
    # quotient and R the remainder, for example:
    # 4 / 3 = 1 remainder 1

    # If OP is '*' and the most-significant 32-bits of the 64-bit product are nonzero,
    # you should show the result Z as Z_h * 4294967296 + Z_l where
    # Z_h is the integer in the most-significant 32-bits and Z_l is the integer in the
    # least significant 32-bits of the product.

#print result
#    li $v0, 4
#    la $a0, result
#    syscall

#print value
#    lw $a0, 0($t7)
#    li $v0, 1
#    syscall

finish_do_math:
    lw $s0, -32($sp)
    lw $s1, -28($sp)
    lw $s2, -24($sp)
    lw $s3, -20($sp)
    lw $s4, -16($sp)
    lw $s5, -12($sp)
    lw $s6, -8($sp)
    lw $s7, -4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 36
    jr $ra

#TODO: fill in the arithmetic functions:
do_add:
#1. Add the two integers without using the 'add*' or 'sub*' MIPS instruction. In
#   particular, use the 'or', 'and', 'xor', 'sll', and 'srl' instructions.
#2. Return the result in a register. If there is an arithmetic overflow, return an
#   error condition identifying that an overflow occurred in another register.

    #$a0 = addend1
    #$a1 = addend2
    #t0 = sum bits
    #t1 = carry bits

add_loop:
    xor $t0, $a0, $a1
    and $t1, $a0, $a1
    sll $t1, $t1, 1
    move $a0, $t0
    move $a1, $t1
    bne $a1, $0, add_loop
    move $v0, $a0    #put sum in $v0
    jr $ra

do_sub:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lui $t0, 0xffff
    ori $t0, 0xffff
    xor $a1, $a1, $t0    #flip all bits to negate second number
    jal do_add    #add the numbers
    
    move $a0, $v0
    ori $a1, $zero, 1
    jal do_add    #add 1 to finish the 2's complement
    #we can conveniently add the 1 here since addition is commutative
    
    #difference is already in $v0
    lw $ra, 0($sp) 
    addi $sp, $sp, 4
    jr $ra

do_mul:
    ##### OPTIMIZED VERSION -- Multiplier = Product
    #$a0 = multiplicand
    #$a1 = product(upper 32 bits)
    #$t0 = product (lower 32 bits)
    #$t1 = carry bits
    addi $sp, $sp, -4
    sw $ra, 0($sp)   #save $ra on the stack

    move $t0, $a1   # $t0 now = lower 32 bits
    li $a1, 0   #load 0 into upper 32 bits of product
mult_loop:
    ori $t3, $a0, 1
    beq $t3, 1, do_add  #if last bit is 1, add multiplicand to upper half of product
    srl $t0, $t0, 1     #shift upper and lower 32 bits right
#   ori $t2, $a1, 1     #get last bit of upper 32 bits and put into $t2
#   sll $t2, $t2, 31     #shift last bit to most significant bit
#   or $t0, $t0, $t2    #add msb of $t2 to msb of $t0
    srl $a1, $a1, 1
    bne $a1, $0, mult_loop   #if upper 32 bits don't = 0, jump to beginning of function
    move $a1, $t0   #put lower 32 bits into $a1

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

do_div:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)

    #$a0 = dividend
    #$a1 = divisor
    
    #$s0 = divisor
    #$s1 = remainder
    #$s2 = quotient
    move $s0, $a1    #divisor
    move $s1, $zero  #init remainder to zero
    move $s2, $a0    #init quotient to dividend

    #$s3 = i = 32
    #i=32; i>0; i--

    li $s3, 32
do_div_loop:
    beq $s3, $zero, finish_do_div
    addi $s3, $s3, -1

    #jointly shift left remainder and quotient
    #first = s1, second = s2
    sll $s1, $s1, 1  #shift 1st reg left
    li $t0, 1
    sll $t0, $t0, 31
    and $t0, $s2, $t0  #get first bit of 2nd reg --> $t0
    srl $t0, $t0, 31
    or $s1, $s1, $t0  #put that bit in last bit of 1st reg
    sll $s2, $s2, 1  #shift 2nd reg left
    
    #rem = rem - divisor
    move $a0, $s1
    move $a1, $s0
    jal do_sub
    move $s1, $v0

    #get sign bit of rem
    li $t0, 1
    sll $t0, $t0, 31
    and $t0, $s1, $t0
    srl $t0, $t0, 31  #unnecessary shift

    beq $t0, $zero, set_quotient_bit
    #if rem < 0
      #rem+=divisor    #we don't have to do this add if we save the prev rem
      move $a0, $s0
      move $a1, $s1
      jal do_add
      move $s1, $v0

      #quo0 = 0
      #ori $s2, $s2, 0  #unnecessary ori since we shifted
    j do_div_loop

set_quotient_bit:
    #else
      #quo0 = 1
      ori $s2, $s2, 1
    j do_div_loop

finish_do_div:
    move $v0, $s2  #return quotient
    move $v1, $s1  #return remainder
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra

.data
enter_int: .asciiz "Please enter an integer: "
enter_op: .asciiz "Please enter an operator (+, -, *, /): "
newline: .asciiz "\n"
add_op: .byte '+'
sub_op: .byte '-'
mul_op: .byte '*'
div_op: .byte '/'
equal_sign: .asciiz " = "
str_remainder: .asciiz " remainder "
str_add: .asciiz " + "
str_sub: .asciiz " - "
str_mul: .asciiz " * "
str_div: .asciiz " / "
str_big_result: .asciiz " * 4294967296 + "
# TODO: fix invalid op output string so that there is no dot before the invalid operator
invalid_op: .ascii "Error: invalid arithmetic operation "
end_invalid_op: .ascii "'."

