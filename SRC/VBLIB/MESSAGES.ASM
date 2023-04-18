; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	..\rt\messages.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
FAR_HDR	SEGMENT	BYTE PUBLIC USE16 'FAR_MSG'
FAR_HDR	ENDS
FAR_MSG	SEGMENT	BYTE PUBLIC USE16 'FAR_MSG'
FAR_MSG	ENDS
FAR_PAD	SEGMENT	BYTE COMMON USE16 'FAR_MSG'
FAR_PAD	ENDS
FAR_EPAD	SEGMENT	BYTE COMMON USE16 'FAR_MSG'
FAR_EPAD	ENDS
FMGROUP	GROUP	FAR_HDR, FAR_MSG, FAR_PAD, FAR_EPAD
; [00AB]	; Linker - Pass two marker


	PUBLIC		__acrtmsg		; Located at 0:9876h Type = 0
	PUBLIC		b$messages		; Located at 2:0000h Type = 0

__acrtmsg	=	09876h

FAR_MSG	SEGMENT

b$messages	db	002h
	db	010h
        db      000h
	db	003h
	db	010h
        db      000h
	db	004h
	db	010h
        db      000h
	db	005h
	db	010h
        db      000h
	db	006h
	db	010h
        db      000h
	db	007h
	db	010h
	db	'Out of memory',000h
	db	009h
	db	010h
        db      000h
	db	00Ah
	db	010h
        db      000h
	db	00Bh
	db	010h
	db	'Division by zero',000h
	db	00Dh
	db	010h
        db      000h
	db	00Eh
	db	010h
	db	'Out of string space',000h
	db	010h
	db	010h
        db      000h
	db	013h
	db	010h
        db      000h
	db	014h
	db	010h
        db      000h
	db	'3'
	db	010h
	db	'Internal error',000h
	db	'D'
	db	010h
        db      000h
	db	'F'
	db	010h
        db      000h
	db	'I'
	db	010h
        db      000h
	db	'P'
	db	010h
        db      000h
	db	0AFh
	db	011h
        db      000h
	db	0FFh
	db	010h
        db      000h
	db	000h
	db	080h
        db      000h
	db	001h
	db	080h
        db      000h
	db	006h
	db	080h
        db      'Returning to system.',000h
	db	008h
	db	080h
	db	' in ',000h
	db	009h
	db	080h
	db	' of ',000h
	db	00Ah
	db	080h
;        db      'line ',000h
        db      000h
	db	00Bh
	db	080h
	db	'module ',000h
	db	00Ch
	db	080h
	db	' at address ',000h
	db	00Dh
	db	080h
	db	'*Break*',000h
	db	001h
	db	088h
        db      000h
	db	000h
	db	090h
        db      000h
	db	006h
	db	090h
        db      000h
	db	007h
	db	090h
	db	'Out of stack space',000h
	db	000h
	db	094h
;        db      'No line number in ',000h
        db      000h
	db	001h
	db	098h
	db	'Error during run-time initialization',000h
	db	002h
	db	098h
	db	'Out of memory',000h
	db	003h
	db	098h
        db      000h
	db	004h
	db	098h
        db      000h
	db	00Ah
	db	098h
        db      000h
	db	000h
	db	09Ah
        db      000h
	db	002h
	db	09Ah
	db	000h
	db	003h
	db	09Ah
        db      000h
	db	004h
	db	09Ah
        db      000h
	db	008h
	db	09Ah
        db      000h
	db	009h
	db	09Ah
        db      000h

	db	00Ch
	db	09Ah
	db	000h
	db	00Dh
	db	09Ah
	db	000h
	db	00Eh
	db	09Ah
	db	000h
	db	00Fh
	db	09Ah
        db      000h
	db	0FFh
	db	09Ah
        db      000h
	db	' '
	db	09Dh
        db      000h
	db	'!'
	db	09Dh
        db      000h
	db	'"'
	db	09Dh
	db	000h
	db	'#'
	db	09Dh
        db      000h
	db	'$'
	db	09Dh
        db      000h
	db	'%'
	db	09Dh
        db      000h
	db	'&'
	db	09Dh
        db      000h
	db	''''
	db	09Dh
	db	000h
	db	'('
	db	09Dh
        db      000h
	db	')'
	db	09Dh
        db      000h
	db	'*'
	db	09Dh
        db      000h

FAR_MSG	ENDS
	END
