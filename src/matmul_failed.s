.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
    # Error checks
    addi t0, x0, 1
    blt a1, t0, exception # height of A less than 1
    blt a2, t0, exception # width of A less than 1
    blt a4, t0, exception # height of B less than 1
    blt a5, t0, exception # width of B less than 1
    bne a2, a4, exception # width of A != height of B, mul is not possible

    # Prologue
    mv t0, a0 # t0 is matrix* m0
    mv t1, a3 # t1 is matrix* m1
    mv t2, a6 # t2 is ret_arr
    addi t3, t3, 1 # inner counter

    addi sp, sp, -4
    sw ra, 0(sp) # store main's ra onto stack before calling dot

outer_loop_start:


inner_loop_start:
    beq t3, a5, outer_loop_start # break when all columns of m1 has been run through

    # setting up dot function parameters
    mv a0, t0 # arr0 as row-major of m0
    mv a1, t1 # arr1 as row-major of m1
    # a2 width of m0 is dot's num elem to use
    addi a3, a3, 1 # want row of m0, so in row-major order, stride is 1
    mv a4, a5 # want col of m1, so stride should be width of m1

    jal ra, dot # call dot function

    sw a0, 0(t2) # place dot result
    addi t2, t2, 1 # advance ret_arr*

    addi t1, t1, 1 # shift matrix* m1 forward
    addi t3, t3, 1 # increment inner counter

    j inner_loop_start



inner_loop_end:


outer_loop_end:


    # Epilogue


    jr ra

exception:
    li a0, 38
    j exit
