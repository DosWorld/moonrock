DECLARE SUB Split4 (s$)
DECLARE FUNCTION Hex2$ (l%)
DECLARE FUNCTION Hex4$ (l&)
DECLARE FUNCTION PointerModel% (bpptr%)
DECLARE SUB ErrTypeMismatch (z%)
DECLARE SUB PutHandle (z%)
DECLARE SUB PutLine (l$)
DECLARE SUB ReportErr (E$, indent%, showline%)
DECLARE FUNCTION BunPtr% (z%)
DECLARE FUNCTION BunSize% (z%)

DECLARE FUNCTION numi$ (tmp%)

'$INCLUDE: 'MR.INC'

FUNCTION BunPtr% (z%)
bn$ = LCASE$(bp$(z%))
BunPtr% = 0
FOR I% = 0 TO BundlePtr%
 IF bn$ = Bundle$(I%) THEN BunPtr% = I%: EXIT FUNCTION
NEXT
BunPtr% = -1
END FUNCTION

FUNCTION BunSize% (z%)
bn$ = LCASE$(bp$(z%))
BunSize% = 0
FOR I% = 0 TO BundlePtr%
 IF bn$ = Bundle$(I%) THEN BunSize% = BundleSize%(I%): EXIT FOR
NEXT
END FUNCTION

SUB ProcessNum1Func (savevar%)
 SELECT CASE CRC16%(LCASE$(bp$(2)))

  CASE &H1E5D
  ' "isleapyear"
   SELECT CASE bpt%(3)
    CASE IntConst%
     PutLine ("mov ax,*03")
    CASE IntByte%, IntWord%, IntDoubleWord%
     PutLine ("mov ax,ds:[%03]")
   CASE ELSE
    CALL ErrTypeMismatch(3)
   END SELECT
   PutLine ("call _isleapyear")
   IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
   EXIT SUB

  CASE &H1B3F
  ' "keystatus"
   SELECT CASE bpt%(3)
    CASE IntConst%
     PutLine ("mov bx,*03")
    CASE IntByte%, IntWord%, IntDoubleWord%
     PutLine ("mov bx,ds:[%03]")
   CASE ELSE
    CALL ErrTypeMismatch(3)
   END SELECT
   PutLine ("call _keystatus")
   IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
   EXIT SUB

  CASE &H232A
  ' "unusedstack"
   PutLine ("call _unusedstack")
   IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
   EXIT SUB

  CASE &H1F9C
  ' "freestack"
   PutLine ("call _freestack")
   IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
   EXIT SUB

  CASE &H1639
  ' "cget"
  IF bpt%(3) = IntConst% THEN
   PutLine ("mov ax,*03;push ax")
  ELSE
   PutLine ("push word ptr ds:[%03]")
  END IF
  IF bpt%(4) = IntConst% THEN
   PutLine ("mov ax,*04;push ax")
  ELSE
   PutLine ("push word ptr ds:[%04]")
  END IF
  PutLine ("call _cget")
  IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
  EXIT SUB

  CASE &H4A5E
  ' "xpos"
  PutLine ("call _curp_get;mov al,dl;xor ah,ah")
  IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
  EXIT SUB
 
  CASE &H3CEA
  ' "ypos"
  PutLine ("call _curp_get;mov al,dh;xor ah,ah")
  IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
  EXIT SUB

  CASE &H50D8
  ' "strccnt"
  IF bpt%(3) = StrConst% THEN
   PutLine ("mov si,offset %03;call _str_cs_ds;push si")
  ELSE
   PutLine ("mov si,ds:[%03]")
  END IF
  SELECT CASE bpt%(4)
   CASE IntConst%
    PutLine ("mov bx,*04")
   CASE IntByte%
    PutLine ("mov bl,ds:[%04];xor bh,bh")
   CASE IntWord%, IntDoubleWord%
    PutLine ("mov bx,ds:[%04]")
   CASE ELSE
    ErrTypeMismatch (4)
  END SELECT
  SELECT CASE bpt%(5)
   CASE IntConst%
    PutLine ("mov cl,*05")
   CASE IntByte%, IntWord%, IntDoubleWord%
    PutLine ("mov cl,byte ptr ds:[%05]")
   CASE ELSE
    ErrTypeMismatch (5)
  END SELECT
  PutLine ("call _str_ccnt")
  IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
  IF bpt%(3) = StrConst% THEN PutLine ("pop bx;call _mem_free")
  lastsvar2$ = ""
  EXIT SUB

  CASE &H19A4
  ' "feof"
  CALL PutHandle(3)
  PutLine ("call _file_eof")
  IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
  EXIT SUB

  CASE &H6310
  ' "fosdatawaiting"
  PutLine ("call _fos_datawaiting")
  IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
  EXIT SUB

  CASE &H946D
  ' "fosgetchar"
  PutLine ("call _fos_getchar")
  IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
  EXIT SUB

  CASE &H868
  ' "foscarrier"
  PutLine ("call _fos_carrier")
  IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
  EXIT SUB

  CASE &H113E
  ' "hash1"
  IF bpt%(3) = StrConst% THEN
   PutLine ("mov si,offset %03;call _str_cs_ds;push si")
  ELSE
   PutLine ("mov si,ds:[%03]")
  END IF
  PutLine ("call _hash1")
  IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
  IF bpt%(3) = StrConst% THEN PutLine ("pop bx;call _mem_free")
  EXIT SUB
 
  CASE &H215D
  ' "hash2"
  IF bpt%(3) = StrConst% THEN
   PutLine ("mov si,offset %03;call _str_cs_ds;push si")
  ELSE
   PutLine ("mov si,ds:[%03]")
  END IF
  PutLine ("call _hash2")
  IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
  IF bpt%(3) = StrConst% THEN PutLine ("pop bx;call _mem_free")
  EXIT SUB

  CASE &H5138
  ' "instr"
  IF bpt%(3) = StrConst% THEN
   PutLine ("mov si,offset %03;call _str_cs_ds;push si;mov di,si")
  ELSE
   PutLine ("mov di,ds:[%03]")
  END IF
  IF bpt%(4) = StrConst% THEN
   PutLine ("mov si,offset %04;call _str_cs_ds;push si")
  ELSE
   PutLine ("mov si,ds:[%04]")
  END IF
  PutLine ("call _str_instr")
  IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
  IF bpt%(3) = StrConst% THEN PutLine ("pop bx;call _mem_free")
  IF bpt%(4) = StrConst% THEN PutLine ("pop bx;call _mem_free")
  lastsvar2$ = ""
  EXIT SUB

  CASE &H4927
  ' "fexist"
   IF bpt%(3) = StrConst% THEN
    PutLine ("mov si,offset %03;call _str_cs_ds;push si")
   ELSE
    PutLine ("mov si,ds:[%03]")
   END IF
   SELECT CASE bpt%(4)
    CASE IntConst%
     PutLine ("mov cx,*04")
    CASE IntByte%
     PutLine ("mov cl,ds:[%04];xor ch,ch")
    CASE IntWord%, IntDoubleWord%
     PutLine ("mov cx,ds:[%04]")
    CASE ELSE
     CALL ErrTypeMismatch(4)
   END SELECT
   PutLine ("call _file_exist")
   IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
   IF bpt%(3) = StrConst% THEN PutLine ("pop bx;call _mem_free")
   lastsvar2$ = ""
   EXIT SUB

  CASE &HDA44
  ' "sinstr"
   SELECT CASE bpt%(3)
    CASE StrConst%
     PutLine ("mov si,offset %03;call _str_cs_ds;push si")
    CASE StringType%
     IF lastsvar2$ = bp$(3) THEN
      PutLine ("mov si,di")
     ELSE
      PutLine ("mov si,ds:[%03]")
     END IF
   END SELECT
   SELECT CASE bpt%(4)
    CASE StrConst%
     PutLine ("push si;mov si,offset %04;call _str_cs_ds;mov di,si;mov bx,si;pop si")
    CASE StringType%
     IF lastsvar2$ <> bp$(4) THEN PutLine ("mov di,ds:[%04]")
   END SELECT
   PutLine ("call _sinstr")
   IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
   IF bpt%(4) = StrConst% THEN PutLine ("call _mem_free")
   IF bpt%(3) = StrConst% THEN PutLine ("pop bx;call _mem_free")
   lastsvar2$ = ""
   EXIT SUB
 
  CASE &HC0C0
  'CASE "cinstr"
   IF bpt%(3) <> StringType% THEN CALL ErrTypeMismatch(3)
   IF lastsvar2$ = bp$(3) THEN
    PutLine ("mov si,di")
   ELSE
    PutLine ("mov si,ds:[%03]")
   END IF
   SELECT CASE bpt%(4)
    CASE IntConst%
     IF bp$(4) = "0" THEN
      PutLine ("xor cx,cx")
     ELSE
      PutLine ("mov cx,*04")
     END IF
    CASE IntByte%
     PutLine ("mov cl,ds:[%04];xor ch,ch")
    CASE IntWord%, IntDoubleWord%
     PutLine ("mov cx,ds:[%04]")
    CASE ELSE
     CALL ErrTypeMismatch(4)
   END SELECT
   PutLine ("call _cinstr")
   IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
   lastsvar2$ = ""
   EXIT SUB

   'CASE "exec"
   CASE &H3C24
    popfree% = 0
    IF bp$(4) = "mr@null$" THEN
     PutLine ("xor di,di;push di")
'     popfree% = popfree% + 1
    ELSE
     IF bpt%(4) = StrConst% THEN
      PutLine ("mov si,offset %04;call _str_cs_ds;push si;mov di,si")
      popfree% = popfree% + 1
     ELSE
      IF lastsvar2$ <> bp$(4) THEN PutLine ("mov di,ds:[%04]")
     END IF
    END IF
  
    IF bpt%(3) = StrConst% THEN
     PutLine ("mov si,offset %03;call _str_cs_ds;push si")
     popfree% = popfree% + 1
    ELSE
     PutLine ("mov si,ds:[%03]")
    END IF
    PutLine ("call _exec")
    IF popfree% > 0 THEN
     FOR I% = 1 TO popfree%
      PutLine ("pop bx;call _mem_free")
     NEXT
    END IF
    IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
    lastsvar2$ = ""
    EXIT SUB

   CASE &HF3A3
   'CASE "fpos"
    CALL PutHandle(3)
    PutLine ("call _file_pos")
    IF savevar% = TRUE THEN
     PutLine ("mov ds:[%00],ax")
     IF bpt%(0) = IntDoubleWord% THEN PutLine ("mov ds:[%00+2],dx")
     lastivar1$ = bp$(0)
    END IF
    EXIT SUB

   CASE &H6B90
   'CASE "fcreate"
    IF bpt%(3) = StrConst% THEN
     PutLine ("mov si,offset %03;call _str_cs_ds;push si")
    ELSE
     IF lastsvar2$ = bp$(3) THEN
      PutLine ("mov si,di")
     ELSE
      PutLine ("mov si,ds:[%03]")
     END IF
    END IF
'    fileatt% = &H20' archive bit
    IF bpp% > 3 THEN
     FOR z% = 4 TO bpp%
      SELECT CASE LCASE$(bp$(z%))
       CASE "readonly"
        fileatt% = fileatt% OR 1
       CASE "hidden"
        fileatt% = fileatt% OR 2
       CASE "system"
        fileatt% = fileatt% OR 4
       CASE "archive"
        fileatt% = fileatt% OR 32
       CASE "shareable"
        fileatt% = fileatt% OR 128
       CASE ELSE
        CALL ReportErr("^ Bad attribute command", bpsp%(z%), TRUE)
      END SELECT
     NEXT
    END IF
    IF fileatt% = 0 THEN
     PutLine ("xor cx,cx")
    ELSE
     PutLine ("mov cx,0" + HEX$(fileatt%) + "h")
    END IF
    PutLine ("call _file_create")
    IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
    IF bpt%(3) = StrConst% THEN PutLine ("pop bx;call _mem_free")
    lastsvar2$ = ""
    EXIT SUB

  CASE &HAA7C
  'CASE "fget"
   CALL PutHandle(3)
   SELECT CASE bpt%(0)
    CASE IntByte%
     IF bpar$(0) = "" THEN
      PutLine ("mov si,offset %00;mov cx,1;call _fread")
     ELSE
      PutLine ("mov si,offset t1;mov cx,1;call _fread;mov al,byte ptr ds:[t1];mov byte ptr ds:[%00],al")
     END IF
    CASE IntWord%
     IF bpar$(0) = "" THEN
      PutLine ("mov si,offset %00;mov cx,2;call _fread")
     ELSE
      PutLine ("mov si,offset t1;mov cx,2;call _fread;mov ax,ds:[t1];mov ds:[%00],ax")
     END IF
    CASE IntDoubleWord%
     IF bpar$(0) = "" THEN
      PutLine ("mov si,offset %00;mov cx,4;call _fread")
     ELSE
      PutLine ("mov si,offset t1;mov cx,4;call _fread;mov ax,ds:[t1];mov ds:[%00],ax;mov ax,ds:[t1+2];mov ds:[%00],ax")
     END IF
    CASE BundleType%
     IF BundleDef$(BunPtr%(0)) <> "" THEN PutLine ("call __" + LEFT$(bp$(0), LEN(bp$(0)) - 1) + "_release")
     PutLine ("mov si,offset %00;mov cx," + numi$(BunSize%(0)) + ";call _fread")
     IF BundleDef$(BunPtr%(0)) <> "" THEN PutLine ("call __" + LEFT$(bp$(0), LEN(bp$(0)) - 1) + "_2mem")
    CASE StringType%
     IF lastsvar2$ = bp$(0) THEN
      PutLine ("mov si,di")
     ELSE
      PutLine ("mov si,ds:[%00]")
     END IF
     PutLine ("call _fread_str")
    CASE ELSE
     CALL ErrTypeMismatch(0)
   END SELECT
   lastsvar2$ = ""
   EXIT SUB

  CASE &H91A9
  'CASE "farmalloc"
   SELECT CASE bpt%(3)
    CASE IntConst%
     PutLine ("mov bx,*03")
    CASE IntByte%
     PutLine ("mov bl,ds:[%03];xor bh,bh")
    CASE IntWord%, IntDoubleWord%
     PutLine ("mov bx,ds:[%03]")
    CASE ELSE
     CALL ErrTypeMismatch(3)
   END SELECT
   PutLine ("call _farmalloc")
   IF savevar% = TRUE THEN
    IF RIGHT$(bp$(0), 1) = "~" THEN
     SELECT CASE PointerModel%(0)
      CASE Near%
       CALL ReportErr("^ Cannot assign to NEAR pointer", 0, TRUE)
      CASE Far%
       PutLine ("xor ax,ax;mov ds:[%00],ax;mov ds:[%00+2],bx")
       lastivar1$ = "0000"
      CASE Huge%
       PutLine ("xchg bx,ax;call _seg2huge;mov ds:[%00],ax;mov ds:[%00+2],dx")
     END SELECT
    ELSE
     PutLine ("mov ds:[%00],bx")
    END IF
   ELSE
    PutLine ("xchg bx,ax")
   END IF
   EXIT SUB
 
  CASE &H40BB
  'CASE "hugemalloc"
   SELECT CASE bpt%(3)
    CASE IntConst%
     CALL Split4(bp$(3))
     IF vl& = 0 THEN
      PutLine ("xor bx,bx")
     ELSE
      PutLine ("mov bx," + Hex4$(vl&))
     END IF
     IF vh& = 0 THEN
      PutLine ("xor cx,cx")
     ELSE
      PutLine ("mov cx," + Hex4$(vh&))
     END IF
    CASE IntByte%
     PutLine ("mov bl,ds:[%03];xor bh,bh;xor cx,cx")
    CASE IntWord%
     PutLine ("mov bx,ds:[%03];xor cx,cx")
    CASE IntDoubleWord%
     PutLine ("mov bx,ds:[%03];mov cx,ds:[%03+2]")
    CASE ELSE
     CALL ErrTypeMismatch(3)
   END SELECT
   PutLine ("call _hugemalloc")
   IF savevar% = TRUE THEN
    IF RIGHT$(bp$(0), 1) = "~" THEN
     SELECT CASE PointerModel%(0)
      CASE Near%
       CALL ReportErr("^ Cannot assign to NEAR pointer", 0, TRUE)
      CASE Far%
       PutLine ("xor ax,ax;mov ds:[%00],ax;mov ds:[%00+2],bx")
       lastivar1$ = "0000"
      CASE Huge%
       PutLine ("xchg bx,ax;call _seg2huge;mov ds:[%00],ax;mov ds:[%00+2],dx")
     END SELECT
    ELSE
     PutLine ("mov ds:[%00],bx")
    END IF
   ELSE
    PutLine ("xchg bx,ax")
   END IF
   EXIT SUB

  CASE &HCE0E
  'CASE "nearmalloc"
   SELECT CASE bpt%(3)
    CASE IntConst%
     PutLine ("mov bx,*03")
    CASE IntByte%
     PutLine ("mov bl,ds:[%03];xor bh,bh")
    CASE IntWord%, IntDoubleWord%
     PutLine ("mov bx,ds:[%03]")
    CASE ELSE
     CALL ErrTypeMismatch(3)
   END SELECT
   PutLine ("call _mem_alloc")
   IF savevar% = TRUE THEN
    PutLine ("mov ds:[%00],di")
   ELSE
    PutLine ("xchg di,ax")
   END IF
   EXIT SUB

  'CASE "mget"
  CASE &HB463
   SELECT CASE bpt%(3)
    CASE IntConst%
     PutLine ("mov si,*03")
    CASE IntWord%, IntDoubleWord%
     IF lastsvar2$ = bp$(3) THEN
      PutLine ("mov si,di")
      lastsvar2$ = ""
     ELSE
      PutLine ("mov si,ds:[%03]")
     END IF
    CASE ELSE
     CALL ErrTypeMismatch(3)
   END SELECT
   IF bpp% > 3 THEN
    SELECT CASE bpt%(4)
     CASE IntConst%
      PutLine ("mov bx,*04")
     CASE IntWord%, IntDoubleWord%
      PutLine ("mov bx,ds:[%04]")
     CASE ELSE
      CALL ErrTypeMismatch(4)
    END SELECT
   ELSE
    PutLine ("mov bx,ds")
   END IF
   SELECT CASE bpt%(0)
    CASE IntWord%
     IF bpar$(0) = "" THEN
      PutLine ("mov di,offset %00;call _mem_get_2")
     ELSE
      PutLine ("mov di,offset t1;call _mem_get_2;mov ax,ds:[t1];mov ds:[%00],ax")
     END IF
    CASE IntDoubleWord%
     IF bpar$(0) = "" THEN
      PutLine ("mov di,offset %00;call _mem_get_4")
     ELSE
      PutLine ("mov di,offset t1;call _mem_get_4;mov ax,ds:[t1];mov ds:[%00],ax;mov ax,ds:[t1+2];mov ds:[%00+2],ax")
     END IF
    CASE StringType%
     IF lastsvar2$ <> bp$(0) THEN PutLine ("mov di,ds:[%00]")
     PutLine ("mov cx,ds:[di];add di,2;call _mem_get_x")
    CASE BundleType%
     PutLine ("mov di,offset %00;mov cx," + numi$(BunSize%(0)) + ";call _mem_get_x")
    CASE ELSE
     CALL ErrTypeMismatch(0)
   END SELECT
   lastsvar2$ = ""
   EXIT SUB

  CASE &HC2FF
  'CASE "fname"
   PutLine ("mov bx,ds:[%00];call _mem_free")
   SELECT CASE bpt%(3)
    CASE IntConst%
     PutLine ("mov bx,*03")
    CASE IntWord%, IntDoubleWord%
     PutLine ("mov bx,ds:[%03]")
    CASE ELSE
     CALL ErrTypeMismatch(3)
   END SELECT
   PutLine ("call _file_open_name")
   IF savevar% = TRUE THEN
    PutLine ("mov ds:[%00],di")
   ELSE
    PutLine ("xchg di,ax")
   END IF
   lastsvar2$ = ""
   EXIT SUB

  'CASE "crc16"
  CASE &HFA19
   IF lastsvar2$ = bp$(3) THEN
    PutLine ("mov si,di")
   ELSE
    PutLine ("mov si,ds:[%03]")
   END IF
   PutLine ("mov cx,ds:[si];add si,2;call _crc16")
   IF savevar% = TRUE THEN
    PutLine ("mov ds:[%00],bx")
   ELSE
    PutLine ("xchg bx,ax")
   END IF
   lastsvar2$ = ""
   EXIT SUB

  'CASE "fopen"
  CASE &HF8DA
    IF bpt%(3) = StrConst% THEN
     PutLine ("mov si,offset %03;call _str_cs_ds;push si")
    ELSE
     IF lastsvar2$ = bp$(3) THEN
      PutLine ("mov si,di")
     ELSE
      PutLine ("mov si,ds:[%03]")
     END IF
    END IF
    accessmode% = 2 ' read/write
    sharemode% = 0 ' compatibility
    textmode% = FALSE
    IF bpp% > 3 THEN
     FOR z% = 4 TO bpp%
      SELECT CASE LCASE$(bp$(z%))
       CASE "readonly"
        accessmode% = 0
       CASE "writeonly"
        accessmode% = 1
       CASE "readwrite"
        accessmode% = 2
       CASE "compatibility"
        sharemode% = 0
       CASE "denyall"
        sharemode% = &H10
       CASE "denywrite"
        sharemode% = &H20
       CASE "denyread"
        sharemode% = &H30
       CASE "denynone"
        sharemode% = &H40
       CASE "text"
        textmode% = TRUE
       CASE ELSE
        CALL ReportErr("^ Bad open command", bpsp%(z%), TRUE)
      END SELECT
     NEXT
    END IF
    IF sharemode% + accessmode% = 0 THEN
     PutLine ("xor cx,cx")
    ELSE
     PutLine ("mov cx,0" + HEX$(sharemode% + accessmode%) + "h")
    END IF
    PutLine ("call _file_open")
    IF savevar% = TRUE THEN PutLine ("mov ds:[%00],ax"): lastivar1$ = bp$(0)
    IF bpt%(3) = StrConst% THEN PutLine ("pop bx;call _mem_free")
'    IF textmode% = TRUE THEN
'     PutLine ("mov bx,1024;call _mem_alloc;mov bx,ax;shl bx,1;mov word ptr ds:[mr@fbuf+bx],di;mov word ptr ds:[mr@fpos],1024")
'    END IF
    lastsvar2$ = ""
    EXIT SUB

  CASE ELSE
   CALL ReportErr("Compiler error (report to author). Unmatched CRC for keyword: " + bp$(2), 0, FALSE)
  END SELECT

END SUB

