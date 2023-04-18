; DECLARE FUNCTION FFexist% ALIAS "_ffexist" (Filename$)

public _ffexist
public

_ffexist:
        push  bp
        mov   bp,sp
        push  bx,cx, dx, ds

        mov   si,[bp+6]                      ; get filename descriptor
        mov   cx,[si]                        ; get length
        jcxz  >L3
        mov   si,[si+2]                      ; get address of filename
        mov   di,_fnamebuf
L1:
        lodsb
        mov   cs:[di],al
        inc   di
        loop  L1

        mov   byte cs:[di],0

        mov   ax,3d00h
        push  cs
        pop   ds
        mov   dx, _fnamebuf
        int   21h
        jc    >L2
        mov   bx,ax
        mov   ah,3eh
        int   21h
        mov   ax,-1
        jmp   >L3
L2:
        xor   ax,ax
L3:
        pop   ds,dx,cx,bx
        pop   bp
        retf  2

_fnamebuf: db 64 dup ?
