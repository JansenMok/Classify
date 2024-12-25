.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue: Save the caller's stack and register context
    addi sp sp -40
    sw a0 0(sp)
    sw a1 4(sp)
    sw a2 8(sp)
    sw s0 12(sp)                # the pointer to string representing the filename
    sw s1 16(sp)                # a pointer to the number of rows
    sw s2 20(sp)                # a pointer to the number of columns
    sw s3 24(sp)               # the file descriptor
    sw s4 28(sp)               # the pointer to the matrix in memory
    sw s5 32(sp)               # save the # of entries
    sw ra 36(sp)    
    # Opening the file
    mv s0 a0
    mv s1 a1
    mv s2 a2
    li a1, 0      # read mode
    jal fopen
    addi t1 x0 -1
    beq a0, t1, erroringopen
    mv s3, a0  # save file descriptor

    # Read the first 4 bytes (number of rows)
    li a2, 4
    mv a1, s1 
    mv a0 s3
    jal fread
    li t1, 4
    bne a0, t1, erroringread
    
    
    # Read the first 4 bytes (number of cols)
    li a2, 4
    mv a1, s2
    mv a0 s3
    jal fread
    li t1, 4
    bne a0, t1, erroringread

    lw t0, 0(s1)                
    lw t1, 0(s2)                
    mul a0, t0, t1              # a0 <- t0 * t1 (# of entries)
    slli s5, a0, 2            # save the # of entries * 4 
    mv a0 s5
    jal malloc
    
    # s0 - the pointer to string representing the filename
    # s1 - a pointer to the number of rows
    # s2 - a pointer to the number of columns
    # s3 - the file descriptor
    # s4 - the pointer to the matrix in memory
    # s5 - total bytes in matrix
    
    
    beq a0, x0, errormalloc
    mv s4, a0  # save matrix pointer

    # Read matrix data into allocated memory
    mv a0, s3 # the file descriptor
    mv a1, s4 # the pointer to the matrix
    mv a2 s5 # total bytes
    jal fread
    bne a0, s5, erroringread

    # Close the file
    mv a0, s3
    jal fclose
    bne a0, x0, errorclose
    
    mv a0 s4
    mv a1 s1
    mv a2 s2
    # Prepare return values
    lw s0 12(sp)                # the pointer to string representing the filename
    lw s1 16(sp)                # a pointer to the number of rows
    lw s2 20(sp)                # a pointer to the number of columns
    lw s3 24(sp)               # the file descriptor
    lw s4 28(sp)               # the pointer to the matrix in memory
    lw s5 32(sp)               # save the # of entries
    lw ra 36(sp)
    addi sp, sp, 40
    jr ra

erroringopen:
    li a0, 27
    jal exit

erroringread:
    li a0, 29
    jal exit

errormalloc:
    li a0, 26
    jal exit

errorclose:
    li a0, 28
    jal exit