_get_day:
        push    ax,bx,cx,dx
#Z        push    es
#Z        push    ds
#Z        pop     es
        mov     bx,5
        call    _mem_alloc
        push    di
        mov     word ptr [di],3
@S        inc     di
@S        inc     di
#S        add     di,2

        mov     ah,2ah
        int     21h
        mov     bl,3
        mul     bl
        mov     bx,ax
        xor     bh,bh
        add     bx,offset mr@daylist
        mov     ax,word ptr cs:[bx]
        stosw
        mov     al,byte ptr cs:[bx+2]
        stosb
        pop     di
#Z        pop     es
        pop     dx,cx,bx,ax
        ret
mr@daylist:
        db      'SunMonTueWedThuFriSat'

_get_date:
%bundle dateblk
;bundle DATEBLK day@, month@, year%
        push    ax,bx,cx,dx
#Z        push    es
#Z        push    ds
#Z        pop     es
        mov     bx,13
        call    _mem_alloc
        push    di

        mov     ax,11
        stosw
;        mov     word ptr [di],11
;        inc     di
;        inc     di

        mov     ah,2ah
        int     21h

        mov     byte ptr ds:[b_DATEBLK_DAY],dl
        mov     byte ptr ds:[b_DATEBLK_MONTH],dh
        mov     word ptr ds:[w_DATEBLK_YEAR],cx
        mov     al,dl
        call    _dtS1
        mov     al,'-'
        stosb

        mov     al,dh
        dec     al
        mov     dh,3
        mul     dh
        mov     bx,ax
        xor     bh,bh
        add     bx,offset mr@monthlist
        mov     ax,cs:[bx]
        stosw
        mov     al,cs:[bx+2]
        stosb

        mov     al,'-'
        stosb
        sub     cx,1900
        cmp     cl,100
        mov     ch,13h
        jc      >L1
        sbb     cl,100
        inc     ch
L1:
        mov     al,ch
        call    _dtS1
        mov     al,cl
        call    _dtS1
        pop     di
#Z        pop     es
        pop     dx,cx,bx,ax
        ret

mr@monthlist:
        db      'JanFebMarAprMayJunJulAugSepOctNovDec'

_dtS1:
        aam
        or      ax,3030h
        xchg    ah,al
;        mov     byte ptr [di],ah
;        inc     di
;        stosb
        stosw
        ret

_get_time:
%bundle timeblk
;bundle TIMEBLK hour@, minute@, second@
        push    ax,bx,cx,dx
#Z        push    es
#Z        push    ds
#Z        pop     es
        mov     bx,10
        call    _mem_alloc
        push    di
        mov     word ptr [di],8
@S        inc     di
@S        inc     di
#S        add     di,2

        mov     ah,2ch
        int     21h

        mov     byte ptr ds:[b_TIMEBLK_HOUR],ch
        mov     byte ptr ds:[b_TIMEBLK_MINUTE],cl
        mov     byte ptr ds:[b_TIMEBLK_SECOND],dh

        mov     al,ch
        call    _dtS1
        mov     al,':'
        stosb
        mov     al,cl
        call    _dtS1
        mov     al,':'
        stosb
        mov     al,dh
        call    _dtS1

        pop     di
#Z        pop     es
        pop     dx,cx,bx,ax
        ret

