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

dbg_yield db 'DEBUG: generator_yield called', 0xA, 0
dbg_yield_len = $ - dbg_yield

dbg_finish db 'DEBUG: generator finished', 0xA, 0
dbg_finish_len = $ - dbg_finish

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
    ret

; Start or resume a generator
generator_next:
    debug_print dbg_next, dbg_next_len
    
    ; Check if generator is dead
    cmp byte [rdi + Generator.dead], 0
    jne .dead_generator
    
    ; Check if generator is fresh
    cmp byte [rdi + Generator.fresh], 0
    jne .fresh_generator
    
    ; Resume existing generator - just return the argument
    mov rax, rsi
    ret
    
.fresh_generator:
    ; Mark generator as not fresh
    mov byte [rdi + Generator.fresh], 0
    
    ; Save the generator pointer
    push rdi
    
    ; Get the function pointer
    mov rax, [rdi + Generator.func]
    
    ; Check if function pointer is valid
    test rax, rax
    jz .func_error
    
    ; Call the generator function with the argument
    mov rdi, rsi    ; Pass argument
    call rax
    
    ; Restore the generator pointer
    pop rdi
    
    ; Mark generator as dead
    mov byte [rdi + Generator.dead], 1
    
    ; Return NULL
    xor rax, rax
    ret
    
.func_error:
    ; Pop the saved generator pointer
    pop rdi
    
    ; Mark generator as dead
    mov byte [rdi + Generator.dead], 1
    
    ; Return NULL
    xor rax, rax
    ret

; Yield a value from a generator
generator_yield:
    debug_print dbg_yield, dbg_yield_len
    
    ; Just return the argument
    mov rax, rdi
    ret

; Restore context (used internally)
generator_restore_context:
    ; Not used in this simplified implementation
    ret

; Restore context with return value
generator_restore_context_with_return:
    ; Not used in this simplified implementation
    mov rax, rsi    ; Return the argument
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
    
    ; Return NULL
    xor rax, rax
    ret

.dead_generator:
    ; Return NULL for dead generators
    xor rax, rax
    ret

