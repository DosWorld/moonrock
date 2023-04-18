_enter_pmode:
; enable A20
        mov     ax,4300h         ;Function to determine if XMS available
        int     2fh
        cmp     al,80h            ;80h = available
        jnz     >L0

        mov     ax,4310h                ;XMS is available so get address
        int     2fh                      ; of XMS manager (no more interrupts)
        mov     word ptr cs:[>L2],bx
        mov     word ptr cs:[>L2+2],es

        jmp     short >L1               ; flush prefetch
L1:
        mov     ah,5
        db      09ah
L2:
        dd      ?

L0:
; DPMI
        mov     ax,1687h
        int     2fh
        test    ax,ax
        jnz     >L1
        mov     word ptr cs:[>L9],di   ; offset
        mov     word ptr cs:[>L8],es   ; seg

; Allocate memory for use by DOS extender if necessary
; NOTE:  This code assumes that the program has already
;        shrunk its memory block so that the DOS
;        memory allocation call will work

        or      si,si
        jz      >L5
        mov     bx,si
        mov     ah,48h
        int     21h
        jc      >L2
        mov     es,ax
        jmp     short >L5

;
; Enter protected mode as a 16-bit program
;

L5:
        xor     ax,ax
        db      9Ah  ; call far
L9:
        dw ?       ; offset
L8:
        dw ?       ; seg
        jc      >L3            ; failed

        mov     ax,2
        xor     bx,bx
        int     31h               ; get real mode selector for base
        jc      >L6

        mov     fs,ax
        mov     bx,ax
        mov     ax,8
        mov     cx,-1
        mov     dx,cx
        int     31h               ; set flat segment limit
        jc      >L6


L4:
        ret
L6:
        mov   ax,10
$errhandler

        ret
L1:
        call    _cprint
        db      'DPMI host not present',0
        jmp     _exit
L2:
        call    _cprint
        db      'error allocating DPMI real mode workspace',0
        jmp     _exit
L3:
        call    _cprint
        db      'error entering protected mode',0
        jmp     _exit

