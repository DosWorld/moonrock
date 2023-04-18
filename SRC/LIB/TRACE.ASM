_trace:
@1        push  ax,bx,cx,dx,si,di,bp,es
#1        pusha
        mov   al,'['
        call  _tty
#I      mov   di,word ptr cs:[mr@sourcefile]
#I      push  ds
#I      push  cs
#I      pop   ds
#I      call  _tty_str_dos
#I      pop   ds
#I      mov   al,':'
#I      call  _tty
        mov   ax,word ptr ss:[mr@line]
        call  _err_wordu
        mov   al,']'
        call  _tty
        mov   al,' '
        call  _tty
@1        pop   es,bp,di,si,dx,cx,bx,ax
#1        popa
        ret
;trace:  db    '_trace',0
