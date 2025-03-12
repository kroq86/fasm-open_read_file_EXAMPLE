; Common FASM include file for x86_64 Linux
; Contains all reusable patterns, macros, and constants

; Copyright 2025 Kirill Ostapenko <djkroq@gmail.com>

; Permission is hereby granted, free of charge, to any person obtaining
; a copy of this software and associated documentation files (the
; "Software"), to deal in the Software without restriction, including
; without limitation the rights to use, copy, modify, merge, publish,
; distribute, sublicense, and/or sell copies of the Software, and to
; permit persons to whom the Software is furnished to do so, subject to
; the following conditions:

; The above copyright notice and this permission notice shall be
; included in all copies or substantial portions of the Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
; WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
BUFFER_TINY   equ 32     ; For small strings/numbers
BUFFER_SMALL  equ 1024   ; Standard buffer
BUFFER_MEDIUM equ 4096   ; Page size
BUFFER_LARGE  equ 8192   ; Large operations

; Constants for printing
MAGIC_DIV_10_LOW  equ -3689348815    ; Lower 32 bits of magic number
MAGIC_DIV_10_HIGH equ -1             ; Upper 32 bits of magic number
PRINT_BUFFER_SIZE equ 48             ; Buffer size aligned to 16 bytes (40 rounded up)

; Other constants
NULL        equ 0
TRUE        equ 1
FALSE       equ 0
NEWLINE     equ 0xA
SPACE       equ 0x20
NULL_TERM   equ 0

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

macro program_exit code
{
    mov rax, SYS_exit
    mov rdi, code
    syscall
}

; Print array of numbers
macro print_array array, count {
    local .print_loop    ; Make the label local to this macro instance
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

; Print space-separated numbers
macro print_numbers [num1, num2] {
    mov rdi, num1
    call print_no_nl
    mov rdi, SPACE
    call print_char
    mov rdi, num2
    call print
}

; Array operation macros
macro array_element array, index, size {
    array + (index * size)
}

macro array_bounds_check index, max {
    cmp index, max
    jae error_handler
}

macro swap_elements array, i, j, size {
    push rax
    mov rax, [array + i*size]
    xchg rax, [array + j*size]
    mov [array + i*size], rax
    pop rax
}

; Number formatting macros
macro init_number_buffer buffer, size {
    mov byte [buffer + size - 1], 0   ; Null terminator
    mov byte [buffer + size - 2], ' ' ; Space
    lea rbx, [buffer + size - 3]      ; Start position
}

macro convert_number_to_string {
    xor rdx, rdx
    div r12            ; Divide by base
    add dl, '0'        ; Convert to ASCII
    mov [rbx], dl      ; Store digit
    dec rbx
}

; String output macros
macro print_with_newline str, len {
    mov rdi, str
    mov rsi, len
    call print_string
    mov rdi, newline
    mov rsi, 1
    call print_string
}

; Common error handling
macro check_syscall {
    test rax, rax
    js error_handler
}

; Stack frame macros
macro setup_frame {
    push rbp
    mov rbp, rsp
    ; Align stack if needed
    and rsp, -16
}

macro restore_frame {
    mov rsp, rbp
    pop rbp
}

; Common utility functions
print_string:
    push rbp
    push rbx
    mov rbp, rsp
    
    mov rdx, rsi        ; length
    mov rsi, rdi        ; string
    mov rdi, STDOUT     ; file descriptor
    mov rax, SYS_write  ; syscall number
    syscall
    check_syscall
    
    mov rsp, rbp
    pop rbx
    pop rbp
    ret

error_handler:
    ; Print error message if provided
    test rdi, rdi
    jz .exit
    mov rsi, rdx        ; error message length
    call print_string
.exit:
    mov rdi, EXIT_FAILURE
    mov rax, SYS_exit
    syscall

; Common data section
segment readable writeable
    newline db 0xA
    space db ' '
    error_prefix db 'Error: ', 0
    error_suffix db 0xA, 0 