.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    addi sp, sp, -60
    sw a1, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)
    sw s10, 44(sp)
    sw s11, 48(sp)
    sw a2, 52(sp)
    sw ra, 56(sp)
    
    li t0, 5
    bne a0, t0, errorargs
    
    # Read pretrained m0
    li a0, 4
    jal malloc
    beq a0, x0, errormalloc
    mv s10, a0 # pointer to rows
    
    li a0, 4
    jal malloc
    beq a0, x0, errormalloc
    mv s11, a0 # pointer to cols
    
    lw a1, 0(sp)
    lw a0, 4(a1)
    mv a1, s10
    mv a2, s11
    jal read_matrix
    mv s0, a0
    lw s4, 0(s10) # rows of m0
    lw s5, 0(s11) # cols of m0
    
    mv a0, s10
    jal free
    mv a0, s11
    jal free

    # Read pretrained m1
    li a0, 4
    jal malloc
    beq a0, x0, errormalloc
    mv s10, a0 # pointer to rows
    
    li a0, 4
    jal malloc
    beq a0, x0, errormalloc
    mv s11, a0 # pointer to cols
    
    lw a1, 0(sp)
    lw a0, 8(a1)
    mv a1, s10
    mv a2, s11
    jal read_matrix
    mv s1, a0
    lw s6, 0(s10) # rows of m1
    lw s7, 0(s11) # cols of m1
    
    mv a0, s10
    jal free
    mv a0, s11
    jal free
    
    # Read input matrix
    li a0, 4
    jal malloc
    beq a0, x0, errormalloc
    mv s10, a0
    
    li a0, 4
    jal malloc
    beq a0, x0, errormalloc
    mv s11, a0
    
    lw a1, 0(sp)
    lw a0, 12(a1)
    mv a1, s10
    mv a2, s11
    jal read_matrix
    mv s2, a0 # pointer to input matrix
    lw s8, 0(s10) # rows of input
    lw s9, 0(s11) # cols of input
    
    mv a0, s10
    jal free
    mv a0, s11
    jal free

    # Compute h = matmul(m0, input)
    mul a0, s4, s9
    slli a0, a0, 2
    jal malloc
    beq a0, x0, errormalloc
    mv s3, a0 # space for h
    
    mv a0, s0 # m0
    mv a1, s4 # rows of m0
    mv a2, s5 # cols of m0
    mv a3, s2 # input
    mv a4, s8 # rows of input
    mv a5, s9 # cols of input
    mv a6, s3 # h
    jal matmul
    
    # h has s4 rows and s9 cols
    # Compute h = relu(h)
    mv a0, s3
    mul a1, s4, s9
    jal relu

    # Compute o = matmul(m1, h)
    mul a0, s6, s9
    slli a0, a0, 2
    jal malloc
    beq a0, x0, errormalloc
    mv s10, a0 # space for temp o
    
    mv a0, s1 # m1
    mv a1, s6 # rows of m1
    mv a2, s7 # cols of m1
    mv a3, s3 # h
    mv a4, s4 # rows of h
    mv a5, s9 # cols of h
    mv a6, s10 # temp_o
    jal matmul
    
    # Write output matrix o
    lw a1, 0(sp)
    lw a0, 16(a1)
    mv a1, s10
    mv a2, s6
    mv a3, s9
    jal write_matrix

    # Compute and return argmax(o)
    mv a0, s10
    mul a1, s6, s9
    jal argmax
    mv s11, a0 # return value

    # If print flag is 0, print the result
    lw a2 52(sp)
    beq a2, x0 gotoprint
    # Free allocated memory
ending:    
    mv a0, s0
    jal free
    mv a0, s1
    jal free
    mv a0, s2
    jal free
    mv a0, s3
    jal free
    mv a0, s10
    jal free
    
    mv a0, s11 # set return value

    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    lw s10, 44(sp)
    lw s11, 48(sp)
    lw ra, 56(sp)
    addi sp, sp, 60
    jr ra

gotoprint:
    mv a0, s11
    jal print_int
    li a0, 10 # newline character
    jal print_char
    j ending

errorargs:
    li a0, 31
    j exit

errormalloc:
    li a0, 26
    j exit