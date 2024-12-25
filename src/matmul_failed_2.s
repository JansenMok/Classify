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
    addi sp, sp, -44
    sw ra, 40(sp) # store main's ra onto stack before calling dot
    sw s4, 36(sp) # temp return matrix cursor
    sw s3, 32(sp) # m0 row num that is being dotted
    sw s2, 28(sp) # temp pointer to current row head of m0
    sw a3, 24(sp) # storing m1 pointer for inner_loop_end
    sw s1, 20(sp) # storing s1 to follow calling convetion
    sw a0, 16(sp) # storing a0 thru a4 so that dot can use them
    sw a1, 12(sp)
    sw a2, 8(sp)
    sw s0, 4(sp) # storing s0 to follow calling convetion
    sw a4, 0(sp)

    mv s0, a3 # pointer to first elem of col of m1: s0 = a3;
    addi s1, x0, 1 # m1 col counter: s1 = 1;
    mv s2, a0 # pointer to current row of m0: s2 = a0;

outer_loop_start:
    blt a1, s3, outer_loop_end # check if all rows of m0 have been dotted
    addi s3, s3, 1 # increment m0 row counter

    beq s2, a0, inner_loop_start # hack for first loop iteration
    # advance s2 pointer to current row of m0 by width of m0 times size of int
    addi, t0, x0, 4
    mul t0, t0, a2
    addi s2, s2, t0

inner_loop_start:
    # setting dot func parameters
    mv a0, s2 # s2 is matrix* m0
    mv a1, s0 # s0 is matrix* m1
    # a2 already set
    addi a3, x0, 1 # m0's stride is always 1
    mv a4, a5 # m1's stride is width of B in order to get one col

    jal ra, dot
    sw a0, 0(s4) # set result in return matrix pointer

    beq s1, a5, inner_loop_end # # check if finished dot on all m1 cols

    addi s4, a6, 4 # advance return matrix pointer by size of int
    addi s1, s1, 1 # increment m1 cur col tracker NOT by size of int bc a5 is num of nums not size of int
    addi s0, s0, 4 # increment m1 col pointer to get next col by size of int

    j inner_loop_start


inner_loop_end:
    blt a1, s3, outer_loop_end # check if all rows of m0 have been dotted
    addi s4, a6, 4 # advance return matrix pointer by size of int
    lw a3, 24(sp) # restore a3 from stack
    mv s0, a3 # reset s0
    addi s1, x0, 1 # reset s1
    j outer_loop_start

outer_loop_end:
    mv a0, a6

    # Epilogue
    lw a0, 16(sp) # restore a register (not actually needed but whatever)
    lw s1, 20(sp) # restore saved register
    lw s2, 28(sp) # restore saved register
    lw s3, 32(sp) # restore saved register
    lw s4, 36(sp) # restore saved register
    lw ra, 40(sp) # restore return address

    jr ra

exception:
    li a0, 38
    j exit
