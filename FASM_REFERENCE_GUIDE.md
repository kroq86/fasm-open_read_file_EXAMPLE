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