_str_instr:
; ------------------------------------------------------------
;p_STR1  equ [bp-2]
;p_STR2  equ [bp-4]
;w_RES   equ [bp-6]
;w_1@L1  equ [bp-8]
;w_1@L2  equ [bp-10]
;w_1@POSI        equ [bp-12]
;w_1@MATCHED     equ [bp-14]
;w_1@I   equ [bp-16]
; SI = p1~
; DI = p2~
; DL = firstchar@
; CX = matched%
; ------------------------------------------------------------
        push    bp
        mov     bp,sp
        sub     sp,16
        push    bx,cx,dx,si,di

;    DS:SI -> str2           NOTE ORDER
;    DS:DI -> str1           OF STRINGS!
        mov     [bp-2],di
        mov     [bp-4],si

        cmp     word ptr [di],0   ; empty str1? return 0
        jnz     >L0
        mov     word ptr [bp-6],0
        jmp     L7
L0:
        cmp     word ptr [si],0   ; empty str2? return 1
        jnz     >L0
        mov     word ptr [bp-6],1
        jmp     L7
L0:

; 0026  l1% = [str1~]
        mov     bx,[bp-2]
        mov     ax,ds:[bx]
        mov     [bp-8],ax

; 0027	l2% = [str2~]
        mov     bx,[bp-4]
        mov     ax,ds:[bx]
        mov     [bp-10],ax

; 0028	posi% = 0
        mov     word ptr [bp-12],0

; 0029	p2~ = str2~ + 2
        mov     di,[bp-4]
@S        inc     di
@S        inc     di
#S        add     di,2

; 0030	firstchar@ = [p2~]
; dl = firstchar
        mov     dl,byte ptr ds:[di]

; 0032  for posi% = 0 to l1%
        mov     word ptr [bp-12],0
L1:

; 0034	p1~ = str1~ + posi% + 2
        mov     si,[bp-2]
        add     si,[bp-12]
        lodsw         ;  add     si,2

; 0035	matched% = FALSE
        xor     cx,cx
;        mov     word ptr [bp-14],0

; 0036	for i% = posi% to l1%
        mov     ax,[bp-12]
        mov     [bp-16],ax
L2:

; 0037	if [p1~] = firstchar@ then
; dl = firstchar
        cmp     dl,byte ptr ds:[si]
        jnz     short >L0

; 0038	matched% = TRUE
        mov     cx,-1
;        mov     word ptr [bp-14],-1

;        posi% = i%
        mov     ax,word ptr [bp-16]
        mov     word ptr [bp-12],ax

; 0039	exit for
        jmp     >L9
;        fornext2end

; 0040	endif
L0:

; 0041	p1~ = p1~ + 1
        inc     si

; 0042	next
        mov     ax,[bp-16]
        inc     ax
        cmp     ax,[bp-8]
        jg      >L9
        mov     [bp-16],ax
        jmp     short L2
L9:

; 0043	if matched% = FALSE then res% = 0 : exit sub
        test    cx,cx
        jnz     short >L0
;        cmp     word ptr [bp-14],0
;        jnz     short >L0
        mov     word ptr [bp-6],0
        jmp     >L7
L0:

; 0045	res% = i% + 1
        mov     ax,[bp-16]
        inc     ax
        mov     [bp-6],ax

; 0047	p2~ = str2~ + 2
        mov     di,[bp-4]
@S        inc     di
@S        inc     di
#S        add     di,2

; 0048	matched% = TRUE
        mov     cx,-1
;        mov     word ptr [bp-14],-1

; 0049  for i% = 1 to l2%
        mov     word ptr [bp-16],1
L3:

; 0050	if [p1~] <> [p2~] then
        mov     al,byte ptr ds:[si]
        cmp     al,byte ptr ds:[di]
        jz     short >L0

; 0051	matched% = FALSE
        xor     cx,cx
;        mov     word ptr [bp-14],0

; 0052	exit for
        jmp     >L8
;        fornext3end

; 0053	endif
L0:

; 0054	p1~ = p1~ + 1
        inc     si

; 0055	p2~ = p2~ + 1
        inc     di

; 0056	next
        mov     ax,[bp-16]
        inc     ax
        cmp     ax,[bp-10]
        jg      >L8
        mov     [bp-16],ax
        jmp     L3
L8:

; 0057	if matched% = TRUE then exit sub
        cmp     cx,-1
;        cmp     word ptr [bp-14],-1
        jz      short >L7

; 0059	next
        mov     ax,[bp-12]
        inc     ax
        cmp     ax,[bp-8]
        jg      >L0
        mov     [bp-12],ax
        jmp     L1
L0:

; 0060	res% = 0
        mov     word ptr [bp-6],0

; 0061	end sub
L7:
        mov     ax,[bp-6]
        pop     di,si,dx,cx,bx
        mov     sp,bp
        pop     bp
        ret

