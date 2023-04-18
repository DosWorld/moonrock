_memsetb:
; memsetb (value@, offset%, bytes%)
;         bp+8    bp+6     bp+4
        push    bp
        mov     bp,sp
        push    ax,cx,di
#Z      push    es
#Z      push    ds
#Z      pop     es
        mov     di,[bp+6]
        mov     cx,[bp+4]

#D      mov     ax,di
#D      add     ax,cx
#D      jc      >L1

        mov     ax,[bp+8]    ; al used
        rep     stosb
#Z      pop     es
        pop     di,cx,ax
        pop     bp
        ret     6
L1:
#DL1:
#D      mov     ax,12   ; segment overrun
#D$errhandler

_farmemsetb:
; memsetb (value@, segment%, offset%, bytes%)
;         bp+10   bp+8      bp+6     bp+4
        push    bp
        mov     bp,sp
        push    ax,cx,di,es
        mov     es,[bp+8]
        mov     di,[bp+6]
        mov     cx,[bp+4]

#D      mov     ax,di
#D      add     ax,cx
#D      jc      >L1

        mov     ax,[bp+10]
        rep     stosb
        pop     es,di,cx,ax
        pop     bp
        ret     8
#DL1:
#D      mov     ax,12   ; segment overrun
#D$errhandler

_memsetw:
; memsetw (value%, offset%, words%)
;         bp+8    bp+6     bp+4
        push    bp
        mov     bp,sp
        push    ax,cx,di
#Z      push    es
#Z      push    ds
#Z      pop     es
        mov     di,[bp+6]
        mov     cx,[bp+4]

#D      mov     ax,di
#D      add     ax,cx
#D      jc      >L1
#D      add     ax,cx
#D      jc      >L1

        mov     ax,[bp+8]
        rep     stosw
#Z      pop     es
        pop     di,cx,ax
        pop     bp
        ret     6
#DL1:
#D      mov     ax,12   ; segment overrun
#D$errhandler

_farmemsetw:
; memsetw (value%, segment%, offset%, words%)
;         bp+10   bp+8      bp+6     bp+4
        push    bp
        mov     bp,sp
        push    ax,cx,di,es
        mov     es,[bp+8]
        mov     di,[bp+6]
        mov     cx,[bp+4]

#D      mov     ax,di
#D      add     ax,cx
#D      jc      >L1
#D      add     ax,cx
#D      jc      >L1

        mov     ax,[bp+10]
        rep     stosw
        pop     es,di,cx,ax
        pop     bp
        ret     8
#DL1:
#D      mov     ax,12   ; segment overrun
#D$errhandler
