DECLARE SUB EvaluateNum2 (z%, DataType%, bx$, cx$)
DECLARE SUB ErrParm (z%, t$)
DECLARE SUB ProcessLineBPP2 (z%)
DECLARE SUB ReportWarning (E$, indent%, showline%)
DECLARE FUNCTION PointerModel% (bpptr%)
DECLARE SUB SetBPreg (bpr$)
DECLARE FUNCTION PointerType% (bpptr%)
DECLARE FUNCTION PointerSize% (bpptr%)
DECLARE SUB NewSeg (s%, handle%)
DECLARE SUB AddDataRef (v$, s&, handle%)
DECLARE FUNCTION OnOff% (l$)
DECLARE FUNCTION Hex8$ (l&)
DECLARE FUNCTION CVAL& (s$)
DECLARE SUB CheckDS ()
DECLARE SUB ErrMustBeVar (z%)
DECLARE SUB ErrOverflow ()
DECLARE SUB ErrTypeMismatch (z%)
DECLARE SUB EvalNumXorCX (cx$)
DECLARE SUB EvaluateNum (z%, DataType%, bx$, cx$)
DECLARE SUB EvaluateStr (z%)
DECLARE SUB ProcessLine ()
DECLARE SUB PutHandle (z%)
DECLARE SUB Split4 (s$)
DECLARE SUB AddIntVar (tmpv$, s%, bpptr%)
DECLARE SUB AddStringVar (tmpv$, bpptr%)
DECLARE SUB Block (tmp$, addint%)
DECLARE SUB PutLine (l$)
DECLARE SUB ReportErr (E$, indent%, showline%)
DECLARE SUB StringConst (s$, WriteFlag%)
DECLARE SUB WriteFile (l$, h%)
DECLARE SUB GatherPrint (i%)
DECLARE SUB ProcessCommand ()
DECLARE SUB ProcessNum1Func (savevar%)
DECLARE FUNCTION SourceLoad% ALIAS "_sourceload" (BYVAL bufsize%, BYVAL handle%)
DECLARE SUB SetStrPtr ALIAS "_setstrptr" (BYVAL sseg1%, BYVAL sptr1%)
DECLARE FUNCTION GetLine% ALIAS "_getline"

DECLARE FUNCTION Hex2$ (l%)
DECLARE FUNCTION Hex4$ (l&)
DECLARE FUNCTION Evaluate% (z%, DataType%)
DECLARE FUNCTION IntRef$ (n%)

DECLARE FUNCTION numi0$ (tmp%)
DECLARE FUNCTION numi$ (tmp%)
DECLARE FUNCTION MakeVar$ (v$, tt%)
DECLARE FUNCTION numl$ (tmp&)
DECLARE FUNCTION unique% (U$)

DECLARE FUNCTION BunSize% (z%)

'$INCLUDE: 'mr.inc'

SUB EvaluateNum (z%, DataType%, bx$, cx$)
bl$ = LEFT$(bx$, 1) + "l"
cl$ = LEFT$(cx$, 1) + "l"
bh$ = LEFT$(bx$, 1) + "h"
ch$ = LEFT$(cx$, 1) + "h"

TmpStat$ = LCASE$(bp$(z%))
SELECT CASE CRC16%(LCASE$(bp$(z%)))

 CASE &HC68E
  ' "codeptr"
  PutLine ("mov " + bx$ + ",offset __" + bp$(z% + 1))
  z% = z% + 1
  EXIT SUB

 CASE &H642B
 ' "ssin"
  SELECT CASE bpt%(z% + 1)
   CASE IntConst%
    PutLine ("mov " + bx$ + ",*" + numi0$(z% + 1))
   CASE IntByte%
    PutLine ("mov " + bl$ + ",ds:[%" + numi0$(z% + 1) + "];xor " + bh$ + "," + bh$)
   CASE IntWord%, IntDoubleWord%
    PutLine ("mov " + bx$ + ",ds:[%" + numi0$(z% + 1) + "]")
   CASE ELSE
    CALL ErrTypeMismatch(z% + 1)
  END SELECT
  IF bx$ = "ax" THEN PutLine ("call _ssin") ELSE PutLine ("call _ssinbx")
  IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
  z% = z% + 1
  EXIT SUB

 CASE &H4E72
 ' "scos"
  SELECT CASE bpt%(z% + 1)
   CASE IntConst%
    PutLine ("mov " + bx$ + ",*" + numi0$(z% + 1))
   CASE IntByte%
    PutLine ("mov " + bl$ + ",ds:[%" + numi0$(z% + 1) + "];xor " + bh$ + "," + bh$)
   CASE IntWord%, IntDoubleWord%
    PutLine ("mov " + bx$ + ",ds:[%" + numi0$(z% + 1) + "]")
   CASE ELSE
    CALL ErrTypeMismatch(z% + 1)
  END SELECT
  IF bx$ = "ax" THEN PutLine ("call _scos") ELSE PutLine ("call _scosbx")
  IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
  z% = z% + 1
  EXIT SUB

 CASE &H8FE7
 ' "abs"
  SELECT CASE bpt%(z% + 1)
   CASE IntWord%
    LocVarCount% = LocVarCount% + 1
    PutLine ("mov " + bx$ + ",ds:[%" + numi0$(z% + 1) + "]")
    PutLine ("test " + bx$ + ",8000h;jz LL" + numi$(LocVarCount%) + ";neg " + bx$)
    PutLine ("LL" + numi$(LocVarCount%) + ":")
    IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
   CASE IntDoubleWord%
    LocVarCount% = LocVarCount% + 1
    PutLine ("mov " + bx$ + ",ds:[%" + numi0$(z% + 1) + "]")
    PutLine ("mov " + cx$ + ",ds:[%" + numi0$(z% + 1) + "+2]")
    PutLine ("test " + bx$ + ",8000h;jz LL" + numi$(LocVarCount%) + ";not " + cx$)
    PutLine ("neg " + bx$ + ";sbb " + cx$ + ",-1")
    PutLine ("LL" + numi$(LocVarCount%) + ":")
  END SELECT
  z% = z% + 1
  EXIT SUB

 CASE &H658A
 ' "getgraphseg"
  PutLine ("mov " + bx$ + ",word ptr ss:[mr@graph_seg]")
  EXIT SUB

 CASE &H3DB2
 ' "getscreenseg"
  PutLine ("mov " + bx$ + ",word ptr ss:[mr@screen_seg]")
  EXIT SUB

 CASE &HEE0C
 ' "mod"
' IF bx$ = "bx" THEN PutLine ("xchg ax,bx;xchg dx,cx")
 SELECT CASE bpt%(z% + 1)
  CASE IntConst%
   PutLine ("mov bx,*" + numi0$(z% + 1))
  CASE IntByte%
   PutLine ("mov bx,ds:[%" + numi0$(z% + 1) + "];xor bh,bh")
  CASE IntWord%
   PutLine ("mov bx,ds:[%" + numi0$(z% + 1) + "]")
  CASE IntDoubleWord%
   CALL ReportErr("^ not supported", bpsp%(z% + 1), TRUE)
  CASE ELSE
   CALL ErrTypeMismatch(z% + 1)
 END SELECT
 PutLine ("cwd;idiv bx;mov ax,dx")
 IF DataType% = IntDoubleWord% THEN PutLine ("cwd")
' IF bx$ = "bx" THEN PutLine ("xchg ax,bx;xchg dx,cx")
 z% = z% + 1
 EXIT SUB


 CASE &H9E8D
 ' "sgn"
 SELECT CASE bpt%(z% + 1)
  CASE IntByte%
   PutLine ("mov " + bl$ + ",ds:[%" + numi0$(z% + 1) + "];xor " + bh$ + "," + bh$)
  CASE IntWord%
   PutLine ("mov " + bx$ + ",ds:[%" + numi0$(z% + 1) + "]")
  CASE ELSE
   CALL ErrTypeMismatch(z% + 1)
 END SELECT
 IF bx$ = "ax" THEN
  PutLine ("call _sgn16ax")
 ELSE
  PutLine ("call _sgn16bx")
 END IF
 z% = z% + 1
 EXIT SUB

 CASE &H96AD
 ' "varptr"
 t% = z% + 1
 IF bpart%(t%) <> 0 AND bpart%(t%) <> IntConst% THEN
  t$ = MakeVar$(bp$(t%), bpart%(t%))
  PutLine ("mov " + bx$ + ",offset a" + t$)
  SELECT CASE bpart%(t%)
   CASE IntByte%
    t$ = "byte ptr ds:[" + MakeVar$(bpar$(t%), bpart%(t%)) + "]"
   CASE IntWord%, IntDoubleWord%
    t$ = "word ptr ds:[" + MakeVar$(bpar$(t%), bpart%(t%)) + "]"
   CASE ELSE
    CALL ErrTypeMismatch(t%)
  END SELECT
  SELECT CASE bpt%(t%)
   CASE IntByte%
   PutLine ("add " + bx$ + "," + t$)
   CASE IntWord%
    PutLine ("mov " + bpreg$ + "," + t$ + ";add " + bpreg$ + "," + bpreg$)
    PutLine ("add " + bx$ + "," + bpreg$)
   CASE IntDoubleWord%
    PutLine ("mov " + bpreg$ + "," + t$ + ";add " + bpreg$ + "," + bpreg$ + ";add " + bpreg$ + "," + bpreg$)
    PutLine ("add " + bx$ + "," + bpreg$)
  END SELECT
 ELSE
  PutLine ("mov " + bx$ + ",offset %" + numi0$(t%))
 END IF
 z% = z% + 1
 EXIT SUB

 CASE &HF2A1
 ' "strptr"

 IF (bpt%(z% + 1) <> StringType%) AND (RIGHT$(bp$(z% + 1), 1) <> "~") THEN CALL ErrTypeMismatch(z% + 1)
 PutLine ("mov " + bx$ + ",ds:[%" + numi0$(z% + 1) + "]")
 z% = z% + 1
 EXIT SUB

 CASE &H68F4
 ' "neg"
 SELECT CASE DataType%
  CASE IntByte%
   PutLine ("mov " + bl$ + ",ds:[%" + numi0$(z% + 1) + "];xor " + bl$ + "," + bl$ + ";neg " + bx$)
   IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
  CASE IntWord%
   PutLine ("mov " + bx$ + ",ds:[%" + numi0$(z% + 1) + "];neg " + bx$)
   IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
  CASE IntDoubleWord%
   PutLine ("mov " + bx$ + ",ds:[%" + numi0$(z% + 1) + "]")
   IF bpt%(z% + 1) = IntDoubleWord% THEN
    PutLine ("mov " + cx$ + ",ds:[%" + numi0$(z% + 1) + "+2]")
   ELSE
    CALL EvalNumXorCX(cx$)
   END IF
   PutLine ("not " + cx$ + ";neg " + bx$ + ";sbb " + cx$ + ",-1")
 END SELECT
 z% = z% + 1
 EXIT SUB

' CASE &HF3A6
' ' "mgetbyte"
'  IF bx$ = "ax" THEN PutLine ("xchg ax,bx")
'  SELECT CASE bpt%(z% + 1)
'   CASE IntWord%, IntDoubleWord%
'    PutLine ("mov bx,ds:[%" + numi0$(z% + 1) + "];mov bl,byte ptr ds:[bx]")
'   CASE IntConst%
'    PutLine ("mov bl,byte ptr ds:[*" + numi0$(z% + 1) + "]")
'   CASE ELSE
'    ErrTypeMismatch (z% + 1)
'  END SELECT
'  PutLine ("xor bh,bh")
'  IF bx$ = "ax" THEN PutLine ("xchg ax,bx")
'  IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
'  EXIT SUB

' CASE &H1F00
' ' "mgetword"
'  IF bx$ = "ax" THEN PutLine ("xchg ax,bx")
'  SELECT CASE bpt%(z% + 1)
'   CASE IntWord%, IntDoubleWord%
'    PutLine ("mov bx,ds:[%" + numi0$(z% + 1) + "];mov bx,ds:[bx]")
'   CASE IntConst%
'    PutLine ("mov bx,ds:[*" + numi0$(z% + 1) + "]")
'   CASE ELSE
'    ErrTypeMismatch (z% + 1)
'  END SELECT
'  IF bx$ = "ax" THEN PutLine ("xchg ax,bx")
'  IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
'  EXIT SUB
'
' CASE &H13F7
' ' "mgetdword"
'  IF bx$ = "ax" THEN PutLine ("xchg ax,bx;xchg dx,cx")
'  SELECT CASE bpt%(z% + 1)
'   CASE IntWord%, IntDoubleWord%
'    PutLine ("mov bx,ds:[%" + numi0$(z% + 1) + "];mov cx,ds:[bx+2];mov bx,ds:[bx]")
'   CASE IntConst%
'    PutLine ("mov bx,ds:[*" + numi0$(z% + 1) + "];mov cx,ds:[*" + numi0$(z% + 1) + "+2]")
'   CASE ELSE
'    ErrTypeMismatch (z% + 1)
'  END SELECT
'  IF bx$ = "ax" THEN PutLine ("xchg ax,bx;xchg dx,cx")
'  EXIT SUB
'
' CASE &H751C
' ' "mgetbytef"
'  IF bx$ = "ax" THEN PutLine ("xchg ax,bx")
'  IF LastValES$ <> "" THEN PutLine ("push es")
'  SELECT CASE bpt%(z% + 1)
'   CASE IntWord%, IntDoubleWord%
'    PutLine ("mov es,ds:[%" + numi0$(z% + 1) + "]")
'   CASE IntConst%
'    PutLine ("mov " + bx$ + ",ds:[*" + numi0$(z% + 1) + "];mov es," + bx$)
'   CASE ELSE
'    ErrTypeMismatch (z% + 1)
'  END SELECT
'  SELECT CASE bpt%(z% + 2)
'   CASE IntWord%, IntDoubleWord%
'    PutLine ("mov bx,ds:[%" + numi0$(z% + 2) + "];mov bl,byte ptr es:[bx]")
'   CASE IntConst%
'    PutLine ("mov bl,byte ptr ds:[*" + numi0$(z% + 2) + "]")
'   CASE ELSE
'    ErrTypeMismatch (z% + 2)
'  END SELECT
'  PutLine ("xor bh,bh")
'  IF bx$ = "ax" THEN PutLine ("xchg ax,bx")
'  IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
'  IF LastValES$ <> "" THEN PutLine ("pop es")
'  EXIT SUB

' CASE &HEFBE
' ' "mgetword"
'  IF bx$ = "ax" THEN PutLine ("xchg ax,bx")
'  IF LastValES$ <> "" THEN PutLine ("push es")
'  SELECT CASE bpt%(z% + 1)
'   CASE IntWord%, IntDoubleWord%
'    PutLine ("mov es,ds:[%" + numi0$(z% + 1) + "]")
'   CASE IntConst%
'    PutLine ("mov " + bx$ + ",ds:[*" + numi0$(z% + 1) + "];mov es," + bx$)
'   CASE ELSE
'    ErrTypeMismatch (z% + 1)
'  END SELECT
'  SELECT CASE bpt%(z% + 2)
'   CASE IntWord%, IntDoubleWord%
'    PutLine ("mov bx,ds:[%" + numi0$(z% + 2) + "];mov bx,ds:[bx]")
'   CASE IntConst%
'    PutLine ("mov bx,ds:[*" + numi0$(z% + 2) + "]")
'   CASE ELSE
'    ErrTypeMismatch (z% + 2)
 ' END SELECT
 ' IF bx$ = "ax" THEN PutLine ("xchg ax,bx")
'  IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
'  IF LastValES$ <> "" THEN PutLine ("pop es")
'  EXIT SUB

' CASE &HD932
' ' "mgetdword"
'  IF bx$ = "ax" THEN PutLine ("xchg ax,bx;xchg dx,cx")
'  IF LastValES$ <> "" THEN PutLine ("push es")
'  SELECT CASE bpt%(z% + 1)
'   CASE IntWord%, IntDoubleWord%
'    PutLine ("mov es,ds:[%" + numi0$(z% + 1) + "]")
'   CASE IntConst%
'    PutLine ("mov " + bx$ + ",ds:[*" + numi0$(z% + 1) + "];mov es," + bx$)
'   CASE ELSE
'    ErrTypeMismatch (z% + 1)
'  END SELECT
'  SELECT CASE bpt%(z% + 2)
'   CASE IntWord%, IntDoubleWord%
'    PutLine ("mov bx,ds:[%" + numi0$(z% + 2) + "];mov cx,ds:[bx+2];mov bx,ds:[bx]")
'   CASE IntConst%
'    PutLine ("mov bx,ds:[*" + numi0$(z% + 2) + "];mov cx,ds:[*" + numi0$(z% + 1) + "+2]")
'   CASE ELSE
'    ErrTypeMismatch (z% + 2)
'  END SELECT
'  IF bx$ = "ax" THEN PutLine ("xchg ax,bx;xchg dx,cx")
'  IF LastValES$ <> "" THEN PutLine ("pop es")
'  EXIT SUB

 CASE &HBC40
 ' "doserr"
 PutLine ("mov " + bx$ + ",word ptr ss:[_errcode]")
 IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
 EXIT SUB

 CASE &H2E55
 ' "is386"
 IF bx$ = "bx" THEN PutLine ("xchg ax,bx")
 PutLine ("call _is386")
 IF bx$ = "bx" THEN PutLine ("xchg ax,bx")
 IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
 EXIT SUB

 CASE &HED08
 ' "codeseg"
 PutLine ("mov " + bx$ + ",cs")
 IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
 EXIT SUB

 CASE &HBA44
 ' "dataseg"
 PutLine ("mov " + bx$ + ",ds")
 IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
 EXIT SUB

 CASE &H44D2
 ' "scrlen"
 IF bx$ = "bx" THEN
  PutLine ("xor bx,bx;mov bl,byte ptr ss:[mr@screen_length]")
 ELSE
  PutLine ("xor ax,ax;mov al,byte ptr ss:[mr@screen_length]")
 END IF
 IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
 EXIT SUB

 CASE &H741
 ' "rand"
 IF bx$ = "bx" THEN PutLine ("push ax")
 SELECT CASE bpt%(z% + 1)
  CASE IntByte%
  PutLine ("mov al,byte ptr ds:" + numi0$(z% + 1) + "];cbw")
  CASE IntWord%, IntDoubleWord%
   PutLine ("mov ax,ds:[%" + numi0$(z% + 1) + "]")
  CASE IntConst%
   PutLine ("mov ax,*" + numi0$(z% + 1))
 END SELECT
 PutLine ("call _rand")
 IF bx$ = "bx" THEN PutLine ("xchg ax,bx;pop ax")
 IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
 z% = z% + 1
 EXIT SUB

 CASE &HFF99
 ' "val"
 PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "]")
 IF bx$ = "bx" THEN
  PutLine ("call _ival_bx")
 ELSE
  PutLine ("call _ival")
 END IF
 IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
 z% = z% + 1
 EXIT SUB

'  CASE &HDA44
'  ' "sinstr"
 '  IF bx$ = "bx" THEN PutLine ("xchg ax,bx")
 '
 '  SELECT CASE bpt%(z% + 1)
 '   CASE StrConst%
 '    PutLine ("mov si,offset %" + numi0$(z% + 1) + ";call _str_cs_ds_mark")
'    CASE StringType%
'     IF lastsvar2$ = bp$(z% + 1) THEN
'      PutLine ("mov si,di")
'     ELSE
'      PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "]")
'     END IF
'   END SELECT
'   SELECT CASE bpt%(z% + 2)
'    CASE StrConst%
'     PutLine ("push si;mov si,offset %" + numi0$(z% + 2) + ";call _str_cs_ds_mark;mov di,si;pop si")
'    CASE StringType%
'     IF lastsvar2$ <> bp$(z% + 2) THEN PutLine ("mov di,ds:[%" + numi0$(z% + 2) + "]")
'   END SELECT
'   PutLine ("call _sinstr")
'   IF bpt%(z% + 1) = StrConst% OR bpt%(z% + 2) = StrConst% THEN PutLine ("call _str_release")
'   lastsvar2$ = ""
'   IF bx$ = "bx" THEN PutLine ("xchg ax,bx")
'   IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
'   z% = z% + 2
'   EXIT SUB
 
  CASE &HE9F6
  'CASE "flen"
   IF bx$ = "bx" THEN PutLine ("xchg ax,bx;xchg dx,cx")
   CALL PutHandle(z% + 1)
   PutLine ("call _file_length")
   IF bx$ = "bx" THEN PutLine ("xchg bx,ax;xchg cx,dx")
   z% = z% + 1
   EXIT SUB

 CASE &HAD94
 ' "asc"
 IF bpt%(z% + 1) = IntConst% THEN
  PutLine ("mov " + bx$ + "," + numl$(CVAL(bp$(z% + 1))))
 ELSE
  PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "];mov " + bx$ + ",ds:[si+2];mov " + LEFT$(bx$, 1) + "h,0")
 END IF
 z% = z% + 1
 EXIT SUB

 CASE &HF9E9
 ' "sbyte"

  IF bpt%(z% + 2) = IntConst% THEN
   PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "];mov " + bx$ + ",ds:[si+" + numl$(CVAL(bp$(z% + 2))) + "+1];mov " + LEFT$(bx$, 1) + "h,0")
  ELSE
   IF bx$ = "bx" THEN
    PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "];mov bx,ds:[%" + numi0$(z% + 2) + "];mov bx,ds:[si+bx+1];xor bh,bh")
   ELSE
    PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "];add si,ds:[%" + numi0$(z% + 2) + "];mov ax,ds:[si+1];xor ah,ah")
   END IF
  END IF
  IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
  z% = z% + 2
  EXIT SUB

 CASE &H154F
 ' "sword"
  IF bpt%(z% + 2) = IntConst% THEN
   PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "];mov " + bx$ + ",ds:[si+" + numl$(CVAL(bp$(z% + 2))) + "+1]")
  ELSE
   IF bx$ = "bx" THEN
    PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "];mov bx,ds:[%" + numi0$(z% + 2) + "];mov bx,ds:[si+bx+1]")
   ELSE
    PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "];add si,ds:[%" + numi0$(z% + 2) + "];mov ax,ds:[si+1]")
   END IF
  END IF
  IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
  z% = z% + 2
  EXIT SUB

 CASE &HFDBD
 ' "sdword"
  IF bpt%(z% + 2) = IntConst% THEN
   PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "];mov " + bx$ + ",ds:[si+" + numl$(CVAL(bp$(z% + 2))) + "+1];mov " + cx$ + ",ds:[si+" + numl$(CVAL(bp$(z% + 2))) + "+3]")
  ELSE
   IF bx$ = "bx" THEN
    PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "];mov bx,ds:[%" + numi0$(z% + 2) + "];mov bx,ds:[si+bx+1];mov cx,ds:[si+bx+3]")
   ELSE
    PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "];add si,ds:[%" + numi0$(z% + 2) + "];mov ax,ds:[si+1];mov dx,ds:[si+3];pop bx")
   END IF
  END IF
  z% = z% + 2
  EXIT SUB

 CASE &HF143
 'CASE "timertick"
  hiprecision% = IntDoubleWord%
  IF cx$ = "cx" THEN PutLine ("push ax;push dx")
  PutLine ("xor ah,ah;int 1ah")
  IF bx$ = "bx" THEN
   PutLine ("mov bx,dx;pop dx;pop ax")
  ELSE
   PutLine ("mov ax,dx;mov dx,cx")
  END IF
  EXIT SUB

 CASE &H97BD
 'CASE "len"
  PutLine ("mov bx,ds:[%" + numi0$(z% + 1) + "]")
  PutLine ("mov " + bx$ + ",ds:[bx]")
  IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
  z% = z% + 1
  EXIT SUB

 'CASE "inkey"
 CASE &H3AD3
  PutLine ("call _inkey")
  IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
  EXIT SUB

 'CASE "freemem"
 CASE &H9311
  SELECT CASE bp$(z% + 1)
   CASE "0"
    PutLine ("call _mem_usage_total_" + bx$)
    IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
   CASE "1"
    PutLine ("call _mem_usage_largest_" + bx$)
    IF DataType% = IntDoubleWord% THEN CALL EvalNumXorCX(cx$)
   CASE "2"
    PutLine ("call _far_mem_usage_" + bx$)
  END SELECT
  z% = z% + 1
  EXIT SUB

 'CASE "and"
 CASE &HA85C
  SELECT CASE bpt%(z% + 1)
   CASE IntConst%
    PutLine ("and ax,*" + numi0$(z% + 1))
   CASE IntByte%
    PutLine ("and al,ds:[%" + numi0$(z% + 1) + "]")
   CASE IntWord%
    PutLine ("and ax,ds:[%" + numi0$(z% + 1) + "]")
   CASE IntDoubleWord%
    PutLine ("and ax,ds:[%" + numi0$(z% + 1) + "];and dx,ds:[%" + numi0$(z% + 1) + "+2]")
   CASE ELSE
    CALL ErrTypeMismatch(z% + 1)
  END SELECT
  z% = z% + 1
  EXIT SUB

 'CASE "or"
 CASE &H45C1
  SELECT CASE bpt%(z% + 1)
   CASE IntConst%
    PutLine ("or ax,*" + numi0$(z% + 1))
   CASE IntByte%
    PutLine ("or al,ds:[%" + numi0$(z% + 1) + "]")
   CASE IntWord%
    PutLine ("or ax,ds:[%" + numi0$(z% + 1) + "]")
   CASE IntDoubleWord%
    PutLine ("or ax,ds:[%" + numi0$(z% + 1) + "];or dx,ds:[%" + numi0$(z% + 1) + "+2]")
   CASE ELSE
    CALL ErrTypeMismatch(z% + 1)
  END SELECT
  z% = z% + 1
  EXIT SUB

 'CASE "xor"
 CASE &H3468
  SELECT CASE bpt%(z% + 1)
   CASE IntConst%
    PutLine ("xor ax,*" + numi0$(z% + 1))
   CASE IntByte%
    PutLine ("xor al,ds:[%" + numi0$(z% + 1) + "]")
   CASE IntWord%
    PutLine ("xor ax,ds:[%" + numi0$(z% + 1) + "]")
   CASE IntDoubleWord%
    PutLine ("xor ax,ds:[%" + numi0$(z% + 1) + "];xor dx,ds:[%" + numi0$(z% + 1) + "+2]")
   CASE ELSE
    CALL ErrTypeMismatch(z% + 1)
  END SELECT
  z% = z% + 1
  EXIT SUB

 'CASE "shl"
 CASE &HAEF1
 SELECT CASE hiprecision%
  CASE IntWord%
   SELECT CASE bpt%(z% + 1)
    CASE IntConst%
     IF bp$(z% + 1) = "1" THEN
      PutLine ("shl ax,1")
     ELSE
      IF Processor% >= 186 THEN
       PutLine ("shl ax,*" + numi0$(z% + 1))
      ELSE
       PutLine ("mov cl,*" + numi0$(z% + 1) + ";shl ax,cl")
      END IF
     END IF
    CASE IntByte%, IntWord%
     PutLine ("mov cl,byte ptr ds:[%" + numi0$(z% + 1) + "];shl ax,cl")
    CASE ELSE
     CALL ErrTypeMismatch(z% + 1)
   END SELECT
   z% = z% + 1
  CASE IntDoubleWord%
   SELECT CASE bpt%(z% + 1)
    CASE IntConst%
     SELECT CASE bp$(z% + 1)
      CASE "1"
       PutLine ("shl ax,1;rcl dx,1")
      CASE "16"
       PutLine ("xchg dx,ax;xor ax,ax")
      CASE ELSE
      LocVarCount% = LocVarCount% + 1
      PutLine ("mov cx,*" + numi0$(z% + 1) + ";LL" + numi$(LocVarCount%) + ":;shl ax,1;rcl dx,1;loop short LL" + numi$(LocVarCount%))
      END SELECT
    CASE IntWord%
     LocVarCount% = LocVarCount% + 1
     PutLine ("mov cx,ds:[%" + numi0$(z% + 1) + "];LL" + numi$(LocVarCount%) + ":;shl ax,1;rcl dx,1;loop short LL" + numi$(LocalVarCount%))
    CASE IntByte%
     LocVarCount% = LocVarCount% + 1
     PutLine ("mov cl,ds:[%" + numi0$(z% + 1) + "];xor ch,ch;LL" + numi$(LocVarCount%) + ":;shl ax,1;rcl dx,1;loop short LL" + numi$(LocalVarCount%))
    CASE ELSE
     CALL ErrTypeMismatch(z% + 1)
   END SELECT
   z% = z% + 1
  CASE ELSE
   CALL ErrTypeMismatch(0)
  END SELECT
  EXIT SUB

 'CASE "shr"
 CASE &H5D0E
 SELECT CASE hiprecision%
  CASE IntWord%
   SELECT CASE bpt%(z% + 1)
    CASE IntConst%
     IF bp$(z% + 1) = "1" THEN
      PutLine ("shr ax,1")
     ELSE
      IF Processor% >= 186 THEN
       PutLine ("shr ax,*" + numi0$(z% + 1))
      ELSE
       PutLine ("mov cl,*" + numi0$(z% + 1) + ";shr ax,cl")
      END IF
     END IF
    CASE IntByte%, IntWord%
     PutLine ("mov cl,byte ptr ds:[%" + numi0$(z% + 1) + "];shr ax,cl")
    CASE ELSE
     CALL ErrTypeMismatch(z% + 1)
   END SELECT
   z% = z% + 1

  CASE IntDoubleWord%
   SELECT CASE bpt%(z% + 1)
    CASE IntConst%
     SELECT CASE bp$(z% + 1)
      CASE "1"
       PutLine ("shr dx,1;rcr ax,1")
      CASE "16"
       PutLine ("xchg dx,ax;xor dx,dx")
      CASE ELSE
      LocVarCount% = LocVarCount% + 1
      PutLine ("mov cx,*" + numi0$(z% + 1) + ";LL" + numi$(LocVarCount%) + ":;shr dx,1;rcr ax,1;loop short LL" + numi$(LocVarCount%))
      END SELECT
    CASE IntWord%
     LocVarCount% = LocVarCount% + 1
     PutLine ("mov cx,ds:[%" + numi0$(z% + 1) + "];LL" + numi$(LocVarCount%) + ":;shr dx,1;rcr ax,1;loop short LL" + numi$(LocVarCount%))
    CASE IntByte%
     LocVarCount% = LocVarCount% + 1
     PutLine ("mov cl,ds:[%" + numi0$(z% + 1) + "];xor ch,ch;LL" + numi$(LocVarCount%) + ":;shr dx,1;rcr ax,1;loop short LL" + numi$(LocVarCount%))
    CASE ELSE
     CALL ErrTypeMismatch(z% + 1)
   END SELECT
   z% = z% + 1
  CASE ELSE
   CALL ErrTypeMismatch(0)
  END SELECT
  EXIT SUB
CASE ELSE
  CALL EvaluateNum2(z%, DataType%, bx$, cx$)
END SELECT
END SUB

SUB EvaluateNum2 (z%, DataType%, bx$, cx$)
IF INSTR(InternalNFunc$, " " + bp$(z%) + ":") <> 0 THEN
  lastivar2$ = ""
  lastivar1$ = ""

  lastsvar2$ = ""
  lastsvar1$ = ""

  funcname$ = bp$(z%)

  isptr% = INSTR(InternalNFunc$, " " + funcname$ + ":") + LEN(funcname$) + 2

  sp$ = MID$(InternalNFunc$, isptr%)
  sp$ = LEFT$(sp$, INSTR(sp$, " ") - 1)
  SELECT CASE RIGHT$(sp$, 1)
   CASE "%"
    rettype% = IntWord%
   CASE "&"
    rettype% = IntDoubleWord%
   CASE ELSE
    rettype% = IntWord%
  END SELECT
  sp$ = LEFT$(sp$, LEN(sp$) - 2)

  IF bx$ = "bx" THEN PutLine ("xchg ax,bx")

  callmark% = FALSE

  lastax$ = ""

  spp% = 1
  pc% = 0  ' parameter count
  z% = z% + 1
  WHILE pc% < LEN(sp$)
'  FOR z% = 1 TO bpp%
   pc% = pc% + 1
   t$ = MID$(sp$, spp%, 1)
   spp% = spp% + 1
'   PRINT z%; " "; bp$(z%); " "; pc%; " "; LEN(sp$)
   SELECT CASE bpt%(z%)
    CASE IntConst%
     SELECT CASE t$
      CASE "%", "@"
       IF Processor% >= 186 THEN
        PutLine ("push *" + numi0$(z%))
       ELSE
        IF lastax$ = bp$(z%) THEN
         PutLine ("push ax")
        ELSE
         IF (lastax$ = "-1" AND bp$(z%) = "0") OR lastax$ = "0" AND bp$(z%) = "-1" THEN
          PutLine ("not ax")
         ELSE
          IF bp$(z%) = "0" THEN
           PutLine ("xor ax,ax")
          ELSE
           PutLine ("mov ax,*" + numi0$(z%))
          END IF
         END IF
         PutLine ("push ax")
         lastax$ = bp$(z%)
        END IF
       END IF
      CASE "&"
       Split4 (bp$(z%))
       IF Processor% >= 186 THEN
        PutLine ("push " + Hex4$(vl&))
        PutLine ("push " + Hex4$(vh&))
       ELSE
        IF lastax$ = numl$(vl&) THEN
         PutLine ("push ax")
        ELSE
         IF vl& = 0 THEN
          PutLine ("xor ax,ax")
         ELSE
          PutLine ("mov ax," + Hex4$(vl&))
         END IF
         PutLine ("push ax")
         lastax$ = numl$(vl&)
        END IF
        IF vh& <> vl& THEN
         IF vh& = 0 THEN
          PutLine ("xor ax,ax")
         ELSE
          PutLine ("mov ax," + Hex4$(vh&))
         END IF
         lastax$ = numl$(vh&)
        END IF
        PutLine ("push ax")
       END IF
      CASE ELSE
       CALL ErrParm(z%, t$)
     END SELECT
    CASE IntByte%
     IF t$ <> "@" AND t$ <> "%" AND t$ <> "&" THEN CALL ErrParm(z%, t$)
     PutLine ("mov bl,ds:[%" + numi0$(z%) + "];xor bh,bh;push bx")
    CASE IntWord%
     IF t$ <> "%" AND t$ <> "&" THEN CALL ErrParm(z%, t$)
     PutLine ("push word ptr ds:[%" + numi0$(z%) + "]")
    CASE StringType%
     IF t$ <> "$" THEN CALL ErrParm(z%, t$)
     IF bp$(z%) = "mr@null$" THEN
      IF lastax$ <> "0" THEN
       PutLine ("xor ax,ax")
       lastax$ = "0"
      END IF
      PutLine ("push ax")
     ELSE
      PutLine ("push word ptr ds:[%" + numi0$(z%) + "]")
     END IF
    CASE StrFunc%
     IF t$ <> "$" THEN CALL ErrParm(z%, t$)
     CALL EvaluateStr(z%)
     PutLine ("call _str_mark_di;push di")
     callmark% = TRUE
    CASE NumFunc%
     IF t$ = "&" THEN
      PutLine ("xor dx,dx")
      CALL EvaluateNum(z%, IntDoubleWord%, "ax", "dx")
      PutLine ("push ax;push dx")
     ELSE
      CALL EvaluateNum(z%, IntWord%, "ax", "dx")
      PutLine ("push ax")
     END IF
    CASE IntDoubleWord%
     SELECT CASE t$
      CASE "@"
       PutLine ("mov al,byte ptr ds:[%" + numi0$(z%) + "];xor ah,ah;push ax")
      CASE "%"
       PutLine ("push word ptr ds:[%" + numi0$(z%) + "]")
      CASE "&"
       IF Processor% >= 386 THEN
        PutLine ("push dword ptr ds:[%" + numi0$(z%) + "]")
       ELSE
        PutLine ("push word ptr ds:[%" + numi0$(z%) + "];push word ptr ds:[%" + numi0$(z%) + "+2]")
       END IF
     END SELECT
    CASE StrConst%
     IF t$ <> "$" THEN CALL ErrParm(z%, t$)
     PutLine ("mov si,offset %" + numi0$(z%) + ";call _str_cs_ds_mark;push si")
     callmark% = TRUE
    CASE ELSE
     CALL ErrTypeMismatch(z%)
   END SELECT
  z% = z% + 1
  WEND
  'NEXT

 'IF LEN(sp$) <> pc% THEN CALL ReportWarning("^ Argument count mismatch", bpsp%(bpp%) + LEN(bp$(bpp%)), TRUE)
 PutLine ("call _" + LCASE$(funcname$))
 IF callmark% = TRUE THEN PutLine ("call _str_release")
 BPval$ = ""
 LastValES$ = ""
 IF bx$ = "bx" THEN PutLine ("xchg ax,bx")
 IF DataType% = IntDoubleWord% AND rettype% <> IntDoubleWord% THEN CALL EvalNumXorCX(cx$)

 EXIT SUB
ELSE

 CALL ReportErr("Compiler error (report to author). Unmatched CRC for keyword: " + bp$(z%), 0, FALSE)
END IF

END SUB

SUB EvaluateStr (z%)

TmpStat$ = LCASE$(bp$(z%))
SELECT CASE CRC16%(LCASE$(bp$(z%)))

 CASE &H63B9
 ' "getenv"
 IF bpt%(z% + 1) = StrConst% THEN
  PutLine ("mov si,offset %" + numi0$(z% + 1) + ";call _str_cs_ds;push si")
 ELSE
  PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "]")
 END IF
 PutLine ("call _getenviron")
 IF bpt%(z% + 1) = StrConst% THEN PutLine ("pop bx;call _mem_free")
 z% = z% + 1
 EXIT SUB

 CASE &H63BC
 ' "mypath"
 PutLine ("call _mypath")
 EXIT SUB

 CASE &HDE1E
 ' "fosinit"
  SELECT CASE bpt%(z% + 1)
   CASE IntConst%
    PutLine ("mov ax,*" + numi0$(z% + 1) + ";call _fos_init")
   CASE IntByte%
    PutLine ("mov al,byte ptr ds:[%" + numi0$(z% + 1) + "];xor ah,ah;call _fos_init")
   CASE IntWord%, IntDoubleWord%
    PutLine ("mov ax,ds:[%" + numi0$(z% + 1) + "];call _fos_init")
   CASE ELSE
    ErrTypeMismatch (z% + 1)
  END SELECT
  lastsvar2$ = ""
  z% = z% + 1
  EXIT SUB

 CASE &H1E6D
 ' "chr"
  PutLine ("mov bx,3;call _mem_alloc;mov word ptr ds:[di], 1")
  SELECT CASE bpt%(z% + 1)
   CASE IntConst%
    PutLine ("mov byte ptr ds:[di+2],*" + numi0$(z% + 1))
   CASE IntByte%, IntWord, IntDoubleWord%
    PutLine ("mov bl,byte ptr ds:[%" + numi0$(z% + 1) + "];mov ds:[di+2],bl")
  END SELECT
  z% = z% + 1
  EXIT SUB

 CASE &HD3FE
 ' "ftruename"
  PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "];call _file_truename")
  z% = z% + 1
  EXIT SUB

 CASE &H2B1D
 'CASE "null"
  SELECT CASE bpt%(z% + 1)
   CASE IntConst%
    PutLine ("mov cx,*" + numi0$(z% + 1))
   CASE IntByte%
    PutLine ("mov cl,ds:[%" + numi0$(z% + 1) + "];xor ch,ch")
   CASE IntWord, IntDoubleWord%
    PutLine ("mov cx,ds:[%" + numi0$(z% + 1) + "]")
   CASE ELSE
    CALL ErrTypeMismatch(z% + 1)
  END SELECT
  PutLine ("call _str_null")
  z% = z% + 1
  lastsvar2$ = ""
  EXIT SUB
  
   CASE &H5BA
   'CASE "findfirst"
    IF bpt%(z% + 1) = StrConst% THEN
     PutLine ("mov si,offset %" + numi0$(z% + 1) + ";call _str_cs_ds;push si")
    ELSE
     PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "]")
    END IF
    SELECT CASE bpt%(z% + 2)
     CASE IntConst%
      PutLine ("mov cx,*" + numi0$(z% + 2))
     CASE IntByte%
      PutLine ("mov cl,ds:[%" + numi0$(z% + 2) + "];xor ch,ch")
     CASE IntWord%, IntDoubleWord%
      PutLine ("mov cx,ds:[%" + numi0$(z% + 2) + "]")
     CASE ELSE
      CALL ErrTypeMismatch(z% + 2)
    END SELECT
    PutLine ("call _find_first")
    IF bpt%(z% + 1) = StrConst% THEN PutLine ("pop bx;call _mem_free")
    lastsvar2$ = ""
    EXIT SUB

   CASE &HEE34
   'CASE "findnext"
    PutLine ("call _find_next")
    lastsvar2$ = ""
    EXIT SUB
 
 
  'CASE "cmdline"
  CASE &HED25
   PutLine ("call _cmdline")
   lastsvar2$ = ""
   EXIT SUB

 CASE &HC7E6
 ' date
  PutLine ("call _get_date")
  lastsvar2$ = ""
  EXIT SUB

 CASE &H900E
 ' day
  PutLine ("call _get_day")
  lastsvar2$ = ""
  EXIT SUB

 CASE &HCC0B
 ' time
  PutLine ("call _get_time")
  lastsvar2$ = ""
  EXIT SUB

 CASE &H1B10
 ' str
  SELECT CASE bpt%(z% + 1)
   CASE IntConst%
    PutLine ("mov ax,*" + numi0$(z% + 1) + ";call _words")
   CASE IntByte%
    PutLine ("mov al,byte ptr ds:[%" + numi0$(z% + 1) + ";cbw;call _words")
   CASE IntWord%
    PutLine ("mov ax,ds:[%" + numi0$(z% + 1) + "];call _words")
   CASE IntDoubleWord%
    PutLine ("mov ax,ds:[%" + numi0$(z% + 1) + "];mov dx,ds:[%" + numi0$(z% + 1) + "+2];call _doublewords")
  END SELECT
  lastsvar2$ = ""
  z% = z% + 1
  EXIT SUB

 CASE &HAD32
 ' repstr
  IF bpt%(z% + 1) = StrConst% THEN
   PutLine ("mov si,offset %" + numi0$(z% + 1) + ";call _str_cs_ds;push si")
  ELSE
   IF lastsvar2$ = bp$(z% + 1) THEN
    PutLine ("mov si,di")
   ELSE
    PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "]")
    lastsvar2$ = ""
   END IF
   PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "]")
  END IF
  SELECT CASE bpt%(z% + 2)
   CASE IntConst%
    PutLine ("mov cx,*" + numi0$(z% + 2))
   CASE IntWord, IntDoubleWord%
    PutLine ("mov cx,ds:[%" + numi0$(z% + 2) + "]")
   CASE ELSE
    CALL ErrTypeMismatch(z% + 2)
  END SELECT
  PutLine ("call _str_repstr")
  IF bpt%(z% + 1) = StrConst% THEN PutLine ("pop bx;call _mem_free")
  ' ^^^^ this may not be needed.
  lastsvar2$ = ""
  z% = z% + 2
  EXIT SUB

 'CASE "hex8"
 CASE &H9A21
  SELECT CASE bpt%(z% + 1)
   CASE IntConst%
    PutLine ("mov ax,*" + numi0$(z% + 1))
   CASE IntByte%, IntWord%
    PutLine ("mov ax,ds:[%" + numi0$(z% + 1) + "]")
   CASE ELSE
    CALL ErrMustBeVar(z% + 1)
  END SELECT
  PutLine ("call _hex8")
  z% = z% + 1
  EXIT SUB

 CASE &HEFFE
 'CASE "hex16"
  SELECT CASE bpt%(z% + 1)
   CASE IntConst%
    PutLine ("mov ax,*" + numi0$(z% + 1))
   CASE IntByte%
    PutLine ("mov al,byte ptr ds:[%" + numi0$(z% + 1) + "];cbw")
   CASE IntWord%, IntDoubleWord%
    PutLine ("mov ax,ds:[%" + numi0$(z% + 1) + "]")
   CASE ELSE
    CALL ErrMustBeVar(z% + 1)
  END SELECT
  PutLine ("call _hex16")
  z% = z% + 1
  lastsvar2$ = ""
  EXIT SUB

 CASE &HC918
 ' "hex32"
  SELECT CASE bpt%(z% + 1)
   CASE IntConst%
    Split4 (bp$(z% + 1))
    PutLine ("mov ax," + numl$(vl&))
    PutLine ("mov dx," + numl$(vh&))
   CASE IntByte%
    PutLine ("mov al,byte ptr ds:[%" + numi0$(z% + 1) + "];cbw;cwd")
   CASE IntWord%
    PutLine ("mov ax,ds:[%" + numi0$(z% + 1) + "];cwd")
   CASE IntDoubleWord%
    PutLine ("mov ax,ds:[%" + numi0$(z% + 1) + "];mov dx,ds:[%" + numi0$(z% + 1) + "+2]")
   CASE ELSE
    CALL ErrMustBeVar(z% + 1)
  END SELECT
  PutLine ("call _hex32")
  z% = z% + 1
  lastsvar2$ = ""
  EXIT SUB

 CASE &H318D
 'CASE "ucase"
  IF lastsvar2$ = bp$(z% + 1) THEN
   PutLine ("mov si,di")
  ELSE
   PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "]")
   lastsvar2$ = ""
  END IF
  PutLine ("call _str_ucase")
  z% = z% + 1
  lastsvar2$ = ""
  EXIT SUB

 'CASE "lcase"
 CASE &H9DAB
  IF lastsvar2$ = bp$(z% + 1) THEN
   PutLine ("mov si,di")
  ELSE
   PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "]")
   lastsvar2$ = ""
  END IF
  PutLine ("call _str_lcase")
  z% = z% + 1
  lastsvar2$ = ""
  EXIT SUB

 CASE &H6B50
 ' "rtrim"
  IF lastsvar2$ = bp$(z% + 1) THEN
   PutLine ("mov si,di")
  ELSE
   PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "]")
   lastsvar2$ = ""
  END IF
  PutLine ("call _str_rtrim")
  z% = z% + 1
  lastsvar2$ = ""
  EXIT SUB

 'CASE "ltrim"
 CASE &HA0A2
  IF lastsvar2$ = bp$(z% + 1) THEN
   PutLine ("mov si,di")
  ELSE
   PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "]")
   lastsvar2$ = ""
  END IF
  PutLine ("call _str_ltrim")
  z% = z% + 1
  lastsvar2$ = ""
  EXIT SUB

 CASE &H51CB
 'CASE "right"
  IF lastsvar2$ = bp$(z% + 1) THEN
   PutLine ("mov si,di")
  ELSE
   PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "]")
   lastsvar2$ = ""
  END IF
  SELECT CASE bpt%(z% + 2)
   CASE IntConst%
    PutLine ("mov cx,*" + numi0$(z% + 2))
   CASE IntByte%
    PutLine ("mov cl,ds:[%" + numi0$(z% + 2) + "];xor ch,ch")
   CASE IntWord%, IntDoubleWord%
    PutLine ("mov cx,ds:[%" + numi0$(z% + 2) + "]")
  CASE ELSE
   CALL ErrTypeMismatch(z% + 2)
  END SELECT
  PutLine ("call _str_right")
  z% = z% + 2
  lastsvar2$ = ""
  EXIT SUB

 CASE &HF9E4
 'CASE "left"
  IF lastsvar2$ = bp$(z% + 1) THEN
   PutLine ("mov si,di")
  ELSE
   PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "]")
   lastsvar2$ = ""
  END IF
  SELECT CASE bpt%(z% + 2)
   CASE IntConst%
    PutLine ("mov cx,*" + numi0$(z% + 2))
   CASE IntByte%
    PutLine ("mov cl,ds:[%" + numi0$(z% + 2) + "];xor ch,ch")
   CASE IntWord%, IntDoubleWord%
    PutLine ("mov cx,ds:[%" + numi0$(z% + 2) + "]")
  CASE ELSE
   CALL ErrTypeMismatch(z% + 2)
  END SELECT
  PutLine ("call _str_left")
  z% = z% + 2
  lastsvar2$ = ""
  EXIT SUB

 CASE &H7F00
 'CASE "space"
  SELECT CASE bpt%(z% + 1)
   CASE IntConst%
    PutLine ("mov cx,*" + numi0$(z% + 1))
   CASE IntWord, IntDoubleWord%
    PutLine ("mov cx,ds:[%" + numi0$(z% + 1) + "]")
   CASE ELSE
    CALL ErrTypeMismatch(z% + 1)
  END SELECT
  PutLine ("call _str_space")
  z% = z% + 1
  lastsvar2$ = ""
  EXIT SUB

 'CASE "mid"
 CASE &H44AA
  IF bpt%(z% + 1) = StrConst% THEN
   PutLine ("mov si,offset %" + numi0$(z% + 1) + ";call _str_cs_ds;push si")
  ELSE
   IF lastsvar2$ = bp$(z% + 1) THEN
    PutLine ("mov si,di")
   ELSE
    PutLine ("mov si,ds:[%" + numi0$(z% + 1) + "]")
    lastsvar2$ = ""
   END IF
  END IF
  SELECT CASE bpt%(z% + 2)
   CASE IntConst%
    PutLine ("mov bx,*" + numi0$(z% + 2))
   CASE IntWord, IntDoubleWord%
    PutLine ("mov bx,ds:[%" + numi0$(z% + 2) + "]")
   CASE ELSE
    CALL ErrTypeMismatch(z% + 2)
  END SELECT
  SELECT CASE bpt%(z% + 3)
   CASE IntConst%
    PutLine ("mov cx,*" + numi0$(z% + 3))
    z% = z% + 3
   CASE IntWord, IntDoubleWord%
    PutLine ("mov cx,ds:[%" + numi0$(z% + 3) + "]")
    z% = z% + 3
   CASE ELSE
    PutLine ("xor cx,cx")
    z% = z% + 2
  END SELECT
  PutLine ("call _str_mid")
  IF bpt%(z% + 1) = StrConst% THEN PutLine ("pop bx;call _mem_free")
  ' ^^^^ dunno if this should be here.
  lastsvar2$ = ""
  EXIT SUB

CASE ELSE
 CALL ReportErr("Compiler error (report to author). Unmatched CRC for keyword: " + bp$(z%), 0, FALSE)
END SELECT

END SUB

