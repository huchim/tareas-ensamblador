; printf is a bit harder as it requires varargs setup.
; https://stackoverflow.com/questions/8194141/how-to-print-a-number-in-assembly-nasm/32853546#32853546
default rel            ; make [rel format] the default, you always want this.
extern printf          ; NASM requires declarations of external symbols, unlike GAS


; * Sección de datos donde los datos inicializados son declarados y definidos.
section .data
; -----------------------------------------------------------
; La sección de datos puede servir para definir los identificadores
; cada identificador puede tener un tamaño:
;   > Bytes (8-bits, 2^8): [0 to 255]
;       foo db 50
;                                                                             0011 0010
;                                                                                3    2
;                                                                                  0x32
;
;   > Words (16-bits, 2^16): [0 to 65,535]
;       foo dw 50,000
;                                                                   1100 0011 0101 0000
;                                                                      C    3    5    0
;                                                                                 0xC350
;
;   > Double-words (32-bits, 2^32): [0 to 4,294,967,295]
;       foo dd 500,000
;                                               0000 0000 0000 0111 1010 0001 0010 0000
;                                                  0    0    0    7    A    1    2    0
;                                                                          0x0007 0xA120
;
;   > Quadword (64-bits, 2^64): [0 to 2^64]
;       foo dq 50,000,000
;       0000 0000 0000 0000 0000 0000 0000 0000 0000 0010 1111 1010 1111 0000 1000 0000
;          0    0    0    0    0    0    0    0    0    2    F    A    F    0    8    0
;                                                            0x0000 0x0000 0x02FA 0xF080
;       Otro ejemplo:
;       foo dq 50,000,000,000
;       0000 0000 0000 0000 0000 0000 0000 1011 1010 0100 0011 1011 0111 0100 0000 0000
;                                             B    A    4    3    B    7    4    0    0
;                                                           0x0000 0x000B 0xA43B 0x7400
;
;   > Double quadword (128-bits, 2^128): [0 to 2^128]
;       foo ddq 5,000,000,000,000,000,0000
;       0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0010 1011 0101 1110 0011 1010 1111 0001 0110 1011 0001 1000 1000 0000 0000 0000 0000
;                                                                                     2    B    5    E    3    A    F    1    6    B    1    8    8    0    0    0    0
;                                                                                                                                    0x0002 0xB5E3 0xAF16 0xB188 0x0000
; 
; -----------------------------------------------------------
; Referencia: https://flint.cs.yale.edu/cs421/papers/x86-asm/asm.html
; -----------------------------------------------------------

; Es importante mencionar que un número entero puede ser representado usando todas los bits
; disponibles, sin embargo en el caso de los números flotantes (con decimal) se debe considerar
; el signo, la parte entera y la parte decimal. En el formato IEEE-754 se puede representar:
;
;                                                                                        -2.2
;                                                                   -2.2000000476837158203125
;      0000 0000 0000 0000 0000 0000 0000 0000 [1] [1000 0000] [0001 1001 1001 1001 1001 101]
;
; Ver: https://www.h-schmidt.net/FloatConverter/IEEE754.html
;      http://www.cs.put.poznan.pl/tzok/public/cawllp-04-asm.html
;                                       
; -----------------------------------------------------------
; 
; Este es un registrador EAX de 32 bits, y su disposición (layout) es la siguiente:
;  ________________ ________ ____ ____
; |      EAX       |   AX   | AH | AL |
; |________________|________|____|____|
;  \_________________________________/
;           |       \________________/
;       32 bits              |    \__/
;                        16 bits   ||
;                                8 bits
;
; Es importante mencionar que en el libro, dice que EAX se ve afectado por el valor de AX, y AX de AH, es decir, que cuando
; el valor de AX cambia, el valor de EAX también cambia, ya que en realidad EAX es el resultado del valor de todos los registradores.
; 
; Los registradores generales se describen en la página #24 del libro, estos pueden servir para almenacer datos, pero hay
; hay otros con un rol espécifico:
;
; - Stack Pointer Register (Página #26, 2.3.1.2)
;   - rsp
; - Base Pointer Register (Página #26, 2.3.1.3)
;   - rbp
; - Instruction Pointer Register (Página #26, 2.3.1.4)
;   - rip (next instruction to be executed)
; - Flag Register  (Página #26, 2.3.1.5)
;   - 
;
; Ver https://www.cs.virginia.edu/~evans/cs216/guides/x86-registers.png
;     https://ikrima.dev/dev-notes/assembly/asm-cheatsheet/
; --------------------------------------------------------------------------
; Definir constantes
; Las constantes son definidas utilizando el operador `equ` (página #48, 4.3)
    LF             equ    10  ; Salto de línea
    NULL           equ     0  ; Fin del texto.
    EXIT_SUCCESS   equ     0  ; Código de salida con éxito.
    SYS_exit       equ    60  ; Llamada al sistema para terminar.
; -----
; Definir variables
; -----------------------------------------------------------
; American Standard Code for Information Interchange (ASCII)
;
; Los carácteres son representados númericamente, donde cada carácter tiene asignado un número, de
; acuerdo a la tabla ASCIII.
;
; Ejemplo:         A (caràcter)
;                 65 (decimal)
;          0100 0001 (binario)
;             4    1
;                 41 (héxadecimal)
;
; Como en el ejemplo, cada cáracter es almacenado en 8-bits que soporta correctamente la tabla de
; carácteres ASCIII, sin embargo no es lo adecuado cuando se usan otros carácteres usados en otros
; idiomas como 专 (0x4E10), para ello es necesario utilizar Unicode (este archivo es UTF-8, soporta
; los carácteres Unicode). Aunque en este tema no es importante saberlo, esto es útil cuando en
; algunos documentos vemos carácteres extraños (?, ◆) que usualmente es provocado porque no se
; especifica correctamente la tabla de carácteres.
;
; Otro datos importante (página #43, 3.4.2) es que para marcar como finalizado una cadena de texto
; se usa el carácter NULL que es igual a 0, como este carácter no se puede imprimir se usa para marcar
; el fin del texto.
; 
; -----------------------------------------------------------
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

; -----
; INFO:
;   La multiplicación tipicamente produce un resultado del doble de tamaño. Esto es, que al multiplicar
;   dos valores n-bit producirá un resultado de 2n-bit.
;
;   Multiplicando dos números de 8-bit producirá un resultado de 16-bits. Similarmente, la multiplicación
;   de dos números de 16-bits producirán un resultado de 32-bits, la multiplicación de dos números de 32-bits
;   producirán un resultado de 64-bits y la multiplicación de dos números de 64-bits producirán un resultado
;   de 128-bits:
;
;   (16-bits, 2^16)
;   qAns1 =                3066
;           0000 1011 1111 1010
;                        0x0BFA
    qAns1 dw 0
;
; ----

; ************************************************************
; * Sección de texto, donde el código es colocado.
section .text

; Iniciamos con la etiqueta `_start', es importante saber que si usamos gcc como compilador, debemos
; utilizar `main`, ya que este crea su propia etiqueta `_start` y luego llama a `main`, por lo que
; deberemos renombrer. Si usamos `ld` no es necesario. Por otro lado, algunos sistemas operativos no
; necesitan agregar el prefijo `_` al nombre de la etiqueta.
global main
main:
    ; Vamos a realizar una multiplicación
    ; qAns3 = a * b
    ; Movemos `bNumA` (8-bit) al registrador `al` (8-bit)
    ; En este ejemplo, especificamos el tamaño de la fuente (`bNumA`), pero como ambos son del mismo 
    ; tamaño no será necesario. El modificador `byte` es usado para establecer el tamaño y existen otros.
    mov al, [bNumA]
    ; El multiplicador debe ser un registrador o una posición en la memoria.
    ; El multiplicando se encuentra en un registrador "al" (de acuerdo al tamaño, puede ser al/ax/eax/rax).
    mul byte [bNumB]
    ; Página #101 del libro
    ; `al` es un registrador "acumulador", es decir que serà usado para almacenar el resultado.
    ; En el depurador aparecerá com `eax` porque recordemos que `ax` se encuentra dentro del espacio de `eax`.
    mov word [qAns1], ax

; -----------------
    ; Ver: https://www.cs.uaf.edu/2017/fall/cs301/lecture/09_25_printf.html    
    mov rdi, resultado_msg
    mov rsi, [qAns1]
    mov al, 0 ; magic for varargs (0==no magic, to prevent a crash!)
    call printf

; ************************************************************
; Terminamos.
; Como el flujo del programa va de arriba hacia abajo, en este punto podemos evitar
; que continúe a otras etiquetas, como la de `printScreen`.
last:
    mov rax, SYS_exit ; `rax` es el registrador "acumulador", lo usamos para indicar la salida.
    mov rdi, EXIT_SUCCESS;  Salimos del programa.
    syscall

