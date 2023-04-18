_tty:
        push  ax,dx
        mov   dl,al
        mov   ah,02h
        int   21h
        pop   dx,ax
        ret

_tty_cr:
        mov   al,13
        call  _tty
        mov   al,10
        jmp   _tty
%include _tty

_inkey:
; Returns keypress in AX, or -1 if none available
        push  dx
        mov   ah,06h
        mov   dl,0ffh
;L1:
        int   21h
        jz    >L1
        mov   ah,0
        pop   dx
        ret
L1:
        mov   ax,-1
        pop   dx
        ret

_keyboard_input:
; Get line input from keyboard
;    BX = maximum length of line
;    CL = character to fill with
; returns:
;    DS:DI -> pointer to string

        push  ax,bx,cx,dx
        mov   dx,bx
        add   bx,2
        call  _mem_alloc
        push  di
@S        inc   di
@S        inc   di
#S        add   di,2
        xor   bx,bx
        cmp   cl,' '
        jz    >L3
        push  cx
        mov   al,cl
        mov   cx,dx
L1:
        call  _tty
        loop  L1

        mov   al,8
        mov   cx,dx
L2:
        call  _tty
        loop  L2
        pop   cx
L3:
        mov   ah,07h
        int   21h
        cmp   al,' '
        jae   >L6
        cmp   al,13
        jz    >L9
        cmp   al,8
        jz    >L5
        jmp   short L3

L5:
        or    bx,bx
        jz    L3
        dec   bx
        dec   di
        mov   al,8
        call  _tty
        mov   al,cl
        call  _tty
        mov   al,8
        call  _tty
        jmp   short L3
L6:
        cmp   bx,dx
        jz    L3
        mov   [di],al
        inc   bx
        inc   di
        call  _tty
        jmp   short L3
L9:
        pop   di
        push  di
        mov   [di],bx
        mov   si,di
        call  _str_copy
        pop   bx
        call  _mem_free
        pop   dx,cx,bx,ax
        ret

