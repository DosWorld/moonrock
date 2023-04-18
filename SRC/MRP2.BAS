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
DECLARE SUB WriteFile (l$, H%)
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

SUB CheckDS
STATIC AlreadyReported%
IF DataPtr& > 65535 THEN
 IF AlreadyReported% = FALSE THEN
  CALL ReportErr("^ data segment exhausted (64k limit)", 0, TRUE)
 END IF
 AlreadyReported% = TRUE
END IF
END SUB

SUB ErrMustBeVar (z%)
CALL ReportErr("^ Numerical variable or constant expected", bpsp%(z%), TRUE)
END SUB

SUB ErrOverflow
IF SwDebug% = TRUE THEN PutLine ("into")
END SUB

SUB ErrParm (z%, t$)
SELECT CASE t$
 CASE "v$"
  CALL ReportErr("^ String '$' expected", bpsp%(z%), TRUE)
 CASE "v@"
  CALL ReportErr("^ Byte '@' expected", bpsp%(z%), TRUE)
 CASE "v%"
  CALL ReportErr("^ Word '%' expected", bpsp%(z%), TRUE)
 CASE "v&"
  CALL ReportErr("^ Long '&' expected", bpsp%(z%), TRUE)
 CASE "a$"
  CALL ReportErr("^ String array '$'expected", bpsp%(z%), TRUE)
 CASE "a@"
  CALL ReportErr("^ Byte array '@' expected", bpsp%(z%), TRUE)
 CASE "a%"
  CALL ReportErr("^ Word array '%' expected", bpsp%(z%), TRUE)
 CASE "a&"
  CALL ReportErr("^ Long array '&' expected", bpsp%(z%), TRUE)
 CASE ELSE
  CALL ReportErr("^ '" + t$ + "' type expected", bpsp%(z%), TRUE)
END SELECT
END SUB

SUB ErrSubDef (z%)
CALL ReportWarning("^ Conflicts with previous sub definition", bpsp%(z%), TRUE)
END SUB

SUB ErrTypeMismatch (z%)
CALL ReportErr("^ Type mismatch", bpsp%(z%), TRUE)
END SUB

SUB EvalNumXorCX (cx$)
PutLine ("xor " + cx$ + "," + cx$)
END SUB

FUNCTION Hex2$ (l%)
Hex2$ = "0" + RIGHT$("0000" + LEFT$(HEX$(l%), 4), 4) + "h"
END FUNCTION

FUNCTION Hex4$ (l&)
Hex4$ = "0" + RIGHT$("0000" + LEFT$(HEX$(l&), 4), 4) + "h"
END FUNCTION

FUNCTION Hex8$ (l&)
Hex8$ = "0" + RIGHT$("00000000" + LEFT$(HEX$(l&), 8), 8) + "h"
END FUNCTION

FUNCTION OnOff% (l$)
SELECT CASE UCASE$(l$)
 CASE "ON"
  OnOff% = TRUE
 CASE "OFF"
  OnOff% = FALSE
 CASE ELSE
  CALL ReportErr("^ON or OFF required", 0, TRUE)
END SELECT
END FUNCTION

SUB Pass2
'SEEK #FMin%, 1
CALL NewSeg(CodeSeg%, FMcode%)
IF SwDebug% = TRUE AND SwPartial% = FALSE THEN PutLine ("call _packfunctiondump;mov word ptr ss:[mr@func],-1")
linecount% = 0
strconstcount% = 0
Pass% = 2
SourceType% = Code%
LOCATE , , 0
currentsub$ = "(none):"
CurrentFile$ = IncludeName$(IncludeSP%)
updsub% = TRUE
ieof% = TRUE
SkipLine% = FALSE
'SetStrPtr VARPTR(InStrBuf), VARSEG(InStrSeg)
WHILE ieof% = TRUE
 errflag% = FALSE
 inline$ = ""
GetLine:
 linecount% = linecount% + 1
' ieof% = GetLine%
 LINE INPUT #FMin%, ttt$
 IF ieof% = FALSE THEN GOTO FoundEOF
 IF EOF(FMin%) THEN ieof% = FALSE
 PRINT "Line: " + numi$(linecount%); : LOCATE , 1
 IF updsub% = TRUE THEN
  PRINT "Line: " + LEFT$(numi$(linecount%) + "   ", 5) + "  Sub: " + LEFT$(LEFT$(currentsub$, LEN(currentsub$) - 1) + SPACE$(40), 40) + "File: " + LEFT$(CurrentFile$ + SPACE$(14), 14); : LOCATE , 1
  updsub% = FALSE
 END IF
 'inline$ = inline$ + LTRIM$(RTRIM$(InStrBuf))
 inline$ = inline$ + LTRIM$(RTRIM$(ttt$))
 IF RIGHT$(inline$, 1) = "_" THEN inline$ = LEFT$(inline$, LEN(inline$) - 1): GOTO GetLine

 l$ = inline$
 IF LEFT$(l$, 1) = "#" THEN
  IF WriteSource% = TRUE THEN CALL WriteFile(linefeed$ + "; " + RIGHT$("0000" + numi$(linecount%), 4) + "	" + inline$, FMcode%)

  t$ = MID$(l$, 2)
  ptr% = INSTR(t$, " ")
  IF ptr% <> 0 THEN
   k$ = UCASE$(LEFT$(t$, ptr% - 1))
   p2$ = LTRIM$(MID$(t$, ptr%))
   p$ = UCASE$(p2$)
  ELSE
   k$ = UCASE$(t$)
   p$ = ""
   p2$ = ""
  END IF
  IF k$ = "ENDIF" THEN SkipLine% = FALSE
  IF SkipLine% = TRUE THEN inline$ = "": GOTO GetLine

  SELECT CASE k$
   CASE "ENDIF"
   ' nothing
   CASE "OUT"
    COLOR 14
    LOCATE , 1
    PRINT SPACE$(79);
    LOCATE , 1
    PRINT p2$
    COLOR 7
    updsub% = TRUE
   CASE "ABORT"
    CALL ReportErr("FATAL: Compile aborted at line " + numi$(linecount%), 0, TRUE)
    FMerr% = FREEFILE
    OPEN errfile$ FOR APPEND AS #FMerr%
    PRINT #FMerr%, ""
    PRINT #FMerr%, "FATAL: Compile aborted prematurely."
   
    CLOSE
    KILL tpath$ + "variable.$$$"
    KILL tpath$ + "code.$$$"
    KILL tpath$ + "strconst.$$$"
    KILL tpath$ + "stack.$$$"
    END
   CASE "IFDEF"
    IF INSTR(Def$, " " + p$ + " ") = 0 THEN SkipLine% = TRUE
   CASE "IFNDEF"
    IF INSTR(Def$, " " + p$ + " ") <> 0 THEN SkipLine% = TRUE
   CASE "INCLUDE"
    IF FFexist(p$) = FALSE THEN
     IF FFexist(ENVIRON$("MRINCLUDE") + "\" + p$) = TRUE THEN
      p$ = ENVIRON$("MRINCLUDE") + "\" + p$
     ELSE
      CALL ReportErr("^ Include file not found", 0, TRUE)
      GOTO includeskip
     END IF
    END IF
    IncludePosi&(IncludeSP%) = SEEK(FMin%)
    IncludeLine%(IncludeSP%) = linecount%
    CLOSE #FMin%
    IncludeSP% = IncludeSP% + 1
    IncludeName$(IncludeSP%) = p$
    CurrentFile$ = p$
    ptr% = INSTR(CurrentFile$, "\")
    WHILE ptr% <> 0
     CurrentFile$ = MID$(CurrentFile$, ptr% + 1)
     ptr% = INSTR(CurrentFile$, "\")
    WEND
   
    OPEN p$ FOR INPUT AS #FMin%
    linecount% = 0
    updsub% = TRUE
includeskip:
   CASE "PROJECT"
    ProjList$ = LTRIM$(RTRIM$(p$)) + ","
   CASE "PRESERVE"
    PreserveFlag% = TRUE
   CASE ELSE
    CALL ReportErr("^ Unrecognised directive", 0, TRUE)
  END SELECT
  l$ = "": inline$ = ""
 END IF

 IF SkipLine% = TRUE THEN inline$ = "": GOTO GetLine

 IF l$ <> "" AND LEFT$(l$, 1) <> "'" AND LEFT$(l$, 1) <> "$" THEN
  IF UCASE$(LEFT$(l$, 6)) = "BEGIN " THEN
   bt$ = UCASE$(LTRIM$(MID$(l$, INSTR(l$, " "))))
   SELECT CASE bt$
    CASE "CODE"
     SourceType% = Code%
     CALL NewSeg(CodeSeg%, FMcode%)
    CASE "DEF"
     SourceType% = VarDef%
     CALL NewSeg(DataSeg%, FMcode%)
    CASE ELSE
     CALL ReportErr("^ Bad BEGIN parameter", 6, TRUE)
   END SELECT
  ELSE

   IF SourceType% = Code% THEN
    IF WriteSource% = TRUE THEN
'     IF LEFT$(l$, 1) <> "@" THEN
      IF LEN(inline$) < 70 THEN
       CALL WriteFile(linefeed$ + "; " + RIGHT$("0000" + numi$(linecount%), 4) + "	" + inline$, FMcode%)
      ELSE
       CALL WriteFile(linefeed$ + "; " + RIGHT$("0000" + numi$(linecount%), 4) + "	" + LEFT$(inline$, 70), FMcode%)
       t$ = MID$(inline$, 71)
       WHILE t$ <> ""
        CALL WriteFile(";        " + LEFT$(t$, 70), FMcode%)
        t$ = MID$(t$, 71)
       WEND
      END IF
     IF LEFT$(l$, 1) <> "@" THEN
      CALL StringConst(l$, TRUE)
      IF INSTR(l$, "'") <> 0 THEN l$ = RTRIM$(LEFT$(l$, INSTR(l$, "'") - 1))
     END IF
'     ELSE
'      CALL StringConst(l$, TRUE)
'      CALL WriteFile(linefeed$ + "; " + RIGHT$("0000" + numi$(linecount%), 4) + "	@", FMcode%)
'     END IF
    ELSE
     CALL StringConst(l$, TRUE)
     IF INSTR(l$, "'") <> 0 THEN l$ = RTRIM$(LEFT$(l$, INSTR(l$, "'") - 1))
    END IF
    IF INSTR(inline$, ":") = 0 THEN
     IF LEFT$(l$, 1) <> "@" THEN
'      IF SwResume% = TRUE THEN PutLine ("mov word ptr cs:[mr@ip],offset $-1")
      IF SwDebug% = TRUE THEN PutLine ("mov word ptr ss:[mr@line]," + numi$(linecount%))
      IF SwTrace% = TRUE THEN PutLine ("call _trace")
     END IF
     IF SwSingleStep% = TRUE THEN PutLine ("int 3")
    END IF
    fs& = LOF(FMcode%) + LEN(fb$(FMcode%))
    IF LEFT$(l$, 1) = "@" THEN
     l$ = MID$(l$, 2)
     ptr% = sinstr(l$, "$%&~")
     WHILE ptr% <> 0
      ptr2% = ptr%
      DO
       ptr2% = ptr2% - 1
      LOOP UNTIL INSTR("ABCDEFGHIJKLMNOPQRSTUVWXYZ._0123456789", UCASE$(MID$(l$, ptr2%, 1))) = 0
      v$ = MID$(l$, ptr2% + 1, ptr% - ptr2%)
      SELECT CASE MID$(l$, ptr%, 1)
       CASE "@"
        t$ = MakeVar$(v$, IntByte%)
       CASE "%"
        t$ = MakeVar(v$, IntWord%)
       CASE "&"
        t$ = MakeVar(v$, IntDoubleWord%)
       CASE "$"
        t$ = MakeVar(v$, StringType%)
       CASE "~"
        t$ = MakeVar(v$, Pointer%)
      END SELECT
      l$ = LEFT$(l$, ptr2%) + t$ + MID$(l$, ptr% + 1)
      ptr% = sinstr(l$, "$%&^")
     WEND
     CALL WriteFile("	" + l$, FMcode%)
    ELSE
     IF currentsub$ = ":" THEN
      IF UCASE$(LEFT$(inline$, 4)) <> "SUB " THEN CALL ReportWarning("Source code present outside sub boundary", 0, TRUE)
      END IF

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
      LOOP UNTIL ptr% = 0 OR inline$ = ""
     END IF
    END IF
   ELSE
    ' it's variable defs
    IF INSTR(l$, "'") <> 0 THEN l$ = RTRIM$(LEFT$(l$, INSTR(l$, "'") - 1))
    ptr% = INSTR(l$, " ")
    IF ptr% <> 0 THEN
     k$ = UCASE$(LEFT$(l$, ptr% - 1))
     p$ = LTRIM$(MID$(l$, ptr%))
    ELSE
     k$ = UCASE$(l$)
     p$ = ""
    END IF
    IF LEFT$(k$, 1) = "%" THEN
     CALL Block(l$, FALSE)
     IF bp$(1) <> "=" THEN CALL ReportErr("^ Expected '='", bpsp%(1), TRUE)
     badconst% = FALSE
     FOR i% = 2 TO bpp%
      IF bpt%(i%) <> IntConst% AND bpt%(i%) <> TermType% THEN badconst% = TRUE
     NEXT
     IF badconst% = TRUE THEN
      CALL ReportErr("^ Evaluation must contain constants only", bpsp%(2), TRUE)
     ELSE
      IF INSTR(inline$, "-") <> 0 THEN
       FOR z% = 1 TO bpp%
        IF bp$(z%) = "-" AND bpt%(z% + 1) = IntConst% AND (bpt%(z% - 1) = TermType% OR bp$(0) = "case") THEN
         bp$(z%) = "-" + bp$(z% + 1)
         bpt%(z%) = IntConst%
         FOR j% = z% + 2 TO bpp%
          bp$(j% - 1) = bp$(j%)
          bpt%(j% - 1) = bpt%(j%)
          bpsp%(j% - 1) = bpsp%(j%)
          bpar$(j% - 1) = bpar$(j%)
         NEXT
         bpp% = bpp% - 1
        END IF
       NEXT
     END IF
     s& = CVAL&(bp$(2))
     IF bpp% > 2 THEN
      FOR i% = 3 TO bpp%
       SELECT CASE bp$(i%)
        CASE "+"
         s& = s& + CVAL&(bp$(i% + 1))
         i% = i% + 1
        CASE "-"
         s& = s& - CVAL&(bp$(i% + 1))
         i% = i% + 1
        CASE "*"
         s& = s& * CVAL&(bp$(i% + 1))
         i% = i% + 1
        CASE "/"
         s& = s& / CVAL&(bp$(i% + 1))
         i% = i% + 1
        CASE "\"
         s& = s& \ CVAL&(bp$(i% + 1))
         i% = i% + 1
        CASE ELSE
         CALL ReportErr("^ Bad constant evaluation format", bpsp%(i%), TRUE)
       END SELECT
      NEXT
     END IF
     ConstTable$ = ConstTable$ + UCASE$(bp$(0)) + "=" + numl$(s&) + " "
    END IF

    ELSE
    SELECT CASE k$
     CASE "TYPE"
      TypePtr% = TypePtr% + 1
      ptr% = INSTR(p$, " ")
      IF ptr% = 0 THEN
       CALL ReportErr("^ Invalid TYPE definition", bpsp%(0), TRUE)
      ELSE
       TypeName$(TypePtr%) = UCASE$(LEFT$(p$, ptr% - 1))
       TypeParm$(TypePtr%) = MID$(p$, ptr% + 1)
      END IF

     CASE "POINTER"
      CALL Block(l$, FALSE)
      ty$ = "N"
      ps% = 2 'db pointer size
      sz$ = ""
      FOR i% = 1 TO bpp%
       SELECT CASE bp$(i%)
        CASE "far"
         ESused% = TRUE
         ty$ = "F"
         ps% = 4
        CASE "huge"
         ESused% = TRUE
         ty$ = "H"
         ps% = 4
        CASE "near"
         ty$ = "N"
         ps% = 2
        CASE "byte"
         sz$ = "B"
        CASE "word"
         sz$ = "W"
        CASE "dword"
         sz$ = "D"
        CASE "string"
         sz$ = "S"
        CASE ELSE
         IF bpt%(i%) <> Pointer% THEN
          CALL ReportErr("^ Unrecognised POINTER parameter", bpsp%(i%), TRUE)
         ELSE
          t1$ = UCASE$(bp$(i%))
          IF INSTR(PtrTable$, ":" + t1$ + " ") <> 0 THEN CALL ReportErr("^ Pointer already defined elsewhere", bpsp%(i%), TRUE)
         END IF
       END SELECT
      NEXT
      IF sz$ = "" THEN CALL ReportErr("^ Pointer size not defined", 0, TRUE)
      PtrTable$ = PtrTable$ + ty$ + sz$ + ":" + t1$ + " "
      t1$ = LEFT$(t1$, LEN(t1$) - 1)
      IF SwPartial% = TRUE THEN
       IF SwMain% = FALSE THEN
        CALL WriteFile("extrn p_" + t1$, FMvar%)
       ELSE
        CALL WriteFile("public p_" + t1$, FMvar%)
        IF ps% = 2 THEN
         CALL WriteFile("p_" + t1$ + " dw 1 dup (?)", FMvar%)
        ELSE
         CALL WriteFile("p_" + t1$ + " dd 1 dup (?)", FMvar%)
        END IF
       END IF
      ELSE
       CALL WriteFile("p_" + t1$ + "	equ " + Hex4$(DataPtr&), FMvar%)
      END IF
      DataPtr& = DataPtr& + ps%

     CASE "SET"
      CALL Block(l$, FALSE)
      IF bp$(1) = "=" THEN
       startnum& = CVAL&(bp$(2))
       sp% = 3
      ELSE
       startnum& = 0
       sp% = 1
      END IF
      FOR i% = sp% TO bpp%
       ConstTable$ = ConstTable$ + UCASE$(bp$(i%)) + "=" + numl$(startnum&) + " "
       startnum& = startnum& + 1
      NEXT

     CASE "PRAGMA"
      ptr% = INSTR(p$, " ")
      IF ptr% <> 0 THEN
       k2$ = UCASE$(LEFT$(p$, ptr% - 1))
       p2$ = LTRIM$(MID$(p$, ptr%))
      ELSE
       k2$ = UCASE$(k$)
       p2$ = ""
      END IF
      SELECT CASE UCASE$(k2$)
       CASE "SUBNULLSTRINGCHECK"
        PragmaSubNullStringCheck% = OnOff%(p2$)
       CASE ELSE
        CALL ReportErr("^Unknown PRAGMA parameter", bpsp%(1), TRUE)
      END SELECT

     CASE "ERRORHANDLER"
      errhandler$ = LCASE$(p$)

     CASE "LANGUAGE"
      IF SwDep% = FALSE THEN
       PRINT "*Warning*   Language defined in source but /L commandline switch not specified"
       PRINT
      END IF
      SELECT CASE UCASE$(p$)
       CASE "BASIC", "QUICKBASIC"
        Language% = QuickBASIC
      END SELECT

     CASE "COMMON"
      CALL Block(l$, FALSE)
      FOR i% = 1 TO bpp%
       CommonList$ = CommonList$ + LCASE$(bp$(i%)) + " "
       SELECT CASE bpt%(i%)
        CASE IntByte%
         CALL AddIntVar(bp$(i%), 1, i%)
        CASE IntWord%
         CALL AddIntVar(bp$(i%), 2, i%)
        CASE IntDoubleWord%
         CALL AddIntVar(bp$(i%), 4, i%)
        CASE StringType%
         CALL AddStringVar(bp$(i%), i%)
       END SELECT
      NEXT

     CASE "BUNDLE"
      CALL Block(l$, FALSE)
      IF RIGHT$(bp$(1), 1) = ":" THEN
       bn$ = LEFT$(bp$(1), LEN(bp$(1)) - 1)
      ELSE
       bn$ = bp$(1)
      END IF
      BundlePtr% = BundlePtr% + 1
      Bundle$(BundlePtr%) = LCASE$(bn$ + "^")
      bn2$ = bn$ ' used later
      bn$ = bn$ + "_"
      bs% = 0
     
      IF SwPartial% = TRUE AND SwMain% = FALSE THEN
       CALL WriteFile("extrn bu_" + UCASE$(bn2$) + ":NEAR", FMvar%)
      ELSE
       IF SwMain% = TRUE THEN
        CALL WriteFile("public bu_" + UCASE$(bn2$), FMvar%)
        CALL WriteFile("bu_" + UCASE$(bn2$) + ":", FMvar%)
'        db " + numi$(bs%) + " dup (?)", FMvar%)
       ELSE
        CALL WriteFile("bu_" + UCASE$(bn2$) + "	equ 0" + HEX$(DataPtr&) + "h", FMvar%)
       END IF
      END IF
     
      FOR z% = 2 TO bpp%
       CommonList$ = CommonList$ + LCASE$(bn$) + LCASE$(bp$(z%)) + " "
       SELECT CASE bpt%(z%)
        CASE IntByte%
         CALL AddIntVar(bn$ + bp$(z%), 1, z%)
         bs% = bs% + 1
        CASE IntWord%
         CALL AddIntVar(bn$ + bp$(z%), 2, z%)
         bs% = bs% + 2
        CASE IntDoubleWord%
         CALL AddIntVar(bn$ + bp$(z%), 4, z%)
         bs% = bs% + 4
        CASE StringType%
         CALL AddStringVar(bn$ + bp$(z%), z%)
         sl% = VAL(bpar$(z%))  ' size of element
         CALL AddDataRef("", sl% - 2, FMvar%)
         SELECT CASE LCASE$(bp$(z% + 1))
          CASE "mr"
           t$ = "M"
           z% = z% + 1
          CASE "null"
           t$ = "N"
           z% = z% + 1
          CASE "pascal"
           t$ = "P"
           z% = z% + 1
          CASE ELSE
           CALL ReportErr("^ String type not defined", bpsp%(z%), TRUE)
         END SELECT
         BundleDef$(BundlePtr%) = BundleDef$(BundlePtr%) + t$ + MKI$(bs%) + MKI$(sl%)
         bs% = bs% + sl%
'         DataPtr& = DataPtr& + sl% - 2
       CASE ELSE
        CALL ReportErr("^ Type not supported", bpsp%(z%), TRUE)
       END SELECT
      NEXT
      BundleSize%(BundlePtr%) = bs%
      CALL WriteFile("even", FMvar%)

     CASE "SUB"
      CALL Block(l$, FALSE)
      IF bpt%(1) <> Label% THEN bpt%(1) = Label%: bp$(1) = bp$(1) + ":"
      IF SwDep% = TRUE THEN
       st$ = "F"
      ELSE
       st$ = "N"
      END IF
      IF bpt%(2) = CmdType% THEN
       IF bp$(2) = "near" THEN st$ = "N"
       IF bp$(2) = "far" THEN st$ = "F"
       IF bp$(2) = "marg" THEN st$ = "M"
       IF bp$(2) = "extern" THEN
        st$ = "E"
        ExternUsed% = TRUE
        CALL WriteFile("extrn " + LEFT$(LCASE$(bp$(1)), LEN(bp$(1)) - 1), FMout%)
       END IF
       startbp% = 3
      ELSE
       startbp% = 2
      END IF
      SubPtr% = SubPtr% + 1
      Sub$(SubPtr%) = LCASE$(bp$(1)) + st$
      IF bpp% >= startbp% THEN
       FOR z% = startbp% TO bpp%
        IF bpar$(z%) = "ARRAY_BY_REF" THEN
         SELECT CASE bpt%(z%)
          CASE IntByte%
           t$ = "a@"
          CASE IntWord%
           t$ = "a%"
          CASE IntDoubleWord%
           t$ = "a&"
          CASE StringType%
           t$ = "a$"
          CASE ELSE
           CALL ErrTypeMismatch(z%)
         END SELECT
        ELSE

        SELECT CASE bpt%(z%)
         CASE IntByte%
          t$ = "v@"
         CASE IntWord%
          t$ = "v%"
         CASE IntDoubleWord%
          t$ = "v&"
         CASE StringType%
          t$ = "v$"
         CASE Pointer%
           SELECT CASE PointerType(z%)
            CASE IntWord%
             t$ = "v%"
            CASE IntDoubleWord%
             t$ = "v&"
           END SELECT
         CASE ELSE
          CALL ErrTypeMismatch(z%)
        END SELECT
        END IF
        Sub$(SubPtr%) = Sub$(SubPtr%) + t$
       NEXT
      END IF

     CASE "DIM"
      CALL Block(l$, FALSE)
           
      IF bp$(1) = "far" OR bp$(1) = "huge" THEN

       IF bp$(1) = "far" THEN at$ = "f" ELSE at$ = "h"

       SELECT CASE bpt%(2)  ' multiplication factor
        CASE IntByte%
         f& = 1
         t$ = "a" + at$ + "b"
        CASE IntWord%
         f& = 2
         t$ = "a" + at$ + "w"
        CASE IntDoubleWord%
         f& = 4
         t$ = "a" + at$ + "d"
'        CASE BundleType%
'         f& = BunSize%(2)
'         IF f& = 0 THEN CALL ErrBundle(2)
'         t$ = "afb"
        CASE ELSE
         CALL ReportErr("^ Type not supported", bpsp%(2), TRUE)
       END SELECT
       
       el& = VAL(bpar$(2))
       s& = el& * f&: ' size of array
       vv$ = UCASE$(LEFT$(bp$(2), LEN(bp$(2)) - 1))
       tn$ = LCASE$(bp$(2))
      ELSE
       SELECT CASE RIGHT$(bp$(1), 1):  ' multiplication factor
        CASE "@"
         f& = 1
         t$ = "ab"
        CASE "%"
         f& = 2
         t$ = "aw"
        CASE "&"
         f& = 4
         t$ = "ad"
        CASE "$"
         f& = 2
         t$ = "as"
        CASE ELSE
         CALL ReportErr("^ Type not supported", bpsp%(1), TRUE)
       END SELECT
    
       el& = VAL(bpar$(1))
       s& = (el& + 1) * f&: ' size of array
      
       vv$ = UCASE$(LEFT$(bp$(1), LEN(bp$(1)) - 1))
       tn$ = LCASE$(bp$(1))
      END IF

      IF bp$(1) = "far" AND s& > 65536 THEN CALL ReportErr("^ Cannot fit into single FAR segment; use HUGE array type", bpsp%(2), TRUE)

      CommonList$ = CommonList$ + tn$ + " "
     
      SELECT CASE t$
      
       CASE "as"
        strcount% = strcount% + 1
        CALL AddDataRef("as_" + vv$, s&, FMvar%)
'        CALL WriteFile("as_" + vv$ + "	equ 0" + HEX$(DataPtr&) + "h", FMvar%)
'        DataPtr& = DataPtr& + s&
        DimType$ = DimType$ + vv$ + "$:N" + numl$(el&) + " "
        IF SwPartial% = TRUE AND SwMain% = FALSE THEN
         DimBound$ = DimBound$ + "extrn bas_" + vv$ + ":WORD" + linefeed$
        ELSE
         IF SwMain% = TRUE THEN DimBound$ = DimBound$ + "public bas_" + vv$ + linefeed$
         DimBound$ = DimBound$ + "bas_" + vv$ + ": dw 0," + numl$(el&) + linefeed$
        END IF
       CASE "ab"
        intcount% = intcount% + 1
        CALL AddDataRef("ab_" + vv$, s&, FMvar%)
        DimType$ = DimType$ + vv$ + "@:N" + numl$(el&) + " "
        IF SwPartial% = TRUE AND SwMain% = FALSE THEN
         DimBound$ = DimBound$ + "extrn bab_" + vv$ + ":WORD" + linefeed$
        ELSE
         IF SwMain% = TRUE THEN DimBound$ = DimBound$ + "public bab_" + vv$ + linefeed$
         DimBound$ = DimBound$ + "bab_" + vv$ + ": dw 0," + numl$(el&) + linefeed$
        END IF
       CASE "aw"
        intcount% = intcount% + 1
        CALL AddDataRef("aw_" + vv$, s&, FMvar%)
        DimType$ = DimType$ + vv$ + "%:N" + numl$(el&) + " "
        IF SwPartial% = TRUE AND SwMain% = FALSE THEN
         DimBound$ = DimBound$ + "extrn baw_" + vv$ + ":WORD" + linefeed$
        ELSE
         IF SwMain% = TRUE THEN DimBound$ = DimBound$ + "public baw_" + vv$ + linefeed$
         DimBound$ = DimBound$ + "baw_" + vv$ + ": dw 0," + numl$(el&) + linefeed$
        END IF
       CASE "ad"
        intcount% = intcount% + 1
        CALL AddDataRef("ad_" + vv$, s&, FMvar%)
        DimType$ = DimType$ + vv$ + "&:N" + numl$(el&) + " "
        IF SwPartial% = TRUE AND SwMain% = FALSE THEN
         DimBound$ = DimBound$ + "extrn bad_" + vv$ + ":WORD" + linefeed$
        ELSE
         IF SwMain% = TRUE THEN DimBound$ = DimBound$ + "public bad_" + vv$ + linefeed$
         DimBound$ = DimBound$ + "bad_" + vv$ + ": dw 0," + numl$(el&) + linefeed$
        END IF
       CASE "afb"
        ESused% = TRUE
        intcount% = intcount% + 1
        CALL AddDataRef("afb_" + vv$, 2, FMvar%)
        FarDimList$ = FarDimList$ + Hex4$((s& \ 16) + 1) + "," + t$ + "_" + vv$ + ","
        DimType$ = DimType$ + vv$ + "@:F" + numl$(el&) + " "
        IF SwPartial% = TRUE AND SwMain% = FALSE THEN
         DimBound$ = DimBound$ + "extrn bafb_" + vv$ + ":WORD" + linefeed$
        ELSE
         IF SwMain% = TRUE THEN DimBound$ = DimBound$ + "public bafb_" + vv$ + linefeed$
         DimBound$ = DimBound$ + "bafb_" + vv$ + ": dw 0," + numl$(el&) + linefeed$
        END IF
       CASE "afw"
        ESused% = TRUE
        intcount% = intcount% + 1
        CALL AddDataRef("afw_" + vv$, 2, FMvar%)
        FarDimList$ = FarDimList$ + Hex4$((s& \ 16) + 1) + "," + t$ + "_" + vv$ + ","
        DimType$ = DimType$ + vv$ + "%:F" + numl$(el&) + " "
        IF SwPartial% = TRUE AND SwMain% = FALSE THEN
         DimBound$ = DimBound$ + "extrn bafw_" + vv$ + ":WORD" + linefeed$
        ELSE
         IF SwMain% = TRUE THEN DimBound$ = DimBound$ + "public bafw_" + vv$ + linefeed$
         DimBound$ = DimBound$ + "bafw_" + vv$ + ": dw 0," + numl$(el&) + linefeed$
        END IF
       CASE "afd"
        ESused% = TRUE
        intcount% = intcount% + 1
        CALL AddDataRef("afd_" + vv$, 2, FMvar%)
'        CALL WriteFile("afd_" + vv$ + "	equ 0" + HEX$(DataPtr&) + "h", FMvar%)
'        DataPtr& = DataPtr& + 2
        FarDimList$ = FarDimList$ + Hex4$((s& \ 16) + 1) + "," + t$ + "_" + vv$ + ","
        DimType$ = DimType$ + vv$ + "&:F" + numl$(el&) + " "
        IF SwPartial% = TRUE AND SwMain% = FALSE THEN
         DimBound$ = DimBound$ + "extrn bafd_" + vv$ + ":WORD" + linefeed$
        ELSE
         IF SwMain% = TRUE THEN DimBound$ = DimBound$ + "public bafd_" + vv$ + linefeed$
         DimBound$ = DimBound$ + "bafd_" + vv$ + ": dw 0," + numl$(el&) + linefeed$
        END IF
       CASE "ahb"
        ESused% = TRUE
        intcount% = intcount% + 1
        CALL AddDataRef("ahb_" + vv$, 2, FMvar%)
        FarDimList$ = FarDimList$ + Hex4$((s& \ 16) + 1) + "," + t$ + "_" + vv$ + ","
        DimType$ = DimType$ + vv$ + "@:H" + numl$(el&) + " "
        IF SwPartial% = TRUE AND SwMain% = FALSE THEN
         DimBound$ = DimBound$ + "extrn bahb_" + vv$ + ":WORD" + linefeed$
        ELSE
         IF SwMain% = TRUE THEN DimBound$ = DimBound$ + "public bahb_" + vv$ + linefeed$
         DimBound$ = DimBound$ + "bahb_" + vv$ + ": dw 0," + numl$(el&) + linefeed$
        END IF
       CASE "ahw"
        ESused% = TRUE
        intcount% = intcount% + 1
        CALL AddDataRef("ahw_" + vv$, 2, FMvar%)
        FarDimList$ = FarDimList$ + Hex4$((s& \ 16) + 1) + "," + t$ + "_" + vv$ + ","
        DimType$ = DimType$ + vv$ + "%:H" + numl$(el&) + " "
        IF SwPartial% = TRUE AND SwMain% = FALSE THEN
         DimBound$ = DimBound$ + "extrn bahw_" + vv$ + ":WORD" + linefeed$
        ELSE
         IF SwMain% = TRUE THEN DimBound$ = DimBound$ + "public bahw_" + vv$ + linefeed$
         DimBound$ = DimBound$ + "bahw_" + vv$ + ": dw 0," + numl$(el&) + linefeed$
        END IF
       CASE "ahd"
        ESused% = TRUE
        intcount% = intcount% + 1
        CALL AddDataRef("ahd_" + vv$, 2, FMvar%)
'        CALL WriteFile("ahd_" + vv$ + "	equ 0" + HEX$(DataPtr&) + "h", FMvar%)
'        DataPtr& = DataPtr& + 2
        FarDimList$ = FarDimList$ + Hex4$((s& \ 16) + 1) + "," + t$ + "_" + vv$ + ","
        DimType$ = DimType$ + vv$ + "&:H" + numl$(el&) + " "
        IF SwPartial% = TRUE AND SwMain% = FALSE THEN
         DimBound$ = DimBound$ + "extrn bahd_" + vv$ + ":WORD" + linefeed$
        ELSE
         IF SwMain% = TRUE THEN DimBound$ = DimBound$ + "public bahd_" + vv$ + linefeed$
         DimBound$ = DimBound$ + "bahd_" + vv$ + ": dw 0," + numl$(el&) + linefeed$
        END IF
      END SELECT
      CALL CheckDS
      DimType$ = LCASE$(DimType$)

     CASE "STACK"
      IF UCASE$(RIGHT$(p$, 1)) = "K" THEN
       stacksize% = VAL(p$) * 1024
      ELSE
       stacksize% = VAL(p$)
      END IF
    
     CASE "STRSEGSIZE"
      IF UCASE$(RIGHT$(p$, 1)) = "K" THEN
       StrSegSize& = VAL(p$) * 1024
       IF StrSegSize& > 65535 THEN StrSegSize& = 65535
      ELSE
       StrSegSize& = VAL(p$)
      END IF
    CASE ELSE
     CALL ReportErr("^ Unrecognised definition keyword", 0, TRUE)
    END SELECT
   END IF

   END IF
  END IF
 ELSE
  IF LEFT$(l$, 1) = "$" THEN
   l$ = LTRIM$(MID$(l$, 2))
   ptr% = INSTR(l$, " ")
   IF ptr% <> 0 THEN
    k$ = UCASE$(LEFT$(l$, ptr% - 1))
    p$ = LTRIM$(MID$(l$, ptr%))
   ELSE
    k$ = UCASE$(l$)
    p$ = ""
   END IF
   IF WriteSource% = TRUE THEN
    CALL WriteFile("", FMcode%)
    CALL WriteFile(";  " + RIGHT$("0000" + numi$(linecount%), 4) + "  " + inline$, FMcode%)
   END IF
   SELECT CASE k$
    CASE "OUTSTREAM"
     outstream$ = LCASE$(p$)
     IF outstream$ = "_tty_str_direct" THEN SwStr$ = SwStr$ + "@ "
   CASE ELSE
    CALL ReportWarning("^ Unknown meta-command", 1, TRUE)
   END SELECT
  END IF
 END IF
FoundEOF:
WEND
IF IncludeSP% <> 0 THEN
 CLOSE #FMin%
 IncludeSP% = IncludeSP% - 1
 OPEN IncludeName$(IncludeSP%) FOR INPUT AS #FMin%
 CurrentFile$ = IncludeName$(IncludeSP%)
 ptr% = INSTR(CurrentFile$, "\")
 WHILE ptr% <> 0
  CurrentFile$ = MID$(CurrentFile$, ptr% + 1)
  ptr% = INSTR(CurrentFile$, "\")
 WEND
 SEEK #FMin%, IncludePosi&(IncludeSP%)
 linecount% = IncludeLine%(IncludeSP%)
 inline$ = ""
 ieof% = TRUE
 updsub% = TRUE
 GOTO GetLine
END IF
IF ForNextSP% < 0 THEN CALL ReportErr("Mismatched FOR..NEXT: too many NEXTs in sub " + currentsub$, 0, FALSE): ForNextSP% = 0
IF ForNextSP% > 0 THEN CALL ReportErr("Mismatched FOR..NEXT: too many FORs in sub " + currentsub$, 0, FALSE): ForNextSP% = 0
IF IfThenSP% < 0 THEN CALL ReportErr("Mismatched IF..ELSE..ENDIF: too many ENDIFs in sub " + currentsub$, 0, FALSE): IfThenSP% = 0
IF IfThenSP% > 0 THEN CALL ReportErr("Mismatched IF..ELSE..ENDIF: too many IFs in sub " + currentsub$, 0, FALSE): IfThenSP% = 0
IF CaseListSP% < 0 THEN CALL ReportErr("Mismatched SELECT CASE..CASE..END SELECT: too many END SELECTs in sub " + currentsub$, 0, FALSE): CaseListSP% = 0
IF CaseListSP% > 0 THEN CALL ReportErr("Mismatched SELECT CASE..CASE..END SELECT: too many SELECT CASEs in sub " + currentsub$, 0, FALSE): CaseListSP% = 0
IF WhileWendSP% < 0 THEN CALL ReportErr("Mismatched WHILE..WEND: too many WENDs in sub " + currentsub$, 0, FALSE): WhileWendSP% = 0
IF WhileWendSP% > 0 THEN CALL ReportErr("Mismatched WHILE..WEND: too many WHILEs in sub " + currentsub$, 0, FALSE): WhileWendSP% = 0

IF currentsub$ <> "(none):" AND currentsub$ <> ":" THEN CALL ReportErr("Final sub (" + LEFT$(currentsub$, LEN(currentsub$) - 1) + ") does not have END SUB", 0, FALSE)
PRINT SPACE$(79); : LOCATE , 1
LOCATE , , 1
END SUB

FUNCTION PointerModel% (bpptr%)
ptr% = INSTR(PtrTable$, ":" + UCASE$(bp$(bpptr%)) + " ")
IF ptr% <> 0 THEN
 SELECT CASE MID$(PtrTable$, ptr% - 2, 1)
  CASE "H"
   PointerModel% = Huge%
  CASE "N"
   PointerModel% = Near%
  CASE "F"
   PointerModel% = Far%
 END SELECT
END IF

END FUNCTION

FUNCTION PointerSize% (bpptr%)
ptr% = INSTR(PtrTable$, ":" + UCASE$(bp$(bpptr%)) + " ")
SELECT CASE MID$(PtrTable$, ptr% - 1, 1)
 CASE "B"
  PointerSize% = IntByte%
 CASE "W"
  PointerSize% = IntWord%
 CASE "D"
  PointerSize% = IntDoubleWord%
 CASE "S"
  PointerSize% = StringType%

END SELECT

END FUNCTION

FUNCTION PointerType% (bpptr%)
ptr% = INSTR(PtrTable$, ":" + UCASE$(bp$(bpptr%)) + " ")
IF ptr% <> 0 THEN
 SELECT CASE MID$(PtrTable$, ptr% - 2, 1)
  CASE "N"
   PointerType% = IntWord%
  CASE "F", "H"
   PointerType% = IntDoubleWord%
 END SELECT
ELSE
 PointerType% = UnknownType%
END IF
END FUNCTION

SUB ProcessCMP

  signed% = TRUE

  LocVarCount% = LocVarCount% + 1

  tin$ = inline$
  ptr% = INSTR(LCASE$(tin$), " then ")
  IF ptr% <> 0 THEN tin$ = LEFT$(tin$, ptr% - 1)

  IF sinstr(tin$, "<>=") = 0 THEN
   notflag% = FALSE
   IF bp$(1) = "not" THEN
    bp$(1) = bp$(2)
    bpt%(1) = bpt%(2)
    bpsp%(1) = bpsp%(2)
    bpar$(1) = bpar$(2)
    bpart%(1) = bpart%(2)
    bppr%(1) = bppr%(2)
    
    FOR i% = 1 TO bpp%
     bp$(i% + 2) = bp$(i%)
     bpt%(i% + 2) = bpt%(i%)
     bpsp%(i% + 2) = bpsp%(i%)
     bpar$(i% + 2) = bpar$(i%)
     bpart%(i% + 2) = bpart%(i%)
     bppr%(i% + 2) = bppr%(i%)
    NEXT
    bpp% = bpp% + 2
    notflag% = TRUE
   END IF

'   IF bp$(bpp%) = "then" THEN bpp% = bpp% - 1
'   bpt%(bpp% + 1) = TermType%
  
     
   IF notflag% = TRUE THEN
    bp$(2) = "="
    bp$(3) = "0"
   ELSE
    bp$(2) = "<>"
    bp$(3) = "0"
   END IF
   bpt%(2) = TermType%
   bpt%(3) = IntConst%

'PRINT tin$
'FOR i% = 0 TO bpp%: PRINT bp$(i%); " "; : NEXT
'PRINT

'   bpt%(bpp% + 2) = IntConst%

'   bp$(bpp% + 3) = "then": bpt%(bpp% + 3) = CmdType%
'   bpp% = bpp% + 3
  END IF
  
  n1f% = FALSE
  IF bpt%(1) = Num1Func% THEN
   n1f% = TRUE
   bp$(0) = "t1%": bpt%(0) = IntWord%
   FOR i% = bpp% - 1 TO 1 STEP -1
    bp$(i% + 1) = bp$(i%)
    bpt%(i% + 1) = bpt%(i%)
    bpar$(i% + 1) = bpar$(i%)
    bpart%(i% + 1) = bpart%(i%)
    bppr%(i% + 1) = bppr%(i%)
   NEXT
   bpp% = bpp% + 1
  
  CALL ProcessNum1Func(FALSE)
   bp$(1) = "t1%": bpt%(1) = IntWord%
   CALL AddIntVar(bp$(1), 2, 1)
   FOR i% = 3 TO bpp%
    IF bpt%(i%) = TermType% THEN EXIT FOR
   NEXT
   k% = 2
   FOR j% = i% TO bpp%
    bp$(k%) = bp$(j%): bpt%(k%) = bpt%(j%): bpar$(k%) = bpar$(j%): bpart%(k%) = bpart%(j%)
    k% = k% + 1
   NEXT
   bpp% = bpp% - i% + 1
  END IF
  
  IF bpp% = 1 THEN
   bp$(2) = "=": bpt%(2) = TermType%
   bp$(3) = "-1": bpt%(3) = IntConst%
   bpp% = 3
  END IF

  IF bpp% = 2 AND bp$(1) = "not" THEN
   bp$(1) = bp$(2): bpt%(1) = bpt%(2)
   bp$(2) = "<>": bpt%(2) = TermType%
   bp$(3) = "-1": bpt%(3) = IntConst%
   bpp% = 3
  END IF

  IF bp$(2) = "<" AND bp$(3) = ">" THEN
   bp$(2) = "<>"
   k% = 3
   FOR j% = 4 TO bpp%
    bp$(k%) = bp$(j%)
    bpt%(k%) = bpt%(j%)
    bpar$(k%) = bpar$(j%)
    bpart%(k%) = bpart%(j%)
    bppr%(k%) = bppr%(j%)
    k% = k% + 1
   NEXT
   bpp% = bpp% - 1
  END IF
  
  IF bp$(2) = "<" AND bp$(3) = "=" THEN
   bp$(2) = "<="
   k% = 3
   FOR j% = 4 TO bpp%
    bp$(k%) = bp$(j%): bpt%(k%) = bpt%(j%): bpar$(k%) = bpar$(j%): bpart%(k%) = bpart%(j%)
    k% = k% + 1
   NEXT
   bpp% = bpp% - 1
  END IF

  IF bp$(2) = ">" AND bp$(3) = "=" THEN
   bp$(2) = ">="
   k% = 3
   FOR j% = 4 TO bpp%
    bp$(k%) = bp$(j%): bpt%(k%) = bpt%(j%): bpar$(k%) = bpar$(j%): bpart%(k%) = bpart%(j%)
    k% = k% + 1
   NEXT
   bpp% = bpp% - 1
  END IF

  IF bp$(1) = "true" THEN bp$(1) = "-1": bpt%(1) = IntConst%
  IF bp$(1) = "false" THEN bp$(1) = "0": bpt%(1) = IntConst%
  IF bp$(3) = "true" THEN bp$(3) = "-1": bpt%(3) = IntConst%
  IF bp$(3) = "false" THEN bp$(3) = "0": bpt%(3) = IntConst%

  pr1% = bpt%(1)
  pr3% = bpt%(3)
  precision% = IntByte%
  IF pr1% = IntWord% OR pr3% = IntWord% THEN precision% = IntWord%
  IF pr1% = IntDoubleWord% OR pr3% = IntDoubleWord% THEN precision% = IntDoubleWord%

  SELECT CASE bpt%(1)
   CASE StringType%
    IF bp$(3) = "mr@null$" THEN
   
     SELECT CASE bp$(2)
      CASE "="
       IF lastsvar2$ = bp$(1) THEN
        PutLine ("mov cx,ds:[di]")
       ELSE
        PutLine ("mov si,ds:[%01];mov cx,ds:[si]")
       END IF
       PutLine ("jcxz short LL" + numi$(LocVarCount%))
      CASE "<>"
       IF lastsvar2$ = bp$(1) THEN
        PutLine ("cmp word ptr ds:[di],0")
       ELSE
        PutLine ("mov si,ds:[%01];cmp word ptr ds:[si],0")
       END IF
       PutLine ("jnz short LL" + numi$(LocVarCount%))
     END SELECT
     EXIT SUB
    END IF
  
    SELECT CASE bpt%(3)
     CASE StrConst%
      t% = VAL(MID$(bp$(3), 5))
      IF LEN(sc$(t%)) = 3 AND INSTR(sc$(t%), "\") = 0 THEN
       IF lastsvar2$ <> bp$(1) THEN PutLine ("mov di,ds:[%01]")
       PutLine ("cmp word ptr ds:[di],1")
       SELECT CASE bp$(2)
        CASE "="
         PutLine ("jnz short LL" + numi$(LocVarCount%))
        CASE "<>"
         PutLine ("jnz short LL" + numi$(LocVarCount% + 1))
       END SELECT
       PutLine ("cmp byte ptr ds:[di+2]," + numi$(ASC(MID$(sc$(VAL(MID$(bp$(3), 5))), 2))))
       SELECT CASE bp$(2)
        CASE "="
         PutLine ("jz short LL" + numi$(LocVarCount% + 1))
        CASE "<>"
         PutLine ("jnz short LL" + numi$(LocVarCount% + 1))
       END SELECT
       PutLine ("LL" + numi$(LocVarCount%) + ":")
       LocVarCount% = LocVarCount% + 1
       EXIT SUB
      END IF
      PutLine ("mov si,offset %03;call _str_cs_ds;push si")
     CASE StringType%
      IF lastsvar2$ = bp$(3) THEN
       PutLine ("mov si,di")
      ELSE
       PutLine ("mov si,ds:[%03]")
      END IF
    END SELECT
    IF lastsvar2$ = bp$(1) THEN
     ' DI already set
    ELSE
     PutLine ("mov di,ds:[%01]")
    END IF
   
    PutLine ("call _str_compare")
    IF bpt%(3) = StrConst% THEN PutLine ("pop bx;pushf;call _mem_free;popf")
    SELECT CASE bp$(2)
     CASE "="
      PutLine ("jz short LL" + numi$(LocVarCount%))
     CASE "<>"
      PutLine ("jnz short LL" + numi$(LocVarCount%))
     CASE "<"
      PutLine ("jb short LL" + numi$(LocVarCount%))
     CASE ">"
      PutLine ("ja short LL" + numi$(LocVarCount%))
     CASE "<="
      PutLine ("jbe short LL" + numi$(LocVarCount%))
     CASE ">="
      PutLine ("jae short LL" + numi$(LocVarCount%))
    END SELECT
    EXIT SUB
  
   CASE IntConst%
    Split4 (bp$(3))
    IF lastivar2$ <> bp$(3) THEN
     PutLine ("mov ax," + Hex4$(vl&))
     lastivar2$ = bp$(3)
    END IF
    IF precision% = IntDoubleWord% THEN PutLine ("mov dx," + Hex4$(vh&))
   CASE IntByte%
    IF bpt%(3) <> IntConst% THEN PutLine ("mov al,byte ptr ds:[%01]")
    IF precision% = IntWord% OR precision% = IntDoubleWord% THEN PutLine ("xor ah,ah")
    IF precision% = IntDoubleWord% THEN PutLine ("xor dx,dx")
   CASE IntWord%
    IF bpt%(3) <> IntConst% AND lastivar2$ <> bp$(1) THEN PutLine ("mov ax,ds:[%01]"): lastivar2$ = bp$(1)
    IF precision% = IntDoubleWord% THEN PutLine ("xor dx,dx")
   CASE IntDoubleWord%
    IF lastivar2$ <> bp$(1) THEN PutLine ("mov ax,ds:[%01];mov dx,ds:[%01+2]"): lastivar2$ = bp$(1)
   CASE NumFunc%
    z% = 1
    CALL EvaluateNum(z%, precision%, "ax", "dx")
    IF hiprecision% > precision% THEN precision% = hiprecision%
    n1f% = TRUE
    z% = z% - 1
    IF z% > 0 THEN
     FOR i% = 1 TO bpp%
      bp$(i%) = bp$(i% + z%)
      bpt%(i%) = bpt%(i% + z%)
      bpar$(i%) = bpar$(i% + z%)
      bpart%(i%) = bpart%(i% + z%)
    NEXT
    bpp% = bpp% - z%
   END IF
  END SELECT

  IF precision% = IntDoubleWord% THEN signed% = FALSE

  SELECT CASE precision%
   CASE IntByte%
    SELECT CASE bpt%(3)
     CASE IntConst%
      PutLine ("cmp byte ptr ds:[%01],*03")
     CASE IntByte%, IntWord%, IntDoubleWord%
      PutLine ("cmp al,byte ptr ds:[%03]")
    END SELECT
   CASE IntWord%
    SELECT CASE bpt%(3)
     CASE IntConst%
      IF n1f% = FALSE THEN
        IF lastivar2$ = bp$(1) THEN
         IF bp$(3) = "0" THEN
          PutLine ("test ax,ax")
         ELSE
          PutLine ("cmp ax,*03")
         END IF
        ELSE
         PutLine ("cmp word ptr ds:[%01],*03")
        END IF
      ELSE
       IF bp$(3) = "0" THEN
        PutLine ("test ax,ax")
       ELSE
        PutLine ("cmp ax,*03")
       END IF
      END IF
     CASE IntByte%, IntWord%, IntDoubleWord%
      PutLine ("cmp ax,ds:[%03]")
    END SELECT
   CASE IntDoubleWord%
    SELECT CASE bpt%(3)
     CASE IntConst%
      Split4 (bp$(3))
      PutLine ("cmp dx," + numl$(vh&) + ";jnz short LL" + numi$(LocVarCount%))
      PutLine ("cmp ax," + numl$(vl&) + ";LL" + numi$(LocVarCount%) + ":")
      LocVarCount% = LocVarCount% + 1
     CASE IntWord%
      PutLine ("cmp word ptr ds:[%03+2], 0;jnz short LL" + numi$(LocVarCount%))
      PutLine ("cmp ax,ds:[%03];LL" + numi$(LocVarCount%) + ":")
      LocVarCount% = LocVarCount% + 1
     CASE IntDoubleWord%
      PutLine ("cmp dx,ds:[%03+2];jnz short LL" + numi$(LocVarCount%))
      PutLine ("cmp ax,ds:[%03];LL" + numi$(LocVarCount%) + ":")
      LocVarCount% = LocVarCount% + 1
    END SELECT
  END SELECT
   
'    ErrOverflow
    SELECT CASE bp$(2)
     CASE "="
      PutLine ("jz short LL" + numi$(LocVarCount%))
     CASE "<>"
      PutLine ("jnz short LL" + numi$(LocVarCount%))
     CASE "<"
      IF signed% = TRUE THEN
       PutLine ("jl short LL" + numi$(LocVarCount%))
      ELSE
       PutLine ("jb short LL" + numi$(LocVarCount%))
      END IF
     CASE ">"
      IF signed% = TRUE THEN
       PutLine ("jg short LL" + numi$(LocVarCount%))
      ELSE
       PutLine ("ja short LL" + numi$(LocVarCount%))
      END IF
     CASE "<="
      IF signed% = TRUE THEN
       PutLine ("jle short LL" + numi$(LocVarCount%))
      ELSE
       PutLine ("jbe short LL" + numi$(LocVarCount%))
      END IF
     CASE ">="
      IF signed% = TRUE THEN
       PutLine ("jge short LL" + numi$(LocVarCount%))
      ELSE
       PutLine ("jae short LL" + numi$(LocVarCount%))
      END IF
    END SELECT


END SUB

SUB ProcessLine

IF SwOpt% = TRUE THEN
 lastivar2$ = lastivar1$
 lastsvar2$ = lastsvar1$
ELSE
 lastivar2$ = ""
 lastsvar2$ = ""
END IF

lastsvar1$ = ""
lastivar1$ = ""
freeflag% = FALSE

'BPval$ = ""
LastValES$ = "" ' *** TEMP ***

'tmp$ = GenRep$(TRUE)

pushfirst% = FALSE
mempop% = 0

hiprecision% = IntWord%

IF INSTR(inline$, "-") <> 0 THEN
 FOR z% = 1 TO bpp%
  IF bp$(z%) = "-" AND bpt%(z% + 1) = IntConst% AND (bpt%(z% - 1) = TermType% OR bp$(0) = "case") THEN
   bp$(z%) = "-" + bp$(z% + 1)
   bpt%(z%) = IntConst%
   FOR j% = z% + 2 TO bpp%
    bp$(j% - 1) = bp$(j%)
    bpt%(j% - 1) = bpt%(j%)
    bpsp%(j% - 1) = bpsp%(j%)
    bpar$(j% - 1) = bpar$(j%)
   NEXT
   bpp% = bpp% - 1
 END IF
 NEXT
END IF

IF bpt%(0) = CmdType% THEN
 CALL ProcessCommand
 EXIT SUB

ELSE

IF bp$(1) = "=" THEN
 IF bpp% = 2 AND (bpt%(2) = IntByte% OR bpt%(2) = IntWord% OR bpt%(2) = IntDoubleWord% OR bpt%(2) = IntConst%) THEN SetBPreg ("bx")

 IF bpt%(2) = Num1Func% THEN CALL ProcessNum1Func(TRUE): EXIT SUB

 IF bpt%(0) = StringType% AND bp$(2) = "mr@null$" AND bpp% = 2 THEN
  SetBPreg ("si")
  PutLine ("mov bx,ds:[%00];call _mem_free")
  PutLine ("xor ax,ax;mov ds:[%00],ax")
  SetBPreg ("bx")
  EXIT SUB
 END IF

 IF bpt%(0) = StringType% AND (bpt%(2) = StringType% OR bpt%(2) = StrConst%) AND bpp% = 2 THEN
  PutLine ("mov bx,ds:[%00];call _mem_free")
  SELECT CASE bpt%(2)
   CASE StrConst%
    PutLine ("mov si,offset %02;call _str_cs_ds;mov ds:[%00],si")
    EXIT SUB
   CASE StringType%
    IF lastsvar2$ = bp$(2) THEN
     PutLine ("mov si,di")
    ELSE
     PutLine ("mov si,ds:[%02]")
    END IF
    PutLine ("call _str_copy")
  END SELECT
  PutLine ("mov ds:[%00],di")
  lastsvar1$ = bp$(0)
  EXIT SUB
 END IF

 IF bpt%(0) = StringType% AND INSTR(inline$, "+") <> 0 THEN
 'a$=b$+c$+d$+...
  freeflag% = TRUE
 
  ' freeflag% TRUE means that the dest string can be freed prior to mixing

  FOR z% = 2 TO bpp%
   IF bp$(z%) = bp$(0) THEN freeflag% = FALSE
  NEXT
  IF freeflag% = TRUE THEN
    PutLine ("mov bx,ds:[%00];call _mem_free")
  END IF
 
  CALL GatherPrint(2)
  IF freeflag% = FALSE THEN
    PutLine ("mov bx,ds:[%00];call _mem_free")
  END IF
  PutLine ("mov ds:[%00],di")
  IF release% = TRUE THEN PutLine ("call _str_release")
  EXIT SUB
 END IF

 IF bpt%(0) = StringType% THEN
  freeflag% = TRUE
  FOR z% = 2 TO bpp%
   IF bp$(z%) = bp$(0) THEN freeflag% = FALSE
  NEXT
  IF freeflag% = TRUE THEN
    PutLine ("mov bx,ds:[%00];call _mem_free")
  ELSE
   pushfirst% = TRUE
  END IF
 END IF

 IF (bpt%(0) = IntByte% OR bpt%(0) = IntWord% OR bpt%(0) = IntDoubleWord%) AND (bpt%(4) = IntByte% OR bpt%(4) = IntWord% OR bpt%(4) = IntDoubleWord%) AND bpp% = 4 THEN
  SetBPreg ("bx")
  IF bp$(0) = bp$(2) AND bpar$(0) = bpar$(2) THEN
   SELECT CASE bp$(3)
    CASE "+"
     SELECT CASE bpt%(0)
      CASE IntByte%
       IF lastivar2$ <> bp$(4) THEN PutLine ("mov al,byte ptr ds:[%04]"): lastivar2$ = bp$(4)
       PutLine ("add byte ptr ds:[%00],al")
       ErrOverflow
       SetBPreg ("bp")
       EXIT SUB
      CASE IntWord%
       IF lastivar2$ <> bp$(4) THEN PutLine ("mov ax,ds:[%04]"): lastivar2$ = bp$(4)
       PutLine ("add ds:[%00],ax")
       ErrOverflow
       SetBPreg ("bp")
       EXIT SUB
      CASE IntDoubleWord%
       SELECT CASE bpt%(4)
        CASE IntByte%
         IF Processor% >= 386 THEN
          PutLine ("movsx byte ptr ds:[%04];add dword ptr ds:[%00],eax")
         ELSE
          IF lastivar2$ <> bp$(4) THEN PutLine ("mov al,byte ptr ds:[%04];cbw;cwd"): lastivar2$ = bp$(4)
          PutLine ("add ds:[%00],ax;adc ds:[%00+2],dx")
         END IF
         ErrOverflow
         SetBPreg ("bp")
         EXIT SUB

        CASE IntWord%
         IF Processor% >= 386 THEN
          PutLine ("movsx eax,word ptr ds:[%04];add dword ptr ds:[%00],eax")
         ELSE
          IF lastivar2$ <> bp$(4) THEN PutLine ("mov ax,ds:[%04];cwd"): lastivar2$ = bp$(4)
          PutLine ("add ds:[%00],ax;adc ds:[%00+2],dx")
         END IF
         ErrOverflow
         SetBPreg ("bp")
         EXIT SUB
        CASE IntDoubleWord%
         IF Processor% >= 386 THEN
          PutLine ("mov eax,dword ptr ds:[%04];add dword ptr ds:[%00],eax")
         ELSE
          IF lastivar2$ <> bp$(4) THEN PutLine ("mov ax,ds:[%04];mov dx,ds:[%04+2]"): lastivar2$ = bp$(4)
          PutLine ("add ds:[%00],ax;adc ds:[%00+2],dx")
         END IF
         ErrOverflow
         SetBPreg ("bp")
         EXIT SUB
       END SELECT
     END SELECT
   
    CASE "-"
     SELECT CASE bpt%(0)
      CASE IntByte%
       IF lastivar2$ <> bp$(4) THEN PutLine ("mov al,byte ptr ds:[%04]"): lastivar2$ = bp$(4)
       PutLine ("sub byte ptr ds:[%00],al")
       SetBPreg ("bp")
       EXIT SUB
      CASE IntWord%
       IF lastivar2$ <> bp$(4) THEN PutLine ("mov ax,ds:[%04]"): lastivar2$ = bp$(4)
       PutLine ("sub ds:[%00],ax")
       SetBPreg ("bp")
       EXIT SUB
      CASE IntDoubleWord%
       SELECT CASE bpt%(4)
        CASE IntByte%
         IF Processor% >= 386 THEN
          PutLine ("movsx byte ptr ds:[%04];sub dword ptr ds:[%00],eax")
         ELSE
          IF lastivar2$ <> bp$(4) THEN PutLine ("mov al,byte ptr ds;[%04];cbw;cwd"): lastivar2$ = bp$(4)
          PutLine ("sub ds:[%00],ax;sbb ds:[%00+2],dx")
         END IF
         SetBPreg ("bp")
         EXIT SUB
        CASE IntWord%
         IF Processor% >= 386 THEN
          PutLine ("movsx eax,ds:[%04];sub dword ptr ds:[%00],eax")
         ELSE
          IF lastivar2$ <> bp$(4) THEN PutLine ("mov ax,ds:[%04];cwd"): lastivar2$ = bp$(4)
          PutLine ("sub ds:[%00],ax;sbb ds:[%00+2],dx")
         END IF
         SetBPreg ("bp")
         EXIT SUB
        CASE IntDoubleWord%
         IF Processor% >= 386 THEN
          PutLine ("mov eax,dword ptr ds:[%04];sub dword ptr ds:[%00],eax")
         ELSE
          IF lastivar2$ <> bp$(4) THEN PutLine ("mov ax,ds:[%04];mov dx,ds:[%04+2]"): lastivar2$ = bp$(4)
          PutLine ("sub ds:[%00],ax;sbb ds:[%00+2],dx")
         END IF
         SetBPreg ("bp")
         EXIT SUB
       END SELECT
     END SELECT
     
   END SELECT
  END IF
  SetBPreg ("bp")
 END IF

' SELECT CASE bpt%(0)
'  CASE Pointer%
'   precision% = PointerType%(0)
'  CASE PointerRef%
'   precision% = PointerSize%(0)
'   IF precision% = IntByte% THEN precision% = IntWord%
'  CASE ELSE
   precision% = bpt%(0)
' END SELECT

 hiprecision% = IntWord%
 FOR j% = 0 TO bpp%
  IF bpt%(j%) = IntDoubleWord% THEN hiprecision% = IntDoubleWord%
 NEXT

 IF precision% = IntWord% OR precision% = IntDoubleWord% THEN
  IF (bp$(0) = bp$(2)) AND (bpar$(0) = bpar$(2)) AND (bpt%(0) = bpt%(2)) AND (bpt%(4) = IntWord% OR bpt%(4) = IntDoubleWord% OR bpt%(4) = IntConst%) AND bpp% = 4 THEN
   SELECT CASE bp$(3)
    CASE "+"
     IF bp$(4) = "1" THEN
      SELECT CASE precision%
       CASE IntWord%
        PutLine ("inc word ptr ds:[%00]")
       CASE IntDoubleWord%
        IF Processor% >= 386 THEN
         PutLine ("inc dword ptr ds:[%00]")
        ELSE
         PutLine ("add word ptr ds:[%00],1;adc word ptr ds:[%00+2],0")
        END IF
      END SELECT
      lastsvar1$ = lastsvar2$
      ErrOverflow
      EXIT SUB
     ELSE
      
      SELECT CASE precision%
       CASE IntWord%
        SELECT CASE bpt%(4)
         CASE IntConst%
          PutLine ("add word ptr ds:[%00],*04")
         CASE IntWord%, IntDoubleWord%
          IF lastivar2$ <> bp$(4) THEN PutLine ("mov ax,ds:[%04]"): lastivar2$ = bp$(4)
          PutLine ("add ds:[%00],ax")
        END SELECT
        ErrOverflow
        EXIT SUB
       CASE IntDoubleWord%
        SELECT CASE bpt%(4)
         CASE IntConst%
          IF Processor% >= 386 THEN
           PutLine ("add dword ptr ds:[%00]," + bp$(4))
          ELSE
           Split4 (bp$(4))
           PutLine ("add word ptr ds:[%00]," + Hex4$(vl&))
           PutLine ("adc word ptr ds:[%00+2]," + Hex4$(vh&))
          END IF
         CASE IntWord%
          IF Processor% >= 386 THEN
           PutLine ("movsx eax,word ptr ds:[%04];add dword ptr ds:[%00],eax")
          ELSE
           IF lastivar2$ <> bp$(4) THEN PutLine ("mov ax,ds:[%04];cwd"): lastivar2$ = bp$(4)
           PutLine ("add ds:[%00],ax;add ds:[%00+2],dx")
          END IF
         CASE IntDoubleWord%
          IF Processor% >= 386 THEN
           PutLine ("mov eax,dword ptr ds:[%04];add dword ptr ds:[%00],eax")
          ELSE
           IF lastivar2$ <> bp$(4) THEN PutLine ("mov ax,ds:[%04];mov dx,ds:[%04+2]"): lastivar2$ = bp$(4)
           PutLine ("add ds:[%00],ax;adc ds:[%04+2],dx")
          END IF
        END SELECT
        ErrOverflow
        EXIT SUB
       END SELECT

      SELECT CASE bpt%(4)
       CASE IntConst%
        SELECT CASE precision%
         CASE IntWord%
          PutLine ("add word ptr ds:[%00],*04")
          ErrOverflow
          lastsvar1$ = lastsvar2$
          EXIT SUB
         CASE IntDoubleWord%
          IF Processor% >= 386 THEN
           PutLine ("add dword ptr ds:[%00]," + Hex8$(CVAL(bp$(4))))
          ELSE
           Split4 (bp$(4))
           PutLine ("add word ptr ds:[%00]," + Hex4$(vl&))
           PutLine ("adc word ptr ds:[%00+2]," + Hex4$(vh&))
          END IF
          ErrOverflow
          lastsvar1$ = lastsvar2$
          EXIT SUB
         END SELECT
' ***********************************
       CASE IntWord%
        PutLine ("mov ax,ds:[%00];add ax,ds:[%04];mov ds:[%00],ax")
        ErrOverflow
        lastsvar1$ = lastsvar2$
        EXIT SUB
       CASE IntDoubleWord%
        PutLine ("mov ax,ds:[%00];mov dx,ds:[%00+2];add ax,ds:[%04];adc dx,ds:[%04+2];mov ds:[%00],ax;mov ds:[%00+2],dx")
        ErrOverflow
        lastsvar1$ = lastsvar2$
        EXIT SUB
      END SELECT
     END IF
   
    CASE "-"
     IF bp$(4) = "1" THEN
      SELECT CASE precision%
       CASE IntWord%
        PutLine ("dec word ptr ds:[%00]")
       CASE IntDoubleWord%
        IF Processor% >= 386 THEN
         PutLine ("dec dword ptr ds:[%00]")
        ELSE
         PutLine ("sub word ptr ds:[%00], 1;sbb word ptr ds:[%00+2], 0")
        END IF
      END SELECT
      lastsvar1$ = lastsvar2$
      EXIT SUB
     ELSE
      SELECT CASE precision%
       CASE IntWord%
        SELECT CASE bpt%(4)
         CASE IntConst%
          PutLine ("sub word ptr ds:[%00],*04")
         CASE IntWord%, IntDoubleWord%
          IF lastivar2$ <> bp$(4) THEN PutLine ("mov ax,ds:[%04]"): lastivar2$ = bp$(4)
          PutLine ("sub ds:[%00],ax")
        END SELECT
        EXIT SUB
       CASE IntDoubleWord%
        SELECT CASE bpt%(4)
         CASE IntConst%
          IF Processor% >= 386 THEN
           PutLine ("sub dword ptr ds:[%00]," + Hex8$(CVAL(bp$(4))))
          ELSE
           Split4 (bp$(4))
           PutLine ("sub word ptr ds:[%00]," + Hex4$(vl&))
           PutLine ("sbb word ptr ds:[%00+2]," + Hex4$(vh&))
          END IF
         CASE IntWord%
          IF lastivar2$ <> bp$(0) THEN PutLine ("mov ax,ds:[%00];mov dx,ds:[%00+2]"): lastivar2$ = bp$(0)
          PutLine ("sub ax,ds:[%04];sbb dx,0;mov ds:[%00],ax;mov ds:[%00+2],dx")
         CASE IntDoubleWord%
          IF lastivar2$ <> bp$(0) THEN PutLine ("mov ax,ds:[%00];mov dx,ds:[%00+2]"): lastivar2$ = bp$(0)
          PutLine ("sub ax,ds:[%04];sbb dx,ds:[%04+2];mov ds:[%00],ax;mov ds:[%00+2],dx")
        END SELECT
        lastsvar1$ = lastsvar2$
        EXIT SUB
       END SELECT

      SELECT CASE bpt%(4)
       CASE IntConst%
        SELECT CASE precision%
         CASE IntWord%
          PutLine ("sub word ptr ds:[%00],*04")
          lastsvar1$ = lastsvar2$
          EXIT SUB
         CASE IntDoubleWord%
          Split4 (bp$(4))
          PutLine ("sub word ptr ds:[%00]," + Hex4$(vl&))
          PutLine ("sbb word ptr ds:[%00+2]," + Hex4$(vh&))
          lastsvar1$ = lastsvar2$
          EXIT SUB
         END SELECT
' ***********************************
       CASE IntWord%
        IF lastivar2$ <> bp$(4) THEN PutLine ("mov ax,ds:[%04]"): lastivar2$ = bp$(4)
        PutLine ("sub ds:[%00],ax")
        EXIT SUB
       CASE IntDoubleWord%
        IF lastivar2$ <> bp$(0) THEN PutLine ("mov ax,ds:[%00];mov dx,ds:[%00+2]"): lastivar2$ = bp$(0)
        PutLine ("sub ax,ds:[%04];sbb dx,ds:[%04+2];mov ds:[%00],ax;mov ds:[%00+2],dx")
        EXIT SUB
      END SELECT
     END IF

    CASE "*"
     SELECT CASE precision%
      CASE IntWord%
       SELECT CASE bpt%(4)
        CASE IntConst%
         PutLine ("mov ax,*04;imul word ptr ds:[%00]")
        CASE IntWord%
         IF lastivar2$ <> bp$(0) THEN PutLine ("mov ax,ds:[%00]"): lastivar2$ = bp$(0)
         PutLine ("imul word ptr ds:[%04];mov ds:[%00],ax")
        CASE IntDoubleWord%
         IF Processor% >= 386 THEN
          PutLine ("movsx eax,word ptr ds:[%00];imul dword ptr ds:[%04];mov word ptr ds:[%00],ax")
         ELSE
          IF lastivar2$ <> bp$(0) THEN PutLine ("mov ax,ds:[%00];cwd"): lastivar2$ = bp$(0)
          PutLine ("mov ds:[t1],ax;mov ds:[t1+2],dx")
          PutLine ("mov si,t1;mov di,offset %04;call _mul32;mov ds:[%00],ax")
         END IF
       END SELECT
       EXIT SUB
      CASE IntDoubleWord%
       SELECT CASE bpt%(4)
        CASE IntConst%
         IF Processor% >= 386 THEN
          IF CVAL(bp$(4)) = 0 THEN
           PutLine ("xor eax,eax")
          ELSE
           PutLine ("mov eax," + Hex8$(CVAL(bp$(4))))
          END IF
          PutLine ("imul dword ptr ds:[%00]")
         ELSE
          Split4 (bp$(4))
          PutLine ("mov word ptr ds:[t1]," + Hex4$(vl&) + ";mov word ptr ds:[t2]," + Hex4$(vh&))
          PutLine ("mov si,offset t1;mov di,offset %00;call _mul32;mov ds:[%00],ax;mov ds:[%00+2],dx")
         END IF
        CASE IntWord%
         IF Processor% >= 386 THEN
          PutLine ("movsx eax,word ptr ds:[%04];imul dword ptr ds:[%00]")
         ELSE
          PutLine ("mov ax,ds:[%04];cwd;mov ds:[t1],ax;mov ds:[t2],dx")
          PutLine ("mov si,offset t1;mov di,offset %00;call _mul32;mov ds:[%00],ax;mov ds:[%00+2],dx")
         END IF
        CASE IntDoubleWord%
         IF Processor% >= 386 THEN
          PutLine ("mov eax,dword ptr ds:[%04];imul dword ptr ds:[%00]")
         ELSE
          PutLine ("mov si,offset %00;mov di,offset %04;call _mul32;mov ds:[%00],ax;mov ds:[%00+2],dx")
         END IF
       END SELECT
       EXIT SUB
      END SELECT
 
    CASE "/", "\"
     SELECT CASE precision%
      CASE IntWord%
       SELECT CASE bpt%(4)
        CASE IntConst%
         PutLine ("mov ax,ds:[%00];cwd;mov bx,*04;idiv bx")
        CASE IntWord%
         IF lastivar2$ <> bp$(0) THEN PutLine ("mov ax,ds:[%00]"): lastivar2$ = bp$(0)
         PutLine ("cwd;idiv ds:[%04];mov ds:[%00],ax")
        CASE IntDoubleWord%
         IF Processor% >= 386 THEN
          PutLine ("movsx eax,word ptr ds:[%00];cdq;idiv dword ptr ds:[%04];mov word ptr ds:[%00],ax")
         ELSE
          IF lastivar2$ <> bp$(0) THEN PutLine ("mov ax,ds:[%00];cwd"): lastivar2$ = bp$(0)
'          PutLine ("mov ds:[t1],ax;mov ds:[t1+2],dx")
'          PutLine ("mov si,offset t1;mov di,offset %04;call _div32;mov ds:[%00],ax")
          PutLine ("push word ptr ds:[%04+2];push word ptr ds:[%04];push dx;push ax;call _div32;mov ds:[%00],ax")
         END IF
       END SELECT
       EXIT SUB
      CASE IntDoubleWord%
       SELECT CASE bpt%(4)
        CASE IntConst%
         IF Processor% >= 386 THEN
          IF CVAL(bp$(4)) = 0 THEN
           PutLine ("xor ebx,ebx")
          ELSE
           PutLine ("mov ebx," + Hex8$(CVAL(bp$(4))))
          END IF
          PutLine ("mov eax,dword ptr ds:[%00];cdq;idiv ebx;mov dword ptr ds:[%00],eax")
'          PutLine ("cdq;idiv dword ptr ds:[%00]")
         ELSE
          Split4 (bp$(4))
'          PutLine ("mov word ptr ds:[t1]," + Hex4$(vl&) + ";mov word ptr ds:[t2]," + Hex4$(vh&))
 '         PutLine ("mov si,offset t1;mov di,offset %00;call _div32;mov ds:[%00],ax;mov ds:[%00+2],dx")
          PutLine ("mov ax," + Hex4$(vh&) + ";push ax;mov ax," + Hex4$(vl&) + ";push ax")
          PutLine ("push word ptr ds:[%00+2];push word ptr ds:[%00]")
          PutLine ("call _div32;mov ds:[%00],ax;mov ds:[%00+2],dx")
         END IF
        CASE IntWord%
         IF Processor% >= 386 THEN
          PutLine ("movsx eax,word ptr ds:[%04];cdq;idiv dword ptr ds:[%00]")
         ELSE
'          PutLine ("mov ax,ds:[%04];cwd;mov ds:[t1],ax;mov ds:[t1+2],dx")
          PutLine ("mov ax,ds:[%04];cwd;push dx;push ax")
          PutLine ("push word ptr ds:[%00+2];push word ptr ds:[%00]")
'          PutLine ("mov si,offset t1;mov di,offset %00;call _div32;mov ds:[%00],ax;mov ds:[%00+2],dx")
          PutLine ("call _div32;mov ds:[%00],ax;mov ds:[%00+2],dx")
         END IF
        CASE IntDoubleWord%
         IF Processor% >= 386 THEN
          PutLine ("mov eax,dword ptr ds:[%04];cdq;idiv dword ptr ds:[%00]")
         ELSE
'          PutLine ("mov si,offset %00;mov di,offset %04;call _div32;mov ds:[%00],ax;mov ds:[%00+2],dx")
           PutLine ("push word ptr ds:[%04+2];push word ptr ds:[%04]")
           PutLine ("push word ptr ds:[%00+2];push word ptr ds:[%00]")
           PutLine ("call _div32;mov ds:[%00],ax;mov ds:[%00+2],dx")

         END IF
       END SELECT
       EXIT SUB
      END SELECT

   END SELECT
  ELSE
   IF bpp% = 2 AND bpt%(2) = IntConst% THEN
    IF SwSpeed% = FALSE THEN

     'SELECT CASE precision%
     SELECT CASE bpt%(0)
      CASE IntByte%
       IF bp$(2) = "0" THEN
        IF lastivar2$ <> "0000" AND lastivar2$ <> "00000000" THEN
         PutLine ("xor ax,ax")
        END IF
        PutLine ("mov ds:[%00],al")
        lastivar1$ = "0000"
       ELSE
        PutLine ("mov byte ptr ds:[%00],*02")
       END IF
      CASE IntWord%
       IF bp$(2) = "0" THEN
        IF lastivar2$ <> "0000" AND lastivar2$ <> "00000000" THEN
         PutLine ("xor ax,ax")
        END IF
        PutLine ("mov ds:[%00],ax")
        lastivar1$ = "0000"
       ELSE
        PutLine ("mov word ptr ds:[%00],*02")
       END IF
      CASE IntDoubleWord%
       IF CVAL(bp$(2)) = 0 THEN
        IF Processor% >= 386 THEN
         IF lastivar2$ <> "00000000" THEN
          PutLine ("xor eax,eax")
         END IF
         lastivar1$ = "00000000"
         PutLine ("mov dword ptr ds:[%00],eax")
        ELSE
         IF lastivar2$ <> "0000" THEN
          PutLine ("xor ax,ax")
         END IF
         lastivar1$ = "0000"
         PutLine ("mov ds:[%00],ax;mov ds:[%00+2],ax")
        END IF
       ELSE
        IF Processor% >= 386 THEN
         PutLine ("mov dword ptr ds:[%00]," + Hex8$(CVAL(bp$(2))))
        ELSE
         Split4 (bp$(2))
         PutLine ("mov word ptr ds:[%00]," + Hex4$(vl&) + ";mov word ptr ds:[%00+2]," + Hex4$(vh&))
        END IF
       END IF
      END SELECT
    ELSE
      SELECT CASE bpt%(0)
       CASE IntByte%
        PutLine ("mov byte ptr ds:[%00]," + numl$(CVAL(bp$(2))))
       CASE IntWord%
        PutLine ("mov word ptr ds:[%00]," + numl$(CVAL(bp$(2))))
       CASE IntDoubleWord%
        IF Processor% >= 386 THEN
         PutLine ("mov dword ptr ds:[%00]," + Hex8$(CVAL(bp$(2))))
        ELSE
         Split4 (bp$(2))
         PutLine ("mov word ptr ds:[%00]," + Hex4$(vl&) + ";mov word ptr ds:[%00+2]," + Hex4$(vh&))
        END IF
      END SELECT
     END IF
    SetBPreg ("bp")
    EXIT SUB
   END IF
  END IF

 END IF
 
  SetBPreg ("bx")
  SELECT CASE bpt%(2)
   CASE IntByte%
    PutLine ("mov al,byte ptr ds:[%02];cbw")
    IF hiprecision% = IntDoubleWord% THEN PutLine ("cwd")
   CASE IntWord%
    IF lastivar2$ <> bp$(2) THEN PutLine ("mov ax,ds:[%02]"): lastivar2$ = bp$(2)
    IF hiprecision% = IntDoubleWord% THEN PutLine ("cwd")
   CASE IntDoubleWord%
    IF lastivar2$ <> bp$(2) THEN PutLine ("mov ax,ds:[%02];mov dx,ds:[%02+2]"): lastivar2$ = bp$(2)

   CASE IntConst%
    Split4 (bp$(2))
    IF vl& = 0 THEN
     PutLine ("xor ax,ax")
    ELSE
     PutLine ("mov ax," + Hex4$(vl&))
    END IF
    IF precision% = IntDoubleWord THEN
     IF vh& = 0 THEN
      PutLine ("xor dx,dx")
     ELSE
      PutLine ("mov dx," + Hex4$(vh&))
     END IF
    END IF
 
   CASE StrConst%
    IF pushfirst% = TRUE THEN
     IF lastsvar2$ = bp$(0) THEN
      PutLine ("push di")
     ELSE
      PutLine ("push word ptr ds:[%00]")
     END IF
     mempop% = mempop% + 1
    END IF
    PutLine ("xchg si,di;mov si,offset %" + numi0$(2) + ";call _str_cs_ds;xchg si,di")
 
   CASE StringType%
    IF bp$(0) = bp$(2) THEN
     IF lastsvar2$ <> bp$(2) THEN PutLine ("mov di,ds:[%00]")
     ' DI is otherwise already set from last line
     IF pushfirst% = TRUE THEN PutLine ("push di"): mempop% = mempop% + 1
    ELSE
     IF pushfirst% = TRUE THEN
      IF lastsvar2$ = bp$(0) THEN
       PutLine ("push di")
      ELSE
       PutLine ("push word ptr ds:[%00]")
      END IF
      mempop% = mempop% + 1
     END IF
    
     IF lastsvar2$ = bp$(2) THEN
      PutLine ("mov si,di")
     ELSE
      PutLine ("mov si,ds:[%02]")
     END IF
     PutLine ("call _str_copy")
    END IF

   CASE NumFunc%
     IF pushfirst% = TRUE THEN
      IF lastsvar2$ = bp$(0) THEN
       PutLine ("push di")
      ELSE
       PutLine ("push word ptr ds:[%00]")
      END IF
      mempop% = mempop% + 1
     END IF
    CALL EvaluateNum(2, precision%, "ax", "dx")

   CASE StrFunc%
     IF pushfirst% = TRUE THEN
      IF lastsvar2$ = bp$(0) THEN
       PutLine ("push di")
      ELSE
       PutLine ("push word ptr ds:[%00]")
      END IF
      mempop% = mempop% + 1
     END IF
    CALL EvaluateStr(2)

  END SELECT
  SetBPreg ("bp")

IF bpp% > 2 THEN
CALL ProcessLineBPP2(z%)
 END IF

 SetBPreg ("bx")
 SELECT CASE bpt%(0)
  CASE IntByte%
   PutLine ("mov byte ptr ds:[%00],al")
   lastivar1$ = ""
  CASE IntWord%
   PutLine ("mov ds:[%00],ax")
   lastivar1$ = bp$(0)
  CASE IntDoubleWord%
   PutLine ("mov ds:[%00],ax;mov ds:[%00+2],dx")
   lastivar1$ = bp$(0)
  CASE StringType%
   PutLine ("mov ds:[%00],di")
   lastsvar1$ = bp$(0)
   IF mempop% > 0 THEN
    FOR i% = 1 TO mempop%
     PutLine ("pop bx;call _mem_free")
    NEXT
   END IF
  CASE Pointer%
   t% = PointerType%(0)
   SELECT CASE t%
    CASE IntWord%
     PutLine ("mov ds:[%00],ax")
    CASE IntDoubleWord%
     PutLine ("mov ds:[%00],ax;mov ds:[%00],dx")
   END SELECT
'  CASE PointerRef%
'   SELECT CASE PointerSize%(0)
'    CASE IntByte%
'     PutLine ("mov byte ptr ds:[%00],al")
'    CASE IntWord%
'     PutLine ("mov ds:[%00],ax")
'    CASE IntDoubleWord%
'     PutLine ("mov ds:[%00],ax;mov ds:[%00+2],dx")
'   END SELECT
 
  CASE ELSE
   CALL ErrTypeMismatch(0)
 END SELECT
END IF
END IF

IF bpt%(0) = Label% AND bpp% = 0 THEN
 fb$(FMcode%) = fb$(FMcode%) + "__" + bp$(0) + CHR$(13) + CHR$(10)
END IF

SetBPreg ("bp")
END SUB

SUB ProcessLineBPP2 (z%)
 FOR z% = 3 TO bpp%
  SELECT CASE bpt%(z%)

   CASE NumFunc%
    CALL EvaluateNum(z%, precision%, "bx", "cx")

   CASE TermType%
    SELECT CASE bp$(z%)
     CASE "+"
      z% = z% + 1
      SELECT CASE bpt%(z%)
       CASE IntConst%
        IF (bp$(z%) = "1" OR bp$(z%) = "2") AND precision% <> IntDoubleWord% THEN
         IF SwSpeed% = TRUE THEN
          IF bp$(z%) = "1" THEN
           PutLine ("inc ax")
          ELSE
           PutLine ("add ax,2")
          END IF
         ELSE
          PutLine ("inc ax")
          IF bp$(z%) = "2" THEN PutLine ("inc ax")
         END IF
        ELSE
         PutLine ("add ax,*" + numi0$(z%))
        END IF
        IF precision% = IntDoubleWord% THEN PutLine ("adc dx,0")
        ErrOverflow
       CASE IntByte%
        PutLine ("add al,ds:[%" + numi0$(z%) + "];adc ah,0")
        IF precision% = IntDoubleWord% THEN PutLine ("adc dx,0")
        ErrOverflow
       CASE IntWord%
        PutLine ("add ax,ds:[%" + numi0$(z%) + "]")
        IF precision% = IntDoubleWord% THEN PutLine ("adc dx,0")
        ErrOverflow
       CASE IntDoubleWord%
        PutLine ("add ax,ds:[%" + numi0$(z%) + "]")
        PutLine ("adc dx,ds:[%" + numi0$(z%) + "+2]")
        ErrOverflow
'       CASE StrConst%
'        PutLine ("mov si,offset %" + numi0$(z%) + ";call _str_cs_ds")
'        PutLine ("mov bx,si;call _str_conc")
'        PutLine ("call _mem_free")
'       CASE StringType%
'        PutLine ("mov si,ds:[%" + numi0$(z%) + "]")
'        IF z% = 4 AND bp$(0) = bp$(2) THEN
'         ' SI is already pointing to string plus it doesn't need to be freed
'         PutLine ("call _str_conc")
'        ELSE
'         PutLine ("push di;call _str_conc;pop bx;call _mem_free")
'        END IF

       CASE NumFunc%
        CALL EvaluateNum(z%, precision%, "bx", "cx")
        PutLine ("add ax,bx")
        IF hiprecision% = IntDoubleWord% THEN PutLine ("adc dx,cx")
        ErrOverflow
     
'       CASE StrFunc%
'        PutLine ("push di")
'        CALL EvaluateStr(z%)
'        PutLine ("mov si,di;pop di;push si;call _str_conc")
'        PutLine ("pop bx;call _mem_free")

      END SELECT
   
     CASE "-"
      SELECT CASE bpt%(z% + 1)
       CASE IntConst%
        IF (bp$(z% + 1) = "1" OR bp$(z% + 1) = "2") AND precision% <> IntDoubleWord% THEN
         IF SwSpeed% = TRUE THEN
          IF bp$(z% + 1) = "1" THEN
           PutLine ("dec ax")
          ELSE
           PutLine ("sub ax,2")
          END IF
         ELSE
          PutLine ("dec ax")
          IF bp$(z% + 1) = "2" THEN PutLine ("dec ax")
         END IF
        ELSE
         PutLine ("sub ax,*" + numi0$(z% + 1))
        END IF
        IF precision% = IntDoubleWord% THEN PutLine ("sbb dx,0")
       CASE IntByte%
        PutLine ("sub al,ds:[%" + numi0$(z% + 1) + "];sbb ah,0")
        IF precision% = IntDoubleWord% THEN PutLine ("sbb dx,0")
       CASE IntWord%
        PutLine ("sub ax,ds:[%" + numi0$(z% + 1) + "]")
        IF precision% = IntDoubleWord% THEN PutLine ("sbb dx,0")
       CASE IntDoubleWord
        PutLine ("sub ax,ds:[%" + numi0$(z% + 1) + "];sbb dx,ds:[%" + numi0$(z% + 1) + "+2]")
       CASE NumFunc%
        CALL EvaluateNum(z% + 1, precision%, "bx", "cx")
        PutLine ("sub ax,bx")
        IF precision% = IntDoubleWord% THEN PutLine ("sbb dx,cx")
    
      END SELECT
      ErrOverflow
      z% = z% + 1

     CASE "*"
      SELECT CASE bpt%(z% + 1)
       CASE IntConst%
        PutLine ("mov bx,*" + numi0$(z% + 1))
       CASE IntByte%
        PutLine ("mov bl,ds:[%" + numi0$(z% + 1) + "];xor bh,bh")
       CASE IntWord%
        PutLine ("mov bx,ds:[%" + numi0$(z% + 1) + "]")
       CASE IntDoubleWord%
        PutLine ("mov word ptr ds:[t1],ax;mov word ptr ds:[t1+2],dx")
        PutLine ("mov si,offset t1;mov di,offset %" + numi0$(z% + 1) + ";call _mul32")
       CASE NumFunc%
        CALL EvaluateNum(z%, precision%, "bx", "cx")
      END SELECT
      IF bpt%(z% + 1) <> IntDoubleWord% THEN PutLine ("imul bx")
      z% = z% + 1

     CASE "/"
      SELECT CASE bpt%(z% + 1)
       CASE IntConst%
        PutLine ("mov bx,*" + numi0$(z% + 1))
       CASE IntByte%
        PutLine ("mov bl,ds:[%" + numi0$(z% + 1) + "];xor bh,bh")
       CASE IntWord%
        PutLine ("mov bx,ds:[%" + numi0$(z% + 1) + "]")
       CASE IntDoubleWord%
'        PutLine ("mov word ptr ds:[t1],ax;mov word ptr ds:[t1+2],dx")
'        PutLine ("mov si,offset t1;mov di,offset %" + numi0$(z% + 1) + ";call _div32")
        PutLine ("push word ptr ds:[%" + numi0$(z% + 1) + "+2];push word ptr ds:[%" + numi0$(z% + 1) + "]")
        PutLine ("push dx;push ax;call _div32")

       CASE NumFunc%
        CALL EvaluateNum(z%, precision%, "bx", "cx")
      END SELECT
     
      IF bpt%(z% + 1) <> IntDoubleWord% THEN
       IF hiprecision% <> IntDoubleWord% THEN PutLine ("cwd")
       PutLine ("idiv bx;sub bx,dx;cmp dx,bx;sbb ax,-1")
       IF hiprecision% = IntDoubleWord% THEN PutLine ("xor dx,dx")
      END IF
      z% = z% + 1
   
     CASE "\"
      SELECT CASE bpt%(z% + 1)
       CASE IntConst%
        PutLine ("mov bx,*" + numi0$(z% + 1))
       CASE IntByte%
        PutLine ("mov bl,ds:[%" + numi0$(z% + 1) + "];xor bh,bh")
       CASE IntWord%
        PutLine ("mov bx,ds:[%" + numi0$(z% + 1) + "]")
       CASE IntDoubleWord%
'        PutLine ("mov word ptr ds:[t1],ax;mov word ptr ds:[t1+2],dx")
'        PutLine ("mov si,offset t1;mov di,offset %" + numi0$(z% + 1) + ";call _div32")
        PutLine ("push word ptr ds:[%" + numi0$(z% + 1) + "+2];push word ptr ds:[%" + numi0$(z% + 1) + "]")
        PutLine ("push dx;push ax;call _div32")

       CASE NumFunc%
        CALL EvaluateNum(z%, precision%, "bx", "cx")
      END SELECT
      IF bpt%(z% + 1) <> IntDoubleWord% THEN
       IF hiprecision% <> IntDoubleWord% THEN PutLine ("cwd")
       PutLine ("idiv bx")
       IF hiprecision% = IntDoubleWord% THEN PutLine ("xor dx,dx")
      END IF
      z% = z% + 1

    END SELECT

  END SELECT
 NEXT

END SUB

SUB PutHandle (z%)
SELECT CASE bpt%(z%)
 CASE IntConst%
  IF VAL(bp$(z%)) > 4 THEN
   CALL ReportErr("^ Integer variable or const 1-4 required for handle", bpsp%(z%), TRUE)
  ELSE
   PutLine ("mov bx,*" + numi0$(z%))
  END IF
 CASE IntByte%
  PutLine ("mov bl,ds:[%" + numi0$(z%) + "];xor bh,bh")
 CASE IntWord%
  PutLine ("mov bx,ds:[%" + numi0$(z%) + "]")
 CASE ELSE
  CALL ErrTypeMismatch(z%)
END SELECT
END SUB

SUB SetBPreg (bpr$)
BPval$ = ""
bpreg$ = bpr$
END SUB

SUB Split4 (s$)
v& = CVAL(s$)
vl& = v& AND 65535
vh& = SHR32&(v&, 16)
IF vh& = 0 AND SGN(v&) = -1 THEN vh& = -1
END SUB

