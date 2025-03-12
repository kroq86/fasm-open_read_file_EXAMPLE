; Common FASM include file for x86_64 Linux
; Contains all reusable patterns, macros, and constants

; System calls
SYS_read    equ 0
SYS_write   equ 1
SYS_open    equ 2
SYS_close   equ 3
SYS_lseek   equ 8
SYS_mmap    equ 9
SYS_exit    equ 60
SYS_accept  equ 43

; File descriptors
STDIN       equ 0
STDOUT      equ 1
STDERR      equ 2

; File open modes
O_RDONLY    equ 0
O_WRONLY    equ 1
O_RDWR      equ 2
O_CREAT     equ 64
O_TRUNC     equ 512
O_APPEND    equ 1024

; Protection flags
PROT_READ   equ 1
PROT_WRITE  equ 2
PROT_EXEC   equ 4

; Exit codes
EXIT_SUCCESS equ 0
EXIT_FAILURE equ 1

; Common buffer sizes
BUFFER_TINY   equ 128
BUFFER_SMALL  equ 1024
BUFFER_MEDIUM equ 4096
BUFFER_LARGE  equ 8192

; Syscall macros with error checking
macro syscall1_safe number, a
{
    mov rax, number
    mov rdi, a
    syscall
    test rax, rax
    js error_handler
}

macro syscall2_safe number, a, b
{
    mov rax, number
    mov rdi, a
    mov rsi, b
    syscall
    test rax, rax
    js error_handler
}

macro syscall3_safe number, a, b, c
{
    mov rax, number
    mov rdi, a
    mov rsi, b
    mov rdx, c
    syscall
    test rax, rax
    js error_handler
}

; Basic syscalls without error checking
macro syscall1 number, a
{
    mov rax, number
    mov rdi, a
    syscall
}

macro syscall2 number, a, b
{
    mov rax, number
    mov rdi, a
    mov rsi, b
    syscall
}

macro syscall3 number, a, b, c
{
    mov rax, number
    mov rdi, a
    mov rsi, b
    mov rdx, c
    syscall
}

; Function call helpers
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

macro funcall3 func, a, b, c
{
    mov rdi, a
    mov rsi, b
    mov rdx, c
    call func
}

; String operations
macro strlen str
{
    mov rdi, str
    xor rcx, rcx
    not rcx
    xor al, al
    repne scasb
    not rcx
    dec rcx
}

macro strcpy dest, src
{
    mov rdi, dest
    mov rsi, src
    mov rcx, BUFFER_SMALL
    rep movsb
}

; File operations
macro open_file filename, mode
{
    mov rax, SYS_open
    mov rdi, filename
    mov rsi, mode
    mov rdx, 0644o     ; Default permissions
    syscall
    test rax, rax
    js error_handler
}

macro read_file fd, buffer, size
{
    mov rax, SYS_read
    mov rdi, fd
    mov rsi, buffer
    mov rdx, size
    syscall
    test rax, rax
    js error_handler
}

macro write_file fd, buffer, size
{
    mov rax, SYS_write
    mov rdi, fd
    mov rsi, buffer
    mov rdx, size
    syscall
    test rax, rax
    js error_handler
}

macro close_file fd
{
    mov rax, SYS_close
    mov rdi, fd
    syscall
    test rax, rax
    js error_handler
}

; Function prologue/epilogue
macro function_start
{
    push rbp
    mov rbp, rsp
}

macro function_end
{
    mov rsp, rbp
    pop rbp
    ret
}

; Debug helpers
macro debug_break
{
    int3
}

macro print_debug msg, len
{
    syscall3 SYS_write, STDERR, msg, len
}

; Memory operations
macro memzero buffer, size
{
    mov rdi, buffer
    mov rcx, size
    xor al, al
    rep stosb
}

macro memcpy dest, src, size
{
    mov rdi, dest
    mov rsi, src
    mov rcx, size
    rep movsb
}

; Error handling
macro handle_error msg, msg_len
{
    syscall3 SYS_write, STDERR, msg, msg_len
    syscall1 SYS_exit, EXIT_FAILURE
}

; Stack frame helpers
macro stack_frame_create size
{
    push rbp
    mov rbp, rsp
    sub rsp, size
}

macro stack_frame_destroy
{
    mov rsp, rbp
    pop rbp
}

; Common data structures
struc point
{
    .x dd 0
    .y dd 0
}

struc buffer_info
{
    .data dq 0
    .size dd 0
    .used dd 0
}

; Useful constants
NULL        equ 0
TRUE        equ 1
FALSE       equ 0
NEWLINE     equ 0xA
NULL_TERM   equ 0

; Register preservation
macro preserve_regs
{
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
}

macro restore_regs
{
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
}

; Common program structure
macro program_init
{
    format ELF64 executable
    segment readable writeable
    segment readable executable
    entry main
}

macro program_exit code
{
    syscall1 SYS_exit, code
}

; Optimized integer printing
MAGIC_DIV_10 equ -3689348814741910323  ; Magic number for division by 10
PRINT_BUFFER_SIZE equ 40               ; Standard buffer size for number printing

; Print any 64-bit integer with newline
print:
    mov     r9, MAGIC_DIV_10           ; Load division constant
    sub     rsp, PRINT_BUFFER_SIZE     ; Reserve buffer space
    mov     BYTE [rsp+31], NEWLINE     ; Store newline at end
    lea     rcx, [rsp+30]             ; Point to buffer end

.convert_loop:
    mov     rax, rdi                  ; Number to convert in RDI
    lea     r8, [rsp+32]             ; End of buffer pointer
    mul     r9                       ; Optimized division by 10
    mov     rax, rdi
    sub     r8, rcx                  ; Calculate length
    shr     rdx, 3                   ; Quick divide by 8
    lea     rsi, [rdx+rdx*4]         ; Multiply by 5
    add     rsi, rsi                 ; Multiply by 2 (total *10)
    sub     rax, rsi                 ; Get remainder
    add     eax, 48                  ; Convert to ASCII
    mov     BYTE [rcx], al           ; Store digit
    mov     rax, rdi                 ; Preserve number
    mov     rdi, rdx                 ; Move quotient for next iteration
    mov     rdx, rcx                 ; Save current position
    sub     rcx, 1                   ; Move buffer pointer
    cmp     rax, 9                   ; Check if more digits
    ja      .convert_loop            ; Continue if number > 9

    lea     rax, [rsp+32]            ; Calculate string length
    mov     edi, STDOUT              ; Use stdout
    sub     rdx, rax                 ; Calculate length
    xor     eax, eax                 ; Clear RAX
    lea     rsi, [rsp+32+rdx]        ; Point to start of number
    mov     rdx, r8                  ; Length to write
    mov     rax, SYS_write           ; System call number
    syscall                          ; Write number
    add     rsp, PRINT_BUFFER_SIZE   ; Restore stack
    ret

; Print number without newline
print_no_nl:
    mov     r9, MAGIC_DIV_10         ; Load division constant
    sub     rsp, PRINT_BUFFER_SIZE   ; Reserve buffer space
    lea     rcx, [rsp+31]           ; Point to buffer end (no newline)

.convert_loop:
    mov     rax, rdi                ; Number to convert
    lea     r8, [rsp+32]           ; End pointer
    mul     r9                     ; Divide by 10
    mov     rax, rdi
    sub     r8, rcx                ; Length
    shr     rdx, 3                 ; Quick divide
    lea     rsi, [rdx+rdx*4]       ; Times 10
    add     rsi, rsi
    sub     rax, rsi               ; Remainder
    add     eax, 48                ; To ASCII
    mov     BYTE [rcx], al         ; Store
    mov     rax, rdi               ; Save
    mov     rdi, rdx               ; Next
    mov     rdx, rcx               ; Position
    sub     rcx, 1                 ; Move
    cmp     rax, 9                 ; More?
    ja      .convert_loop          ; Continue

    lea     rax, [rsp+32]          ; Length calc
    mov     edi, STDOUT            ; Output
    sub     rdx, rax               ; Length
    xor     eax, eax               ; Clear
    lea     rsi, [rsp+32+rdx]      ; Buffer
    mov     rdx, r8                ; Count
    mov     rax, SYS_write         ; Write
    syscall
    add     rsp, PRINT_BUFFER_SIZE ; Cleanup
    ret

; Print space-separated numbers
macro print_numbers [num1, num2] {
    mov rdi, num1
    call print_no_nl
    mov rdi, SPACE
    call print_char
    mov rdi, num2
    call print
}

; Print array of numbers
macro print_array array, count {
    mov rbx, array        ; Array pointer
    mov rcx, count        ; Counter
.print_loop:
    mov rdi, [rbx]       ; Load number
    push rcx             ; Save counter
    push rbx             ; Save pointer
    call print_no_nl     ; Print number
    mov rdi, SPACE       ; Print space
    call print_char
    pop rbx              ; Restore pointer
    pop rcx              ; Restore counter
    add rbx, 8          ; Next number
    dec rcx             ; Decrement counter
    jnz .print_loop     ; Continue if not done
    mov rdi, NEWLINE    ; Print final newline
    call print_char
} 