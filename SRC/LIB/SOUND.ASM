_soundon:
; BX = note to play
        push    ax,bx,dx
        mov     ax,34DCh
        mov     dx,12h
        cmp     dx,bx
        jnc     >L1
        div     bx
        xchg    ax,bx        ;  mov     bx,ax
        in      al,61h
        test    al,03h
        jnz     >L2
        or      al,03h
        out     061h,al
        mov     al,0B6h
        out     043h,al
L2:
        mov     al,bl
        out     042h,al
        mov     al,bh
        out     042h,al
L1:
        pop     dx,bx,ax
        ret

_soundoff:
        push    ax
        in      al,61h
        and     al,0FCh
        out     061h,al
        pop     ax
        ret

