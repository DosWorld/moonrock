; DECLARE FUNCTION sinstr% ALIAS "_sinstr" (str1$, set1$)

public _sinstr
public

_sinstr:
; Searches str1 for characters in set str2
; returns:
;   AX =  position (0 if not found)

STR1 equ [bp+8]
SET equ [bp+6]

        push   bp
        mov    bp, sp
        push   bx, cx, dx
        mov    cx, 128
        mov    di, offset __table
        xor    ax, ax
        push   es, cs
        pop    es
        rep    stosw
        pop    es

        mov    si, [SET]                       ; get set descriptor
        mov    cx, [si]                        ; get length
        mov    bx, [si+2]                      ; get address of set

        xor    ax, ax
L1:
        mov    di, offset __table
        mov    al, [bx]            ; get next char in set
        add    di, ax              ; calculate position in table
        mov    cs:[di] b, -1       ; add to table
        inc    bx
        loop   L1

        mov    si, [STR1]
        mov    cx, [si]            ; size of string to search
        jcxz   NoMatch
        mov    bx, [si+2]
        mov    si, bx
        xor    bx, bx              ; position counter
L1:
        inc    bx
        mov    di, offset __table
        lodsb
        add    di, ax              ; calculate position in table
        cmp    cs:[di] b, -1
        jz     >L2
        loop   L1
NoMatch:
        xor    ax, ax
        jmp    >L3
L2:
        mov    ax, bx
L3:
        pop    dx, cx, bx
        pop    bp
        retf   4

__table: db 256 dup (0)
