_cmdline:
; Returns commandline in DS:DI
        push  ax,bx,cx,ds,es
#E      mov   es,word ptr ds:[mr@psp]
@E      push  cs
@E      pop   es

        mov   bl,es:[080h]
        or    bl,bl
        jz    >L3
        xor   bh,bh
        add   bx,2
        call  _mem_alloc
        push  di

        push  ds
        pop   es           ; NOTE! ES=DS for this func

#E      mov   ds,word ptr ds:[mr@psp]
@E      push  cs
@E      pop   ds           ; NOTE! DS=CS for this func

        mov   cl,ds:[080h]
        xor   ch,ch
        mov   es:[di],cx
@S        inc   di
@S        inc   di
#S        add   di,2
        mov   si,81h
        rep   movsb

        pop   di
L2:
        pop   es,ds,cx,bx,ax
        ret
L3:
        xor   di,di
        jmp   short L2
