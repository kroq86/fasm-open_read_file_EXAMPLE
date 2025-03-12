# FASM (Flat Assembler) Reference Guide

## 1. SYSTEM CALLS AND FILE OPERATIONS
From linux.inc and mycat.asm:

### System Call Numbers
```nasm
SYS_read  equ 0    ; Read from file
SYS_write equ 1    ; Write to file
SYS_exit  equ 60   ; Exit program
SYS_close equ 3    ; Close file
```

### File Operations
Opening Files:
```nasm
mov rax, 2        ; sys_open
mov rdi, filename ; File path
mov rsi, 0        ; O_RDONLY
syscall
```

### Standard Descriptors
```nasm
STDOUT   equ 1
STDERR   equ 2
```

## 2. FUNCTION MACROS
From linux.inc:

### Function Call Wrappers
```nasm
macro funcall1 func, a
{
    mov rdi, a
    call func
}

macro funcall2 func, a, b
{
    mov rdi, a
    mov rsi, b
    call func
}
```

## 3. MEMORY AND DATA
From mycat.asm:

### Data Definitions
```nasm
file_handle dq 0         ; Quad-word (64-bit)
filename db 'lol.txt', 0 ; Null-terminated string
buffer_size equ 1024     ; Constant
buffer rb buffer_size    ; Reserve bytes
```

### Segments
```nasm
segment readable executable
segment readable writeable
```

## 4. ARITHMETIC AND NUMBER PROCESSING
From fib.asm:

### Number Printing
```nasm
mov r9, -3689348814741910323
mul r9
shr rdx, 3
lea rsi, [rdx+rdx*4]
add rsi, rsi
sub rax, rsi
add eax, 48
```

## 5. CONTROL FLOW

### Program Entry
```nasm
format ELF64 executable
entry main
```

### Error Checking
```nasm
test rax, rax     ; Check error
js error_handler  ; Jump if negative
```

## 6. REGISTER USAGE

### System Calls
- RAX: System call number
- RDI: First argument
- RSI: Second argument
- RDX: Third argument

### Function Parameters
- RDI: First parameter
- RSI: Second parameter
- RDX: Third parameter
- RCX: Fourth parameter

## 7. MEMORY MANAGEMENT

### Buffer Operations
- Fixed-size buffers
- Dynamic allocation
- Stack operations

## 8. EXIT CODES
```nasm
EXIT_SUCCESS equ 0
EXIT_FAILURE equ 1
```

## 9. DEBUGGING

### Common Debug Points
- Error checking after syscalls
- Buffer overflow prevention
- Memory alignment

## 10. OPTIMIZATION

### Register Usage
- Minimize memory access
- Use registers efficiently
- Proper alignment

## 11. COMMON PATTERNS

### File Reading Loop
From mycat.asm:
```nasm
read_loop:
    mov rax, SYS_read
    mov rdi, [file_handle]
    mov rsi, buffer
    mov rdx, buffer_size
    syscall
```

### Function Structure
```nasm
function_name:
    ; Preserve registers if needed
    ; Function body
    ; Restore registers
    ret
```

## 12. SYSTEM INTEGRATION

### Process Control
- Program exit
- File operations
- Standard I/O

## 13. BEST PRACTICES

### Code Organization
- Clear sections
- Consistent naming
- Error handling
- Resource cleanup

## 14. QUICK REFERENCE

### Essential Instructions
- mov: Data movement
- syscall: System calls
- call/ret: Function calls
- push/pop: Stack operations

### Common Registers
- rax: System calls, return values
- rdi, rsi, rdx: Parameters
- rsp: Stack pointer

## 1. FUNDAMENTAL CONCEPTS

### 1.1 Registers
#### General Purpose Registers (64-bit)
- RAX: Accumulator, function return value
- RBX: Base register, preserved across function calls
- RCX: Counter register, loop/string operations
- RDX: Data register, I/O operations
- RSI: Source index, string operations
- RDI: Destination index, string operations
- RBP: Base pointer, frame reference
- RSP: Stack pointer

#### 32-bit Versions
- EAX, EBX, ECX, EDX
- ESI, EDI, EBP, ESP

#### 16-bit Versions
- AX, BX, CX, DX
- SI, DI, BP, SP

#### 8-bit Access
- High: AH, BH, CH, DH
- Low: AL, BL, CL, DL

### 1.2 Memory Segments
- Text (Code) Segment: Instructions
- Data Segment: Initialized data
- BSS Segment: Uninitialized data
- Stack Segment: Runtime stack

### 1.3 Data Types
- Byte (db): 8 bits
- Word (dw): 16 bits
- Double Word (dd): 32 bits
- Quad Word (dq): 64 bits
- Ten Bytes (dt): 80 bits

## 2. INSTRUCTION SET

### 2.1 Data Movement
- MOV: Basic data transfer
- XCHG: Exchange data
- PUSH: Push to stack
- POP: Pop from stack
- LEA: Load effective address

### 2.2 Arithmetic Operations
- ADD: Addition
- SUB: Subtraction
- MUL: Unsigned multiply
- IMUL: Signed multiply
- DIV: Unsigned divide
- IDIV: Signed divide
- INC: Increment
- DEC: Decrement

### 2.3 Logical Operations
- AND: Bitwise AND
- OR: Bitwise OR
- XOR: Bitwise XOR
- NOT: Bitwise NOT
- SHL/SAL: Shift left
- SHR: Logical shift right
- SAR: Arithmetic shift right
- ROL: Rotate left
- ROR: Rotate right

### 2.4 Control Flow
- JMP: Unconditional jump
- CALL: Function call
- RET: Return from function
- Conditional Jumps:
  - JE/JZ: Equal/Zero
  - JNE/JNZ: Not equal/Not zero
  - JG/JNLE: Greater
  - JGE/JNL: Greater or equal
  - JL/JNGE: Less
  - JLE/JNG: Less or equal

## 3. MEMORY AND ADDRESSING

### 3.1 Addressing Modes
- Immediate: Direct value
- Register: Register content
- Direct: Memory location
- Register Indirect: [register]
- Base+Index: [base+index]
- Scale: [base+index*scale]
- Displacement: [base+displacement]

### 3.2 Memory Directives
- DB: Define byte
- DW: Define word
- DD: Define double
- DQ: Define quad
- DT: Define ten bytes
- RB: Reserve bytes
- RW: Reserve words
- RD: Reserve doubles
- RQ: Reserve quads

## 4. SYSTEM INTERFACE

### 4.1 Linux System Calls
- System Call Numbers
- Parameter Passing
- Return Values
- Error Handling

### 4.2 File Operations
- Opening Files
- Reading
- Writing
- Closing
- Error Checking

### 4.3 Process Control
- Program Termination
- Process Creation
- Signal Handling
- Memory Management

## 5. OPTIMIZATION TECHNIQUES

### 5.1 Code Optimization
- Register Usage
- Memory Access
- Loop Optimization
- Branch Prediction
- Instruction Selection

### 5.2 Memory Optimization
- Alignment
- Caching
- Memory Access Patterns
- Buffer Management

## 6. DEBUGGING AND TOOLS

### 6.1 Debugging
- GDB Commands
- Breakpoints
- Memory Inspection
- Register Examination
- Stack Tracing

### 6.2 Common Tools
- FASM Assembler
- Linker
- Debugger
- Binary Utilities

## 7. BEST PRACTICES

### 7.1 Code Organization
- Meaningful Labels
- Consistent Formatting
- Clear Comments
- Modular Design

### 7.2 Error Handling
- Return Codes
- Error Messages
- Recovery Strategies
- Cleanup Procedures

### 7.3 Performance
- Register Allocation
- Memory Access
- Instruction Selection
- Loop Optimization

## 8. ADVANCED TOPICS

### 8.1 SIMD Instructions
- Data Types
- Operations
- Performance
- Use Cases

### 8.2 Floating Point
- FPU Instructions
- SSE Instructions
- Precision Control
- Exception Handling

### 8.3 System Programming
- Interrupt Handling
- Device Access
- Memory Management
- Protection Rings

## 9. QUICK REFERENCE

### 9.1 Common Instructions
- Data Movement
- Arithmetic
- Logic
- Control Flow
- System

### 9.2 Register Usage
- Function Parameters
- Return Values
- Preserved Registers
- Scratch Registers

### 9.3 System Calls
- File Operations
- Process Control
- Memory Management
- I/O Operations

## 10. APPENDIX

### 10.1 Instruction Format
- Opcode
- Operands
- Addressing Modes
- Prefixes

### 10.2 Error Codes
- System Errors
- Runtime Errors
- Common Issues
- Debug Solutions

### 10.3 Resources
- Documentation
- Tools
- References
- Communities

# FASM Assembly Examples Guide

## 1. Basic Program Structure
From mycat.asm:
```nasm
format ELF64 executable
include "linux.inc"

segment readable writeable
    file_handle dq 0
    filename db 'lol.txt', 0
    buffer_size equ 1024
    buffer rb buffer_size

segment readable executable
entry main
```

## 2. System Calls (linux.inc)
```nasm
SYS_read  equ 0
SYS_write equ 1
SYS_exit  equ 60
SYS_close equ 3

STDOUT    equ 1
STDERR    equ 2
```

## 3. Macro Definitions
From linux.inc:
```nasm
macro funcall1 func, a
{
    mov rdi, a
    call func
}

macro funcall2 func, a, b
{
    mov rdi, a
    mov rsi, b
    call func
}
```

## 4. Binary Search Implementation
From binary_search/bin_s.asm:
```nasm
macro binary_search array, value {
    mov r8, 0                      ; left = 0
    mov r9, array_size            ; right = array_size

.loop:
    cmp r8, r9                    ; while (left <= right)
    ja .not_found                 ; if left > right, not found

    mov rax, r8                   ; left
    add rax, r9                   ; left + right
    shr rax, 1                    ; (left + right) / 2
    mov r10, rax                  ; mid = rax

    movzx r11d, byte [array + r10] ; array[mid]
    cmp r11d, value               ; if (array[mid] == value)
    je .found                     ;   return mid
}
```

## 5. File Operations
From mycat.asm:
```nasm
open:
    mov rax, 2        ; sys_open
    mov rdi, filename ; filename
    mov rsi, 0        ; O_RDONLY
    mov rdx, 0        ; mode
    syscall
    test rax, rax     ; error check
```

## 6. Number Processing
From fib.asm:
```nasm
print:
    mov r9, -3689348814741910323
    sub rsp, 40
    mov BYTE [rsp+31], 10
    lea rcx, [rsp+30]
.L2:
    mov rax, rdi
    mul r9
    shr rdx, 3
```

## 7. Data Structures
From binary_search/bin_s.asm:
```nasm
segment readable writable
    array db 1, 2, 3, 4    ; byte array
    array_size equ 4       ; constant
```

## 8. Register Usage Examples

### System Calls
```nasm
mov rax, SYS_write    ; syscall number
mov rdi, STDOUT       ; first arg
mov rsi, buffer       ; second arg
mov rdx, buffer_size  ; third arg
syscall
```

### Arithmetic
```nasm
mov rax, r8           ; copy
add rax, r9           ; add
shr rax, 1           ; divide by 2
```

## 9. Memory Access Patterns

### Direct Memory Access
```nasm
mov BYTE [rsp+31], 10          ; stack write
movzx r11d, byte [array + r10] ; array access
```

### Buffer Operations
```nasm
buffer_size equ 1024    ; constant
buffer rb buffer_size   ; reserve bytes
```

## 10. Control Flow Examples

### Loops
```nasm
.loop:
    cmp r8, r9        ; condition
    ja .not_found     ; jump if above
    ; loop body
    jmp .loop         ; continue loop
```

### Conditionals
```nasm
test rax, rax         ; test result
js error_handler      ; jump if negative
```

## 11. Function Patterns

### Function Entry/Exit
```nasm
function:
    push rbp          ; save base pointer
    mov rbp, rsp      ; new frame
    ; function body
    mov rsp, rbp      ; restore stack
    pop rbp           ; restore base pointer
    ret               ; return
```

## 12. Error Handling
```nasm
test rax, rax         ; check syscall result
js error_handler      ; handle error if negative

EXIT_SUCCESS equ 0
EXIT_FAILURE equ 1
```

## 13. Common Operations

### String Handling
```nasm
filename db 'lol.txt', 0  ; null-terminated string
```

### Buffer Management
```nasm
buffer_size equ 1024      ; size constant
buffer rb buffer_size     ; reserve space
```

## 14. System Integration

### Standard I/O
```nasm
STDOUT equ 1
STDERR equ 2

syscall3 SYS_write, STDOUT, buffer, length
```

## 15. Best Practices from Examples

1. Memory Layout:
   - Separate readable/writable segments
   - Clear data structure definitions
   - Proper alignment

2. Error Handling:
   - Check syscall returns
   - Define error constants
   - Proper cleanup

3. Code Organization:
   - Logical sections
   - Clear labels
   - Consistent formatting

4. Optimization:
   - Efficient register usage
   - Minimal memory access
   - Smart arithmetic (shift vs divide)

## Array Operations

### Array Access Patterns
```nasm
; Direct array access
mov rax, [array + index*8]    ; 64-bit elements
mov eax, [array + index*4]    ; 32-bit elements
mov ax, [array + index*2]     ; 16-bit elements
mov al, [array + index]       ; 8-bit elements

; Using array_element macro
mov rax, [array_element array, index, 8]
```

### Array Iteration
```nasm
; Forward iteration
xor rcx, rcx                  ; Initialize counter
.loop:
    mov rax, [array + rcx*8]  ; Access element
    inc rcx                   ; Next element
    cmp rcx, length          ; Check bounds
    jb .loop                 ; Continue if below length

; Reverse iteration
mov rcx, length              ; Start from end
.loop:
    dec rcx                  ; Previous element
    mov rax, [array + rcx*8] ; Access element
    test rcx, rcx           ; Check if reached start
    jnz .loop               ; Continue if not zero
```

## Sorting Algorithms

### Quicksort Implementation
```nasm
quicksort:
    ; Function prologue
    push rbp
    mov rbp, rsp
    push rbx                ; Preserve registers
    push r12
    push r13
    push r14
    push r15

    ; Parameters:
    ; rdi = array base address
    ; rsi = low index
    ; rdx = high index

    ; Check if partition size > 1
    cmp rsi, rdx
    jge .done

    ; Save parameters
    mov r12, rdi           ; array
    mov r13, rsi           ; low
    mov r14, rdx           ; high

    ; Call partition function
    call partition
    mov r15, rax           ; Save pivot index

    ; Recursively sort left partition
    mov rdi, r12           ; array
    mov rsi, r13           ; low
    lea rdx, [r15-1]       ; pivot-1
    call quicksort

    ; Recursively sort right partition
    mov rdi, r12           ; array
    lea rsi, [r15+1]       ; pivot+1
    mov rdx, r14           ; high
    call quicksort

.done:
    ; Function epilogue
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
```

### Partition Function
```nasm
partition:
    ; Function prologue
    push rbp
    mov rbp, rsp

    ; Parameters:
    ; rdi = array base address
    ; rsi = low index
    ; rdx = high index

    ; Use last element as pivot
    mov rcx, [rdi + rdx*8] ; pivot value
    mov r8, rsi            ; i = low - 1
    dec r8

    ; Iterate through partition
    mov r9, rsi            ; j = low
.loop:
    cmp r9, rdx            ; while j < high
    jge .done

    ; Compare current element with pivot
    mov rax, [rdi + r9*8]
    cmp rax, rcx
    jg .next

    ; If element <= pivot, swap
    inc r8                 ; i++
    push rax
    mov rax, [rdi + r8*8]
    xchg rax, [rdi + r9*8]
    mov [rdi + r8*8], rax
    pop rax

.next:
    inc r9                 ; j++
    jmp .loop

.done:
    ; Place pivot in final position
    inc r8
    mov rax, [rdi + r8*8]
    xchg rax, [rdi + rdx*8]
    mov [rdi + r8*8], rax

    ; Return pivot index
    mov rax, r8

    ; Function epilogue
    mov rsp, rbp
    pop rbp
    ret
```

## Number Formatting

### Integer to String Conversion
```nasm
; Convert number in rax to string
; Buffer address in rdi
; Returns string length in rcx
convert_number:
    push rbp
    mov rbp, rsp
    push rbx
    push r12

    mov r12, 10           ; Base 10
    lea rbx, [rdi + 31]   ; End of buffer
    mov byte [rbx], 0     ; Null terminator
    dec rbx

    ; Handle zero case
    test rax, rax
    jnz .convert
    mov byte [rbx], '0'
    dec rbx
    jmp .done

.convert:
    ; Handle negative numbers
    test rax, rax
    jns .positive
    neg rax
    push rax
    mov byte [rdi], '-'
    pop rax

.positive:
    ; Convert digits
.loop:
    xor rdx, rdx
    div r12              ; rax = quotient, rdx = remainder
    add dl, '0'          ; Convert to ASCII
    mov [rbx], dl        ; Store digit
    dec rbx
    test rax, rax
    jnz .loop

.done:
    ; Calculate length
    lea rcx, [rdi + 31]
    sub rcx, rbx
    inc rbx              ; Point to first digit
    mov rsi, rbx         ; Save start address

    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
```

## Register Usage Guidelines

### Register Preservation
- Caller-saved: RAX, RCX, RDX, R8-R11
- Callee-saved: RBX, RBP, RSP, R12-R15
- Parameter passing: RDI, RSI, RDX, RCX, R8, R9

### Register Allocation in Recursive Functions
1. Save callee-saved registers in prologue
2. Use caller-saved registers for temporary values
3. Pass parameters in standard registers
4. Restore registers in reverse order in epilogue

## Error Handling

### System Call Error Checking
```nasm
; Check syscall result
test rax, rax
js error_handler         ; Jump if sign flag set (negative result)

; Error handler
error_handler:
    neg rax             ; Get positive error code
    ; Handle specific error codes
    cmp rax, EINVAL
    je .invalid_argument
    cmp rax, EACCES
    je .permission_denied
    ; Default error
    jmp .unknown_error
```

## Memory Safety

### Stack Alignment
```nasm
; Proper stack alignment (16-byte)
push rbp
mov rbp, rsp
and rsp, -16            ; Align stack
sub rsp, 32             ; Allocate aligned buffer

; Restore stack
mov rsp, rbp
pop rbp
```

### Buffer Operations
```nasm
; Safe string copy with bounds checking
mov rcx, dst_size       ; Maximum size
lea rdi, [dst]          ; Destination
lea rsi, [src]          ; Source
rep movsb              ; Copy bytes
mov byte [rdi-1], 0    ; Ensure null termination
```

## 1. Common Include Integration

### 1.1 Standard Symbols
```nasm
; System calls from common.inc
SYS_write  ; Write to file descriptor
SYS_exit   ; Exit program

; File descriptors
STDOUT     ; Standard output (1)
STDERR     ; Standard error (2)

; Exit codes
EXIT_SUCCESS  ; Successful exit (0)
EXIT_FAILURE  ; Error exit (1)

; Common constants
SPACE      ; Space character
NEWLINE    ; Newline character
```

### 1.2 Common Functions
```nasm
; String output
print_string:    ; (rdi = string, rsi = length)
syscall3_safe:   ; Safe syscall wrapper
```

## 2. Recursive Algorithm Patterns

### 2.1 Quicksort Implementation
```nasm
quicksort:
    ; Register preservation
    push rbp
    push rbx
    push r12-r14
    mov rbp, rsp

    ; Parameters:
    ; rdi = array base
    ; rsi = low index
    ; rdx = high index

    ; Base case
    cmp rsi, rdx
    jge .done

    ; Save parameters
    mov r12, rdi    ; array
    mov r13, rsi    ; low
    mov r14, rdx    ; high

    ; Partition and recurse
    call partition
    mov rbx, rax    ; pivot

    ; Sort left partition
    mov rdi, r12
    mov rsi, r13
    lea rdx, [rbx-1]
    call quicksort

    ; Sort right partition
    mov rdi, r12
    lea rsi, [rbx+1]
    mov rdx, r14
    call quicksort

.done:
    mov rsp, rbp
    pop r14-r12
    pop rbx
    pop rbp
    ret
```

### 2.2 Partition Function Pattern
```nasm
partition:
    ; Register preservation
    push rbp
    push rbx
    push r12-r15
    mov rbp, rsp

    ; Save parameters
    mov r12, rdi    ; array
    mov r13, rsi    ; low
    mov r14, rdx    ; high

    ; Get pivot
    mov rax, [r12 + r14*8]
    mov r15, rax    ; pivot value

    ; Initialize indices
    mov rbx, r13
    dec rbx         ; i = low - 1

    ; Partition loop
    mov r13, rsi    ; j = low
.loop:
    cmp r13, r14
    jge .done

    ; Compare with pivot
    mov rax, [r12 + r13*8]
    cmp rax, r15
    jg .continue

    ; Swap elements
    inc rbx
    mov rax, [r12 + rbx*8]
    xchg rax, [r12 + r13*8]
    mov [r12 + rbx*8], rax

.continue:
    inc r13
    jmp .loop

.done:
    ; Place pivot
    inc rbx
    mov rax, [r12 + rbx*8]
    xchg rax, [r12 + r14*8]
    mov [r12 + rbx*8], rax

    mov rax, rbx    ; Return pivot index
    
    mov rsp, rbp
    pop r15-r12
    pop rbx
    pop rbp
    ret
```

## 3. Number Formatting Patterns

### 3.1 Integer to String
```nasm
print_number:
    push rbp
    push rbx
    push r12
    mov rbp, rsp

    mov rax, rdi        ; number to print
    mov r12, 10         ; base 10
    mov rbx, buffer
    add rbx, 31         ; end of buffer
    mov byte [rbx], 0   ; null terminator
    dec rbx
    mov byte [rbx], SPACE
    dec rbx

.convert:
    xor rdx, rdx
    div r12            ; divide by 10
    add dl, '0'        ; to ASCII
    mov [rbx], dl      ; store digit
    dec rbx
    test rax, rax
    jnz .convert

    ; Print result
    inc rbx
    mov rdi, rbx
    mov rsi, buffer
    add rsi, 31
    sub rsi, rbx
    call print_string

    mov rsp, rbp
    pop r12
    pop rbx
    pop rbp
    ret
```

## 4. Array Operation Patterns

### 4.1 Array Printing
```nasm
print_array:
    push rbp
    push rbx
    push r12-r13
    mov rbp, rsp

    mov r12, rdi    ; array
    mov r13, rsi    ; size

    xor rbx, rbx    ; counter
.loop:
    cmp rbx, r13
    jge .done

    mov rdi, [r12 + rbx*8]
    call print_number

    inc rbx
    jmp .loop

.done:
    mov rsp, rbp
    pop r13-r12
    pop rbx
    pop rbp
    ret
```

### 4.2 Array Element Swapping
```nasm
; Swap array elements at indices i and j
; rdi = array, rsi = i, rdx = j
swap_elements:
    push rax
    mov rax, [rdi + rsi*8]
    xchg rax, [rdi + rdx*8]
    mov [rdi + rsi*8], rax
    pop rax
    ret
```

## 5. Best Practices

### 5.1 Register Usage in Recursive Functions
- Save callee-saved registers (rbx, r12-r15)
- Use r12-r15 for preserving parameters
- Use rax, rcx, rdx for temporary values
- Restore registers in reverse order

### 5.2 Error Handling
```nasm
; Check array bounds
cmp rsi, array_size
jae error_handler

; Check buffer space
lea rax, [rdi + rcx]
cmp rax, buffer_end
ja error_handler

; Handle errors
error_handler:
    mov rdi, error_msg
    mov rsi, error_len
    call print_string
    mov rdi, EXIT_FAILURE
    call exit
```

### 5.3 Buffer Management
```nasm
; Safe buffer allocation
buffer_size equ 32
buffer rb buffer_size

; Buffer position tracking
lea rbx, [buffer + buffer_size - 1]
mov byte [rbx], 0    ; null terminator
```

## 6. Common Patterns

### 6.1 Program Structure
```nasm
format ELF64 executable
include 'common.inc'

segment readable writeable
    ; Data declarations
    msg db 'Hello', 0
    msg_len = $ - msg

segment readable executable
entry main

main:
    ; Program logic
    mov rdi, msg
    mov rsi, msg_len
    call print_string

    mov rax, SYS_exit
    mov rdi, EXIT_SUCCESS
    syscall
```

### 6.2 Function Template
```nasm
function_name:
    push rbp
    push rbx        ; if used
    push r12-r15    ; if used
    mov rbp, rsp

    ; Function body

    mov rsp, rbp
    pop r15-r12     ; if used
    pop rbx         ; if used
    pop rbp
    ret
```

# FASM Coroutines and Generators Guide

## 1. Coroutine Basics

### 1.1 Generator Structure
```nasm
; Generator structure definition
struc Generator
{
    .fresh db 0         ; Is this a fresh generator?
    .dead db 0          ; Is this generator dead?
    .padding rb 6       ; Padding for alignment
    .rsp dq 0           ; Saved stack pointer
    .stack_base dq 0    ; Base of generator's stack
    .func dq 0          ; Function pointer
}

; Generator stack management
struc Generator_Stack
{
    .items dq 0         ; Array of generator pointers
    .count dq 0         ; Number of generators
    .capacity dq 0      ; Capacity of items array
}
```

### 1.2 Generator Initialization
```nasm
generator_init:
    ; Save generator stack pointer
    mov [generator_stack], rdi
    ret
```

## 2. Generator Implementation

### 2.1 Generator Next Function
```nasm
generator_next:
    ; Check if generator is dead
    cmp byte [rdi + Generator.dead], 0
    jne .dead_generator
    
    ; Check if generator is fresh
    cmp byte [rdi + Generator.fresh], 0
    jne .fresh_generator
    
    ; Handle existing generator
    ; ...
    ret

.fresh_generator:
    ; Mark generator as not fresh
    mov byte [rdi + Generator.fresh], 0
    
    ; Save generator pointer
    push rdi
    
    ; Get function pointer
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
    
    ; Return NULL
    xor rax, rax
    ret

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

### 2.2 Generator Yield Function
```nasm
generator_yield:
    ; Simply return the argument
    mov rax, rdi
    ret
```

## 3. C Wrapper Integration

### 3.1 C Structure Definitions
```c
// Generator structure
typedef struct {
    char fresh;
    char dead;
    char padding[6];
    void* rsp;
    void* stack_base;
    void* func;
} Generator;

// Generator stack management
typedef struct {
    void **items;
    size_t count;
    size_t capacity;
} Generator_Stack;
```

### 3.2 C Wrapper Functions
```c
// Initialize generator system
void python_generator_init() {
    // Initialize generator stack
    Generator_Stack* stack = malloc(sizeof(Generator_Stack));
    stack->items = malloc(sizeof(void*) * 16);  // Initial capacity
    stack->count = 0;
    stack->capacity = 16;
    
    // Add initial generator (main context)
    void* main_gen = malloc(sizeof(void*) * 8);
    memset(main_gen, 0, sizeof(*main_gen));
    stack->items[stack->count++] = main_gen;
    
    // Set the global stack pointer
    generator_stack = stack;
    
    // Initialize the assembly code with our stack
    generator_init(stack);
}

// Call generator_next
void* python_generator_next(void* g, void* arg) {
    // Push generator onto stack
    if (generator_stack->count >= generator_stack->capacity) {
        generator_stack->capacity *= 2;
        generator_stack->items = realloc(generator_stack->items, 
                                        sizeof(void*) * generator_stack->capacity);
    }
    
    // Store the generator in the stack
    generator_stack->items[generator_stack->count++] = g;
    
    // Call the assembly function
    void* result = generator_next(g, arg);
    
    // Pop the generator from the stack
    if (generator_stack->count > 0) {
        generator_stack->count--;
    }
    
    return result;
}

// Call generator_yield
void* python_generator_yield(void* arg) {
    // Call the assembly function
    return generator_yield(arg);
}
```

## 4. Python Integration

### 4.1 Python Structure Definition
```python
class GeneratorStruct(ctypes.Structure):
    _fields_ = [
        ("fresh", ctypes.c_bool),
        ("dead", ctypes.c_bool),
        ("_padding", ctypes.c_char * 6),  # Align to 8 bytes
        ("rsp", ctypes.c_void_p),
        ("stack_base", ctypes.c_void_p),
        ("func", ctypes.c_void_p),
    ]
```

### 4.2 Python Generator Class
```python
class Generator(GeneratorStruct):
    def __init__(self, func):
        super().__init__()
        self.fresh = True
        self.dead = False
        self.func_obj = GENERATOR_FUNC(func)  # Keep reference to prevent GC
        self.func = ctypes.cast(self.func_obj, ctypes.c_void_p).value
        
        # We don't actually use the stack in our simplified implementation
        self.stack_base = 0
        self.rsp = 0
    
    def next(self, arg=None):
        """Send a value to the generator and get the next yielded value."""
        if self.dead:
            return None
        
        try:
            # For the first call, pass self as the argument to the generator function
            if self.fresh:
                return lib.python_generator_next(ctypes.byref(self), ctypes.byref(self))
            else:
                # For subsequent calls, pass the provided argument
                return lib.python_generator_next(ctypes.byref(self), 
                                               ctypes.c_void_p(arg) if arg is not None else None)
        except Exception as e:
            # Mark the generator as dead if an exception occurs
            self.dead = True
            return None
```

### 4.3 Python Generator Function Example
```python
def example_generator(arg):
    try:
        # Convert the argument to a generator pointer
        gen_ptr = ctypes.cast(arg, ctypes.c_void_p).value
        
        # Yield a value and get the first argument from the caller
        result = lib.python_generator_yield(ctypes.c_void_p(1))
        
        # Yield another value and get the second argument from the caller
        result = lib.python_generator_yield(ctypes.c_void_p(2))
        
        # Yield a third value and get the third argument from the caller
        result = lib.python_generator_yield(ctypes.c_void_p(3))
        
    except Exception as e:
        print(f"Exception in generator function: {e}")
    finally:
        # Mark the generator as dead if needed
        if arg:
            try:
                gen = ctypes.cast(arg, ctypes.POINTER(GeneratorStruct))
                if gen:
                    gen.contents.dead = True
            except Exception as e:
                print(f"Error marking generator as dead: {e}")
```

## 5. Best Practices for Coroutines

### 5.1 Generator State Management
1. Always check if a generator is dead before attempting to resume it
2. Mark generators as dead after they complete or encounter errors
3. Use a consistent structure for generator objects
4. Maintain a stack of active generators

### 5.2 Error Handling
1. Check function pointers before calling them
2. Handle exceptions in generator functions
3. Clean up resources when generators complete
4. Provide debug information for troubleshooting

### 5.3 Performance Considerations
1. Minimize context switching overhead
2. Use efficient memory allocation for generator stacks
3. Avoid unnecessary copying of data between contexts
4. Release resources promptly when generators complete

### 5.4 Integration with Host Languages
1. Ensure structure definitions match between assembly, C, and host language
2. Use appropriate calling conventions for cross-language calls
3. Handle memory management consistently across language boundaries
4. Provide clear documentation for API users 