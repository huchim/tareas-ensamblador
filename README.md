# Tareas de ensamblador

## Herramientas

### Linux

Instalar las siguientes herramientas.

- nasm
- gcc
- ddd
- make

#### Compilar

Todos las carpetas son una tarea. Cambiar al directorio y ejecutar los siguientes comandos:

```bash
nasm -w+all -f elf64 -o 'tarea.o' 'tarea.asm'
gcc -fno-pie -m64 -no-pie -pedantic-errors -o 'tarea.out' 'tarea.o'
```

### Windows

#### Instalación del ensamblador NASM

- Instalar [NASM v2.16.01](https://www.nasm.us/pub/nasm/releasebuilds/2.16.01/) como administrador.
- Localizar la carpeta donde se instaló: `C:\Program Files\NASM\`
- Agregar la carpeta a la variable de entorno `PATH`.
  - [Como agregar variables de entorno (S. O. Windows 10)](https://medium.com/@01luisrene/como-agregar-variables-de-entorno-s-o-windows-10-e7f38851f11f)
  - [Variables de Entorno Windows 11 | Comandos](https://www.solvetic.com/tutoriales/article/12395-variables-de-entorno-windows-11-comandos/)

#### Instalación del enlazador GoLink

- Descargar [GoLink v1.0.4.5](https://www.godevtool.com/Golink.zip)
- Descomprimir el contenido en la carpeta: `C:\golink`
- Agregar la carpeta a la variable de entorno `PATH`.
  - [Como agregar variables de entorno (S. O. Windows 10)](https://medium.com/@01luisrene/como-agregar-variables-de-entorno-s-o-windows-10-e7f38851f11f)
  - [Variables de Entorno Windows 11 | Comandos](https://www.solvetic.com/tutoriales/article/12395-variables-de-entorno-windows-11-comandos/)

#### Compilar

Todos las carpetas son una tarea. Cambiar al directorio y ejecutar los siguientes comandos:

```bash
nasm  -w+all -g -f win64 -l 'tarea.lst' -o 'tarea.obj' 'tarea.asm'
goasm -f win64 -o 'tarea.obj' 'tarea.asm'
golink tarea.obj /console kernel32.dll user32.dll msvcrt.dll /debug dbg /entry main /fo tarea.exe
```

Si se ha instalado el programa `make`, solo corresponde ejecutar `make`.

#### Depurar

https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/

[Descargar WinDbg](https://aka.ms/windbg/download)

```
%LOCALAPPDATA%\Microsoft\WindowsApps\WinDbgX.exe -o tarea.exe
```

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
  -  ?

Ver

- https://www.cs.virginia.edu/~evans/cs216/guides/x86-registers.png
- https://ikrima.dev/dev-notes/assembly/asm-cheatsheet/

### Definir constantes

Las constantes son definidas utilizando el operador `equ` (página #48, 4.3)

```assembly
LF             equ    10  ; Salto de línea
NULL           equ     0  ; Fin del texto.
EXIT_SUCCESS   equ     0  ; Código de salida con éxito.
SYS_exit       equ    60  ; Llamada al sistema para terminar.
```

### Definir variables

#### Definir variables de texto

>  Deben de ir antes que las demás variables.

American Standard Code for Information Interchange (ASCII)

Los carácteres son representados númericamente, donde cada carácter tiene asignado un número, de acuerdo a la tabla ASCIII.

Como en el ejemplo, cada cáracter es almacenado en 8-bits que soporta correctamente la tabla de carácteres ASCIII, sin embargo no es lo adecuado cuando se usan otros carácteres usados en otros idiomas como 专 (0x4E10), para ello es necesario utilizar Unicode (este archivo es UTF-8, soporta los carácteres Unicode). Aunque en este tema no es importante saberlo, esto es útil cuando en algunos documentos vemos carácteres extraños (`?, ◆`) que usualmente es provocado porque no se especifica correctamente la tabla de carácteres.

Otro datos importante (página #43, 3.4.2) es que para marcar como finalizado una cadena de texto se usa el carácter `NULL` que es igual a 0, como este carácter no se puede imprimir se usa para marcar el fin del texto.

```
Ejemplo:         A (caràcter)
                65 (decimal)
         0100 0001 (binario)
            4    1
              0x41 (héxadecimal)
```

Código:

```assembly
resultado_msg db "El resultado es: %d", 10, 0
```
