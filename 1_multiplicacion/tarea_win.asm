default rel
extern printf


section .data
; -----
; Define constants
    LF equ 10 ; Salto de línea
    NULL equ 0 ; fin de cadena.
    EXIT_SUCCESS equ 0 ; successful operation
    SYS_exit equ 60 ; call code for terminate

; -----
; Define variables 
    resultado_msg db "El resultado es: %d", LF, NULL
    a dw 4321 ;16-bits
    b dw 1234 ; 16-bits
    qAns3 dd 0 ; 32-bits
    message1 db "hello world", LF, NULL

; ********
; Code Section
section .text

global main
main:
    ; qAns3 = a * b
    mov ax, word [a] ; ax es de 16bits (ax, bx, cx, dx)
    mul word [b] ;
    mov dword [qAns3], eax; ; es de 32-bits (eax, ebx, ecx, edx)

; Imprimir el resultado usando printf
    mov rcx, resultado_msg; (register c extended, 64-bits)
    mov rdx, [qAns3] ; (register d extended, 64-bits)
    mov al, 0
    ; https://learn.microsoft.com/es-es/cpp/build/x64-calling-convention?view=msvc-170
    call printf ; printf(rcx, rdx)

; ********
; Done, terminate program.
last:
    mov rax, SYS_exit ; Call code for exit
    xor rdi, rdi      ; Exit program with success
    syscall
