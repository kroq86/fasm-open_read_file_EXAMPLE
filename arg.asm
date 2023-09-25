format ELF64 executable

include "linux.inc"

buffer_size equ 1024
buffer rb buffer_size

segment readable executable
entry main
main:
    mov rsi, rsp
    add rsi, 8 
    mov rdi, [rsp]
    cmp rdi, 2
    jl error

    mov rdx, [rsi]
    mov [argument], rdx
    add qword [argument], 4

find_eq:  
    mov rsi, [argument]
    xor rcx, rcx
    while_loop:
        mov al, [rsi + rcx]   ; Load the current character
        cmp al, 0             ; Check for null terminator
        je end_while          ; If null terminator, exit the loop
        inc rcx               ; Move to the next character
        jmp while_loop

    end_while:
        xor rdx, rdx
        find_equals:
            mov al, [rsi + rdx]
            cmp al, '='
            je found_equals
            inc rdx
            jmp find_equals

        found_equals:
            sub rdx, rcx
            remove_loop:
                mov rsi, [argument]   ; Reset rsi to the beginning of the argument string
                add rsi, rcx          ; Move rsi to the end of the string
                sub rsi, rdx          ; Subtract the distance from '='
                mov byte [rsi], 0     ; Null-terminate the string at this position
            sub rdx, 5
            jge do_delete

do_delete:
    mov rsi, argument     ; Reset rsi to the beginning of the argument string
    add rsi, rcx          ; Move rsi to the end of the string
    sub rsi, rdx          ; Subtract the distance from the end
    mov byte [rsi], 0     ; Null-terminate the string at this position

    
    syscall3 SYS_write, STDOUT, [argument], rdx
    syscall3 SYS_write, STDOUT, myVariable, 16

open:
int3
    mov rax, 2
    mov rdi, [argument]
    mov rsi, 0
    mov rdx, 0
    syscall
    test rax, rax
    js error
    mov r8, rax
    
    syscall3 SYS_read, r8, buffer, buffer_size 
    syscall2 SYS_write,1, buffer
    
close:
    mov rax, 3
    mov rdi, r8
    syscall    
    
    
    exit EXIT_SUCCESS
    
error:
    exit EXIT_FAILURE             

   
segment readable writeable
myVariable db 'issuesAll.json', 0
argument dq 0
equals db '='





    

