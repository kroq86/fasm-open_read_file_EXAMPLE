#include <stdint.h>

extern double dot_product(double* v1, double* v2, int length);
extern double vector_norm(double* v, int length);

double py_dot_product(double* v1, double* v2, int length) {
    return dot_product(v1, v2, length);
}

double py_vector_norm(double* v, int length) {
    return vector_norm(v, length);
}
