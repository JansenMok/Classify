.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    addi sp sp -4
    sw ra 0(sp)
    addi t0, x0, 1
    blt a1, t0, exception # error 36: len < 1
    mv t1, a1 # t1 == num elements
    mv t2, a0 # load arr pointer into t2

loop_start:
    beq t1, x0, loop_end # end if temp_num_elem (t1) equals 0

    lw t3, 0(t2) # deref t2 into t3
    blt t3, x0, negative # check if negative

positive:
    j loop_continue

negative:
    li t4, 0 # temporary register to hold 0 as 4 bytes
    sw x0, 0(t2) # set elem to 0 if neg using set word for 4 bytes

loop_continue:

    addi t2, t2, 4 # move arr pointer forward 4 bytes (size of int)
    addi t1, t1, -1 # decrement temp_num_elem
    j loop_start

loop_end:
    # Epilogue
    sw ra 0(sp)
    addi sp sp 4
    jr ra

exception:
    li a0 36
    j exit
