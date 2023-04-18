_hex32:
; Converts DX:AX to 8 digit hex string
;    DX:AX =  value
; returns:
;    DS:SI -> pointer to output string
      push    ax,bx,cx,dx
      mov     bx,10
      call    _mem_alloc
      push    di
@S      inc       di
@S      inc       di
#S      add       di,2
      mov     bl,dh
      call    _hex
      mov     bl,dl
      call    _hex
      mov     bl,ah
      call    _hex
      mov     bl,al
      call    _hex
      pop     di
      mov     word ptr ds:[di],8
      pop     dx,cx,bx,ax
      ret

_hex16:
; Converts AX to 4 digit hex string
;    AX    =  value
; returns:
;    DS:DI -> pointer to output string

       push    ax,bx,cx
       mov     bx,6
       call    _mem_alloc
       push    di
@S       inc      di
@S       inc      di
#S       add      di,2
       mov     bl,ah
       call    _hex
       mov     bl,al
       call    _hex
       pop     di
       mov     word ptr ds:[di],4
       pop     cx,bx,ax
       ret

_hex8:
; Converts AL to 2 digit hex string
;    AL    =  value
; returns:
;    DS:DI -> pointer to output string

       push    ax,bx,cx
       mov     bx,4
       call    _mem_alloc
       push    di
@S       inc      di
@S       inc      di
#S       add      di,2
       mov     bl,al
       call    _hex
       pop     di
       mov     word ptr ds:[di],2
       pop     cx,bx,ax
       ret

_hex:
       push    ax
       push    bx
@1       shr     bl,1
@1       shr     bl,1
@1       shr     bl,1
@1       shr     bl,1
#1       shr     bl,4
       call    _nybble
       pop     bx
       call    _nybble
       pop     ax
       ret

_nybble:
       and     bx,0fh
       mov     al,byte ptr cs:[bx+mr@nybtab]
       mov     ds:[di],al
       inc     di
       ret

mr@nybtab:     db      '0123456789abcdef'

