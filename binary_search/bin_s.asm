format ELF64 executable

segment readable writable
    array db 1, 2, 3, 4
    array_size equ 4
segment readable executable

macro binary_search array, value {
    mov r8, 0                     ; left = 0
    mov r9, array_size            ; right = array_size

.loop:
    cmp r8, r9                    ; while (left <= right)
    ja .not_found                 ; if left > right, not found

    mov rax, r8                   ; rax = left
    add rax, r9                   ; rax = left + right
    shr rax, 1                    ; rax = (left + right) / 2  (middle index)
    mov r10, rax                  ; mid = rax

    movzx r11d, byte [array + r10] ; array[mid]
    cmp r11d, value                ; if (array[mid] == value)
    je .found                      ;   return mid

    cmp r11d, value               ; if (array[mid] < value)
    jl .smaller                   ;  left = mid + 1
    jmp .bigger                   ; else right = mid - 1

.smaller:
    inc r10                       ; mid++
    mov r8, r10                   ; left = mid + 1
    jmp .loop

.bigger:
    dec r10                       ; mid--
    mov r9, r10                   ; right = mid - 1
    jmp .loop

.found:
    mov r12, r10                  ; Save index in r12
    jmp .end

.not_found:
    mov rdi, -1                 

.end:
}

entry main

main:
    binary_search array, 2        
    mov rdi, r12
    call print
    call exit

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

exit:
    mov rax, 60
    xor rdi, rdi
    syscall
