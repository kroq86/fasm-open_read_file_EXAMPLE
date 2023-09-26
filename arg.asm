format ELF64 executable

include "linux.inc"

buffer_size equ 1024
buffer rb buffer_size

segment readable executable
entry main

main: 
    mov r9, [rsp + 16]
    test r9, r9
    jz error
    mov rdi, r9
    call strlen

open:
    mov rax, 2
    mov rdi, r9 
    mov rsi, 0
    mov rdx, 0
    syscall
    test rax, rax
    js error
    mov r9, rax
    
syscall3 SYS_read, r9, buffer, buffer_size 
syscall2 SYS_write,1, buffer
    
close:
    mov rax, 3
    mov rdi, r9
    syscall    
 

error: 
    exit EXIT_FAILURE             

exit EXIT_SUCCESS

strlen: 
    push rcx
    xor rcx, rcx

    .strlen_loop: 
        mov byte al, [rdi + rcx]
        cmp al, 0
        je .strlen_cleanup
        inc rcx
        jmp .strlen_loop


    .strlen_cleanup: 
        mov rax, rcx
        pop rcx
        ret


segment readable writable

struc string [data] {
    common
        . db data
        .size = $ - .
}

usage string "[usage]: ./main [arg1]", 0xA, 0x0
