_exec:
; Execute program at DS:SI with parameters DS:DI
; returns:
;   AX = errorlevel returned
%allocate execp_env 2
%allocate execp_cmd 4
%allocate execp_fc1 2
%allocate execp_fc2 2

#R      mov   word ptr ss:[_errcode],0
#1      pusha
@1        push  bx,cx,dx,bp,si,di
#Z        push    es
#Z        push  ds
#Z        pop   es

        mov   bp,di
        clc
        xor   al,al
        call  _str_2_asciiz
        push  di
        mov   dx,di

        mov   si,bp
        mov   cx,ds:[si]
        mov   bx,cx
        add   bx,4
        call  _mem_alloc
        push  di
        lodsw         ; add si,2
        mov   al,cl
        add   al,2
        stosb
        mov   al,' '
        stosb
        rep   movsb

;        mov   ax,1300h
;        stosw
        mov     word ptr ds:[di],13

;        mov   al,13
;        stosb
;        mov   al,0
;        stosb

        pop   di
        push  di
        mov   word ptr ds:[execp_cmd],di
        mov   word ptr ds:[execp_cmd+2],ds

        xor   ax,ax
        mov   word ptr ds:[execp_env],ax
        mov   word ptr ds:[execp_fc1],ax
        mov   word ptr ds:[execp_fc2],ax

        mov   ax,4b00h
        mov   bx,offset execp_env
        int   21h
        pop   bx
        pop   cx
        pushf

        call  _mem_free
        mov   bx,cx
        call  _mem_free

        popf
        jc    >L1

        mov   ah,4dh      ; get errorlevel
        int   21h

L2:
#Z      pop     es
#1      popa
@1        pop   di,si,bp,dx,cx,bx
        ret
L1:
#R      mov   ss:[_errcode],ax
#R      jmp   short L2
@R        jmp   _err_dos     ; no return
@R%include _err_dos

