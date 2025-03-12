format ELF64 executable
include 'common.inc'

; System call numbers
SYS_write equ 1
SYS_exit  equ 60

; File descriptors
STDOUT    equ 1

; Exit codes
EXIT_SUCCESS equ 0

; Data segment following rule 1.2
segment readable writeable
    ; Following rule 2.1 for data declarations
    ARRAY_SIZE equ 10
    msg_unsorted db 'Unsorted array:', 0xA
    msg_unsorted_len = $ - msg_unsorted
    msg_sorted db 0xA, 'Sorted array:', 0xA
    msg_sorted_len = $ - msg_sorted
    space db ' '
    newline db 0xA
    array dq 64, 34, 25, 12, 22, 11, 90, 87, 45, 33  ; Test array
    number_buffer rb 32                               ; For number printing

; Code segment following rule 1.2
segment readable executable
entry main

; Print string function (rdi = string, rsi = length)
print_string:
    push rbp
    push rbx
    mov rbp, rsp
    
    mov rdx, rsi        ; length
    mov rsi, rdi        ; string
    mov rdi, STDOUT     ; file descriptor
    mov rax, SYS_write  ; syscall number
    syscall
    
    mov rsp, rbp
    pop rbx
    pop rbp
    ret

; Following rule 5.1 for function structure
quicksort:
    ; 1. Save registers (rule 3.2)
    push rbp
    push rbx
    push r12
    push r13
    push r14
    mov rbp, rsp
    
    ; 2. Parameters (rule 5.2)
    ; rdi = array start
    ; rsi = low index
    ; rdx = high index
    
    ; 3. Function body
    cmp rsi, rdx
    jge .done           ; If low >= high, return
    
    ; Save parameters
    mov r12, rdi        ; array
    mov r13, rsi        ; low
    mov r14, rdx        ; high
    
    ; Partition
    call partition
    mov rbx, rax        ; pivot index
    
    ; Quicksort left part
    lea rax, [rbx-1]
    mov rdi, r12
    mov rsi, r13
    mov rdx, rax
    call quicksort
    
    ; Quicksort right part
    lea rax, [rbx+1]
    mov rdi, r12
    mov rsi, rax
    mov rdx, r14
    call quicksort
    
.done:
    ; 4. Restore stack and registers (rule 3.2)
    mov rsp, rbp
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; Partition function following rule 5.1
partition:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbp, rsp
    
    ; Save parameters
    mov r12, rdi        ; array
    mov r13, rsi        ; low
    mov r14, rdx        ; high
    
    ; Pivot = array[high]
    mov rax, [r12 + r14*8]
    mov r15, rax        ; pivot value
    
    ; i = low - 1
    mov rbx, r13
    dec rbx
    
    ; for j = low to high-1
    mov r13, rsi        ; j = low
.loop:
    cmp r13, r14
    jge .done
    
    ; if array[j] <= pivot
    mov rax, [r12 + r13*8]
    cmp rax, r15
    jg .continue
    
    ; i++
    inc rbx
    
    ; swap array[i] and array[j]
    mov rax, [r12 + rbx*8]
    xchg rax, [r12 + r13*8]
    mov [r12 + rbx*8], rax
    
.continue:
    inc r13
    jmp .loop
    
.done:
    ; Place pivot in final position
    inc rbx
    mov rax, [r12 + rbx*8]
    xchg rax, [r12 + r14*8]
    mov [r12 + rbx*8], rax
    
    ; Return partition index
    mov rax, rbx
    
    mov rsp, rbp
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; Print number function
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
    mov byte [rbx], ' ' ; space after number
    dec rbx
    
.convert_loop:
    xor rdx, rdx
    div r12            ; divide by 10
    add dl, '0'        ; convert to ASCII
    mov [rbx], dl      ; store digit
    dec rbx
    test rax, rax
    jnz .convert_loop
    
    ; Print the number
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

; Print array with numbers function (renamed to avoid conflict)
print_array_numbers:
    push rbp
    push rbx
    push r12
    push r13
    mov rbp, rsp
    
    mov r12, rdi        ; array
    mov r13, rsi        ; size
    
    ; Print each number
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

; Main function following rule 5.1
main:
    ; Print unsorted array message
    mov rdi, msg_unsorted
    mov rsi, msg_unsorted_len
    call print_string
    
    ; Print array before sorting
    mov rdi, array
    mov rsi, ARRAY_SIZE
    call print_array_numbers
    
    ; Sort array
    mov rdi, array      ; array pointer
    xor rsi, rsi        ; low = 0
    mov rdx, ARRAY_SIZE
    dec rdx             ; high = size-1
    call quicksort
    
    ; Print sorted array message
    mov rdi, msg_sorted
    mov rsi, msg_sorted_len
    call print_string
    
    ; Print array after sorting
    mov rdi, array
    mov rsi, ARRAY_SIZE
    call print_array_numbers
    
    ; Print final newline
    mov rdi, newline
    mov rsi, 1
    call print_string
    
    ; Exit program using syscall
    mov rax, SYS_exit   ; syscall number for exit
    mov rdi, EXIT_SUCCESS ; exit code 0
    syscall             ; make the syscall 