#include <stdint.h>
#include <stddef.h>

extern int binary_search(int *arr, size_t size, int value);

int py_binary_search(int *arr, size_t size, int value) {
    return binary_search(arr, size, value);
}
