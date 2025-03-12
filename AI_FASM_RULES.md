# FASM Code Generation Rules for AI

## 1. Program Structure Rules

### 1.1 Required Header
ALWAYS start with:
```nasm
format ELF64 executable    ; For executables
format ELF64              ; For libraries
include "common.inc"      ; Common macros and patterns
```

### 1.2 Segment Order
ALWAYS define segments in this order:
```nasm
segment readable writeable    ; Data first
    ; Constants and variables here

segment readable executable   ; Code second
entry main                   ; Entry point
```

## 2. Memory and Data Rules

### 2.1 Data Declarations
```nasm
; CORRECT order:
buffer_size equ 1024     ; 1. Constants first
error_msg db 'Error', 0  ; 2. Initialized data
buffer rb buffer_size    ; 3. Reserved space last
```

### 2.2 Size Constants
ALWAYS use predefined sizes:
```nasm
BUFFER_TINY   equ 128    ; For small strings
BUFFER_SMALL  equ 1024   ; Standard buffer
BUFFER_MEDIUM equ 4096   ; Page size
BUFFER_LARGE  equ 8192   ; Large operations
```

### 2.3 String Declarations
ALWAYS include terminators:
```nasm
db 'Message', 0      ; Null-terminated
db 'Line', 0xA, 0   ; With newline and null
```

## 3. Register Usage Rules

### 3.1 System Call Parameters
NEVER mix up this order:
```nasm
RAX : System call number
RDI : First argument
RSI : Second argument
RDX : Third argument
R10 : Fourth argument
R8  : Fifth argument
R9  : Sixth argument
```

### 3.2 Register Preservation
ALWAYS preserve in this order:
```nasm
; On entry:
push rbp
push rbx        ; If used
push r12-r15    ; If used

; On exit (REVERSE order):
pop r15-r12
pop rbx
pop rbp
```

### 3.3 Volatile Registers
NEVER assume these preserve values:
```nasm
RAX, RCX, RDX    ; Always volatile
R8-R11           ; Caller-saved
```

## 4. Error Handling Rules

### 4.1 System Calls
ALWAYS check returns:
```nasm
syscall
test rax, rax    ; Check result
js error         ; Negative = error
```

### 4.2 Error Handler Structure
ALWAYS include these components:
```nasm
error_handler:
    ; 1. Print error message
    ; 2. Clean up resources
    ; 3. Exit with failure
```

## 5. Function Implementation Rules

### 5.1 Function Structure
ALWAYS follow this pattern:
```nasm
function_name:
    ; 1. Save registers
    ; 2. Setup stack frame
    ; 3. Function body
    ; 4. Restore stack
    ; 5. Restore registers
    ; 6. Return
```

### 5.2 Parameter Access
PREFER registers over stack:
```nasm
; First 6 parameters in registers
; Additional parameters at [rbp+16], [rbp+24], etc.
```

## 6. Memory Safety Rules

### 6.1 Buffer Operations
ALWAYS check bounds:
```nasm
cmp rax, buffer_size    ; Check size
jae error_handler      ; Handle overflow
```

### 6.2 String Operations
ALWAYS set maximum length:
```nasm
mov rcx, BUFFER_SMALL   ; Set max length
rep movsb              ; Safe copy
```

## 7. Macro Usage Rules

### 7.1 System Call Macros
PREFER safe versions:
```nasm
; Use these:
syscall3_safe SYS_write, STDOUT, msg, len

; Instead of:
mov rax, SYS_write
mov rdi, STDOUT
mov rsi, msg
mov rdx, len
syscall
```

### 7.2 Function Macros
USE provided helpers:
```nasm
funcall2 print_string, message, length
```

## 8. File Operation Rules

### 8.1 File Opening
ALWAYS check mode and permissions:
```nasm
; Reading
open_file filename, O_RDONLY

; Writing (with create)
open_file filename, O_WRONLY or O_CREAT, 0644o
```

### 8.2 File Handling
ALWAYS follow this sequence:
1. Open file
2. Check handle
3. Perform operations
4. Close file
5. Handle errors

## 9. Memory Management Rules

### 9.1 Stack Alignment
ALWAYS maintain 16-byte alignment:
```nasm
sub rsp, 32    ; Align to 16 bytes
```

### 9.2 Memory Access
PREFER structured access:
```nasm
mov eax, [rbx + 4*rcx]    ; Indexed
mov eax, [rbx + struct.field]  ; Structure
```

## 10. Optimization Rules

### 10.1 Loop Optimization
```nasm
; PREFER:
xor rcx, rcx    ; Clear counter
rep movsb      ; Use string ops
```

### 10.2 Condition Codes
PREFER flags over comparisons:
```nasm
test rax, rax    ; Instead of cmp rax, 0
```

## 11. Debug Support Rules

### 11.1 Debug Points
```nasm
debug_break    ; Insert breakpoint
```

### 11.2 Debug Messages
```nasm
print_debug msg, len
```

## 12. Common Patterns

### 12.1 Command Line Arguments
```nasm
main:
    mov r9, [rsp + 16]    ; argv[1]
    test r9, r9           ; Check exists
```

### 12.2 Buffer Processing
```nasm
read_loop:
    read_file fd, buffer, buffer_size
    test rax, rax
    jz done
```

## 13. Safety Checklist

### 13.1 Before System Calls
1. ✓ Correct registers loaded
2. ✓ Valid pointers
3. ✓ Buffer space available
4. ✓ Error handling ready

### 13.2 Before Functions
1. ✓ Parameters in order
2. ✓ Stack aligned
3. ✓ Registers preserved
4. ✓ Return value location clear

## 14. Code Generation Template

### 14.1 Basic Program
```nasm
format ELF64 executable

include "common.inc"

segment readable writeable
    ; Data here

segment readable executable
entry main

main:
    ; Code here
    program_exit EXIT_SUCCESS

error_handler:
    handle_error error_msg, error_msg_len
```

### 14.2 Library Module
```nasm
format ELF64

public function_name

segment readable executable

function_name:
    function_start
    ; Implementation
    function_end
```

## 15. Testing Rules

### 15.1 Function Testing
1. Test null/empty inputs
2. Test maximum sizes
3. Test error conditions
4. Verify register preservation

### 15.2 System Testing
1. Test file operations
2. Test memory operations
3. Test error handling
4. Verify cleanup

## 16. Documentation Requirements

### 16.1 Function Headers
```nasm
; Function: name
; Input:   RDI - first parameter
;          RSI - second parameter
; Output:  RAX - result
; Affects: RCX, RDX
; Notes:   Any special considerations
```

### 16.2 Error Messages
```nasm
error_msg db 'Error: specific description', 0xA, 0
error_msg_len = $ - error_msg
```

## 17. Number Printing Rules

### 17.1 Integer to String Conversion
ALWAYS use this optimized pattern for printing numbers:
```nasm
print:
    mov     r9, -3689348814741910323    ; Magic number for division optimization
    sub     rsp, 40                      ; Reserve stack space
    mov     BYTE [rsp+31], 10           ; Store newline at end
    lea     rcx, [rsp+30]               ; Point to buffer end

.convert_loop:
    mov     rax, rdi                    ; Number to convert in RDI
    lea     r8, [rsp+32]               ; End of buffer pointer
    mul     r9                         ; Optimized division by 10
    mov     rax, rdi
    sub     r8, rcx                    ; Calculate length
    shr     rdx, 3                     ; Quick divide by 8
    lea     rsi, [rdx+rdx*4]           ; Multiply by 5
    add     rsi, rsi                   ; Multiply by 2 (total *10)
    sub     rax, rsi                   ; Get remainder
    add     eax, 48                    ; Convert to ASCII
    mov     BYTE [rcx], al             ; Store digit
    mov     rax, rdi                   ; Preserve number
    mov     rdi, rdx                   ; Move quotient for next iteration
    mov     rdx, rcx                   ; Save current position
    sub     rcx, 1                     ; Move buffer pointer
    cmp     rax, 9                     ; Check if more digits
    ja      .convert_loop              ; Continue if number > 9

    lea     rax, [rsp+32]              ; Calculate string length
    mov     edi, 1                     ; STDOUT
    sub     rdx, rax                   ; Calculate length
    xor     eax, eax                   ; Clear RAX
    lea     rsi, [rsp+32+rdx]          ; Point to start of number
    mov     rdx, r8                    ; Length to write
    mov     rax, 1                     ; SYS_write
    syscall                            ; Write number
    add     rsp, 40                    ; Restore stack
    ret
```

### 17.2 Number Printing Rules
1. ALWAYS use the optimized division method with magic number
2. NEVER use division instruction for base 10 conversion
3. ALWAYS handle the full range of 64-bit integers
4. PREFER stack buffer over static buffer for thread safety
5. ALWAYS include newline handling option
6. ALWAYS preserve all registers except RAX (syscall)

### 17.3 Optimization Techniques
1. Use magic number `-3689348814741910323` for division by 10
2. Use `shr rdx, 3` instead of division for quotient
3. Use `lea` for multiplication by 10 (multiply by 5 then 2)
4. Build string in reverse order for efficiency
5. Combine digit conversion with ASCII adjustment in one step

### 17.4 Buffer Management
1. ALWAYS allocate sufficient stack space (40 bytes standard)
2. PREFER stack allocation over static buffers
3. ALWAYS handle buffer boundaries safely
4. CALCULATE final string length correctly
5. INCLUDE space for newline if needed

### 17.5 Register Usage for Print
```nasm
RDI : Input number to print
R9  : Magic number constant
RAX : Working register / syscall
RCX : Buffer pointer
RDX : Division result / length
RSI : Multiplication result / buffer pointer
R8  : Length calculation
```

### 17.6 Print Function Integration
ALWAYS follow this pattern when using print:
```nasm
; Before calling print:
mov rdi, number_to_print    ; Load number in RDI
call print                  ; Call print function

; For multiple numbers:
push rdi                    ; Save current number if needed
call print
pop rdi                     ; Restore for next operation
```

## 14. Array Handling Rules

### 14.1 Array Declarations
```nasm
; CORRECT array declarations:
array dq 64, 34, 25    ; Initialized array
buffer rb 1024         ; Reserved buffer
array_size equ ($ - array) / 8  ; Size calculation
```

### 14.2 Array Access Patterns
```nasm
; ALWAYS use proper indexing:
mov rax, [array + rdi*8]    ; 64-bit elements
mov eax, [array + rdi*4]    ; 32-bit elements
mov al, [array + rdi]       ; 8-bit elements

; ALWAYS check bounds:
cmp rdi, array_size
jae error_handler
```

### 14.3 Array Iteration
```nasm
; Forward iteration
xor rbx, rbx           ; Clear counter
.loop:
    cmp rbx, length
    jge .done
    ; Process array[rbx]
    inc rbx
    jmp .loop

; Reverse iteration
mov rbx, length
.loop:
    dec rbx
    ; Process array[rbx]
    test rbx, rbx
    jnz .loop
```

## 15. Number Formatting Rules

### 15.1 Integer to String
```nasm
; ALWAYS reserve sufficient buffer:
number_buffer rb 32    ; For 64-bit integers

; CORRECT conversion pattern:
mov rax, number        ; Number to convert
mov r12, 10           ; Base (decimal)
.convert:
    xor rdx, rdx
    div r12           ; Divide by base
    add dl, '0'       ; Convert to ASCII
    mov [buffer + rbx], dl
    dec rbx
    test rax, rax
    jnz .convert
```

### 15.2 Output Formatting
```nasm
; ALWAYS include spacing:
msg db ' '            ; Space between numbers
newline db 0xA        ; Line endings

; String length calculation:
msg_len = $ - msg     ; Without null terminator
```

## 16. Recursive Function Rules

### 16.1 Register Preservation
```nasm
; ALWAYS save used registers:
push rbp
push rbx              ; Callee-saved
push r12-r15         ; If used
mov rbp, rsp

; ALWAYS restore in reverse order:
mov rsp, rbp
pop r15-r12
pop rbx
pop rbp
```

### 16.2 Parameter Passing
```nasm
; First 6 parameters:
rdi - First parameter
rsi - Second parameter
rdx - Third parameter
rcx - Fourth parameter
r8  - Fifth parameter
r9  - Sixth parameter

; Additional parameters on stack:
[rbp + 16] - Seventh parameter
[rbp + 24] - Eighth parameter
```

### 16.3 Recursive Calls
```nasm
; ALWAYS save parameters before recursive call:
mov r12, rdi          ; Save first param
mov r13, rsi          ; Save second param
call recursive_func
mov rdi, r12          ; Restore params
mov rsi, r13
```

## 17. Safety Guidelines

### 17.1 Buffer Operations
```nasm
; ALWAYS initialize buffers:
mov rcx, buffer_size
xor rax, rax
rep stosb            ; Zero buffer

; ALWAYS check buffer space:
lea rax, [rbx + 1]   ; Calculate needed space
cmp rax, buffer_size
ja error_handler
```

### 17.2 Error Handling
```nasm
; ALWAYS check system calls:
syscall
test rax, rax
js error_handler

; ALWAYS provide error messages:
error_msg db 'Error: Buffer overflow', 0
```

## Array Handling Rules

### Array Declaration and Access
1. Always declare array size as a constant or computed value
2. Use proper element size multipliers (1, 2, 4, 8 bytes)
3. Validate array indices before access
4. Use macros for common array operations

Example:
```nasm
; Good - Clear size and element type
array_size equ 100
array rq array_size    ; quad-word array

; Good - Index validation
cmp rax, array_size
jae error_handler
mov rbx, [array + rax*8]

; Bad - No size checking
mov rbx, [array + rax*8]  ; Potential buffer overflow
```

### Array Iteration
1. Initialize counters to zero or array bounds
2. Use appropriate comparison instructions
3. Preserve array bounds in registers
4. Clear loop registers after use

Example:
```nasm
; Good - Clear initialization and bounds checking
xor rcx, rcx          ; Clear counter
mov rdx, array_size   ; Load bound once
.loop:
    mov rax, [array + rcx*8]
    inc rcx
    cmp rcx, rdx
    jb .loop
xor rcx, rcx          ; Clear after use

; Bad - Inefficient and unsafe
mov rcx, 0
.loop:
    mov rax, [array + rcx*8]
    inc rcx
    cmp rcx, array_size  ; Reloads size each iteration
    jb .loop
```

## Recursive Function Rules

### Stack Frame Management
1. Always set up and restore stack frames
2. Align stack to 16 bytes
3. Save and restore all used registers
4. Clear registers after use

Example:
```nasm
; Good - Complete frame management
function:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    
    ; Function body
    
    pop r13
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

; Bad - Incomplete frame
function:
    push rbp
    ; Missing register saves
    ; Function body
    pop rbp
    ret
```

### Parameter Passing
1. Use standard registers (rdi, rsi, rdx, rcx, r8, r9)
2. Save parameters in callee-saved registers
3. Restore parameters for recursive calls
4. Document parameter usage

Example:
```nasm
; Good - Clear parameter handling
quicksort:            ; (array, low, high)
    ; Parameters:
    ; rdi = array base
    ; rsi = low index
    ; rdx = high index
    
    push rbp
    mov rbp, rsp
    push r12         ; Save array
    push r13         ; Save low
    push r14         ; Save high
    
    mov r12, rdi
    mov r13, rsi
    mov r14, rdx

; Bad - Unclear parameters
quicksort:
    push rbp
    mov rbp, rsp
    ; No parameter documentation
    ; No parameter saving
```

## Number Formatting Rules

### Integer Conversion
1. Handle special cases first (zero, negative)
2. Use appropriate buffer sizes
3. Validate input ranges
4. Clear temporary registers

Example:
```nasm
; Good - Complete number handling
convert_number:
    test rax, rax
    jz .zero_case
    js .negative_case
    
    mov r12, 10          ; Base
    lea rbx, [buffer+31] ; End of buffer
    mov byte [rbx], 0    ; Null terminator
    
    ; Conversion loop
    
    xor r12, r12        ; Clear temp register

; Bad - Incomplete handling
convert_number:
    div r12             ; No special cases
    add dl, '0'
    mov [buffer], dl
```

## Error Handling Rules

### System Call Errors
1. Check return values
2. Handle specific error codes
3. Provide error messages
4. Clean up resources

Example:
```nasm
; Good - Complete error handling
    mov rax, SYS_write
    syscall
    test rax, rax
    js .error
    
.error:
    neg rax
    mov rdi, error_msg
    call print_error
    jmp cleanup

; Bad - No error checking
    mov rax, SYS_write
    syscall
    ; Continue without checking
```

## Memory Safety Rules

### Buffer Operations
1. Check buffer sizes before operations
2. Use bounds-checked copy operations
3. Maintain null termination
4. Clear sensitive data

Example:
```nasm
; Good - Safe buffer handling
    mov rcx, dst_size
    cmp rcx, src_size
    jb .buffer_overflow
    
    rep movsb
    mov byte [rdi-1], 0
    
    ; Clear sensitive data
    push rcx
    mov rcx, src_size
    xor rax, rax
    rep stosb
    pop rcx

; Bad - Unsafe copy
    mov rcx, src_size
    rep movsb           ; No size check
```

## Register Usage Rules

### Register Allocation
1. Use caller-saved registers for temporary values
2. Save and restore callee-saved registers
3. Clear sensitive data from registers
4. Document register usage

Example:
```nasm
; Good - Clear register usage
    ; rax = loop counter
    ; rbx = array element
    ; r12 = array base
    push rbx
    push r12
    
    ; Function body
    
    xor rax, rax    ; Clear sensitive data
    pop r12
    pop rbx

; Bad - Unclear usage
    push rbx
    ; No documentation
    ; No clearing
    pop rbx
```

## Code Organization Rules

### Function Structure
1. Group related functions
2. Document dependencies
3. Maintain consistent calling conventions
4. Use meaningful labels

Example:
```nasm
; Good - Clear structure
section .text
; Array manipulation functions
array_init:
array_sort:
array_search:

; String handling functions
string_copy:
string_compare:

; Bad - Mixed functions
function1:
string_func:
array_func:
helper: 
```

## 1. Symbol Conflict Prevention Rules

### 1.1 Common Include Files
ALWAYS check for symbol conflicts with common.inc:
```nasm
; DON'T redefine these symbols (they're in common.inc):
; - System calls (SYS_*)
; - File descriptors (STDOUT, STDIN, etc.)
; - Exit codes (EXIT_SUCCESS, EXIT_FAILURE)
; - Common constants (SPACE, NEWLINE)
; - Common functions (print_string, etc.)
```

### 1.2 Symbol Naming
ALWAYS use unique prefixes for local symbols:
```nasm
; CORRECT - Unique prefixes
msg_program_name db 'MyProgram', 0
array_buffer rb 1024
number_temp dq 0

; WRONG - Generic names that might conflict
msg db 'MyProgram', 0    ; Too generic
buffer rb 1024           ; Could conflict
temp dq 0               ; Too generic
```

### 1.3 Function Naming
ALWAYS use descriptive, specific names:
```nasm
; CORRECT - Specific function names
print_array_numbers:     ; Clear purpose
convert_number_decimal:  ; Specific conversion

; WRONG - Generic names that might conflict
print:                  ; Too generic
convert:                ; Too vague
```

## 2. Array Handling Rules

### 2.1 Array Declarations
ALWAYS declare size constants and use proper alignment:
```nasm
ARRAY_SIZE equ 10              ; Size constant
array dq 64, 34, 25, 12       ; Aligned data
array_buffer rb ARRAY_SIZE * 8 ; Aligned buffer
```

### 2.2 Array Access
ALWAYS use proper indexing and bounds checking:
```nasm
; Check bounds before access
cmp rsi, ARRAY_SIZE
jae error_handler

; Use correct scaling
mov rax, [array + rsi*8]  ; For qwords
mov eax, [array + rsi*4]  ; For dwords
```

### 2.3 Array Parameters
ALWAYS pass array parameters consistently:
```nasm
; Standard parameter order:
; rdi = array base address
; rsi = array size or low index
; rdx = high index (for range operations)
```

## 3. Recursive Function Rules

### 3.1 Register Preservation
ALWAYS preserve registers in recursive functions:
```nasm
recursive_function:
    push rbp
    push rbx
    push r12-r15    ; Save all used registers
    mov rbp, rsp

    ; Function body

    mov rsp, rbp
    pop r15-r12     ; Restore in reverse order
    pop rbx
    pop rbp
    ret
```

### 3.2 Parameter Handling
ALWAYS save parameters before recursive calls:
```nasm
    mov r12, rdi    ; Save array pointer
    mov r13, rsi    ; Save low index
    mov r14, rdx    ; Save high index

    call recursive_function  ; Recursive call

    mov rdi, r12    ; Restore parameters
    mov rsi, r13
    mov rdx, r14
```

## 4. Number Formatting Rules

### 4.1 Buffer Management
ALWAYS use safe buffer practices:
```nasm
number_buffer rb 32        ; Sufficient size for 64-bit
add rbx, 31               ; Start from end
mov byte [rbx], 0         ; Null terminator
mov byte [rbx-1], SPACE   ; Use constants from common.inc
```

### 4.2 Number Conversion
ALWAYS handle special cases:
```nasm
    test rax, rax
    jz .zero_case     ; Handle zero
    js .negative      ; Handle negative
```

## 5. Common Include Usage Rules

### 5.1 Include Order
ALWAYS include common files first:
```nasm
format ELF64 executable
include 'common.inc'      ; First include
; ... other includes if needed
```

### 5.2 Using Common Functions
ALWAYS use common functions when available:
```nasm
; Use these from common.inc:
call print_string         ; For string output
syscall3_safe SYS_write  ; For safe syscalls
```

### 5.3 Constants Usage
ALWAYS use common constants:
```nasm
mov rdi, STDOUT          ; Use standard FD
mov rdi, EXIT_SUCCESS    ; Use exit codes
mov byte [rbx], NEWLINE  ; Use character constants
```

## 6. Error Handling Rules

### 6.1 Array Bounds
ALWAYS check array bounds:
```nasm
    cmp rsi, ARRAY_SIZE
    jae .error_handler
    
.error_handler:
    mov rdi, error_msg
    call print_string
    jmp exit_error
```

### 6.2 Buffer Overflow Prevention
ALWAYS validate buffer sizes:
```nasm
    lea rax, [rbx + 1]   ; Calculate needed space
    cmp rax, buffer_size
    ja .error_handler
```

## 7. Documentation Rules

### 7.1 Function Headers
ALWAYS document parameters and effects:
```nasm
; Function: sort_array
; Input:   rdi = array pointer
;          rsi = array size
; Output:  sorted array in-place
; Affects: rax, rbx, rcx, rdx
```

### 7.2 Complex Algorithms
ALWAYS document key steps:
```nasm
quicksort:
    ; 1. Base case check
    cmp rsi, rdx
    jge .done

    ; 2. Partition array
    call partition

    ; 3. Recursive sort left partition
    ; ... comments explaining the logic
```

## 18. Coroutines and Generators Implementation

### 18.1 Generator Structure
```nasm
; ALWAYS define a clear generator structure
struc Generator {
    .fresh db 0         ; Is this a fresh generator?
    .dead db 0          ; Is this generator dead?
    align 8             ; Ensure proper alignment
    .rsp dq 0           ; Saved stack pointer
    .stack_base dq 0    ; Base of generator's stack
    .func dq 0          ; Function pointer
}
```

### 18.2 Generator Stack Management
```nasm
; ALWAYS define a clear stack structure
struc GeneratorStack {
    .items dq 0         ; Array of generator pointers
    .count dq 0         ; Number of generators
    .capacity dq 0      ; Capacity of items array
}

; ALWAYS initialize the stack properly
generator_stack: dq 0   ; Global pointer to stack
```

### 18.3 Generator Function Implementation
```nasm
; ALWAYS check generator state first
generator_next:
    ; Check if generator is dead
    cmp byte [rdi + Generator.dead], 0
    jne .dead_generator
    
    ; Check if generator is fresh
    cmp byte [rdi + Generator.fresh], 0
    jne .fresh_generator
    
    ; Handle existing generator
    ; ...

.fresh_generator:
    ; Mark generator as not fresh
    mov byte [rdi + Generator.fresh], 0
    
    ; Save generator pointer before calling function
    push rdi
    
    ; Get and validate function pointer
    mov rax, [rdi + Generator.func]
    test rax, rax
    jz .func_error
    
    ; Call function with argument
    mov rdi, rsi
    call rax
    
    ; Restore generator pointer
    pop rdi
    
    ; Mark as dead after completion
    mov byte [rdi + Generator.dead], 1
```

### 18.4 Yield Implementation
```nasm
; ALWAYS keep yield implementation simple
generator_yield:
    ; Just return the argument for simplicity
    mov rax, rdi
    ret
```

### 18.5 Error Handling in Generators
```nasm
; ALWAYS handle error cases
.func_error:
    ; Pop saved generator pointer
    pop rdi
    
    ; Mark generator as dead
    mov byte [rdi + Generator.dead], 1
    
    ; Return NULL
    xor rax, rax
    ret

.dead_generator:
    ; Return NULL for dead generators
    xor rax, rax
    ret
```

### 18.6 Debug Messages
```nasm
; ALWAYS include debug messages for complex operations
section '.rodata' writeable
    dbg_next db 'DEBUG: generator_next called', 0xA, 0
    dbg_next_len = $ - dbg_next
    
    dbg_yield db 'DEBUG: generator_yield called', 0xA, 0
    dbg_yield_len = $ - dbg_yield

; Use debug print macro
debug_print dbg_next, dbg_next_len
```

### 18.7 Foreign Function Interface
```nasm
; ALWAYS export symbols for FFI
public generator_init
public generator_next
public generator_yield
public generator__finish_current

; ALWAYS use standard calling convention
; RDI: First argument (generator pointer)
; RSI: Second argument (value/argument)
; RAX: Return value
```