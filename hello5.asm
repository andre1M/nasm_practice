%include "stud_io.inc"  ; includes macrodirectives to print chars
global _start

section .text           ; executable code section
_start:	mov	    eax, 0  ; put zero in eax as a counter variable
 again:	PRINT 	"Hello" ; call marcos to print string
    	PUTCHAR	10      ; put char with code 10 (new line)
    	inc 	eax     ; increment value at eax by 1
    	cmp	    eax, 5  ; compare eax to 5
    	jl	    again   ; "jump if lower" to "again" label above
    	FINISH          ; stop execution macros

