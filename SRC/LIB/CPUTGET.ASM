_cput:
%startup _tty_str_direct_setup
%startuppm _tty_str_direct_setup_pm
; Put character C at X,Y
        push    bp
        mov     bp,sp
        push    ax,bx,cx,dx,di,es

        mov     es,word ptr ss:[mr@screen_seg]

        mov     bl,byte ptr ss:[mr@current_back]
@1      shl     bl,1
@1      shl     bl,1
@1      shl     bl,1
@1      shl     bl,1
#1      shl     bl,4
        mov     cl,byte ptr ss:[mr@current_fore]
        cmp     cl,16
        jb      >L1
        or      bl,80h
        and     cl,0fh
L1:
        or      bl,cl
        mov     ah,bl

        mov     dh,[bp+6]  ; row
        mov     dl,[bp+8]  ; column
#D      call    _curscheck
        mov     al,[bp+4]  ; character

        xor     cl,cl     ; Clear CL
        mov     ch,dh     ; CX = Row * 256
        shr     cx,1      ; CX = Row * 128
        mov     di,cx     ; Store in si
@1      shr     di,1      ; si = Row * 64
@1      shr     di,1      ; si = Row * 32
#1      shr     di,2
        add     di,cx     ; si = (Row * 128)+(Row * 32)={Row*160}
        xor     ch,ch     ; Clear CH register
        mov     cl,dl     ; CX = Columns
        shl     cx,1      ; Account for attribute
        add     di,cx     ; si = (Row * 160) + (Col * 2)

        stosw

        pop     es,di,dx,cx,bx,ax
        pop     bp
        ret     6

_cget:
%startup _tty_str_direct_setup
%startuppm _tty_str_direct_setup_pm
; Get character C at X,Y
; returns:
;    AL = character
        push    bp
        mov     bp,sp
        push    cx,dx,si,ds

        mov     ds,word ptr ss:[mr@screen_seg]
        mov     dh,[bp+4]  ; row
        mov     dl,[bp+6]  ; column
#D      call    _curscheck

        xor     cl,cl     ; Clear CL
        mov     ch,dh     ; CX = Row * 256
        shr     cx,1      ; CX = Row * 128
        mov     si,cx     ; Store in si
@1      shr     si,1      ; si = Row * 64
@1      shr     si,1      ; si = Row * 32
#1      shr     si,2
        add     si,cx     ; si = (Row * 128)+(Row * 32)={Row*160}
        xor     ch,ch     ; Clear CH register
        mov     cl,dl     ; CX = Columns
        shl     cx,1      ; Account for attribute
        add     si,cx     ; si = (Row * 160) + (Col * 2)
        lodsw
        pop     ds,si,dx,cx
        pop     bp
        ret     4

_curscheck:
; checks cursor bounds
; DH = row (Y)
; DL = column (X)
        cmp     dl,80
        jae     >L1
        cmp     dh,byte ptr ss:[mr@screen_length]
        ja      >L1
        ret
L1:
        mov     ax,6  ; invalid function call
$errhandler
