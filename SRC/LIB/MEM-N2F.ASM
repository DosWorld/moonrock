_memneartofar:
; Copies near memory to far memory
; neartofar(soffset%, dseg%, doffset%, bytes%)
;           bp+10     bp+8   bp+6      bp+4
        push    bp
        mov     bp,sp
        push    si,di,es
        mov     es,[bp+8]
        mov     di,[bp+6]
        mov     si,[bp+10]
        mov     cx,[bp+4]

#D      mov     ax,si
#D      add     ax,cx
#D      jc      >L1
#D      mov     ax,di
#D      add     ax,cx
#D      jc      >L1

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

        pop     es,di,si
        pop     bp
        ret     8
#DL1:
#D      mov     ax,12   ; segment overrun
#D$errhandler

_memfartonear:
; Copies far memory to near memory
; neartofar(sseg%, soffset%, doffset%, bytes%)
;           bp+10      bp+8      bp+6    bp+4
        push    bp
        mov     bp,sp
        push    si,di,ds,es
        push    ds
        pop     es
        mov     ds,[bp+10]
        mov     si,[bp+8]
        mov     di,[bp+6]
        mov     cx,[bp+4]

#D      mov     ax,si
#D      add     ax,cx
#D      jc      >L1
#D      mov     ax,di
#D      add     ax,cx
#D      jc      >L1

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

        pop     es,ds,di,si
        pop     bp
        ret     8
#DL1:
#D      mov     ax,12   ; segment overrun
#D$errhandler


