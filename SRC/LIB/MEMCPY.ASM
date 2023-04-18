_memcopy:
        push    bp
        mov     bp,sp
        push    si,di
#Z        push    es
#Z        push    ds
#Z        pop     es
        mov     cx,[bp+4]    ; bytes
        mov     di,[bp+6]    ; dest
        mov     si,[bp+8]    ; source
#D      mov     ax,si
#D      add     ax,cx
#D      jc      >L1
#D      mov     ax,di
#D      add     ax,cx
#D      jc      >L1
        shr     cx,1
        rep     movsw
        adc     cx,cx
        rep     movsb
;        mov     ax,[bp+004h]
#Z        pop     es
        pop     di,si
        pop     bp
        ret     6
#DL1:
#D      mov     ax,12   ; segment overrun
#D$errhandler
