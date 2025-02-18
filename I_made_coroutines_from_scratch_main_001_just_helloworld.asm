format ELF64 executable

STDIN_FILENO = 1

SYS_write = 1
SYS_exit = 60

main:
    mov rax, SYS_write
    mov rdi, STDIN_FILENO
    mov rsi, msg
    mov rdx, msg_len
    syscall

    mov rax, SYS_exit
    mov rdi, 0
    syscall

msg: db "Hello, World!", 0, 10
msg_len = $-msg
