code segment word public
assume cs:code

public _crc16

_crc16 proc far

; returns:
;    AX    =  CRC16

; DECLARE FUNCTION CRC16% ALIAS "_crc16" (s$)

         push   bp
         mov    bp,sp
         push   bx
         push   cx
         push   dx
         push   si
         mov    bx,[bp+6]
         mov    cx,[bx]          ; get length
         jcxz   L5
         mov    si,[bx+2]        ; get address

         xor    dx,dx

L1:
         lodsb
         xor    ah,ah
         xchg   ah,al
         xor    dx,ax
         push   cx
         mov    cx,8
L2:
         mov    bx,dx
         shl    dx,1
         and    bx,8000h
         jz     L3
         xor    dx,1021h
L3:
         loop   L2
         pop    cx
         loop   L1

         mov    ax,dx
L4:
         pop    si
         pop    dx
         pop    cx
         pop    bx
         pop    bp
         retf   2
L5:
         xor    ax,ax
         jmp    L4

endp
code ends
end
