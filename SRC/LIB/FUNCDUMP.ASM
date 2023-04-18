_packfunctiondump:
%startup _pfdsetup
%ss mr@func dw 21 dup(?)
        pushf
        push    cx,si,di,ds,es
        mov     cx,ss
        mov     ds,cx
        mov     es,cx
        mov     si,offset mr@func + 38
        mov     di,offset mr@func + 40
        mov     cx,21
        std
        rep     movsw
        pop     es,ds,di,si,cx
        popf
        ret

_pfdsetup:
        push    es
        push    ss
        pop     es
        mov     di,offset mr@func
        mov     cx,21
        xor     ax,ax
        rep     stosw
        pop     es
        ret
