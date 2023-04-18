DECLARE SUB NewSeg (s%, handle%)
DECLARE SUB WriteStartup ()
DECLARE SUB AddDataRef (v$, s&, handle%)

DECLARE SUB WriteStack ()
DECLARE FUNCTION FileReplace$ (parm$, Filename$)
DECLARE SUB Read386 ()
DECLARE SUB WriteLib ()
DECLARE SUB WriteOut (s$)
DECLARE SUB Pass2 ()
DECLARE SUB Flushfile (h%)
DECLARE SUB PutLine (l$)
DECLARE SUB ReportErr (E$, indent%, showline%)
DECLARE SUB WriteFile (l$, h%)

DECLARE FUNCTION BunSize% (z%)

DECLARE FUNCTION Switch% (l$, s$)
DECLARE FUNCTION Lexpand$ (l$)

DECLARE FUNCTION numi$ (tmp%)
DECLARE FUNCTION MakeVar$ (v$, tt%)
DECLARE FUNCTION numl$ (tmp&)
DECLARE FUNCTION unique% (u$)

DECLARE FUNCTION Hex2$ (l%)
DECLARE FUNCTION Hex4$ (l&)

'$INCLUDE: 'mr.inc'
TYPE PtrType
 LibName AS STRING * 30
 Posi AS LONG
 Length AS INTEGER
END TYPE

'$DYNAMIC

ON ERROR GOTO errorhandler

'$INCLUDE: 'mrk.inc'

'startmem& = FRE(-1)
starttime! = TIMER

SysPath$ = SPACE$(64)          ' VERY important! This must have something in it
CALL MyPath(SysPath$)
SysPath$ = RTRIM$(SysPath$)          ' trim back to normal size
WHILE RIGHT$(SysPath$, 1) <> "\" AND SysPath$ <> ""
 SysPath$ = LEFT$(SysPath$, LEN(SysPath$) - 1)
WEND

SysPath$ = UCASE$(SysPath$)
IF SysPath$ = "C:\QB\" THEN SysPath$ = "C:\MR\"
IF SysPath$ = "C:\VBDOS\" THEN SysPath$ = "C:\MR\"

LOCATE , , 1
COLOR 7
PRINT "MoonRock compiler v" + Ver$ + " [DOS]; Copyright (c) 1994-1996 by Rowan Crowe."
COLOR 10
PRINT "This compiler has been customised by <insert_your_name_here>"
COLOR 12
COLOR 7

StrTable$ = " "
LabelTable$ = " "
IntTable$ = " "
LibTable$ = " "
LibVector$ = " "
PtrTable$ = " "

Def$ = " "
DataRefList$ = " "
IntArrayTable$ = " "
outstream$ = "_tty_str_dos"
errhandler$ = "_err_msg"
SwStr$ = " C M "
f386$ = " "
FarDimList$ = "mr@FarDimList: dw "
DimType$ = " "
ConstTable$ = " "
CommonList$ = " mr@null$ "
BundlePtr% = -1
Language% = MR%
ExternUsed% = FALSE

t$ = UCASE$(ENVIRON$("MRCSWITCH"))
IF t$ <> "" THEN PRINT "MRC environment variable: " + t$

tpath$ = UCASE$(ENVIRON$("$PTH"))
IF tpath$ <> "" AND RIGHT$(tpath$, 1) <> "\" THEN tpath$ = tpath$ + "\"

cmdline$ = UCASE$(LTRIM$(RTRIM$(COMMAND$))) + t$
WriteSource% = TRUE

dummy% = Switch%(cmdline$, "/-M")

SwMain% = Switch%(cmdline$, "/IM")
SwPartial% = Switch%(cmdline$, "/I")
IF SwMain% = TRUE THEN SwPartial% = TRUE

'IF Switch%(cmdline$, "/-S") = TRUE THEN WriteSource% = FALSE
'IF Switch%(cmdline$, "/S") = TRUE THEN WriteSource% = TRUE

SwSpeed% = Switch%(cmdline$, "/S")

SwDOSX% = Switch%(cmdline$, "/X")

SwOpt% = TRUE
IF Switch%(cmdline$, "/-O") = TRUE THEN SwOpt% = FALSE

EXE% = FALSE
IF Switch%(cmdline$, "/E") = TRUE THEN EXE% = TRUE
IF EXE% = TRUE THEN Def$ = Def$ + "__EXE "

Sw186% = Switch%(cmdline$, "/1")
'SwFarCall% = Switch%(cmdline$, "/F")
SwFarCall% = FALSE
SwTrace% = Switch%(cmdline$, "/DT")
SwSingleStep% = Switch%(cmdline$, "/DS")
IF Switch%(cmdline$, "/D") = TRUE THEN SwDebug% = TRUE
IF SwTrace% = TRUE THEN SwDebug% = TRUE
IF SwSingleStep% = TRUE THEN SwDebug% = TRUE

IF SwDebug% = TRUE THEN Def$ = Def$ + "__DEBUG "

Sw386% = FALSE
IF Switch%(cmdline$, "/-3") = TRUE THEN Sw386% = FALSE
IF Switch%(cmdline$, "/3") = TRUE THEN Sw386% = TRUE

IF Sw386% = TRUE THEN Sw186% = TRUE: SwStr$ = SwStr$ + " 1 "

SwCritical% = TRUE
IF Switch%(cmdline$, "/-C") = TRUE THEN SwCritical% = FALSE
IF Switch%(cmdline$, "/C") = TRUE THEN SwCritical% = TRUE

SwResume% = Switch%(cmdline$, "/R")
IF SwResume% = TRUE THEN Def$ = Def$ + "__RESUME "

SwDep% = FALSE
IF Switch%(cmdline$, "/L") = TRUE THEN SwDep% = TRUE: SwCritical% = FALSE: EXE% = TRUE
IF Switch%(cmdline$, "/-L") = TRUE THEN SwDep% = FALSE
IF SwDep% = TRUE THEN Def$ = Def$ + "__DEP "

SwDPMI% = Switch%(cmdline$, "/P")
IF SwDPMI% = TRUE THEN
 LibTable$ = LibTable$ + "_enter_pmode "
 SwCritical% = FALSE
 Sw386% = TRUE
END IF
IF SwDPMI% = TRUE THEN Def$ = Def$ + "__DPMI "

IF SwDOSX% = TRUE THEN
 EXE% = TRUE
 SwCritical% = FALSE
 SwStr$ = SwStr$ + " E "
END IF

IF SwCritical% = TRUE THEN
 LibTable$ = LibTable$ + "_critical "
ELSE
 ptr% = INSTR(SwStr$, " C ")
 IF ptr% <> 0 THEN MID$(SwStr$, ptr%) = "   "
END IF
IF SwDebug% = TRUE THEN LibTable$ = LibTable$ + "_err_overflow _err_div0 "

Processor% = 86
IF Sw186% = TRUE THEN Processor% = 186
IF Sw386% = TRUE THEN Processor% = 386: Sw186% = TRUE: SwStr$ = SwStr$ + " 1 "

SELECT CASE Processor%
 CASE 86
  Def$ = Def$ + "__8086 "
 CASE 186
  Def$ = Def$ + "__186 "
 CASE 386
  Def$ = Def$ + "__386 "
 CASE ELSE
  PRINT
  PRINT "Internal error: Processor=" + numi$(Processor%)
END SELECT

cmdline$ = " " + cmdline$ + " "
ptr% = INSTR(cmdline$, "!")
WHILE ptr% <> 0
 ptr2% = INSTR(ptr%, cmdline$, " ")
 Def$ = Def$ + UCASE$(MID$(cmdline$, ptr% + 1, ptr2% - ptr% - 1)) + " "
 MID$(cmdline$, ptr%) = SPACE$(ptr2% - ptr%)
 ptr% = INSTR(cmdline$, "!")
WEND

infile$ = LTRIM$(RTRIM$(cmdline$))
IF infile$ = "" THEN
 PRINT
 PRINT "  Usage:"
 PRINT "    MRC  <source filename>  [switches]"
 PRINT
 PRINT "  Switch options are:"
 PRINT "    /S   Optimize for speed              /R   Set DOSERR instead of aborting"
 PRINT "    /1   186/286+ code generation        /3   386+ code generation"
 PRINT "    /E   EXE compilation                 /L   Language dependent OBJ"
 PRINT "    /I   Incremental compile             /IM  Incremental compile: MAIN"
 PRINT "    /P   DPMI protected mode executable  /D   Runtime debugging code         "
 PRINT "    /DT  Trace source line numbers       /DS  Single step each line (INT 3)"
 PRINT
 PRINT "    /-C  Disable critical error handler  /-M  Exclude text error msg list    "
 PRINT "    /-O  Disable register optimisations"
 PRINT

 COLOR 12
 PRINT "THIS IS A PUBLIC DOMAIN SOURCE CODE RELEASE.  THE AUTHOR IMPLIES NO"
 PRINT "      WARRANTY WHATSOEVER ON MODIFICATIONS DONE BY OTHERS!"
 PRINT
 COLOR 7

 PRINT "Rowan Crowe, 3:635/727@fidonet      rowan@jelly.freeway.DIALix.oz.au"
 PRINT "Jelly-Bean Software Development, Melbourne AUSTRALIA."
 END
END IF

DIM SHARED sc$(500)

DIM SHARED Preserve$(500)

DIM SHARED bp$(70)
DIM SHARED bpt%(70), bpsp%(70), bpar$(70), bpart%(70), bpterm$(70)
DIM SHARED bppr%(70)
DIM SHARED fb$(10)
DIM SHARED fornextstack%(20), fornextend$(20), fornextvar$(20), fornextt%(20)
DIM SHARED WhileWendStack%(20)
DIM SHARED CaseListStack%(20), CaseListInCnt%(20), CaseListPrecision%(20)
DIM SHARED CaseListVar$(20), CaseListArrVar$(20), CaseListArrType%(20)
DIM SHARED CaseListElse%(20), CaseListReload%(20)
DIM SHARED IfThenStack%(20), ElsePtr%(20)
DIM SHARED NestStack%(50)
DIM SHARED Sub$(100), SubUsed%(100)
DIM SHARED Bundle$(10), BundleSize%(10), BundleDef$(10)
DIM SHARED IncludeName$(5), IncludePosi&(5), IncludeLine%(5)
DIM SHARED TypeName$(100), TypeParm$(100)

DIM SHARED LastSeg%(10)   ' not shared between modules

IF INSTR(infile$, ".") = 0 THEN infile$ = infile$ + ".MOO"
t$ = LEFT$(infile$, INSTR(infile$, "."))
outfile$ = t$ + "ASM"
errfile$ = t$ + "ERR"
objfile$ = t$ + "OBJ"
IF SwMain% = TRUE THEN
 FMbuild% = FREEFILE
 OPEN t$ + "B" FOR BINARY AS #FMbuild%
 IF LOF(1) = 0 THEN
  buildcount& = 0
 ELSE
  GET #FMbuild%, , buildcount&
  buildcount& = buildcount& + 1
  SEEK #FMbuild%, 1
 END IF
 PUT #FMbuild%, , buildcount&
 CLOSE #FMbuild%
 ConstTable$ = ConstTable$ + "%__BUILD__=" + numl$(buildcount&) + " "
END IF

IF SwPartial% = TRUE AND SwMain% = FALSE THEN libfile$ = t$ + "L"

IncludeName$(0) = infile$

depname$ = LEFT$(infile$, INSTR(infile$, ".") - 1)
IF INSTR(depname$, "\") <> 0 THEN
 ptr% = LEN(depname$)
 DO
 ptr% = ptr% - 1
 LOOP UNTIL MID$(depname$, ptr%, 1) = "\"
 depname$ = MID$(depname$, ptr% + 1)
END IF

FOR i% = 1 TO LEN(depname$)
 IF INSTR("-+=().", MID$(depname$, i%, 1)) <> 0 THEN MID$(depname$, i%, 1) = "_"
NEXT

bad% = FALSE

IF FFexist%(SysPath$ + "moonrock.alb") = FALSE THEN
  PRINT "FATAL: MoonRock library file '" + SysPath$ + "MOONROCK.ALB' not found"
  bad% = TRUE
END IF
IF FFexist%(SysPath$ + "moonrock.ptr") = FALSE THEN
  PRINT "FATAL: MoonRock library file '" + SysPath$ + "MOONROCK.PTR' not found"
  bad% = TRUE
END IF

IF FFexist%(infile$) = FALSE THEN
  PRINT "FATAL: Input file '" + infile$ + "' not found."
  bad% = TRUE
END IF

IF bad% = TRUE THEN END

FMin% = FREEFILE
OPEN infile$ FOR INPUT AS #FMin%
'm& = SETMEM(-(LOF(FMin%) + 256))
'l% = (LOF(FMin%) \ 16) + 2
'a% = SourceLoad%(l%, FILEATTR(FMin%, 2))
'IF a% <> 0 THEN
' PRINT "Error loading source. Dos reported error code #" + numi$(a%)
' END
'END IF
'CLOSE #FMin%

FMout% = FREEFILE
OPEN outfile$ FOR OUTPUT AS #FMout%
CLOSE #FMout%
KILL outfile$

FMsc% = FREEFILE
OPEN tpath$ + "STRCONST.$$$" FOR OUTPUT AS #FMsc%
CLOSE #FMsc%
OPEN tpath$ + "STRCONST.$$$" FOR BINARY AS #FMsc%

FMvar% = FREEFILE
OPEN tpath$ + "VARIABLE.$$$" FOR OUTPUT AS #FMvar%
CLOSE #FMvar%
OPEN tpath$ + "VARIABLE.$$$" FOR BINARY AS #FMvar%
CALL WriteFile("; " + STRING$(60, "-"), FMvar%)
'CALL WriteFile("mr@freestart equ " + Hex4$(DataPtr&), FMvar%): DataPtr& = DataPtr& + 2
FMcode% = FREEFILE
OPEN tpath$ + "code.$$$" FOR OUTPUT AS #FMcode%
CLOSE #FMcode%
OPEN tpath$ + "code.$$$" FOR BINARY AS #FMcode%

IF EXE% = TRUE THEN
 CALL WriteFile("_text ends", FMcode%)
ELSE
 CALL WriteFile("code ends", FMcode%)
END IF

FMstack% = FREEFILE
OPEN tpath$ + "stack.$$$" FOR OUTPUT AS #FMstack%
IF SwResume% = FALSE THEN PRINT #FMstack%, "mr@ds dw 1 dup (?)"

FMerr% = FREEFILE
OPEN errfile$ FOR BINARY AS #FMerr%
CLOSE #FMerr%
KILL errfile$

defaultstacksize% = 1024
StrSegSize& = 32767

'PRINT "Compiling " + infile$ + " -> " + outfile$

stacksize% = defaultstacksize%

'CALL NewSeg(CodeSeg%, FMout%)
'CALL NewSeg(DataSeg%, FMout%)
DataPtr& = 2
IF SwPartial% = TRUE THEN
' CALL NewSeg(DataSeg%, FMvar%)
 IF SwMain% = TRUE THEN
'  CALL WriteFile("ORG 0", FMvar%)
  CALL WriteFile("dw 1 dup (?)", FMvar%)
  CALL WriteFile("public t1,t2", FMvar%)
  CALL WriteFile("t1 dw 1 dup (?)", FMvar%): DataPtr& = DataPtr& + 2
  CALL WriteFile("t2 dw 1 dup (?)", FMvar%): DataPtr& = DataPtr& + 2
 ELSE
  CALL WriteFile("extrn t1:WORD", FMvar%)
  CALL WriteFile("extrn t2:WORD", FMvar%)
 END IF
' CALL NewSeg(CodeSeg%, FMvar%)
ELSE
 CALL WriteFile("t1	equ " + Hex4$(DataPtr&), FMvar%): DataPtr& = DataPtr& + 2
 CALL WriteFile("t2	equ " + Hex4$(DataPtr&), FMvar%): DataPtr& = DataPtr& + 2
END IF

 IF EXE% = TRUE THEN
  IF SwPartial% = FALSE THEN
   CALL WriteFile("mr@psp equ " + Hex4$(DataPtr&), FMvar%): DataPtr& = DataPtr& + 2
  ELSE
   IF SwMain% = FALSE THEN
    CALL WriteFile("EXTRN mr@psp", FMvar%)
   ELSE
    CALL WriteFile("public mr@psp", FMvar%)
    CALL WriteFile("mr@psp dw 1 dup (?)", FMvar%)
   END IF
  END IF
 END IF

 'CALL WriteOut("")
'CALL NewSeg(CodeSeg%, FMout%)

CALL Pass2

IF errcount% > 0 THEN
 PRINT
 PLAY "l32cn0cn0c"
 PRINT numi$(errcount%) + " severe error(s), output written to " + errfile$
ELSE

 REDIM SHARED sc$(0), bp$(0), bpt%(0), bpsp%(0), bpar$(0), bpart%(0), bpterm$(0)
 REDIM SHARED fornextstack%(0), fornextend$(0), fornextvar$(0), fornextt%(0)
 REDIM SHARED WhileWendStack%(0), CaseListStack%(0), CaseListInCnt%(0), CaseListPrecision%(0)
 REDIM SHARED CaseListVar$(0), CaseListArrVar$(0), CaseListArrType%(0)
 REDIM SHARED CaseListElse%(0), CaseListReload%(0)
 REDIM SHARED IfThenStack%(0), ElsePtr%(0)
 REDIM SHARED NestStack%(0)
 REDIM SHARED IncludeName$(0), IncludePosi&(0), IncludeLine%(0)
 ConstTable$ = ""
 dummy& = FRE("")

 IF SwPartial% = FALSE OR SwMain% = TRUE THEN
  CALL WriteFile(linefeed$, FMcode%)
  IF SwMain% = TRUE THEN CALL WriteFile("public _exit", FMcode%)
  CALL WriteFile("_exit:", FMcode%)
  IF SwCritical% = TRUE OR SwDebug% = TRUE OR atexit% = TRUE THEN PutLine ("push ax")
 
  IF atexit% = TRUE THEN
   CALL AddDataRef("mr@atexit", 2, FMvar%)
   CALL PutLine("cmp word ptr ds:[mr@atexit],0;jnz LL" + numi$(LocVarCount% + 3) + ";mov word ptr ds:[mr@atexit],1")
   CALL PutLine("xor di,di")
   LocVarCount% = LocVarCount% + 1
   CALL PutLine("LL" + numi$(LocVarCount%) + ":;mov ax,word ptr ds:[di+mr@atexittab];test ax,ax;jz LL" + numi$(LocVarCount% + 1))
   CALL PutLine("push di;call	ax;pop di;add di,2;jmp short LL" + numi$(LocVarCount%))
   LocVarCount% = LocVarCount% + 1
   CALL PutLine("LL" + numi$(LocVarCount%) + ":")
  END IF

  PutLine ("call	mr@cleanup")

  IF PtrTable$ <> " " THEN PutLine ("call _chknullptr")

  CALL WriteFile("_exit2:", FMcode%)
  IF SwCritical% = TRUE THEN
   CALL PutLine("mov ax,2524h;lds dx,dword ptr cs:[old_int24];int 21h")
  END IF
  IF SwDebug% = TRUE THEN
   CALL PutLine("mov ax,2500h;lds dx,dword ptr ss:[old_int00];int 21h")
   CALL PutLine("mov	ax,2504h;lds dx,dword ptr ss:[old_int04];int 21h")
   IF DimType$ <> "" THEN CALL PutLine("mov ax,2505h;lds dx,dword ptr ss:[old_int05];int 21h")
  END IF
  IF SwCritical% = TRUE OR SwDebug% = TRUE OR atexit% = TRUE THEN PutLine ("pop ax")
  CALL PutLine("mov dx,-8531;mov ah,4ch;int 21h")
 
  IF atexit% = TRUE THEN
   LocVarCount% = LocVarCount% + 1
   CALL PutLine("LL" + numi$(LocVarCount%) + ":;call _cprint;db 13,10,'Program error: exception occurred in _atexit',0")
   CALL PutLine("jmp short LL" + numi$(LocVarCount% - 1))
  END IF
 END IF


 FMout% = FREEFILE
 OPEN outfile$ FOR OUTPUT AS #FMout%
 CLOSE #FMout%
 OPEN outfile$ FOR BINARY AS #FMout%

 CALL WriteFile("; Generated by MoonRock " + Ver$ + " from sourcecode file " + infile$, FMout%)
 d$ = DATE$
 mm% = VAL(d$)
 CALL WriteFile("; Compile time was " + TIME$ + " on " + MID$(d$, 4, 2) + "-" + MID$("  JanFebMarAprMayJunJulAugSepOctNovDec", mm% * 3, 3) + "-" + RIGHT$(d$, 4) + linefeed$, FMout%)
 IF LTRIM$(Def$) <> "" THEN CALL WriteOut("; * Conditional directives: " + LTRIM$(RTRIM$(Def$)))
' IF WriteSource% = TRUE THEN CALL WriteFile("; * Original source included as comments.", FMout%)
 IF SwSpeed% = TRUE THEN
  CALL WriteOut("; * Compiled for maximum speed.")
 ELSE
  CALL WriteOut("; * Compiled for smallest size.")
 END IF
 IF SwDPMI% = TRUE THEN CALL WriteOut("; * DPMI dependent code.")
 IF SwDebug% = TRUE THEN CALL WriteOut("; * Runtime error checking will be performed.")
 IF SwTrace% = TRUE THEN CALL WriteOut("; * Source line numbers will be shown during execution.")
 IF SwSingleStep% = TRUE THEN CALL WriteOut("; * INT 3 will be executed before each source line.")
 SELECT CASE Processor%
  CASE 86
   CALL WriteOut("; * Lowest target processor: 8086")
  CASE 186
   CALL WriteOut("; * Lowest target processor: 186/286")
  CASE 386
   CALL WriteOut("; * Lowest target processor: 386")
 END SELECT

 CALL NewSeg(CodeSeg%, FMout%)
 IF EXE% = TRUE THEN CALL NewSeg(StrConstSeg%, FMout%)
 CALL NewSeg(DataSeg%, FMout%)
 CALL NewSeg(CodeSeg%, FMout%)
 IF StrSegSize& / 2 <> StrSegSize& \ 2 THEN StrSegSize& = StrSegSize& + 1
 IF StrSegSize& > 65534 THEN StrSegSize& = 65534
 CALL WriteFile("$strsegsize equ 0" + HEX$(StrSegSize&) + "h", FMout%)
 IF EXE% = FALSE AND (SwPartial% = FALSE OR SwMain% = TRUE) THEN CALL WriteOut("org 100h")

 IF Processor% = 386 THEN CALL WriteOut("p386")
 IF Processor% = 186 THEN CALL WriteOut("p186")

 IF SwPartial% = TRUE AND SwMain% = FALSE THEN
  CALL WriteOut("extrn _exit:NEAR")
 END IF
 IF SwPartial% = TRUE THEN
  CALL WriteOut("extrn $StartOfDynamic:ABS")
  CALL WriteOut("extrn end_of_code:ABS")
 END IF

 CALL WriteOut("public")
 Flushfile (FMcode%)

 IF SwPartial% = FALSE OR SwMain% = TRUE THEN CALL WriteStartup

 CALL NewSeg(DataSeg%, FMout%)


 Flushfile (FMvar%)
 Flushfile (FMout%)

 SEEK #FMvar%, 1
 l& = LOF(FMvar%)

 DO
  s& = l& - SEEK(FMvar%) + 1
  IF s& > 1024 THEN s& = 1024
  tmp$ = SPACE$(s&)
  GET #FMvar%, , tmp$
  PUT #FMout%, , tmp$
 LOOP UNTIL SEEK(FMvar%) > l&
 tmp$ = ""
 d& = FRE("")
 CLOSE #FMvar%
 OPEN "variable.$$$" FOR OUTPUT AS #FMvar%
 CLOSE #FMvar%
 OPEN "variable.$$$" FOR BINARY AS #FMvar%

 CALL NewSeg(CodeSeg%, FMout%)
 Flushfile (FMout%)
 Flushfile (FMcode%)

 SEEK #FMcode%, 1
 l& = LOF(FMcode%)

 DO
  s& = l& - SEEK(FMcode%) + 1
  IF s& > 1024 THEN s& = 1024
  tmp$ = SPACE$(s&)
  GET #FMcode%, , tmp$
  PUT #FMout%, , tmp$
 LOOP UNTIL SEEK(FMcode%) > l&
 tmp$ = ""
 CLOSE #FMcode%

 IF SwPartial% = FALSE OR SwMain% = TRUE THEN
  CALL WriteFile(linefeed$ + "db 13,10,'Generated by MoonRock compiler v" + Ver$ + "; Portions (C) 1994-1996 by Rowan Crowe',13,10", FMout%)
  CALL WriteOut("")
 END IF
 
  IF BundlePtr% <> -1 THEN
   FOR i% = 0 TO BundlePtr%
    IF BundleDef$(i%) <> "" THEN
     bu$ = UCASE$(LEFT$(Bundle$(i%), LEN(Bundle$(i%)) - 1))
     IF SwPartial% = TRUE AND SwMain% = FALSE THEN
      CALL WriteFile("extrn __" + LCASE$(bu$) + "_2disk:NEAR", FMout%)
     ELSE
      CALL WriteFile("public __" + LCASE$(bu$) + "_2disk", FMout%)
      CALL WriteFile("__" + LCASE$(bu$) + "_2disk:", FMout%)
     END IF
     t$ = BundleDef$(i%)
     DO
      bt$ = LEFT$(t$, 1)         ' type
      bs% = CVI(MID$(t$, 2, 2))  ' offset
      sl% = CVI(MID$(t$, 4, 2))  ' size of string
      IF SwPartial% = FALSE OR SwMain% = TRUE THEN
       CALL WriteOut("	mov	si,offset bu_" + bu$ + " + 0" + HEX$(bs%) + "h")
       CALL WriteOut("	mov	cx," + numi$(sl%))
      END IF
      SELECT CASE bt$
       CASE "P"
        IF SwPartial% = FALSE OR SwMain% = TRUE THEN CALL WriteOut("	call	_mem2disk_pascal")
        IF INSTR(LibTable$, " _mem2disk_pascal ") = 0 THEN LibTable$ = LibTable$ + "_mem2disk_pascal "
       CASE "M"
        IF SwPartial% = FALSE OR SwMain% = TRUE THEN CALL WriteOut("	call	_mem2disk_mr")
        IF INSTR(LibTable$, " _mem2disk_mr ") = 0 THEN LibTable$ = LibTable$ + "_mem2disk_mr "
       CASE "N"
        IF SwPartial% = FALSE OR SwMain% = TRUE THEN CALL WriteOut("	call	_mem2disk_null")
        IF INSTR(LibTable$, " _mem2disk_null ") = 0 THEN LibTable$ = LibTable$ + "_mem2disk_null "
      END SELECT
      t$ = MID$(t$, 6)
     LOOP UNTIL t$ = ""
     IF SwPartial% = FALSE OR SwMain% = TRUE THEN CALL WriteOut("	ret" + linefeed$)
    END IF
    IF BundleDef$(i%) <> "" THEN
     bu$ = UCASE$(LEFT$(Bundle$(i%), LEN(Bundle$(i%)) - 1))
     IF SwPartial% = TRUE AND SwMain% = FALSE THEN
      CALL WriteFile("extrn __" + LCASE$(bu$) + "_2mem:NEAR", FMout%)
     ELSE
      CALL WriteFile("public __" + LCASE$(bu$) + "_2mem", FMout%)
      CALL WriteFile("__" + LCASE$(bu$) + "_2mem:", FMout%)
     END IF
     t$ = BundleDef$(i%)
     DO
      bt$ = LEFT$(t$, 1)         ' type
      bs% = CVI(MID$(t$, 2, 2))  ' offset
      sl% = CVI(MID$(t$, 4, 2))  ' size of string
      IF SwPartial% = FALSE OR SwMain% = TRUE THEN CALL WriteOut("	mov	si,offset bu_" + bu$ + " + 0" + HEX$(bs%) + "h")
      SELECT CASE bt$
       CASE "P"
        IF SwPartial% = FALSE OR SwMain% = TRUE THEN CALL WriteOut("	call	_disk2mem_pascal")
        IF INSTR(LibTable$, " _disk2mem_pascal ") = 0 THEN LibTable$ = LibTable$ + "_disk2mem_pascal "
       CASE "M"
        IF SwPartial% = FALSE OR SwMain% = TRUE THEN CALL WriteOut("	call	_disk2mem_mr")
        IF INSTR(LibTable$, " _disk2mem_mr ") = 0 THEN LibTable$ = LibTable$ + "_disk2mem_mr "
       CASE "N"
        IF SwPartial% = FALSE OR SwMain% = TRUE THEN
         CALL WriteOut("	mov	cx," + numi$(sl%))
         CALL WriteOut("	call	_disk2mem_null")
        END IF
        IF INSTR(LibTable$, " _disk2mem_null ") = 0 THEN LibTable$ = LibTable$ + "_disk2mem_null "
      END SELECT
      t$ = MID$(t$, 6)
     LOOP UNTIL t$ = ""
     IF SwPartial% = FALSE OR SwMain% = TRUE THEN CALL WriteOut("	ret" + linefeed$)
    END IF
    IF BundleDef$(i%) <> "" THEN
     bu$ = UCASE$(LEFT$(Bundle$(i%), LEN(Bundle$(i%)) - 1))
     IF SwPartial% = TRUE AND SwMain% = FALSE THEN
      CALL WriteFile("extrn __" + LCASE$(bu$) + "_release:NEAR", FMout%)
     ELSE
      CALL WriteFile("public __" + LCASE$(bu$) + "_release", FMout%)
      CALL WriteFile("__" + LCASE$(bu$) + "_release:", FMout%)
      CALL WriteOut("	push	bx")
      t$ = BundleDef$(i%)
      DO
       bs% = CVI(MID$(t$, 2, 2))  ' offset
       CALL WriteOut("	mov	bx,word ptr ds:[bu_" + bu$ + " + 0" + HEX$(bs%) + "h]")
       CALL WriteOut("	call	_mem_free")
       t$ = MID$(t$, 6)
      LOOP UNTIL t$ = ""
      IF INSTR(LibTable$, " _mem_free ") = 0 THEN LibTable$ = LibTable$ + "_mem_free "
      CALL WriteOut("	pop	bx")
      CALL WriteOut("	ret" + linefeed$)
     END IF
    END IF

   NEXT
  END IF

 CALL WriteLib

 FOR i% = 1 TO SubPtr%
  IF SubUsed%(i%) = FALSE THEN CALL WriteFile("extrn __" + LEFT$(Sub$(i%), INSTR(Sub$(i%), ":")) + "NEAR", FMout%)
 NEXT

 CALL NewSeg(DataSeg%, FMout%)
 Flushfile (FMvar%)
 Flushfile (FMout%)

 SEEK #FMvar%, 1
 l& = LOF(FMvar%)

 DO
  s& = l& - SEEK(FMvar%) + 1
  IF s& > 1024 THEN s& = 1024
  tmp$ = SPACE$(s&)
  GET #FMvar%, , tmp$
  PUT #FMout%, , tmp$
 LOOP UNTIL SEEK(FMvar%) > l&
 tmp$ = ""
 d& = FRE("")
 CLOSE #FMvar%

 CALL NewSeg(CodeSeg%, FMout%)

 IF SwPartial% = FALSE OR SwMain% = TRUE THEN
  CALL WriteFile("mr@startup:", FMout%)

 IF WriteMemManager% = TRUE THEN
  IF SwPartial% = TRUE THEN
   CALL WriteOut("	mov	di,offset $StartOfDynamic")
  ELSE
   CALL WriteOut("	mov	di,$StartOfDynamic")
  END IF

  CALL WriteOut("	mov	word ptr ds:[di],'FR'")
  IF SwPartial% = TRUE THEN
   CALL WriteOut("	mov	bx,$StrSegSize - 16")
   CALL WriteOut("	sub	bx,di") ' di=offset $StartOfDynamic
   CALL WriteOut("	mov	word ptr ds:[di+2],bx")
  ELSE
   CALL WriteOut("	mov	word ptr ds:[di+2],$StrSegSize - 16 - $StartOfDynamic")
  END IF
  CALL WriteOut("	mov	word ptr ds:[di+4],ax")
  CALL WriteOut("	mov	si,$StrSegSize - 8")
  CALL WriteOut("	mov	word ptr ds:[di+6],si")

  CALL WriteOut("	mov	word ptr ds:[si],'AR'")
  CALL WriteOut("	mov	word ptr ds:[si+2],ax")
  CALL WriteOut("	mov	word ptr ds:[si+4],di") ' di=$StartOfDynamic
  CALL WriteOut("	mov	word ptr ds:[si+6],ax")
 END IF
 
  IF LTRIM$(StartupList$) <> "" THEN
   t$ = LTRIM$(StartupList$)
   DO
    ptr% = INSTR(t$, " ")
    l$ = LEFT$(t$, ptr% - 1)
    t$ = MID$(t$, ptr% + 1)
    CALL WriteFile("	call	" + l$, FMout%)
   LOOP UNTIL t$ = ""
  END IF
  IF SwDPMI% = TRUE THEN
   CALL WriteOut("	call	_enter_pmode")
   IF LTRIM$(StartupPMList$) <> "" THEN
   t$ = LTRIM$(StartupPMList$)
    DO
     ptr% = INSTR(t$, " ")
     l$ = LEFT$(t$, ptr% - 1)
     t$ = MID$(t$, ptr% + 1)
     CALL WriteFile("	call	" + l$, FMout%)
    LOOP UNTIL t$ = ""
   END IF
  END IF
  CALL WriteFile("	jmp	__Main", FMout%)

  CALL WriteFile("mr@cleanup:", FMout%)
  IF LTRIM$(CleanupList$) <> "" THEN
   t$ = LTRIM$(CleanupList$)
   DO
    ptr% = INSTR(t$, " ")
    l$ = LEFT$(t$, ptr% - 1)
    t$ = MID$(t$, ptr% + 1)
    CALL WriteFile("	call	" + l$, FMout%)
   LOOP UNTIL t$ = ""
  END IF
  CALL WriteFile("	ret", FMout%)

  IF FarDimList$ <> "mr@FarDimList: dw " THEN
   FarDimList$ = FarDimList$ + "0"
   CALL WriteOut(FarDimList$)
  END IF

  IF SwDep% = TRUE THEN
   WriteOut ("mr@my_ds:	dw 1 dup (?)")
   WriteOut ("mr@their_ds:	dw 1 dup (?)")
  ELSE
  END IF

  IF SwPartial% = FALSE THEN CALL WriteFile("$StartOfDynamic equ " + Hex4$(DataPtr&), FMout%)
 END IF
 
 IF EXE% = FALSE THEN CALL WriteStack
 
 IF SwDebug% = TRUE THEN
  IF SwPartial% = TRUE THEN
   IF SwMain% = TRUE THEN
    CALL WriteOut("public mr@line")
    CALL WriteOut("mr@line dw 1 dup (?)")
   ELSE
    CALL WriteOut("extrn mr@line:WORD")
   END IF
  ELSE
   CALL WriteOut("mr@line dw 1 dup (?)"): DataPtr& = DataPtr& + 2
  END IF
  IF SwPartial% = FALSE THEN
   CALL WriteOut("mr@sourcefile	dw " + numi$(LEN(infile$)))
   CALL WriteOut("	db '" + infile$ + "'")
  ELSE
   IF SwMain% = TRUE THEN
    CALL WriteOut("public mr@sourcefile")
    CALL WriteOut("mr@sourcefile	dw offset src_" + depname$)
   ELSE
    CALL WriteOut("extrn mr@sourcefile:WORD")
   END IF
   CALL WriteOut("src_" + depname$ + "	dw " + numi$(LEN(infile$)))
   CALL WriteOut("db '" + infile$ + "'")
  END IF
 END IF

 Flushfile (FMsc%)
 CLOSE #FMsc%

 IF EXE% = FALSE THEN
  OPEN tpath$ + "strconst.$$$" FOR INPUT AS #FMsc% LEN = 2048
  WHILE NOT EOF(FMsc%)
   LINE INPUT #FMsc%, l$
   CALL WriteFile(l$, FMout%)
  WEND
  CLOSE #FMsc%
  IF SwPartial% = FALSE THEN CALL WriteFile("EVEN" + linefeed$ + "end_of_code:" + linefeed$, FMout%)
  CALL WriteFile("code ends", FMout%)
 ELSE
  CALL WriteFile("_text ends" + linefeed$, FMout%)
  CALL WriteFile(linefeed$ + "_strconst segment para public 'data'", FMout%)
  CALL WriteFile("assume cs:_strconst", FMout%)
  OPEN tpath$ + "strconst.$$$" FOR INPUT AS #FMsc% LEN = 2048
  WHILE NOT EOF(FMsc%)
   LINE INPUT #FMsc%, l$
   CALL WriteFile(l$, FMout%)
  WEND
  CLOSE #FMsc%
  CALL WriteFile("_strconst ends", FMout%)
 END IF

 IF EXE% = TRUE THEN
'  IF SwPartial% = FALSE OR SwMain% = TRUE THEN
'   CALL WriteFile(linefeed$ + "_data segment PARA public 'DATA'", FMout%)
'   CALL WriteFile("db " + numl$(StrSegSize&) + " dup (?)", FMout%)
'   CALL WriteFile("_data ends", FMout%)
'   CALL WriteFile("", FMout%)
'  END IF
  CALL WriteFile("_stack segment para stack 'stack'", FMout%)
  CALL WriteFile("assume cs:_stack", FMout%)
  CALL WriteStack
  IF SwPartial% = FALSE OR SwMain% = TRUE THEN CALL WriteFile("db " + numi$(stacksize%) + " dup (?)", FMout%)
  CALL WriteFile("_stack ends", FMout%)
 END IF
 IF SwDep% = FALSE THEN
  IF SwPartial% = TRUE AND SwMain% = FALSE THEN
   CALL WriteFile("END", FMout%)
  ELSE
   CALL WriteFile("END	start_of_code", FMout%)
  END IF
 ELSE
  CALL WriteFile("END", FMout%)
 END IF

 PRINT
 IF SwDep% = TRUE AND Language% = MR% THEN
  PRINT "*Warning*   /L specified but language not defined in source"
  PRINT
 END IF
 IF errcount% = 0 THEN
 
  IF warncount% <> 0 THEN
   PRINT "  warnings:               ";
   PRINT numi$(warncount%)
   PLAY "o3l30ac"
   KILL errfile$
'  ELSE
'   PRINT "none"
  END IF
'  PRINT "  errors:                 none"
'  PRINT

  PRINT "  variable summary:       integers=" + numi$(intcount%) + "  strings=" + numi$(strcount%) + "  labels=" + numi$(labelcount%)
  'IF stacksize% = defaultstacksize% THEN tmp$ = " (Default)" ELSE tmp$ = ""
  'PRINT "            Stack size:             " + numi$(stacksize%) + "b" + tmp$
  'PRINT "            Variable data size:     DS=" + numl$(DataPtr&) + "b"
  'PRINT "            Compile memory usage:   " + numl$(startmem& - FRE(-1)) + "b"
  '(" + numl$(FRE(a$)) + "b free near)"
 END IF
END IF
Flushfile (FMout%)
CLOSE
KILL tpath$ + "variable.$$$"
KILL tpath$ + "code.$$$"
KILL tpath$ + "strconst.$$$"
KILL tpath$ + "stack.$$$"

IF errcount% = 0 THEN
 C$ = LTRIM$(STR$(TIMER - starttime!))
 ptr% = INSTR(C$, ".")
 IF ptr% <> 0 THEN C$ = LEFT$(C$, ptr% + 1)
 PRINT "  MRC compile time:       " + C$ + " seconds."
 CLOSE
 
 IF FFexist%(SysPath$ + "MRC.CFG") = TRUE THEN
  FMcfg% = FREEFILE
  OPEN SysPath$ + "MRC.CFG" FOR INPUT AS #FMcfg%
  WHILE NOT EOF(FMcfg%)
   LINE INPUT #FMcfg%, l$
   l$ = LTRIM$(RTRIM$(l$))
   IF LEFT$(l$, 1) <> ";" AND l$ <> "" THEN
    ptr% = INSTR(l$, " ")
    IF ptr% <> 0 THEN
     k$ = UCASE$(LEFT$(l$, ptr% - 1))
     pa$ = LTRIM$(MID$(l$, ptr%))
     SELECT CASE k$
      CASE "ASSEMBLECOM"
       AssembleCOM$ = FileReplace$(pa$, outfile$)
      CASE "ASSEMBLEEXE"
       AssembleEXE$ = FileReplace$(pa$, outfile$)
      CASE "LINKCOM"
       LinkCOM$ = FileReplace$(pa$, objfile$)
      CASE "LINKEXE"
       LinkEXE$ = FileReplace$(pa$, objfile$)
     END SELECT
    END IF
   END IF
  WEND
  CLOSE #FMcfg%
 ELSE
  AssembleCOM$ = "ASM " + outfile$ + ";"
  AssembleEXE$ = "ASM " + outfile$ + ";"
  LinkCOM$ = "MRLINK " + objfile$
  LinkEXE$ = "LINK " + objfile$ + ";"
 END IF

 IF FFexist%(objfile$) = TRUE THEN KILL objfile$

 IF EXE% = TRUE THEN
  SHELL AssembleEXE$
 ELSE
  SHELL AssembleCOM$
 END IF
 IF FFexist(objfile$) = TRUE THEN
  IF EXE% = TRUE AND SwDep% = FALSE AND SwPartial% = FALSE AND ExternUsed% = FALSE THEN
   IF LinkEXE$ <> "" THEN SHELL LinkEXE$
  ELSE
   IF LinkCOM$ <> "" AND EXE% = FALSE AND SwDep% = FALSE AND SwPartial% = FALSE THEN SHELL LinkCOM$
  END IF
 ELSE
  IF LinkCOM$ <> "" THEN PRINT "*error*     OBJ not found: error occurred during assembly"
 END IF
 IF ExternUsed% = TRUE THEN PRINT "  EXTERN specified; manual link required"

 C$ = LTRIM$(STR$(TIMER - starttime!))
 ptr% = INSTR(C$, ".")
 IF ptr% <> 0 THEN C$ = LEFT$(C$, ptr% + 1)
 PRINT "  total compile time:     " + C$ + " seconds."
END IF
END

errorhandler:
PRINT
PRINT
PRINT "BASIC runtime error #" + numi$(ERR) + "  ";
SELECT CASE ERR
 CASE 6
  PRINT "[Overflow]"
 CASE 7
  PRINT "[Out of memory]"
 CASE 14
  PRINT "[Out of DGROUP space]"
 CASE 53
  PRINT "[File not found]"
 CASE 57
  PRINT "[Hardware error accessing device]"
 CASE 61
  PRINT "[Insufficient disk space]"
 CASE 64
  PRINT "[Bad file name]"
 CASE 67
  PRINT "[Out of DOS file handles]"
 CASE 70
  PRINT "[Access denied]"
 CASE 75
  PRINT "[Path/File access error]"
 CASE 76
  PRINT "[Path not found]"
 CASE ELSE
  PRINT
END SELECT
CLOSE
END

REM $STATIC
SUB AddDataRef (v$, s&, handle%)
IF INSTR(DataRefList$, " " + LCASE$(v$) + " ") = 0 OR v$ = "" THEN
 DataRefList$ = DataRefList$ + LCASE$(v$) + " "
 IF SwPartial% = TRUE THEN
  IF SwMain% = TRUE THEN
   IF v$ <> "" THEN CALL WriteFile("public " + v$, handle%)
   SELECT CASE s&
    CASE 2
     CALL WriteFile(v$ + " dw 1 dup (?)", handle%)
    CASE 4
     CALL WriteFile(v$ + " dw 2 dup (?)", handle%)
    CASE ELSE
     IF (s& / 2) <> (s& \ 2) THEN s& = s& + 1
     CALL WriteFile(v$ + " db " + numl$(s&) + " dup (?)", handle%)
   END SELECT
  ELSE
   IF v$ <> "" THEN CALL WriteFile("extrn " + v$ + ":WORD", handle%)
  END IF
 ELSE
  IF v$ <> "" THEN CALL WriteFile(v$ + " equ 0" + HEX$(DataPtr&) + "h", handle%)
 END IF
 DataPtr& = DataPtr& + s&
END IF
END SUB

FUNCTION FileReplace$ (parm$, Filename$)
p2$ = UCASE$(parm$)
ptr% = INSTR(p2$, "%S")
IF ptr% <> 0 THEN
 FileReplace$ = LEFT$(parm$, ptr% - 1) + Filename$ + MID$(parm$, ptr% + 2)
ELSE
 FileReplace$ = parm$
END IF
END FUNCTION

SUB NewSeg (s%, handle%)
'STATIC LastSeg%()
'DIM LastSeg%(10)
IF s% = LastSeg%(handle%) THEN EXIT SUB
IF EXE% = FALSE THEN
 SELECT CASE LastSeg%(handle%)
  CASE CodeSeg%
   IF s% <> 0 THEN CALL WriteFile("code ends", handle%)
  CASE DataSeg%
   IF s% <> 0 THEN CALL WriteFile("data ends", handle%)
'  CASE StrConstSeg%
'   IF s% <> 0 THEN CALL WriteFile("_strconst ends", handle%)
 END SELECT
ELSE
 SELECT CASE LastSeg%(handle%)
  CASE CodeSeg%
   IF s% <> 0 THEN CALL WriteFile("_text ends", handle%)
  CASE DataSeg%
   IF s% <> 0 THEN CALL WriteFile("_data ends", handle%)
  CASE StrConstSeg%
   IF s% <> 0 THEN CALL WriteFile("_strconst ends", handle%)
 END SELECT
END IF

IF EXE% = FALSE THEN
 SELECT CASE s%
  CASE CodeSeg%
   IF SwPartial% = TRUE THEN
    CALL WriteFile("code segment byte public", handle%)
   ELSE
    CALL WriteFile("code segment word public", handle%)
   END IF
   CALL WriteFile("assume cs:code", handle%)
  CASE DataSeg%
   CALL WriteFile("data segment word public", handle%)
   CALL WriteFile("assume cs:data", handle%)
 END SELECT
ELSE
 SELECT CASE s%
  CASE CodeSeg%
   CALL WriteFile("_text segment para public 'code'", handle%)
   CALL WriteFile("assume cs:_text", handle%)
  CASE DataSeg%
   CALL WriteFile("_data segment para public 'data'", handle%)
   CALL WriteFile("assume cs:_data", handle%)
  CASE StrConstSeg%
   CALL WriteFile("_strconst segment para public 'data'", handle%)
   CALL WriteFile("assume cs:_strconst", handle%)
 END SELECT
END IF
LastSeg%(handle%) = s%
END SUB

FUNCTION Switch% (l$, s$)
ptr% = INSTR(l$, s$)
IF ptr% <> 0 THEN
 l$ = LEFT$(l$, ptr% - 1) + MID$(l$, ptr% + LEN(s$))
 t$ = MID$(s$, 2)
 IF LEFT$(t$, 1) = "-" THEN
  ptr% = INSTR(SwStr$, MID$(t$, 2))
  IF ptr% <> 0 THEN
   DO
    MID$(SwStr$, ptr%, 1) = " "
    ptr% = ptr% + 1
   LOOP UNTIL MID$(SwStr$, ptr%, 1) = " "
  END IF
 ELSE
  SwStr$ = SwStr$ + MID$(s$, 2, 1) + " "
 END IF
 Switch% = TRUE
ELSE
 Switch% = FALSE
END IF

END FUNCTION

SUB WriteLib
IF ESused% = TRUE THEN SwStr$ = SwStr$ + " Z "
M& = FRE("")
liberr% = 0
DIM P(300) AS PtrType

StartupList$ = " "
CleanupList$ = " "

WriteMemManager% = FALSE
IF SwMain% = TRUE THEN
 ptr% = INSTR(ProjList$, ",")
 WHILE ptr% <> 0
  t$ = LEFT$(ProjList$, ptr% - 1)
  ProjList$ = LTRIM$(RTRIM$(MID$(ProjList$, ptr% + 1)))
  FMlibref% = FREEFILE
  IF t$ <> LEFT$(infile$, INSTR(infile$, ".") - 1) THEN
   OPEN t$ + ".L" FOR INPUT AS #FMlibref%
   LOCATE , 1
   PRINT "Gathering project library references... " + t$ + SPACE$(20); : LOCATE , 1
   WHILE NOT EOF(FMlibref%)
    LINE INPUT #FMlibref%, l$
    IF INSTR(LibTable$, " " + l$ + " ") = 0 THEN LibTable$ = LibTable$ + l$ + " "
   WEND
   CLOSE #FMlibref%
  ' KILL t$ + ".L"
  END IF
  ptr% = INSTR(ProjList$, ",")
 WEND
 PRINT SPACE$(79); : LOCATE , 1
END IF
IF LibTable$ <> " " THEN
 FMptr% = FREEFILE
 OPEN SysPath$ + "MOONROCK.PTR" FOR BINARY ACCESS READ AS #FMptr%
 pptr% = -1
 LibAvail$ = " "
 LibRef$ = LibTable$
 null$ = CHR$(0)
 IF SwPartial% = TRUE AND SwMain% = FALSE THEN PRINT "Writing library references... ";
 DO
  pptr% = pptr% + 1
  GET #FMptr%, , P(pptr%)
  tp% = INSTR(P(pptr%).LibName, null$)
  IF tp% <> 0 THEN P(pptr%).LibName = LEFT$(P(pptr%).LibName, tp% - 1)
  l$ = RTRIM$(P(pptr%).LibName)
  LibAvail$ = LibAvail$ + l$ + " "
  IF INSTR(LibRef$, " " + l$ + " ") <> 0 THEN MID$(LibRef$, INSTR(LibRef$, " " + l$ + " "), LEN(l$) + 1) = SPACE$(LEN(l$) + 1)
 LOOP UNTIL P(pptr%).Posi = -1
 LibRef$ = RTRIM$(LTRIM$(LibRef$))
 IF LibRef$ <> "" THEN
  PRINT
  COLOR 28
  PRINT "**Error**";
  COLOR 4
  PRINT "  Unresolved external library references. Report to author."
  PRINT
  COLOR 14
  PRINT LibRef$
  PRINT
  COLOR 7
  CLOSE
  END
 END IF
 pptr% = pptr% - 1
 CLOSE #FMptr%
 LibWritten$ = " "
 CALL WriteFile("", FMout%)
 CALL WriteFile("; Standard routines", FMout%)
 CALL WriteFile("", FMout%)
 IF SwPartial% = TRUE AND SwMain% = FALSE THEN
  FMlibref% = FREEFILE
  OPEN libfile$ FOR OUTPUT AS #FMlibref%
 END IF

 FMlib% = FREEFILE
 OPEN SysPath$ + "MOONROCK.ALB" FOR INPUT AS #FMlib%
 DO
  FOR i% = 0 TO pptr%
   IF INSTR(LibTable$, " " + RTRIM$(P(i%).LibName) + " ") <> 0 THEN
    ptr% = INSTR(LibTable$, " " + RTRIM$(P(i%).LibName) + " ")
    cname$ = RTRIM$(P(i%).LibName)
    IF INSTR(cname$, "mem") <> 0 THEN WriteMemManager% = TRUE
     MID$(LibTable$, ptr% + 1, LEN(cname$)) = SPACE$(LEN(cname$))
     LibTable$ = " " + LTRIM$(RTRIM$(LibTable$)) + " "
     IF INSTR(LibWritten$, " " + cname$ + " ") = 0 THEN
      LibWritten$ = LibWritten$ + cname$ + " "
       IF SwPartial% = FALSE OR SwMain% = TRUE THEN
        PRINT "Writing lib: " + cname$ + SPACE$(30); : LOCATE , 1
        fb$(FMout%) = fb$(FMout%) + linefeed$ + "public " + cname$ + linefeed$
       ELSE
        fb$(FMout%) = fb$(FMout%) + "extrn " + cname$ + ":NEAR" + linefeed$
        PRINT #FMlibref%, cname$
       END IF
        
       SEEK #FMlib%, P(i%).Posi + 1
       DO
        LINE INPUT #FMlib%, l$
        'PRINT l$
        l2$ = LTRIM$(l$)
        IF INSTR("#@", LEFT$(l2$, 1)) <> 0 THEN
         lineok% = TRUE
         WHILE INSTR("#@", LEFT$(l2$, 1)) <> 0
          SELECT CASE LEFT$(l2$, 1)
           CASE "@"
            IF INSTR(SwStr$, " " + MID$(l2$, 2, 1) + " ") <> 0 THEN lineok% = FALSE
           CASE "#"
            IF INSTR(SwStr$, " " + MID$(l2$, 2, 1) + " ") = 0 THEN lineok% = FALSE
          END SELECT
          l2$ = MID$(l2$, 3)
          l$ = MID$(l$, 3)
         WEND
        ELSE
         lineok% = TRUE
        END IF
        IF lineok% = TRUE THEN
        IF LEFT$(l2$, 1) = "	" THEN l2$ = MID$(l2$, 2)
        IF MID$(l2$, 3, 1) = "	" THEN l2$ = LEFT$(l2$, 2) + MID$(l2$, 4)
        IF INSTR("$%", LEFT$(l2$, 1)) = 0 THEN
         IF LEFT$(l2$, 5) = "call	" AND INSTR(l2$, "ds:[") = 0 THEN
          IF INSTR(LibTable$, " " + MID$(l2$, 6) + " ") = 0 AND MID$(l2$, 6, 3) <> "mr@" THEN LibTable$ = LibTable$ + MID$(l2$, 6) + " "
           IF SwFarCall% = TRUE THEN
           ptr% = INSTR(l$, "call	")
           l$ = LEFT$(l$, ptr% + 4) + "far " + MID$(l$, ptr% + 5)
          END IF
         END IF
         IF SwPartial% = FALSE OR SwMain% = TRUE THEN
          IF WriteSource% = TRUE THEN
           fb$(FMout%) = fb$(FMout%) + l$ + linefeed$
          ELSE
           fb$(FMout%) = fb$(FMout%) + LTRIM$(l$) + linefeed$
          END IF
         END IF
        ELSE
'         IF SwPartial% = FALSE OR SwMain% = TRUE THEN
          SELECT CASE LEFT$(l2$, 1)
           CASE "$"
            IF SwFarCall% = TRUE THEN t$ = " far" ELSE t$ = ""
            SELECT CASE UCASE$(MID$(l2$, 2))
             CASE "OUTSTREAM"
              IF SwPartial% = FALSE OR SwMain% = TRUE THEN fb$(FMout%) = fb$(FMout%) + "	call" + t$ + "	" + outstream$ + linefeed$
              IF INSTR(LibTable$, " " + outstream$ + " ") = 0 THEN LibTable$ = LibTable$ + outstream$ + " "
             CASE "ERRHANDLER"
              IF SwPartial% = FALSE OR SwMain% = TRUE THEN fb$(FMout%) = fb$(FMout%) + "	jmp" + t$ + "	" + errhandler$ + linefeed$
              IF errhandler$ = "_err_msg" THEN
               IF INSTR(LibTable$, " " + errhandler$ + " ") = 0 THEN LibTable$ = LibTable$ + errhandler$ + " "
              END IF
            END SELECT
           CASE "%"
            l2$ = MID$(l2$, 2)
            ptr% = INSTR(l2$, " ")
            SELECT CASE UCASE$(LEFT$(l2$, ptr% - 1))
             CASE "BUNDLE"
              bn$ = UCASE$(LTRIM$(MID$(l2$, ptr%)))
              matched% = FALSE
              FOR ti% = 0 TO BundlePtr%
               t1$ = LEFT$(Bundle$(ti%), LEN(Bundle$(ti%)) - 1)
               IF UCASE$(t1$) = bn$ THEN matched% = TRUE
              NEXT
              IF matched% = FALSE THEN
               PRINT "*Error*  Bundle definition '" + bn$ + "' required for function " + cname$
               errcount% = errcount% + 1
               errflag% = TRUE
               liberr% = liberr% + 1
              END IF
             CASE "ALLOCATE"
              l2$ = LTRIM$(MID$(l2$, 9))
              ptr% = INSTR(l2$, " ")
              v$ = LEFT$(l2$, ptr% - 1)
              IF SwMain% = TRUE THEN CALL NewSeg(DataSeg%, FMout%)
              CALL AddDataRef(v$, VAL(MID$(l2$, ptr%)), FMout%)
              IF SwMain% = TRUE THEN CALL NewSeg(CodeSeg%, FMout%)
            '  IF INSTR(DataRefList$, " " + LCASE$(v$) + " ") = 0 THEN
            '   DataRefList$ = DataRefList$ + LCASE$(v$) + " "
            '   fb$(FMout%) = fb$(FMout%) + v$ + " equ 0" + HEX$(DataPtr&) + "h" + linefeed$
            '   DataPtr& = DataPtr& + VAL(MID$(l2$, ptr%))
            '  END IF
             CASE "INCLUDE"
              t$ = LCASE$(LTRIM$(MID$(l2$, 9)))
              IF INSTR(LibTable$, " " + t$ + " ") = 0 THEN LibTable$ = LibTable$ + t$ + " "
             CASE "STARTUP"
              t$ = LCASE$(LTRIM$(MID$(l2$, 9)))
              IF INSTR(LibTable$, " " + t$ + " ") = 0 THEN LibTable$ = LibTable$ + t$ + " "
              IF INSTR(StartupList$, " " + t$ + " ") = 0 THEN StartupList$ = StartupList$ + t$ + " "
             CASE "CLEANUP"
              t$ = LCASE$(LTRIM$(MID$(l2$, 9)))
              IF INSTR(LibTable$, " " + t$ + " ") = 0 THEN LibTable$ = LibTable$ + t$ + " "
              IF INSTR(CleanupList$, " " + t$ + " ") = 0 THEN CleanupList$ = CleanupList$ + t$ + " "
             CASE "STARTUPPM"
              IF SwDPMI% = TRUE THEN
               t$ = LCASE$(LTRIM$(MID$(l2$, 11)))
               IF INSTR(LibTable$, " " + t$ + " ") = 0 THEN LibTable$ = LibTable$ + t$ + " "
               IF INSTR(StartupPMList$, " " + t$ + " ") = 0 THEN StartupPMList$ = StartupPMList$ + t$ + " "
              END IF
             CASE "SS"
              t$ = LTRIM$(MID$(l2$, 3))
              PRINT #FMstack%, t$
            END SELECT
         END SELECT
        'END IF
       END IF
       END IF
       IF LEN(fb$(FMout%)) > 1024 THEN Flushfile (FMout%)
      LOOP UNTIL SEEK(FMlib%) + 2 > (P(i%).Posi + 1 + P(i%).Length)
      Flushfile (FMout%)
     END IF
    END IF
  NEXT

 LOOP UNTIL LibTable$ = "  "
 LOCATE , 1
 PRINT SPACE$(50); : LOCATE , 1
 IF SwPartial% = TRUE AND SwMain% = FALSE THEN CLOSE #FMlibref%

END IF
IF liberr% <> 0 THEN PRINT "FATAL: " + numi$(liberr%) + " library function error(s)"

END SUB

SUB WriteOut (s$)
CALL WriteFile(s$, FMout%)
END SUB

SUB WriteStack
CLOSE #FMstack%
FMstack% = FREEFILE
OPEN tpath$ + "stack.$$$" FOR INPUT AS #FMstack%
WHILE NOT EOF(FMstack%)
 LINE INPUT #FMstack%, l$
 IF SwPartial% = TRUE AND SwMain% = FALSE THEN
  ptr% = INSTR(l$, " ")
  CALL WriteFile("extrn " + LEFT$(l$, ptr% - 1) + ":WORD", FMout%)
 ELSE
  IF SwMain% = TRUE THEN
   ptr% = INSTR(l$, " ")
   CALL WriteFile("public " + LEFT$(l$, ptr% - 1), FMout%)
  END IF
  CALL WriteFile(l$, FMout%)
 END IF
WEND
CLOSE #FMstack%

IF SwDebug% = TRUE THEN
 IF SwPartial% = FALSE OR SwMain% = TRUE THEN
  CALL WriteOut("old_int00:	dd 1 dup (?)")
  CALL WriteOut("_err dw 1 dup (?)")
  CALL WriteFile("old_int04:	dd 1 dup (?)", FMout%)
 ELSE
  IF SwPartial% = TRUE THEN
   CALL WriteOut("extrn old_int00:DWORD")
   CALL WriteOut("extrn _err:WORD")
   CALL WriteOut("extrn old_int04:DWORD")
 END IF
 END IF
END IF
IF SwDebug% = TRUE THEN
 CALL WriteFile(DimBound$, FMout%)
 IF DimType$ <> "" AND (SwPartial% = FALSE OR SwMain% = TRUE) THEN
  CALL WriteFile("old_int05:	dd 1 dup (?)", FMout%)
 END IF
 IF SwPartial% = TRUE AND SwMain% = FALSE THEN CALL WriteOut("extrn old_int05:DWORD")
'  CALL WriteOut(DimBound$)
END IF
IF (SwPartial% = FALSE OR SwMain% = TRUE) AND SwResume% = TRUE THEN CALL WriteFile("_errcode: dw 1 dup (?)", FMout%)
END SUB

SUB WriteStartup
 CALL WriteFile("; " + STRING$(60, "-"), FMvar%)

 IF SwDep% = FALSE THEN
  'CALL WriteOut("main:")
  CALL WriteOut("start_of_code:")
  IF SwDOSX% = FALSE THEN
   IF EXE% = FALSE THEN
    CALL WriteOut("	mov	sp,offset end_of_code+" + numi$(stacksize%))
    IF SwPartial% = TRUE THEN
'     CALL WriteOut("	and	sp,0fffeh")
     CALL WriteOut("	mov	bx,offset end_of_code")
     IF Processor% >= 186 THEN
      CALL WriteOut("	shr	bx,4")
     ELSE
      CALL WriteOut("	mov	cl,4")
      CALL WriteOut("	shr	bx,cl")
     END IF
     CALL WriteOut("	add	bx," + numi$(((stacksize%) \ 16) + 1))
    ELSE
     CALL WriteOut("	mov	bx,((offset end_of_code - offset start_of_code + 15) / 16) + " + numi$(((stacksize% + 15) / 16) + 16))
    END IF
    CALL WriteOut("	mov	ah,4ah" + linefeed$ + "	int	21h")
    IF SwDebug% = TRUE THEN
     CALL WriteOut("	jnc	_ResizeOK")
     CALL WriteOut("	jmp	_InitErr")
     CALL WriteOut("_ResizeOK:")
    ELSE
     CALL WriteOut("	jc	_InitErr")
    END IF
    IF EXE% = TRUE THEN CALL WriteOut("	push	cs" + linefeed$ + "	pop	ds")
    IF SwCritical% = TRUE THEN
     CALL WriteOut("	mov	ax,3524h" + linefeed$ + "	int	21h")
     CALL WriteOut("	mov	word ptr cs:[old_int24],bx" + linefeed$ + "	mov	word ptr cs:[old_int24+2],es")
     CALL WriteOut("	mov	ax,2524h" + linefeed$ + "	mov	dx,offset _critical")
     CALL WriteOut("	int	21h")
    END IF
   ELSE
    CALL WriteOut("	push	es")
    CALL WriteOut("	mov	bx,sp" + linefeed$ + "	add	bx,17")
    IF Processor% >= 186 THEN
     CALL WriteOut("	shr	bx,4")
    ELSE
     CALL WriteOut("	mov	cl,4" + linefeed$ + "	shr	bx,cl")
    END IF
    CALL WriteOut("	mov	ax,ss" + linefeed$ + "	add	bx,ax")
    CALL WriteOut("	mov	ax,es" + linefeed$ + "	sub	bx,ax")
'    CALL WriteOut("	inc	bx")
    CALL WriteOut("	mov	ah,4ah" + linefeed$ + "	int	21h")
    IF SwDebug% = TRUE THEN
     CALL WriteOut("	jnc	_ResizeOK")
     CALL WriteOut("	jmp	_InitErr")
     CALL WriteOut("_ResizeOK:")
    ELSE
     CALL WriteOut("	jc	_InitErr")
    END IF
   
    IF SwCritical% = TRUE OR SwDebug% = TRUE THEN CALL WriteOut("	push	cs" + linefeed$ + "	pop	ds")
    IF SwCritical% = TRUE THEN
     CALL WriteOut("	mov	ax,3524h" + linefeed$ + "	int	21h")
     CALL WriteOut("	mov	word ptr cs:[old_int24],bx" + linefeed$ + "	mov	word ptr cs:[old_int24+2],es")
     CALL WriteOut("	mov	ax,2524h" + linefeed$ + "	mov	dx,offset _critical")
     CALL WriteOut("	int	21h")
    END IF
   END IF
  ELSE
   IF EXE% = TRUE THEN CALL WriteOut("	push	es")
  END IF

 ELSE
  CALL WriteOut("public " + depname$ + "_INIT")
  CALL WriteOut(depname$ + "_INIT:")
  CALL WriteOut("	push	bp")
  CALL WriteOut("	push	si")
  CALL WriteOut("	push	di")
  CALL WriteOut("	push	ds")
  CALL WriteOut("	push	es")
 END IF

 IF SwDebug% = TRUE THEN
  CALL WriteOut("	mov	ax,3500h" + linefeed$ + "	int	21h")
  CALL WriteOut("	mov	word ptr ss:[old_int00],bx" + linefeed$ + "	mov	word ptr ss:[old_int00+2],es")
  CALL WriteOut("	mov	ax,2500h" + linefeed$ + "	mov	dx,offset _err_div0")
  CALL WriteOut("	int	21h")
  CALL WriteOut("	mov	ax,3504h" + linefeed$ + "	int	21h")
  CALL WriteOut("	mov	word ptr ss:[old_int04],bx" + linefeed$ + "	mov	word ptr ss:[old_int04+2],es")
  CALL WriteOut("	mov	ax,2504h" + linefeed$ + "	mov	dx,offset _err_overflow")
  CALL WriteOut("	int	21h")
  IF DimType$ <> "" THEN
   CALL WriteOut("	mov	ax,3505h" + linefeed$ + "	int	21h")
   CALL WriteOut("	mov	word ptr ss:[old_int05],bx" + linefeed$ + "	mov	word ptr ss:[old_int05+2],es")
   CALL WriteOut("	mov	ax,2505h" + linefeed$ + "	mov	dx,offset _err_bound")
   CALL WriteOut("	int	21h")
   LibTable$ = LibTable$ + "_err_bound "
  END IF
 END IF

' IF EXE% = FALSE THEN
  CALL WriteOut("	mov	ah,48h" + linefeed$ + "	mov	bx,(($strsegsize / 16)+1)" + linefeed$ + "	int	21h")
  CALL WriteOut("	jc	_InitErr")
' ELSE
'  CALL WriteOut("	mov	ax,seg _DATA")
' END IF

 CALL WriteOut("	mov	ds,ax")
 CALL WriteOut("	mov	es,ax")
 IF SwResume% = FALSE THEN WriteOut ("	mov	word ptr ss:[mr@ds],ax")
 IF SwDep% = TRUE THEN CALL WriteOut("	mov	word ptr cs:[mr@my_ds],ax")
 CALL WriteOut("	xor	di,di")
 CALL WriteOut("	mov	cx,$strsegsize/2")
 CALL WriteOut("	xor	ax,ax")
 CALL WriteOut("	cld")
 CALL WriteOut("	rep	stosw")
 IF EXE% = TRUE THEN CALL WriteOut("	pop	word ptr ds:[mr@psp]")

 IF FarDimList$ <> "mr@FarDimList: dw " THEN
  CALL WriteOut("	mov	si,offset mr@FarDimList")
  CALL WriteOut("FarDimLoop:")
  CALL WriteOut("	mov	ah,48h")
  CALL WriteOut("	mov	bx,cs:[si]")
  CALL WriteOut("	or	bx,bx")
  CALL WriteOut("	jz	short FarDimDone")
  CALL WriteOut("	add	si,2")
  CALL WriteOut("	int	21h")
  CALL WriteOut("	jc	_InitErr")
  CALL WriteOut("	mov	di,cs:[si]")
  CALL WriteOut("	add	si,2")
  CALL WriteOut("	mov	ds:[di],ax")
  CALL WriteOut("	jmp	short FarDimLoop")
  CALL WriteOut("FarDimDone:")
  CALL WriteOut("	xor	ax,ax")
 END IF



 IF SwMain% = TRUE THEN
  CALL WriteFile("	call	mr@startup", FMout%)
  CALL WriteFile("	jmp	_exit", FMout%)
 ELSE
  CALL WriteFile("	jmp	mr@startup", FMout%)
 END IF
 
 IF SwDep% = TRUE THEN
  CALL WriteOut("__Main:")
  CALL WriteFile("	mov	ax,-1", FMout%)
  CALL WriteFile(depname$ + "_RET:", FMout%)
  CALL WriteFile("	pop	es", FMout%)
  CALL WriteFile("	pop	ds", FMout%)
  CALL WriteFile("	pop	di", FMout%)
  CALL WriteFile("	pop	si", FMout%)
  CALL WriteFile("	pop	bp", FMout%)
  CALL WriteFile("	retf", FMout%)
  CALL WriteFile("_InitErr:", FMout%)
  CALL WriteFile("	xor	ax,ax", FMout%)
  CALL WriteFile("	jmp	" + depname$ + "_RET", FMout%)
 ELSE
  CALL WriteOut("_InitErr:")
  CALL WriteOut("	mov	ah,9")
  CALL WriteOut("	mov	dx,offset mr@InitMsg")
  IF EXE% = TRUE THEN
   CALL WriteOut("	push	cs")
   CALL WriteOut("	pop	ds")
  END IF
  CALL WriteOut("	int	21h")
  CALL WriteOut("	jmp	_exit2")
  CALL WriteOut("mr@InitMsg: db 'Memory allocation error$'")
  IF SwMain% = FALSE THEN
   CALL WriteOut(linefeed$ + "public __MAIN")
   CALL WriteOut(linefeed$ + "__Main:")
  END IF
  'IF SwDPMI% = TRUE THEN WriteOut ("	call	_enter_pmode")
 END IF

 'CLOSE #FMcode%

END SUB

