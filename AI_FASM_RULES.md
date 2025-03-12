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
include "common.inc"

program_init

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