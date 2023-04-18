_tty_str_direct:
; Prints string at DS:DI
%startup _tty_str_direct_setup
%startuppm _tty_str_direct_setup_pm
@1        push  ax,bx,cx,dx,si,di,bp,ds,es

#1        pusha
#1        push  ds,es

          push  ds
          pop   es

        mov   ds,word ptr ss:[mr@screen_seg]

        mov   bl,byte ptr ss:[mr@current_back]
@1        shl   bl,1
@1        shl   bl,1
@1        shl   bl,1
@1        shl   bl,1
#1        shl   bl,4
        mov   cl,byte ptr ss:[mr@current_fore]
        cmp   cl,16
        jb    >L1
        or    bl,80h
        and   cl,0fh
L1:
        or    bl,cl
        mov   bh,byte ptr ss:[mr@current_page]

;        mov   dx,word ptr ss:[mr@curspos]

        mov   ah,03h
        int   10h              ; get cursor position
                               ; which is now in DH (row), DL (col)

        mov   bp,es:[di]
        or    bp,bp
        jz    >L4
        inc     di
        inc     di
L1:
        mov   al,es:[di]
        cmp   al,32
        jb    >L5
L2:
        xor   cl,cl     ; Clear CL
        mov   ch,dh     ; CX = Row * 256
        shr   cx,1      ; CX = Row * 128
        mov   si,cx     ; Store in si
@1        shr   si,1      ; si = Row * 64
@1        shr   si,1      ; si = Row * 32
#1        shr   si,2
        add   si,cx     ; si = (Row * 128)+(Row * 32)={Row*160}
        xor   ch,ch     ; Clear CH register
        mov   cl,dl     ; CX = Columns
        shl   cx,1      ; Account for attribute
        add   si,cx     ; si = (Row * 160) + (Col * 2)

        mov   ah,bl
        mov   [si],ax

        inc   dl               ; getting ready to shove it to the right one char
        cmp   dl,80           ; check for wrap
        jb    >L3
        xor   dl,dl
        jmp   short >L8
L3:
        inc   di
        dec   bp
        jnz   L1

;        mov   word ptr ss:[mr@curspos],dx
        mov   ah,02h           ; set new cursor position
        int   10h
L4:
@1        pop   es,ds,bp,di,si,dx,cx,bx,ax
#1        pop   es,ds
#1        popa
        ret
L5:
        cmp   al,13
        jz    >L7
        cmp   al,10
        jz    >L8
        cmp   al,7
        jnz   L2
        push  dx
        mov   ah,02h
        mov   dl,7
        int   21h
        pop   dx
        jmp   short L3
L7:
        mov   dl,0
        jmp   short L3
L8:
        inc   dh
        cmp   dh,byte ptr ss:[mr@screen_length]
        jb    L3

        push  es,si,di
        push  ds
        pop   es
        mov   si,160
        xor   di,di
;        mov   cx,1920
        mov   cx,word ptr ss:[mr@screen_scroll]
@3        rep   movsw
#3        rep   movsd
        mov   cx,80
        mov   ah,bl
        mov   al,0
        rep   stosw
        pop   di,si,es
        dec   dh
        jmp   short L3

_tty_str_direct_setup:
;        push  ax,bx,cx,dx,di,es
;        mov   word ptr ss:[mr@screen_seg],0b800h
        push    es
        mov   al,0
        mov   byte ptr ss:[mr@current_page],al
        mov   byte ptr ss:[mr@current_back],al
        mov   byte ptr ss:[mr@current_fore],7
        mov   byte ptr ss:[mr@screen_length],25

;        mov   ah,03h
;        mov   bh,0
;        int   10h              ; get cursor position
;                               ; which is now in DH (row), DL (col)
;        mov   word ptr ss:[mr@curspos],dx
        mov   dx,3ceh
        mov   al,6
        out   dx,al
        inc   dl
        in    al,dx
#1        shr   al,2
@1        shr   al,1
@1        shr   al,1
        and   al,03h
        mov   bl,al
        mov   bh,0
        add   bx,bx
        mov   ax,word ptr cs:[mr@seglist+bx]
        mov   word ptr ss:[mr@screen_seg],ax

        mov   ah,0fh
        int   10h                   ; get current video mode
        cmp   al,7                 ; special case, hercules
        jnz   >L1
        mov   word ptr ss:[mr@screen_seg],0b000h
L1:

        mov   ax,2b01h
        mov   cx,4445h
        mov   dx,5351h
        int   21h
        cmp   al,0ffh     ; DV is present if AL<>FFh
        jz    >L1

        mov   es,word ptr ss:[mr@screen_seg]
        xor   di,di
        mov   ah,0feh
        int   10h          ; get DESQview shadow buffer
        mov   word ptr ss:[mr@screen_seg],es

L1:
        mov   ax,040h     ; <----------+
        mov   es,ax       ;            |
        mov   al,byte ptr es:[084h] ;  |
;        xor   ah,ah      ; AH = 0 already
        inc   ax
        mov   word ptr ss:[mr@screen_length],ax
        mov   bx,80
        mul   bx
        sub   ax,80
#3      shr   ax,1
        mov   word ptr ss:[mr@screen_scroll],ax

;        pop   es,di,dx,cx,bx,ax
        pop     es
        ret

mr@seglist   dw 0a000h,0a000h,0b000h,0b800h
%ss mr@screen_seg    dw 1 dup (?)
%ss mr@current_page  db 1 dup (?)
%ss mr@current_fore  db 1 dup (?)
%ss mr@current_back  db 1 dup (?)
%ss mr@screen_length db 1 dup (?)
%ss mr@screen_scroll dw 1 dup (?)
;%ss mr@curspos       dw 1 dup (?)

_tty_str_direct_setup_pm:
        mov   ax,2
        mov   bx,word ptr ss:[mr@screen_seg]
        int   31h               ; get real mode selector
        jc    >L1
        mov   word ptr ss:[mr@screen_seg],ax
        ret
L1:
        mov   ax,10
$errhandler

