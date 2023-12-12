# Multiplicación

La multiplicación tipicamente produce un resultado del doble de tamaño. Esto es, que al multiplicar dos valores n-bit producirá un resultado de 2n-bit.

Multiplicando dos números de 8-bit producirá un resultado de 16-bits. Similarmente, la multiplicación de dos números de 16-bits producirán un resultado de 32-bits, la multiplicación de dos números de 32-bits producirán un resultado de 64-bits y la multiplicación de dos números de 64-bits producirán un resultado de 128-bits:

```
(16-bits, 2^16)
qAns1 =                3066
        0000 1011 1111 1010
                     0x0BFA
```

Código ensamblador:

```assembly
qAns1 dw 0
```

## Código fuente

```assembly
default rel
extern printf

section .data
    LF             equ    10  ; Salto de línea
    NULL           equ     0  ; Fin del texto.
    EXIT_SUCCESS   equ     0  ; Código de salida con éxito.
    SYS_exit       equ    60  ; Llamada al sistema para terminar.

    resultado_msg db "El resultado es: %d", LF, NULL

;   (8-bits, 2^8)
;   bNumA =                  42
;                     0010 1010
;                          0x2A
    bNumA db 42
;   (8-bits, 2^8)
;   bNumA =                  73
;                     0100 1001
;                          0x49
    bNumB db 73
;   (16-bits, 2^16)
;   qAns1 =                3066
;           0000 1011 1111 1010
;                        0x0BFA
    qAns1 dw 0

section .text
global main
main:
    ; Vamos a realizar una multiplicación
    ; qAns3 = a * b
    ; Movemos `bNumA` (8-bit) al registrador `al` (8-bit)
    ; En este ejemplo, especificamos el tamaño de la fuente (`bNumA`), pero como ambos son del mismo 
    ; tamaño no será necesario. El modificador `byte` es usado para establecer el tamaño y existen otros.
    mov al, byte [bNumA]
    ; El multiplicador debe ser un registrador o una posición en la memoria.
    ; El multiplicando se encuentra en un registrador "al" (de acuerdo al tamaño, puede ser al/ax/eax/rax).
    mul byte [bNumB]
    ; Página #101 del libro
    ; `al` es un registrador "acumulador", es decir que serà usado para almacenar el resultado.
    ; En el depurador aparecerá com `eax` porque recordemos que `ax` se encuentra dentro del espacio de `eax`.
    mov word [qAns1], ax

    mov rdi, resultado_msg
    mov rsi, [qAns1]
    mov al, 0
    call printf

; ************************************************************
; Terminamos.
; Como el flujo del programa va de arriba hacia abajo, en este punto podemos evitar
; que continúe a otras etiquetas, como la de `printScreen`.
last:
    mov rax, SYS_exit ; `rax` es el registrador "acumulador", lo usamos para indicar la salida.
    mov rdi, EXIT_SUCCESS;  Salimos del programa.
    syscall
```

## Multiplicación

```bash
cd 1_multiplicacion
make
./tarea.out
```
