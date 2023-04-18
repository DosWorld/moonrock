
_err_msg:
;@R%ss mr@ds dw 1 dup (?)
#D%ss mr@indent dw 1 dup (?)
#D      push   sp,ss,es,ds,cs,bp,di,si,dx,cx,bx,ax
#C      push   ax
#C      mov    ax,word ptr cs:[mr@critical_err]
#C      or     ax,ax             ; did a critical error cause it?
#C      jz     >L1                ; nup
#C      pop    bx                 ; discard old error code
#C      add    ax,119            ; create new error code

#C      push   ax
#CL1:
;      call   _cprint
;      db     13,10,0
#C    pop    ax
#M    push   ax
      call   _cprint
      db     13,10,13,10
#L    db     'MoonRock r'
@L    db     'R'
      db     'untime error #',0
      call   _err_wordu
#M    pop    ax
#M    mov    cx,ax
#M    mov    si,offset mr@err_table
#M    push   cs
#M    pop    ds
#ML2:
#M    lodsb
#M    or     al,al
#M    jnz    L2
#M    lodsb
#M    or     al,al
#M    jz     >L2
#M    cmp    al,cl
#M    jnz    L2
#M    call   _cprint
#M    db '  [',0
#ML3:
#M    lodsb
#M    or     al,al
#M    jz     >L1
#M    call   _tty
#M    jmp    short L3
#ML1:
#M    call   _cprint
#M    db     ']',0
#ML2:
      call   _cprint
      db     13,10,0
#D      mov    word ptr ss:[mr@indent],20
#D      call   _cprint
#D      db     'Function track dump:',13,10,0
#D      mov    bx,offset mr@func + 40
#D      mov    cx,21
#DL1:
#D      mov    si,ss:[bx]
#D      or     si,si
#D      jz     >L4
#D      cmp    si,-1
#D      jnz    >L5
#D      mov    ax,word ptr ss:[mr@indent]
#D      sub    ax,2
#D      jnc    >L9
#D      xor    ax,ax
#DL9:
#D      mov    word ptr ss:[mr@indent],ax
#D      sub    bx,2
#D      loop   L1
#D      jmp    short L8
#DL5:
#D      add    word ptr ss:[mr@indent],2
#D      push   cx
#D      mov    cx,word ptr ss:[mr@indent]
#DL6:
#D      mov    ah,2
#D      mov    dl,' '
#D      int    21h
#D      loop   L6
#D      pop    cx

#DL2:
#D      mov    al,cs:[si]
#D      or     al,al
#D      jz     >L3
#D      call   _tty
#D      inc    si
#D      jmp    short L2
#DL3:
#D      call   _cprint
#D      db     13,10,0
#DL4:
#D      sub    bx,2
#D      loop   L1
#DL8:
#D      call   _cprint
#D      db     13,10,0

;        call   _cprint
;@D      db     13,10,0
#D      call   _cprint
#D      db     'Source: ',0
#D      push   ds
#D      push   cs
#D      pop    ds
@I#D      mov    di,offset mr@sourcefile
#I#D      mov    di,word ptr cs:[mr@sourcefile]
#D      call   _tty_str_dos
#D      pop    ds
#D      call   _cprint
#D      db     ' ',' Line: ',0
#D      mov    ax,word ptr ss:[mr@line]
#D      call   _err_wordu
#D      call   _cprint
#D      db     13,10,0
#D      mov    si,offset mr@regtable
#D      mov    cx,12
#DL1:
#D      push   cs
#D      pop    ds
#D      lodsb
#D      call   _tty
#D      lodsb
#D      call   _tty
#D      mov    al,'='
#D      call   _tty
#D      pop    bx
#D      call   _hex16_con
#D      mov    al,' '
#D      call   _tty
#D      cmp    cx,4
#D      jz     >L2
#D      call   _tty
#DL2:
#D      loop   L1
@R      mov    ds,word ptr ss:[mr@ds]
        jmp    _exit

#Dmr@regtable:
#D        db     'AXBXCXDXSIDIBPCSDSESSSSP'

mr@err_table:
; Moonrock errors
#M      db     0,1,'MCB corrupt'
#M      db     0,2,'invalid pointer to free'
#D      db     0,3,'overflow'
#M      db     0,4,'invalid file handle'
#M      db     0,5,'out of near memory'
#M      db     0,6,'invalid function call'
#D      db     0,7,'array element out of bounds'
#M      db     0,8,'read past end of file'
;      db     0,9,'not open for text read'
#P     db     0,10,'error initialising protected mode'
#D#M     db     0,11,'divide overflow'
#D#M     db     0,12,'segment boundary overrun'
#M     db     0,13,'unsupported screen mode'
; DOS errors
@R#M      db     0,100,'unknown critical error'
;#M      db     0,101,'function number invalid'
@R#M      db     0,102,'file not found'
@R#M      db     0,103,'path not found'
;@R#M      db     0,104,'out of file handles'
@R#M      db     0,105,'access denied'
;#M      db     0,106,'invalid handle'
;#M      db     0,107,'DOS memory control block destroyed'
@R#M      db     0,108,'out of far memory'
;#M      db     0,109,'memory block address invalid'
;#M      db     0,110,'environment invalid'
;#M      db     0,111,'format invalid'
;@R#M      db     0,112,'access code invalid'
;#M      db     0,113,'data invalid'
;@R#M      db     0,115,'invalid drive'
;#M      db     0,116,'attempt to remove current directory'
;#M      db     0,117,'not same device'
;#M      db     0,118,'no more files'

; Critical errors
@R#M      db     0,119,'write protect violation'
;#M      db     0,120,'unknown unit for driver'
@R#M      db     0,121,'drive not ready'
;#M      db     0,122,'unknown command given to driver'
;#M      db     0,123,'data CRC error'
;#M      db     0,124,'bad device driver request structure length'
;#M      db     0,125,'seek error'
;#M      db     0,126,'unknown media type'
;#M      db     0,127,'sector not found'
;#M      db     0,128,'printer out of paper'
;@R#M      db     0,129,'write fault'
;@R#M      db     0,130,'read fault'
@R#M      db     0,131,'general failure'
@R#M      db     0,132,'sharing violation'
@R#M      db     0,133,'lock violation'
;#M      db     0,134,'invalid disk change'
;#M      db     0,135,'FCB unavailable'
;#M      db     0,136,'sharing buffer overflow'
;#M      db     0,137,'code page mismatch'
;#M      db     0,138,'out of input'
@R#M      db     0,139,'insufficient disk space'
#M      db     0,0

_err_overflow:
        mov    ax,3
$errhandler

_err_wordu:
        mov     bx,10
        xor     dx,dx
        div     bx
        or      ax,ax          ;See if ax=0
        jz      >L1
        push    dx
        call    _err_wordu
        pop     dx
L1:
        or      dl,'0'
        mov     ah,02h
        int     21h
        ret

_err_dos:
        cmp     ax,13
        jb      >L1
        mov     ah,59h
        xor     bx,bx
        int     21h
L1:
        add     ax,100
$errhandler

_err_bound:
        mov     ax,7
$errhandler

_err_div0:
        mov     ax,11
$errhandler
