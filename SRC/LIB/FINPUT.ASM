_finput:
;    BX = handle
; returns:
;    DI -> string from file
%allocate mr@fbuf 30
%allocate mr@fpos 30
%allocate mr@finputeof 30

        push    ax,bx,cx,dx,si,bp
#Z        push    es
#Z        push    ds
#Z        pop     es                  ; ES=DS for this function
        mov     bp,bx               ; save handle
        mov     di,bx
        shl     di,1
        mov     si,word ptr ds:[mr@fbuf+di]  ; get buffer pointer
        or      si,si               ; allocated?
        jz      >L9                 ; nup
L1:
        cmp     word ptr ds:[mr@finputeof+di],-1
        jnz     >L2
;finputeof:
        xor     di,di
        jmp     L4

;        jmp     finputeof
L2:
        add     si,word ptr  ds:[mr@fpos+di]
        mov     cx,1024
        sub     cx,word ptr ds:[mr@fpos+di]  ; get remaining free space
        jcxz    >L5
;        mov     dx,di               ; temp save of [mr@fpos+di]
        mov     di,si               ; save pointer
        mov     bx,cx               ; save free space
        mov     al,13
        repnz   scasb
        jnz     >L5                 ; need to load more from the file

        sub     bx,cx               ; bx contains size of string
        mov     cx,bx
        add     bx,2
        call    _mem_alloc
;        push    dx                  ; save [mr@fpos+di]
        push    di
#S        add     di,2
@S        inc     di
@S        inc     di
        xor     dx,dx               ; string size counter
        push    cx                  ; fbuf addition later
L2:
        jcxz    >L3
        lodsb
        cmp     al,9
        jz      >L0
        cmp     al,32
        jb      L8
L0:
        inc     dx
        stosb
        loop    L2
L3:
        pop     cx
        pop     di
        mov     [di],dx
        mov     bx,bp
        shl     bx,1

;        pop     bx                  ; [mr@fpos+bx]
        add     word ptr ds:[mr@fpos+bx],cx
L4:
#Z        pop     es
        pop     bp,si,dx,cx,bx,ax
        ret

L8:
; eeek
        loop    L2
        jmp     short L3

L9:
        push    di                  ; allocate buffer memory
        mov     bx,1024
        call    _mem_alloc
        mov     si,di
        pop     di
        mov     word ptr ds:[mr@fpos+di],1024
        mov     word ptr ds:[mr@fbuf+di],si
;        jmp     short L5

L5:
        mov     bx,bp
        shl     bx,1
        cmp     word ptr ds:[mr@finputeof+bx],-1
        jz      >L0
        push    di                  ; pop di
        mov     di,word ptr ds:[mr@fbuf+bx]
        push    di                  ; pop si
        mov     si,di
        add     si,word ptr ds:[mr@fpos+bx]
        mov     cx,1024
        sub     cx,word ptr ds:[mr@fpos+bx]

        mov     dx,word ptr ds:[mr@fbuf+bx]
        add     dx,cx

@S      rep     movsb

#S#3      mov    ax,cx
#S#3      and    ax,3
#S#3      shr    cx,2
#S#3      rep    movsd
#S#3      add    cx,ax
#S#3      rep    movsb

#S@3      shr    cx,1
#S@3      rep    movsw
#S@3      adc    cx,cx
#S@3      rep    movsb

        mov     ah,3fh
        mov     cx,word ptr ds:[mr@fpos+bx]
        mov     si,cx               ; temp save
        mov     word ptr ds:[mr@fpos+bx],0
        mov     bx,bp
        int     21h
        or      ax,ax               ; EOF?
        jz      >L7
        cmp     ax,si               ; compare bytes req to byte read
        jb      >L2
L6:
        pop     si,di
        mov     di,bp
        shl     di,1

        jmp     L1

L7:
        mov     si,bp
        shl     si,1
        mov     word ptr ds:[mr@finputeof+si],-1
        mov     bx,word ptr ds:[mr@fbuf+si]
        call    _mem_free
        mov     word ptr ds:[mr@fbuf+si],0
        jmp     short L6

L2:
;        mov     bx,bp
;        shl     bx,1
;        mov     di,ds:[mr@fbuf+bx]
        mov     di,dx
        add     di,ax      ; AX = bytes read from disk

        mov     cx,si
        sub     cx,ax
        xor     al,al

@S      rep     stosb

#S      shr    cx,1
#S      rep    stosw
#S      adc    cx,cx
#S      rep    stosb

        jmp     short L6


L0:
        mov     ax,8   ; EOF
$errhandler
;#Ddbg_finput:
;#D       db '_finput',0
