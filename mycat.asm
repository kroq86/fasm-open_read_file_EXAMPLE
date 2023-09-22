format ELF64 executable

include "linux.inc"

file_handle dq 0
filename db 'lol.txt', 0
buffer_size equ 1024
buffer rb buffer_size

segment readable executable
entry main

main:
    syscall3 SYS_write, STDOUT, greet_msg, greet_msg_len

open:
    mov rax, 2
    mov rdi, filename
    mov rsi, 0
    mov rdx, 0
    syscall
    mov r8, rax
    
read:
    mov rax, 0
    mov rdi, r8
    mov rsi, buffer
    mov rdx, buffer_size
    syscall

print:    
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    syscall

close:
    mov rax, 3
    mov rdi, r8
    syscall

exit EXIT_SUCCESS

 
segment readable writeable

greet_msg db "Start", 10
greet_msg_len = $ - greet_msg

open_failed_msg db "Failed to open the file.", 10
open_failed_msg_len = $ - open_failed_msg

