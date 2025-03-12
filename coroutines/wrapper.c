#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

// Generator stack management
typedef struct {
    void **items;
    size_t count;
    size_t capacity;
} Generator_Stack;

// Use the generator_stack from assembly
// Make it visible to Python
__attribute__((visibility("default")))
Generator_Stack* generator_stack;

extern void generator_init(Generator_Stack* stack);
extern void* generator_next(void* g, void* arg);
extern void* generator_yield(void* arg);
extern void* generator__finish_current();

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
    memset(main_gen, 0, sizeof(*main_gen));
    stack->items[stack->count++] = main_gen;
    
    // Set the global stack pointer
    generator_stack = stack;
    
    // Initialize the assembly code with our stack
    generator_init(stack);
    
    printf("DEBUG: Generator stack initialized at %p\n", (void*)stack);
    printf("DEBUG: Initial count: %zu\n", stack->count);
}

__attribute__((visibility("default")))
void* python_generator_next(void* g, void* arg) {
    // Push generator onto stack
    if (generator_stack->count >= generator_stack->capacity) {
        generator_stack->capacity *= 2;
        generator_stack->items = realloc(generator_stack->items, sizeof(void*) * generator_stack->capacity);
    }
    
    // Store the generator in the stack
    generator_stack->items[generator_stack->count++] = g;
    
    printf("DEBUG: python_generator_next - stack count: %zu\n", generator_stack->count);
    printf("DEBUG: Generator at %p, arg at %p\n", g, arg);
    
    // Print generator info
    typedef struct {
        char fresh;
        char dead;
        char padding[6];
        void* rsp;
        void* stack_base;
        void* func;
    } Generator;
    
    Generator* gen = (Generator*)g;
    printf("DEBUG: Generator info - fresh: %d, dead: %d, func: %p\n", 
           gen->fresh, gen->dead, gen->func);
    
    // Call the assembly function
    void* result = generator_next(g, arg);
    
    // Pop the generator from the stack
    if (generator_stack->count > 0) {
        generator_stack->count--;
    }
    
    return result;
}

__attribute__((visibility("default")))
void* python_generator_yield(void* arg) {
    printf("DEBUG: python_generator_yield called with arg: %p\n", arg);
    
    // Call the assembly function
    void* result = generator_yield(arg);
    
    printf("DEBUG: python_generator_yield returning: %p\n", result);
    return result;
}

// Dummy main function that just returns success
int main() {
    return 0;
}