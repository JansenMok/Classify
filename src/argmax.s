.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    addi sp sp -4
    sw ra 0(sp)
    addi t0, x0, 1
    blt a1, t0, exception # error 36: len < 1

    mv t0, a0 # t0 is arr pointer
    mv t1, a1 # t1 is num elem in arr
    li t2, 0 # t2 is current "index"
    li t3, -2048 # t3 is current largest found
    li t4, 0 # t4 is max "index"

loop_start:
    beq t1, x0, loop_end # end condition when num elem reaches 0

    lw t5, 0(t0) # deref arr pointer
    blt t3, t5, found_larger # branch if found element (t2) greater than current largest (t3)
not_larger:
    j loop_continue # continue if element wasnt larger

found_larger:
    mv t3, t5 # t3 = t2;
    mv t4, t2

loop_continue:
    addi t0, t0, 4 # increment arr pointer forward 4 bytes
    addi t1, t1, -1 # decrement num elem for terminating condition
    addi t2, t2, 1 # increment index to be returned
    j loop_start

loop_end:
    # Epilogue
    mv a0, t4 # set function return value (a0) to index (t4)
    sw ra 0(sp)
    addi sp sp 4
    jr ra

exception:
    li a0, 36
    j exit
