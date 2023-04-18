_chknullptr:
        cmp     word ptr ds:[0],0   ; clobbered?
        jnz     >L1
        ret
L1:
        call    _cprint
        db      13,10,'Program error: null pointer assignment',0
        ret
