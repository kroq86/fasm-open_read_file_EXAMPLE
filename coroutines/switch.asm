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

struc RegState {
    .rbp dq 0
    .rbx dq 0
    .r12 dq 0
    .r13 dq 0
    .r14 dq 0
    .r15 dq 0
    .rsp dq 0
    .ret dq 0
}
virtual at 0
    RegState RegState
    sizeof.RegState = $
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

section '.text' executable
public generator_init
public generator_next
public generator_restore_context
public generator_restore_context_with_return
public generator_yield
public generator_switch_context
public generator_return
public generator__finish_current

generator_init:
    mov [generator_stack], rdi  ; Save generator_stack pointer from C
    ret

generator_next:
    ; Check if generator is dead first
    cmp byte [rdi + Generator.dead], 0
    je .not_dead
    xor rax, rax
    ret
.not_dead:
    ; Save registers
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    ; Save generator pointer
    push rdi
    
    ; Save stack pointer for later
    mov rdx, rsp
    
    ; Call switch context
    mov rdi, [rsp]        ; Get generator pointer back
    call generator_switch_context
    
    ; Restore everything
    pop rdi               ; Remove saved generator
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

generator_restore_context:
    ; Restore registers in exact order as C code
    mov rsp, rdi           ; Restore stack pointer
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rdi
    pop rbp
    ret

generator_restore_context_with_return:
    ; Same as restore_context but with return value in rax
    mov rsp, rdi           ; Restore stack pointer
    mov rax, rsi           ; Set return value
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rdi
    pop rbp
    ret

generator_yield:
    ; Save registers in exact order as C code
    push rbp
    mov rbp, rsp
    push rdi               ; Save yield value
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rsi, rsp          ; Current stack pointer
    jmp generator_return

generator_switch_context:
    ; Save registers
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    ; Save current rsp in previous generator
    mov rax, [generator_stack]
    mov rcx, [rax + GeneratorStack.items]  ; Get items array
    mov rax, [rax + GeneratorStack.count]  ; Get count
    sub rax, 2                             ; Get index of previous generator
    mov rax, [rcx + rax*8]                 ; Get previous generator
    mov [rax + Generator.rsp], rdx         ; Save rsp in Generator struct
    
    ; Check if generator is fresh
    cmp byte [rdi + Generator.fresh], 0    ; Check fresh flag
    je .not_fresh
    
    ; Handle fresh generator
    mov byte [rdi + Generator.fresh], 0    ; Clear fresh flag
    
    ; Setup new stack
    mov rsp, [rdi + Generator.stack_base]  ; Load stack_base
    add rsp, 1024 * 4096                  ; Move to top of stack
    and rsp, -16                          ; Align stack to 16 bytes
    
    ; Save registers on new stack
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    ; Call generator function
    mov rax, [rdi + Generator.func]       ; Get function pointer
    mov rdi, rsi                          ; Set up arg
    call rax                              ; Call function
    
    ; Function returned - go to finish
    pop r15                               ; Clean up registers
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp generator__finish_current         ; Done

.not_fresh:
    ; Restore from saved state
    mov rdi, [rdi + Generator.rsp]        ; Get saved rsp
    mov rsi, rax                          ; Set return value
    
    ; Restore registers
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp generator_restore_context_with_return

generator_return:
    ; Set up stack frame
    push rbp
    mov rbp, rsp
    
    ; Save rsp in current generator (index count-1)
    mov rax, [generator_stack]
    mov rcx, [rax + GeneratorStack.items]  ; Get items array
    mov rax, [rax + GeneratorStack.count]  ; Get count
    dec rax                                ; Get index of current generator
    mov rdx, [rcx + rax*8]                 ; Get current generator
    mov [rdx + Generator.rsp], rsi         ; Save rsp in Generator struct
    
    ; Pop generator from stack (C code will handle cleanup)
    mov rcx, [generator_stack]
    dec qword [rcx + GeneratorStack.count]  ; Decrement count
    
    ; Get previous generator's context (index count-2)
    mov rax, [generator_stack]
    mov rcx, [rax + GeneratorStack.items]  ; Get items array
    mov rax, [rax + GeneratorStack.count]  ; Get count
    dec rax                                ; Get index of previous generator
    mov rdx, [rcx + rax*8]                 ; Get previous generator
    mov rdi, [rdx + Generator.rsp]         ; Get its saved rsp
    mov rsi, [rbp - 8]                     ; Get yield value from stack
    
    mov rsp, rbp                           ; Restore stack frame
    pop rbp
    jmp generator_restore_context_with_return

generator__finish_current:
    ; Set up stack frame
    push rbp
    mov rbp, rsp
    
    ; Mark current generator as dead (index count-1)
    mov rax, [generator_stack]
    mov rcx, [rax + GeneratorStack.items]  ; Get items array
    mov rax, [rax + GeneratorStack.count]  ; Get count
    dec rax                                ; Get index of current generator
    mov rdx, [rcx + rax*8]                 ; Get current generator
    mov byte [rdx + Generator.dead], 1     ; Set dead flag
    
    ; Pop generator from stack (C code will handle cleanup)
    mov rcx, [generator_stack]
    dec qword [rcx + GeneratorStack.count]  ; Decrement count
    
    ; Get previous generator's context (index count-2)
    mov rax, [generator_stack]
    mov rcx, [rax + GeneratorStack.items]  ; Get items array
    mov rax, [rax + GeneratorStack.count]  ; Get count
    dec rax                                ; Get index of previous generator
    mov rdx, [rcx + rax*8]                 ; Get previous generator
    mov rdi, [rdx + Generator.rsp]         ; Get its saved rsp
    xor rsi, rsi                          ; Return NULL
    
    mov rsp, rbp                          ; Restore stack frame
    pop rbp
    jmp generator_restore_context_with_return

