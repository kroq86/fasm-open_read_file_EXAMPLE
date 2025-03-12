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

## 15. FUNDAMENTAL CONCEPTS

### Registers
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

### Memory Segments
- Text (Code) Segment: Instructions
- Data Segment: Initialized data
- BSS Segment: Uninitialized data
- Stack Segment: Runtime stack

### Data Types
- Byte (db): 8 bits
- Word (dw): 16 bits
- Double Word (dd): 32 bits
- Quad Word (dq): 64 bits
- Ten Bytes (dt): 80 bits

## 16. INSTRUCTION SET

### Data Movement
- MOV: Basic data transfer
- XCHG: Exchange data
- PUSH: Push to stack
- POP: Pop from stack
- LEA: Load effective address

### Arithmetic Operations
- ADD: Addition
- SUB: Subtraction
- MUL: Unsigned multiply
- IMUL: Signed multiply
- DIV: Unsigned divide
- IDIV: Signed divide
- INC: Increment
- DEC: Decrement

### Logical Operations
- AND: Bitwise AND
- OR: Bitwise OR
- XOR: Bitwise XOR
- NOT: Bitwise NOT
- SHL/SAL: Shift left
- SHR: Logical shift right
- SAR: Arithmetic shift right
- ROL: Rotate left
- ROR: Rotate right

### Control Flow
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

## 17. MEMORY AND ADDRESSING

### Addressing Modes
- Immediate: Direct value
- Register: Register content
- Direct: Memory location
- Register Indirect: [register]
- Base+Index: [base+index]
- Scale: [base+index*scale]
- Displacement: [base+displacement]

### Memory Directives
- DB: Define byte
- DW: Define word
- DD: Define double
- DQ: Define quad
- DT: Define ten bytes
- RB: Reserve bytes
- RW: Reserve words
- RD: Reserve doubles
- RQ: Reserve quads

## 18. SYSTEM INTERFACE

### Linux System Calls
- System Call Numbers
- Parameter Passing
- Return Values
- Error Handling

### File Operations
- Opening Files
- Reading
- Writing
- Closing
- Error Checking

### Process Control
- Program Termination
- Process Creation
- Signal Handling
- Memory Management

## 19. OPTIMIZATION TECHNIQUES

### Code Optimization
- Register Usage
- Memory Access
- Loop Optimization
- Branch Prediction
- Instruction Selection

### Memory Optimization
- Alignment
- Caching
- Memory Access Patterns
- Buffer Management

## 20. DEBUGGING AND TOOLS

### Debugging
- GDB Commands
- Breakpoints
- Memory Inspection
- Register Examination
- Stack Tracing

### Common Tools
- FASM Assembler
- Linker
- Debugger
- Binary Utilities 