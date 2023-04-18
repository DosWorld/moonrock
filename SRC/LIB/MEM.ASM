; Memory allocation routines.
; ---------------------------
;
; Memory is allocated by pointer rather than segment: these routines use
; DI as a pointer into a constant segment, thus there is a communal
; maximum limit of slightly less than 64k.
;
; Note: DS should always point to the same constant segment and is assumed to
;       be valid in these routines
;
; Memory control block structure:
;
; offs  type  description
; ----  ----  ----------------------
;  0    byte  signature "R"
;  1    byte  status - "F" free  "A" allocated
;  2    word  size of block in bytes
;  4    word  pointer: previous MCB (0=first block)
;  6    word  pointer: forward MCB (0=last block)
;  8

_mem_alloc:
;    BX = number of bytes to allocate
; returns:
;    DS:DI -> memory block
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],offset dbg_mem_alloc
        push  ax,bx,si
        test  bx,1
        jz    >L1
        inc   bx
L1:
        mov   di,$StartOfDynamic
L2:
        cmp   byte ptr [di],'R'
        jnz   >L9                  ; error!!! pointing to invalid block
        cmp   byte ptr [di+1],'F'  ; free?
        jz    >L4
L3:
        mov   di,[di+6]            ; point to next block
        or    di,di                ; null?
        jnz   L2                   ; nup, continue loop
; if we drop down here we're at the last block and therefore out of
; memory. Crash!
        mov   ax,5                 ; out of memory
$errhandler
L4:
        cmp   [di+2],bx            ; is the block big enough?
        jb    L3                   ; nup
        mov   word ptr [di],'AR'   ; set to allocated status
        mov   [di+2],bx            ; size of block
        lea   si,[di+bx+16]        ; SI temp. 16 is merely a nice number
        cmp   si,[di+6]            ; is there room to create new MCB?
        ja    >L5                  ; nope: leave as-is

;       /~~~~~~~~~~~~~~~~~~~~~~~~\        old link
;      |                          |
;   previous MCB---new MCB---forward MCB  new links

        lea   si,[di+bx+8]         ; point to new MCB
        mov   word ptr [si],'FR'   ; sig+free
        mov   ax,[di+6]            ; pointer to forward MCB
        sub   ax,si                ; difference from new MCB
        sub   ax,8                 ; less space for previous+new MCB
; ***
        mov   [si+2],ax            ; AX contains new block size
        mov   [si+4],di            ; point to last MCB
        mov   ax,[di+6]
        mov   [si+6],ax            ; pointer to forward MCB
; New MCB has now been filled
        mov   bx,[di+6]
        mov   [bx+4],si

        mov   [di+6],si            ; previous MCB -> new MCB
L5:
        add   di,8                 ; point to actual memory
        pop   si,bx,ax
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],-1
        ret
L9:
        mov   ax,1                 ; corrupt MCB
$errhandler
;#Ddbg_mem_alloc:
;#D      db    '_mem_alloc',0

_mem_free:
; DS:BX points to memory block
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],offset dbg_mem_free
        or    bx,bx                 ; null?
        jz    >L9                   ; skip the rest
        push  ax,bx,si,di

        sub   bx,8                  ; point to MCB

        cmp   word ptr [bx],'AR'    ; allocated?
        jnz   >L5                   ; error! not allocated!
        mov   word ptr [bx],'FR'    ; mark free

        mov   si,[bx+4]             ; previous MCB
        mov   di,[bx+6]             ; forward MCB

    or    si,si                 ; first MCB?
    jz    >L1                   ; nup, skip to forward free check
    cmp   word ptr [si],'FR'    ; is previous MCB free?
    jnz   >L1                   ; nup, skip to forward free check

    mov   ax,[bx+2]             ; this block size
    add   ax,8                  ; plus MCB
    add   [si+2],ax             ; save new size of previous MCB
    mov   [si+6],di             ; link previous to forward
    mov   [di+4],si
    mov   word ptr [bx],'fr'    ; invalidate block header
    mov   bx,si

L1:
        or    di,di                 ; last MCB?
        jz    >L2                   ; nup
        cmp   word ptr [di],'FR'    ; is forward MCB free?
        jnz   >L2                   ; nup
        mov   ax,[di+2]             ; forward block size
        add   ax,8                  ; plus MCB
        add   [bx+2],ax             ; save new size
        mov   ax,[di+6]
        mov   [bx+6],ax
        mov   word ptr [di],'fr'    ; invalidate block header
L2:
        pop   di,si,bx,ax
L9:
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],-1
        ret
L5:
        mov   ax,2                  ; Invalid pointer to free
$errhandler
;#Ddbg_mem_free:
;#D      db    '_mem_free',0

_sub_cleanup:
; Release strings used in sub
; DS:SI -> offset list
; NOTE: no registers deliberately preserved
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],offset dbg_sub_cleanup
        xor   ax,ax         ; used later
L1:
        mov   di,cs:[si]    ; pointer to pointer
        or    di,di
        jz    >L3
        mov   bx,[di]
        mov   [di],ax       ; ax=0
        or    bx,bx
        jz    >L2
        call  _mem_free
L2:
        add   si,2
        jmp   short L1
L3:
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],-1
        ret
;#Ddbg_sub_cleanup:
;#D      db    '_sub_cleanup',0

_str_release:
; Release previously marked strings
%allocate mr@markptr 2
%allocate mr@marklist 30
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],offset dbg_str_release
        push  bx,cx,si
        mov   cx,word ptr ds:[mr@markptr]        ; pointer
        jcxz  >L4
        shr   cx,1                      ; count of args
        mov   si,offset mr@marklist     ; point to start of list
L1:
        mov   bx,ds:[si]
        or    bx,bx
        jz    >L2
        call  _mem_free
        jcxz  >L3
L2:
@S        inc   si
@S        inc   si
#S        add   si,2
        loop  L1
L3:
        mov   word ptr ds:[mr@markptr],cx  ; cx=0
L4:
        pop   si,cx,bx
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],-1
        ret
;L5:
;        mov   ax,2          ; Invalid pointer to free
;$errhandler
;#Ddbg_str_release:
;#D      db    '_str_release',0

_mem_usage:
; Returns free memory
;   BX = total free memory
;   CX = size of largest free block

;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],offset dbg_mem_usage
        push  ax,di
        mov   di,$StartOfDynamic
        xor   bx,bx                  ; total free memory
        xor   cx,cx                  ; largest free block
L1:
        cmp   byte ptr [di],'R'      ; get signature
        jnz   >L9                    ; error!!! pointing to an invalid block
        cmp   byte ptr [di+1],'F'    ; is it free?
        jnz   >L2                    ; no, skip it
        mov   ax,[di+2]              ; get length of current block
        add   bx,ax                  ; add to total memory count
        cmp   ax,cx                  ; is this block larger than previous largest?
        ja    >L4
L2:
        mov   di,[di+6]
        or    di,di
        jnz   L1                     ; loop back
; now at last block
        pop   di,ax
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],-1
        ret

L4:
        mov   cx,ax                  ; store as new largest block
        jmp   short L2
L9:
        mov   ax,1                   ; corrupt MCB
$errhandler
;#Ddbg_mem_usage:
;#D      db    '_mem_usage',0

_mem_usage_total_ax:
        call  _mem_usage
        mov   ax,bx
        ret

_mem_usage_total_bx:
        jmp   _mem_usage
%include _mem_usage

_mem_usage_largest_ax:
        call  _mem_usage
        mov   ax,cx
        ret

_mem_usage_largest_bx:
        call  _mem_usage
        mov   bx,cx
        ret

_mem_usage_dump:
        push  ax,bx,cx,ds,di
#Z        push  es
#Z        push  ds
#Z        pop   es
        mov   ah,2
        mov   dl,13
        int   21h
        mov   dl,10
        int   21h
        mov   di,$StartOfDynamic

        xor   bx,bx         ; free
        xor   cx,cx         ; alloc
        mov   word ptr cs:[mr@freeb],bx  ; bx=0
        mov   word ptr cs:[mr@allocb],bx ; bx=0
L1:

        push  bx
        mov   bx,di
        call  _hex16_con
        pop   bx
        cmp   byte ptr [di+1],'A'
        jnz   >L2
        call  _cprint
        db    ' ',' USED',0
        jmp   >L4

L2:
        cmp   byte ptr [di+1],'F'
        jnz   >L3
        call  _cprint
        db    ' ',' FREE',0
        jmp   >L4
L3:
        call  _cprint
        db    ' ',' ????',0
L4:
        call  _cprint
        db    ' ',' Len=',0
        push  bx
        mov   bx,[di+2]     ; get length of current block
        call  _hex16_con
        call  _cprint
        db    ' ',' Prev=',0
        mov   bx,[di+4]
        call  _hex16_con
        call  _cprint
        db    ' Forward=',0
        mov   bx,[di+6]
        call  _hex16_con
        call  _cprint
        db    13,10,0
        pop   bx
        mov   dl,32
        cmp   byte ptr [di+1],'F'
        jz    >L5
        inc   bx
        mov   ax,[di+2]
        add   word ptr cs:[mr@freeb],ax
        jmp   short >L6
L5:
        inc   cx
        mov   ax,[di+2]
        add   word ptr cs:[mr@allocb],ax
        push  cx,di
        mov   cx,ax
        xor   ax,ax
        add   di,8
        rep   stosb
        pop   di,cx
L6:
        mov   di,[di+6]
        or    di,di
        jz    >L7
        jmp   L1            ; loop back
L7:
        push  ds
        push  cs
        pop   ds
        push  cx
        call  _cprint
        db    13,10,'Alloc: ',0
        mov   ax,bx
        call  _err_wordu
        mov   ah,2
        mov   dl,'/'
        int   21h
        mov   ax,word ptr cs:[mr@freeb]
        call  _err_wordu
        call  _cprint
        db    13,10,'Free: ',' ',0
        pop   ax
        call  _err_wordu
        mov   ah,2
        mov   dl,'/'
        int   21h
        mov   ax,word ptr cs:[mr@allocb]
        call  _err_wordu
        pop   ds
#Z        pop   es
        pop   di,dx,cx,bx,ax
        ret
L9:
        mov   ax,1          ; corrupt MCB
$errhandler
mr@freeb: dw ?
mr@allocb: dw ?
;mr@mud1: db 13,10,'Alloc: $'
;mr@mud2: db 13,10,'Free: ',' $'

_memchk:
; Checks linked list chain for integrity
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],offset dbg_memchk
        push  ax,di
        mov   di,$StartOfDynamic
L1:
        cmp   byte ptr [di],'R'      ; get signature
        jnz   >L9                    ; error!!! pointing to an invalid block
        mov   di,[di+6]
        or    di,di
        jnz   L1                     ; loop back
; now at last block
        pop   di,ax
;#D      call  _packfunctiondump
;#D      mov   word ptr ss:[mr@func],-1
        ret
L9:
        mov   ax,1                   ; corrupt MCB
$errhandler
;#Ddbg_memchk:
;#D      db    '_memchk',0
