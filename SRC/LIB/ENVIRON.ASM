_getenviron:
; Get environment variable
;    DS:SI -> name of variable
; returns:
;    DS:DI -> output string
        push    ax,bx,bp,si,es
        call    _str_ucase
        mov     bp,di

@E      push    cs
@E      pop     es
#E      mov     es,word ptr ds:[mr@psp]
        mov     bx,es:[2ch]          ; get environment segment
        mov     es,bx                ; ES now points to environment.

        xor     di,di
L1:
        mov     si,bp
;        mov     cx,[si]
;        add     si,2
        lodsw
        xchg    cx,ax
L2:
        mov     al,es:[di]
        inc     di
        cmp     al,'a'
        jb      >L3
        cmp     al,'z'
        ja      >L3
        and     al,0DFh
L3:
        cmp     al,ds:[si]
        jnz     >L5
        inc     si
        loop    L2
        cmp     byte ptr es:[di],'='  ; check for equals
        jnz     >L5
; We've found it!
        inc     di
        push    di
        mov     cx,7fffh
        xor     al,al
        repnz   scasb
        mov     bx,8001h
        sub     bx,cx
        call    _mem_alloc
        lea     cx,[bx-2]
        mov     [di],cx
        pop     si
        push    di

@S        inc     di
@S        inc     di
#S        add     di,2

        push    ds
        push    es

        push    ds
        pop     es   ; ES needs to be restored regardless since it
                     ; was modified above

        pop     ds                    ; xchg ds, es

        rep     movsb

        pop     ds

        pop     di
        jmp     >L9

L5:
        xor     al,al
        mov     cx,7fffh
        repnz   scasb
        scasb
        jz      >L8       ; end of environment
        dec     di
        jmp     short L1

L8:
        xor     di,di     ; not found
L9:
        pop     es,si,bp,bx,ax
        ret
