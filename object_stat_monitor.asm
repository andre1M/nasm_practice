; this example contains a collection of NASM snippets that describe
; bitwise operations on an array of 512 bits
; it is assumed that such array stores a status of 512 arbitrary objects
global _start

; allocate memory in the heap for uninitialized variables
section .bss
arr512  resd    16

; comments like "..." denote some arbitrary code 
section .text
_start:             
        ; ...
        ; clean arr512, e.g. put zeros everywhere
        xor     eax, eax        ; EAX:=0
        mov     ecx, 16         ; counter
        mov     esi, arr512
lp:     mov     [esi+4*ecx-4], 0
        loop    lp              ; decrement ECX and jump if ECX!=0        

        ; ...
        ; assume ebx now contains element number X
        shl     ebx, 3          ; place 2^5 quotient in BH reg
        shr     bl, 3           ; place 2^5 reminder in BL reg

        ; ...
        ; insert 1 at X position, num_elem is BH, num bite is BL 
        mov     cl, bl          ; only CL reg can be used in shr/shl
        mov     eax, 1          ; create a mask
        shl     eax, cl         ; put 1 to the position BL 
        or      [arr512+4*bh-4], eax    ; apply mask

        ; ...
        ; delete entry from arr512
        mov     cl, bl
        mov     eax, 1
        shl     eax, cl
        not     eax
        and     [arr512+4*bh-4], eax

        ; ...
        ; test if X is in the arr512
        mov     cl, bl
        mov     eax, 1
        shl     eax, cl
        test    [arr512+4*bh-4], eax
        ; if the result of this operation is 0,
        ; then X is not in the arr512 (ZF=1).
        ; ZF=0 means X is in arr512
        
        ; ...
        ; count the number of entries in arr512
        xor     ebx, ebx    ; EBX:=0
        mov     ecx, 16     ; counter of elements
lp1:    mov     eax, [arr512+4*ecx-4]   ; load array element
lp2:    test    eax, 1      ; is there 1 in the lowest bit?
        jz      notone      ; 0 in the lowest bit
        inc     ebx         ; +1 to the number of entries
notone: shr     1           ; shift entries by 1
        test    eax, eax    ; EAX==0?
        jnz     lp2         ; test remaining bits
        loop    lp1         ; decrement ECX and 
                            ; load next element if ECX!=0           
        ; the number of entries is now stored in EBX
        
        ; ...
exit:                       ; exit program 

