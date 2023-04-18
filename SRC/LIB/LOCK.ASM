_flock:
#R      mov     word ptr ss:[_errcode],0
        mov     ax,5c00h
        int     21h
        jc      >L1
        ret
L1:
#R      add     ax,100
#R      mov     word ptr ss:[_errcode],ax
#R      ret
@R      jmp     _err_dos
@R%include _err_dos

_funlock:
#R      mov     word ptr ss:[_errcode],0
        mov     ax,5c01h
        int     21h
        jc      >L1
        ret
L1:
#R      add     ax,100
#R      mov     word ptr ss:[_errcode],ax
#R      ret
@R      jmp     _err_dos
@R%include _err_dos
