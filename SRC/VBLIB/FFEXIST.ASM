; DECLARE FUNCTION FFexist% ALIAS "_ffexist" (Filename$)

public _ffexist
public

_ffexist:
        push  bp
        mov   bp,sp
        push  bx,cx,dx,ds,es

        push  [bp+6]
        call  far StringLength                ; AX contains length
        mov   cx,ax
        jcxz  >L3
        push  [bp+6]
        call  far StringAddress               ; DX:AX contains far address
        mov   es,dx
        mov   bx,ax
        mov   di,_fnamebuf
L1:
        mov   al, es:[bx]
        mov   cs:[di],al
        inc   bx
        inc   di
        loop  L1

        mov   byte ptr cs:[di],0

        mov   ax,3d00h
        push  cs
        pop   ds
        mov   dx,_fnamebuf
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
        pop   es,ds,dx,cx,bx
        pop   bp
        retf  2

_fnamebuf: db 64 dup ?
