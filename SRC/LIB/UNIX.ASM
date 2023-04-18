_isleapyear:
;LeapYear if Year Mod 4 = 0
;   EXCEPT if Year Mod 100 = 0
;       UNLESS Year Mod 400 = 0
;
; returns AX = -1  yes
; returns AX = 0   no
;        push    bp
;        mov     bp,sp
        push    bx,cx,dx,si
;        mov     ax,[bp+4]
        mov     cx,ax   ; year store
        xor     si,si
        cwd
        mov     bx,4
        div     bx
        or      dx,dx   ; = 0?
        jnz     >L9
; leapyear=TRUE
        mov     si,-1

        mov     ax,cx
        cwd
        mov     bx,100
        div     bx
        or      dx,dx   ; <> 0?
        jnz     >L9
; leapyear=FALSE
        xor     si,si

        mov     ax,cx
        cwd
        mov     bx,400
        div     bx
        or      dx,dx   ; = 0?
        jnz     >L9
; leapyear=TRUE
        mov     si,-1
L9:
        mov     ax,si
        pop     si,dx,cx,bx
;        pop     bp
        ret
;       ret     2
