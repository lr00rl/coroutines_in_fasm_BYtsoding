format ELF64 executable

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

;.again:
;    cmp r15, 0
;    jle .over
;        mov rax, 1
;        mov rdi, 1
;        mov rsi, message
;        mov rdx, message_len
;        syscall
;        dec r15
;    jmp .again
;
;.over:
;    mov rax, 60
;    mov rdi, 0
;    ; xor rdi, rdi
;    syscall

macro for i, start, end {
    mov QWORD [i], start
.#i#_again:
    push rax
    mov rax, QWORD [i]
    cmp rax, end
    pop rax
    jge .#i#_over
}

macro endfor i {
    inc QWORD [i]
    jmp .#i#_again
.#i#_over:
}

macro syscall1 number, arg1 {
    mov rax, number
    mov rdi, arg1
    syscall
}

macro syscall3 number, arg1, arg2, arg3 {
    mov rax, number
    mov rdi, arg1
    mov rsi, arg2
    mov rdx, arg3
    syscall
}

STDIN_FILENO = 0
STDOUT_FILENO = 1
STDERR_FILENO = 2
SYS_read = 0
SYS_write = 1
SYS_open = 2
SYS_close = 3
SYS_exit = 60
O_RDONLY = 0

macro write fd, buf, len {
    syscall3 SYS_write, fd, buf, len
}

macro exit code {
    syscall1 SYS_exit, code
}

read_entire_file:
    push rbp
    mov rbp, rsp
    sub rsp, 8

    syscall3 SYS_open, rdi, O_RDONLY, 0
    cmp rax, 0
    jl .failed

    mov [rbp-8], rax

    syscall3 SYS_read, [rbp-8], buffer, buffer_capacity
    cmp rax, 0
    jl .failed

    mov [buffer_len], rax

    syscall1 SYS_close, [rbp-8]

.failed:
    add rsp, 8
    pop rbp
    ret


entry _start
_start:

    mov rdi, input_file_path
    call read_entire_file
    cmp rax, 0
    jl .fail_read_entire_file

    write STDOUT_FILENO, buffer, [buffer_len]

    mov QWORD [count], 0
    for i, 0, [buffer_len]
        mov rax, buffer
        add rax, [i]
        mov bl, BYTE [rax]
        mov rcx, [count]
        mov rdx, rcx
        inc rcx
        cmp bl, 10  ;; '\n'
        cmove rdx, rcx
        mov [count], rdx
    endfor i

    mov rdi, [count]
    call print

    ;; int 3 ; breakpoint for debug
    ;; for i, 0, 5
    ;;     mov rdi, [i]
    ;;     call print
    ;;     for j, 0, 3
    ;;         write STDOTU_FILENO, hello, hello_len
    ;;     endfor j
    ;; endfor i

    exit 0
.fail_read_entire_file:
    write STDERR_FILENO, fail_read_entire_file_msg, fail_read_entire_file_msg_len
    exit 69


struc String_View addr, count
{
    .addr dq addr
    .count dq count
}

input_file_path: db "message.txt", 0, 10
ok_msg: db "OK", 0, 10
; ", 0" means null-terminated string
; ", 10" means newline
ok_msg_len = $-ok_msg
fail_read_entire_file_msg: db "Failed to read the entire file", 0
fail_read_entire_file_msg_len = $-fail_read_entire_file_msg
message: file "message.txt"
message_len = $-message
i: dq 0
j: dq 0
count: dq 0

buffer: rb 10*1024
buffer_capacity = $-buffer
buffer_len: rq 1
