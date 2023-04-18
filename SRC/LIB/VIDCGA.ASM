_setmode:
%startup _graphic_setup
%include _putcga2
%include _getcga2
%include _putcga4
%include _getcga4
%include _putcga2x
%include _putcga4x
%include _clscga
;%include _cga16ktable
; AX = mode
        xor     ah,ah
        cmp     ax,6    ; mono 640x200
        jz      >L0
        cmp     ax,4    ; cga 320x200
        jz      >L1
        cmp     ax,3
        jz      >L2     ; text
        mov     ax,13   ; unsupported screen mode
$errhandler

L0:
        mov     word ptr ds:[_putpixel],offset _putcga2
        mov     word ptr ds:[_putpixelx],offset _putcga2x
        mov     word ptr ds:[_getpixel],offset _getcga2
        mov     word ptr ds:[_gcls],offset _clscga
        mov     word ptr ss:[mr@graph_seg],0b800h
        jmp     short >L9
L1:
        mov     word ptr ds:[_putpixel],offset _putcga4
        mov     word ptr ds:[_putpixelx],offset _putcga4x
        mov     word ptr ds:[_getpixel],offset _getcga4
        mov     word ptr ds:[_gcls],offset _clscga
        mov     word ptr ss:[mr@graph_seg],0b800h
        jmp     short >L9
L2:
        mov     ax,offset _nomodeset
        mov     word ptr ds:[_putpixel],ax
        mov     word ptr ds:[_putpixelx],ax
        mov     word ptr ds:[_getpixel],ax
        mov     word ptr ds:[_gcls],ax
;        mov     word ptr ss:[mr@graph_seg],0b800h
        jmp     short >L9
L9:
        int     10h
        ret

_nomodeset:
; called when putpixel or getpixel is invoked, but no graphics mode is set
        mov     ax,6    ; invalid function call
$errhandler

_graphic_setup:
%allocate _putpixel 2
%allocate _getpixel 2
%allocate _putpixelx 2
%allocate _gcls 2
%allocate mr@old_screen_mode 2
%allocate mr@cga16ktable 400
%ss mr@graph_seg dw 1 dup (?)
%include _nomodeset
%include _restore_video_mode
%cleanup _restore_video_mode
#Z        push    es
        mov     ax,offset _nomodeset
        mov     word ptr ds:[_putpixel],ax
        mov     word ptr ds:[_putpixelx],ax
        mov     word ptr ds:[_getpixel],ax
        mov     word ptr ds:[_gcls],ax
        mov     word ptr ss:[mr@graph_seg],0b800h

        mov     ah,0fh
        int     10h
        xor     ah,ah
        mov     word ptr ds:[mr@old_screen_mode],ax

        mov     di,offset mr@cga16ktable
#Z        push    ds
#Z        pop     es
        xor     ax,ax
        mov     cx,100
L1:
        stosw
        push    ax
        add     ax,2000h
        stosw
        pop     ax
        add     ax,80
        loop    L1

#Z        pop     es
        ret

_restore_video_mode:
        mov     ax,word ptr ds:[mr@old_screen_mode]
        int     10h
        ret

_clscga:
        push    ax,cx,di,es
        mov     es,word ptr ss:[mr@graph_seg]
        xor     di,di
        xor     ax,ax
        mov     cx,1FFEh
        rep     stosw
        pop     es,di,cx,ax
        ret

;_cga16ktable:
;dw      0000h,2000h,0050h,2050h,00A0h,20A0h,00F0h,20F0h
;dw      0140h,2140h,0190h,2190h,01E0h,21E0h,0230h,2230h
;dw      0280h,2280h,02D0h,22D0h,0320h,2320h,0370h,2370h
;dw      03C0h,23C0h,0410h,2410h,0460h,2460h,04B0h,24B0h
;dw      0500h,2500h,0550h,2550h,05A0h,25A0h,05F0h,25F0h
;dw      0640h,2640h,0690h,2690h,06E0h,26E0h,0730h,2730h
;dw      0780h,2780h,07D0h,27D0h,0820h,2820h,0870h,2870h
;dw      08C0h,28C0h,0910h,2910h,0960h,2960h,09B0h,29B0h
;dw      0A00h,2A00h,0A50h,2A50h,0AA0h,2AA0h,0AF0h,2AF0h
;dw      0B40h,2B40h,0B90h,2B90h,0BE0h,2BE0h,0C30h,2C30h
;dw      0C80h,2C80h,0CD0h,2CD0h,0D20h,2D20h,0D70h,2D70h
;dw      0DC0h,2DC0h,0E10h,2E10h,0E60h,2E60h,0EB0h,2EB0h
;dw      0F00h,2F00h,0F50h,2F50h,0FA0h,2FA0h,0FF0h,2FF0h
;dw      1040h,3040h,1090h,3090h,10E0h,30E0h,1130h,3130h
;dw      1180h,3180h,11D0h,31D0h,1220h,3220h,1270h,3270h
;dw      12C0h,32C0h,1310h,3310h,1360h,3360h,13B0h,33B0h
;dw      1400h,3400h,1450h,3450h,14A0h,34A0h,14F0h,34F0h
;dw      1540h,3540h,1590h,3590h,15E0h,35E0h,1630h,3630h
;dw      1680h,3680h,16D0h,36D0h,1720h,3720h,1770h,3770h
;dw      17C0h,37C0h,1810h,3810h,1860h,3860h,18B0h,38B0h
;dw      1900h,3900h,1950h,3950h,19A0h,39A0h,19F0h,39F0h
;dw      1A40h,3A40h,1A90h,3A90h,1AE0h,3AE0h,1B30h,3B30h
;dw      1B80h,3B80h,1BD0h,3BD0h,1C20h,3C20h,1C70h,3C70h
;dw      1CC0h,3CC0h,1D10h,3D10h,1D60h,3D60h,1DB0h,3DB0h
;dw      1E00h,3E00h,1E50h,3E50h,1EA0h,3EA0h,1EF0h,3EF0h

_putcga4:
;%include _cga16ktable
;%startup _graphic_setup
;plot a point on 320x200x4 color graphics screen

        cmp     cx,319
        ja      >L0
        cmp     dx,199
        ja      >L0
        push    ax,bx,cx,es
        mov     es,word ptr ss:[mr@graph_seg]
        mov     bx,dx                   ;get scan line address
        shl     bx,1                    ; ..
        mov     bx,word ptr ds:[mr@cga16ktable+bx]       ; ..
        mov     ah,cl                   ;save low byte of column
@1        shr     cx,1                    ;get column offset
@1        shr     cx,1                    ; ..
#1        shr     ax,2
        add     bx,cx                   ;add column offset to address
        not     ah                      ;get shift count
        and     ah,3                    ; ..
        shl     ah,1                    ; ..
        mov     cl,ah                   ; ..
        and     al,3                    ;mask off unwanted bits
        rol     al,cl                   ;get or mask
        mov     ah,0fch                 ;get and mask
        rol     ah,cl                   ; ..
        mov     cl,es:[bx]              ;plot the point
        and     cl,ah                   ; ..
        or      cl,al                   ; ..
        mov     es:[bx],cl              ; ..
        pop     es,cx,bx,ax
L0:
        ret

_getcga4:
;return a point from 320x200x4 color graphics screen
        cmp     cx,639
        ja      >L0
        cmp     dx,199
        ja      >L0
        push    bx,cx,es
        mov     es,word ptr ss:[mr@graph_seg]
        mov     bx,dx                   ;get scan line address
        shl     bx,1                    ; ..
        mov     bx,word ptr ds:[mr@cga16ktable+bx]       ; ..
        mov     ax,cx                   ;save column
@1        shr     ax,1                    ;get column offset
@1        shr     ax,1                    ; ..
#1        shr     ax,2
        add     bx,ax                   ;add column offset to address
        not     cl                      ;get shift count
        and     cl,3                    ; ..
        shl     cl,1                    ; ..
        mov     al,es:[bx]              ;return the point
        ror     al,cl                   ; ..
        and     ax,3                    ; ..
        pop     es,cx,bx
        ret
L0:
        mov     ax,6   ; invalid function call
$errhandler

_putcga2:
;plot a point on 640x200x2 color graphics screen
;AX=0 or 1
;CX=X
;DX=Y
;%include _cga16ktable
;%startup _graphic_setup
        cmp     cx,639
        ja      >L0
        cmp     dx,199
        ja      >L0
        push    ax,bx,cx,es
        mov     es,word ptr ss:[mr@graph_seg]
        mov     bx,dx                   ;get scan line address
        shl     bx,1                    ; ..
        mov     bx,word ptr ds:[mr@cga16ktable+bx]       ; ..
        mov     ah,cl                   ;save low order byte of column
@1        shr     cx,1                    ;get column offset
@1        shr     cx,1                    ; ..
@1        shr     cx,1                    ; ..
#1        shr     cx,3
        add     bx,cx                   ;add column offset to address
        not     ah                      ;get shift count
        and     ah,7                    ; ..
        mov     cl,ah                   ; ..
        and     al,1                    ;mask off unwanted bits
        rol     al,cl                   ;get or mask
        mov     ah,0feh                 ;get and mask
        rol     ah,cl                   ; ..
        mov     cl,es:[bx]              ;plot the point
        and     cl,ah                   ; ..
        or      cl,al                   ; ..
        mov     es:[bx],cl              ; ..
        pop     es,cx,bx,ax
L0:
        ret

_getcga2:
;return a point from 640x200x2 color graphics screen
;CX=X
;DX=Y
;%startup _graphic_setup
;%include _cga16ktable
        cmp     cx,639
        ja      >L0
        cmp     dx,199
        ja      >L0
        push    bx,cx,es
        mov     es,word ptr ss:[mr@graph_seg]
        mov     bx,dx                   ;get scan line address
        shl     bx,1                    ; ..
        mov     bx,word ptr ds:[mr@cga16ktable+bx]       ; ..
        mov     ax,cx                   ;save column
@1        shr     ax,1                    ;get column offset
@1        shr     ax,1                    ; ..
@1        shr     ax,1                    ; ..
#1        shr     ax,3
        add     bx,ax                   ;add column offset to address
        not     cl                      ;get shift count
        and     cl,7                    ; ..
        mov     al,es:[bx]              ;return the point
        ror     al,cl                   ; ..
        and     ax,1                    ; ..
        pop     es,cx,bx
        ret
L0:
        mov     ax,6                   ; invalid function call
$errhandler


_putcga4x:
;%include _cga16ktable
;%startup _graphic_setup
;plot a point on 320x200x4 color graphics screen (XOR)

        cmp     cx,319
        ja      >L0
        cmp     dx,199
        ja      >L0
        push    ax,bx,cx,es
        mov     es,word ptr ss:[mr@graph_seg]
        mov     bx,dx                   ;get scan line address
        shl     bx,1                    ; ..
        mov     bx,word ptr ds:[mr@cga16ktable+bx]       ; ..
        mov     ah,cl                   ;save low byte of column
@1        shr     cx,1                    ;get column offset
@1        shr     cx,1                    ; ..
#1        shr     ax,2
        add     bx,cx                   ;add column offset to address
        not     ah                      ;get shift count
        and     ah,3                    ; ..
        shl     ah,1                    ; ..
        mov     cl,ah                   ; ..
        and     al,3                    ;mask off unwanted bits
        rol     al,cl                   ;get or mask
;        mov     ah,0fch                 ;get and mask
;        rol     ah,cl                   ; ..
        xor     es:[bx],cl
;        mov     cl,es:[bx]              ;plot the point
;        and     cl,ah                   ; ..
;        or      cl,al                   ; ..
;        mov     es:[bx],cl              ; ..
        pop     es,cx,bx,ax
L0:
        ret

_putcga2x:
;plot a point on 640x200x2 color graphics screen (XOR)
;AX=0 or 1
;CX=X
;DX=Y
;%include _cga16ktable
;%startup _graphic_setup
        cmp     cx,639
        ja      >L0
        cmp     dx,199
        ja      >L0
        push    ax,bx,cx,es
        mov     es,word ptr ss:[mr@graph_seg]
        mov     bx,dx                   ;get scan line address
        shl     bx,1                    ; ..
        mov     bx,word ptr ds:[mr@cga16ktable+bx]       ; ..
        mov     ah,cl                   ;save low order byte of column
@1        shr     cx,1                    ;get column offset
@1        shr     cx,1                    ; ..
@1        shr     cx,1                    ; ..
#1        shr     cx,3
        add     bx,cx                   ;add column offset to address
        not     ah                      ;get shift count
        and     ah,7                    ; ..
        mov     cl,ah                   ; ..
        and     al,1                    ;mask off unwanted bits
        rol     al,cl                   ;get or mask
;        mov     ah,0feh                 ;get and mask
;        rol     ah,cl                   ; ..
;        mov     cl,es:[bx]              ;plot the point
;        and     cl,ah                   ; ..
;        or      cl,al                   ; ..
;        mov     es:[bx],cl              ; ..
        xor      es:[bx],al
        pop     es,cx,bx,ax
L0:
        ret
