_keystatus:
; return status of keyboard scan code BX
; returns:
; AX = 0 key not pressed
; AX = 1 key pressed
%startup _install09
        push    bx
        xor     bh,bh
        mov     al,byte ptr cs:[mr@keytable+bx]
        cbw
        pop     bx
        ret


_install09:
%cleanup _restore09
%include _int09
        push    ds,es
        mov     ax,3509h
        int     21h
        mov     word ptr cs:[mr@oldint09],bx
        mov     word ptr cs:[mr@oldint09+2],es

        mov     ax,2509h
        mov     dx,offset _int09
        push    cs
        pop     ds
        int     21h

        push    cs
        pop     es
        xor     ax,ax
        mov     di,offset mr@keytable
        mov     cx,64
        rep     stosw

        pop     es,ds
        ret

_restore09:
        push    ax,dx,ds
        mov     ax,2509h
        mov     dx,word ptr cs:[mr@oldint09]
        mov     ds,word ptr cs:[mr@oldint09+2]
        int     21h
        pop     ds,dx,ax
        ret

_int09:
        push    ax,bx,cx,dx,di,ds,es
        in      al,60h

        mov     di,offset mr@scanexception
        mov     cx,mr@scanexceptionend - mr@scanexception
        push    cs
        pop     es
        repnz   scasb
        jnz     >L0   ; no match to exception
L9:
;CallOldInt:
        pop     es,ds,di,dx,cx,bx,ax
        db      0eah
mr@oldint09:
        dd      ?
L0:
;        mov     cx,0b800h
;        mov     es,cx
;        mov     ch,6

        mov     bl,al
        and     bx,07fh   ; BX points to table

        mov     dl,al
        xor     dh,dh
        and     dl,80h
        rol     dl,1    ; 80h -> 1, 0 -> 0
        dec     dl      ; break = 0, make = -1

        mov     byte ptr cs:[mr@keytable+bx],dl

        jmp     short L9

mr@scanexception:
        db 000h,0E0h,0E1h,0EEh,0F0h,0FAh,0FCh,0FDh,0FEh,0FFh
mr@scanexceptionend:
mr@keytable db 128 dup (?)
