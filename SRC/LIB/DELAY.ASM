_microdelay:
; BX = time to delay
        push    ax,cx,dx
        mov     al,0
        out     43h,al
        in      al,61h
        in      al,40h
        mov     ah,al
        in      al,61h
        in      al,40h
        xchg    al,ah
        mov     cx,ax     ; start point
        sub     ax,bx
        mov     dx,ax     ; end point
L1:
        mov     al,0
        out     43h,al
        in      al,61h
        in      al,40h
        mov     ah,al
        in      al,61h
        in      al,40h
        xchg    al,ah
        cmp     ax,cx
        ja      >L9     ; wrapped around!
        cmp     ax,dx
        ja      L1
L9:
        pop     dx,cx,ax
        ret

_delay:
; BX = number of ticks to delay
;endvalL equ          ; SI
;endvalH equ          ; DI
;chkvalL equ [bp-2]
;chkvalH equ [bp-4]
;---temptickL equ [bp-10]
;---temptickH equ [bp-12]
        push    bp
        mov     bp,sp
        sub     sp,4
        push    ax,cx,dx,si,di

; 0004  endval& = timertick + value&
        mov     ah,0
        int     1ah
        add     dx,bx
        adc     cx,0
        mov     si,dx
        mov     di,cx

; 0005	chkval& = endval& - value&
        sub     dx,bx
        sbb     cx,0
        mov     [bp-2],dx
        mov     [bp-4],cx

; 0006	tt& = timertick
L1:
        mov     ah,0
        int     1ah
;        mov     [bp-10],dx
;        mov     [bp-12],cx

; 0007	while tt& < endval&
;        mov     ax,[bp-10]
;        mov     dx,[bp-12]
;        mov     ax,dx
;        mov     dx,cx
        cmp     cx,di
        jnz     short >L2
        cmp     dx,si
L2:
        jae     short >L9   ; done
;        jmp     short >L9   ; done
;L3:

; 0008	if tt& < chkval& then goto rollover:
        cmp     cx,[bp-4]
        jnz     short >L4
        cmp     dx,[bp-2]
L4:
        jb      short >L9   ; rollover

        call    _timeslice

        jmp     short L1

L9:

        pop     dx,cx,ax
        mov     sp,bp
        pop     bp
        ret

