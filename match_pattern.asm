; This subprogram compares the reference string (pattern)
;   with an example string (string).
; This subprogram is recursive.
; Character '?' matches with any other character of the reference string.
; Character '*' matches with any substring of the reference string
;   incuding an empty substring.
; It is assumed that string address is passed through the stack at EBP+8
;   and the pattern address is passed through the stack at EBP+12.
; Value of 0 indicates the end of string/pattern.
; One local variable I is used (4 bytes).
; The result is passed through the EAX (true -- 1 or false -- 0).
; Call example:
;   push dword pattern
;   push dword string
;   call match
;   add esp, 8


match:                          ; organise stack frame
        push ebp                ; save old content of EBP to stack
        mov ebp, esp            ; copy stack pointer to EBP
        sub esp, 4              ; make space (4 bytes) for local variable I
        
        push esi                ; save old content of ESI and EDI to stack
        push edi                ;   because they will be used later here 
                                ; load arguments for this call:
        mov esi, [ebp+8]        ;   string  
        mov edi, [ebp+12]       ;   pattern
  
.again:                         ; jump here to compare another char of the
                                ;   pattern with another char or substring
                                ;   of the string
        cmp byte [edi], 0       ; is pattern empty?
        jne .not_end            ; jump if pattern is not empty
        cmp byte [esi], 0       ; is string empty?
        jne near .false         ; pattern is empty but string is not: FALSE
                                ;   "near" is required since .false label
                                ;   can't be reached with short jump
        jmp .true               ; both pattern and string are empty: TRUE
        
.not_end:                       ; pattern is not empty
        cmp byte [edi], '*'     ; is the first char of pattern '*'?
        jne .not_star           ; jump to simple chars comparison
        mov dword [ebp-4], 0    ; I := 0 

.start_loop:                    ; prepare for recursive call
        mov eax, edi            ; save pattern address in EAX
        inc eax                 ; drop the first char ('*') of pattern
        push eax                ; second argument (pattern) goes to stack
                                ;   first to be at EBP+12
        mov eax, esi            ; save string address to eax
        add eax, [ebp-4]        ; drop I number of chars of string
        push eax                ; first argument -- sring (EBP+8)
        
        call match              ; recursive call with updated arguments
        
        add esp, 8              ; clear stack after call (4 bytes per arg)
        test eax, eax           ; check the returned value
        jnz .true               ; not zero: TRUE
                                ; this means that string leftover matched
                                ;   pattern
        add eax, [ebp-4]        ; returned zero (EAX = 0): FALSE, 
                                ;   EAX := EAX + I
                                ; let's try to drop one more char and match
                                ;   what's left with pattern
        cmp byte [esi+eax], 0   ; check if the string is not already empty
        je .false               ; string is emtpy but pattern is not: FALSE
        inc dword [ebp-4]       ; otherwise drop one more char from string
        jmp .start_loop         ; try again
        
.not_star:
        mov al, [edi]           ; copy pattern char to AL (8 bit part of 
                                ;   EAX)
        cmp al, '?              ; is this char '?' 
        je .quest               ; if so, jump out
        
        cmp al, [esi]           ; pattern char is neither '*' nor '?'
                                ;   it should match exactly the char from
                                ;   string (if string is empty this
                                ;   comparison will fail as well)
        jne .false              ; pattern char doesn't match string: FALSE
        jmp .goon               ; chars match, go on

.quest:
        cmp [esi], 0            ; any char matches '?' except 0 (empty str)
        jz .false               ; if string is empty: FALSE
                                ;   otherwise, continue to .goon

.goon:                          ; jump here if chars match
        inc esi                 ; move to the next char in string
        inc edi                 ; move to the next char in pattern
        jmp .again              ; continue comparison
.true:
        mov eax, 1              ; return TRUE
        jmp .quit

.false:
        xor eax, eax            ; return FALSE

.quit:                          ; execution is over, restore registers and
                                ;   stack by removing values from stack and
                                ;   putting them back to the approp.
                                ;   locations
                                ; at this point stack stores:
                                ;   - old value of EDI
                                ;   - old value of ESI
                                ;   - local variable I
                                ;   - old value of EPB
                                ;   - return address (curr. value of EBP 
                                ;       stores a stack address to this 
                                ;       value)
                                ;   - passed arguments
        pop edi                 ; restore EDI
        pop esi                 ; restore ESI
        mov esp, epb            ; restore stack pointer from EBP, this 
                                ;   deletes local variable I, ESP points at
                                ;   the old value of EBP
        pop epb                 ; restore EPB
                                ; now ESP points at the return address
        ret                     ; return control
 
