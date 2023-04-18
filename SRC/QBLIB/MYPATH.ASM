
; DECLARE SUB MyPath ALIAS "_mypath" (s$)

; p$ = SPACE$(64)          ' VERY important! This must have something in it
; call MyPath (p$)
; p$ = RTRIM$(p$)          ' trim back to normal size

; PRINT p$                 ' p$ now contains full path+filename of EXE
public _mypath
public

_mypath:

        push  bp
        mov   bp, sp                ; I hate stack based variables.
        push  ax, bx, cx, dx, si, di, ds, es

        mov   ax, 6200h
        int   21h                   ; get PSP segment
        mov   es, bx                ; ES points to PSP

        mov   bx, es:[2ch]          ; get environment segment
        mov   es, bx                ; ES now points to environment.

        xor   al, al                ; AL=0
        xor   di, di                ; DI=0
        mov   cx, 7fffh             ; environment can be up to 32k in size!

@searchloop:

        repnz scasb                 ; search for null
        scasb                       ; is there another null after that?
        jnz   @searchloop           ; no, still searching

        add   di, 2
        mov   si, di

        mov   bx, [bp+6]            ; string descriptor
        mov   di, [bx+2]            ; actual string address

        push  es
        mov   ax, ds
        mov   es, ax
        pop   ds                    ; xchg ds, es

@copyloop:

        lodsb                       ; load byte from environment
        or    al, al                ; is it null? (end of string)
        jz    @copydone
        stosb                       ; store byte to QB string
        jmp   @copyloop

@copydone:

        pop   es, ds, di, si, dx, cx, bx, ax
        pop   bp
        retf  2
