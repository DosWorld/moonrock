; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	..\rt\cninit.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
RTCODE	SEGMENT	PARA PUBLIC USE16 'CODE'
RTCODE	ENDS
_BSS	SEGMENT	WORD PUBLIC USE16 'DATA'
_BSS	ENDS
_DATA	SEGMENT	WORD PUBLIC USE16 'DATA'
_DATA	ENDS
DGROUP	GROUP	_BSS, _DATA
; [00BE]	; Unknown COMENT Record (Class 168): '[08][01]'
; [010C]	; Linker - Pass two marker

	EXTRN		B$RESETSCN:NEAR
	EXTRN		b$IOFLAG:BYTE
	EXTRN		b$Chaining:BYTE
	EXTRN		b$errnum:WORD
	EXTRN		B$RTLLTERM:NEAR
	EXTRN		B$PUTCR:NEAR
	EXTRN		B$PUTNUM:NEAR
	EXTRN		B$NearRet:ABS
	PUBLIC		B$CNINI			; Located at 1:0000h Type = 1
	PUBLIC		B$CNKBDSET		; Located at 1:0021h Type = 1
	PUBLIC		B$CNKBDRESET		; Located at 1:0034h Type = 1
	PUBLIC		B$CNTERM		; Located at 1:003Fh Type = 1
	PUBLIC		B$Pause			; Located at 1:0063h Type = 1

RTCODE	SEGMENT
	assume	cs: RTCODE


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
	call	near ptr B$CNKBDSET
	ret
B$CNKBDSET:
	xor	al,al
	mov	ah,33h
	int	21h
	mov	$S4,dl
	xor	dl,dl
	mov	al,01h
	mov	ah,33h
	int	21h
	ret
B$CNKBDRESET:
	mov	dl,$S4
	mov	al,01h
	mov	ah,33h
	int	21h
	ret
B$CNTERM:
	cmp	word ptr b$errnum,+000h
	jz	$L5
	call	far ptr RTCODE:B$Pause
$L5:	cmp	byte ptr b$Chaining,00h
	jnz	$L6
	test	byte ptr b$IOFLAG,40h
	jz	$L7
	call	B$RESETSCN
$L7:	call	B$RTLLTERM
$L6:	call	near ptr B$CNKBDRESET
	ret
B$Pause:
;        test    byte ptr b$IOFLAG,03h
;        jnz     $L8
;        call    B$PUTCR
;        mov     ax,8006h
;        call    B$PUTNUM
;        mov     cx,00C8h
;$L10:   mov     ax,03E8h
;$L9:    dec     ax
;        jnz     $L9
;        loop    $L10
;        mov     ax,0C07h
;        int     21h
;        mov     ax,0C00h
;        int     21h
;        call    B$PUTCR
$L8:	retf

RTCODE	ENDS
_BSS	SEGMENT

$S4	db	000h

_BSS	ENDS
	END
