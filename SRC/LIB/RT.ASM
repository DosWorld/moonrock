_abs16:
; Return absolute value
; AX = input
; AX = output
        or      ax,ax
        jl      >L1
        ret
L1:
        neg     ax
        ret

_sgn16ax:
;    AX = input
; returns:
;    AX = -1   negative
;    AX = 0    zero
;    AX = 1    positive
        or      ax,ax
        jz      >L1
        mov     ax,1
        jl      >L2
L1:
        ret
L2:
        neg     ax
        ret

_sgn16bx:
;    BX = input
; returns:
;    BX = -1   negative
;    BX = 0    zero
;    BX = 1    positive
        or      bx,bx
        jz      >L1
        mov     bx,1
        jl      >L2
L1:
        ret
L2:
        neg     bx
        ret
