_file_exist:
;    CX     = file attribute
;    DS:SI -> filespec
; returns:
;    AX     = -1  file exists
;    AX     = 0   file does not exist
%bundle ffblk
        push  di
        call  _find_first
        or    di,di          ; was a null string returned ?
        jz    >L2
L1:
        call  _find_next     ; clear the rest (for Novell NCP tables)
        or    di,di
        jnz   L1
        mov   ax,-1
        pop   di
        ret
L2:
        xor   ax,ax
        pop   di
        ret

_find_first:
; DOS 'FINDFIRST' interrupt call
;    CX    =  file attribute
;    DS:SI -> filespec
; returns:
;    FFBLK filled
;    DS:DI -> filename (null for no matching filespec)
%allocate mr@DTA 64
%bundle ffblk
        push  ax,bx,cx,dx,si
#Z        push  es
#Z        push  ds
#Z        pop   es
        xor   al,al
        clc
        call  _str_2_asciiz
        push  di

        mov   ah,1ah
        mov   dx,offset mr@DTA
        int   21h                      ; set DTA to ds:di

        mov   ah,4eh
        pop   dx                       ; DS:DS -> filename
        push  dx
        int   21h                      ; FINDFIRST
        jc    >L1
        pop   bx
        call  _mem_free

        mov   dx,offset mr@DTA + 1Eh
        call  _asciiz_2_str            ; convert DS:DX to DS:DI mr string

; Bundle FFBLK: Attr@, Time%, Date%, Size&, Name$[13] null
;               0      1      3      5      9
;        mov   al,byte ptr ds:[mr@DTA + 15h]
;        xor   ah,ah
;        mov   ds:[w_FFBLK_ATTR],ax
;        mov   ds:[s_FFBLK_NAME],di
        push  di
        mov   si,offset mr@DTA + 15h
        mov   di,offset b_FFBLK_ATTR
#S        mov   cx,4
#S        rep   movsw
#S        movsb
@S        mov   cx,9
@S        rep   movsb

        pop   di
        jmp   short >L2
L1:
        pop   bx
        call  _mem_free
        xor   di,di
        mov   ds:[s_FFBLK_NAME],di
L2:
#Z        pop   es
        pop   si,dx,cx,bx,ax
        ret

_find_next:
; DOS 'FINDNEXT' interrupt call
; returns:
;    DS:DI -> filename (null for no more matching files)
%allocate mr@DTA 64
%bundle ffblk

        push  ax,bx,cx,dx,si
#Z        push  es
#Z        push  ds
#Z        pop   es
        mov   ah,4fh
        int   21h                      ; FINDNEXT
        jc    >L1
        mov   dx,offset mr@DTA + 1Eh
        call  _asciiz_2_str            ; convert DS:DX to DS:DI mr string
; Bundle FFBLK: Attr@, Time%, Date%, Size&, Name$[13] null
;               0      1      3      5      9
;        mov   al,byte ptr ds:[mr@DTA + 15h]
;        xor   ah,ah
;        mov   ds:[w_FFBLK_ATTR],ax
;        mov   ds:[s_FFBLK_NAME],di
        push  di
        mov   si,offset mr@DTA + 15h
        mov   di,offset b_FFBLK_ATTR

#S        mov   cx,4
#S        rep   movsw
#S        movsb
@S        mov   cx,9
@S        rep   movsb

        pop   di
        jmp   short >L2
L1:
        xor   di,di
        mov   ds:[s_FFBLK_NAME],di
L2:
#Z        pop   es
        pop   si,dx,cx,bx,ax
        ret

