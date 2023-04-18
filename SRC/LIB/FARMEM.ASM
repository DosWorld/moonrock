_far_mem_resize:
; Resizes DOS far memory
;    AX = size to resize to
;    BX = segment to resize
; returns:
;    BX = segment (may change)
        push  es,cx,dx
        mov   es,bx
        mov   cx,ax
        mov   bx,ax
@1        shr   bx,1
@1        shr   bx,1
@1        shr   bx,1
@1        shr   bx,1
#1        shr   bx,4
        and   al,0fh
        or    al,al
        jz    >L1
        inc   bx
L1:
        mov   dx,bx    ; temp store
        mov   ah,4ah
        int   21h
        jnc   >L9       ; no error

        mov   ah,48h
        mov   bx,dx
        int   21h       ; allocate new block
        jnc   >L1
        jmp   _err_dos
L1:
        push  ax        ; seg of new block
        push  es        ; seg to free later

        push  ds
        push  es
        pop   ds
        mov   es,ax
        xor   si,si
        xor   di,di
        shr   cx,1     ; cx / 2
        rep   movsw     ; shift data to new block
        pop   ds

        pop   es
        mov   ah,49h
        int   21h
        jnc   >L1
        jmp   _err_dos
L1:
        pop   es        ; ES now points to new block
L9:
        mov   bx,es
        pop   dx,cx,es
        ret
%include _err_dos

_far_mem_usage_ax:
; Returns amount of free far memory in DX:AX
@P        push  bx
@P@1        push  cx
@P        mov   ah,48h
@P        mov   bx,0ffffh
@P        int   21h
@P        mov   dx,bx
@P#1        shr   dx,12
@P@1        mov   cl,12
@P@1        shr   dx,cl
@P        mov   ax,bx
@P#1        shl   ax,4
@P@1        mov   cl,4
@P@1        shl   ax,cl
@P@1        pop   cx
@P        pop   bx
@P        ret

#P%allocate mr@dpmibuf 48
#P      push  di,es
#P      mov   ax,0500h
#P      push  ds
#P      pop   es
#P      mov   edi,offset mr@dpmibuf
#P      int   31h
#P      mov   ax,word ptr es:[mr@dpmibuf]
#P      mov   dx,word ptr es:[mr@dpmibuf+2]
#P      pop   es,di
#P      ret

_far_mem_usage_bx:
; Returns amount of free far memory in CX:BX
        push   dx,ax
        call   _far_mem_usage_ax
        mov    cx,dx
        mov    bx,ax
        pop    ax,dx
        ret

_far_mem_free:

; Deallocates far memory, DOS
;    BX = segment to free - ignored if BX=0

        or    bx,bx
        jz    >L1
        push  es,ax
        mov   es,bx
        mov   ah,49h
        int   21h
        jc    >L2
        pop   ax,es
L1:
        ret

L2:
        jmp   _err_dos      ; no return
%include _err_dos

_hugemalloc:
; Allocates memory, DOS, 64k+
;    CX:BX = bytes to allocate
; returns:
;    BX = allocated segment
        push    ax,dx
        xchg    cx,dx    ;DX:BX = paras

	mov	cx,4
L1:
	clc
        rcr     dx,1
        rcr     bx,1
        loop    short L1
        inc     bx

        mov     ah,48h
        int     21h
        jc      >L1
        xchg    bx,ax  ; mov bx,ax
        xchg    cx,dx
        pop     ax,dx
        ret
L1:
        jmp   _err_dos          ; no return
%include _err_dos

_farmalloc:
; Allocates memory, DOS
;    BX = bytes to allocate
; returns:
;    BX = allocated segment

        push  ax
        mov   ax,bx
        clc
@1        shr   bx,1
@1        shr   bx,1
@1        shr   bx,1
@1        shr   bx,1
#1        shr   bx,4
        and   al,0fh
        or    al,al
        jz    >L1
        inc   bx
L1:
        mov   ah,48h
        int   21h
        jc    >L2
        mov   bx,ax
        pop   ax
        ret
L2:
        jmp   _err_dos          ; no return
%include _err_dos

