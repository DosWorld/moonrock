_drawbutton:
;w_2@BUTBCOL     equ [bp+4]
;w_2@BCOL        equ [bp+6]
;w_2@FCOL        equ [bp+8]
;w_2@WIDTH       equ [bp+10]
;w_2@TY  equ [bp+12]
;w_2@TX  equ [bp+14]
;s_2@TITLE       equ [bp-2]
; ----- w_2@L
; ----- w_2@T1
; ----- w_2@T2
%allocate mr@screenchar 4
        push    bp
        mov     bp,sp
        sub     sp,2
        mov     si,[bp+16]
        call    _str_copy
        mov     [bp-2],di
        mov     word ptr ds:[mr@screenchar],1
        call    _curp_get
        push    dx

; 0062	mcursor tx%, ty%
        mov     dl,byte ptr [bp+14]
        mov     dh,byte ptr [bp+12]
        call    _curp_set

; 0063	colour fcol%, bcol%
        mov     al,byte ptr [bp+8]
        mov     byte ptr ss:[mr@current_fore], al
        mov     al,byte ptr [bp+6]
        mov     byte ptr ss:[mr@current_back], al

; 0064	l% = width% - len(title$) / 2
        mov     ax,[bp+10]
        mov     bx,[bp-2]
        mov     bx,ds:[bx]
        sub     ax,bx
        mov     bx,2
        cwd
        idiv    bx

; 0065	if l% > 0 then title$ = space(l%) + title$
        or      ax,ax
        jle     >L1
        mov     cx,ax
        call    _str_space

        push    di
        mov     si,word ptr [bp-2]
        call    _str_conc
        pop     bx
        call    _mem_free
        mov     bx,[bp-2]
        call    _mem_free
        mov     [bp-2],di
L1:

; 0066	title$ = title$ + space(80)
        mov     cx,80
        call    _str_space
        push    di
        mov     si,di
        mov     di,word ptr [bp-2]
        call    _str_conc
        pop     bx
        call    _mem_free
        mov     bx,[bp-2]
        call    _mem_free
        mov     [bp-2],di
        call    _str_release

; 0067	print left(title$, width%)
        mov     si,[bp-2]
        mov     cx,[bp+10]
        call    _str_left
        push    di
$outstream
        pop     bx
        call    _mem_free

; 0068	colour 0, butbcol%
        mov     byte ptr ss:[mr@current_fore],0
        mov     al,byte ptr [bp+4]
        mov     byte ptr ss:[mr@current_back], al

; 0069	print "Ü"
        mov     di,offset mr@screenchar
        mov     byte ptr ds:[di+2],'Ü'
$outstream

; 0072  mcursor (tx% + 1), (ty% + 1)
        mov     dl,byte ptr [bp+14]
        mov     dh,byte ptr [bp+12]
        add     dx,0101h
        call    _curp_set

; 0073	print repstr("ß", width%)
        mov     si,offset mr@screenchar
        mov     byte ptr ds:[si+2],'ß'
        mov     cx,[bp+10]
        call    _str_repstr
        push    di
$outstream
        pop     bx
        call    _mem_free

; 0075	end sub
        mov     bx,word ptr [bp-2]
        call    _mem_free
        pop     dx
        call    _curp_set
        mov     sp,bp
        pop     bp
        ret     14
