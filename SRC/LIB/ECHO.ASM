_file_print_cs:
; Writes a text string located in CS to an open file
;    CS:DI -> string to write
;    BX    =  file handle
@E   push  ds
@E   push  cs
@E   pop   ds
#E   xchg  si,di
#E   call  _str_cs_ds
#E   xchg  di,si
     call  _file_print
#E   xchg  bx,di
#E   call  _mem_free
#E   xchg  di,bx
@E   pop   ds
   ret

_echo_strconst:
; Display string constant pointed to by CS:DI
; destroys: BX
@E   push  ds
@E   push  cs
@E   pop   ds
#E   xchg  si,di
#E   call  _str_cs_ds
#E   xchg  di,si
#E   push  di
$outstream
#E   pop   bx
#E   call  _mem_free
@E   pop   ds
   ret

_echo_words:
; Display integer in AX
        push    bx
        call    _words
        push    di
$outstream
        pop     bx
        call    _mem_free
        pop     bx
        ret

_echo_doublewords:
; Display integer in AX:DX
        push    bx
        call    _doublewords
        push    di
$outstream
        pop     bx
        call    _mem_free
        pop     bx
        ret
