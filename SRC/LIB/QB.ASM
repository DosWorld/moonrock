_str_copy_qb:
        push   bx,cx,ds,es

        mov    es,word ptr cs:[mr@their_ds]

        mov    cx,es:[si]          ; get length
        jcxz   >L2
        mov    bx,cx
        add    bx,2
        call   _mem_alloc

        mov    [di],cx

        push   di
@S        inc     di
@S        inc     di
#S        add     di,2

        push   ds
        pop    es                ; ES=DS for this func

        mov    ds,word ptr cs:[mr@their_ds]

        mov    si,[si+2]        ; get address

@S        rep    movsb

#S#3      mov    ax,cx
#S#3      and    ax,3
#S#3      shr    cx,2
#S#3      rep    movsd
#S#3      add    cx,ax
#S#3      rep    movsb

#S@3      shr    cx,1
#S@3      rep    movsw
#S@3      adc    cx,cx
#S@3      rep    movsb

        pop    di
L1:
        pop    es,ds,bx,cx
        ret
L2:
        xor    di,di
        jmp    short L1
