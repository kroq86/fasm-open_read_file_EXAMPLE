format ELF64 executable

; Include the Linux headers
include "linux.inc"

; Define a file handle and the filename to open
file_handle dq 0
filename db 'lol.txt', 0

; Define the size of the buffer
buffer_size equ 1024

; Define a buffer to read file contents into
buffer rb buffer_size

segment readable executable
entry main

main:
    ; Print a greeting message to the console
    syscall3 SYS_write, STDOUT, greet_msg, greet_msg_len

open:
    ; Open the file for reading
    mov rax, 2        ; sys_open syscall number
    mov rdi, filename ; Pointer to the filename
    mov rsi, 0        ; Flags (O_RDONLY)
    mov rdx, 0        ; Mode (ignored for O_RDONLY)
    syscall
    test rax, rax     ; Check if syscall returned an error (rax will be negative)
    js open_failed    ; Jump to open_failed label if an error occurred
    mov r8, rax       ; Store the file descriptor in r8
    
read:
    ; Read from the file into the buffer
    mov rax, 0            ; sys_read syscall number
    mov rdi, r8           ; File descriptor
    mov rsi, buffer       ; Pointer to the buffer
    mov rdx, buffer_size  ; Number of bytes to read
    syscall

print:    
    ; Print the contents of the buffer to the console
    mov rax, 1        ; sys_write syscall number
    mov rdi, 1        ; File descriptor (stdout)
    mov rsi, buffer   ; Pointer to the buffer
    syscall

close:
    ; Close the file
    mov rax, 3        ; sys_close syscall number
    mov rdi, r8       ; File descriptor
    syscall

exit EXIT_SUCCESS

open_failed:
    ; Print an error message if file opening failed
    syscall3 SYS_write, STDOUT, open_failed_msg, open_failed_msg_len
    exit EXIT_FAILURE

segment readable writeable

; Define a greeting message and its length
greet_msg db "Start", 10
greet_msg_len = $ - greet_msg

; Define an error message for failed file opening and its length
open_failed_msg db "Failed to open the file.", 10
open_failed_msg_len = $ - open_failed_msg
