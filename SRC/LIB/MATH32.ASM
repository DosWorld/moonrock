_div32_w16:
; Divide a 32 bit number with a 16 bit number
;   DS:SI -> num1 (dword)
;   DS:DI -> num2 (word)
; returns:
;   DX:AX  = result
        push    bx,cx
        mov     ax,[si]
        mov     dx,[si+2]
        mov     bx,[di]
        xchg    cx,dx
        xchg    ax,cx
        sub     dx,dx
        div     bx
        xchg    cx,ax
        div     bx
        mov     dx,cx
        pop     cx,bx
        ret

_386_div32_w16:
; Divide a 32 bit number with a 16 bit number [386]
;   DS:SI -> num1 (dword)
;   DS:DI -> num2 (word)
; returns:
;   DX:AX  = result
        db     66h
        push   bx                   ;; push   ebx
        db     66h,8bh,04h        ;; mov    eax,[si]
        db     66h,0fh,0bfh,1dh  ;; movsx  ebx,word ptr [di]
        db     66h,0f7h,0fbh      ;; idiv   ebx
        mov    dx,ax
        db     66h,0c1h,0e8h,10h ;; shr    eax,16
        xchg   ax,dx
        db     66h
        pop    bx                   ;; pop ebx
        ret

_mul32:
; Multiply two 32 bit numbers
;   DS:SI -> num1
;   DS:DI -> num2
; returns:
;   DX:AX  = result
        push    bp
        mov     bp,sp
        sub     sp,8

        push    bx,cx,si,di

        mov     ax,[si]
        mov     dx,[si+2]

        mov     bx,[di]
        mov     cx,[di+2]

        mov     di,dx                   ; save copy of argument 1
        mov     si,ax

        mul     bx                      ; arg1 low * arg2 low
        mov     [bp-2],ax
        mov     [bp-4],dx

        mov     ax,di                   ; arg1 high * arg2 high
        mul     cx
        mov     [bp-6],ax
        mov     [bp-8],dx                   ;save v4

        mov     ax,di                   ; arg1 high * arg2 low
        mul     bx
        add     [bp-4],ax                   ; accumulate result
        adc     [bp-6],dx
        adc     word ptr [bp-8],0

        mov     ax,si                   ; arg1 low * arg2 high
        mul     cx
        add     [bp-4],ax                   ; accumulate result
        adc     [bp-6],dx
        adc     word ptr [bp-8],0

;
; load up return registers, dx,cx,bx,ax
;
        mov     dx,[bp-4]
        mov     ax,[bp-2]
        pop     di,si,cx,bx
        mov     sp,bp
        pop     bp
        ret

_386_mul32:
; Multiply two 32 bit numbers [386]
;   DS:SI -> num1
;   DS:DI -> num2
; returns:
;   DX:AX  = result
        db     66h
        push   bx                   ;; push   ebx
        db     66h,8bh,04h        ;; mov    eax,[si]
        db     66h,8bh,1dh        ;; mov    ebx,[di]
        db     66h,0f7h,0ebh      ;; imul   ebx
        mov    dx,ax
        db     66h,0c1h,0e8h,10h ;; shr    eax,16
        xchg   ax,dx
        db     66h
        pop    bx                   ;; pop    ebx
        ret

_div32:
        push    bp
        mov     bp,sp
        push    di
        push    si
        push    bx
        xor     di,di
        mov     ax,[bp+6]
        or      ax,ax
        jnl     >L1
        inc     di
        mov     dx,[bp+4]
        neg     ax
        neg     dx
        sbb     ax,0
        mov     [bp+6],ax
        mov     [bp+4],dx
L1:
        mov     ax,[bp+10]
        or      ax,ax
        jnl     >L2
        inc     di
        mov     dx,[bp+8]
        neg     ax
        neg     dx
        sbb     ax,0
        mov     [bp+10],ax
        mov     [bp+8],dx
L2:
        or      ax,ax
        jnz     >L3
        mov     cx,[bp+8]
        mov     ax,[bp+6]
        xor     dx,dx
        div     cx
        mov     bx,ax
        mov     ax,[bp+4]
        div     cx
        mov     dx,bx
        jmp     short >L4
L3:
        mov     bx,ax
        mov     cx,[bp+8]
        mov     dx,[bp+6]
        mov     ax,[bp+4]
L5:
        shr     bx,1
        rcr     cx,1
        shr     dx,1
        rcr     ax,1
        or      bx,bx
        jnz     L5
        div     cx
        mov     si,ax
        mul     word ptr [bp+10]
        xchg    ax,cx
        mov     ax,[bp+8]
        mul     si
        add     dx,cx
        jc      >L6
        cmp     dx,[bp+6]
        jnbe    >L6
        jc      >L7
        cmp     ax,[bp+4]
        jbe     >L7
L6:
        dec     si
L7:
        xor     dx,dx
        xchg    ax,si
L4:
        dec     di
        jnz     >L8
        neg     dx
        neg     ax
        sbb     dx,0
L8:
        pop     bx
        pop     si
        pop     di
        pop     bp
        ret     8
