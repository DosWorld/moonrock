_farmemcopy:
; farmemcopy(sseg%, soffset%, dseg%, doffset%, bytes%)
;            bp+12  bp+10     bp+8   bp+6      bp+4
        push    bp
        mov     bp,sp
        push    si,di,ds,es

        mov     ds,[bp+12]
        mov     es,[bp+8]

        mov     cx,[bp+4]    ; bytes
        mov     di,[bp+6]    ; dest offset
        mov     si,[bp+10]    ; source offset
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

;        mov     ax,[bp+004h]
        pop     es,ds,di,si
        pop     bp
        ret     10
#DL1:
#D      mov     ax,12   ; segment overrun
#D$errhandler


_farmemcopys:
; copies from seg to seg without offset specified
; farmemcopys(sseg%, dseg%, bytes%)
;            bp+8    bp+6   bp+4
        push    bp
        mov     bp,sp
        push    si,di,ds,es

        mov     ds,[bp+8]
        mov     es,[bp+6]

        mov     cx,[bp+4]    ; bytes
        xor     si,si
        xor     di,di

;#D      mov     ax,si
;#D      add     ax,cx
;#D      jc      >L1
;#D      mov     ax,di
;#D      add     ax,cx
;#D      jc      >L1

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
        ret     6
;#DL1:
;#D      mov     ax,12   ; segment overrun
;#D$errhandler
