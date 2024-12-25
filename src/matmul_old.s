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
#   a6 (int*)  is the pointer to the start of d
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

    # Error checks for valid matrix dimensions
    addi t0, x0, 1
    blt a1, t0, erroring        # a1 (height of m0) must be >= 1
    blt a2, t0, erroring        # a2 (width of m0) must be >= 1
    blt a4, t0, erroring        # a4 (height of m1) must be >= 1
    blt a5, t0, erroring        # a5 (width of m1) must be >= 1
    bne a2, a4, erroring        # width of m0 must equal height of m1

    # Prologue: Save registers to stack
    addi sp, sp, -44
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    sw s1, 28(sp)
    sw ra, 32(sp)
    sw s2, 36(sp)
    sw s3, 40(sp)

    # Save pointers to m0, m1, and d
    mv s1, a0   # m0 pointer
    mv s2, a3   # m1 pointer
    mv s3, a6   # d pointer

outer_loop_start:
    # Outer loop for each row of m0
inner_loop_start:
    # Inner loop for each column of m1
    mv a0, s1  # Set a0 to current row of m0
    mv a1, s2  # Set a1 to same value as a3
    addi a3, x0, 1  # Set stride of arr0 to 1
    mv a4, a5  # Set stride of arr1 to width of m1
    jal ra, dot  # Call dot product function
    sw a0, 0(s3)  # Store result of dot product in d
    addi s3, s3, 4  # Move to next element in d

    # Reload saved registers
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
inner_loop_end:
    # Check if we are done with the current row of m1
    slli t3, a5, 2  # t3 = 4 * width of m1
    addi s2, s2, 4  # Move to the next column of m1
    add t3, t3, a3  # t3 = t3 + a3
    bge t3, s2, inner_loop_start  # Repeat inner loop if not done

outer_loop_end:
    # Check if we are done with all rows of m0
    slli t2, a2, 2  # t2 = 4 * width of m0
    add s1, s1, t2  # Move to the next row of m0
    mul t2, a1, a2  # t2 = height of m0 * width of m0
    add t2, t2, s1  # t2 = t2 + s1
    bge t2, s1, outer_loop_start  # Repeat outer loop if not done

    # Epilogue: Restore registers from stack
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    lw s1, 28(sp)
    lw ra, 32(sp)
    lw s2, 36(sp)
    lw s3, 40(sp)
    addi sp, sp, 44

    jr ra  # Return from function

erroring:
    li a0, 38  # Load error code 38
    j exit  # Exit program with error code