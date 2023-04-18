_mem2disk_null:
; Converts memory record to null terminated string
;    DS:SI -> pointer to record
;       CX  = max static size
; format before conv: DSpointer(word)
; format after conv:  string+<NULL>
;        mov     si,[si]
;        lodsw              ; get string size
;        cmp     ax,cx      ; smaller than record size?


        ret
_mem2disk_pascal:
        ret
_mem2disk_mr:
        ret

_disk2mem_null:
; Converts null terminated string in disk record to memory record
;    DS:SI -> position in record
;       CX  = max static size
; format before conv: string+<NULL>
; format after conv:  DSpointer(word)
        push  bx,di
#Z        push  es
#Z        push  ds
#Z        pop   es          ; ES=DS for this func
        mov   di,si
        mov   al,0
        mov   bx,cx
        repnz scasb       ; find null terminator
        sub   bx,cx      ; find length
        lea   cx,[bx-1]
        jcxz  >L5
        add   bx,2
        call  _mem_alloc
        mov   [di],cx    ; store length
        push  di
        push  si
@S        inc     di
@S        inc     di
#S        add     di,2
        rep   movsb
        pop   si
        pop   word ptr [si]        ; store pointer in record
L1:
#Z        pop   es
        pop   di,bx
        ret
L5:
        mov   word ptr [si],cx    ; cx=0
        jmp   short L1

_disk2mem_mr:
; Converts MR string in disk record to memory record
;    DS:SI -> position in record
; format before conv: sizeofstr(word)+string
; format after conv:  DSpointer(word)
        push  bx,di
#Z        push  es
#Z        push  ds
#Z        pop   es          ; ES=DS for this func
        mov   bx,[si]    ; size: word
        mov   cx,bx
        jcxz  >L5         ; 0 length?
        add   bx,2
        call  _mem_alloc
        mov   [si],di    ; store pointer
        mov   [di],cx    ; store length
@S        inc     si
@S        inc     si
#S        add     si,2
@S        inc     di
@S        inc     di
#S        add     di,2

        rep   movsb
L1:
#Z        pop   es
        pop   di,bx
        ret
L5:
        mov   word ptr [si],cx   ; cx=0
        jmp   short L1

_disk2mem_pascal:
; Converts Pascal string in disk record to memory record
;    DS:SI -> position in record
; format before conv: sizeofstr(byte)+string
; format after conv:  DSpointer(word)
        push  bx,di
#Z        push  es
#Z        push  ds
#Z        pop   es          ; ES=DS for this func
        mov   bl,[si]    ; size: byte
        mov   bh,0
        mov   cx,bx
        jcxz  >L5
        add   bx,2
        call  _mem_alloc
        push  di          ; save pointer
        push  si          ; save record pos
        mov   [di],cx    ; store length in dgroup
@S        inc     di
@S        inc     di
#S        add     di,2
        inc   si
        rep   movsb       ; copy from record to dgroup
        pop   si          ; record pos
        pop   word ptr [si]        ; string pointer
L1:
#Z        pop   es
        pop   di,bx
        ret
L5:
        mov   word ptr [si],cx   ; cx=0
        jmp   short L1
