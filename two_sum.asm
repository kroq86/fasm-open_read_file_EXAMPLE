; Two Sum Problem: Find indices of two numbers that add up to target
; Example: [2,7,11,15], target=9 -> output: [0,1] (2+7=9)

format ELF64 executable

include 'common.inc'

segment readable writeable
    ; Constants first (following AI rules 2.1)
    array_size equ 6
    
    ; Initialized data second
    msg_input db 'Input array: ', 0
    msg_input_len = $ - msg_input
    msg_target db 'Target sum: ', 0
    msg_target_len = $ - msg_target
    msg_found db 'Found indices: ', 0
    msg_found_len = $ - msg_found
    msg_not_found db 'No solution found', 0xA, 0
    msg_not_found_len = $ - msg_not_found
    
    ; Error messages
    msg_error db 'Error: System call failed', 0xA, 0
    msg_error_len = $ - msg_error
    
    ; Arrays and buffers last
    numbers dq 3, 2, 4, 15, 7, 11    ; Array to search in
    target dq 6                      ; Target sum to find
    result_indices dq 0, 0           ; Will store the found indices

segment readable executable

; Print functions
print:
    push    rbp                     ; Preserve frame pointer
    mov     rbp, rsp               ; Setup new frame
    sub     rsp, PRINT_BUFFER_SIZE ; Reserve aligned buffer space
    mov     BYTE [rsp+31], NEWLINE ; Store newline at end
    lea     rcx, [rsp+30]         ; Point to buffer end

    ; Load magic number in two parts
    mov     r9d, MAGIC_DIV_10_LOW
    shl     r9, 32
    mov     r9d, MAGIC_DIV_10_HIGH

.convert_loop:
    mov     rax, rdi              ; Number to convert in RDI
    lea     r8, [rsp+32]         ; End of buffer pointer
    mul     r9                   ; Optimized division by 10
    mov     rax, rdi
    sub     r8, rcx              ; Calculate length
    shr     rdx, 3               ; Quick divide by 8
    lea     rsi, [rdx+rdx*4]     ; Multiply by 5
    add     rsi, rsi             ; Multiply by 2 (total *10)
    sub     rax, rsi             ; Get remainder
    add     eax, 48              ; Convert to ASCII
    mov     BYTE [rcx], al       ; Store digit
    mov     rax, rdi             ; Preserve number
    mov     rdi, rdx             ; Move quotient for next iteration
    mov     rdx, rcx             ; Save current position
    sub     rcx, 1               ; Move buffer pointer
    cmp     rax, 9               ; Check if more digits
    ja      .convert_loop        ; Continue if number > 9

    lea     rax, [rsp+32]        ; Calculate string length
    mov     edi, STDOUT          ; Use stdout
    sub     rdx, rax             ; Calculate length
    xor     eax, eax             ; Clear RAX
    lea     rsi, [rsp+32+rdx]    ; Point to start of number
    mov     rdx, r8              ; Length to write
    mov     rax, SYS_write       ; System call number
    syscall                      ; Write number
    
    leave                        ; Restore stack frame
    ret

print_no_nl:
    push    rbp                     ; Preserve frame pointer
    mov     rbp, rsp               ; Setup new frame
    sub     rsp, PRINT_BUFFER_SIZE ; Reserve aligned buffer space
    lea     rcx, [rsp+31]         ; Point to buffer end (no newline)

    ; Load magic number in two parts
    mov     r9d, MAGIC_DIV_10_LOW
    shl     r9, 32
    mov     r9d, MAGIC_DIV_10_HIGH

.convert_loop:
    mov     rax, rdi              ; Number to convert
    lea     r8, [rsp+32]         ; End pointer
    mul     r9                   ; Divide by 10
    mov     rax, rdi
    sub     r8, rcx              ; Length
    shr     rdx, 3               ; Quick divide
    lea     rsi, [rdx+rdx*4]     ; Times 10
    add     rsi, rsi
    sub     rax, rsi             ; Remainder
    add     eax, 48              ; To ASCII
    mov     BYTE [rcx], al       ; Store
    mov     rax, rdi             ; Save
    mov     rdi, rdx             ; Next
    mov     rdx, rcx             ; Position
    sub     rcx, 1               ; Move
    cmp     rax, 9               ; More?
    ja      .convert_loop        ; Continue

    lea     rax, [rsp+32]        ; Length calc
    mov     edi, STDOUT          ; Output
    sub     rdx, rax             ; Length
    xor     eax, eax             ; Clear
    lea     rsi, [rsp+32+rdx]    ; Buffer
    mov     rdx, r8              ; Count
    mov     rax, SYS_write       ; Write
    syscall
    
    leave                        ; Restore stack frame
    ret

print_char:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16              ; Align stack
    mov     [rsp], dil           ; Store character
    mov     rax, SYS_write
    mov     rdi, STDOUT
    lea     rsi, [rsp]
    mov     rdx, 1
    syscall
    leave
    ret

; Main program entry
entry main

; Function: main
; Input:   none
; Output:  none
; Affects: RAX, RDI, RSI, RDX
main:
    ; Print input array
    syscall3_safe SYS_write, STDOUT, msg_input, msg_input_len
    print_array numbers, array_size
    
    ; Print target
    syscall3_safe SYS_write, STDOUT, msg_target, msg_target_len
    mov rdi, [target]
    call print
    
    ; Find two sum
    call find_two_sum
    
    ; Check if solution found (RAX will be 1 if found, 0 if not)
    test rax, rax
    jz .not_found
    
    ; Print result indices
    syscall3_safe SYS_write, STDOUT, msg_found, msg_found_len
    print_array result_indices, 2
    jmp .exit
    
.not_found:
    syscall3_safe SYS_write, STDOUT, msg_not_found, msg_not_found_len
    
.exit:
    program_exit EXIT_SUCCESS

; Function: find_two_sum
; Input:   none (uses global variables)
; Output:  RAX = 1 if found, 0 if not found
; Affects: RAX, R12-R15
; Notes:   Updates result_indices with found indices
find_two_sum:
    ; Save registers (following AI rules 3.2)
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    ; Register allocation (following AI rules documentation)
    ; R12 = outer loop counter (i)
    ; R13 = inner loop counter (j)
    ; R14 = target value
    ; R15 = array base
    
    mov r14, [target]        ; Load target value
    lea r15, [numbers]       ; Load array base address
    xor r12, r12            ; i = 0
    
.outer_loop:
    ; Check bounds (following AI rules 6.1)
    cmp r12, array_size - 1
    jae .not_found
    
    mov r13, r12            ; j = i
    inc r13                 ; j = i + 1
    
.inner_loop:
    ; Check bounds
    cmp r13, array_size
    jae .next_outer
    
    ; Calculate sum of numbers[i] + numbers[j]
    mov rax, [r15 + r12*8]  ; Load numbers[i]
    add rax, [r15 + r13*8]  ; Add numbers[j]
    
    ; Compare with target
    cmp rax, r14
    je .found
    
    inc r13                 ; j++
    jmp .inner_loop
    
.next_outer:
    inc r12                 ; i++
    jmp .outer_loop
    
.found:
    ; Store found indices
    mov [result_indices], r12
    mov [result_indices + 8], r13
    mov rax, 1              ; Return true
    jmp .return
    
.not_found:
    xor rax, rax            ; Return false
    
.return:
    ; Restore registers in reverse order (AI rules 3.2)
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret 