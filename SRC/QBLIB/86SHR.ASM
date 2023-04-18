; DECLARE FUNCTION SHR32& ALIAS "_shr32" (BYVAL Value&, BYVAL ShiftBy%)
; DECLARE FUNCTION SHR16% ALIAS "_shr16" (BYVAL Value%, BYVAL ShiftBy%)

_shr16:
        push    bp
        mov     bp,sp
        push    cx
        mov     cx,[bp+6]
        mov     ax,[bp+8]
        shr     ax,cl
        pop     cx
        pop     bp
        retf    4

_shr32:
        push  bp
        mov   bp,sp
        push  cx
        mov   cx,[bp+6]
        mov   ax,[bp+8]
        mov   dx,[bp+10]
        jcxz  >L2
L1:
        clc
        rcr   dx,1
        rcr   ax,1
        loop  L1
L2:
        pop   cx
        pop   bp
        retf  6
