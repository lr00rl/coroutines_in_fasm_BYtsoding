format ELF64 executable

entry _start
_start:
    mov r15, 10

.again:
    cmp r15, 0
    jle .over
        mov rax, 1
        mov rdi, 1
        mov rsi, message
        mov rdx, message_len
        syscall
        dec r15
    jmp .again

.over:
    mov rax, 60
    mov rdi, 0
    ; xor rdi, rdi
    syscall

message: file "message.txt"
message_len = $-message

