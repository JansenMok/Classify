// a0 == arr0
// a1 == arr1
// a2 == number of elements (width of arr0 or height of arr1)
// a3 == stride of arr0 (basically always 1 in this case)
// a4 == stride of arr1 (width of arr1)

int dot(int* arr0, int* arr1, int num_elem, int arr0_stride, int arr1_stride) {
    // assume this works
}

// --------------
// a0 == m0
// a1 == height of m0
// a2 == width of m0
// a3 == m1
// a4 == height of m1
// a5 == width of m1
// a6 == result arr location

int* matmul(matrix* m0, int m0_height, int m0_width,
        matrix* m1, int m1_height, int m1_width, matrix* result) {

    matrix* m0_cursor = m0; // no need to reset this one
    matrix* m1_cursor = m1; // remember to reset this one

    int m0_current_row = 0;
    while (m0_current_row < m0_height) {

        int m1_current_col = 0;
        while (m1_current_col < m1_width) {

            int m0_stride = 1;
            int dot_result = dot(m0_cursor, m1_cursor, m0_width, m0_stride, m1_width);
            *result = dot_result;

            result += 4; // sizeof(int) == 4 (use addi here)
            m1_cursor += 4; // advance m1 cursor to next elem
            m1_current_col++;
        }

        m1_current_col = 0; // reset
        m1_cursor = m1; // reset pointer asw

        int int_size = 4;
        int m0_advance_size = int_size * m0_width; // no such thing as muli
        m0_cursor += m0_advance_size;

        m0_current_row++;
    }
}
