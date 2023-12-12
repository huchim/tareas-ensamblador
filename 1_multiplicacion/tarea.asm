default rel
extern printf

section .data
; --------------------------------------------------------------------------
; Definir constantes
    LF             equ    10
    NULL           equ     0
    EXIT_SUCCESS   equ     0
    SYS_exit       equ    60
; -----
; Definir variables
    resultado_msg db "El resultado es: %d", LF, NULL
    bNumA db 42
    bNumB db 73
    qAns1 dw 0

section .text

global main
main:
    mov al, [bNumA]
    mul byte [bNumB]
    mov word [qAns1], ax

    mov rdi, resultado_msg
    mov rsi, [qAns1]
    mov al, 0
    call printf

last:
    mov rax, SYS_exit
    mov rdi, EXIT_SUCCESS
    syscall

