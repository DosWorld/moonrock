
_words:
; Converts signed integer in AX to string
;    AX    =  value
;    DS:DI -> pointer to output string

        push    ax,bx,cx,dx
        mov     bx,7
        call    _mem_alloc
        push    di
@S        inc     di
@S        inc     di
#S        add     di,2
        xor     cx,cx
        cmp     ax,0
        jge     >L1
        mov     byte ptr [di],'-'
        inc     di
        inc     cx
        neg     ax
;
L1:
        call    _word2
        pop     di
        mov     [di],cx
        pop     dx,cx,bx,ax
        ret

_wordu:

; Converts unsigned integer in AX to string
;    AX    =  value
;    DS:DI -> pointer to output string

        push    ax,bx,cx,dx
        mov     bx,7
        call    _mem_alloc
        push    di
@S        inc     di
@S        inc     di
#S        add     di,2
        xor     cx,cx
        call    _word2
        pop     di
        mov     [di],cx
        pop     dx,cx,bx,ax
        ret

_word2:
        mov     bx,10
        xor     dx,dx
        div     bx
        or      ax,ax          ;See if ax=0
        jz      >L1
        push    dx
        call    _word2
        pop     dx
L1:
        mov     al,dl
        or      al,'0'
        mov     [di],al
        inc     di
        inc     cx
        ret
