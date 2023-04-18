_timeslice:
%startup _multitask_setup
%allocate mr@multitasker 1
; 0 = DOS     1 = DV    2 = Generic OS/2 Windows
; NOTE: no registers deliberately preserved
;        mov   al,ds:[mr@multitasker]
;        cmp   al,1
        cmp   byte ptr ds:[mr@multitasker],1
        je    >L2
        jb    >L1
        mov   ax,1680h
        int   2fh            ; Generic OS/2 Windows
        ret
L1:
        int   28h            ; DOS
        ret
L2:
        mov   ax,1000h
        int   15h
        ret

_multitask_setup:
%allocate mr@multitasker 1
        mov   ax,2b01h
        mov   cx,4445h
        mov   dx,5351h
        int   21h
        cmp   al,0ffh     ; DV is present if AL<>FFh
        jz    >L1
        mov   al,1
        jmp   short >L9
L1:
        mov   ax,1680h
        int   2fh
        or    al,al       ; AL=0 if call supported
        jnz   >L1
        mov   al,2
        jmp   short >L9
L1:
        xor   al,al
L9:
        mov   byte ptr ds:[mr@multitasker],al
        ret
