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

    # storing saved registers onto stack
    addi sp, sp, -52
    sw ra, 48(sp)
    sw s0, 44(sp)
    sw s1, 40(sp)
    sw s2, 36(sp)
    sw s3, 32(sp)
    sw s4, 28(sp)
    sw s5, 24(sp)
    sw s6, 20(sp)
    sw s7, 16(sp)
    sw s8, 12(sp)
    sw s9, 8(sp)
    sw s10, 4(sp)
    sw s11, 0(sp)


    # Initialization

    # storing all func parameters into saved registers
    mv s0, a0 # m0 (matrix*)
    mv s1, a1 # m0_height
    mv s2, a2 # m0_width
    mv s3, a3 # m1 (matrix*)
    mv s4, a4 # m1_height
    mv s5, a5 # m1_width
    mv s6, a6 # result (matrix*)

    # initializing cursors
    mv s7, s0 # m0_cursor, does not reset
    mv s8, s3 # m1_cursor, must reset after inner loop finishes

    add s9, x0, x0 # s9 == m0_current_row

outer_loop_start:
    bge s9, s1, outer_loop_end # m0_current_row >= to m0_height then full calculation is finished

    add s10, x0, x0 # s10 is m1_current_col, set/reset to index 0

inner_loop_start:
    bge s10, s5, inner_loop_end # m1_current_col >= m1_width then move onto next row of m0

    # call dot function
    mv a0, s7 # set arr0 pointer to m0_cursor
    mv a1, s8 # set arr1 pointer to m1_cursor
    mv a2, s2 # set num elem to m0_width
    addi a3, x0, 1 # set stride of arr0 as 1
    mv a4, s5 # set stride of arr1 as m1_width

    jal ra, dot

    sw a0, 0(s6) # store returned result

    addi s6, s6, 4 # advance result arr pointer by sizeof(int)
    addi s8, s8, 4 # advance m1_cursor by sizeof(int)
    addi s10, s10, 1 # increment col counter

    j inner_loop_start

inner_loop_end:
    add s10, x0, x0 # reset m1_current_col
    mv s8, s3 # reset cursor pointer

    addi t1, x0, 4 # sizeof(int)
    mul t2, t1, s2 # t2 = sizeof(int) * m0_width
    add s7, s7, t2 # advance m0_cursor by t2 which is width of m0 times by sizeof int

    addi s9, s9, 1 # next row in m0 (simply a counter, no need to scale by elem*sizeofint)

    j outer_loop_start

outer_loop_end:
    # restore saved registers from stack
    lw s11, 0(sp)
    lw s10, 4(sp)
    lw s9, 8(sp)
    lw s8, 12(sp)
    lw s7, 16(sp)
    lw s6, 20(sp)
    lw s5, 24(sp)
    lw s4, 28(sp)
    lw s3, 32(sp)
    lw s2, 36(sp)
    lw s1, 40(sp)
    lw s0, 44(sp)
    lw ra, 48(sp)
    addi sp, sp, 52

    jr ra # return

exception:
    li a0, 38
    j exit
