_ival_bx:
                push    ax
                call    _ival
                mov     bx,ax
                pop     ax
                ret
_ival:
; Returns numerical value of string DS:SI in AX
                push    bx,cx,dx
                xor     cx,cx
                mov     bx,ds:[si]
                xor     ax,ax
                or      bx,bx
                jz      >L9
;                inc     bx
                lodsw   ; add si,2
;                inc     si
;                inc     si
L1:
                lodsb
                cmp     al,' '
                jbe     L1
                dec     si

                mov     ah,ch                          ;Assume it's positive
                cmp     byte ptr ds:[si],'-'
                jnz     >L1
;
; Set up for negative numbers.
;
                inc     si                              ;Skip "-"
                mov     ah,1                           ;Flag negative value.
;
L1:
                call    _mr$ivalS0
                jc      >L2                             ;Quit if error.
                cmp     ah,0
                je      >L1
                neg     cx
                clc
                jmp     short >L2                             ;Not really an error.

L1:
                or      cx,cx                          ;See if overflow
                clc
                jns     >L2                             ;Not an error
                stc                                        ;Error if negative.
L2:
                mov     ax,cx
L9:
                pop     dx,cx,bx
                ret

_mr$ivalS0:
                pushf
                cld
;
L0:
                lodsb
                cmp     al,'0'
                jb      >L1
                cmp     al,'9'
                ja      >L1
                xor     al,'0'
                cmp     al,10
                ja      >L1
                shl     cx,1
                jc      >L2
                mov     dx,cx
                shl     cx,1
                jc      >L2
                shl     cx,1
                jc      >L2
                add     cx,dx
                jc      >L2
                add     cl,al
                adc     ch,0
                jc      >L2
                dec     bx
                jnz     L0
L1:
                popf
                clc
                ret
L2:
                popf
                stc
                ret

