; File Operations Example
; Demonstrates common.inc features through file I/O operations

include 'common.inc'

program_init

segment readable writeable
    ; File paths and messages
    input_file db 'test.txt', 0
    output_file db 'output.txt', 0
    msg_reading db 'Reading file: ', 0
    msg_reading_len = $ - msg_reading
    msg_writing db 'Writing to file: ', 0
    msg_writing_len = $ - msg_writing
    msg_success db 'Operation completed successfully', 0xA, 0
    msg_success_len = $ - msg_success
    msg_error db 'Error occurred: ', 0
    msg_error_len = $ - msg_error
    newline db 0xA
    
    ; Buffers
    read_buffer rb BUFFER_MEDIUM
    write_buffer rb BUFFER_MEDIUM
    
    ; File descriptors
    fd_in dq 0
    fd_out dq 0
    
    ; Buffer info structure with 64-bit fields
    struc buffer_info_64
    {
        .data dq 0    ; 64-bit pointer
        .size dq 0    ; 64-bit size
        .used dq 0    ; 64-bit used count
    }
    
    buffer buffer_info_64    ; Instance of our structure

segment readable executable

; Error handler function
error_handler:
    preserve_regs
    syscall3 SYS_write, STDERR, msg_error, msg_error_len
    restore_regs
    program_exit EXIT_FAILURE

; Function to process buffer (uppercase conversion)
process_buffer:
    function_start
    
    ; Parameters:
    ; RDI = buffer address
    ; RSI = buffer length
    
    mov rcx, rsi        ; Length to process
    mov rax, rdi        ; Buffer address
    
.loop:
    cmp rcx, 0
    je .done
    
    ; Convert to uppercase if lowercase letter
    mov bl, [rax]
    cmp bl, 'a'
    jb .next
    cmp bl, 'z'
    ja .next
    sub bl, 32          ; Convert to uppercase
    mov [rax], bl
    
.next:
    inc rax
    dec rcx
    jmp .loop
    
.done:
    function_end

; Main program
entry main
main:
    stack_frame_create 16   ; Create stack frame
    
    ; Initialize buffer info
    mov qword [buffer.data], read_buffer
    mov qword [buffer.size], BUFFER_MEDIUM
    mov qword [buffer.used], 0
    
    ; Print reading message
    syscall3_safe SYS_write, STDOUT, msg_reading, msg_reading_len
    
    ; Open input file
    open_file input_file, O_RDONLY
    mov [fd_in], rax
    
    ; Open output file
    open_file output_file, O_WRONLY or O_CREAT or O_TRUNC
    mov [fd_out], rax
    
    ; Clear read buffer
    memzero read_buffer, BUFFER_MEDIUM
    
    ; Read from input file
    read_file [fd_in], read_buffer, BUFFER_MEDIUM
    mov qword [buffer.used], rax    ; Store bytes read (64-bit)
    
    ; Process buffer (convert to uppercase)
    mov rdi, read_buffer
    mov rsi, [buffer.used]
    call process_buffer
    
    ; Write to output file
    write_file [fd_out], read_buffer, [buffer.used]
    
    ; Close files
    close_file [fd_in]
    close_file [fd_out]
    
    ; Print success message
    syscall3_safe SYS_write, STDOUT, msg_success, msg_success_len
    
    stack_frame_destroy
    program_exit EXIT_SUCCESS 