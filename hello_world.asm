section .text
global  _start
_start:
    mov edx,len
    mov ecx,msg
    mov ebx,1
    mov eax,4
    int 0x80
    mov eax,1
    int 0x80
section .data
msg db  'hello world',0xa
len equ $ - msg

;; This can be compiled by nasm
; nasm -f elf64 hello_world.asm -o hello.o
; ld hello.o -o hello
