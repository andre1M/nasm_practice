%include "stud_io.inc"
global _start                   ; make program start label global

section .data                   ; initialized data section
  array db      0, 1, 2, 3, 4   ; 5 single byte memory sections

section .text                   ; code and initialized data section
_start:                         ; program entry point
        mov     ebx, 0          ; initialize counter
 again: mov     eax, [array + ebx]
        add     eax, 20
        PUTCHAR eax
        PRINT   ' '
        inc     ebx
        cmp     ebx, 5
        jl      again
        FINISH

