_set_critical:
%include _critical
#3      push  eax
@3      push  ax
        push  es
        xor   ax,ax
        mov   es,ax
        cli
#3      mov   eax,dword ptr es:[24h*4]
#3      mov   dword ptr cs:[old_int24],eax
@3      mov   ax,word ptr es:[24h*4]
@3      mov   word ptr cs:[old_int24],ax
@3      mov   ax,word ptr es:[24h*4+2]
@3      mov   word ptr cs:[old_int24+2],ax
        mov   word ptr es:[24h*4],offset _critical
        mov   word ptr es:[24h*4+2],cs
        sti
        pop   es
@3      pop   ax
#3      pop   eax
        ret
_restore_critical:
@3      push  ax
#3      push  eax
        push  es
        xor   ax,ax
        mov   es,ax
        cli
#3      mov   eax,dword ptr cs:[old_int24]
#3      mov   dword ptr es:[24h*4],eax
@3      mov   ax,word ptr cs:[old_int24]
@3      mov   word ptr es:[24h*4],ax
@3      mov   ax,word ptr cs:[old_int24+2]
@3      mov   word ptr es:[24h*4+2],ax
        sti
        pop   es
@3      pop   ax
#3      pop   eax
        ret

_critical:
        test  ah,80h
        jz    >L1
        db    0EAh  ;; jmp far
old_int24    dd ?
L1:
@P        mov   word ptr cs:[mr@critical_err],di   ; store critical error
#P        push  ds
#P        mov   ax,seg _STACK
#P        mov   ds,ax
#P        mov   word ptr ds:[mr@critical_err],di
#P        pop   ds
        mov   al,03h                      ; fail call
        iret
@Pmr@critical_err dw 1 dup (?)
#P%ss mr@critical_err dw 1 dup (?)

