format ELF64 executable
entry main
print:
    mov     r9, -3689348814741910323
    sub     rsp, 40
    mov     BYTE [rsp+31], 10
    lea     rcx, [rsp+30]
.L2:
    mov     rax, rdi
    lea     r8, [rsp+32]
    mul     r9
    mov     rax, rdi
    sub     r8, rcx
    shr     rdx, 3
    lea     rsi, [rdx+rdx*4]
    add     rsi, rsi
    sub     rax, rsi
    add     eax, 48
    mov     BYTE [rcx], al
    mov     rax, rdi
    mov     rdi, rdx
    mov     rdx, rcx
    sub     rcx, 1
    cmp     rax, 9
    ja      .L2
    lea     rax, [rsp+32]
    mov     edi, 1
    sub     rdx, rax
    xor     eax, eax
    lea     rsi, [rsp+32+rdx]
    mov     rdx, r8
    mov     rax, 1
    syscall
    add     rsp, 40
    ret

SYS_read equ 0
SYS_write equ 1
SYS_exit equ 60
SYS_accept equ 43
SYS_close equ 3

STDOUT equ 1
STDERR equ 2

EXIT_SUCCESS equ 0
EXIT_FAILURE equ 1

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

macro fib a, b {
    mov r10, a
    mov r11, b
    mov r12, 1

_loop:
    add r10, r11    ;a + b

    mov rdi, r11
    call print
    mov rdi, r10
    call print

    mov r11, r10    ; new a into b
    mov r10, r12    ; counter into a

    inc r12
    cmp r12, 5
    jle _loop
}

segment readable executable
main:
    mov r8, 1  
    fib r8,r8        
loop_start:
    syscall3 SYS_write, STDOUT, greet_msg, greet_msg_len
    
    inc r8
    cmp r8, 10
    jle loop_start     

    syscall1 SYS_exit, 0

segment readable writeable

greet_msg db "Happy hacking", 10
greet_msg_len = $ - greet_msg
