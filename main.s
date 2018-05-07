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
    # Print the following message:
    # X OP Y = Z.
    # Where Z is the arithmetical result of the operation OP conducted on the two
    # integers input from the user, X and Y.

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
    move $t0, $v0    #move upper 32 bits of product into $t0
    move $t1, $v1    #move lower 32 bits of product into $t1

    #PRINT RESULT
    # If OP is '*' and the most-significant 32-bits of the 64-bit product are nonzero,
    # you should show the result Z as Z_h * 4294967296 + Z_l where
    # Z_h is the integer in the most-significant 32-bits and Z_l is the integer in the
    # least significant 32-bits of the product.

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
    beq $t0, $zero, print_small_result    #if the number is small, only print lower bits
    li $v0, 1
    move $a0, $t0    #print higher 32 bits of result
    syscall
    li $v0, 4
    la $a0, str_big_result
    syscall
print_small_result:
    li $v0, 1
    move $a0, $t1    #print lower 32 bits of result
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
    # If OP is '/' you should replace Z with Q remainder R, where Q is the
    # quotient and R the remainder, for example:
    # 4 / 3 = 1 remainder 1
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

do_add:
#1. Add the two integers without using the 'add*' or 'sub*' MIPS instruction. In
#   particular, use the 'or', 'and', 'xor', 'sll', and 'srl' instructions.
#2. Return the result in a register. If there is an arithmetic overflow, return an
#   error condition identifying that an overflow occurred in another register.

    #$a0 = addend1
    #$a1 = addend2
    #t0 = sum bits
    #t1 = carry bits
    #t2 = msb of addend1
    #t3 = msb of addend2
    #t4 = msb of sum
    #t5 = term1 of overflow eq
    #t6 = term2 of overflow eq

    li $t2, 1
    sll $t2, $t2, 31
    move $t3, $t2    #copy 1<<31 from t2 into t3
    and $t2, $t2, $a0    #get msb
    and $t3, $t3, $a1    #get msb

add_loop:
    xor $t0, $a0, $a1
    and $t1, $a0, $a1
    sll $t1, $t1, 1
    move $a0, $t0
    move $a1, $t1
    bne $a1, $0, add_loop
    move $v0, $a0    #put sum in $v0

    li $t4, 1
    sll $t4, $t4, 31
    and $t4, $t4, $v0    #get msb of sum

    #overflow = a'br + ab'r' 
    #    where a, b, r 
    #    = last bits of addend1, addend2, and result respectively
    #a, b, r = t2, t3, t4
    and $t5, $t3, $t4    #do part of 1st term
    move $t6, $t2    #do part of 2nd term
    not $t2, $t2
    not $t3, $t3
    not $t4, $t4
    and $t5, $t5, $t2    #do rest of 1st term
    and $t6, $t6, $t3    #finish 2nd term    
    and $t6, $t6, $t4
    or $v1, $t5, $t6    #return overflow in v1
    jr $ra

do_sub:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    not $a1, $a1    #flip all bits to do 1st step of 2's complement
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
    #Grade School Multiplication Algorithm

    #1a: 1=> Prod = Prod + Mcand
    #1b: 0 => No operation
    #2: Shift Left Multiplicand
    #3: Shift Right Multiplier
    
    addi $sp, $sp, -28    #7 registers * 4 bytes per word
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    sw $s5, 24($sp)

    #$s0 = mplier = $a0
    #s1 = mcand_high = $0
    #s2 = mcand_low = $a1
    #s3 = prod_high = $0
    #s4 = prod_low = $0
    #s5 = i = 32

    move $s0, $a0
    move $s1, $0
    move $s2, $a1
    move $s3, $0
    move $s4, $0
    addi $s5, $0, 32

do_mul_loop:
    addi $t0, $0, 1
    and $t0, $t0, $s0    #get last bit of multiplier
    beq $t0, $0, do_mul_step_1b    #if it's zero, do step 1b, else do step 1a

    #1a: 1=> Prod = Prod + Mcand
    move $a0, $s1    #first 2 arg registers contain Mcand
    move $a1, $s2
    move $a2, $s3    #next 2 arg registers contain Prod
    move $a3, $s4
    jal do_add_64_bit
    move $s3, $v0    #retrieve result from return registers
    move $s4, $v1

do_mul_step_1b:
    #1b: 0 => No operation
    
    #2: Shift Left Multiplicand
    move $a0, $s1    #first 2 arg registers contain Mcand
    move $a1, $s2
    jal sll_64_bit
    move $s1, $v0
    move $s2, $v1

    #3: Shift Right Multiplier
    srl $s0, $s0, 1

    addi $s5, -1    #i--
    bgtz $s5, do_mul_loop    #loop while i > 0

    move $v0, $s3    #move product to return registers
    move $v1, $s4

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    addi $sp, $sp, 28    #7 registers * 4 bytes per word
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

sll_64_bit:
    #first = a0, second = a1
    sll $a0, $a0, 1  #shift 1st reg left
    li $t0, 1
    sll $t0, $t0, 31
    and $t0, $a1, $t0  #get first bit of 2nd reg --> $t0
    srl $t0, $t0, 31
    or $a0, $a0, $t0  #put that bit in last bit of 1st reg
    sll $a1, $a1, 1  #shift 2nd reg left
    move $v0, $a0
    move $v1, $a1
    jr $ra

srl_64_bit:
    #first = a0, second = a1
    srl $a1, $a1, 1  #shift 2nd reg right
    li $t0, 1
    and $t0, $a0, $t0  #get last bit of 1st reg --> $t0
    sll $t0, $t0, 31
    or $a1, $a1, $t0  #put that bit in first bit of 2nd reg
    srl $a0, $a0, 1  #shift 1st reg right
    move $v0, $a0
    move $v1, $a1
    jr $ra

do_add_64_bit:
    addi $sp, $sp, -28    #7 registers * 4 bytes per word
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    sw $s5, 24($sp)
    
    #s0 = a0 = addend1, higher 32 bits
    #s1 = a1 = addend1, lower 32 bits
    #s2 = a2 = addend2, higher 32 bits
    #s3 = a3 = addend2, lower 32 bits
    #s4 = sum, higher 32 bits
    #s5 = sum, lower 32 bits

    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3

    #add higher 32 bits
    move $a0, $s0
    move $a1, $s2
    jal do_add
    move $s4, $v0

    #add lower 32 bits
    move $a0, $s1
    move $a1, $s3
    jal do_add
    move $s5, $v0
    
    #there's a carry if a sum is less than either addend
    #let's see if there's a carry from the lower 32 bits
    bgt $s1, $s5, add_carry_bit    #addend1_lower > sum_lower
    bgt $s3, $s5, add_carry_bit    #addend2_lower > sum_lower
    j finish_do_add_64_bit
add_carry_bit:
    addi $s4, $s4, 1    #add carry bit to sum, higher 32 bits

finish_do_add_64_bit:
    move $v0, $s4    #return higher 32 bits
    move $v1, $s5    #return lower 32 bits
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    addi $sp, $sp, 28    #7 registers * 4 bytes per word
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
invalid_op: .ascii "Error: invalid arithmetic operation "
end_invalid_op: .ascii "'"


