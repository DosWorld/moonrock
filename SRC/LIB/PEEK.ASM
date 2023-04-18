_mem_put_2:
; Copy a word from data area to memory
;   DS:SI   -> source
;   BX:DI   -> destination
        push  bx,es
        mov   es,bx
        mov   bx,[si]
        mov   es:[di],bx
        pop   es,bx
        ret

_mem_put_4:
; Copy a doubleword from data area to memory
;   DS:SI   -> source
;   BX:DI   -> destination
@3      push  bx
#3      push  ebx
        push  es
        mov   es,bx
@3      mov   bx,[si]
@3      mov   es:[di],bx
@3      mov   bx,[si+2]
@3      mov   es:[di+2],bx
#3      mov   ebx,[si]
#3      mov   es:[di],ebx
        pop   es
@3      pop   bx
#3      pop   ebx
        ret

_mem_put_x:
; Copy from data area to memory
;   DS:SI   -> source
;   BX:DI   -> dest buffer
;   CX       = number of bytes to transfer
        jcxz  >L1
        push  bx,es
        mov   es,bx
        rep   movsb
        pop   es,bx
L1:
        ret

_mem_get_2:
; Copy a word from memory to data area
;   BX:SI   -> source
;   DS:DI   -> destination
        push  bx,es
        mov   es,bx
        mov   bx,es:[si]
        mov   [di],bx
        pop   es,bx
        ret

_mem_get_4:
; Copy a doubleword from memory to data area
;   BX:SI    -> source
;   DS:DI    -> destination
        push  bx,es
        mov   es,bx
        mov   bx,es:[si]
        mov   [di],bx
        mov   bx,es:[si+2]
        mov   [di+2],bx
        pop   es,bx
        ret

_mem_get_x:
; Copy memory into the data area
;   BX:SI   -> source
;   CX       = number of bytes to transfer
;   DS:DI   -> dest buffer
        jcxz  >L1
        push  bx,es,ds
        push  ds
        pop   es
        mov   ds,bx
        rep   movsb
        pop   ds,es,bx
L1:
        ret

