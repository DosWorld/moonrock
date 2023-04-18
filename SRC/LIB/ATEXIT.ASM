_atexit:
; adds a sub to call when exiting program
; AX = offset of sub
%allocate mr@atexitptr 2
%allocate mr@atexittab 32
        push    di
        mov     di,word ptr ds:[mr@atexitptr]
        cmp     di,32
        jae     >L1
        mov     word ptr ds:[mr@atexittab+di],ax
        add     word ptr ds:[mr@atexitptr],2
        pop     di
        ret
L1:
        mov     ax,6   ; invalid function call
$errhandler
