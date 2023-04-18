_hash1:
; Create 16 bit hash value
;   DS:SI -> string
; returns:
;   AX = hash value
        push  cx
        mov   cx,[si]
        xor   ax,ax
@S        inc     si
@S        inc     si
#S        add     si,2
L1:
        clc
        xor   al,[si]
        inc   si
        add   ax,cx
@1      rcr   ax,1
@1      rcr   ax,1
#1      rcr   ax,2
        loop  L1
        pop   cx
        ret

_hash2:
; Create 16 bit hash value
;   DS:SI -> string
; returns:
;   AX = hash value
        push  cx
        mov   cx,[si]
        xor   ax,ax
@S        inc     si
@S        inc     si
#S        add     si,2
;        add   si,2
L1:
        clc
        xor   al,[si]
        inc   si
        sub   ax,cx
@1      rcl   ax,1
@1      rcl   ax,1
#1      rcl   ax,2
        loop  L1
        pop   cx
        ret
