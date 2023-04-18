
_freadfar:
; Read a block from an open file into FAR memory
; freadfar(handle%, seg%, offset%, bytes%)
;          bp+10    bp+8  bp+6     bp+4
        push    bp
        mov     bp,sp
#C      mov     word ptr cs:[mr@critical_err],0
#R      mov     word ptr ss:[_errcode],0
        push    ax,dx
        mov     bx,[bp+10]  ; handle
        mov     cx,[bp+4]   ; bytes
        mov     dx,[bp+6]   ; offset
        push    ds
        mov     ds,[bp+8]   ; seg
        mov     ah,3fh
        int     21h
        pop     ds
        jc      >L1
L0:
        or      ax,ax
        jz      >L2
        pop     dx,ax
        pop     bp
        ret     8
L1:
#R      mov     word ptr ss:[_errcode],ax
#R      jmp     short L0
@R      jmp     _err_dos      ; no return
L2:
        mov     ax,8         ; end of file
$errhandler
@R%include _err_dos

;#Ddbg_freadfar:
;#D      db    '_freadfar',0

_file_eof:
; Checks if fpos = flen
;   BX = handle
; returns:
;   AX = 0    OK
;   AX = -1   at end of file
%allocate mr@fbuf 30
%allocate mr@fpos 30
        push  bx,cx,dx,bp,si
        mov   si,bx
        add   si,si
        mov   bp,bx

        xor   cx,cx
        xor   dx,dx
        mov   ax,4201h       ; current file position
        int   21h

;        call  _file_pos     ; DX:AX = position
        mov   bx,dx
        xchg  bx,bp
        mov   cx,ax
        call  _file_length  ; DX:AX = length
        sub   ax,cx
        sbb   dx,bp
        js    >L2
        or    ax,ax
        jz    >L2
L0:
        xor   ax,ax
L1:
        pop   si,bp,dx,cx,bx
        ret
L2:
        cmp   word ptr ds:[mr@fbuf+si],0   ; text buffer exists?
        jz    >L3                          ; no, EOF!
        mov   bx,word ptr ds:[mr@fbuf+si]
        cmp   word ptr [bx],0              ; text buffer empty? EOF!
        jnz   L0
L3:
        mov   ax,-1
        jmp   short L1

_file_truename:
; Returns a file's full drive&path
;   DS:SI -> input
; returns:
;   DS:DI -> output
        push  ax,bx,cx

#Z      push  es
#Z        push  ds
#Z        pop   es

;        clc
;        xor   al,al
;        call  _str_2_asciiz
;        push  di
;        mov   si,di

        mov   bx,128
        call  _mem_alloc
        push  di

        lodsw
        xchg    cx,ax
;        mov   cx,[si]
;        add   si,2

        rep   movsb
        mov   byte ptr [di],0   ; ES=DS
        pop   di
        push  di
        mov   si,di

        mov   ah,60h
        int   21h
        jc    >L2
        pop   di
        mov   bx,di
        mov   dx,di
        call  _asciiz_2_str
        call  _mem_free
;        pop   bx
;        call  _mem_free

L1:
#Z        pop   es
        pop   cx,bx,ax
        ret
L2:
        pop   bx
        call  _mem_free
;        pop   bx
;        call  _mem_free
        xor   di,di
        jmp   short L1

_fread_str:
;    DS:SI -> dest string
        mov   cx,[si]
        add   si,2
        jmp   _fread
%include _fread

_asciiz_2_str:
; Converts an ASCIIZ string to standard
;    DS:DX -> pointer to ASCIIZ string
; returns
;    DS:DI -> mr string
        push  ax,bx,cx,dx,si
#Z        push    es
#Z        push    ds
#Z        pop     es           ; ES=DS for this func
        mov   si,dx
        xor   cx,cx
L1:
        lodsb
        or    al,al
        jz    >L2
        inc   cx
        jmp   short L1
L2:
        mov   bx,cx
        add   bx,2
        call  _mem_alloc
        push  di
        mov     ax,cx
        stosw
;        mov   [di],cx
;        add   di,2
        mov   si,dx

        rep     movsb
;L3:
;        lodsb

;        mov   [di],al
;        inc   di
;        loop  L3

L4:
        pop   di
#Z        pop   es
        pop   si,dx,cx,bx,ax
        ret

_str_2_asciiz:
; Converts a standard string to ASCIIZ, ASCIICR etc
;    AL = terminator
;    DS:SI -> pointer to mr string
;    CF set:   include leading space
;    CF clear: do not include leading space
; returns:
;    DS:DI -> ASCIIZ string

        push  bx,cx,dx,si,bp
#Z      push  es
#Z        push  ds
#Z        pop   es            ; ES=DS
        jc    >L1
        xor   dx,dx
        jmp   short >L2
L1:
        mov   dx,1
L2:
        mov   bp,ax
        mov   bx,[si]
        mov   cx,bx
        add   bx,2          ; 1 for leading space, 1 for NUL terminator
        call  _mem_alloc
        push  di

        lodsw    ; add si,2
        or    dx,dx
        jz    >L3
        mov   byte ptr [di],' '
        inc   di
L3:
        jcxz  >L5

        rep     movsb
;L4:
;        lodsb
;        mov   [di],al
;        inc   di
;        loop  L4
L5:
        mov   ax,bp
        stosb
;        mov   byte ptr [di],al
        pop   di
#Z        pop   es
        pop   bp,si,dx,cx,bx
        ret

_file_create:
; Creates a file
;    DS:SI -> pointer to filename
;    CX     = file attributes
; returns:
;    AX = file handle
%allocate mr@filename 30
;%allocate mr@filepos 30
%allocate mr@fbuf 30
%allocate mr@fpos 30
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],offset dbg_file_create
#C      mov   word ptr cs:[mr@critical_err],0
#R      mov   word ptr ss:[_errcode],0
        push  bx,cx,dx,di
        clc
        mov   al,0
        call  _str_2_asciiz
        push  di             ; save pointer in case DOS clobbers it
        mov   dx,di
        mov   ah,3ch
        int   21h
        jc    >L2
        call  _str_copy
        mov   bx,ax
        shl   bx,1
        mov   word ptr ds:[mr@filename+bx],di       ; store filename
;        mov   word ptr ds:[mr@filepos+bx],-1
L1:
        pop   bx
        call  _mem_free
        pop   di,dx,cx,bx
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],-1
        ret
L2:
#R      add   ax,100
#R      mov   word ptr ss:[_errcode],ax
#R      mov   ax,-1
#R      jmp   short L1
@R      jmp   _err_dos
;#Ddbg_file_create:
;#D      db    '_file_create',0
@R%include _err_dos

_file_open:
; Opens an existing file
;    DS:SI -> pointer to filename
;    CX = access & sharing
%allocate mr@filename 30
;%allocate mr@filepos 30
%allocate mr@fbuf 30
%allocate mr@fpos 30
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],offset dbg_file_open
#C      mov   word ptr cs:[mr@critical_err],0
#R      mov   word ptr ss:[_errcode],0
        push  bx,cx,dx,di,bp
        mov   bp,cx
        clc
        mov   al,0
        call  _str_2_asciiz
        push  di
L1:
;fileO_cont:
        mov   dx,di
        mov   ax,bp        ; mov al,bp(l)
        and   al,7fh       ; strip top bit
        mov   ah,3dh
        xor   cx,cx
        int   21h
        jc    >L3
        call  _str_copy
        mov   bx,ax
        shl   bx,1
        mov   word ptr ds:[mr@filename+bx],di       ; store filename
;        mov   word ptr ds:[mr@filepos+bx],-1
        push  word ptr ds:[mr@fbuf+bx]
        mov   word ptr ds:[mr@fbuf+bx],0  ; null buffer
        pop   bx
        call  _mem_free
        pop   bx
        call  _mem_free
;        test  bp,10000000b             ; is top bit set, text buf req?
;        jnz   >L2
;        mov   bx,1024
;        call  _far_mem_alloc
;        mov   cx,bx
;        mov   bx,ax
;        shl   bx,1
;        mov   word ptr ds:[mr@fbuf+bx],cx       ; store buffer segment
L2:
        pop   bp,di,dx,cx,bx
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],-1
        ret

L3:
        cmp   ax,2
        jnz   >L4
        test  bp,00000011b    ; are we open for write?
        jz    >L4              ; no, cause error
        mov   cx,20h          ; archive attribute
        push  si
        call  _file_create
        pop   si
        mov   bx,ax
        mov   ah,3eh
        int   21h              ; close file
        jmp   L1
;        fileO_cont
L4:
#R      pop   bx
#R      call  _mem_free
#R      mov   word ptr ss:[_errcode],ax
#R      jmp   short L2
@R      jmp   _err_dos    ; no return
;#Ddbg_file_open:
;#D      db    '_file_open',0
@R%include _err_dos

_file_close:
; Closes a previously opened file
;    BX = file handle
%allocate mr@filename 30
;%allocate mr@filepos 30
%allocate mr@fbuf 30
%allocate mr@fpos 30
%allocate mr@finputeof 30
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],offset dbg_file_close
#C      mov   word ptr cs:[mr@critical_err],0
#R      mov   word ptr ss:[_errcode],0
        or    bx,bx
        jz    >L2
        push  ax,si
        mov   ah,3eh
        int   21h
        jc    >L1
        add   bx,bx
        mov   si,bx
        mov   bx,word ptr ds:[mr@filename+si]
        call  _mem_free     ; free filename memory
        mov   bx,word ptr ds:[mr@fbuf+si]    ; free buffer
        call  _mem_free
        xor   ax,ax
        mov   word ptr ds:[mr@filename+si],ax     ; reset name pointer to 0
        mov   word ptr ds:[mr@fpos+si],ax
        mov   word ptr ds:[mr@finputeof+si],ax
        mov   word ptr ds:[mr@fbuf+si],ax

L0:
        pop   si,ax
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],-1
        ret
L1:
#R      mov   word ptr ss:[_errcode],ax
#R      jmp   short L0
@R      jmp   _err_dos
L2:
        mov   ax,4       ; invalid handle
$errhandler
;#Ddbg_file_close:
;#D      db    '_file_close',0
@R%include _err_dos

_file_write:
; Writes a block to an open file
;   DS:SI -> block to write
;   BX    =  file handle
;   CX    =  number of bytes to write
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],offset dbg_file_write
#C      mov   word ptr cs:[mr@critical_err],0
#R      mov   word ptr ss:[_errcode],0
        push  ax,dx
        mov   dx,si
        mov   ah,40h
        int   21h
        jc    >L1
L0:
        pop   dx,ax
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],-1
        ret
L1:
#R      mov   word ptr ss:[_errcode],ax
#R      jmp   short L0
@R      jmp   _err_dos      ; no return
@R%include _err_dos

;#Ddbg_file_write:
;#D      db    '_file_write',0

_file_seek:
%allocate mr@fbuf 30
%allocate mr@fpos 30
%allocate mr@finputeof 30
; Seek to specified file position
;    BX    = file handle
;    DX:AX = position to seek to
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],offset dbg_file_seek
#C      mov   word ptr cs:[mr@critical_err],0
#R      mov   word ptr ss:[_errcode],0
        push  cx,si
        mov   cx,dx
        mov   dx,ax
        mov   ax,4200h    ; seek from start of file
        int   21h
        jc    >L1
        mov   si,bx
        add   si,si
        mov   bx,word ptr ds:[mr@fbuf+si]
        call  _mem_free
        xor   cx,cx
        mov   word ptr ds:[mr@fbuf+si],cx  ; cx=0
        mov   word ptr ds:[mr@fpos+si],cx  ; cx=0
        mov   word ptr ds:[mr@finputeof+si],cx
L0:
        pop   si,cx
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],-1
        ret
L1:
#R      mov   word ptr ss:[_errcode],ax
#R      jmp   short L0
@R      jmp   _err_dos      ; no return
@R%include _err_dos

;#Ddbg_file_seek:
;#D      db    '_file_seek',0

_file_pos:
; Return current file position
;    BX    = file handle
; returns:
;    DX:AX = current file position
%allocate mr@fbuf 30
%allocate mr@fpos 30
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],offset dbg_file_pos
#C      mov   word ptr cs:[mr@critical_err],0
#R      mov   word ptr ss:[_errcode],0
        push  bx,cx
        xor   cx,cx
        xor   dx,dx
        mov   ax,4201h       ; current file position
        int   21h
        jc    >L2
        add   bx,bx          ; *2
        cmp   word ptr ds:[mr@fbuf+bx],0
        jz    >L0
        sub   ax,1024
        sbb   dx,0
        add   ax,word ptr ds:[mr@fpos+bx]
        adc   dx,0
L0:
        pop   cx,bx
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],-1
        ret
L2:
#R      mov   word ptr ss:[_errcode],ax
#R      jmp   short L0
@R      jmp   _err_dos      ; no return
@R%include _err_dos

;#Ddbg_file_pos:
;#D      db    '_file_pos',0

_file_length:
; Return length of file
;    BX    = file handle
; returns:
;    DX:AX = length of file
;mr@foff_save_lo equ [BP-2]
;mr@foff_save_hi equ [BP-4]
        push  bp
        mov   bp,sp
        sub   sp,4
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],offset dbg_file_length
#C      mov   word ptr cs:[mr@critical_err],0
#R      mov   word ptr ss:[_errcode],0
        push  cx

        xor   cx,cx
        xor   dx,dx
        mov   ax,4201h       ; current file position
        int   21h
        jc    >L1

        mov   word ptr [bp-2],ax
        mov   word ptr [bp-4],dx
        xor   cx,cx
        xor   dx,dx
        mov   ax,4202h       ; end of file position
        int   21h
        jc    >L1
        push  ax
        push  dx
        mov   cx,word ptr [bp-4]
        mov   dx,word ptr [bp-2]
        mov   ax,4200h
        int   21h
        jc    >L1
L0:
        pop   dx
        pop   ax
        pop   cx
        mov   sp,bp
        pop   bp
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],-1
        ret
L1:
#R      mov   word ptr ss:[_errcode],ax
#R      jmp   short L0
@R      jmp   _err_dos      ; no return
@R%include _err_dos

;#Ddbg_file_length:
;#D      db    '_file_length',0

_fread:
; Read a block from an open file
;    BX     = file handle
;    CX     = number of bytes to read
;    DS:SI -> buffer
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],offset dbg_fread
#C      mov   word ptr cs:[mr@critical_err],0
#R      mov   word ptr ss:[_errcode],0
        push  ax,dx
        mov   dx,si
        mov   ah,3fh
        int   21h
        jc    >L1
L0:
        or    ax,ax
        jz    >L2
        pop   dx,ax
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],-1
        ret
L1:
#R      mov   word ptr ss:[_errcode],ax
#R      jmp   short L0
@R      jmp   _err_dos      ; no return
L2:
        mov   ax,8         ; end of file
$errhandler
@R%include _err_dos

;#Ddbg_fread:
;#D      db    '_fread',0

_file_print:
; Writes a text string to an open file
;    DS:DI -> string to write
;    BX    =  file handle
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],offset dbg_file_print
#C      mov   word ptr cs:[mr@critical_err],0
#R      mov   word ptr ss:[_errcode],0
        push  ax,cx,dx,di

        mov   cx,[di]
        jcxz  >L1
        lea   dx,[di+2]
        mov   ah,40h
        int   21h
        jc    >L2
L1:
        pop   di,dx,cx,ax
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],-1
        ret
L2:
#R      mov   word ptr ss:[_errcode],ax
#R      jmp   short L1
@R      jmp   _err_dos      ; no return
@R%include _err_dos

;#Ddbg_file_print:
;#D      db    '_file_print',0

_file_open_name:
; Get a name of a file, given a handle
;    BX = handle
; returns:
;    DS:DI -> filename
%allocate mr@filename 30
;%allocate mr@filepos 30
%allocate mr@fbuf 30
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],offset dbg_file_open_name
        push  ax,bx,si
        cmp   bx,15
        ja    >L1
        shl   bx,1
        mov   si,word ptr ds:[mr@filename+bx]
        or    si,si
        jz    >L1
        call  _str_copy
        pop   si,bx,ax
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],-1
        ret
L1:
        mov   ax,4          ; invalid file handle
$errhandler
;#Ddbg_file_open_name:
;#D      db    '_file_open_name',0

_file_kill:
; Deletes a file
;    DS:SI -> pointer to filename
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],offset dbg_file_kill
#C      mov   word ptr cs:[mr@critical_err],0
#R      mov   word ptr ss:[_errcode],0
        push  cx,dx,di
        clc
        mov   al,0
        call  _str_2_asciiz
        push  di             ; save pointer in case DOS clobbers it
        mov   dx,di
        mov   ah,41h
        mov   cl,0
        int   21h
        jc    >L1
L0:
        pop   bx
        call  _mem_free
        pop   di,dx,cx
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],-1
        ret
L1:
#R      mov   word ptr ss:[_errcode],ax
#R      jmp   short L0
@R      jmp   _err_dos      ; no return
@R%include _err_dos

;#Ddbg_file_kill:
;#D      db    '_file_kill',0
