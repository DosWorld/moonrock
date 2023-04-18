_tty_str_bios:
; Prints string at DS:DI
%startup _tty_str_bios_setup
@1        push  ax,bx,cx,dx,si,ds
#1        push  ds
#1        pusha

        mov   bl,byte ptr ss:[mr@current_back]
@1        shl   bl,1
@1        shl   bl,1
@1        shl   bl,1
@1        shl   bl,1
#1        shl   bl,4
        or    bl,byte ptr ss:[mr@current_fore]
        mov   bh,byte ptr ss:[mr@current_page]
        mov   si,[di]
        or    si,si
        jz    >L4
@S        inc   di
@S        inc   di
#S        add   di,2
L1:
        mov   al,[di]
        cmp   al,32
        jb    >L5

        mov   ah,09h
        mov   cx,1
        int   10h

        mov   ah,03h
        int   10h              ; get cursor position
                               ; which is now in DH (row), DL (col)

        inc   dl               ; getting ready to shove it to the right one char
        cmp   dl,80            ; check for wrap
        jnz   >L2
        call  _tty_bios_cr
        mov   ah,03h
        int   10h
        jmp   short >L3
L2:
        mov   ah,02h
        int   10h              ; set new cursor position
L3:
        inc   di
        dec   si
        jnz   L1

L4:
@1        pop   ds,si,dx,cx,bx,ax
#1        popa
#1        pop   ds
        ret
L5:
        mov   ah,02h
        mov   dl,al
        int   21h
        jmp   short L3
%ss mr@current_page:  db ?
%ss mr@current_fore:  db ?
%ss mr@current_back:  db ?
%ss mr@screen_length: db ?

_tty_str_bios_setup:
        push  ax,es
        xor   ax,ax       ; <--------------------+
;        mov   al,0       ;                      |
        mov   byte ptr ss:[mr@current_page],al ; |
        mov   byte ptr ss:[mr@current_back],al ; |
        mov   byte ptr ss:[mr@screen_length],25 ;|
        mov   word ptr ss:[mr@current_fore],7  ; |
;                                                |
        mov   al,040h     ; <----------+---------+
        mov   es,ax       ;            |
        mov   al,byte ptr es:[084h] ;  |
;        xor   ah,ah      ; AH = 0 already
        inc   ax
        mov   word ptr ss:[mr@screen_length],ax
        pop   es,ax
        ret


_tty_scroll:
        push  ax,bx,cx,dx
        mov   bh,byte ptr ss:[mr@current_back]
@1        shl   bh,1
@1        shl   bh,1
@1        shl   bh,1
@1        shl   bh,1
#1        shl   bh,4
        or    bh,byte ptr ss:[mr@current_fore]
        xor   cx,cx            ; 0, 0 top corner
        mov   dh,byte ptr ss:[mr@screen_length]
        mov   dl,79
;        mov   al,01
        mov   ah,06h
        int   10h
        pop   dx,cx,bx,ax
        ret

_tty_bios_cr:
        push  ax,bx,cx,dx
        mov   ah,03h
        mov   bh,byte ptr ss:[mr@current_page]
        int   10h
        inc   dh
        mov   ah,02h
        int   10h
        cmp   dh,byte ptr ss:[mr@screen_length]
        jb    >L1
        mov   al,01
        call  _tty_scroll
        mov   dh,byte ptr ss:[mr@screen_length]
        dec   dh
L1:
        mov   ah,02h
        xor   dl,dl
        int   10h
        pop   dx,cx,bx,ax
        ret

_curp_get:
        push  ax,bx,cx
        mov   ah,03h
        mov   bh,byte ptr ss:[mr@current_page]
        int   10h
        pop   cx,bx,ax
        ret

_curp_set:
        push  ax,bx,cx
        mov   ah,02h
        mov   bh,byte ptr ss:[mr@current_page]
        int   10h
        pop   cx,bx,ax
        ret

_cls:
#@%startup _tty_str_direct_setup
#@%startuppm _tty_str_direct_setup_pm

@@        push  ax,bx,cx,dx,bp
@@        mov   bh,byte ptr ss:[mr@current_back]
@@@1        shl   bh,1
@@@1        shl   bh,1
@@@1        shl   bh,1
@@@1        shl   bh,1
@@#1        shl   bh,4
@@        or    bh,byte ptr ss:[mr@current_fore]
@@        xor   cx,cx            ; 0,0 top corner
@@        mov   dh,byte ptr ss:[mr@screen_length]
@@        mov   dl,79
@@        mov   ax,0600h
@@        int   10h
@@        mov   ah,02h
@@        mov   bh,byte ptr ss:[mr@current_page]
@@        xor   dx,dx
@@        int   10h

@@        pop   bp,dx,cx,bx,ax


#@        push  ax,bx,cx,dx,di,bp,es
#@        mov   es,word ptr ss:[mr@screen_seg]

#@        mov   ah,byte ptr ss:[mr@current_back]
#@@1        shl   ah,1
#@@1        shl   ah,1
#@@1        shl   ah,1
#@@1        shl   ah,1
#@#1        shl   ah,4
#@        mov   bl,byte ptr ss:[mr@current_fore]
#@        cmp   bl,16
#@        jb    >L1
#@        or    ah,80h
#@        and   bl,0fh
#@L1:
#@        or    ah,bl

#@        xor   di,di
#@@3      mov   al,20h

#@#3      mov   bx,ax
#@#3      shl   eax,16
#@#3      or    ax,bx

#@        mov   cx,word ptr ss:[mr@screen_scroll]
#@@3      rep   stosw
#@#3      rep   stosd
#@        mov   cx,80
#@        rep   stosw
#@        mov   ah,02h
#@        mov   bh,byte ptr ss:[mr@current_page]
#@        xor   dx,dx
#@        int   10h

#@        pop   es,bp,di,dx,cx,bx,ax

        ret
