_crc16:

; returns:
;    AX    =  CRC16

; DECLARE FUNCTION CRC16% ALIAS "_crc16" (s$)

;         int 3
         push   bp
         mov    bp, sp
         push   bx, cx, dx, si, ds
         push   [bp+6]
         call   far StringLength  ; AX = length
         mov    cx, ax
         jcxz   >L5
         push   [bp+6]
         call   far StringAddress ; DX:AX = address
         mov    ds, dx
         mov    si, ax
         xor    dx, dx

L1:
         lodsb
;         mov    al, [si]
;         inc    si
         xor    ah, ah
         xchg   ah, al
         xor    dx, ax
         push   cx
         mov    cx, 8
L2:
         mov    bx, dx
         shl    dx, 1
         and    bx, 8000h
         jz     >L3
         xor    dx, 1021h
L3:
         loop   L2
         pop    cx
         loop   L1

         mov    ax, dx
L4:
         pop    ds, si, dx, cx, bx
         pop    bp
         retf   2
L5:
         xor    ax, ax
         jmp    L4
