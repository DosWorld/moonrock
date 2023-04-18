_is386:
   pushf
   mov   ax,7000h
   push  ax
   popf
   pushf
   pop   ax
   and   ax,7000h
   jnz   >L1
   xor   ax,ax
   popf
   ret
L1:
   mov   ax,-1
   popf
   ret

