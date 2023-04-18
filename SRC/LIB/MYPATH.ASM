_mypath:
; Returns path of currently executing program at DS:DI
        push  ax,bx,cx,si,es

@E      push  cs
@E      pop   es
#E      mov   es,ds:[mr@psp]

;        mov   ax,6200h
;        int   21h                   ; get PSP segment
;        mov   es,bx                ; ES points to PSP

        mov   bx,es:[2ch]          ; get environment segment
        mov   es,bx                ; ES now points to environment.

        xor   al,al                ; AL=0
        xor   di,di                ; DI=0
        mov   cx,7fffh             ; environment can be up to 32k in size!

L1:

        repnz scasb                 ; search for null
        scasb                       ; is there another null after that?
        jnz   L1                    ; no, still searching

@S        inc   di
@S        inc   di
#S        add   di,2
        push  di
        mov   cx,128
        repnz scasb                 ; AL=0

        mov   bx,130
        sub   bx,cx

        call  _mem_alloc
        lea   cx,[bx-3]
        mov   [di],cx
        pop   si
        push  di
@S        inc   di
@S        inc   di
#S        add   di,2

        push  ds
        push  es

        push    ds
        pop     es   ; restored from above

        pop   ds                    ; xchg ds, es
        rep   movsb
        pop   ds

        pop   di
        pop   es,si,cx,bx,ax
        ret
