_cprint:
        push  bp
        mov   bp,sp
        push  ax,si
        mov   si,[bp+2]
L1:
        mov   al,cs:[si]
        or    al,al
        jz    >L2
        call  _tty
        inc   si
        jmp   short L1
L2:
        inc   si
        mov   [bp+2],si
        pop   si,ax
        pop   bp
        ret
