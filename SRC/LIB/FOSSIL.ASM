_fos_init:
;    AX    =  port
; returns:
;    DS:DI -> FOSSIL init string
        push    bx,cx,si
        push    es   ; ES used later
        mov     word ptr ss:[mr@fosactiveport],-1
        cmp     ax,-1     ; is it a local init
        jnz     >L1
#Z        push    ds
#Z        pop     es
        mov     bx,7
        call    _mem_alloc
        mov     si,offset mr@local
        push    di
        push    ds
        push    cs
        pop     ds
#S        mov     cx,3
#S        rep     movsw
#S        movsb                   ; move 7 bytes
@S        mov     cx,7
@S        rep     movsb
        pop     ds
        pop     di
        jmp     short >L5

L1:
        dec     ax
        mov     word ptr ss:[mr@fosactiveport],ax
        mov     dx,ax
        mov     ax,0400h
        xor     bx,bx
        int     14h
        cmp     ax,1954h        ; is a FOSSIL driver present?
        jz      >L2
        mov     word ptr ss:[mr@fosactiveport],-1  ; invalidate
        xor     di,di           ; null string
        jmp     >L5

L2:
        mov     ax,1000h               ; disable ^C ^K
        int     14h

        mov     ax,1400h               ; disable watchdog
        int     14h

        mov     ax,1b00h
        push    ss
        pop     es
        mov     di,offset mr@fosinfo
        mov     cx,19
        int     14h                     ; get info

        mov     es,word ptr ss:[mr@fosinfo_idseg]
        mov     di,word ptr ss:[mr@fosinfo_idptr]
        mov     al,0
        mov     cx,128
        repnz   scasb
        mov     bx,130
        sub     bx,cx                  ; size + 2
        lea     cx,[bx-2]
        call    _mem_alloc
        mov     [di],cx
        push    di
@S        inc     di
@S        inc     di
#S        add     di,2
        mov     ax,es
        push    ds
        pop     es
        mov     ds,ax
        mov     si,word ptr ss:[mr@fosinfo_idptr]
        rep     movsb
        push    es
        pop     ds
        pop     di
L5:
        pop     es,si,cx,bx
        ret

mr@local: dw 5
          db 'Local'

%ss mr@fosactiveport       dw 1 dup (?)

%ss mr@fosinfo label near
%ss mr@fosinfo_strsize     dw 1 dup (?)
%ss mr@fosinfo_ver         dw 1 dup (?)
%ss mr@fosinfo_idptr       dw 1 dup (?)
%ss mr@fosinfo_idseg       dw 1 dup (?)
%ss mr@fosinfo_ibufr       dw 1 dup (?)
%ss mr@fosinfo_ifree       dw 1 dup (?)
%ss mr@fosinfo_obufr       dw 1 dup (?)
%ss mr@fosinfo_ofree       dw 1 dup (?)
%ss mr@fosswidth           db 1 dup (?)
%ss mr@fossheight          db 1 dup (?)
%ss mr@fosbaud             db 1 dup (?)

_fos_carrier:
; Checks for carrier presence
; returns:
;    AX = 0   not present
;    AX = -1  present OR local
        push    dx
        mov     dx,word ptr ss:[mr@fosactiveport]
        cmp     dx,-1
        jz      >L1

        mov     ah,03h
        int     14h
        and     ax,128                    ; if bit 7 set, carrier = TRUE
        jnz     >L1
;        xor     ax,ax                     ; return FALSE   (AX=0)
        pop     dx
        ret
L1:
        mov     ax,-1                     ; return TRUE
        pop     dx
        ret


_fos_datawaiting:
; Checks for waiting data
; returns:
;    AX = 0   no data in FOSSIL buffer
;    AX = -1  data waiting

        push  dx
        mov   dx,word ptr ss:[mr@fosactiveport]
        cmp   dx,-1                     ; Local?
        jz    >L1
        mov   ah,03h
        int   14h
        and   ax,256
        jz    >L1
        mov   ax,-1
        pop   dx
        ret
L1:
;        xor   ax,ax
        pop   dx
        ret


_fos_deinit:
; Deinitialises FOSSIL
        push  ax,dx
        mov   dx,word ptr ss:[mr@fosactiveport]
        cmp   dx,-1
        jz    >L1
        mov   ah,05h
        int   14h
L1:
        mov   word ptr ss:[mr@fosactiveport],-1
        pop   dx,ax
        ret



_fos_flush:
; Waits for output buffer to empty
        push  ax,dx
        mov   dx,word ptr ss:[mr@fosactiveport]
        cmp   dx,-1
        jz    >L1
        mov   ah,08h
        int   14h
L1:
        pop   dx,ax
        ret


_fos_getchar:
; Gets a character from FOSSIL, returns in AX
; returns -1 if no character available
        push  dx
        mov   dx,word ptr ss:[mr@fosactiveport]
        cmp   dx,-1
        jz    >L1
        mov   ah,03h
        int   14h
        and   ax,256                   ; any data waiting?
        jz    >L1                      ; nope
        mov   ah,02h
        int   14h
        pop   dx
        ret
L1:
        pop   dx
        mov   ax,-1
        ret


_fos_tx:
; Transmits string to output buffer, waits if necessary
;    DS:SI -> string
        push  ax,cx,dx,di
#Z        push  es

        mov   dx,word ptr ss:[mr@fosactiveport]
        cmp   dx,-1
        jz    >L2

        mov   cx,[si]                        ; get length
        jcxz  >L2

        lea   di,[si+2]
;        add   si,2
;        mov   di,si
#Z        push  ds
#Z        pop   es

L1:
        mov   ah,19h
        int   14h
        sub   cx,ax
        add   di,ax
        jcxz  >L2                             ; all done.
        call  _timeslice
        jmp   short L1

L2:
#Z        pop   es
        pop   di,dx,cx,ax
        ret
