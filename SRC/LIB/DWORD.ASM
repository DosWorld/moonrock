_doublewords:
; Converts signed integer in AX:DX to string
;    DX:AX =  value
; returns:
;    DS:DI -> pointer to output string

        push    ax,bx,cx,dx,si
        mov     bx,13      ; largest number is -n,nnn,nnn,nnn
        call    _mem_alloc
        push    di
@S        inc     di
@S        inc     di
#S        add     di,2
        xor     si,si      ; used as size of string counter
        cmp     dx,0
        jge     >L1
        push    ax
        mov     byte ptr [di],'-'
        inc     si
        inc     di
        pop     ax
        neg     dx
        neg     ax
        sbb     dx,0
;
L1:
        call    _doubleword2
        pop     di
        mov     word ptr [di],si
        pop     si,dx,cx,bx,ax
        ret

_doublewordu:

; Converts unsigned integer in DX:AX to string
;    DX:AX =  value
; returns:
;    DS:DI -> pointer to output string

        push    ax,bx,cx,dx,si
        mov     bx,12      ; largest number is n,nnn,nnn,nnn
        call    _mem_alloc
        push    di
@S        inc     di
@S        inc     di
#S        add     di,2
        xor     si,si      ; used as size of string counter
        call    _doubleword2
        pop     di
        mov     word ptr [di],si
        pop     si,dx,cx,bx,ax
        ret

_doubleword2:
        call    _doubleword_div10
        cmp     ax,dx          ;See if dx:ax=0
        jnz     >L1
        or      ax,ax
        jz      >L2
L1:
        push    bx
        call    _doubleword2
        pop     bx
L2:
        mov     al,bl
        or      al,'0'
        mov     [di],al
        inc     di
        inc     si
        ret

_doubleword_div10:
        mov     cx,10
        mov     bx,ax
        xchg    ax,dx
        xor     dx,dx
        div     cx
        xchg    bx,ax
        div     cx
        xchg    dx,bx
        ret
