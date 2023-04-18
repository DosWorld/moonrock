_int86:
%allocate i86bp 2
; int86(int%, ireg^, oreg^)
;       bp+8  bp+6   bp+4
        push    bp
        mov     bp,sp
        sub     sp,4
        pushf
        push    ax,bx,cx,dx,si,di,es

        mov     al,[bp+8]
        mov     byte ptr cs:[L1],al

        mov     di,[bp+6]
; AX,BX,CX,DX,BP,SI,DI,FLAGS
        mov     ax,[di]
        mov     bx,[di+2]
        mov     cx,[di+4]
        mov     dx,[di+6]
        mov     si,[di+10]
        push    bp
        mov     bp,[di+8]
        mov     di,[di+12]
        push    ds
        jmp     short >L0
L0:
        push    word ptr [di+14]
        popf
        db      0cdh
L1:
        db      ?
        pop     ds
        mov     word ptr ds:[i86bp],bp
        pop     bp

        pushf
        pop     [bp-2]
        mov     word ptr [bp-4],di
        mov     di,[bp+4]
        mov     [di],ax
        mov     [di+2],bx
        mov     [di+4],cx
        mov     [di+6],dx
        mov     ax,ds:[i86bp]
        mov     [di+8],ax     ; BP
        mov     [di+10],si
        mov     ax,[bp-4]
        mov     [di+12],ax    ; DI
        mov     ax,[bp-2]
        mov     [di+14],ax    ; flags

        pop     es,di,si,dx,cx,bx,ax
        popf
        mov     sp,bp
        pop     bp
        ret     6


_int86x:
%allocate i86bp 2
; int86x(int%, ireg^, oreg^)
;       bp+8  bp+6   bp+4
        push    bp
        mov     bp,sp
        sub     sp,4
        pushf
        push    ax,bx,cx,dx,si,di,es

        mov     al,[bp+8]
        mov     byte ptr cs:[L1],al

        mov     di,[bp+6]
; AX,BX,CX,DX,BP,SI,DI,FLAGS
        mov     ax,[di+12]
        mov     word ptr cs:[i86xdi],ax  ; DI
        mov     ax,[di]
        mov     bx,[di+2]
        mov     cx,[di+4]
        mov     dx,[di+6]
        mov     si,[di+10]
        push    bp
        mov     bp,[di+8]
        mov     es,[di+18]
        push    ds
        mov     ds,[di+16]
        mov     di,cs:[i86xdi]
        jmp     short >L0
L0:
        push    word ptr [di+14]
        popf
        db      0cdh
L1:
        db      ?
        mov     word ptr cs:[i86xds],ds
        pop     ds
        mov     word ptr ds:[i86bp],bp
        pop     bp

        pushf
        pop     [bp-2]
        mov     word ptr [bp-4],di
        mov     di,[bp+4]
        mov     [di],ax
        mov     [di+2],bx
        mov     [di+4],cx
        mov     [di+6],dx
        mov     ax,ds:[i86bp]
        mov     [di+8],ax     ; BP
        mov     [di+10],si
        mov     ax,[bp-4]
        mov     [di+12],ax    ; DI
        mov     ax,[bp-2]
        mov     [di+14],ax    ; flags
        mov     ax,cs:[i86xds]
        mov     [di+16],ax    ; DS
        mov     [di+18],es

        pop     es,di,si,dx,cx,bx,ax
        popf
        mov     sp,bp
        pop     bp
        ret     6
i86xdi dw ?
i86xds dw ?

