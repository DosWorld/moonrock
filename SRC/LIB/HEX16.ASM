
_hex8_con:
       push    ax
       push    dx
       push    bx
@1       shr     bl,1
@1       shr     bl,1
@1       shr     bl,1
@1       shr     bl,1
#1       shr     bl,4
       call    __nybble_con
       pop     bx
       call    __nybble_con
       pop     dx
       pop     ax
       ret

_hex16_con:
       push    bx
       mov     bl,bh
       call    _hex8_con
       pop     bx
       call    _hex8_con
       ret

__nybble_con:
       and     bx,0Fh
       mov     dl,byte ptr cs:[bx+mr@err_nybtab]
       mov     ah,02h
       int     21h
       ret

mr@err_nybtab:
       db '0123456789ABCDEF'
