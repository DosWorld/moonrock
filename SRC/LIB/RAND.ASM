_rand:
; Create 'random' number
;   AX = number range
; Returns:
;   AX = number
;%startup _rand_setup
%allocate mr@rand1 2
%allocate mr@rand2 2

;        push   bx,cx,dx
;        mov    cx,ax
;        mov    dx,106
;        mov    ax,ds:[mr@rand]
;        mul    dx
;        add    ax,1283
;        mov    bx,6075
;        adc    dx,0
;        div    bx
;        mov    ax,dx
;        mul    cx
;        div    bx
;        mov    ds:[mr@rand],ax
;        pop    dx,cx,bx
;        ret



;                                ; in:  bx = range (0-bx)
;                                ; out: dx = random number 0 -bx
;        push    bx,cx,dx
;        xchg    bx,ax    ; mov bx,ax
;        mov     ax,ds:[mr@rand]
;        mov     cx,9377
;        mul     cx
;        add     ax,9439
;        mov     ds:[mr@rand],ax
;        and     ax,7fffh
;        cwd
;        div     bx
;        xchg    ax,dx    ; mov ax,dx
;        inc     ax
;        pop     dx,cx,bx
;        ret

        push    bx,cx,dx,si,di
        mov     di,ax         ; temp store
;v1.1   mov     DX,ds:[mr@rand1]
;v1.1   mov     AX,ds:[mr@rand2]
        mov     cx,015Ah
        mov     bx,04E35h
;v1.1   mov     SI,AX
;v1.1   mov     AX,DX
        mov     si,ds:[mr@rand2]
        mov     ax,ds:[mr@rand1]
        mov     dx,ax
        mul     bx
        xchg    ax,cx
        mul     di
        add     cx,ax
        mov     ax,si
        mul     bx
        add     dx,cx
        add     ax,1
        adc     dx,0
;v1.1   mov     ds:[mr@rand1],dx
        mov     ds:[mr@rand2],ax
        mov     ax,dx
        mov     ds:[mr@rand1],ax           ;v1.1
;        AND     AX,07FFFh       ; Comment this out to increase range to 8 bits.
        and     ax,7fffh
        cwd
        div     di
        mov     ax,dx
        inc     ax
        pop     di,si,dx,cx,bx
        ret

_randomize:
        push    bp
        mov     bp,sp
        push    ax,bx,cx,dx
        mov     dx,[bp+6]
        mov     cx,[bp+4]   ; CX:DX
        test    dx,dx
        jnz     >L1
        test    cx,cx
        jnz     >L1
        xor     ah,ah
        int     1ah             ; CX:DX = ticks
L1:
;v1.1   XOR     DX,DX
;v1.1   mov     ds:[mr@rand1],DX
        mov     ds:[mr@rand1],cx
        mov     ds:[mr@rand2],dx
        pop     dx,cx,bx,ax
        pop     bp
        ret     4


;_rand_setup:
; Seed the random number generator
;        xor   ah,ah
;        int   1ah                    ; return ticks in CX:DX
;        add   cx,dx
;        mov   ds:[mr@rand],cx
;        ret

