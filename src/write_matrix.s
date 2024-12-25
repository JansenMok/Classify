.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

    # Prologue

    addi sp sp -40
    sw a0 0(sp)
    sw a1 4(sp)
    sw a2 8(sp)
    sw s0 12(sp)                # serves as an iterator i
    sw s1 16(sp)                # number of rows
    sw s2 20(sp)                # number of columns
    sw s3 24(sp)               # the file descriptor
    sw s4 28(sp)               # the pointer to the matrix in memory
    sw s5 32(sp)               # save the # of entries
    sw ra 36(sp)    
    # Opening the file
    mv s4 a1
    mv s1 a2
    mv s2 a3
    
    li a1, 1      # write mode
    jal fopen
    addi t1 x0 -1
    beq a0, t1, erroringopen
    mv s3, a0  # save file descriptor
    
    
    mv a0 s3
    addi sp, sp, -4
    sw s1, 0(sp)
    mv a1 sp
    addi sp, sp, 4
    addi a2, x0, 1
    addi a3, x0, 4
    call fwrite                 # fwrite(fp, row, 1, 4)
    li t1 1
    bne a0, t1, erroringwrite    

    mv a0 s3
    addi sp, sp, -4
    sw s2, 0(sp)
    mv a1 sp
    addi sp, sp, 4
    addi a2, x0, 1
    addi a3, x0, 4
    call fwrite                 # fwrite(fp, row, 1, 4)
    li t1 1
    bne a0, t1, erroringwrite  
    

    mul s5, s1, s2              
    mv s0 x0           

writing_loop:
    bgeu s0, s5, epilogueclose
    mv a0 s3
    mv a1 s0
    slli a1 a1 2
    add a1 a1 s4
    addi a2, x0, 1
    addi a3, x0, 4
    call fwrite                 
    li t1 1
    bne a0, t1, erroringwrite  
    addi s0, s0, 1
    j writing_loop






epilogueclose:
    mv a0, s3
    call fclose                 # fclose(fp)
    bne a0, x0, errorclose
    # Epilogue
    lw a1 4(sp)
    lw a2 8(sp)
    lw s0 12(sp)                # serves as an iterator i
    lw s1 16(sp)                # number of rows
    lw s2 20(sp)                # number of columns
    lw s3 24(sp)               # the file descriptor
    lw s4 28(sp)               # the pointer to the matrix in memory
    lw s5 32(sp)               # save the # of entries
    lw ra 36(sp)    
    addi sp sp 40
    jr ra


erroringopen:
    li a0, 27
    jal exit

erroringwrite:
    li a0, 30
    jal exit
errorclose:
    li a0, 28
    jal exit