.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    # Prologue
    addi sp sp -4
    sw ra 0(sp)
    # malformed exception
    addi t0, x0, 1
    blt a2, t0, num_elem_exception
    blt a3, t0, stride_exception
    blt a4, t0, stride_exception

    # initialization
    mv t0, a0
    mv t1, a1
    mv t2, a2
    li t3, 0 # total

loop_start:
    beq t2, x0, loop_end # terminating condition

    lw t4, 0(t0) # deref element in arr0
    lw t5, 0(t1) # deref element in arr1
    mul t5, t4, t5 # multiply elements together

    add t3, t3, t5 # add to total

    li t6, 4 # load size of int
    mul t6, a3, t6 # scale stride with size of int
    add t0, t0, t6 # move pointer to arr0 forward by stride len

    li t6, 4 # load size of int
    mul t6, a4, t6 # scale stride with size of int
    add t1, t1, t6 # move pointer to arr1 forward by stride len

    addi t2, t2, -1 # decrement num elem
    j loop_start

loop_end:
    # Epilogue
    
    mv a0, t3
    lw ra 0(sp)
    addi sp sp 4
    jr ra

num_elem_exception:
    li a0, 36
    j exit

stride_exception:
    li a0, 37
    j exit