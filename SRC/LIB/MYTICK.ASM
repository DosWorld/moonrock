_mytick:
%startup _install08
%allocate mr@mytick 4
        mov     ax,ds:[mr@mytick]
        mov     dx,ds:[mr@mytick+2]
        ret

_install08:
%cleanup _restore08
%include _int08
        push    ds,es
        mov     ax,3508h
        int     21h
        mov     word ptr cs:[mr@oldint08],bx
        mov     word ptr cs:[mr@oldint08+2],es

        mov     ax,2508h
        mov     dx,offset _int08
        push    cs
        pop     ds
        int     21h
        pop     es,ds
        ret

_restore08:
        push    ax,dx,ds
        mov     ax,2508h
        mov     dx,word ptr cs:[mr@oldint08]
        mov     ds,word ptr cs:[mr@oldint08+2]
        int     21h
        pop     ds,dx,ax
        ret

_int08:
        pushf
@3        add     word ptr ds:[mr@mytick],1
@3        adc     word ptr ds:[mr@mytick+2],0
#3        inc     dword ptr ds:[mr@mytick],1
        popf
        db      0eah
mr@oldint08:
        dd      ?
