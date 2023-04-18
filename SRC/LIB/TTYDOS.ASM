_tty_str_dos:
; Write string using DOS
;    DS:DI -> string to print
@1        push  ax,bx,cx,dx
#1        pusha

        mov   cx,[di]
        jcxz  >L1
        lea   dx,[di+2]
        mov   ah,40h
        mov   bx,1
        int   21h
L1:
@1        pop   dx,cx,bx,ax
#1        popa
        ret
