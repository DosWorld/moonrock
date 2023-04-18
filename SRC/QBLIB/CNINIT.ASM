; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	..\rt\cninit.asm
        .386p
        .387
CODE	SEGMENT	WORD PUBLIC USE16 'CODE'
CODE	ENDS
INIT_CODE	SEGMENT	WORD PUBLIC USE16 'CODE'
INIT_CODE	ENDS
_BSS	SEGMENT	WORD PUBLIC USE16 'DATA'
_BSS	ENDS
_DATA	SEGMENT	WORD PUBLIC USE16 'DATA'
_DATA	ENDS
XIB	SEGMENT	WORD PUBLIC USE16 'DATA'
XIB	ENDS
XI	SEGMENT	WORD PUBLIC USE16 'DATA'
XI	ENDS
XIE	SEGMENT	WORD PUBLIC USE16 'DATA'
XIE	ENDS
DGROUP	GROUP	_BSS, _DATA, XIB, XI, XIE
; [0153]	; Linker - Pass two marker

	EXTRN		b$shlt_disp:WORD
	EXTRN		b$term_disp:WORD
	EXTRN		b$shli_disp:WORD
	EXTRN		b$run_disp:WORD
	EXTRN		b$ini_disp:WORD
	EXTRN		b$Chaining:BYTE
	EXTRN		B$NearRet:ABS
	EXTRN		b$errnum:WORD
	EXTRN		b$IOFLAG:BYTE
        PUBLIC          B$CNINI
        PUBLIC          B$Pause

CODE	SEGMENT
	assume	cs: CODE

	EXTRN		B$RESETSCN:NEAR
	EXTRN		B$PUTNUM:NEAR
	EXTRN		B$PUTCR:NEAR
	EXTRN		B$GWTERM:NEAR
B$CNINI:
	mov	bx,0001h
	mov	cl,02h
$L3:	mov	ax,4400h
	int	21h
	test	dl,80h
	jz	$L1
	test	dl,03h
	jnz	$L2
$L1:	assume	ds: DGROUP
	or	b$IOFLAG,cl
$L2:	mov	cl,01h
	dec	bx
	jz	$L3
	call	$S4
	ret
$S14:	ret
$S4:	xor	al,al
	mov	ah,33h
	int	21h
	mov	$S5,dl
	xor	dl,dl
	mov	al,01h
	mov	ah,33h
	int	21h
	ret
$S9:	mov	dl,$S5
	mov	al,01h
	mov	ah,33h
	int	21h
	ret
$S13:	cmp	word ptr b$errnum,+000h
	jz	$L6
	call	far ptr CODE:B$Pause
$L6:	cmp	byte ptr b$Chaining,00h
	jnz	$L7
	test	byte ptr b$IOFLAG,40h
	jz	$L8
	call	B$RESETSCN
$L8:	call	B$GWTERM
$L7:	call	$S9
	ret
B$Pause:
;        test    byte ptr b$IOFLAG,03h
;        jnz     $L10
;        call    B$PUTCR
;        mov     ax,8007h
;        call    B$PUTNUM
;        mov     cx,00C8h
;$L12:   mov     ax,03E8h
;$L11:   dec     ax
;        jnz     $L11
;        loop    $L12
;        mov     ax,0C07h
;        int     21h
;        call    B$PUTCR

$L10:   retf

CODE	ENDS
INIT_CODE	SEGMENT
	assume	cs: INIT_CODE


$S15:	assume	ds: DGROUP
	mov	word ptr b$ini_disp + 00008h,offset CODE:B$CNINI
	mov	word ptr b$term_disp + 00004h,offset CODE:$S13
	mov	word ptr b$run_disp + 00008h,offset CODE:$S14
	mov	word ptr b$shli_disp + 00004h,offset CODE:$S4
	mov	word ptr b$shlt_disp + 00006h,offset CODE:$S9
	retf

INIT_CODE	ENDS
_BSS	SEGMENT

$S5	db	000h

_BSS	ENDS
XI	SEGMENT

	dd	INIT_CODE:$S15

XI	ENDS
	END
