# Tareas de ensamblador

## Herramientas

### NASM

[NASM](https://www.nasm.us/) es el ensamblador necesario para crear el archivo "objetO".

- Descargar para Windows: [NASM v2.16.01](https://www.nasm.us/pub/nasm/releasebuilds/2.16.01/)

### GCC

GCC es el compilador que utilizaremos para crear el archivo ejecutable.

En la página de [GCC](https://gcc.gnu.org/install/binaries.html) se pueden encontrar diversas formas de instalarlos en varios sistemas operativos, por ejemplo [Cygwin](https://sourceware.org/cygwin/) en Windows.

En esta página se puede encontrar más información para poder instalarlo:

https://stackoverflow.com/questions/47215330/how-do-i-install-gcc-on-cygwin

### MAKE

Make es opcional, se instala con el mismo instalador de CYGWIN, y es usado para facilitar los pasos de la compilación.

### Compilar

Todos las carpetas son una tarea. Cambiar al directorio y ejecutar los siguientes comandos:

```bash
nasm -w+all -f elf64 -o 'tarea.o' 'tarea.asm'
gcc -fno-pie -m64 -no-pie -pedantic-errors -o 'tarea.out' 'tarea.o'
```

Si se ha instalado el programa `make`, solo corresponde ejecutar `make`.

## Documentación

## `printf`

La función `printf` se encuentra en una librería externa de C. Los archivos C tienen su equivalencia con ensamblador, por lo que se pueden utilizar. Sin embargo es más sencillo utilizar GCC, ya que este se encarga de enlazar dinámicamente la librería con nuestro programa.

```assembly
; printf is a bit harder as it requires varargs setup.
; https://stackoverflow.com/questions/8194141/how-to-print-a-number-in-assembly-nasm/32853546#32853546
extern printf          ; NASM requires declarations of external symbols, unlike GAS
```

De acuerdo a [Assembly Language &amp; Computer Architecture Lecture (CS 301)](https://www.cs.uaf.edu/2017/fall/cs301/lecture/09_25_printf.html) hay 3 registradores que son importantes:`rdi`, `rsi` y `al`, por eso cuando llamamos a la función, debemos mover nuestros datos a esos registradores:

```assembly
section .data
    resultado_msg db "El resultado es: %d", LF, NULL
    
section .text
    ; ... (código)
    ; Imprimir el resultado de qAns1
    mov rdi, resultado_msg; rdi es el formato
    mov rsi, [qAns1] ;qAns1 es el valor
    mov al, 0 ; magic for varargs (0==no magic, para que no falle)
    call printf
```

Esta función la usamos varias veces, por eso la explicación adicional.

### Tamaño de los identificadores

Cada identificador puede tener un tamaño:

Bytes (8-bits, 2^8): [0 to 255]

```
foo db 50
                                                                      0011 0010
                                                                         3    2
                                                                           0x32
```
Words (16-bits, 2^16): [0 to 65,535]

```
foo dw 50,000
                                                            1100 0011 0101 0000
                                                               C    3    5    0
                                                                         0xC350
```

Double-words (32-bits, 2^32): [0 to 4,294,967,295]

```
foo dd 500,000
                                        0000 0000 0000 0111 1010 0001 0010 0000
                                           0    0    0    7    A    1    2    0
                                                                  0x0007 0xA120
```

Quadword (64-bits, 2^64): [0 to 2^64]

```
foo dq 50,000,000
0000 0000 0000 0000 0000 0000 0000 0000 0000 0010 1111 1010 1111 0000 1000 0000
    0    0    0    0    0    0    0    0    0    2    F    A    F    0    8    0
                                                     0x0000 0x0000 0x02FA 0xF080
```

Otro ejemplo:

```
foo dq 50,000,000,000
0000 0000 0000 0000 0000 0000 0000 1011 1010 0100 0011 1011 0111 0100 0000 0000
                                      B    A    4    3    B    7    4    0    0
                                                    0x0000 0x000B 0xA43B 0x7400
```

Double quadword (128-bits, 2^128): [0 to 2^128]

```
foo ddq 5,000,000,000,000,000,0000
      0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0010 1011 0101 1110 0011 1010 1111 0001 0110 1011 0001 1000 1000 0000 0000 0000 0000
                                                                                    2    B    5    E    3    A    F    1    6    B    1    8    8    0    0    0    0
                                                                                                                                   0x0002 0xB5E3 0xAF16 0xB188 0x0000
```

Referencia: https://flint.cs.yale.edu/cs421/papers/x86-asm/asm.html

### Punto flotante

Es importante mencionar que un número entero puede ser representado usando todas los bits disponibles, sin embargo en el caso de los números flotantes (con decimal) se debe considerar el signo, la parte entera y la parte decimal. En el formato IEEE-754 se puede representar:

```
                                                                                        -2.2
                                                                   -2.2000000476837158203125
      0000 0000 0000 0000 0000 0000 0000 0000 [1] [1000 0000] [0001 1001 1001 1001 1001 101]
```
Ver:

- https://www.h-schmidt.net/FloatConverter/IEEE754.html
- http://www.cs.put.poznan.pl/tzok/public/cawllp-04-asm.html

### Registradores

Este es un registrador EAX de 32 bits, y su disposición (layout) es la siguiente:

```
Este es un registrador EAX de 32 bits, y su disposición (layout) es la siguiente:
 ________________ ________ ____ ____
|      EAX       |   AX   | AH | AL |
|________________|________|____|____|
 \_________________________________/
          |       \________________/
      32 bits              |    \__/
                       16 bits   ||
                               8 bits
```

Es importante mencionar que en el libro, dice que EAX se ve afectado por el valor de AX, y AX de AH, es decir, que cuando el valor de AX cambia, el valor de EAX también cambia, ya que en realidad EAX es el resultado del valor de todos los registradores.

Los registradores generales se describen en la página #24 del libro, estos pueden servir para almenacer datos, pero hay hay otros con un rol espécifico:

- Stack Pointer Register (Página #26, 2.3.1.2)
  - rsp
- Base Pointer Register (Página #26, 2.3.1.3)
  - rbp
- Instruction Pointer Register (Página #26, 2.3.1.4)
  - rip (next instruction to be executed)
- Flag Register  (Página #26, 2.3.1.5)
  - 

Ver

- https://www.cs.virginia.edu/~evans/cs216/guides/x86-registers.png
- https://ikrima.dev/dev-notes/assembly/asm-cheatsheet/

## Multiplicación

```bash
cd 1_multiplicacion
make
./tarea.out
```