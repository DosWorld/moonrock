; FOSSIL routines which support more than one active port
; These routines differ in that they use a handle which is
; returned by mfosinit. For COM ports, the handle is the COM
; port number. For local ports, a handle of 0 is returned.
; If an error occurs, a handle of -1 is returned.
_mfosinit:
;    AX    =  port    (0 = Local)
; returns:
;    AX = handle
        push    bp
        mov     bp,sp
        push    bx,cx,si,es
        mov     ax,[bp+4]
        test    ax,ax     ; local init?
        jnz     >L2
        jmp     short >L5
L2:
        dec     ax
        mov     dx,ax
        mov     ax,0400h
        xor     bx,bx
        int     14h
        cmp     ax,1954h        ; is a FOSSIL driver present?
        jz      >L3
        mov     ax,-1           ; error occurred
        jmp     >L5

L3:
        mov     ax,1000h               ; disable ^C ^K
        int     14h

        mov     ax,1400h               ; disable watchdog
        int     14h

        mov     ax,[bp+4]

L5:
        pop     es,si,cx,bx
        pop     bp
        ret     2

_mfoscarrier:
; Checks for carrier presence
;    AX = port
; returns:
;    AX = 0   not present
;    AX = -1  present OR local
        push    bp
        mov     bp,sp
        push    dx
        mov     ax,[bp+4]
        test    ax,ax     ; local init?
        jz      >L1
        mov     dx,ax
        dec     dx

        mov     ah,03h
        int     14h
        and     ax,128                    ; if bit 7 set, carrier = TRUE
        jnz     >L1
;        xor     ax,ax                     ; return FALSE   (AX=0)
        pop     dx
        pop     bp
        ret     2
L1:
        mov     ax,-1                     ; return TRUE
        pop     dx
        pop     bp
        ret     2


_mfosdatawaiting:
; Checks for waiting data
;    AX = port
; returns:
;    AX = 0   no data in FOSSIL buffer
;    AX = -1  data waiting

        push    bp
        mov     bp,sp
        push    dx
        mov     ax,[bp+4]
        test    ax,ax     ; local init?
        jz      >L1
        mov     dx,ax
        dec     dx
        mov     ah,03h
        int     14h
        and     ax,256
        jz      >L1
        mov     ax,-1
L1:
        pop     dx
        pop     bp
        ret     2


_mfosdeinit:
; Deinitialises FOSSIL
;    AX = port
        push    bp
        mov     bp,sp
        push    ax,dx
        mov     ax,[bp+4]
        test    ax,ax    ; local?
        jz      >L1      ; ignore
        mov     dx,ax
        dec     dx
        mov     ah,05h
        int     14h
L1:
        pop     dx,ax
        pop     bp
        ret     2



_mfosflushout:
; Waits for output buffer to empty
; AX = port
        push    bp
        mov     bp,sp
        push    ax,dx
        mov     ax,[bp+4]
        test    ax,ax     ; local?
        jz      >L1       ; ignore
        mov     dx,ax
        dec     dx
        mov     ah,08h
        int     14h
L1:
        pop     dx,ax
        pop     bp
        ret     2


_mfosgetchar:
; Gets a character from FOSSIL, returns in AX
; AX = port
; returns -1 if no character available
        push    bp
        mov     bp,sp
        push    dx
        mov     ax,[bp+4]
        test    ax,ax  ; local?
        jz      >L1
        mov     dx,ax
        dec     dx
        mov     ah,03h
        int     14h
        and     ax,256                  ; any data waiting?
        jz      >L1                      ; nope
        mov     ah,02h
        int     14h
        pop     dx
        pop     bp
        ret     2
L1:
        mov     ax,-1
        pop     dx
        pop     bp
        ret     2


_mfostx:
; Transmits string to output buffer, waits if necessary
;    AX     = port
;    DS:SI -> string
        push    bp
        mov     bp,sp

        push    ax,cx,dx,si,di

#Z        push    es

        mov     ax,[bp+6]
        test    ax,ax
        jz      >L2

        mov     si,[bp+4]
        mov     cx,[si]                        ; get length
        jcxz    >L2

        lea     di,[si+2]
#Z        push    ds
#Z        pop     es

L1:
        mov     ah,19h
        int     14h
        sub     cx,ax
        add     di,ax
        jcxz    >L2                             ; all done.
        call    _timeslice
        jmp     short L1

L2:
#Z        pop     es
        pop     di,si,dx,cx,ax
        pop     bp
        ret     4
