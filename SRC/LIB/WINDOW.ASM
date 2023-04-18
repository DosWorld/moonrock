_drawwindow:
;www_1@BODYCOL     equ [bp+4]
;www_1@BORDERFCOL  equ [bp+6]
;www_1@BARBCOL     equ [bp+8]
;www_1@BARFCOL     equ [bp+10]
;www_1@LENGTH      equ [bp+12]
;www_1@WIDTH       equ [bp+14]
;www_1@TY  equ     [bp+16]
;www_1@TX  equ     [bp+18]
;-----www_1@L    --
;-----www_1@T1   --
;www_1@T2  equ [bp-2]
;www_1@T3  equ [bp-4]
;www_1@Y   equ [bp-6]
;www_1@T   equ [bp-8]
;wws_1@TITLE  equ     [bp-10]
%allocate mr@screenchar 4
        push    bp
        mov     bp,sp
        sub     sp,10
        mov     si,[bp+20]
        call    _str_copy
        mov     [bp-10],di
        mov     word ptr ds:[mr@screenchar],1
        call    _curp_get
        push    dx       ; save cursor

; 0028  mcursor tx%, ty%
        mov     dl,byte ptr [bp+18]
        mov     dh,byte ptr [bp+16]
        call    _curp_set

; 0029	colour barfcol%, barbcol%
        mov     al,byte ptr [bp+10]
        mov     byte ptr ss:[mr@current_fore], al
        mov     al,byte ptr [bp+8]
        mov     byte ptr ss:[mr@current_back], al

; 0030	l% = width% - len(title$) / 2
        mov     ax,[bp+14]
        mov     bx,[bp-10]
        mov     bx,ds:[bx]
        sub     ax,bx
        mov     bx,2
        cwd
        idiv    bx
;        sub     bx,dx
;        cmp     dx,bx
;        sbb     ax,-1
;        mov     [www_1@L],ax

; 0031	if l% > 0 then title$ = space(l%) + title$
        or      ax,ax
        jle     short >L1
        mov     cx,ax
        call    _str_space
        push    di
        mov     si,word ptr [bp-10]
        call    _str_conc
        pop     bx
        call    _mem_free
        mov     bx,[bp-10]
        call    _mem_free
        mov     [bp-10],di
L1:

; 0032	title$ = title$ + space(80)
        mov     cx,80
        call    _str_space
        push    di
        mov     si,di
        mov     di,word ptr [bp-10]
        call    _str_conc
        pop     bx
        call    _mem_free
        mov     bx,[bp-10]
        call    _mem_free
        mov     [bp-10],di

; 0033	print left(title$, width%)
        mov     si,[bp-10]
        mov     cx,[bp+14]
        call    _str_left
        push    di
$outstream
        pop     bx
        call    _mem_free

; 0035	t2% = ty% + length% - 1
        mov     ax,[bp+16]
        add     ax,[bp+12]
        dec     ax
        mov     [bp-2],ax

; 0036	t3% = width% - 2
        mov     ax,[bp+14]
#S        sub     ax,2
@S        dec     ax
@S        dec     ax
        mov     [bp-4],ax

; 0037  for y% = (ty% + 1) to (ty% + length% - 1)
        mov     ax,[bp+16]
        inc     ax
        mov     [bp-6],ax
L2:
; fornext1

; 0038	mcursor tx%, y%
        mov     dl,byte ptr [bp+18]
        mov     dh,byte ptr [bp-6]
        call    _curp_set

; 0039	colour borderfcol%, bodycol%
        mov     al,byte ptr [bp+6]
        mov     byte ptr ss:[mr@current_fore], al
        mov     al,byte ptr [bp+4]
        mov     byte ptr ss:[mr@current_back], al

; 0040	print "º" + space(t3%) + "º"
        mov     di,offset mr@screenchar
        mov     byte ptr ds:[di+2],'º'
$outstream
        mov     cx,[bp-4]
        call    _str_space
        push    di
$outstream
        pop     bx
        call    _mem_free
        mov     di,offset mr@screenchar
$outstream

; 0041	colour ?,0
        mov     byte ptr ss:[mr@current_back],0

; 0042	print " "
        mov     di,offset mr@screenchar
        mov     byte ptr ds:[di+2],32
$outstream

; 0043	next
        mov     ax,[bp-6]
        inc     ax
        cmp     ax,[bp-2]
        jg      >L1
        mov     [bp-6],ax
        jmp     short L2   ; fornext1
L1:

; 0044  t% = ty% + length%
        mov     ax,[bp+16]
        add     ax,[bp+12]
        mov     [bp-8],ax

; 0045  mcursor tx%, (ty% + length%)
        mov     dl,byte ptr [bp+18]
        mov     dh,byte ptr [bp-8]
        call    _curp_set

; 0046	colour borderfcol%, bodycol%
        mov     al,byte ptr [bp+6]
        mov     byte ptr ss:[mr@current_fore], al
        mov     al,byte ptr [bp+4]
        mov     byte ptr ss:[mr@current_back], al

; 0047	print "È" + repstr("Í", t3%) + "¼"
        mov     di,offset mr@screenchar
        mov     byte ptr ds:[di+2],'È'
$outstream
        mov     si,offset mr@screenchar
        mov     byte ptr ds:[si+2],'Í'
        mov     cx,[bp-4]
        call    _str_repstr
        push    di
$outstream
        pop     bx
        call    _mem_free
        mov     di,offset mr@screenchar
        mov     byte ptr ds:[di+2],'¼'
$outstream

; 0048	colour ?,0
        mov     byte ptr ss:[mr@current_back],0

; 0049	print " "
        mov     di,offset mr@screenchar
        mov     byte ptr ds:[di+2],32
$outstream

; 0052  mcursor (tx% + 1), (t% + 1)
        mov     dl,byte ptr [bp+18]
        inc     dl
        mov     dh,byte ptr [bp-8]
        inc     dh
        call    _curp_set

; 0053	print space(width%)
        mov     cx,[bp+14]
        call    _str_space
        push    di
$outstream
        pop     bx
        call    _mem_free

; 0056  end sub
        mov     bx,[bp-10]
        call    _mem_free
        pop     dx
        call    _curp_set   ; restore cursor
        mov     sp,bp
        pop     bp
        ret     18

