_screensave:
; Save screen
%startup _screensave_setup
%allocate mr@screensave_stack 30
%allocate mr@screensave_ptr 2
        push    ax,bx,cx,si,di,es
        mov     ax,160
        mov     bl,byte ptr ss:[mr@screen_length]
        mov     bh,0
        mul     bx                                      ; AX=no of paras
        mov     bx,ax
        call    _farmalloc
        mov     si,word ptr ds:[mr@screensave_ptr]
        cmp     si,30
        jae     >L1
        add     word ptr ds:[mr@screensave_ptr],2
        mov     word ptr ds:[si+mr@screensave_stack],bx         ; store segment
        mov     es,bx
        xor     si,si
        xor     di,di
        mov     ax,80
        mov     bl,byte ptr ss:[mr@screen_length]
        mov     bh,0
        mul     bx                                      ; AX=no of paras
        mov     cx,ax
        push    ds
        mov     ds,word ptr ss:[mr@screen_seg]
#3      shr     cx,1
#3      rep     movsd
@3      rep     movsw
        pop     ds
        pop     es,di,si,cx,bx,ax
        ret
L1:
        mov     ax,6     ; invalid function call
$errhandler

_screensave_setup:
        mov     word ptr ds:[mr@screensave_ptr],0
        ret

_screenrestore:
        push    ax,bx,cx,si,di,es
        mov     si,word ptr ds:[mr@screensave_ptr]
        cmp     si,1
        jl      >L1
        sub     word ptr ds:[mr@screensave_ptr],2
        dec     si
        dec     si  ;      sub     si,2
        push    ds
        mov     ds,word ptr ds:[si+mr@screensave_stack]     ; segment
        mov     es,word ptr ss:[mr@screen_seg]
        mov     ax,80
        mov     bl,byte ptr ss:[mr@screen_length]
        mov     bh,0
        mul     bx                                      ; AX=no of paras
        mov     cx,ax
        xor     si,si
        xor     di,di
#3      shr     cx,1
#3      rep     movsd
@3      rep     movsw
        mov     bx,ds
        pop     ds
        call    _far_mem_free
        pop     es,di,si,cx,bx,ax
        ret
L1:
        mov     ax,6     ; invalid function call
$errhandler
