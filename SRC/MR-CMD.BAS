DECLARE SUB AddDataRef (v$, s&, handle%)
DECLARE SUB ProcessCommand4 ()
DECLARE SUB SubMarg ()
DECLARE FUNCTION PointerModel% (bpptr%)
DECLARE SUB SetBPreg (bpr$)
DECLARE FUNCTION PointerType% (bpptr%)
DECLARE FUNCTION PointerSize% (bpptr%)
DECLARE SUB ProcessCommand3 (h%)
DECLARE SUB WriteFile (l$, h%)
DECLARE SUB ReportWarning (E$, indent%, showline%)
DECLARE SUB NestCheck (expected%)
DECLARE SUB LockUnlockSetup ()
DECLARE SUB StringConst (s$, WriteFlag%)
DECLARE SUB ProcessLine ()
DECLARE SUB Block (tmp$, addint%)
DECLARE SUB ProcessCommand2 (h%)
DECLARE FUNCTION Hex8$ (l&)
DECLARE FUNCTION CVAL& (s$)
DECLARE SUB ErrOverflow ()
DECLARE SUB ErrParm (z%, t$)
DECLARE SUB ErrSubDef (z%)
DECLARE SUB ErrTypeMismatch (z%)
DECLARE SUB EvaluateNum (z%, DataType%, bx$, cx$)
DECLARE SUB EvaluateStr (z%)
DECLARE SUB ProcessCMP ()
DECLARE SUB PutHandle (z%)
DECLARE SUB Split4 (s$)
DECLARE SUB AddIntVar (tmpv$, s%, bpptr%)
DECLARE SUB AddLabel (l$, parmcount%)
DECLARE SUB AddStringVar (tmpv$, bpptr%)
DECLARE SUB Flushfile (h%)
DECLARE SUB PutLine (l$)
DECLARE SUB ReportErr (E$, indent%, showline%)
DECLARE SUB GatherPrint (i%)
DECLARE SUB ProcessPrintF (z%)
DECLARE FUNCTION Hex2$ (l%)
DECLARE FUNCTION Hex4$ (l&)

DECLARE FUNCTION BunSize% (z%)

DECLARE FUNCTION numi0$ (tmp%)
DECLARE FUNCTION Lexpand$ (l$)
DECLARE FUNCTION unique% (u$)
DECLARE FUNCTION numi$ (tmp%)
DECLARE FUNCTION MakeVar$ (v$, tt%)
DECLARE FUNCTION numl$ (tmp&)

'$INCLUDE: 'MR.INC'

SUB GatherPrint (i%)
'PRINT inline$ + "i%="; i%; "  bpp%="; bpp%
release% = FALSE
IF i% = bpp% THEN
 SELECT CASE bpt%(i%)
  CASE TermType%
  '(nothing)
  CASE StrConst%
   PutLine ("mov si,offset %" + numi0$(i%) + ";call _str_cs_ds;mov di,si")
   release% = TRUE
  CASE StringType%
   bpreg$ = "bx"
   PutLine ("mov si,ds:[%" + numi0$(i%) + "];call _str_copy")
   release% = TRUE
   bpreg$ = "bp"
  CASE StrFunc%
   CALL EvaluateStr(i%)
   PutLine ("call _str_mark_di")
   release% = TRUE
  CASE IntByte%
   bpreg$ = "bx"
   PutLine ("mov al,byte ptr ds:[%" + numi0$(i%) + "];cbw;call _words")
   bpreg$ = "bp"
   release% = TRUE
  CASE IntWord%
   bpreg$ = "bx"
   PutLine ("mov ax,ds:[%" + numi0$(i%) + "];call _words")
   bpreg$ = "bp"
   release% = TRUE
  CASE IntDoubleWord%
   bpreg$ = "bx"
   PutLine ("mov ax,ds:[%" + numi0$(i%) + "];mov dx,ds:[%" + numi0$(i%) + "+2]")
   PutLine ("call _doublewords")
   bpreg$ = "bp"
   release% = TRUE
  CASE NumFunc%
   CALL EvaluateNum(i%, IntDoubleWord%, "ax", "dx")
   PutLine ("call _doublewords")
   release% = TRUE
  CASE ELSE
   CALL ErrTypeMismatch(i%)
 END SELECT
ELSE
arg% = 0
FOR z% = i% TO bpp%
 SELECT CASE bpt%(z%)
  CASE TermType%
  '(nothing)
  CASE StrConst%
   PutLine ("mov si,offset %" + numi0$(z%) + ";call _str_cs_ds_mark;push si")
   arg% = arg% + 1
   release% = TRUE
  CASE StringType%
   bpreg$ = "bx"
   PutLine ("push word ptr ds:[%" + numi0$(z%) + "]")
   bpreg$ = "bp"
   arg% = arg% + 1
  CASE StrFunc%
   CALL EvaluateStr(z%)
   PutLine ("call _str_mark_di;push di")
   arg% = arg% + 1
   release% = TRUE
  CASE IntByte%
   bpreg$ = "bx"
   PutLine ("mov al,byte ptr ds:[%" + numi0$(z%) + "];cbw;call _words;call _str_mark_di;push di")
   bpreg$ = "bp"
   arg% = arg% + 1
   release% = TRUE
  CASE IntWord%
   bpreg$ = "bx"
   PutLine ("mov ax,ds:[%" + numi0$(z%) + "];call _words;call _str_mark_di;push di")
   bpreg$ = "bp"
   arg% = arg% + 1
   release% = TRUE
  CASE IntDoubleWord%
   bpreg$ = "bx"
   PutLine ("mov ax,ds:[%" + numi0$(z%) + "];mov dx,ds:[%" + numi0$(z%) + "+2]")
   PutLine ("call _doublewords;call _str_mark_di;push di")
   bpreg$ = "bp"
   arg% = arg% + 1
   release% = TRUE
  CASE NumFunc%
   CALL EvaluateNum(z%, IntDoubleWord%, "ax", "dx")
   PutLine ("call _doublewords;call _str_mark_di;push di")
   arg% = arg% + 1
   release% = TRUE
  CASE ELSE
   CALL ErrTypeMismatch(z%)
 END SELECT
NEXT
PutLine ("mov cx," + numi$(arg%) + ";call _str_mix")
END IF
END SUB

SUB LockUnlockSetup
 lastivar1$ = ""
 lastsvar1$ = ""
 lastivar2$ = ""
 lastsvar2$ = ""

 PutHandle (1)
 SELECT CASE bpt%(2)
  CASE IntConst%
   Split4 (bp$(2))
   IF vl& = 0 THEN
    PutLine ("xor dx,dx")
   ELSE
    PutLine ("mov dx," + Hex4$(vl&))
   END IF
   IF vl& = vh& THEN
    PutLine ("mov cx,dx")
   ELSE
    PutLine ("mov cx," + Hex4$(vh&))
   END IF
  CASE IntByte%
   PutLine ("mov dl,ds:[%02];xor dh,dh;xor cx,cx")
  CASE IntWord%
   PutLine ("mov dx,ds:[%02];xor cx,cx")
  CASE IntDoubleWord%
   PutLine ("mov dx,ds:[%02];mov cx,ds:[%02+2]")
  CASE ELSE
   ErrTypeMismatch (2)
 END SELECT
 SELECT CASE bpt%(3)
  CASE IntConst%
   Split4 (bp$(3))
   IF vl& = 0 THEN
    PutLine ("xor di,di")
   ELSE
    PutLine ("mov di," + Hex4$(vl&))
   END IF
   IF vl& = vh& THEN
    PutLine ("mov si,di")
   ELSE
    PutLine ("mov si," + Hex4$(vh&))
   END IF
  CASE IntWord%
   PutLine ("mov di,ds:[%03];xor si,si")
  CASE IntDoubleWord%
   PutLine ("mov di,ds:[%03];mov si,ds:[%03+2]")
  CASE ELSE
   ErrTypeMismatch (3)
 END SELECT
END SUB

SUB NestCheck (expected%)
IF NestStack%(NestSP%) <> expected% THEN
 SELECT CASE NestStack%(NestSP%)
 CASE NestForNext%
  ExpectedNest$ = "NEXT"
 CASE NestIfThen%
  ExpectedNest$ = "ELSE/ENDIF"
 CASE NestWhileWend%
  ExpectedNest$ = "WEND"
 CASE NestSelectCase%
  ExpectedNest$ = "CASE/END SELECT"
 CASE ELSE
  ExpectedNest$ = "??"
 END SELECT
 CALL ReportErr("^ Expected " + ExpectedNest$, bpsp%(0), TRUE)
ELSE
 NestSP% = NestSP% - 1
END IF
END SUB

SUB ProcessCommand

 SELECT CASE CRC16%(LCASE$(bp$(0)))

 CASE &H24B8
 ' "timeslice"
  PutLine ("call _timeslice")
  EXIT SUB

 CASE &H9DBD
 ' "mcursor"
  IF bpt%(1) = IntConst% AND bpt%(2) = IntConst% THEN
   dl& = CVAL(bp$(1))
   dh& = CVAL(bp$(2))
   IF dl& = 0 AND dh& = 0 THEN
    PutLine ("xor dx,dx")
   ELSE
    PutLine ("mov dx,0" + RIGHT$("00" + HEX$(dh&), 2) + RIGHT$("00" + HEX$(dl&), 2) + "h")
   END IF
  ELSE
   SELECT CASE bpt%(1)
    CASE IntConst%
     PutLine ("mov dl,*01")
    CASE IntByte%, IntWord%, IntDoubleWord%
     PutLine ("mov dl,byte ptr ds:[%01]")
   END SELECT
   SELECT CASE bpt%(2)
    CASE IntConst%
     PutLine ("mov dh,*02")
    CASE IntByte%, IntWord%, IntDoubleWord%
     PutLine ("mov dh,byte ptr ds:[%02]")
   END SELECT
  END IF
  PutLine ("call _curp_set")
  EXIT SUB

 CASE &H46A6
  ' "farmemresize"
  PutLine ("mov bx,ds:[%01]")
  SELECT CASE bpt%(2)
   CASE IntConst%
    IF bp$(2) = "0" THEN
     PutLine ("xor ax,ax")
    ELSE
     PutLine ("mov ax,*02")
    END IF
   CASE IntByte%, IntWord%, IntDoubleWord%
    PutLine ("mov ax,ds:[%02]")
  END SELECT
  PutLine ("call _far_mem_resize;mov ds:[%01],bx")
  EXIT SUB

 CASE &HC288
 ' "cls"
  PutLine ("call _cls")
  EXIT SUB

 CASE &HE671
 ' "goto"
  LastValES$ = ""
  t$ = bp$(1)
  IF RIGHT$(t$, 1) = ":" THEN t$ = LEFT$(t$, LEN(t$) - 1)
  t1$ = UCASE$(t$)
  l% = LEN(t1$)
  FOR i% = 1 TO SubPtr%
   IF UCASE$(LEFT$(Sub$(i%), l%)) = t1$ THEN CALL ReportErr("^ Cannot GOTO a SUB", bpsp%(1), TRUE): EXIT FOR
  NEXT
  PutLine ("jmp __" + t$)
  EXIT SUB

 'printf
' CASE &HFEAB
'  CALL ProcessPrintF(1)
'  PutLine ("call " + outstream$)
'  EXIT SUB

 '"nearmemfree"
 CASE &H654E
  IF bpt%(1) <> IntWord% THEN
   CALL ErrTypeMismatch(0)
  ELSE
   PutLine ("mov bx,ds:[%01];call _mem_free")
  END IF
  EXIT SUB

 'CASE "farmemfree"
 CASE &H6954
  IF bpt%(1) <> IntWord% AND bpt%(1) <> IntDoubleWord% THEN
   CALL ErrTypeMismatch(0)
  ELSE
   PutLine ("mov bx,ds:[%01];call _far_mem_free")
  END IF
  EXIT SUB

 'CASE "call"
 CASE &H8D38
  lastivar2$ = ""
  lastivar1$ = ""

  lastsvar2$ = ""
  lastsvar1$ = ""
 
  bp$(1) = LCASE$(bp$(1))
  IF RIGHT$(bp$(1), 1) <> ":" THEN bp$(1) = bp$(1) + ":"

  l% = LEN(bp$(1))
  matched$ = ""
'  PRINT
'  PRINT bp$(1) + "     :"
  FOR i% = 1 TO SubPtr%
'   PRINT Sub$(i%), LEFT$(Sub$(i%), l%)
   IF LEFT$(Sub$(i%), l%) = bp$(1) THEN matched$ = Sub$(i%): EXIT FOR
  NEXT

  IF matched$ = "" THEN
   CALL ReportErr("^ Sub not defined", bpsp%(1), TRUE)
   EXIT SUB
  END IF

  IF MID$(matched$, l% + 1) = "M" THEN CALL SubMarg: EXIT SUB
  IF MID$(matched$, l% + 1) = "E" THEN SubUsed%(i%) = TRUE

  pc% = 0
  s$ = MID$(matched$, l% + 2)
  IF bpp% > 1 THEN

   callmark% = FALSE

   lastax$ = ""

   sp% = 1
   FOR z% = 2 TO bpp%
    pc% = pc% + 2
    t$ = MID$(s$, sp%, 2)
    sp% = sp% + 2
    IF bpar$(z%) = "ARRAY_BY_REF" THEN
     PutLine ("mov ax,offset %" + numi0$(z%) + ";push ax")
    ELSE
     
    SELECT CASE bpt%(z%)
     CASE IntConst%
      bpreg$ = "bx"
      SELECT CASE t$
       CASE "v%", "v@"
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
       CASE "v&"
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
     bpreg$ = "bp"

     CASE IntByte%
      bpreg$ = "bx"
      IF t$ <> "v@" AND t$ <> "a@" THEN CALL ErrParm(z%, t$)
      PutLine ("mov bl,ds:[%" + numi0$(z%) + "];xor bh,bh;push bx")
      'PutLine ("push word ptr ds:[%" + numi0$(z%) + "]")
      bpreg$ = "bp"
     CASE IntWord%
      bpreg$ = "bx"
      IF t$ <> "v%" AND t$ <> "a%" THEN CALL ErrParm(z%, t$)
      PutLine ("push word ptr ds:[%" + numi0$(z%) + "]")
      bpreg$ = "bp"
     CASE StringType%
      bpreg$ = "bx"
      IF t$ <> "v$" AND t$ <> "a$" THEN CALL ErrParm(z%, t$)
      IF bp$(z%) = "mr@null$" THEN
       IF lastax$ <> "0" THEN
        PutLine ("xor ax,ax")
        lastax$ = "0"
       END IF
       PutLine ("push ax")
      ELSE
       PutLine ("push word ptr ds:[%" + numi0$(z%) + "]")
      END IF
      bpreg$ = "bp"
     CASE StrFunc%
      IF t$ <> "v$" AND t$ <> "a$" THEN CALL ErrParm(z%, t$)
      CALL EvaluateStr(z%)
      PutLine ("call _str_mark_di;push di")
      callmark% = TRUE
     CASE NumFunc%
      IF t$ = "v&" OR t$ = "a&" THEN
       PutLine ("xor dx,dx")
       CALL EvaluateNum(z%, IntDoubleWord%, "ax", "dx")
       PutLine ("push ax;push dx")
      ELSE
       CALL EvaluateNum(z%, IntWord%, "ax", "dx")
       PutLine ("push ax")
      END IF
     CASE IntDoubleWord%
      bpreg$ = "bx"
      IF t$ <> "v&" AND t$ <> "a&" THEN CALL ErrParm(z%, t$)
      IF Processor% >= 386 THEN
       PutLine ("push dword ptr ds:[%" + numi0$(z%) + "]")
      ELSE
       PutLine ("push word ptr ds:[%" + numi0$(z%) + "];push word ptr ds:[%" + numi0$(z%) + "+2]")
      END IF
      bpreg$ = "bp"
     CASE StrConst%
      IF t$ <> "v$" AND t$ <> "a$" THEN CALL ErrParm(z%, t$)
      PutLine ("mov si,offset %" + numi0$(z%) + ";call _str_cs_ds_mark;push si")
      callmark% = TRUE
     CASE ELSE
      CALL ErrTypeMismatch(z%)
    END SELECT
    END IF
   NEXT
  END IF
  IF LEN(s$) <> pc% THEN CALL ReportWarning("^ Argument count mismatch", bpsp%(bpp%) + LEN(bp$(bpp%)), TRUE)
  IF MID$(matched$, l% + 1) <> "E" THEN
   PutLine ("call __" + LEFT$(bp$(1), LEN(bp$(1)) - 1))
  ELSE
   PutLine ("call	" + LEFT$(bp$(1), LEN(bp$(1)) - 1))
  END IF
  IF callmark% = TRUE THEN PutLine ("call _str_release")
  'IF SwResume% = TRUE THEN PutLine ("mov word ptr cs:[mr@stackptr], sp")
  BPval$ = ""
  LastValES$ = ""

  EXIT SUB

 'CASE "colour"
 CASE &HE51E
  SELECT CASE bpt%(1)
   CASE IntConst%
    PutLine ("mov byte ptr ss:[mr@current_fore],*01")
   CASE IntByte%, IntWord%, IntDoubleWord%
    PutLine ("mov al,byte ptr ds:[%01]")

   CASE Default%
    ' (nothing)
   CASE ELSE
    CALL ErrTypeMismatch(1)
  END SELECT

  IF bpt%(1) <> Default% AND bpt%(1) <> IntConst% THEN PutLine ("mov byte ptr ss:[mr@current_fore], al")
  IF bpp% > 1 THEN
   SELECT CASE bpt%(2)
    CASE IntConst%
     PutLine ("mov byte ptr ss:[mr@current_back],*02")
    CASE IntByte%, IntWord%, IntDoubleWord%
     PutLine ("mov al,byte ptr ds:[%02]")
    CASE ELSE
     CALL ErrTypeMismatch(z%)
   END SELECT
   IF bpt%(2) <> Default% AND bpt%(2) <> IntConst% THEN PutLine ("mov byte ptr ss:[mr@current_back], al")
  END IF
  EXIT SUB

 'CASE "print"
 CASE &HA157
  lastsvar2$ = ""
  FOR z% = 1 TO bpp%
   IF bp$(z%) = "+" THEN z% = z% + 1
   SELECT CASE bpt%(z%)
    CASE IntByte%
     bpreg$ = "bx"
     PutLine ("mov al,byte ptr ds:[%" + numi0$(z%) + "];cbw;call _echo_words")
     bpreg$ = "bp"
    CASE IntWord%
     bpreg$ = "bx"
     PutLine ("mov ax,ds:[%" + numi0$(z%) + "];call _echo_words")
     bpreg$ = "bp"
    CASE IntDoubleWord%
     bpreg$ = "bx"
     PutLine ("mov ax,ds:[%" + numi0$(z%) + "];mov dx,ds:[%" + numi0$(z%) + "+2]")
     PutLine ("call _echo_doublewords")
     bpreg$ = "bp"
    CASE StrConst%
     PutLine ("mov di,offset %" + numi0$(z%) + ";call _echo_strconst")
    CASE StringType%
     bpreg$ = "bx"
     PutLine ("mov di,ds:[%" + numi0$(z%) + "];call " + outstream$)
     bpreg$ = "bp"
    CASE NumFunc%
     SELECT CASE bp$(z%)
      CASE "mytick"
      CASE ELSE
       PutLine ("xor dx,dx")
     END SELECT
     CALL EvaluateNum(z%, IntDoubleWord%, "ax", "dx")
     PutLine ("call _echo_doublewords")
    CASE StrFunc%
     CALL EvaluateStr(z%)
     PutLine ("push di;call " + outstream$ + ";ƒbx;call _mem_free")
    CASE Num1Func%
     CALL ReportErr("^ Must save to a variable", bpsp%(z%), TRUE)
   END SELECT
  NEXT
  EXIT SUB

 'CASE "while"
 CASE &HD1FD
  LastValES$ = ""
  NestSP% = NestSP% + 1
  NestStack%(NestSP%) = NestWhileWend%
  WhileWendCnt% = WhileWendCnt% + 1
  WhileWendSP% = WhileWendSP% + 1
  WhileWendStack%(WhileWendSP%) = WhileWendCnt%
  PutLine ("_whl" + numi$(WhileWendCnt%) + ":")
  CALL ProcessCMP
  PutLine ("jmp " + "_wnd" + numi$(WhileWendCnt%) + ";LL" + numi$(LocVarCount%) + ":")
  EXIT SUB

 CASE &H67C4
 'CASE "wend"
  CALL NestCheck(NestWhileWend%)
  PutLine ("jmp _whl" + numi$(WhileWendStack%(WhileWendSP%)))
  PutLine ("_wnd" + numi$(WhileWendStack%(WhileWendSP%)) + ":")
  WhileWendSP% = WhileWendSP% - 1
  EXIT SUB

 'CASE "sub"
 CASE &H3A10
 BPvar$ = "bx"
 BPval$ = ""

 LastValES$ = ""
 IF currentsub$ = "(none):" AND LastBP0$ <> "end" AND SwPartial% = FALSE THEN PutLine ("jmp _exit")

 IF currentsub$ <> "(none):" AND currentsub$ <> ":" THEN CALL ReportErr("^ Previous sub does not have END SUB", 0, TRUE)
 IF RIGHT$(bp$(1), 1) <> ":" THEN bp$(1) = bp$(1) + ":"
 currentsub$ = LCASE$(bp$(1))
 SubCounter% = SubCounter% + 1
 updsub% = TRUE
 pop% = 0
 l% = LEN(currentsub$)
 FOR i% = 1 TO SubPtr%
  IF LEFT$(Sub$(i%), l%) = currentsub$ THEN EXIT FOR
 NEXT
 SubUsed%(i%) = TRUE
 sp$ = MID$(Sub$(i%), l% + 2)
 st$ = MID$(Sub$(i%), l% + 1, 1)
 IF (LEN(sp$) \ 2) <> bpp% - 1 THEN CALL ReportWarning("^ Argument count mismatch", bpsp%(bpp%) + LEN(bp$(bpp%)), TRUE)
 IF bpp% > 1 THEN
  LocalArray$ = " "
  FOR z% = 2 TO bpp%
   t$ = MID$(sp$, ((z% - 2) * 2) + 1, 2)
   IF LEFT$(t$, 1) = "a" THEN
    SELECT CASE bpt%(z%)
     CASE IntByte%
      IF t$ <> "a@" AND bpar$(z%) <> "ARRAY_BY_REF" THEN CALL ErrSubDef(z%)
      LocalArray$ = LocalArray$ + bp$(z%) + " "
      pop% = pop% + 2
     CASE IntWord%
      IF t$ <> "a%" AND bpar$(z%) <> "ARRAY_BY_REF" THEN CALL ErrSubDef(z%)
      LocalArray$ = LocalArray$ + bp$(z%) + " "
      pop% = pop% + 2
     CASE StringType%
      IF t$ <> "a$" AND bpar$(z%) <> "ARRAY_BY_REF" THEN CALL ErrSubDef(z%)
      LocalArray$ = LocalArray$ + bp$(z%) + " "
      pop% = pop% + 2
     CASE IntDoubleWord%
      IF t$ <> "a&" AND bpar$(z%) <> "ARRAY_BY_REF" THEN CALL ErrSubDef(z%)
      LocalArray$ = LocalArray$ + bp$(z%) + " "
      pop% = pop% + 2
    END SELECT

   ELSE

   SELECT CASE bpt%(z%)
    CASE IntByte%
     IF t$ <> "v@" THEN CALL ErrSubDef(z%)
     pop% = pop% + 2
    CASE IntWord%
     IF t$ <> "v%" THEN CALL ErrSubDef(z%)
     pop% = pop% + 2
    CASE StringType%
     IF t$ <> "v$" THEN CALL ErrSubDef(z%)
     pop% = pop% + 2
    CASE IntDoubleWord%
     IF t$ <> "v&" THEN CALL ErrSubDef(z%)
     pop% = pop% + 4
   END SELECT
   END IF

  NEXT
 END IF

 fb$(FMcode%) = fb$(FMcode%) + "public __" + UCASE$(LEFT$(currentsub$, LEN(currentsub$) - 1)) + CHR$(13) + CHR$(10)
 CALL AddLabel(bp$(1), pop%)
 IF PreserveFlag% = TRUE THEN
   t$ = LCASE$(LEFT$(currentsub$, LEN(currentsub$) - 1))
   PutLine ("jmp mr@preserve_" + t$)
   CALL WriteFile("mr@reentry_" + t$ + ":", FMcode%)
   PreserveCount% = -1
   PreserveList$ = " "
 END IF

 IF SwDebug% = TRUE THEN
  PutLine ("mov word ptr ss:[mr@line]," + numi$(linecount%))
 END IF
 IF SwTrace% = TRUE THEN PutLine ("call _trace")
 IF SwSingleStep% = TRUE THEN PutLine ("int 3")

 SubFree$ = ""
 IF SwDep% = TRUE THEN PutLine ("call _set_critical;push bp")
 IF bpp% > 1 THEN
  ptr% = 2
  IF SwDep% = TRUE THEN
  ' PutLine ("push bp") ' ^^ done above
   ptr% = ptr% + 2
  END IF
  IF st$ = "F" THEN ptr% = ptr% + 2
  IF PreserveFlag% = FALSE THEN PutLine ("mov bp,sp")

  IF SwDep% = TRUE THEN
   IF INSTR(sp$, "$") <> 0 THEN PutLine ("mov word ptr cs:[mr@their_ds], ds")
   PutLine ("push si;push di;push ds;push es;mov ds, word ptr cs:[mr@my_ds]")
  END IF

  IF PragmaSubNullStringCheck% = TRUE THEN PutLine ("xor dx,dx")
  FOR z% = bpp% TO 2 STEP -1
   IF bpar$(z%) = "ARRAY_BY_REF" THEN
    SELECT CASE bpt%(z%)
     CASE IntByte%
      t$ = "lab_"
     CASE IntWord%
      t$ = "law_"
     CASE IntDoubleWord
      t$ = "lad_"
     CASE StringType%
      t$ = "las_"
    END SELECT
    t$ = t$ + numi$(SubCounter%) + "@" + UCASE$(LEFT$(bp$(z%), LEN(bp$(z%)) - 1))
    PutLine ("mov ax,[bp+" + numi$(ptr%) + "];mov ds:[" + t$ + "],ax")
    ptr% = ptr% + 2
    CALL AddDataRef(t$, 2, FMvar%)
   ELSE
   SELECT CASE bpt%(z%)
    CASE IntByte%
     CALL AddIntVar(bp$(z%), 1, z%)
     PutLine ("mov al,byte ptr [bp+" + numi$(ptr%) + "];mov byte ptr ds:[%" + numi0$(z%) + "],al")
     ptr% = ptr% + 2
    CASE IntWord%
     CALL AddIntVar(bp$(z%), 2, z%)
     PutLine ("mov ax,[bp+" + numi$(ptr%) + "];mov ds:[%" + numi0$(z%) + "],ax")
     ptr% = ptr% + 2
    CASE StringType%
     CALL AddStringVar(bp$(z%), z%)
     SELECT CASE Language%
      CASE MR%
       IF PragmaSubNullStringCheck% = TRUE THEN
        LocVarCount% = LocVarCount% + 1
        PutLine ("mov si,[bp+" + numi$(ptr%) + "];or si,si")
        PutLine ("jz LL" + numi$(LocVarCount%) + ";call _str_copy")
        PutLine ("mov ds:[%" + numi0$(z%) + "],di;jmp short LL" + numi$(LocVarCount% + 1))
        PutLine ("LL" + numi$(LocVarCount%) + ":;mov ds:[%" + numi0$(z%) + "],dx")
        PutLine ("LL" + numi$(LocVarCount% + 1) + ":")
        LocVarCount% = LocVarCount% + 2
       ELSE
        PutLine ("mov si,[bp+" + numi$(ptr%) + "];call _str_copy;mov ds:[%" + numi0$(z%) + "],di")
       END IF
      CASE QuickBASIC%
       PutLine ("mov si,[bp+" + numi$(ptr%) + "];call _str_copy_qb;mov ds:[%" + numi0$(z%) + "],di")
     END SELECT
     t$ = MakeVar$(bp$(z%), StringType%)
     IF INSTR(SubFree$, t$ + ",") = 0 THEN SubFree$ = SubFree$ + MakeVar$(bp$(z%), StringType%) + ","
     ptr% = ptr% + 2
    CASE IntDoubleWord%
     CALL AddIntVar(bp$(z%), 4, z%)
'     IF Processor% >= 386 THEN
'      PutLine ("mov eax,dword ptr [bp+" + numi$(ptr%) + "];mov dword ptr ds:[%" + numi0$(z%) + "],eax")
'     ELSE
      PutLine ("mov ax,[bp+" + numi$(ptr%) + "];mov ds:[%" + numi0$(z%) + "+2],ax")
      PutLine ("mov ax,[bp+" + numi$(ptr% + 2) + "];mov ds:[%" + numi0$(z%) + "],ax")
'     END IF
     ptr% = ptr% + 4
    CASE ELSE
     CALL ErrTypeMismatch(z%)
   END SELECT
   END IF
  NEXT
 ELSE
  IF SwDep% = TRUE THEN
   PutLine ("push si;push di;push ds;push es;mov ds,word ptr cs:[mr@my_ds]")
  END IF
 END IF
 IF SwDebug% = TRUE THEN
  PutLine ("call _packfunctiondump")
  PutLine ("mov word ptr ss:[mr@func],offset dbg_" + LEFT$(currentsub$, LEN(currentsub$) - 1))
  IF SwPartial% = TRUE THEN
   PutLine ("push word ptr cs:[mr@sourcefile]")
   PutLine ("mov word ptr cs:[mr@sourcefile],offset src_" + depname$)
  END IF
 END IF
 bpreg$ = "bp"
 EXIT SUB
 
 
  CASE ELSE
    CALL ProcessCommand2(CRC16%(LCASE$(bp$(0))))
END SELECT

END SUB

SUB ProcessCommand2 (h%)
SELECT CASE h%

 'CASE "end"
 CASE &H749C
  IF bp$(1) = "sub" THEN
   GOTO CReturn
  END IF

  IF bp$(1) = "select" THEN
   GOTO Cendcaselist
  END IF

  IF bpp% = 0 THEN
   PutLine ("xor al,al")
  ELSE
   SELECT CASE bpt%(1)
    CASE IntConst%
     PutLine ("mov al," + Hex2$(VAL(bp$(1))))
    CASE IntByte%, IntWord%, IntDoubleWord%
     PutLine ("mov al,byte ptr ds:[%01]")
    CASE ELSE
     CALL ErrTypeMismatch(1)
   END SELECT
  END IF
  PutLine ("jmp _exit")
  EXIT SUB

 CASE &HB7E6
 ' "select"
  LastValES$ = ""
  IF bp$(1) <> "case" THEN CALL ReportErr("^ CASE expected", bpsp%(1), TRUE): EXIT SUB
  IF bpt%(2) <> IntByte% AND bpt%(2) <> IntWord% AND bpt%(2) <> IntDoubleWord% AND bpt%(2) <> StringType% THEN CALL ReportErr("^ Must be numerical or string variable", bpsp%(1), TRUE): EXIT SUB
  bpreg$ = "bx"
  NestSP% = NestSP% + 1
  NestStack%(NestSP%) = NestSelectCase%
  CaseListSP% = CaseListSP% + 1
  CaseListElse%(CaseListSP%) = FALSE
  CaseListReload%(CaseListSP%) = FALSE
  CaseListPrecision%(CaseListSP%) = bpt%(2)
  'CaseListVar$(CaseListSP%) = "ds:[" + MakeVar$(bp$(2), bpt%(2))
  CaseListVar$(CaseListSP%) = bp$(2)
  CaseListArrVar$(CaseListSP%) = bpar$(2)
  CaseListArrType%(CaseListSP%) = bpart%(2)
  CaseListInCnt%(CaseListSP%) = 0   ' internal caselist element counter
  CaseListStack%(CaseListSP%) = CaseListCnt% ' global caselist count
  CaseListCnt% = CaseListCnt% + 1
  IF bpt%(2) = IntDoubleWord% AND Processor% >= 386 THEN
   PutLine ("mov eax,dword ptr ds:[%02]")
  ELSE
   SELECT CASE bpt%(2)
    CASE IntByte%
     PutLine ("mov al,byte ptr ds:[%02];cbw")
    CASE IntWord%
     IF lastivar2$ <> bp$(2) THEN PutLine ("mov ax,ds:[%02]")
    CASE IntDoubleWord%
     IF lastivar2$ <> bp$(2) THEN PutLine ("mov ax,ds:[%02];mov dx,ds:[%02+2]")
    CASE StringType%
'     IF lastsvar2$ <> bp$(2) THEN PutLine ("mov di,ds:[%02]")  ' note DI used
     PutLine ("")
     CaseListReload%(CaseListSP%) = TRUE
   END SELECT
  END IF
  IF lastivar2$ = bp$(2) AND Processor% < 386 THEN CALL WriteFile(";", FMcode%)
  bpreg$ = "bp"
  EXIT SUB

 CASE &HF5C
 ' "case"
  LastValES$ = ""
  IF CaseListInCnt%(CaseListSP%) <> 0 THEN
   PutLine ("jmp _clst" + numi$(CaseListStack%(CaseListSP%)) + "_end")
   PutLine ("_clst" + numi$(CaseListStack%(CaseListSP%)) + "_" + numi$(CaseListInCnt%(CaseListSP%)) + ":")
  END IF
  IF bp$(1) = "else" THEN CaseListElse%(CaseListSP%) = TRUE: EXIT SUB

  IF CaseListElse%(CaseListSP%) = TRUE THEN CALL ReportErr("^ CASE ELSE must be last CASE statement in block", bpsp%(1), TRUE)
  bpreg$ = "bx"
  IF CaseListReload%(CaseListSP%) = TRUE THEN
   CaseListReload%(CaseListSP%) = FALSE
  
   bp$(69) = CaseListVar$(CaseListSP%)
   bpt%(69) = CaseListPrecision%(CaseListSP%)
   bpar$(69) = CaseListArrVar$(CaseListSP%)
   bpart%(69) = CaseListArrType%(CaseListSP%)
   IF CaseListPrecision%(CaseListSP%) = IntDoubleWord% AND Processor% >= 386 THEN
    PutLine ("mov eax,dword ptr ds:[%69]")
   ELSE
    SELECT CASE CaseListPrecision%(CaseListSP%)
     CASE IntByte%
      PutLine ("mov al,byte ptr ds:[%69];cbw")
     CASE IntWord%
      PutLine ("mov ax,ds:[%69]")
     CASE IntDoubleWord%
      PutLine ("mov ax,ds:[%69];mov dx,ds:[%69+2]")
     CASE StringType%
      PutLine ("mov di,ds:[%69]")   ' note DI is used
      CaseListReload%(CaseListSP%) = TRUE
    END SELECT
   END IF
  END IF

  FOR i% = 1 TO bpp%
   SELECT CASE bpt%(i%)
    CASE IntConst%
     IF CaseListPrecision%(CaseListSP%) = IntWord% THEN
      IF bp$(i%) = "0" THEN
       PutLine ("test ax,ax")
      ELSE
       PutLine ("cmp ax,*" + numi0$(i%))
      END IF
      PutLine ("jz _cont" + numi$(CaseListStack%(CaseListSP%)) + "_" + numi$(CaseListInCnt%(CaseListSP%)))
     ELSE
      IF Processor% >= 386 THEN
       IF CVAL(bp$(1)) = 0 THEN
        PutLine ("or eax,eax")
       ELSE
        PutLine ("cmp eax," + Hex8$(CVAL(bp$(i%))))
       END IF
       PutLine ("jz _cont" + numi$(CaseListStack%(CaseListSP%)) + "_" + numi$(CaseListInCnt%(CaseListSP%)))
      ELSE
       Split4 (bp$(i%))
       LocVarCount% = LocVarCount% + 1
       IF vl& = 0 THEN
        PutLine ("test ax,ax")
       ELSE
        PutLine ("cmp ax," + Hex4$(vl&))
       END IF
       PutLine ("jnz short LL" + numi$(LocVarCount%))
       IF vh& = 0 THEN
        PutLine ("or dx,dx")
       ELSE
        PutLine ("cmp dx," + Hex4$(vh&))
       END IF
       PutLine ("jz _cont" + numi$(CaseListStack%(CaseListSP%)) + "_" + numi$(CaseListInCnt%(CaseListSP%)))
       PutLine ("LL" + numi$(LocVarCount%) + ":")
       LocVarCount% = LocVarCount% + 1
      END IF
     END IF
    CASE IntByte%
     PutLine ("cmp al,ds:[%" + numi0$(i%) + "]")
     PutLine ("jz _cont" + numi$(CaseListStack%(CaseListSP%)) + "_" + numi$(CaseListInCnt%(CaseListSP%)))
    CASE IntWord%
     PutLine ("cmp ax,ds:[%" + numi0$(i%) + "]")
     PutLine ("jz _cont" + numi$(CaseListStack%(CaseListSP%)) + "_" + numi$(CaseListInCnt%(CaseListSP%)))
    CASE IntDoubleWord%
     IF Processor% >= 386 THEN
      PutLine ("cmp eax,ds:[%" + numi0$(i%) + "];jnz _cont" + numi$(CaseListStack%(CaseListSP%)) + "_" + numi$(CaseListInCnt%(CaseListSP%)))
     ELSE
      LocVarCount% = LocVarCount% + 1
      PutLine ("cmp ax,ds:[%" + numi0$(i%) + "];jnz short LL" + numi$(LocVarCount%))
      PutLine ("cmp dx,ds:[%" + numi0$(i%) + "+2];jz _cont" + numi$(CaseListStack%(CaseListSP%)) + "_" + numi$(CaseListInCnt%(CaseListSP%)))
      PutLine ("LL" + numi$(LocVarCount%) + ":")
      LocVarCount% = LocVarCount% + 1
     END IF
    CASE StringType%
     PutLine ("mov si,ds:[%" + numi0$(i%) + "];call _str_compare;test ax,ax")
     PutLine ("jnz _cont" + numi$(CaseListStack%(CaseListSP%)) + "_" + numi$(CaseListInCnt%(CaseListSP%)))
'              -1 = strings match
    CASE StrConst%
     PutLine ("mov si,offset %" + numi0$(i%) + ";call _str_cs_ds;push si;call _str_compare;pop bx;call _mem_free;test ax,ax")
     PutLine ("jnz _cont" + numi$(CaseListStack%(CaseListSP%)) + "_" + numi$(CaseListInCnt%(CaseListSP%)))
'              -1 = strings match
    CASE ELSE

     CALL ErrTypeMismatch(i%)
   END SELECT
  NEXT
  PutLine ("jmp _clst" + numi$(CaseListStack%(CaseListSP%)) + "_" + numi$(CaseListInCnt%(CaseListSP%) + 1))
  PutLine ("_cont" + numi$(CaseListStack%(CaseListSP%)) + "_" + numi$(CaseListInCnt%(CaseListSP%)) + ":")
  CaseListInCnt%(CaseListSP%) = CaseListInCnt%(CaseListSP%) + 1
  bpreg$ = "bp"
  EXIT SUB


Cendcaselist:
  CALL NestCheck(NestSelectCase%)
  PutLine ("_clst" + numi$(CaseListStack%(CaseListSP%)) + "_end:")
  IF CaseListElse%(CaseListSP%) = FALSE THEN PutLine ("_clst" + numi$(CaseListStack%(CaseListSP%)) + "_" + numi$(CaseListInCnt%(CaseListSP%)) + ":")
  CaseListSP% = CaseListSP% - 1
  IF CaseListSP% > 0 THEN CaseListReload%(CaseListSP%) = TRUE
  EXIT SUB


 CASE &HE544
 'CASE "fclose"
  CALL PutHandle(1)
  PutLine ("call _file_close")
  EXIT SUB

 CASE &H73AE
 'CASE "fprint"
  CALL GatherPrint(2)
  CALL PutHandle(1)
  IF bpp% = 2 THEN
   PutLine ("push di;call _file_print;pop bx;call _mem_free")
  ELSE
   PutLine ("call _str_mark_di;call _file_print;call _str_release")
  END IF
  EXIT SUB
 
 'CASE "fput"
 CASE &H6FFC
  CALL PutHandle(1)
  SELECT CASE bpt%(2)
   CASE IntByte%
    PutLine ("mov si,offset %02;mov cx,1;call _file_write")
   CASE IntWord%
    PutLine ("mov si,offset %02;mov cx,2;call _file_write")
   CASE IntDoubleWord%
    PutLine ("mov si,offset %02;mov cx,4;call _file_write")
'   CASE StrConst%
'    PutLine ("mov si,offset %02;mov cx,cs:[si];add si,2;call _file_write")
   CASE StringType%
    PutLine ("mov si,ds:[%02];mov cx,ds:[si];add si,2;call _file_write")
   CASE BundleType%
    PutLine ("mov si,offset %02;mov cx," + numi$(BunSize%(2)) + ";call _file_write")
   CASE ELSE
    CALL ErrTypeMismatch(2)
   END SELECT
   EXIT SUB

 CASE &H7503
 ' fkill
  SELECT CASE bpt%(1)
   CASE StrConst%
    PutLine ("mov si,offset %01;call _str_cs_ds;push si;call _file_kill;pop bx;call _mem_free")
   CASE StringType%
    PutLine ("mov si,ds:[%01];call _file_kill")
  END SELECT
  EXIT SUB

 'CASE "fseek "
 CASE &H5479
  CALL PutHandle(1)
  SELECT CASE bpt%(2)
   CASE IntConst%
    Split4 (bp$(2))
    IF vl& = 0 THEN
     PutLine ("xor ax,ax")
     IF vh& = 0 THEN
      PutLine ("mov dx,ax")
     ELSE
      PutLine ("mov dx," + Hex4$(vh&))
     END IF
     PutLine ("call _file_seek")
     EXIT SUB
    END IF
    PutLine ("mov ax," + Hex4$(vl&) + ";mov dx," + Hex4$(vh&))
   CASE IntByte%
    PutLine ("mov al,byte ptr ds:[%02];xor ah,ah")
   CASE IntWord%
    PutLine ("mov ax,ds:[%02];xor dx,dx")
   CASE IntDoubleWord%
    PutLine ("mov ax,ds:[%02];mov dx,ds:[%02+2]")
   CASE ELSE
    CALL ErrTypeMismatch(2)
  END SELECT
  PutLine ("call _file_seek")
  EXIT SUB

 'CASE "for"
 CASE &H6C0A
  bpreg$ = "bx"
  LastValES$ = ""
  NestSP% = NestSP% + 1
  NestStack%(NestSP%) = NestForNext%
  SELECT CASE bpt%(3)
   CASE IntConst%
    SELECT CASE bpt%(1)
     CASE IntByte%
      PutLine ("mov byte ptr ds:[%01],*03")
     CASE IntWord%
      IF CVAL(bp$(3)) = 0 THEN
       PutLine ("xor ax,ax;mov ds:[%01],ax")
      ELSE
       PutLine ("mov word ptr ds:[%01],*03")
      END IF
     CASE IntDoubleWord%
      IF Processor% >= 386 THEN
       IF CVAL(bp$(3)) = 0 THEN
        PutLine ("xor eax,eax;mov dword ptr ds:[%01],eax")
       ELSE
        PutLine ("mov dword ptr ds:[%01]," + Hex8$(CVAL(bp$(3))))
       END IF
      ELSE
       IF CVAL(bp$(3)) = 0 THEN
        PutLine ("xor ax,ax;mov ds:[%01],ax;mov ds:[%01+2],ax")
       ELSE
        Split4 (numl$(CVAL(bp$(3))))
        PutLine ("mov word ptr ds:[%01]," + Hex4$(vl&))
        PutLine ("mov word ptr ds:[%01+2]," + Hex4$(vh&))
       END IF
      END IF
    END SELECT
   CASE IntByte%
    PutLine ("mov al,byte ptr ds:[%03]")
   CASE IntWord%
    PutLine ("mov ax,ds:[%03]")
   CASE IntDoubleWord%
    IF Processor% >= 386 THEN
     PutLine ("mov eax,dword ptr ds:[%03]")
    ELSE
     PutLine ("mov ax,ds:[%03];mov dx,ds:[%03+2]")
    END IF
   CASE ELSE
    CALL ErrTypeMismatch(3)
  END SELECT
  IF bpt%(3) <> IntConst% THEN
   SELECT CASE bpt%(1)
    CASE IntByte%
     PutLine ("mov ds:[%01],al")
    CASE IntWord%
     PutLine ("mov ds:[%01],ax")
    CASE IntDoubleWord%
     IF Processor% >= 386 THEN
      PutLine ("mov dword ptr ds:[%01],eax")
     ELSE
      PutLine ("mov ds:[%01],ax;mov ds:[%01+2],dx")
     END IF
   END SELECT
  END IF
  ForNextSP% = ForNextSP% + 1
  fornextcnt% = fornextcnt% + 1
  fornextvar$(ForNextSP%) = MakeVar$(bp$(1), bpt%(1))
  fornextstack%(ForNextSP%) = fornextcnt%
  fornextt%(ForNextSP%) = bpt%(1)
  PutLine ("_fornext" + numi$(fornextcnt%) + ":")
  fornextend$(ForNextSP%) = bp$(5)
  bpreg$ = "bp"
  EXIT SUB

 CASE &H34F0
 'CASE "next"
  CALL NestCheck(NestForNext%)
  LastValES$ = ""
  SELECT CASE fornextt%(ForNextSP%)
   CASE IntByte%
    PutLine ("mov al,byte ptr ds:[" + fornextvar$(ForNextSP%) + "];inc al")
   CASE IntWord%
    PutLine ("mov ax,ds:[" + fornextvar$(ForNextSP%) + "];inc ax")
   CASE IntDoubleWord%
    IF Processor% >= 386 THEN
     PutLine ("mov eax,dword ptr ds:[" + fornextvar$(ForNextSP%) + "];inc eax")
    ELSE
     PutLine ("mov ax,ds:[" + fornextvar$(ForNextSP%) + "];mov dx,ds:[" + fornextvar$(ForNextSP%) + "+2]")
     PutLine ("add ax,1;adc dx,0")
    END IF
  END SELECT
  ErrOverflow

'  SELECT CASE RIGHT$(fornextend$(ForNextSP%), 1)
'   CASE "@"

  signed% = TRUE
  SELECT CASE RIGHT$(fornextend$(ForNextSP%), 1)
   CASE "%"
   'PutLine ("cmp ax,ds:[__" + LEFT$(fornextend$(ForNextSP%), LEN(fornextend$(ForNextSP%)) - 1) + "]")
    PutLine ("cmp ax,ds:[" + MakeVar$(LEFT$(fornextend$(ForNextSP%), LEN(fornextend$(ForNextSP%))), fornextt%(ForNextSP%)) + "]")
   CASE "@"
    PutLine ("cmp al,ds:[" + MakeVar$(LEFT$(fornextend$(ForNextSP%), LEN(fornextend$(ForNextSP%))), fornextt%(ForNextSP%)) + "]")
   CASE "&"
    IF Processor% >= 386 THEN
     PutLine ("cmp eax,ds:[" + MakeVar$(LEFT$(fornextend$(ForNextSP%), LEN(fornextend$(ForNextSP%))), fornextt%(ForNextSP%)) + "]")
    ELSE
     LocVarCount% = LocVarCount% + 1
     PutLine ("cmp dx,ds:[" + MakeVar$(LEFT$(fornextend$(ForNextSP%), LEN(fornextend$(ForNextSP%))), fornextt%(ForNextSP%)) + "+2];jnz LL" + numi$(LocVarCount%))
     PutLine ("cmp ax,ds:[" + MakeVar$(LEFT$(fornextend$(ForNextSP%), LEN(fornextend$(ForNextSP%))), fornextt%(ForNextSP%)) + "];LL" + numi$(LocVarCount%) + ":")
     signed% = FALSE
    END IF
   CASE ELSE
    SELECT CASE fornextt%(ForNextSP%)
     CASE IntByte%
      PutLine ("cmp al," + fornextend$(ForNextSP%))
     CASE IntWord%
      PutLine ("cmp ax," + fornextend$(ForNextSP%))
     CASE IntDoubleWord%
      IF Processor% >= 386 THEN
       PutLine ("cmp eax," + Hex8$(CVAL(fornextend$(ForNextSP%))))
      ELSE
       Split4 (fornextend$(ForNextSP%))
       LocVarCount% = LocVarCount% + 1
       PutLine ("cmp dx," + Hex4$(vh&) + ";jnz LL" + numi$(LocVarCount%) + ";cmp ax," + Hex4$(vl&) + ";LL" + numi$(LocVarCount%) + ":")
       signed% = FALSE
      END IF
    END SELECT
  END SELECT

  ErrOverflow
  IF signed% = TRUE THEN
   PutLine ("jg _fornext" + numi$(fornextstack%(ForNextSP%)) + "end")
  ELSE
   PutLine ("ja _fornext" + numi$(fornextstack%(ForNextSP%)) + "end")
  END IF
  SELECT CASE fornextt%(ForNextSP%)
   CASE IntByte%
    PutLine ("mov ds:[" + fornextvar$(ForNextSP%) + "],al")
   CASE IntWord%
    PutLine ("mov ds:[" + fornextvar$(ForNextSP%) + "],ax")
   CASE IntDoubleWord%
    IF Processor% >= 386 THEN
     PutLine ("mov dword ptr ds:[" + fornextvar$(ForNextSP%) + "],eax")
    ELSE
     PutLine ("mov ds:[" + fornextvar$(ForNextSP%) + "],ax")
     PutLine ("mov ds:[" + fornextvar$(ForNextSP%) + "+2],dx")
    END IF
  END SELECT
  PutLine ("jmp _fornext" + numi$(fornextstack%(ForNextSP%)) + ";_fornext" + numi$(fornextstack%(ForNextSP%)) + "end:")
  ForNextSP% = ForNextSP% - 1
  EXIT SUB

 CASE &HAC78
 'CASE "return"
  IF SwDep% = FALSE THEN CALL ReportWarning("^ Use END SUB instead of RETURN", bpsp%(0), TRUE)
CReturn:

  LastValES$ = ""
  IF currentsub$ = "(none):" OR currentsub$ = ":" THEN
   CALL ReportErr("^ Not in a sub", 0, TRUE)
  ELSE
   IF ForNextSP% < 0 THEN CALL ReportErr("Mismatched FOR..NEXT: too many NEXTs in sub " + currentsub$, 0, FALSE): ForNextSP% = 0
   IF ForNextSP% > 0 THEN CALL ReportErr("Mismatched FOR..NEXT: too many FORs in sub " + currentsub$, 0, FALSE): ForNextSP% = 0
   IF IfThenSP% < 0 THEN CALL ReportErr("Mismatched IF..ELSE..ENDIF: too many ENDIFs in sub " + currentsub$, 0, FALSE): IfThenSP% = 0
   IF IfThenSP% > 0 THEN CALL ReportErr("Mismatched IF..ELSE..ENDIF: too many IFs in sub " + currentsub$, 0, FALSE): IfThenSP% = 0
   IF CaseListSP% < 0 THEN CALL ReportErr("Mismatched SELECT CASE..CASE..END SELECT: too many END SELECTs in sub " + currentsub$, 0, FALSE): CaseListSP% = 0
   IF CaseListSP% > 0 THEN CALL ReportErr("Mismatched SELECT CASE..CASE..END SELECT: too many SELECT CASEs in sub " + currentsub$, 0, FALSE): CaseListSP% = 0
   IF WhileWendSP% < 0 THEN CALL ReportErr("Mismatched WHILE..WEND: too many WENDs in sub " + currentsub$, 0, FALSE): WhileWendSP% = 0
   IF WhileWendSP% > 0 THEN CALL ReportErr("Mismatched WHILE..WEND: too many WHILEs in sub " + currentsub$, 0, FALSE): WhileWendSP% = 0
  
   ptr% = INSTR(LabelTable$, LCASE$(currentsub$))
   ptr% = INSTR(ptr%, LabelTable$, ":") + 1
   PutLine ("__" + LEFT$(currentsub$, LEN(currentsub$) - 1) + "_end:")
   IF SubFree$ <> "" THEN PutLine ("mov si,offset mr@cleanup_" + LEFT$(currentsub$, LEN(currentsub$) - 1) + ";call _sub_cleanup")
   IF SwDep% = TRUE THEN
    IF bpp% > 0 THEN
     SELECT CASE bpt%(1)
      CASE IntConst%
       Split4 (bp$(1))
       IF vl& = 0 THEN
        PutLine ("xor ax,ax")
       ELSE
        PutLine ("mov ax," + Hex4$(vl&))
       END IF
       IF vh& = vl& THEN
        PutLine ("mov dx,ax")
       ELSE
        IF vh& = 0 THEN
         PutLine ("xor dx,dx")
        ELSE
         PutLine ("mov dx," + Hex4$(vl&))
        END IF
       END IF
      CASE IntByte%
       PutLine ("mov al,byte ptr ds:[%01];xor ah,ah;cwd")
      CASE IntWord%
       PutLine ("mov ax,ds:[%01];xor dx,dx")
      CASE IntDoubleWord%
       PutLine ("mov ax,ds:[%01];mov dx,ds:[%01]")
     END SELECT
    END IF
   END IF

   l% = LEN(currentsub$)
   FOR i% = 1 TO SubPtr%
    IF LEFT$(Sub$(i%), l%) = currentsub$ THEN EXIT FOR
   NEXT
   t$ = LCASE$(MID$(Sub$(i%), l% + 1, 1))
   IF t$ = "n" THEN t$ = ""
   IF SwDep% = TRUE THEN PutLine ("ƒes;ƒds;ƒdi;ƒsi;ƒbp;call _restore_critical")
   IF SwDebug% = TRUE THEN
    CALL PutLine("call _packfunctiondump;mov word ptr ss:[mr@func],-1")
    IF SwPartial% = TRUE THEN PutLine ("ƒword ptr cs:[mr@sourcefile]")
   END IF
  
   IF PreserveFlag% = TRUE THEN
     IF PreserveCount% <> -1 THEN
      FOR z% = PreserveCount% TO 0 STEP -1
       p$ = Preserve$(z%)
       SELECT CASE LEFT$(p$, 2)
        CASE "b_"
         PutLine ("pop ax;mov word ptr ds:[" + p$ + "]")
        CASE "w_"
         PutLine ("pop word ptr ds:[" + p$ + "]")
        CASE "d_"
         PutLine ("pop word ptr ds:[" + p$ + "+2]")
         PutLine ("pop word ptr ds:[" + p$ + "]")
        CASE "s_"
         PutLine ("pop word ptr ds:[" + p$ + "]")
        CASE "p_"
         bp$(70) = MID$(p$, 3) + "~"
         SELECT CASE PointerType%(70)
          CASE IntWord%
           PutLine ("pop word ptr ds:[" + p$ + "]")
          CASE IntDoubleWord%
           PutLine ("pop word ptr ds:[" + p$ + "+2]")
           PutLine ("pop word ptr ds:[" + p$ + "]")
         END SELECT
       END SELECT
      NEXT
     END IF
   END IF
   pop% = VAL(MID$(LabelTable$, ptr%))
   IF t$ <> "m" THEN
    IF pop% = 0 THEN
     PutLine ("ret" + t$)
    ELSE
     PutLine ("ret" + t$ + " " + numi$(pop%))
    END IF
   ELSE
    PutLine ("ret")
   END IF
  
   IF PreserveFlag% = TRUE THEN
    PreserveFlag% = FALSE
    IF PreserveCount% <> -1 THEN
     CALL WriteFile("mr@preserve_" + LEFT$(currentsub$, LEN(currentsub$) - 1) + ":", FMcode%)
     PutLine ("mov bp,sp")
     FOR z% = 0 TO PreserveCount%
       p$ = Preserve$(z%)
       SELECT CASE LEFT$(p$, 2)
        CASE "b_"
         PutLine ("push word ptr ds:[" + p$ + "]")
        CASE "w_"
         PutLine ("push word ptr ds:[" + p$ + "]")
        CASE "d_"
         PutLine ("push word ptr ds:[" + p$ + "]")
         PutLine ("push word ptr ds:[" + p$ + "+2]")
        CASE "s_"
         PutLine ("push word ptr ds:[" + p$ + "]")
        CASE "p_"
         bp$(70) = MID$(p$, 3) + "~"
         SELECT CASE PointerType(70)
          CASE IntWord%
           PutLine ("push word ptr ds:[" + p$ + "]")
          CASE IntDoubleWord%
           PutLine ("push word ptr ds:[" + p$ + "]")
           PutLine ("push word ptr ds:[" + p$ + "+2]")
         END SELECT
       END SELECT
      NEXT
      PutLine ("jmp mr@reentry_" + LEFT$(currentsub$, LEN(currentsub$) - 1))
     END IF
    END IF

   IF SubFree$ <> "" THEN
    PutLine ("mr@cleanup_" + LEFT$(currentsub$, LEN(currentsub$) - 1) + ": dw " + SubFree$ + "0")
   END IF
   IF SwDebug% = TRUE THEN
    CALL WriteFile("dbg_" + LEFT$(currentsub$, LEN(currentsub$) - 1) + ": db '__" + LEFT$(currentsub$, LEN(currentsub$) - 1) + "',0" + CHR$(13) + CHR$(10), FMcode%)
   END IF
   CALL WriteFile("__" + LEFT$(currentsub$, LEN(currentsub$) - 1) + " endp", FMcode%)
   currentsub$ = ":"
   SubFree$ = ""
   updsub% = TRUE
  END IF
  EXIT SUB
 
  CASE ELSE
    CALL ProcessCommand3(h%)
END SELECT
END SUB

SUB ProcessCommand3 (h%)
SELECT CASE h%

 CASE &HE407
 ' "putpixelx"
 SELECT CASE bpt%(1)
   CASE IntConst%
    PutLine ("mov cx,*01")
   CASE IntByte%
    PutLine ("mov cl,ds:[%01];xor ch,ch")
   CASE IntWord%, IntDoubleWord%
    PutLine ("mov cx,ds:[%01]")
   CASE ELSE
    CALL ErrTypeMismatch(1)
 END SELECT
 SELECT CASE bpt%(2)
   CASE IntConst%
    PutLine ("mov dx,*02")
   CASE IntByte%
    PutLine ("mov dl,ds:[%02];xor dh,dh")
   CASE IntWord%, IntDoubleWord%
    PutLine ("mov dx,ds:[%02]")
   CASE ELSE
    CALL ErrTypeMismatch(2)
 END SELECT
 SELECT CASE bpt%(3)
   CASE IntConst%
    PutLine ("mov ax,*03")
   CASE IntByte%
    PutLine ("mov al,ds:[%03];xor ah,ah")
   CASE IntWord%, IntDoubleWord%
    PutLine ("mov ax,ds:[%03]")
   CASE ELSE
    CALL ErrTypeMismatch(3)
 END SELECT
 PutLine ("call	word ptr ds:[_putpixelx]")
 EXIT SUB


 CASE &H61F0
 ' "setgraphseg"
  SELECT CASE bpt%(1)
   CASE IntConst%
    PutLine ("mov word ptr ss:[mr@graph_seg],*01")
   CASE IntWord%
    PutLine ("mov ax,ds:[%01];mov word ptr ss:[mr@graph_seg],ax")
   CASE ELSE
    CALL ErrTypeMismatch(1)
  END SELECT
  EXIT SUB

 CASE &H8E63
 ' "microdelay"
 SELECT CASE bpt%(1)
  CASE IntConst%
   Split4 (bp$(1))
   PutLine ("mov bx," + Hex4$(vl&))
  CASE IntByte%
   PutLine ("mov bl,ds:[%01];xor bh,bh")
  CASE IntWord%, IntDoubleWord%
   PutLine ("mov bx,ds:[%01]")
  CASE ELSE
   ErrTypeMismatch (1)
 END SELECT
 PutLine ("call _microdelay")
 EXIT SUB

 CASE &HCA77
 ' "gcls"
  PutLine ("call	word ptr ds:[_gcls]")
  EXIT SUB

 CASE &H9BEB
 ' "setgraphmode"
  SELECT CASE bpt%(1)
   CASE IntConst%
    PutLine ("mov ax,*01")
   CASE IntByte%
    PutLine ("mov al,ds:[%01];xor ah,ah")
   CASE IntWord%, IntDoubleWord%
    PutLine ("mov ax,ds:[%01]")
   CASE ELSE
    CALL ErrTypeMismatch(1)
  END SELECT
  PutLine ("call _setmode")
  EXIT SUB

 CASE &H9188
 ' "putpixel"
 SELECT CASE bpt%(1)
   CASE IntConst%
    PutLine ("mov cx,*01")
   CASE IntByte%
    PutLine ("mov cl,ds:[%01];xor ch,ch")
   CASE IntWord%, IntDoubleWord%
    PutLine ("mov cx,ds:[%01]")
   CASE ELSE
    CALL ErrTypeMismatch(1)
 END SELECT
 SELECT CASE bpt%(2)
   CASE IntConst%
    PutLine ("mov dx,*02")
   CASE IntByte%
    PutLine ("mov dl,ds:[%02];xor dh,dh")
   CASE IntWord%, IntDoubleWord%
    PutLine ("mov dx,ds:[%02]")
   CASE ELSE
    CALL ErrTypeMismatch(2)
 END SELECT
 SELECT CASE bpt%(3)
   CASE IntConst%
    PutLine ("mov ax,*03")
   CASE IntByte%
    PutLine ("mov al,ds:[%03];xor ah,ah")
   CASE IntWord%, IntDoubleWord%
    PutLine ("mov ax,ds:[%03]")
   CASE ELSE
    CALL ErrTypeMismatch(3)
 END SELECT
 PutLine ("call	word ptr ds:[_putpixel]")
 EXIT SUB

 CASE &H736
 ' "setscreenseg"
  SELECT CASE bpt%(1)
   CASE IntConst%
    PutLine ("mov word ptr ss:[mr@screen_seg],*01")
   CASE IntWord%
    PutLine ("mov ax,ds:[%01];mov word ptr ss:[mr@screen_seg],ax")
   CASE ELSE
    CALL ErrTypeMismatch(1)
  END SELECT
  EXIT SUB

 CASE &HBDD2
 'CASE "if"
  LastValES$ = ""
  NestSP% = NestSP% + 1
  NestStack%(NestSP%) = NestIfThen%
  IfThenCnt% = IfThenCnt% + 1
  IfThenSP% = IfThenSP% + 1
  IfThenStack%(IfThenSP%) = IfThenCnt%
  CALL ProcessCMP
  PutLine ("jmp " + "_nif" + numi$(IfThenCnt%) + ";LL" + numi$(LocVarCount%) + ":")
  l$ = inline$
  CALL StringConst(l$, TRUE)
  IF INSTR(l$, "'") <> 0 THEN l$ = RTRIM$(LEFT$(l$, INSTR(l$, "'") - 1))
  IF INSTR(LCASE$(l$), " then ") <> 0 THEN

' if <exp> then <...>
   ptr% = INSTR(inline$, " then ")
   inline$ = LTRIM$(MID$(inline$, ptr% + 5))
   l$ = inline$
   CALL StringConst(l$, TRUE)
   t% = INSTR(l$, "'")
   IF t% <> 0 THEN l$ = RTRIM$(LEFT$(l$, t% - 1))
 
   IF INSTR(l$, ":") = 0 OR INSTR(l$, " ") = 0 OR LCASE$(LEFT$(l$, 3)) = "if " OR LCASE$(LEFT$(l$, 4)) = "sub " OR LCASE$(LEFT$(l$, 5)) = "goto " THEN
    CALL Block(l$, TRUE)
    IF errflag% = FALSE THEN
     ProcessLine
     IF fs& = LOF(FMcode%) + LEN(fb$(FMcode%)) AND errflag% = FALSE THEN CALL ReportWarning("^ Source line produces no compiled code!", 0, TRUE)
    END IF
   ELSE
    t$ = l$ + ":"
    ptr% = INSTR(t$, ":")
    DO
     l$ = LEFT$(t$, ptr% - 1)
     t$ = MID$(t$, ptr% + 1)
     CALL Block(l$, TRUE)
     IF errflag% = FALSE THEN
      ProcessLine
      IF fs& = LOF(FMcode%) + LEN(fb$(FMcode%)) AND errflag% = FALSE THEN CALL ReportWarning("^ Source line produces no compiled code!", 0, TRUE)
     END IF
     ptr% = INSTR(t$, ":")
    LOOP UNTIL ptr% = 0
   END IF
   PutLine ("_nif" + numi$(IfThenStack%(IfThenSP%)) + ":")
   IfThenSP% = IfThenSP% - 1
   NestSP% = NestSP% - 1
   LastValES$ = ""
  END IF
  EXIT SUB

 CASE &H6A94
 'CASE "else"
  LastValES$ = ""
  PutLine ("jmp _eif" + numi$(IfThenStack%(IfThenSP%)))
  PutLine ("_nif" + numi$(IfThenStack%(IfThenSP%)) + ":")
  ElsePtr%(IfThenSP%) = IfThenStack%(IfThenSP%)
  EXIT SUB

 CASE &H3B7A
 'CASE "endif"
  LastValES$ = ""
  CALL NestCheck(NestIfThen%)
  IF ElsePtr%(IfThenSP%) = IfThenStack%(IfThenSP%) THEN
   PutLine ("_eif" + numi$(IfThenStack%(IfThenSP%)) + ":")
   ElsePtr%(IfThenSP%) = 0
  ELSE
   PutLine ("_nif" + numi$(IfThenStack%(IfThenSP%)) + ":")
  END IF
  IfThenSP% = IfThenSP% - 1
  EXIT SUB

 CASE &HD3B9
 ' "cput"
  IF bpt%(1) = IntConst% THEN
   PutLine ("mov ax,*01;push ax")
  ELSE
   PutLine ("push word ptr ds:[%01]")
  END IF
  IF bpt%(2) = IntConst% THEN
   PutLine ("mov ax,*02;push ax")
  ELSE
   PutLine ("push word ptr ds:[%02]")
  END IF
  IF bpt%(3) = IntConst% THEN
   PutLine ("mov ax,*03;push ax")
  ELSE
   PutLine ("push word ptr ds:[%03]")
  END IF
  PutLine ("call _cput")
  EXIT SUB

 CASE &HC2BD
 ' "swap"
  IF bpt%(1) <> bpt%(2) THEN CALL ReportErr("^ SWAPped types must match", bpsp%(1), TRUE): EXIT SUB
  SELECT CASE bpt%(1)
   CASE IntByte%
    PutLine ("mov al,byte ptr ds:[%01];xchg al,byte ptr ds:[%02];mov byte ptr ds:[%01],al")
   CASE IntWord%, StringType%
    PutLine ("mov ax,word ptr ds:[%01];xchg ax,word ptr ds:[%02];mov word ptr ds:[%01],ax")
   CASE IntDoubleWord%
    PutLine ("mov ax,word ptr ds:[%01];xchg ax,word ptr ds:[%02];mov word ptr ds:[%01],ax")
    PutLine ("mov ax,word ptr ds:[%01+2];xchg ax,word ptr ds:[%02+2];mov word ptr ds:[%01+2],ax")
   CASE ELSE
    CALL ErrTypeMismatch(1)
  END SELECT
  EXIT SUB

 'CASE "input"
 CASE &H5B9F
  IF bpt%(1) <> StringType% THEN CALL ErrTypeMismatch(1)
  PutLine ("mov bx,ds:[%01];call _mem_free")
  IF bpp% > 1 THEN
   SELECT CASE bpt%(2)
    CASE IntConst%
     PutLine ("mov bx,*02")
    CASE IntByte%
     PutLine ("mov bl,byte ptr ds:[%02];xor bh,bh")
    CASE IntWord%
     PutLine ("mov bx,ds:[%02]")
    CASE IntDoubleWord%
     PutLine ("mov bx,ds:[%02]")
    CASE ELSE
     CALL ErrTypeMismatch(2)
   END SELECT
  ELSE
   PutLine ("mov bx,78")
  END IF
  IF bpp% > 2 THEN
   SELECT CASE bpt%(3)
    CASE IntConst%
     PutLine ("mov cx,*03")
    CASE IntByte%, IntWord%, IntDoubleWord%
     PutLine ("mov cl,byte ptr ds:[%03]")
    CASE ELSE
     CALL ErrTypeMismatch(3)
   END SELECT
  ELSE
   PutLine ("mov cl,' '")
  END IF
  PutLine ("call _keyboard_input;mov ds:[%01],di")
  EXIT SUB

 CASE &H1B9F
 '"exit"
  SELECT CASE bp$(1)
   CASE "for"
    PutLine ("jmp _fornext" + numi$(fornextstack%(ForNextSP%)) + "end")
   CASE "sub"
    PutLine ("jmp __" + LEFT$(currentsub$, LEN(currentsub$) - 1) + "_end")
   CASE "while"
    PutLine ("jmp _wnd" + numi$(WhileWendStack%(WhileWendSP%)))
   CASE ELSE
    CALL ReportErr("^ Expected FOR/SUB/WHILE", bpsp%(1), TRUE)
  END SELECT
  EXIT SUB



 CASE &H95A7
 ' "atexit"
  atexit% = TRUE
  IF ASC(bp$(1)) = 58 THEN bp$(1) = LEFT$(bp$(1), LEN(bp$(1)) - 1)  ' :
  PutLine ("mov ax,offset __" + LCASE$(bp$(1)) + ";call _atexit")
  EXIT SUB

 CASE &H4CE2
 ' "delay"
 SELECT CASE bpt%(1)
  CASE IntConst%
   Split4 (bp$(1))
   PutLine ("mov bx," + Hex4$(vl&))
  CASE IntByte%
   PutLine ("mov bl,ds:[%01];xor bh,bh")
  CASE IntWord%, IntDoubleWord%
   PutLine ("mov bx,ds:[%01]")
  CASE ELSE
   ErrTypeMismatch (1)
 END SELECT
 PutLine ("call _delay")
 EXIT SUB

 CASE &HF657
 ' "flock"
 CALL LockUnlockSetup
 PutLine ("call _flock")
 EXIT SUB

 CASE &HE0D8
 ' "funlock"
 CALL LockUnlockSetup
 PutLine ("call _funlock")
 EXIT SUB

 CASE &HFE19
 ' "fosflush"
 PutLine ("call _fos_flush")
 EXIT SUB

 CASE &HE33F
 ' "fostx"
 SELECT CASE bpt%(1)
  CASE StringType%
   PutLine ("mov si,ds:[%01]")
  CASE StrConst%
   PutLine ("mov si,offset %01;call _str_cs_ds;mov bx,si")
  CASE ELSE
   ErrTypeMismatch (1)
 END SELECT
 PutLine ("call _fos_tx")
 IF bpt%(1) = StrConst% THEN PutLine ("call _mem_free")
 EXIT SUB

 CASE &H6C68
 ' "fosdeinit"
 PutLine ("call _fos_deinit")
 EXIT SUB

 CASE &HD276
 ' "soundon"
 SELECT CASE bpt%(1)
 CASE IntConst%
  PutLine ("mov bx,*01")
 CASE IntByte%
  PutLine ("mov bl,ds:[%01];xor bh,bh")
 CASE IntWord%, IntDoubleWord%
  PutLine ("mov bx,ds:[%01]")
 END SELECT
 PutLine ("call _soundon")
 EXIT SUB

 CASE &H18F6
 ' "soundoff"
 PutLine ("call _soundoff")
 EXIT SUB

 CASE &H6F5B
 ' "screensave"
 PutLine ("call _screensave")
 EXIT SUB

 CASE &H70F9
 PutLine ("call _screenrestore")
 EXIT SUB

 CASE &H8966
 ' "finput"
 IF bpt%(2) <> StringType% THEN CALL ErrTypeMismatch(2)
 PutLine ("mov bx,ds:[%02];call _mem_free")
 CALL PutHandle(1)
 PutLine ("call _finput;mov ds:[%02],di")
 EXIT SUB

 CASE &HD925
 ' "static"
  PutLine ("")
  EXIT SUB

 CASE &H6B91
 ' "memdebug"
  PutLine ("call _mem_usage_dump")
  EXIT SUB

 CASE &HC129
 ' "push"
  FOR i% = 1 TO bpp%
   SELECT CASE bpt%(i%)
    CASE IntByte%, IntWord%, StringType%
     PutLine ("push word ptr ds:[%" + numi0$(i%) + "]")
    CASE IntDoubleWord%
     PutLine ("push word ptr ds:[%" + numi0$(i%) + "]")
     PutLine ("push word ptr ds:[%" + numi0$(i%) + "+2]")
    CASE ELSE
     CALL ErrTypeMismatch(i%)
   END SELECT
  NEXT
  EXIT SUB

 CASE &HBD8B
 ' "pop"
  FOR i% = 1 TO bpp%
   SELECT CASE bpt%(i%)
    CASE IntByte%
     PutLine ("pop ax;mov byte ptr ds:[%" + numi0$(i%) + "],al")
    CASE IntWord%, StringType%
     PutLine ("pop word ptr ds:[%" + numi0$(i%) + "]")
    CASE IntDoubleWord%
     PutLine ("pop word ptr ds:[%" + numi0$(i%) + "+2]")
     PutLine ("pop word ptr ds:[%" + numi0$(i%) + "]")
    CASE ELSE
     CALL ErrTypeMismatch(i%)
   END SELECT
  NEXT
  EXIT SUB

 CASE ELSE
  CALL ProcessCommand4
END SELECT
END SUB

SUB ProcessCommand4

IF INSTR(InternalSub$, " " + bp$(0) + ":") <> 0 THEN
  lastivar2$ = ""
  lastivar1$ = ""

  lastsvar2$ = ""
  lastsvar1$ = ""

  isptr% = INSTR(InternalSub$, " " + bp$(0) + ":") + LEN(bp$(0)) + 2

  sp$ = MID$(InternalSub$, isptr%)
  sp$ = LEFT$(sp$, INSTR(sp$, " ") - 1)
 

  callmark% = FALSE

  lastax$ = ""

  spp% = 1
  pc% = 0  ' parameter count
  FOR z% = 1 TO bpp%
   pc% = pc% + 1
   t$ = MID$(sp$, spp%, 1)
   spp% = spp% + 1
   SELECT CASE bpt%(z%)
    CASE IntConst%
     bpreg$ = "bx"
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
    bpreg$ = "bp"
    CASE IntByte%
     bpreg$ = "bx"
     IF t$ <> "@" AND t$ <> "%" AND t$ <> "&" THEN CALL ErrParm(z%, t$)
     PutLine ("mov bl,ds:[%" + numi0$(z%) + "];xor bh,bh;push bx")
     bpreg$ = "bp"
    CASE IntWord%
     bpreg$ = "bx"
     IF t$ <> "%" AND t$ <> "&" THEN CALL ErrParm(z%, t$)
     PutLine ("push word ptr ds:[%" + numi0$(z%) + "]")
     bpreg$ = "bp"
    CASE StringType%
     bpreg$ = "bx"
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
     bpreg$ = "bp"
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
     bpreg$ = "bx"
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
     bpreg$ = "bp"
    CASE StrConst%
     IF t$ <> "$" THEN CALL ErrParm(z%, t$)
     PutLine ("mov si,offset %" + numi0$(z%) + ";call _str_cs_ds_mark;push si")
     callmark% = TRUE
    CASE BundleType%
     PutLine ("mov ax,offset %" + numi0$(z%) + ";push ax")
    CASE ELSE
     CALL ErrTypeMismatch(z%)
   END SELECT
  NEXT
 IF LEN(sp$) <> pc% THEN CALL ReportWarning("^ Argument count mismatch", bpsp%(bpp%) + LEN(bp$(bpp%)), TRUE)
 PutLine ("call _" + LCASE$(bp$(0)))
 IF callmark% = TRUE THEN PutLine ("call _str_release")
 BPval$ = ""
 LastValES$ = ""

 EXIT SUB
ELSE
  CALL ReportErr("Compiler error (report to author). Unmatched CRC for keyword: " + bp$(0), 0, FALSE)
END IF
END SUB

SUB ProcessPrintF (z%)
'SELECT CASE bpt%(z%)
' CASE StringType%
'  PutLine ("mov di,ds:[%" + numi0$(z%) + "]")
' CASE StrConst%
'  PutLine ("mov si,offset %" + numi0$(z%) + ";call _str_cs_ds_mark;push si;mov di,si")
'  release% = TRUE
'END SELECT
'spa% = 0
'FOR i% = z% + 1 TO bpp%
' SELECT CASE bpt%(i%)
'  CASE StringType%
'   PutLine ("push word ptr ds:[%" + numi0$(i%) + "]")
'   spa% = spa% + 2
'  CASE StrConst%
'   PutLine ("mov si,offset %" + numi0$(i%) + ";call _str_cs_ds_mark;push si")
'   release% = TRUE
'   spa% = spa% + 2
'  CASE IntByte%
'   PutLine ("mov al,byte ptr ds:[%" + numi0$(i%) + "];cbw;push ax")
'   spa% = spa% + 2
'  CASE IntWord%
'   PutLine ("push word ptr ds:[%" + numi0$(i%) + "]")
'   spa% = spa% + 2
'  CASE IntDoubleWord%
'   IF Processor% >= 386 THEN
'    PutLine ("push dword ptr ds:[%" + numi0$(i%) + "]")
'   ELSE
'    PutLine ("push word ptr ds:[%" + numi0$(i%) + "];push word ptr ds:[%" + numi0$(i%) + "+2]")
'   END IF
'  spa% = spa% + 4
' END SELECT
'NEXT

'PutLine ("call _printf")
's& = spa%
'IF spa% <> 0 THEN PutLine ("add sp," + Hex4$(s&))
'IF release% = TRUE THEN PutLine ("call _str_release")

END SUB

SUB SubMarg
tcount% = 0
parmcount% = bpp% - 1
FOR i% = bpp% TO 1 STEP -1
 SELECT CASE bpt%(i%)
  CASE IntConst%
   bp$(70) = "_t" + numi$(tcount%) + "%"
   bpt%(70) = IntWord%
   CALL AddIntVar(bp$(70), 2, 70)
   PutLine ("mov word ptr ds:[%70],*" + numi0$(i%) + ";mov ax,offset %70;push ax")
   tcount% = tcount% + 1
  CASE IntByte%, IntWord%, IntDoubleWord%, StringType%
   PutLine ("mov ax,offset %" + numi0$(i%) + ";push ax")
  CASE StrConst%
   PutLine ("mov si,offset %" + numi0$(i%) + ";call _str_cs_ds_mark")
   bp$(70) = "_t" + numi$(tcount%) + "$"
   bpt%(70) = IntWord%
   CALL AddIntVar(bp$(70), 2, 70)
   PutLine ("mov ds:[%70],si;mov ax,offset %70;push ax")
   tcount% = tcount% + 1
   callmark% = TRUE
 END SELECT
NEXT
IF parmcount% = 0 THEN
 PutLine ("xor cx,cx")
ELSE
 PutLine ("mov cx," + numi$(parmcount%))
END IF
PutLine ("call __" + LEFT$(bp$(1), LEN(bp$(1)) - 1))
IF parmcount% <> 0 THEN PutLine ("add sp," + numi$(parmcount% * 2))
IF callmark% = TRUE THEN PutLine ("call _str_release")
END SUB

