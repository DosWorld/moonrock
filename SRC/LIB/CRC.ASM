_crc16:
;    DS:SI -> buffer
;    CX    =  number of bytes
; returns:
;    BX    =  CRC16

         push   ax,dx
         xor    dx,dx
L1:
         lodsb
;         mov    al,[si]
;         inc    si
         xor    ah,ah
         xchg   ah,al
         xor    dx,ax
         push   cx
         mov    cx,8
L2:
         mov    bx,dx
         shl    dx,1
         and    bx,8000h
         jz     >L3
         xor    dx,1021h
L3:
         loop   L2
         pop    cx
         loop   L1

         mov    bx,dx
         pop    dx,ax
         ret
