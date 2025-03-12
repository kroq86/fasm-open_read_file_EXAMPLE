#include <stdint.h>
#include <stdlib.h>
#include <string.h>

// Generator stack management
typedef struct {
    void **items;
    size_t count;
    size_t capacity;
} Generator_Stack;

// Use the generator_stack from assembly
Generator_Stack* generator_stack;

extern void generator_init(void);
extern void* generator_next(void* g, void* arg);
extern void generator_restore_context(void* context);
extern void generator_restore_context_with_return(void* context, void* ret);
extern void* generator_yield(void* arg);

// Export our functions with proper visibility
__attribute__((visibility("default")))
void python_generator_init() {
    // Initialize generator stack
    Generator_Stack* stack = malloc(sizeof(Generator_Stack));
    stack->items = malloc(sizeof(void*) * 16);  // Initial capacity
    stack->count = 0;
    stack->capacity = 16;
    
    // Add initial generator (main context)
    void* main_gen = malloc(sizeof(void*) * 8);  // Simple structure for main context
    memset(main_gen, 0, sizeof(void*) * 8);
    stack->items[stack->count++] = main_gen;
    
    // Set the global stack pointer
    generator_stack = stack;
    
    generator_init();
}

__attribute__((visibility("default")))
void* python_generator_next(void* g, void* arg) {
    // Push generator onto stack
    if (generator_stack->count >= generator_stack->capacity) {
        generator_stack->capacity *= 2;
        generator_stack->items = realloc(generator_stack->items, sizeof(void*) * generator_stack->capacity);
    }
    generator_stack->items[generator_stack->count++] = g;
    
    return generator_next(g, arg);
}

__attribute__((visibility("default")))
void python_generator_restore_context(void* context) {
    generator_restore_context(context);
}

__attribute__((visibility("default")))
void python_generator_restore_context_with_return(void* context, void* ret) {
    generator_restore_context_with_return(context, ret);
}

__attribute__((visibility("default")))
void* python_generator_yield(void* arg) {
    return generator_yield(arg);
}

// Dummy main function that just returns success
int main() {
    return 0;
}