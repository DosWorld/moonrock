DECLARE SUB ReportWarning (E$, indent%, showline%)
DECLARE FUNCTION PointerType% (bpptr%)
DECLARE FUNCTION PointerSize% (bpptr%)
DECLARE SUB PutLine.Pointer (l$, pp%, ptr%)
DECLARE FUNCTION CVAL& (s$)

DECLARE SUB CheckDS ()
DECLARE SUB Split4 (s$)
DECLARE SUB AddIntVar (tmpv$, s%, bpptr%)
DECLARE SUB AddStringVar (tmpv$, bpptr%)
DECLARE SUB Flushfile (h%)
DECLARE SUB ReportErr (E$, indent%, showline%)
DECLARE SUB WriteFile (l$, h%)
DECLARE FUNCTION SetES$ (v$)
DECLARE FUNCTION numi0$ (tmp%)
DECLARE FUNCTION Lexpand$ (l$)
DECLARE FUNCTION unique% (u$)
DECLARE FUNCTION numi$ (tmp%)
DECLARE FUNCTION MakeVar$ (v$, tt%)
DECLARE FUNCTION numl$ (tmp&)

DECLARE FUNCTION Hex2$ (l%)
DECLARE FUNCTION Hex4$ (l&)


'$INCLUDE: 'mr.inc'

SUB AddIntVar (tmpv$, s%, bpptr%)
v$ = UCASE$(LEFT$(tmpv$, LEN(tmpv$) - 1))
SELECT CASE s%
 CASE 1
  t$ = "b"
 CASE 2
  t$ = "w"
 CASE 4
  t$ = "d"
 CASE IS > 4
  t$ = "o"
END SELECT


IF INSTR(IntTable$, " " + t$ + v$ + " ") = 0 AND INSTR(IntTable$, " " + t$ + numi$(SubCounter%) + v$ + " ") = 0 THEN
 IF INSTR(validcommand$, " " + v$ + " ") <> 0 OR INSTR(validnumfunc$, " " + v$ + " ") <> 0 OR INSTR(validstrfunc$, " " + v$ + " ") <> 0 OR INSTR(validnum1func$, " " + v$ + " ") <> 0 THEN CALL ReportWarning("^ Reserved name used for variable", bpsp%( _
bpptr%), TRUE)
 intcount% = intcount% + 1
 IF INSTR(CommonList$, " " + LCASE$(tmpv$) + " ") = 0 THEN
  IntTable$ = IntTable$ + t$ + numi$(SubCounter%) + v$ + " "
  IF SwPartial% = TRUE THEN
   SELECT CASE s%
    CASE 1
     CALL WriteFile(RIGHT$(t$, 1) + "_" + numi$(SubCounter%) + "@" + UCASE$(v$) + " db 1 dup (?)", FMvar%)
    CASE 2
     CALL WriteFile(RIGHT$(t$, 1) + "_" + numi$(SubCounter%) + "@" + UCASE$(v$) + " dw 1 dup (?)", FMvar%)
    CASE 4
     CALL WriteFile(RIGHT$(t$, 1) + "_" + numi$(SubCounter%) + "@" + UCASE$(v$) + " dw 2 dup (?)", FMvar%)
    CASE ELSE
     CALL WriteFile(RIGHT$(t$, 1) + "_" + numi$(SubCounter%) + "@" + UCASE$(v$) + " db " + numi$(s%) + " dup (?)", FMvar%)
   END SELECT
  ELSE
   CALL WriteFile(RIGHT$(t$, 1) + "_" + numi$(SubCounter%) + "@" + UCASE$(v$) + "	equ 0" + HEX$(DataPtr&) + "h", FMvar%)
  END IF
  DataPtr& = DataPtr& + s%
  CheckDS
 ELSE
  IntTable$ = IntTable$ + t$ + v$ + " "
  IF SwPartial% = TRUE THEN
   IF SwMain% = FALSE THEN
    SELECT CASE s%
     CASE 1
      CALL WriteFile("extrn " + RIGHT$(t$, 1) + "_" + UCASE$(v$) + ":BYTE", FMvar%)
     CASE 2
      CALL WriteFile("extrn " + RIGHT$(t$, 1) + "_" + UCASE$(v$) + ":WORD", FMvar%)
     CASE 4
'      CALL WriteFile("extrn " + RIGHT$(t$, 1) + "_" + UCASE$(v$) + ":DWORD", FMvar%)
      CALL WriteFile("extrn " + RIGHT$(t$, 1) + "_" + UCASE$(v$) + ":WORD", FMvar%)
     CASE ELSE
      CALL WriteFile("extrn " + RIGHT$(t$, 1) + "_" + UCASE$(v$) + ":NEAR", FMvar%)
    END SELECT
   ELSE
    CALL WriteFile("public " + RIGHT$(t$, 1) + "_" + UCASE$(v$), FMvar%)
    SELECT CASE s%
     CASE 1
      CALL WriteFile(RIGHT$(t$, 1) + "_" + UCASE$(v$) + " db 1 dup (?)", FMvar%)
     CASE 2
      CALL WriteFile(RIGHT$(t$, 1) + "_" + UCASE$(v$) + " dw 1 dup (?)", FMvar%)
     CASE 4
      CALL WriteFile(RIGHT$(t$, 1) + "_" + UCASE$(v$) + " dw 2 dup (?)", FMvar%)
     CASE ELSE
      CALL WriteFile(RIGHT$(t$, 1) + "_" + UCASE$(v$) + " dw " + numi$(s%) + " dup (?)", FMvar%)
    END SELECT
   END IF
  ELSE
   CALL WriteFile(RIGHT$(t$, 1) + "_" + UCASE$(v$) + "	equ 0" + HEX$(DataPtr&) + "h", FMvar%)
  END IF
  DataPtr& = DataPtr& + s%
  CheckDS
 END IF
END IF
IF PreserveFlag% = TRUE THEN
 IF INSTR(PreserveList$, " " + t$ + v$ + " ") = 0 THEN
  IF INSTR(CommonList$, " " + LCASE$(tmpv$) + " ") = 0 THEN
   PreserveCount% = PreserveCount% + 1
   SELECT CASE s%
    CASE 1
     t% = IntByte%
    CASE 2
     t% = IntWord%
    CASE 4
     t% = IntDoubleWord%
   END SELECT
   Preserve$(PreserveCount%) = MakeVar(tmpv$, t%)
   PreserveList$ = PreserveList$ + t$ + v$ + " "
  END IF
 END IF
END IF
END SUB

SUB AddLabel (l$, parmcount%)
labelcount% = labelcount% + 1
l$ = LCASE$(LEFT$(l$, LEN(l$) - 1))
IF INSTR(validcommand$, " " + UCASE$(l$) + " ") <> 0 OR INSTR(validnumfunc$, " " + UCASE$(v$) + " ") <> 0 OR INSTR(validstrfunc$, " " + UCASE$(v$) + " ") <> 0 THEN CALL ReportWarning("^ Reserved name used for label", bpsp%(bpptr%), TRUE)
IF INSTR(LabelTable$, " " + l$ + ":") = 0 THEN
 LabelTable$ = LabelTable$ + l$ + ":" + numi$(parmcount%)
  fb$(FMcode%) = fb$(FMcode%) + "__" + l$ + " proc near" + CHR$(13) + CHR$(10)
' fb$(FMcode%) = fb$(FMcode%) + "__" + l$ + ":" + CHR$(13) + CHR$(10)
ELSE
 CALL ReportErr("^ Duplicate label definition", 0, TRUE)
END IF
END SUB

SUB AddStringVar (tmpv$, bpptr%)
v$ = UCASE$(LEFT$(tmpv$, LEN(tmpv$) - 1))
IF INSTR(StrTable$, " " + v$ + " ") = 0 AND INSTR(StrTable$, " " + numi$(SubCounter%) + v$ + " ") = 0 THEN
 IF INSTR(validcommand$, " " + v$ + " ") <> 0 OR INSTR(validnumfunc$, " " + v$ + " ") <> 0 OR INSTR(validstrfunc$, " " + v$ + " ") <> 0 OR INSTR(validnum1func$, " " + v$ + " ") <> 0 THEN CALL ReportWarning("^ Reserved name used for variable", bpsp%( _
bpptr%), TRUE)
  IF INSTR(CommonList$, " " + LCASE$(tmpv$) + " ") <> 0 THEN
   StrTable$ = StrTable$ + v$ + " "

  ELSE
   StrTable$ = StrTable$ + numi$(SubCounter%) + v$ + " "
   IF INSTR(v$, "$SC_") = 0 AND v$ <> "MR@NULL" THEN SubFree$ = SubFree$ + MakeVar$(v$ + "$", StringType%) + ","
'   IF INSTR(v$, "$SC_") = 0 AND v$ <> "MR@NULL" THEN
'    PreserveCount% = PreserveCount% + 1
'    Preserve$(PreserveCount%) = MakeVar$(v$ + "$", StringType%)
'   END IF
  END IF
  IF INSTR(v$, "$SC_") = 0 AND v$ <> "mr@NULL" THEN
   strcount% = strcount% + 1
   IF SwPartial% = TRUE THEN
    IF INSTR(CommonList$, " " + LCASE$(tmpv$) + " ") <> 0 AND SwMain% = FALSE THEN
     CALL WriteFile("extrn " + MakeVar$(v$ + "$", StringType%) + ":WORD", FMvar%)
    ELSE
     IF INSTR(CommonList$, " " + LCASE$(tmpv$) + " ") <> 0 AND SwMain% = TRUE THEN
      CALL WriteFile("public " + MakeVar$(v$ + "$", StringType%), FMvar%)
     END IF
     CALL WriteFile(MakeVar$(v$ + "$", StringType%) + " dw 1 dup (?)", FMvar%)
    END IF
   ELSE
    CALL WriteFile(MakeVar$(v$ + "$", StringType%) + "	equ 0" + HEX$(DataPtr&) + "h", FMvar%)
   END IF
   DataPtr& = DataPtr& + 2
   CheckDS
  END IF
END IF
IF PreserveFlag% = TRUE THEN
   IF INSTR(PreserveList$, " " + LCASE$(tmpv$) + " ") = 0 THEN
    IF INSTR(v$, "$SC_") = 0 AND v$ <> "MR@NULL" THEN
     IF INSTR(CommonList$, " " + LCASE$(tmpv$) + " ") = 0 THEN
      PreserveCount% = PreserveCount% + 1
      Preserve$(PreserveCount%) = MakeVar$(v$ + "$", StringType%)
      PreserveList$ = PreserveList$ + LCASE$(tmpv$) + " "
     END IF
    END IF
   END IF
END IF
END SUB

SUB BlankStringConst (l$)
DO
 ptr% = INSTR(l$, CHR$(34))
 IF ptr% <> 0 THEN
  ptr2% = INSTR(ptr% + 1, l$, CHR$(34))
  IF ptr2% <> 0 THEN MID$(l$, ptr%, ptr2% - ptr% + 1) = SPACE$(ptr2% - ptr% + 1)
 END IF
LOOP UNTIL ptr% = 0 OR ptr2% = 0
END SUB

SUB Block (tmp$, addint%)
LastBP0$ = bp$(0)

FOR i% = 0 TO 70
 bp$(i%) = ""
 bpt%(i%) = UnknownType%
 bpart%(i%) = 0
 bpterm$(i%) = ""
 bppr%(i%) = FALSE
NEXT


blockredo:

ConstCount% = 0

z% = 0
plustwo% = FALSE
l$ = tmp$
sp% = 0


DO
 bpsp%(z%) = sp%

 ptr% = sinstr%(l$, Term$)

 IF ptr% <> 0 THEN
  IF INSTR(InclTerm$, MID$(l$, ptr%, 1)) = 0 THEN
   ' strip the terminator
   IF MID$(l$, ptr%, 1) = "," THEN bpterm$(z%) = ","
   bp$(z%) = LEFT$(l$, ptr% - 1)
  ELSE
   ' leave it in
   bp$(z%) = LEFT$(l$, ptr% - 1)
   IF bp$(z%) = "" THEN
    bp$(z%) = MID$(l$, ptr%, 1): ' this is the terminator
   ELSE
    bp$(z% + 1) = MID$(l$, ptr%, 1)
    plustwo% = TRUE
   END IF
  END IF
  t% = LEN(l$) - ptr%
  l$ = LTRIM$(MID$(l$, ptr% + 1))
  sp% = sp% + ptr% + (t% - LEN(l$))
  IF LEFT$(bp$(z%), 4) = "$SC_" THEN
   ts% = VAL(MID$(bp$(z%), 5))
   sp% = sp% + LEN(sc$(ts%)) - LEN(bp$(z%))
  END IF
 ELSE
  bp$(z%) = l$
  l$ = ""
 END IF
 bpt%(z%) = UnknownType%
 bpar$(z%) = ""
 IF INSTR(bp$(z%), ".") <> 0 THEN
  IF INSTR("@%&$~", RIGHT$(bp$(z%), 1)) <> 0 THEN MID$(bp$(z%), INSTR(bp$(z%), ".")) = "_"
 END IF
 IF LEFT$(bp$(z%), 1) = "%" THEN
  ttptr% = INSTR(ConstTable$, " " + UCASE$(bp$(z%)) + "=")
  IF ttptr% <> 0 THEN
   t$ = MID$(ConstTable$, ttptr% + LEN(bp$(z%)) + 2)
   ttptr% = INSTR(t$, " ")
   IF ttptr% <> 0 THEN t$ = LEFT$(t$, ttptr% - 1)
   bp$(z%) = numl$(CVAL(t$))
   bpt%(z%) = IntConst%
   ConstCount% = ConstCount% + 1
  ELSE
   IF z% <> 0 AND bp$(0) <> "set" THEN CALL ReportErr("^ Undefined constant", bpsp%(z%), TRUE): bp$(z%) = "0"
  END IF
 END IF
 IF bp$(0) = "sub" THEN addint% = FALSE
 IF LEN(bp$(z%)) > 1 THEN
  SELECT CASE RIGHT$(bp$(z%), 1)
   CASE "@"
    bpt%(z%) = IntByte%
    IF addint% = TRUE THEN CALL AddIntVar(bp$(z%), 1, z%)
   CASE "%"
    bpt%(z%) = IntWord%
    IF bp$(z% + 1) <> "[" AND addint% = TRUE THEN
     CALL AddIntVar(bp$(z%), 2, z%)
    END IF
   CASE "&"
    bpt%(z%) = IntDoubleWord%
    IF bp$(z% + 1) <> "[" AND addint% = TRUE THEN
     CALL AddIntVar(bp$(z%), 4, z%)
    END IF
   CASE "^"
    bpt%(z%) = BundleType%
   CASE "$"
    bpt%(z%) = StringType%
    IF bp$(z% + 1) <> "[" AND addint% = TRUE THEN
     CALL AddStringVar(bp$(z%), z%)
     IF LEFT$(bp$(z%), 4) = "$SC_" THEN bpt%(z%) = StrConst%
    END IF
   CASE ":"
    bpt%(z%) = Label%
   CASE "~"
    IF INSTR(PtrTable$, ":" + UCASE$(bp$(z%)) + " ") = 0 THEN
     IF bp$(0) <> "pointer" THEN CALL ReportErr("^ Pointer not defined", bpsp%(z%), TRUE)
    END IF
    IF z% > 0 AND SourceType% = Code% THEN
     IF bp$(z% - 1) = "[" THEN
      bpt%(z%) = PointerRef%
     ELSE
      bpt%(z%) = PointerType%(z%)
      'bpt%(z%) = Pointer%
     END IF
     IF addint% = TRUE AND PreserveFlag% = TRUE THEN
      IF INSTR(PreserveList$, " " + bp$(z%) + " ") = 0 THEN
       PreserveList$ = PreserveList$ + bp$(z%) + " "
       PreserveCount% = PreserveCount% + 1
       Preserve$(PreserveCount%) = MakeVar(bp$(z%), Pointer%)
      END IF
     END IF
      
    ELSE
     IF SourceType% = Code% THEN
      bpt%(z%) = PointerType%(z%)
     ELSE
      bpt%(z%) = Pointer%
     END IF
    END IF
  END SELECT
 ELSE
  IF bp$(z%) = "?" THEN bpt%(z%) = Default%
 END IF
 IF INSTR(bp$(z%), ":") <> 0 THEN bpt%(z%) = Label%
 IF INSTR("0123456789", LEFT$(bp$(z%), 1)) <> 0 AND bp$(z%) <> "" THEN
  'PRINT bp$(z%)
  bpt%(z%) = IntConst%
  bp$(z%) = numl$(CVAL(bp$(z%)))
  ConstCount% = ConstCount% + 1
  GOTO blockskip
 END IF
 t$ = " " + UCASE$(bp$(z%)) + " "
 IF INSTR(validcommand$, t$) <> 0 THEN bpt%(z%) = CmdType%: bp$(z%) = LCASE$(bp$(z%)): GOTO blockskip
 IF INSTR(validnumfunc$, t$) <> 0 THEN
  bpt%(z%) = NumFunc%
  bp$(z%) = LCASE$(bp$(z%))
  IF bp$(z%) = "true" THEN
   bp$(z%) = "-1"
   bpt%(z%) = IntConst%
  END IF
  IF bp$(z%) = "false" THEN
   bp$(z%) = "0"
   bpt%(z%) = IntConst%
  END IF
  GOTO blockskip
 END IF
 IF INSTR(validstrfunc$, t$) <> 0 THEN bpt%(z%) = StrFunc%: bp$(z%) = LCASE$(bp$(z%)): GOTO blockskip
 IF INSTR(validnum1func$, t$) <> 0 THEN bpt%(z%) = Num1Func%: bp$(z%) = LCASE$(bp$(z%))
blockskip:
 IF INSTR(Term$, bp$(z%)) <> 0 THEN bpt%(z%) = TermType%
 IF INSTR(Term$, bp$(z% + 1)) <> 0 THEN bpt%(z% + 1) = TermType%
 IF bpt%(z%) = UnknownType% THEN
  IF INSTR("+-/*", t$) = 0 AND bp$(0) <> "call" AND bp$(0) <> "sub" AND LEFT$(bp$(z%), 1) <> "%" THEN
  'AND SourceType% = Code%
   t$ = UCASE$(bp$(z%))
   FOR j% = 1 TO TypePtr%
    IF TypeName$(j%) = t$ THEN
     ptr% = INSTR(UCASE$(tmp$), t$)
     tmp$ = LEFT$(tmp$, ptr% - 1) + TypeParm$(j%) + MID$(tmp$, ptr% + LEN(t$) + 1)
     GOTO blockredo
    END IF
   NEXT
   IF SourceType% = Code% THEN
    IF z% > 0 THEN
     IF bp$(z% - 1) = "goto" THEN
      bpt%(z%) = Label%
     ELSE
      IF bp$(z% - 1) <> "codeptr" AND bp$(z% - 1) <> "call" THEN CALL ReportErr("^ Unknown keyword or variable", bpsp%(z%), TRUE)
     END IF
    ELSE
     CALL ReportErr("^ Unknown keyword or variable", bpsp%(z%), TRUE)
    END IF
   END IF
  END IF
 END IF
 IF bp$(z%) <> "" THEN
  z% = z% + 1
  IF plustwo% = TRUE THEN z% = z% + 1
 END IF
 plustwo% = FALSE
'LOOP UNTIL ptr% = 0 OR ptr% = 32000
LOOP UNTIL ptr% = 0
'OR LEN(l$) = 0

bpp% = z% - 1

IF INSTR(tmp$, "[") <> 0 THEN
  ardef% = FALSE
  FOR z% = -1 TO bpp%
  IF bp$(z% + 1) = "[" THEN
   IF bpt%(z% + 2) = PointerRef% THEN
    bppr%(z% + 2) = TRUE
    FOR j% = z% + 1 TO bpp%
     bp$(j%) = bp$(j% + 1)
     bpt%(j%) = bpt%(j% + 1)
     bpsp%(j%) = bpsp%(j% + 1)
     bpar$(j%) = bpar$(j% + 1)
     bpart%(j%) = bpart%(j% + 1)
     bppr%(j%) = bppr%(j% + 1)
    NEXT
   
    bpt%(z% + 1) = PointerSize%(z% + 1)

    bpp% = bpp% - 1
   ELSE    ' array
    bpar$(z%) = bp$(z% + 2)
    bpart%(z%) = bpt%(z% + 2)
    plusfactor% = 2
    IF bpar$(z%) = "" THEN bpar$(z%) = "ARRAY_BY_REF": bpart%(z%) = TermType%: plusfactor% = 1
    FOR j% = z% + 1 TO bpp%
'     FOR t% = 0 TO bpp%
'      PRINT bp$(t%) + " ";
'     NEXT
'     PRINT
     bp$(j%) = bp$(j% + plusfactor%)
     bpt%(j%) = bpt%(j% + plusfactor%)
     bpsp%(j%) = bpsp%(j% + plusfactor%)
     bpar$(j%) = bpar$(j% + plusfactor%)
     bpart%(j%) = bpart%(j% + plusfactor%)
     bppr%(j%) = bppr%(j% + plusfactor%)
    NEXT
'     FOR t% = 0 TO bpp%
'      PRINT bp$(t%) + " ";
'     NEXT
'     PRINT
'    IF ardef% = TRUE THEN
     bpp% = bpp% - plusfactor%
'    ELSE
'     bpp% = bpp% - 2
'    END IF
   END IF
  END IF
 NEXT
END IF
t$ = ""


' now fold constants
'IF ConstCount% > 1 THEN
' FOR i% = 0 TO bpp%
'  IF bpt%(i%) = IntConst% THEN
'   IF i% + 2 <= bpp% AND bpt%(i% + 2) = IntConst% THEN
'    s& = CVAL(bp$(i%))
'    OK% = TRUE
'    SELECT CASE bp$(i% + 1)
'     CASE "+"
'      s& = s& + CVAL(bp$(i% + 2))
'     CASE "-"
'      s& = s& - CVAL(bp$(i% + 2))
'     CASE "*"
'      s& = s& * CVAL(bp$(i% + 2))
'     CASE "\"
'      s& = s& \ CVAL(bp$(i% + 2))
'     CASE "/"
'      s& = s& / CVAL(bp$(i% + 2))
'     CASE "AND"
'      s& = s& AND CVAL(bp$(i% + 2))
'     CASE "OR"
'      s& = s& OR CVAL(bp$(i% + 2))
'     CASE "XOR"
'      s& = s& XOR CVAL(bp$(i% + 2))
'     CASE "MOD"
'      s& = s& MOD CVAL(bp$(i% + 2))
'     CASE ELSE
'      ' unknown operator!
'      OK% = FALSE
'    END SELECT
'    IF OK% = TRUE THEN
'     FOR j% = i% + 1 TO bpp%
'      bp$(j%) = bp$(j% + 2)
'      bpt%(j%) = bpt%(j% + 2)
'      bpsp%(j%) = bpsp%(j% + 2)
'      bpar$(j%) = bpar$(j% + 2)
'      bpart%(j%) = bpart%(j% + 2)
'      bppr%(j%) = bppr%(j% + 2)
'     NEXT
'     bp$(i%) = numl$(s&)
'     bpp% = bpp% - 2
'     i% = i% - 1
'    END IF
'   END IF
'  END IF
' NEXT
'END IF
bp$(bpp% + 1) = ""

END SUB

FUNCTION CVAL& (s$)
s1$ = s$
SELECT CASE UCASE$(RIGHT$(s1$, 1))
 CASE "H"
  CVAL& = VAL("&H" + LEFT$(s1$, LEN(s1$) - 1))
 CASE "B"
 CASE ELSE
  CVAL& = VAL(s1$)
END SELECT
END FUNCTION

SUB Flushfile (h%)
IF LEN(fb$(h%)) > 0 THEN PUT #h%, , fb$(h%)
fb$(h%) = ""
dummy& = FRE("")
END SUB

FUNCTION MakeVar$ (v$, tt%)
glob% = FALSE
SELECT CASE tt%
 CASE IntByte%
  t$ = "b"
 CASE IntWord%
  t$ = "w"
 CASE IntDoubleWord%
  t$ = "d"
 CASE StringType%
  t$ = "s"
 CASE StrConst%
  t$ = "s"
  glob% = TRUE
' CASE IntWordArray%
'  t$ = "a"
'  glob% = TRUE
 CASE BundleType%
  t$ = "bu"
  glob% = TRUE
 CASE Pointer%, PointerRef%
  t$ = "p"
  glob% = TRUE
END SELECT
IF RIGHT$(v$, 1) = "~" THEN t$ = "p": glob% = TRUE
IF INSTR(CommonList$, " " + LCASE$(v$) + " ") = 0 AND glob% = FALSE THEN
 MakeVar$ = t$ + "_" + numi$(SubCounter%) + "@" + UCASE$(LEFT$(v$, LEN(v$) - 1))
ELSE
 MakeVar$ = t$ + "_" + UCASE$(LEFT$(v$, LEN(v$) - 1))
END IF
END FUNCTION

FUNCTION numi$ (tmp%)
numi$ = LTRIM$(STR$(tmp%))
END FUNCTION

FUNCTION numi0$ (tmp%)
numi0$ = RIGHT$("00" + LTRIM$(STR$(tmp%)), 2)
END FUNCTION

FUNCTION numl$ (tmp&)
numl$ = LTRIM$(STR$(tmp&))
END FUNCTION

SUB PutLine (l$)

'bpval$ = ""

IF INSTR(l$, ":;") <> 0 OR RIGHT$(l$, 1) = ":" OR SwOpt% = FALSE THEN
 lastivar2$ = ""
 lastivar1$ = ""

 lastsvar2$ = ""
 lastsvar1$ = ""
 BPval$ = ""
END IF

DO
 ptr% = INSTR(l$, "%")
 pp% = VAL(MID$(l$, ptr% + 1, 2))
 IF ptr% <> 0 THEN
  
  IF RIGHT$(bp$(pp%), 1) = "~" THEN
   IF bppr%(pp%) = TRUE THEN CALL PutLine.Pointer(l$, pp%, ptr%): GOTO skiparray
  END IF
  IF bpart%(pp%) <> 0 THEN
  
   ptrz% = INSTR(LocalArray$, " " + LCASE$(bp$(pp%) + " "))
   IF ptrz% <> 0 THEN

   ' it's a near LOCAL array
  
    IF INSTR("@$%&", RIGHT$(bpar$(pp%), 1)) = 0 THEN
  
     ' constant array element: ie var%[1]
     tptr% = ptr%
     DO
      tptr% = tptr% - 1
     LOOP UNTIL MID$(l$, tptr%, 1) = ";" OR tptr% = 1
'     t$ = MakeVar$(bpar$(pp%), bpart%(pp%)) + CHR$(bpt%(pp%))
'     IF BPval$ <> t$ THEN
'      BPval$ = t$
    
     SELECT CASE bpt%(pp%)
      CASE IntByte%
       ff& = 1
      CASE IntWord%, StringType%
       ff& = 2
      CASE IntDoubleWord%
       ff& = 4
     END SELECT

      t$ = t$ + "mov " + bpreg$ + ",ds:[la" + MakeVar$(bp$(pp%), bpt%(pp%)) + "]"
'      + Hex4$(VAL(bpar$(pp%)) * ff&) + "]"
      IF tptr% > 1 THEN t$ = ";" + t$
      IF MID$(l$, tptr%, 1) <> ";" THEN t$ = t$ + ";"
'     ELSE
'      t$ = ""
'     END IF
     IF MID$(l$, ptr% - 4, 4) = "ds:[" THEN
      l$ = LEFT$(l$, ptr% - 1) + bpreg$ + "+" + Hex4$(VAL(bpar$(pp%)) * ff&) + MID$(l$, ptr% + 3)
      l$ = LEFT$(l$, tptr% - 1) + t$ + MID$(l$, tptr%)
     ELSE
      l$ = LEFT$(l$, ptr% - 1) + "ds:la" + MakeVar$(bp$(pp%), bpt%(pp%)) + "+" + Hex4$(VAL(bpar$(pp%)) * ff&) + MID$(l$, ptr% + 3)
      l$ = LEFT$(l$, tptr% - 1) + t$ + MID$(l$, tptr%)
     END IF
   
   
    ELSE
     ' variable array element: var%[a%]
     tptr% = ptr%
     DO
      tptr% = tptr% - 1
     LOOP UNTIL MID$(l$, tptr%, 1) = ";" OR tptr% = 1
     t$ = MakeVar$(bpar$(pp%), bpart%(pp%)) + CHR$(bpt%(pp%)) + bpreg$
     IF BPval$ <> t$ THEN
      BPval$ = t$
      IF bpart%(pp%) = IntByte% THEN
       IF bpreg$ = "bx" THEN
        t$ = "mov bl,ds:[" + MakeVar$(bpar$(pp%), bpart%(pp%)) + "];xor bh,bh;"
       ELSE
        t$ = "mov " + bpreg$ + ",ds:[" + MakeVar$(bpar$(pp%), bpart%(pp%)) + "];and " + bpreg$ + ",0FFh;"
       END IF
      ELSE
       t$ = "mov " + bpreg$ + ",ds:[" + MakeVar$(bpar$(pp%), bpart%(pp%)) + "];"
      END IF
      SELECT CASE bpt%(pp%)
       CASE IntByte%
       ' (nothing)
       CASE IntWord%, StringType%
        t$ = t$ + "add " + bpreg$ + "," + bpreg$ + ";"
       CASE IntDoubleWord%
        IF Processor% >= 186 THEN
         t$ = t$ + "shl " + bpreg$ + ",2;"
        ELSE
         t$ = t$ + "add " + bpreg$ + "," + bpreg$ + ";add " + bpreg$ + "," + bpreg$ + ";"
        END IF
      END SELECT
      t$ = t$ + "add " + bpreg$ + ",ds:[la" + MakeVar$(bp$(pp%), bpt%(pp%)) + "]"
      IF tptr% > 1 THEN t$ = ";" + t$
      IF MID$(l$, tptr%, 1) <> ";" THEN t$ = t$ + ";"
     ELSE
      t$ = ""
     END IF
     IF MID$(l$, ptr% - 4, 4) = "ds:[" THEN
      l$ = LEFT$(l$, ptr% - 1) + bpreg$ + MID$(l$, ptr% + 3)
      l$ = LEFT$(l$, tptr% - 1) + t$ + MID$(l$, tptr%)
     ELSE
      l$ = LEFT$(l$, ptr% - 1) + "ds:" + bpreg$ + MID$(l$, ptr% + 3)
      l$ = LEFT$(l$, tptr% - 1) + t$ + MID$(l$, tptr%)
     END IF
    END IF
    GOTO skiparray
   END IF

   ptrz% = INSTR(DimType$, " " + LCASE$(bp$(pp%)) + ":")
   IF ptrz% = 0 THEN CALL ReportErr("^ Array not defined", bpsp%(pp%), TRUE): EXIT SUB

   el& = VAL(MID$(DimType$, ptrz% + LEN(bp$(pp%)) + 3))
   SELECT CASE MID$(DimType$, ptrz% + LEN(bp$(pp%)) + 2, 1)
    CASE "n"
  
   ' it's a near array
   
    IF INSTR("@$%&", RIGHT$(bpar$(pp%), 1)) = 0 THEN
    
     ' constant array element: ie var%[1]
    
     IF VAL(bpar$(pp%)) > el& THEN CALL ReportErr("^ Array element out of bounds", bpsp%(pp%), TRUE)
    
     SELECT CASE bpt%(pp%)
      CASE IntByte%
       ff& = 1
      CASE IntWord%, StringType%
       ff& = 2
      CASE IntDoubleWord%
       ff& = 4
     END SELECT

     l$ = LEFT$(l$, ptr% - 1) + "a" + MakeVar$(bp$(pp%), bpt%(pp%)) + "+" + Hex4$(VAL(bpar$(pp%)) * ff&) + MID$(l$, ptr% + 3)
    ELSE
     ' variable array element: var%[a%]
     tptr% = ptr%
     DO
      tptr% = tptr% - 1
     LOOP UNTIL MID$(l$, tptr%, 1) = ";" OR tptr% = 1
     t$ = MakeVar$(bpar$(pp%), bpart%(pp%)) + CHR$(bpt%(pp%)) + bpreg$
     IF BPval$ <> t$ THEN
      BPval$ = t$
     
      IF bpart%(pp%) = IntByte% THEN
       IF bpreg$ = "bx" THEN
        t$ = "mov bl,ds:[" + MakeVar$(bpar$(pp%), bpart%(pp%)) + "];xor bh,bh;"
       ELSE
        t$ = "mov " + bpreg$ + ",ds:[" + MakeVar$(bpar$(pp%), bpart%(pp%)) + "];and " + bpreg$ + ",0FFh;"
       END IF
      ELSE
       t$ = "mov " + bpreg$ + ",ds:[" + MakeVar$(bpar$(pp%), bpart%(pp%)) + "];"
      END IF
    
     
      IF SwDebug% = TRUE THEN
       ArrayVarCount% = ArrayVarCount% + 1
       IF Processor% >= 186 THEN
        t$ = t$ + "bound " + bpreg$ + ",dword ptr ss:[ba" + MakeVar$(bp$(pp%), bpt%(pp%)) + "];"
       ELSE
        t$ = t$ + "cmp " + bpreg$ + ",word ptr ss:[ba" + MakeVar$(bp$(pp%), bpt%(pp%)) + "+2];jbe AA" + numi$(ArrayVarCount%) + ";int 5;AA" + numi$(ArrayVarCount%) + ":;"
       END IF
      END IF
      SELECT CASE bpt%(pp%)
       CASE IntByte%
       ' (nothing)
       CASE IntWord%, StringType%
        t$ = t$ + "add " + bpreg$ + "," + bpreg$
       CASE IntDoubleWord%
        IF Processor% >= 186 THEN
         t$ = t$ + "shl " + bpreg$ + ",2"
        ELSE
         t$ = t$ + "add " + bpreg$ + "," + bpreg$ + ";add " + bpreg$ + "," + bpreg$
        END IF
      END SELECT
      IF tptr% > 1 THEN t$ = ";" + t$
      IF MID$(l$, tptr%, 1) <> ";" THEN t$ = t$ + ";"
     ELSE
      t$ = ""
     END IF
     IF MID$(l$, ptr% - 4, 4) = "ds:[" THEN
      l$ = LEFT$(l$, ptr% - 1) + bpreg$ + "+a" + MakeVar$(bp$(pp%), bpt%(pp%)) + MID$(l$, ptr% + 3)
      l$ = LEFT$(l$, tptr% - 1) + t$ + MID$(l$, tptr%)
     ELSE
      l$ = LEFT$(l$, ptr% - 1) + "ds:" + bpreg$ + "+a" + MakeVar$(bp$(pp%), bpt%(pp%)) + MID$(l$, ptr% + 3)
      l$ = LEFT$(l$, tptr% - 1) + t$ + MID$(l$, tptr%)
     END IF
    END IF
   
   CASE "f"
  
    ' far single segment

    IF INSTR("@$%&", RIGHT$(bpar$(pp%), 1)) = 0 THEN
     ' constant array element: ie var%[1]
    
     IF VAL(bpar$(pp%)) > el& THEN CALL ReportErr("^ Array element out of bounds", bpsp%(pp%), TRUE)
    
     tptr% = ptr%
     DO
      tptr% = tptr% - 1
     LOOP UNTIL MID$(l$, tptr%, 1) = ";" OR tptr% = 1
     t$ = SetES$("mov es,ds:[af" + MakeVar$(bp$(pp%), bpt%(pp%)) + "];")
     SELECT CASE bpt%(pp%)
      CASE IntByte%
       ff& = 1
      CASE IntWord%
       ff& = 2
      CASE IntDoubleWord%
       ff& = 4
     END SELECT
     IF tptr% > 1 THEN t$ = ";" + t$
     IF MID$(l$, tptr%, 1) <> ";" THEN t$ = t$ + ";"
     l$ = LEFT$(l$, ptr% - 1) + "es:" + Hex4$(VAL(bpar$(pp%)) * ff&) + MID$(l$, ptr% + 3)
     l$ = LEFT$(l$, tptr% - 1) + t$ + MID$(l$, tptr%)
    
    ELSE
     ' variable array element: var%[a%]
     tptr% = ptr%
     DO
      tptr% = tptr% - 1
     LOOP UNTIL MID$(l$, tptr%, 1) = ";" OR tptr% = 1
     t$ = SetES$("mov es,ds:[af" + MakeVar$(bp$(pp%), bpt%(pp%)) + "];")
     ttt$ = MakeVar$(bpar$(pp%), bpart%(pp%)) + CHR$(bpt%(pp%)) + bpreg$
     IF BPval$ <> ttt$ THEN
      BPval$ = ttt$
     
      IF bpart%(pp%) = IntByte% THEN
       IF bpreg$ = "bx" THEN
        t$ = t$ + "mov bl,ds:[" + MakeVar$(bpar$(pp%), bpart%(pp%)) + "];xor bh,bh;"
       ELSE
        t$ = t$ + "mov " + bpreg$ + ",ds:[" + MakeVar$(bpar$(pp%), bpart%(pp%)) + "];and " + bpreg$ + ",0FFh;"
       END IF
      ELSE
       t$ = t$ + "mov " + bpreg$ + ",ds:[" + MakeVar$(bpar$(pp%), bpart%(pp%)) + "];"
      END IF
     
      IF SwDebug% = TRUE THEN
       ArrayVarCount% = ArrayVarCount% + 1
       IF Processor% >= 186 THEN
        t$ = t$ + "bound " + bpreg$ + ",dword ptr ss:[baf" + MakeVar$(bp$(pp%), bpt%(pp%)) + "];"
       ELSE
        t$ = t$ + "cmp " + bpreg$ + ",word ptr ss:[baf" + MakeVar$(bp$(pp%), bpt%(pp%)) + "+2];jbe AA" + numi$(ArrayVarCount%) + ";int 5;AA" + numi$(ArrayVarCount%) + ":;"
       END IF
      END IF
      SELECT CASE bpt%(pp%)
       CASE IntByte%
       ' (nothing)
       CASE IntWord%
        t$ = t$ + "add " + bpreg$ + "," + bpreg$
       CASE IntDoubleWord%
        IF Processor% >= 186 THEN
         t$ = t$ + "shl " + bpreg$ + ",2"
        ELSE
         t$ = t$ + "add " + bpreg$ + "," + bpreg$ + ";add " + bpreg$ + "," + bpreg$
        END IF
      END SELECT
     END IF
     
     IF tptr% > 1 THEN t$ = ";" + t$
     IF MID$(l$, tptr%, 1) <> ";" THEN t$ = t$ + ";"
    
     IF MID$(l$, ptr% - 4, 4) = "ds:[" THEN
      l$ = LEFT$(l$, ptr% - 5) + "es:[" + bpreg$ + MID$(l$, ptr% + 3)
      l$ = LEFT$(l$, tptr% - 1) + t$ + MID$(l$, tptr%)
     ELSE
      l$ = LEFT$(l$, ptr% - 1) + "es:" + bpreg$ + MID$(l$, ptr% + 3)
      l$ = LEFT$(l$, tptr% - 1) + t$ + MID$(l$, tptr%)
     END IF
    END IF

   CASE "h"
  
    ' far huge array
  
    bpreg$ = "bp"' needed since lib routines use BP

    IF INSTR("@$%&", RIGHT$(bpar$(pp%), 1)) = 0 THEN
    
     ' constant array element: ie var%[1]
    
     IF VAL(bpar$(pp%)) > el& THEN CALL ReportErr("^ Array element out of bounds", bpsp%(pp%), TRUE)
    
     tptr% = ptr%
     DO
      tptr% = tptr% - 1
     LOOP UNTIL MID$(l$, tptr%, 1) = ";" OR tptr% = 1
     IF BPval$ <> bp$(pp%) + bpar$(pp%) + "H" THEN
      BPval$ = bp$(pp%) + bpar$(pp%) + "H" + bpreg$
      t$ = "mov es,ds:[ah" + MakeVar$(bp$(pp%), bpt%(pp%)) + "];"
      LastValES$ = ""
      t& = VAL(bpar$(pp%))
      IF t& > 65535 THEN
       Split4 (bpar$(pp%))
       IF vh& = 0 THEN
        t$ = t$ + "xor bp,bp;"
       ELSE
        t$ = t$ + "mov bp," + Hex4$(vh&) + ";"
       END IF
       t$ = t$ + "push bp;"
       IF vl& = 0 AND vh& <> 0 THEN
        t$ = t$ + "xor bp,bp;"
       ELSE
        t$ = t$ + "mov bp," + Hex4$(vl&) + ";"
       END IF
       SELECT CASE bpt%(pp%)
        CASE IntByte%
         t$ = t$ + "call _arraycalc_byte_l"
        CASE IntWord%
         t$ = t$ + "call _arraycalc_word_l"
        CASE IntDoubleWord%
         t$ = t$ + "call _arraycalc_dword_l"
       END SELECT
      ELSE
       t$ = t$ + "mov bp," + Hex4$(VAL(bpar$(pp%))) + ";"
       SELECT CASE bpt%(pp%)
        CASE IntByte%
         t$ = t$ + "call _arraycalc_byte"
        CASE IntWord%
         t$ = t$ + "call _arraycalc_word"
        CASE IntDoubleWord%
         t$ = t$ + "call _arraycalc_dword"
       END SELECT
      END IF
      IF tptr% > 1 THEN t$ = ";" + t$
      IF MID$(l$, tptr%, 1) <> ";" THEN t$ = t$ + ";"
     ELSE
      t$ = ""
     END IF
      IF MID$(l$, ptr% - 4, 4) = "ds:[" THEN
       l$ = LEFT$(l$, ptr% - 5) + "es:[bp" + MID$(l$, ptr% + 3)
       l$ = LEFT$(l$, tptr% - 1) + t$ + MID$(l$, tptr%)
      ELSE
       l$ = LEFT$(l$, ptr% - 1) + "es:bp" + MID$(l$, ptr% + 3)
       l$ = LEFT$(l$, tptr% - 1) + t$ + MID$(l$, tptr%)
      END IF
    ELSE
     ' variable array element: var%[a%]
     tptr% = ptr%
     DO
      tptr% = tptr% - 1
     LOOP UNTIL MID$(l$, tptr%, 1) = ";" OR tptr% = 1
     IF BPval$ <> bp$(pp%) + bpar$(pp%) + "H" THEN
      BPval$ = bp$(pp%) + bpar$(pp%) + "H" + bpreg$
      LastValES$ = ""
      t$ = "mov es,ds:[ah" + MakeVar$(bp$(pp%), bpt%(pp%)) + "];mov bp,ds:[" + MakeVar$(bpar$(pp%), bpart%(pp%)) + "];"
      IF SwDebug% = TRUE THEN
       ArrayVarCount% = ArrayVarCount% + 1
       IF Processor% >= 186 THEN
        t$ = t$ + "bound bp,dword ptr ss:[bah" + MakeVar$(bp$(pp%), bpt%(pp%)) + "];"
       ELSE
        t$ = t$ + "cmp bp,word ptr ss:[bah" + MakeVar$(bp$(pp%), bpt%(pp%)) + "+2];jbe AA" + numi$(ArrayVarCount%) + ";int 5;AA" + numi$(ArrayVarCount%) + ":;"
       END IF
      END IF
      IF bpart%(pp%) = IntDoubleWord% THEN
       t$ = t$ + "push word ptr ds:[" + MakeVar$(bpar$(pp%), bpart%(pp%)) + "+2];"
       SELECT CASE bpt%(pp%)
        CASE IntByte%
         t$ = t$ + "call _arraycalc_byte_l"
        CASE IntWord%
         t$ = t$ + "call _arraycalc_word_l"
        CASE IntDoubleWord%
         t$ = t$ + "call _arraycalc_dword_l"
       END SELECT
      ELSE
       SELECT CASE bpt%(pp%)
        CASE IntByte%
         t$ = t$ + "call _arraycalc_byte"
        CASE IntWord%
         t$ = t$ + "call _arraycalc_word"
        CASE IntDoubleWord%
         t$ = t$ + "call _arraycalc_dword"
       END SELECT
      END IF
      IF tptr% > 1 THEN t$ = ";" + t$
      IF MID$(l$, tptr%, 1) <> ";" THEN t$ = t$ + ";"
     
     ELSE
      t$ = ""
     END IF
   
      IF MID$(l$, ptr% - 4, 4) = "ds:[" THEN
       l$ = LEFT$(l$, ptr% - 5) + "es:[bp" + MID$(l$, ptr% + 3)
       l$ = LEFT$(l$, tptr% - 1) + t$ + MID$(l$, tptr%)
      ELSE
       l$ = LEFT$(l$, ptr% - 1) + "es:bp" + MID$(l$, ptr% + 3)
       l$ = LEFT$(l$, tptr% - 1) + t$ + MID$(l$, tptr%)
      END IF
     END IF
  END SELECT
  ELSE
   l$ = LEFT$(l$, ptr% - 1) + MakeVar$(bp$(pp%), bpt%(pp%)) + MID$(l$, ptr% + 3)
  END IF
skiparray:
 END IF
LOOP UNTIL ptr% = 0

DO
 ptr% = INSTR(l$, "*")
 IF ptr% <> 0 THEN l$ = LEFT$(l$, ptr% - 1) + bp$(VAL(MID$(l$, ptr% + 1, 2))) + MID$(l$, ptr% + 3)
LOOP UNTIL ptr% = 0


DO
 ptr% = INSTR(l$, "ƒ")
 IF ptr% <> 0 THEN l$ = LEFT$(l$, ptr% - 1) + "pop " + MID$(l$, ptr% + 1)
LOOP UNTIL ptr% = 0

DO
 ptr% = INSTR(l$, ";")
 IF ptr% <> 0 THEN
  o$ = LEFT$(l$, ptr% - 1)
  l$ = MID$(l$, ptr% + 1)
 ELSE
  o$ = l$
 END IF

 IF LEFT$(o$, 5) = "call " THEN
  li$ = LTRIM$(MID$(o$, 6))
  IF INSTR(LibTable$, " " + li$ + " ") = 0 AND LEFT$(li$, 2) <> "__" THEN LibTable$ = LibTable$ + li$ + " "
'  IF INSTR(f386$, " " + li$ + " ") <> 0 AND Sw386% = TRUE THEN
'   IF INSTR(LibTable$, " _386" + li$ + " ") = 0 THEN LibTable$ = LibTable$ + "_386" + li$ + " "
'   IF INSTR(LibVector$, " " + li$ + " ") = 0 THEN LibVector$ = LibVector$ + li$ + " "
'   o$ = LEFT$(o$, 5) + "word ptr cs:[v" + li$ + "]"
'  END IF
  IF SwFarCall% = TRUE THEN o$ = "call far" + MID$(o$, 5)
 END IF

 IF RIGHT$(o$, 1) = ":" THEN
  fb$(FMcode%) = fb$(FMcode%) + o$ + CHR$(13) + CHR$(10)
 ELSE
  IF INSTR(o$, ": ") = 0 OR LEFT$(o$, 1) = "d" THEN
   ptr2% = INSTR(o$, " ")
   IF ptr2% = 0 THEN
    fb$(FMcode%) = fb$(FMcode%) + "	" + o$ + CHR$(13) + CHR$(10)
   ELSE
    fb$(FMcode%) = fb$(FMcode%) + "	" + LEFT$(o$, ptr2% - 1) + "	" + LTRIM$(MID$(o$, ptr2%)) + CHR$(13) + CHR$(10)
   END IF
  ELSE
   fb$(FMcode%) = fb$(FMcode%) + "	" + o$ + CHR$(13) + CHR$(10)
  END IF
 END IF

LOOP UNTIL ptr% = 0
IF LEN(fb$(FMcode%)) > 1024 THEN Flushfile (FMcode%)
END SUB

SUB PutLine.Pointer (l$, pp%, ptr%)
ptr2% = INSTR(PtrTable$, ":" + UCASE$(bp$(pp%)) + " ")
pt% = PointerSize%(pp%)


SELECT CASE MID$(PtrTable$, ptr2% - 2, 1)
 CASE "N"
  tptr% = ptr%
  DO
   tptr% = tptr% - 1
  LOOP UNTIL MID$(l$, tptr%, 1) = ";" OR tptr% = 1
  t$ = MakeVar$(bp$(pp%), pt%) + CHR$(pt%) + "p" + bpreg$
  IF BPval$ <> t$ THEN
   BPval$ = t$
   t$ = "mov " + bpreg$ + ",ds:[" + MakeVar$(bp$(pp%), Pointer%) + "];"
'   IF tptr% > 1 THEN t$ = ";" + t$
'   IF MID$(l$, tptr%, 1) <> ";" THEN t$ = t$ + ";"
  ELSE
   t$ = ""
  END IF
  IF MID$(l$, ptr% - 4, 4) = "ds:[" THEN
   l$ = LEFT$(l$, ptr% - 1) + bpreg$ + MID$(l$, ptr% + 3)
   l$ = LEFT$(l$, tptr% - 1) + t$ + MID$(l$, tptr%)
  ELSE
   l$ = LEFT$(l$, ptr% - 1) + "ds:" + bpreg$ + MID$(l$, ptr% + 3)
   l$ = LEFT$(l$, tptr% - 1) + t$ + MID$(l$, tptr%)
  END IF

 CASE "F"
  LastValES$ = ""  ' *** TEMP ****
  tptr% = ptr%
  DO
   tptr% = tptr% - 1
  LOOP UNTIL MID$(l$, tptr%, 1) = ";" OR tptr% = 1
  t$ = MakeVar$(bp$(pp%), pt%) + CHR$(pt%) + "p" + bpreg$
  IF BPval$ <> t$ THEN
   BPval$ = t$
'   t$ = "mov " + bpreg$ + ",ds:[" + MakeVar$(bp$(pp%), Pointer%) + "];mov es,ds:[" + MakeVar$(bp$(pp%), Pointer%) + "+2];"
   t$ = "les " + bpreg$ + ",dword ptr ds:[" + MakeVar$(bp$(pp%), Pointer%) + "];"
   ESused% = TRUE

'   IF tptr% > 1 THEN t$ = ";" + t$
'   IF MID$(l$, tptr%, 1) <> ";" THEN t$ = t$ + ";"
  ELSE
   t$ = ""
  END IF
  IF MID$(l$, ptr% - 4, 4) = "ds:[" THEN
   l$ = LEFT$(l$, ptr% - 5) + "es:[" + bpreg$ + MID$(l$, ptr% + 3)
   l$ = LEFT$(l$, tptr% - 1) + t$ + MID$(l$, tptr%)
  ELSE
   l$ = LEFT$(l$, ptr% - 1) + "es:" + bpreg$ + MID$(l$, ptr% + 3)
   l$ = LEFT$(l$, tptr% - 1) + t$ + MID$(l$, tptr%)
  END IF

 CASE "H"
  LastValES$ = ""  ' *** TEMP ****

  tptr% = ptr%
  DO
   tptr% = tptr% - 1
  LOOP UNTIL MID$(l$, tptr%, 1) = ";" OR tptr% = 1
  t$ = MakeVar$(bp$(pp%), pt%) + CHR$(pt%) + "p" + bpreg$
  IF BPval$ <> t$ THEN
   BPval$ = t$
   IF SwDPMI% = TRUE THEN
     t$ = "mov e" + bpreg$ + ",dword ptr ds:[" + MakeVar$(bp$(pp%), Pointer%) + "];"
   ELSE
'     t$ = "mov " + bpreg$ + ",ds:[" + MakeVar$(bp$(pp%), Pointer%) + "];mov es,ds:[" + MakeVar$(bp$(pp%), Pointer%) + "+2];call _huge2seg;"
     t$ = "les " + bpreg$ + ",dword ptr ds:[" + MakeVar$(bp$(pp%), Pointer%) + "];call _huge2seg;"
     ESused% = TRUE
   END IF
  ELSE
   t$ = ""
  END IF
  IF MID$(l$, ptr% - 4, 4) = "ds:[" THEN
   IF SwDPMI% = TRUE THEN
     l$ = LEFT$(l$, ptr% - 5) + "fs:[e" + bpreg$ + MID$(l$, ptr% + 3)
   ELSE
     l$ = LEFT$(l$, ptr% - 5) + "es:[" + bpreg$ + MID$(l$, ptr% + 3)
   END IF
   l$ = LEFT$(l$, tptr% - 1) + t$ + MID$(l$, tptr%)
  ELSE
   IF SwDPMI% = TRUE THEN
     l$ = LEFT$(l$, ptr% - 1) + "fs:e" + bpreg$ + MID$(l$, ptr% + 3)
   ELSE
     l$ = LEFT$(l$, ptr% - 1) + "es:" + bpreg$ + MID$(l$, ptr% + 3)
   END IF
   l$ = LEFT$(l$, tptr% - 1) + t$ + MID$(l$, tptr%)
  END IF

END SELECT
END SUB

SUB ReportErr (E$, indent%, showline%)

'STATIC rep.lastpass%
'STATIC rep.lastlinenum%
'STATIC rep.lastsourcetype%

PRINT SPACE$(50); : LOCATE , 1
FMerr% = FREEFILE
OPEN errfile$ FOR APPEND AS #FMerr%
IF LOF(FMerr%) = 0 THEN PRINT #FMerr%, "Error logfile listing for " + infile$

IF rep.lastsourcetype% <> SourceType% THEN
 PRINT
 PRINT #FMerr%, ""
 SELECT CASE SourceType%
  CASE Code%
   PRINT #FMerr%, "--- CODE area ---"
   PRINT "--- CODE area ---"
  CASE VarDef%
   PRINT #FMerr%, "--- DEF area ---"
   PRINT "--- DEF area ---"
 END SELECT
 rep.lastsourcetype% = SourceType%
END IF

IF showline% = TRUE THEN tmp$ = LEFT$("(" + numi$(linecount%) + ")          ", 11)
IF rep.lastlinenum% <> linecount% AND showline% = TRUE THEN
 PRINT tmp$ + inline$
 PRINT #FMerr%, tmp$ + inline$
END IF
PRINT "*error*    " + SPACE$(indent%) + E$
PRINT #FMerr%, "*error*    " + SPACE$(indent%) + E$
CLOSE #FMerr%
errcount% = errcount% + 1
errflag% = TRUE
rep.lastlinenum% = linecount%
END SUB

SUB ReportWarning (E$, indent%, showline%)

'STATIC rep.lastpass%
'STATIC rep.lastlinenum%
'STATIC rep.lastsourcetype%

PRINT SPACE$(50); : LOCATE , 1
FMerr% = FREEFILE
OPEN errfile$ FOR APPEND AS #FMerr%
IF LOF(FMerr%) = 0 THEN PRINT #FMerr%, "Error logfile listing for " + infile$

IF rep.lastsourcetype% <> SourceType% THEN
 PRINT
 PRINT #FMerr%, ""
 SELECT CASE SourceType%
  CASE Code%
   PRINT #FMerr%, "--- CODE area ---"
   PRINT "--- CODE area ---"
  CASE VarDef%
   PRINT #FMerr%, "--- DEF area ---"
   PRINT "--- DEF area ---"
 END SELECT
 rep.lastsourcetype% = SourceType%
END IF

IF showline% = TRUE THEN tmp$ = LEFT$("(" + numi$(linecount%) + ")          ", 11)
IF rep.lastlinenum% <> linecount% AND showline% = TRUE THEN
 PRINT tmp$ + inline$
 PRINT #FMerr%, tmp$ + inline$
END IF
PRINT "*warning*  " + SPACE$(indent%) + E$
PRINT #FMerr%, "*warning*  " + SPACE$(indent%) + E$
CLOSE #FMerr%
warncount% = warncount% + 1
'warnflag% = TRUE
rep.lastlinenum% = linecount%
END SUB

FUNCTION SetES$ (v$)
ESused% = TRUE
IF UCASE$(LastValES$) <> UCASE$(v$) THEN
 LastValES$ = v$
 SetES$ = v$
ELSE
 SetES$ = ""
END IF
END FUNCTION

SUB StringConst (s$, WriteFlag%)
IF INSTR(s$, CHR$(34)) = 0 THEN EXIT SUB
DO

ptr% = INSTR(s$, CHR$(34))
IF ptr% <> 0 THEN
 ptr2% = INSTR(ptr% + 1, s$, CHR$(34))
 IF ptr2% <> 0 THEN
  sc$ = MID$(s$, ptr% + 1, ptr2% - ptr% - 1)
  IF LEN(sc$) > 0 THEN
   IF WriteFlag% = TRUE THEN
    vv$ = MID$(s$, ptr% + 1, ptr2% - ptr% - 1)
    vl% = LEN(vv$)
    IF INSTR(vv$, "'") <> 0 THEN
     res$ = ""
     FOR i% = 1 TO LEN(vv$)
      c$ = MID$(vv$, i%, 1)
      res$ = res$ + c$
      IF c$ = "'" THEN res$ = res$ + ",39,'"
     NEXT
     vv$ = res$
    END IF

    IF INSTR(vv$, "\") <> 0 THEN
     qopen% = FALSE
     res$ = ""
     FOR i% = 1 TO LEN(vv$)
      c$ = MID$(vv$, i%, 1)
      IF c$ <> "\" THEN
       IF qopen% = FALSE THEN
        IF i% = 1 THEN
         res$ = res$ + "'"
        ELSE
         res$ = res$ + "'"
        END IF
        qopen% = TRUE
       END IF
       res$ = res$ + c$
      ELSE
       i% = i% + 1
       IF qopen% = TRUE THEN res$ = res$ + "',": qopen% = FALSE
       c$ = LCASE$(MID$(vv$, i%, 1))
       SELECT CASE c$
        CASE "n"
         res$ = res$ + "13,10,"
        CASE "t"
         res$ = res$ + "9,"
         vl% = vl% - 1
        CASE "\"
         res$ = res$ + "'\',"
         vl% = vl% - 1
        CASE "g"
         res$ = res$ + "7,"
         vl% = vl% - 1
        CASE "0"
         res$ = res$ + "0,"
         vl% = vl% - 1
        CASE "h"
         res$ = res$ + "0" + MID$(vv$, i% + 1, 2) + "h,"
         vl% = vl% - 3
         i% = i% + 2
        CASE "r"
         res$ = res$ + "13,"
         vl% = vl% - 1
        CASE ELSE
         CALL ReportErr("^ Bad escape sequence", ptr% + i% - 2, TRUE)
       END SELECT
       IF i% <> LEN(vv$) + 1 AND qopen% = TRUE THEN res$ = res$ + "'"
      END IF
     NEXT
     vv$ = res$
     IF qopen% = TRUE THEN vv$ = vv$ + "',"
   
    ELSE
     vv$ = "'" + vv$ + "'"
    END IF
   
    DO
     ptr3% = INSTR(vv$, "'',")
     IF ptr3% <> 0 THEN
      vv$ = LEFT$(vv$, ptr3% - 1) + MID$(vv$, ptr3% + 3)
     END IF
    LOOP UNTIL ptr3% = 0

    IF RIGHT$(vv$, 1) = "," THEN vv$ = LEFT$(vv$, LEN(vv$) - 1)
    IF RIGHT$(vv$, 2) = "''" THEN vv$ = LEFT$(vv$, LEN(vv$) - 2)
    IF RIGHT$(vv$, 1) = "," THEN vv$ = LEFT$(vv$, LEN(vv$) - 1)

     matched% = FALSE
     FOR i% = 0 TO strconstcount%
      IF vv$ = sc$(i%) THEN
       varname$ = "$SC_" + numi$(i%)
       matched% = TRUE
       EXIT FOR
      END IF
     NEXT
    IF matched% = FALSE THEN
     strconstcount% = strconstcount% + 1
     varname$ = "$SC_" + numi$(strconstcount%)
     CALL WriteFile("s_" + varname$ + ": dw " + numi$(vl%), FMsc%)
     sc$(strconstcount%) = vv$
     CALL WriteFile("db " + vv$, FMsc%)
     CALL AddStringVar(varname$ + " ", 0)
    END IF
   END IF
  ELSE
   varname$ = "mr@null"
  END IF
  s$ = LEFT$(s$, ptr% - 1) + varname$ + "$" + MID$(s$, ptr2% + 1)
 END IF
END IF

LOOP UNTIL ptr% = 0 OR ptr2% = 0

END SUB

SUB WriteFile (l$, h%)
fb$(h%) = fb$(h%) + l$ + CHR$(13) + CHR$(10)
IF LEN(fb$(h%)) > 1024 THEN Flushfile (h%)
END SUB

