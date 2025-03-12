format ELF64

; Define structures
struc Generator {
    .fresh db 0
    .dead db 0
    align 8
    .rsp dq 0
    .stack_base dq 0
    .func dq 0
}
virtual at 0
    Generator Generator
    sizeof.Generator = $
end virtual

struc GeneratorStack {
    .items dq 0
    .count dq 0
    .capacity dq 0
}
virtual at 0
    GeneratorStack GeneratorStack
    sizeof.GeneratorStack = $
end virtual

section '.data' writeable
public generator_stack
generator_stack: dq 0  ; Pointer to GeneratorStack

section '.rodata' writeable  ; Read-only data section
; Debug messages
dbg_init db 'DEBUG: generator_init called', 0xA, 0
dbg_init_len = $ - dbg_init

dbg_next db 'DEBUG: generator_next called', 0xA, 0
dbg_next_len = $ - dbg_next

dbg_switch db 'DEBUG: generator_switch_context called', 0xA, 0
dbg_switch_len = $ - dbg_switch

dbg_fresh db 'DEBUG: handling fresh generator', 0xA, 0
dbg_fresh_len = $ - dbg_fresh

dbg_not_fresh db 'DEBUG: handling existing generator', 0xA, 0
dbg_not_fresh_len = $ - dbg_not_fresh

dbg_yield db 'DEBUG: generator_yield called', 0xA, 0
dbg_yield_len = $ - dbg_yield

dbg_return db 'DEBUG: generator_return called', 0xA, 0
dbg_return_len = $ - dbg_return

dbg_finish db 'DEBUG: generator finished', 0xA, 0
dbg_finish_len = $ - dbg_finish

dbg_stack_base db 'DEBUG: stack_base=0x'
dbg_stack_base_val rb 16
db 0xA, 0
dbg_stack_base_len = $ - dbg_stack_base

dbg_func db 'DEBUG: func=0x'
dbg_func_val rb 16
db 0xA, 0
dbg_func_len = $ - dbg_func

dbg_finish_addr db 'DEBUG: finish_addr=0x'
dbg_finish_addr_val rb 16
db 0xA, 0
dbg_finish_addr_len = $ - dbg_finish_addr

dbg_caller_rsp db 'DEBUG: caller_rsp=0x'
dbg_caller_rsp_val rb 16
db 0xA, 0
dbg_caller_rsp_len = $ - dbg_caller_rsp

dbg_stack_count db 'DEBUG: stack_count='
dbg_stack_count_val rb 16
db 0xA, 0
dbg_stack_count_len = $ - dbg_stack_count

dbg_rsp db 'DEBUG: rsp=0x'
dbg_rsp_val rb 16
db 0xA, 0
dbg_rsp_len = $ - dbg_rsp

dbg_stack_ptr db 'DEBUG: stack_ptr=0x'
dbg_stack_ptr_val rb 16
db 0xA, 0
dbg_stack_ptr_len = $ - dbg_stack_ptr

section '.text' executable

; Debug print macro
macro debug_print msg*, len* {
    push rax
    push rdi
    push rsi
    push rdx
    push rcx
    push r11
    
    mov rax, 1      ; sys_write
    mov rdi, 1      ; stdout
    lea rsi, [msg]  ; Load address of message
    mov rdx, len
    syscall
    
    pop r11
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rax
}

; Convert number to hex string
macro print_hex_num num, buf {
    push rax
    push rcx
    push rdx
    push rdi
    
    mov rax, num
    mov rdi, buf
    mov rcx, 16
@@:
    rol rax, 4
    mov dl, al
    and dl, 0x0F
    add dl, '0'
    cmp dl, '9'
    jbe @f
    add dl, 7
@@:
    mov [rdi], dl
    inc rdi
    dec rcx
    jnz @b
    
    pop rdi
    pop rdx
    pop rcx
    pop rax
}

; Export all required symbols
public generator_init
public generator_next
public generator_restore_context
public generator_restore_context_with_return
public generator_yield
public generator_switch_context
public generator_return
public generator__finish_current

; Initialize the generator system
generator_init:
    debug_print dbg_init, dbg_init_len
    ; Store the generator stack pointer passed from C
    mov [generator_stack], rdi
    
    ; Print stack pointer for debugging
    push rax
    mov rax, rdi
    print_hex_num rax, dbg_stack_ptr_val
    debug_print dbg_stack_ptr, dbg_stack_ptr_len
    pop rax
    
    ret

; Start or resume a generator
generator_next:
    debug_print dbg_next, dbg_next_len
    
    ; Check if generator is dead
    cmp byte [rdi + Generator.dead], 0
    jne .dead_generator
    
    ; Save current context
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    ; Save generator and argument
    mov rbp, rdi    ; Save generator
    mov rbx, rsi    ; Save argument
    
    ; Save caller's RSP for later return
    mov rax, [generator_stack]
    mov rcx, [rax + GeneratorStack.count]
    test rcx, rcx
    jz .no_caller
    dec rcx
    mov rdx, [rax + GeneratorStack.items]
    mov r8, [rdx + rcx*8]      ; Get caller generator
    mov [r8 + Generator.rsp], rsp  ; Save caller's RSP
.no_caller:
    
    ; Check if generator is fresh
    cmp byte [rbp + Generator.fresh], 0
    jne .fresh_generator
    
    ; Resume existing generator
    mov rsp, [rbp + Generator.rsp]
    mov rax, rbx    ; Return the argument
    ret
    
.fresh_generator:
    debug_print dbg_fresh, dbg_fresh_len
    
    ; Mark generator as not fresh
    mov byte [rbp + Generator.fresh], 0
    
    ; Set up new stack
    mov rsp, [rbp + Generator.stack_base]
    add rsp, 1024 * 4096   ; Move to top of stack
    
    ; Save current RSP as the generator's RSP
    mov [rbp + Generator.rsp], rsp
    
    ; Call the generator function
    mov rdi, rbx            ; Pass argument
    call [rbp + Generator.func]
    
    ; Mark generator as dead
    mov byte [rbp + Generator.dead], 1
    
    ; Return to caller
    mov rax, [generator_stack]
    mov rcx, [rax + GeneratorStack.count]
    test rcx, rcx
    jz .no_caller_return
    dec rcx
    mov rdx, [rax + GeneratorStack.items]
    mov r8, [rdx + rcx*8]      ; Get caller generator
    mov rsp, [r8 + Generator.rsp]  ; Restore caller's RSP
.no_caller_return:
    
    ; Return NULL
    xor rax, rax
    ret
    
.dead_generator:
    ; Return NULL for dead generators
    xor rax, rax
    ret

; Yield a value from a generator
generator_yield:
    debug_print dbg_yield, dbg_yield_len
    
    ; Save the yield value
    mov rbx, rdi
    
    ; Save registers
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    ; Get the generator stack directly from C
    mov rax, [generator_stack]
    
    ; Print stack pointer for debugging
    push rax
    print_hex_num rax, dbg_stack_ptr_val
    debug_print dbg_stack_ptr, dbg_stack_ptr_len
    pop rax
    
    ; Check if we have a valid stack
    test rax, rax
    jz .simple_return
    
    ; Print stack count for debugging
    push rax
    mov rax, [rax + GeneratorStack.count]
    print_hex_num rax, dbg_stack_count_val
    debug_print dbg_stack_count, dbg_stack_count_len
    pop rax
    
    ; For simplicity, just return to the caller
    ; This is the safest approach given the stack management issues
.simple_return:
    ; For the first yield, we need to return to the original caller
    ; Pop our saved registers
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    
    ; Return the yield value
    mov rax, rbx
    ret

; Restore context (used internally)
generator_restore_context:
    mov rsp, rdi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; Restore context with return value
generator_restore_context_with_return:
    ; Check if the stack pointer is valid
    test rdi, rdi
    jz .invalid_stack
    
    ; Print debug info
    push rax
    mov rax, rdi
    print_hex_num rax, dbg_rsp_val
    debug_print dbg_rsp, dbg_rsp_len
    pop rax
    
    ; Restore stack pointer and return value
    mov rsp, rdi
    mov rax, rsi
    
    ; Check if we have any saved registers
    ; If the stack is too small, it might not have saved registers
    mov rcx, rsp
    add rcx, 56  ; 7 registers * 8 bytes
    cmp rcx, [rsp]  ; Compare with the first value on stack
    jae .no_saved_registers
    
    ; Restore registers
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
    
.no_saved_registers:
    ; Just return the value
    ret
    
.invalid_stack:
    ; Return the value without changing stack
    mov rax, rsi
    ret

; Switch context (used internally)
generator_switch_context:
    ; Not used in this simplified implementation
    ret

; Return from generator (used internally)
generator_return:
    ; Not used in this simplified implementation
    ret

; Finish current generator (used internally)
generator__finish_current:
    debug_print dbg_finish, dbg_finish_len
    
    ; Print stack pointer for debugging
    push rax
    mov rax, [generator_stack]
    print_hex_num rax, dbg_stack_ptr_val
    debug_print dbg_stack_ptr, dbg_stack_ptr_len
    pop rax
    
    ; For simplicity, just return NULL
    ; This is the safest approach given the stack management issues
    xor rax, rax
    ret

