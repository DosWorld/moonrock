_str_ccnt:
; Count occurrences of character n in str1 up to position [BX]
;    DS:SI -> str1
;    BX     = end position in str1 (0=scan entire string)
;    CL     = character to find
; returns:
;    AX     = character count
        push  dx,di
#Z        push    es
        mov   di,si
        xchg  ax,cx          ; mov al,cl
        xor   dx,dx          ; count
        or    bx,bx          ; scan entire string?
        jz    >L1

;        mov   cx,ds:[di]     ; length
;        jcxz  >L4            ; null
;        sub   cx,bx
;        jnc   >L2            ; no carry, OK

        mov     cx,bx
        jcxz    >L1
        cmp     cx,ds:[di]
        jbe     >L2
L1:
        mov   cx,ds:[di]     ; too big or entire string
L2:
#Z        push  ds
#Z        pop   es

@S        inc     di
@S        inc     di
#S        add     di,2
L1:
        repnz scasb
        jz    >L3            ; found match?
L2:
        jcxz  >L4            ; end of string?
        jmp   short L1
L3:
        inc   dx
        jmp   short L2
L4:
        xchg  ax,dx          ; mov ax,dx
#Z      pop     es
        pop   di,dx
        ret

_str_instr1:
; Search for str2 inside str1
;    DS:SI -> str2           NOTE ORDER
;    DS:DI -> str1           OF STRINGS!
;    BX     = starting position in str1   ;** not implemented
; returns:
;    AX     = position in string (0 if not found)
        push  bx,cx,dx,bp,es
        mov   bp,sp
        sub   sp,6
        push  ds
        pop   es
        mov   al,ds:[si+2]   ; load first char
        mov   [bp-6],ax
        mov   cx,ds:[di]     ; get length of str1
        mov   [bp-2],di      ; LenStr1 : temp store
;        add   di,bx
@S        inc   di
@S        inc   di
#S        add   di,2
L1:
        mov   ax,[bp-6]
        repnz scasb           ; search for first char
        jnz   >L9             ; no match at all
        jcxz  >L9

        mov   bx,si          ; temp store
        mov   dx,ds:[si]     ; length of str2
@S        inc     si
@S        inc     si
#S        add     si,2
        mov   [bp-4],di      ; temp store
        dec   di
L2:
        lodsb
        cmp   ds:[di],al
        jnz   >L3
        inc   di
;        dec   cx               ; reached end of main string?
;        cmp   cx,0ffffh
        jz    >L9
        dec   dx
        jnz   L2               ; reached end of str2?
        mov   ax,[bp-4]       ; current DI position
        sub   ax,[bp-2]       ; LenStr1
        sub   ax,2            ; less length ptr
        jmp   short >L5
L3:
        mov   si,bx           ; restore SI
        mov   di,[bp-4]       ; restore DI
        inc   di               ; +1
        loop  L1
        jmp   short >L9
;        jmp   L1

L5:
        mov   sp,bp
        pop   es,bp,dx,cx,bx
        ret
L9:
        xor   ax,ax
        jmp   short L5

_str_cs_ds_mark:
        call  _str_cs_ds
        jmp   _str_mark_si
%include _str_mark_si

_str_mark_si:
; Mark a string for later release
;    DS:SI -> string to add to release list
%allocate mr@markptr 2
%allocate mr@marklist 30
        push  bx
        mov   bx,word ptr ds:[mr@markptr]
        mov   word ptr ds:[mr@marklist+bx],si
        add   word ptr ds:[mr@markptr],2
        pop   bx
        ret

_str_mark_di:
; Mark a string for later release
;    DS:DI -> string to add to release list
%allocate mr@markptr 2
%allocate mr@marklist 30
        push  bx
        mov   bx,word ptr ds:[mr@markptr]
        mov   word ptr ds:[mr@marklist+bx],di
        add   word ptr ds:[mr@markptr],2
        pop   bx
        ret

_str_free:
; Frees memory allocated to string
;    BX -> location in DS
; Note: passed by pointer to pointer
        mov   bx,[bx]
        jmp   _mem_free
%include _mem_free

_str_rtrim:
;    DS:SI -> source string
; returns:
;    DS:DI -> right trimmed string
        push  ax,bx,cx,si
#Z      push    es
        mov   cx,[si]
        jcxz  >L3
#Z        push    ds
#Z        pop     es           ; DS=ES

        lodsw                ; add si,2
        push  si
        add   si,cx
        inc   cx             ; size of dest string
L1:
        dec   si
        jcxz  >L4
        dec   cx
        mov   al,[si]
        cmp   al,' '
        jbe   L1

        pop   si
        jcxz  >L3
        mov   bx,cx
        add   bx,2
        call  _mem_alloc
        push  di
        mov     ax,cx
        stosw
;        mov   [di],cx
;        inc     di
;        inc     di
        rep     movsb
;L1:
;        lodsb
;        mov   [di],al
;        inc   di
;        loop  L1
        pop   di

L2:
#Z      pop   es

        pop   si,cx,bx,ax
        ret
L4:
        pop   si       ; discard
L3:
        xor   di,di    ; null
        jmp   short L2

_sinstr:
; Searches str1 for characters in set str2
;   SI -> string to search
;   DI -> set
; returns:
;   AX =  position (0 if not found)
%allocate mr@sinstr_set 256
        push   bx,cx,dx,bp
#Z      push    es
#Z        push   ds
#Z        pop    es                   ; ES=DS for this func

        mov    bx,di
        mov    di,offset mr@sinstr_set
        mov    dx,di

@3      xor    ax,ax
@3      mov    cx,128
@3      rep    stosw               ; null table

#3      xor    eax,eax
#3      mov    cx,64
#3      rep    stosd

        mov    cx,[bx]
        jcxz   >L5
        add    bx,2
;        xor    ax,ax             ; AX=0 already
L1:
        mov    di,dx
        mov    al,[bx]            ; get next char in set
        add    di,ax              ; calculate position in table
        mov    byte ptr [di],-1          ; add to table
        inc    bx
        loop   L1

        mov    cx,[si]            ; size of string to search
        jcxz   >L5
@S        inc     si
@S        inc     si
#S        add     si,2
        xor    bp,bp              ; position counter
        mov    di,dx
        mov    bh,0
L1:
        inc    bp
        mov    bl,[si]
        inc    si
        cmp    byte ptr [di+bx],-1
        jz     >L2
        loop   L1
L5:
        xor    ax,ax
        jmp    short >L3
L2:
        xchg   ax,bp
L3:
#Z      pop     es
        pop    bp,dx,cx,bx
        ret

_str_mix:
; Note: String pointers are passed as stack based variables
;   CX     = number of arguments
; returns:
;   DS:DI -> new string
%allocate mr@str_mix_ret 2
        pop    word ptr ds:[mr@str_mix_ret] ; pop return address
        push   bp
        mov    bp,sp
        add    bp,2
        push   ax,bx,dx,si
#Z        push   es
#Z        push   ds
#Z        pop    es                  ; NOTE! ES=DS for this func
        mov    dx,cx               ; arg count
        xor    si,si
        xor    ax,ax
L1:
        mov    bx,[bp+si]          ; pointer
        add    ax,[bx]             ; add size
@S        inc     si
@S        inc     si
#S        add     si,2
        loop   L1

        mov    bx,ax
        push   bx                  ; save size
        add    bx,2
        call   _mem_alloc          ; pointer is now in DI

;        pop    word ptr [di]       ; size
;        push   di
;        inc     di
;        inc     di
;  ----\
        pop     ax
        push    di
        stosw

        mov    si,dx               ; point to last arg
        shl    si,1
L1:
        mov    bx,[bp+si-2]        ; pointer to arg
        push   si                  ; save arg pointer
        mov    si,bx
        mov    cx,[si]             ; size

        lodsw     ; add    si,2

@S      rep     movsb

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

        pop    si
@S        dec     si
@S        dec     si
#S        sub     si,2
        jnz    L1

        pop    di
        mov    cx,dx
        shl    cx,1
#Z        pop    es
        pop    si,dx,bx,ax
        pop    bp
        add    sp,cx               ; readjust stack
        jmp    word ptr ds:[mr@str_mix_ret]

_str_conc:
; concaneatates DS:DI + DS:SI
; * NOTE order of arguments! *
; Returns:
;    DS:DI -> new combined string
        push   ax,bx,cx
#Z        push    es
#Z        push   ds
#Z        pop    es                  ; NOTE! ES=DS for this func
        mov    bx,[di]
        add    bx,[si]
        push   si
        mov    si,di
        push   bx
        add    bx,2                ; 2 bytes for string length
        call   _mem_alloc          ; Allocate memory
        pop    bx
        mov    [di],bx             ; Save dest length
        push   di                  ; Push dest pointer
@S        inc     di
@S        inc     di                  ; Point to start of dest string
#S        add     di,2
        mov    cx,[si]             ; Length of string1
        jcxz   >L1
        add    si,2

@S      rep     movsb

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

L1:
        pop    ax                  ; dest pointer
        pop    si
        push   ax                  ; dest pointer
        mov    cx,[si]             ; Length of string2
        jcxz   >L2
@S        inc    si
@S        inc    si
#S        add    si,2

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

L2:
        pop    di
#Z        pop    es
        pop    cx,bx,ax
        ret

_str_copy:
; Copies one string to another
;    DS:SI -> source
; returns:
;    DS:DI -> destination
        push   ax,bx,cx
#Z        push   es
#Z        push   ds
#Z        pop    es                ; NOTE! ES = DS for this func
        mov    cx,[si]
        jcxz   >L2
        add    cx,2
        mov    bx,cx
        call   _mem_alloc
        push   di

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
#Z        pop    es
        pop    cx,bx,ax
        ret
L2:
        xor    di,di
        jmp    short L1

_str_cs_ds:
; Copies a string constant in CS to string in DS
;    CS:SI -> string
; returns:
;    DS:SI -> copy in string seg

        push   ax,bx,cx,di,ds,es
#E      mov    ax,seg _STRCONST
#E      mov    es,ax
#E      mov    cx,es:[si]
@E      mov    cx,cs:[si]
        jcxz   >L2
        add    cx,2
        mov    bx,cx
        call   _mem_alloc

        push   di

        push   ds
        pop    es               ; NOTE! ES = DS for this func
#E      mov    ax,seg _STRCONST
#E      mov    ds,ax
@E      push   cs
@E      pop    ds               ; NOTE! DS = CS for this func

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

        pop    si
L1:
        pop    es,ds,di,cx,bx,ax
        ret
L2:
        xor    si,si     ; null
        jmp    short L1

_str_compare:
; Compares one string to another
;    DS:SI -> string1
;    DS:DI -> string2
; returns:
;    AX = -1  Z=1  strings equal
;    AX =  0  Z=0  strings NOT equal

; note: DS:SI and DS:DI preserved.

        push   cx,si,di
#Z        push   es
#Z        push   ds
#Z        pop    es          ; NOTE! ES=DS for this func

        xor     ax,ax      ; return value
        mov    cx,[si]
        jcxz   >L2
        cmp    cx,[di]     ; are sizes different?
        jnz    >L2

@S        inc     si
@S        inc     si
#S        add     si,2
@S        inc     di
@S        inc     di
#S        add     di,2
        rep    cmpsb
        jnz    >L2

        dec    ax          ; not    ax
L2:
        cmp    ax,-1
#Z        pop    es
        pop    di,si,cx
        ret

_str_ucase:
; Converts string to uppercase
;    DS:SI -> string
; returns
;    DS:DI -> destination

        push   ax,bx,cx
#Z        push    es
#Z        push    ds
#Z        pop     es    ; ES=DS for this func
        mov    cx,[si]
        jcxz   >L4
        mov    bx,cx
        add    bx,2
        call   _mem_alloc
        push   di
        mov     ax,cx
        stosw
        lodsw   ; add si, 2
L1:
        lodsb
        cmp    al,'a'
        jb     >L2
        cmp    al,'z'
        ja     >L2
        and    al,0dfh
L2:
        stosb
        loop   L1
        pop    di
L3:
#Z        pop    es
        pop     cx,bx,ax
        ret
L4:
        xor   di,di   ; null
        jmp   short L3


_str_lcase:
; Converts string to lowercase
;    DS:SI -> string
; returns
;    DS:DI -> destination

        push   ax,bx,cx
#Z        push   es
#Z        push    ds
#Z        pop     es        ; DS=ES for this func
        mov    cx,[si]
        jcxz   >L4
        mov    bx,cx
        add    bx,2
        call   _mem_alloc
;        mov    [di],cx
        push   di
        mov     ax,cx
        stosw
;        inc     di
;        inc     di
        lodsw   ; add si,2
L1:
        lodsb
        cmp    al,'A'
        jb     >L2
        cmp    al,'Z'
        ja     >L2
        or     al,20h
L2:
        stosb
        loop   L1

        pop    di
L3:
#Z        pop    es
        pop    cx,bx,ax
        ret
L4:
        xor     di,di  ; null
        jmp     short L3

_str_left:
;    DS:SI -> source string
;    CX    =  character count
; returns
;    DS:DI -> destination string

        push  ax,bx,cx
        jcxz  >L3         ; null character count?
        cmp   cx,[si]    ; size requested too large?
        jb    >L1
        mov   cx,[si]
L1:
        mov   bx,cx
        add   bx,2
        call  _mem_alloc
        push  di
#Z        push  es
#Z        push  ds
#Z        pop   es

        lodsw   ; add si,2
        mov     ax,cx
        stosw

;        mov   [di],cx
;        inc     di
;        inc     di
;        inc     si
;        inc     si

@S        rep    movsb
;#S#3      mov    ax,cx
#S#3      and    ax,3
#S#3      shr    cx,2
#S#3      rep    movsd
#S#3      add    cx,ax
#S#3      rep    movsb

#S@3      shr    cx,1
#S@3      rep    movsw
#S@3      adc    cx,cx
#S@3      rep    movsb

#Z        pop   es

        pop   di
L2:
        pop   cx,bx,ax
        ret
L3:
        xor   di,di   ; null
        jmp   short L2

_str_right:
;    DS:SI -> source string
;    CX    =  character count
; returns
;    DS:DI -> destination string
        push  ax,bx,cx
        jcxz  >L3         ; null character count?
        mov   bx,[si]
        cmp   cx,bx       ; size requested too large?
        jb    >L1
        mov   cx,[si]
L1:
        sub   bx,cx
        add   si,bx
        mov   bx,cx
        add   bx,2
        call  _mem_alloc
        push  di

#Z        push  es
#Z        push  ds
#Z        pop   es

        lodsw     ; add si,2
        mov     ax,cx
        stosw
;        mov   [di],cx
;        add   di,2

@S        rep    movsb

;#S#3      mov    ax,cx
#S#3      and    ax,3
#S#3      shr    cx,2
#S#3      rep    movsd
#S#3      add    cx,ax
#S#3      rep    movsb

#S@3      shr    cx,1
#S@3      rep    movsw
#S@3      adc    cx,cx
#S@3      rep    movsb

#Z        pop   es

        pop   di
L2:
        pop   cx,bx,ax
        ret
L3:
        xor   di,di   ; null
        jmp   short L2


_str_ltrim:
;    DS:SI -> source string
; returns:
;    DS:DI -> left trimmed string
        push  ax,bx,cx
#Z        push  es
        mov   cx,[si]
        jcxz  >L2
#Z        push    ds
#Z        pop     es

        lodsw       ; add si,2
L1:
        mov   al,[si]
        cmp   al,' '
        ja    >L3
        inc   si
        loop  L1
L2:
        xor   di,di   ; null
        jmp   short >L5

L3:
        mov   bx,cx
        add   bx,2
        call  _mem_alloc
        push  di
        mov     ax,cx
        stosw
;        mov   [di],cx
;        inc   di
;        inc   di
        rep     movsb
        pop   di
L5:
#Z        pop   es
        pop     cx,bx,ax
        ret

_cinstr:
; Finds character in string
;    DS:SI -> string to check
;    CL     = character to find
; returns:
;    AX     = position in string (0 if not found)

        push  bx,cx,di
#Z        push  es
#Z        push  ds
#Z        pop   es               ; NOTE! ES=DS for this func
        xchg  cx,ax            ; mov al,cl
        mov   cx,[si]
        jcxz  >L1


@S        inc     si
@S        inc     si
#S        add     si,2

        mov   di,si
        repnz scasb
        jz    >L2
L1:
        xor   ax,ax
        jmp   short >L3
L2:
        mov   ax,di            ; yes,store posi
        sub   ax,si
L3:
#Z        pop   es
        pop   di,cx,bx
        ret

_str_mid:
; Returns part of a string
;   DS:SI -> source string
;   BX     = position to start
;   CX     = length to copy (0=rest)
; returns:
;   DS:DI -> new string
        push  dx
#3      push  ax
        mov   dx,[si]
        sub   dx,bx            ; does start posi point outside string?
        jc    >L4               ; DX contains size of remaining string
        dec   bx
        cmp   cx,dx            ; is requested length too large?
        ja    >L0
        or    cx,cx
        jnz   >L1
L0:
        mov   cx,dx
        inc   cx
L1:
        add   si,bx
        mov   bx,cx
        add   bx,2
        call  _mem_alloc
        push  di
#Z        push  es
#Z        push  ds
#Z        pop   es
        lodsw   ; add si,2
        mov     ax,cx
        stosw

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

#Z        pop   es
;L3:
        pop   di
#3      pop   ax
        pop   dx
        ret
L4:
        xor   di,di       ; null
#3      pop   ax
        pop   dx
        ret

_str_space:
; Create a string with CX spaces
;    CX     = size of string
; returns:
;    DS:DI -> string
        or    cx,cx        ; negative?
        js    >L1
        jcxz  >L1          ; zero?
        push  ax,bx
#Z        push  es
        mov   bx,cx
        add   bx,2
        call  _mem_alloc
        push  di
;        mov   [di],cx
#Z        push  ds
#Z        pop   es
        mov     ax,cx
        stosw
;        inc   di
;        inc   di
        mov   al,' '
        rep   stosb
        pop   di
#Z        pop   es
        pop   bx,ax
        ret
L1:
        xor   di,di
        ret

_str_null:
; Create a string with CX nulls
;    CX     = size of string
; returns:
;    DS:DI -> string
        or    cx,cx       ; negative?
        js    >L1
        jcxz  >L1          ; zero?
        push  ax,bx
#Z        push    es
        mov   bx,cx
        add   bx,2
        call  _mem_alloc
        push  di
;        mov   [di],cx
#Z        push  ds
#Z        pop   es
        mov     ax,cx
        stosw
;        inc   di
;        inc   di
        xor   al,al
        rep   stosb
        pop   di
#Z        pop   es
        pop   bx,ax
        ret
L1:
        xor   di,di
        ret

_str_repstr:
; Creates a new string with CX copies of DS:SI
;   DS:SI -> source
;   CX     = number of copies
; returns:
;   DS:DI -> string
        push  ax,bx,dx,bp
#Z        push  es
#Z        push  ds
#Z        pop   es               ; NOTE! ES=DS for this function
        lodsw
;        mov   ax,[si]
;        inc   si
;        inc   si
        mov   bp,ax
        mul   cx               ; size of resultant string
        push  ax
        add   ax,2
        xchg  bx,ax           ; (mov bx,ax)
        call  _mem_alloc
        pop   word ptr [di]             ; save size
        push  di

@S        inc     di
@S        inc     di
#S        add     di,2

        mov   bx,si
        mov   ax,bp           ; AX=size of string to copy
        mov   dx,cx           ; DX=number of times to do it
L1:
        mov   cx,ax
        mov   si,bx

@S        rep   movsb

#S        shr   cx,1
#S        rep   movsw
#S        adc   cx,cx
#S        rep   movsb

        dec   dx
        jnz   L1

        pop   di
#Z        pop   es
        pop   bp,dx,bx,ax
        ret
