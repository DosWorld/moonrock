_seg2huge:
; Converts segment:offset to huge (linear) pointer
;    AX = segment
; returns:
;    DX:AX = linear address
        xor     dx,dx
	mov	cx,4
L1:
	clc
	rcl	ax,1
	rcl	dx,1
        loop    short L1
        ret

_huge2seg:
; Converts linear huge address to segment:offset
;    ES = top 16 bits of 32 bit *linear* address
; returns:
;    ES = segment
; eg. ES:BX = 000A:0050   (A0050)
; ->  ES:BX = A000:0050

        push    ax
        mov     ax,es
@1      push    cx
@1      mov     cl,12
@1      shl     ax,cl
@1      pop     cx
#1      shl     ax,12
        mov     es,ax
        pop     ax
        ret

_arraycalc_word_l:
; Calculate segment:offset pointer to huge array byte element
;    BP = element low word
;    <stack> element high word
;    ES = starting seg
; returns:
;    ES:BP -> array element
        push  bp
        mov   bp,sp
        push  cx,dx
        mov   dx,[bp+4]
        mov   bp,[bp]
;        clc
;        rcl   bp,1    ; shift DX:BP left 1 bit
;        rcl   dx,1    ; DX:BP = 32 bit element offset
@1        mov   cl,12
@1        shl   dx,cl   ; convert to seg
#1        shl   dx,12
        mov   cx,es
        add   cx,dx
        mov   es,cx   ; ES:BP now points to element
        pop   dx,cx
        ret   2

;_arraycalc_word_l:
;; Calculate segment:offset pointer to huge array word element
;;    BP = element low word
;;    <stack> element high word
;;    ES = starting seg
;; returns:
;;    ES:BP -> array element
;        push  bp
;        mov   bp,sp
;        push  cx,dx
;        mov   dx,[bp+4]
;        mov   bp,[bp]
;        clc
;        rcl   bp,1    ; shift DX:BP left 1 bit
;        rcl   dx,1    ; DX:BP = 32 bit element offset
;@1        mov   cl,12
;@1        shl   dx,cl   ; convert to seg
;#1        shl   dx,12
;        mov   cx,es
;        add   cx,dx
;        mov   es,cx   ; ES:BP now points to element
;        pop   dx,cx
;        ret   2

_arraycalc_dword_l:
; Calculate segment:offset pointer to huge array doubleword element
;   BP = element low word
;   <stack> = element high word
;   ES = starting seg
; returns:
;   ES:BP -> array element
        push  bp
        mov   bp,sp
        push  cx,dx
        mov   dx,[bp+4]
        mov   bp,[bp]
        clc
        rcl   bp,1
        rcl   dx,1
        clc
        rcl   bp,1
        rcl   dx,1    ; DX:BP = 32 bit element offset
@1        mov   cl,12
@1        shl   dx,cl   ; convert to seg
#1        shl   dx,12
        mov   cx,es
        add   cx,dx
        mov   es,cx   ; ES:BP now points to element
        pop   dx,cx
        ret   2

_arraycalc_word:
; Calculate segment:offset pointer to huge array byte element
;    BP = element
;    ES = starting seg
; returns:
;    ES:BP -> array element
        push  cx,dx
        xor   dx,dx
@1        mov   cl,12
@1        shl   dx,cl   ; convert to seg
#1        shl   dx,12
        mov   cx,es
        add   cx,dx
        mov   es,cx   ; ES:BP now points to element
        pop   dx,cx
        ret

_arraycalc_word:
;; Calculate segment:offset pointer to huge array word element
;;    BP = element
;;    ES = starting seg
;; returns:
;;    ES:BP -> array element
;        push  cx,dx
;        xor   dx,dx
;        clc
;        rcl   bp,1    ; shift DX:BP left 1 bit
;        rcl   dx,1    ; DX:BX = 32 bit element offset
;@1        mov   cl,12
;@1        shl   dx,cl   ; convert to seg
;#1        shl   dx,12
;        mov   cx,es
;        add   cx,dx
;        mov   es,cx   ; ES:BP now points to element
;        pop   dx,cx
;        ret

_arraycalc_dword:
; Calculate segment:offset pointer to huge array doubleword element
;   BP = element
;   ES = starting seg
; returns:
;   ES:BP -> array element
        push  cx,dx
        xor   dx,dx
        clc
        rcl   bp,1
        rcl   dx,1
        clc
        rcl   bp,1
        rcl   dx,1    ; DX:BX = 32 bit element offset
@1        mov   cl,12
@1        shl   dx,cl   ; convert to seg
#1        shl   dx,12
        mov   cx,es
        add   cx,dx
        mov   es,cx   ; ES:BP now points to element
        pop   dx,cx
        ret

