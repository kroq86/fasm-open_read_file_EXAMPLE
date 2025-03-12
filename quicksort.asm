format ELF64 executable
include 'common.inc'

segment readable writeable
    ARRAY_SIZE equ 10
    msg_unsorted db 'Unsorted array:', 0xA
    msg_unsorted_len = $ - msg_unsorted
    msg_sorted db 0xA, 'Sorted array:', 0xA
    msg_sorted_len = $ - msg_sorted
    array dq 64, 34, 25, 12, 22, 11, 90, 87, 45, 33  ; Test array
    number_buffer rb 32                               ; For number printing

segment readable executable
entry main

quicksort:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    mov rbp, rsp
    
    cmp rsi, rdx
    jge .done           ; If low >= high, return
    
    mov r12, rdi        ; array
    mov r13, rsi        ; low
    mov r14, rdx        ; high
    
    call partition
    mov rbx, rax        ; pivot index
    
    lea rax, [rbx-1]
    mov rdi, r12
    mov rsi, r13
    mov rdx, rax
    call quicksort
    
    lea rax, [rbx+1]
    mov rdi, r12
    mov rsi, rax
    mov rdx, r14
    call quicksort
    
.done:
    mov rsp, rbp
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

partition:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbp, rsp
    
    mov r12, rdi        ; array
    mov r13, rsi        ; low
    mov r14, rdx        ; high
    
    mov rax, [r12 + r14*8]
    mov r15, rax        ; pivot value
    
    mov rbx, r13
    dec rbx             ; i = low - 1
    
    mov r13, rsi        ; j = low
.loop:
    cmp r13, r14
    jge .done
    
    mov rax, [r12 + r13*8]
    cmp rax, r15
    jg .continue
    
    inc rbx
    mov rax, [r12 + rbx*8]
    xchg rax, [r12 + r13*8]
    mov [r12 + rbx*8], rax
    
.continue:
    inc r13
    jmp .loop
    
.done:
    inc rbx
    mov rax, [r12 + rbx*8]
    xchg rax, [r12 + r14*8]
    mov [r12 + rbx*8], rax
    
    mov rax, rbx
    
    mov rsp, rbp
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

print_number:
    push rbp
    push rbx
    push r12
    mov rbp, rsp
    
    mov rax, rdi        ; number to print
    mov r12, 10         ; divisor
    mov rbx, number_buffer
    add rbx, 31         ; start from end
    mov byte [rbx], 0   ; null terminator
    dec rbx
    mov byte [rbx], SPACE ; space after number
    dec rbx
    
.convert_loop:
    xor rdx, rdx
    div r12            ; divide by 10
    add dl, '0'        ; convert to ASCII
    mov [rbx], dl      ; store digit
    dec rbx
    test rax, rax
    jnz .convert_loop
    
    inc rbx            ; point to first digit
    mov rdi, rbx       ; string pointer
    mov rsi, number_buffer   ; calculate length
    add rsi, 31
    sub rsi, rbx       ; rsi = length
    call print_string
    
    mov rsp, rbp
    pop r12
    pop rbx
    pop rbp
    ret

print_array_numbers:
    push rbp
    push rbx
    push r12
    push r13
    mov rbp, rsp
    
    mov r12, rdi        ; array
    mov r13, rsi        ; size
    
    xor rbx, rbx
.print_loop:
    cmp rbx, r13
    jge .done
    
    mov rdi, [r12 + rbx*8]
    call print_number
    
    inc rbx
    jmp .print_loop
    
.done:
    mov rsp, rbp
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

main:
    mov rdi, msg_unsorted
    mov rsi, msg_unsorted_len
    call print_string
    
    mov rdi, array
    mov rsi, ARRAY_SIZE
    call print_array_numbers
    
    mov rdi, array      ; array pointer
    xor rsi, rsi        ; low = 0
    mov rdx, ARRAY_SIZE
    dec rdx             ; high = size-1
    call quicksort
    
    mov rdi, msg_sorted
    mov rsi, msg_sorted_len
    call print_string
    
    mov rdi, array
    mov rsi, ARRAY_SIZE
    call print_array_numbers
    
    mov rdi, newline
    mov rsi, 1
    call print_string
    
    mov rax, SYS_exit
    mov rdi, EXIT_SUCCESS
    syscall 