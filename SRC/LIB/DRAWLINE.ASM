_drawline:
%include _drawline2
        mov     ax,word ptr ds:[_putpixel]
        mov     word ptr ds:[_dlpp],ax
        jmp     _drawline2

_drawlinex:
%include _drawline2
        mov     ax,word ptr ds:[_putpixelx]
        mov     word ptr ds:[_dlpp],ax
        jmp     _drawline2

;        daN ROlliNS  (213) 246-5021
;
;8088 self-modifying program implements fast-vector algorithm
;described by Michalsky, doctor dobb's Journal #74, 12/82
;see also: FaST-liNE dRaWiNG TEchNiQUE, byTE, aug 81
;
;routine expects to be called with dS:Si pointing
;to a list of 2-byte arguments:
;
;     si+0   = x1     starting clm (0-319)
;     si+2   = y1     starting row (0-159)
;     si+4   = x2     ending clm
;     si+6   = y2     ending row
;     si+8   = color  (0,1,2,3)
;     si+10  = length
;              0    = draw entire line
;              else = draw sub- or super-set of this vector
;     si+12  = skip length
;              number of pels to go before starting to draw
;              0    = draw entire line

;destroys all registers execpt si and segment regs
_drawline2:
%allocate _dlpp 2

;x1       equ   [bp+16]
;y1       equ   [bp+14]
;x2       equ   [bp+12]
;y2       equ   [bp+10]
;color    equ   [bp+8]
;len      equ   [bp+6]
;skip     equ   [bp+4]
 
;these are values that will be overlayed in the code

;inc_x  EQU  41h
;dec_x  EQU  49h
;inc_y  EQU  42h
;dec_y  EQU  4ah

;these are the addresses where new code is overlayed

;adJ_lONG_axiS   EQU  byTE PTR cS:[di]
;adJ_MaSTER      EQU  WORd PTR cS:[di+3]
;TEST_MaSTER     EQU  WORd PTR cS:[di+7]
;alT_adJ_MaSTER  EQU  WORd PTR cS:[di+13]
;adJ_ShRT_axiS   EQU  byTE PTR cS:[di+15]

      push      bp
      mov       bp,sp

      mov   bl,41h   ;aSSUME xSTEP = +1
      mov   ax,[bp+12]
      sub   ax,[bp+16]
      jge   >L0        ;iF [bp+16] <= [bp+12] ThEN NO chaNGE

      mov   bl,49h   ;xSTEP = -1
      neg   ax         ;xdist = abS(xdist)
L0:
      mov   cx,ax      ;SaVE xdiST

      mov   bh,42h   ;aSSUME ySTEP = +1
      mov   ax,[bp+10]
      sub   ax,[bp+14]
      jge   >L0        ;iF [bp+14] <= [bp+10] ThEN NO chaNGE

      mov   bh,4ah   ;ySTEP = -1
      neg   ax         ;ydiST = abS(ydiST)
L0:
      mov   dx,ax                     ;SaVE ydiST
      mov   di,offset >L3
      ;cS:MOdiFy_baSE  ;POiNT TO ThE cOdE
                                      ;TO MOdiFy
      cmp   dx,cx                     ;dETERMiNE lONGEST axiS
      jge   >L0                       ;y iS lONGER, SO SKiP
                   
      xchg  cx,dx              ;SWaP xdiST, ydiST
      xchg  bl,bh              ;SWaP inc/dec x/y ValUES
L0:                           ;MOdiFy:
      mov   byte ptr cs:[di],bh   ;ThE 1st inc/dec cOdE
      mov   word ptr cs:[di+3],cx      ;MaiN dUTy MaSTER adJUSTMENT
      shr   cx,1               ;SET UP cyclE TESTER
      mov   word ptr cs:[di+7],cx     ;TEST FOR cycliNG
      mov   word ptr cs:[di+13],dx  ;alTERNaTE adJUSTMENT
      mov   byte ptr cs:[di+15],bl   ;alTERNaTE inc/dec cOdE

      mov   di,dx      ;di iS cOUNTER: lONG axiS lENGTh
      cmp   word ptr [bp+6],0      ;iF lENGTh aRG > 0
      je    >L0
      mov   di,[bp+6]     ;ThEN USE iT aS cOUNTER
L0:
      mov   cx,[bp+16]      ;   aNd OThER aRGS
      mov   dx,[bp+14]
      mov   al,[bp+8]
      mov   bp,[bp+4]    ;GET SKiP cOUNT
      xor   bx,bx      ;dUTy MaSTER STaRTS = 0

      jmp       short >L1    ; flush prefetch

;--------TOP OF VEcTOR PlOTTiNG lOOP--------------------
L1:
      cmp   bp,0       ;TEST SKiP cOUNT
      je    >L2
      dec   bp
      jmp   >L3
L2:
;      call  PlOTdOT    ;PlOT a dOT
        call word ptr ds:[_dlpp]
;
;MOST OF ThE FOllOWiNG cOdE iS MOdiFiEd by ThE PREViOUS SEQUENcE.
;ThE 1111h'S aRE dUMMy ValUES ThaT aRE alWayS OVERlayEd.
;
;MOdiFy_baSE:
L3:
       inc   cx        ;inc/dec cx/dx: adJUST lONG axiS PTR
       add   bx,1111h  ;xdiST OR ydiST: adJUST dUTy MaSTER
       cmp   bx,1111h  ;ydiST OR xdiST: chEcK cyclE POSiTiON
       jle   >L0       ;SKiP iF ShORT axiS iS STill OK

       sub   bx,1111h  ;xdiST OR ydiST: adJUST dUTy MaSTER
       inc   dx        ;inc/dec dx/cx: adJUST ShORT axiS PTR
L0:
       dec   di        ;di iS USEd aS cOUNTER
       jge   L1       ;dO NExT dOT iF NOT FiNiShEd
             ;--------------------------------------------------
       pop      bp
       ret      14

;this routine plots the pixel at column cx (0-319) or (0-639)
;                                row    dx (0-199)
;                                colour al (0-3) or (0-1) in high res
;note: a much faster routine
;      can be wiritten to plot dots
;
;PlOTdOT:
;         PUSh  ax
;         PUSh  di      ;biOS dESTROyS ThESE REGiSTERS
;         PUSh  bp
;
;         mov   ah,12   ;WRiTE_dOT FUNcTiON
;         iNT   10h     ;  VidEO i/O call
;
;         POP   bp
;         POP   di
;         POP   ax
;         RET           ;NEaR RETURN TO dRaWliNE PROc
