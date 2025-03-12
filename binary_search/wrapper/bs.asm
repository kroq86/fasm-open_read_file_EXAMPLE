format ELF64

public binary_search

binary_search:
    push rbp
    mov rbp, rsp
    ;   1st parameter: RDI
    ;   2nd parameter: RSI
    ;   3rd parameter: RDX
    ;   4th parameter: RCX
    ;   5th parameter: R8
    ;   6th parameter: R9

    ;   int *arr   <-- RDI (Pointer to the beginning of the integer array)
    ;   size_t size  <-- RSI (Number of elements in the array)
    ;   int value  <-- RDX (Value to search for)

    mov r8, 0                     ; left = 0
    mov r9, rsi                   ; right = size
.loop:
    cmp r8, r9                    ; while (left <= right)
    ja .not_found                 ; if left > right, not found
    mov rax, r8                   ; rax = left
    add rax, r9                   ; rax = left + right
    shr rax, 1                    ; rax = (left + right) / 2 (middle index)
    mov r10, rax                  ; mid = rax
    lea r11, [rdi + r10*4]        ; Calculate address of array[mid] (int32_t = 4 bytes)
    mov r11d, [r11]               ; array[mid]
    cmp r11d, edx                 ; if (array[mid] == value)
    je .found                     ; return mid
    cmp r11d, edx                 ; if (array[mid] < value)
    jl .smaller                   ; left = mid + 1
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
    mov rax, r10                  ; Save index in rax (return value)
    jmp .end
.not_found:
    mov rax, -1                   ; Return -1 if not found
.end:
    pop rbp
    ret
