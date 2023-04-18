_freestack:
        mov     ax,sp
@E      sub     ax,offset end_of_code
        ret

_unusedstack:
%startup _unusedstack_setup
        pushf
        cli
        push    cx,di,es
        push    ss
        pop     es
@E        mov     di,offset end_of_code
#E        xor     di,di    ; stack assumed to start at SS:0000
        mov     al,55h
        mov     cx,0FFFFh
        repz    scasb
        xchg    ax,cx  ; mov ax,cx
        not     ax
        pop     es,di,cx
        popf
        ret

_unusedstack_setup:
        pushf
        cli
        push    ax,cx,di,es
        push    ss
        pop     es
@E        mov     di,offset end_of_code
#E        xor     di,di    ; stack assumed to start at SS:0000
        mov     cx,sp
@E        sub     cx,di  ; calculate free stack
        sub     cx,2
        mov     al,55h
        rep     stosb
        pop     es,di,dx,ax
        popf
        ret

