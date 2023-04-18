DECLARE SUB Process (f$)
DECLARE FUNCTION FFexist% (tmpmask$, tmpattrib%)
DECLARE FUNCTION FFfindnext$ ()
DECLARE FUNCTION FFfindfirst$ ()
DECLARE SUB FFinit (fftmpmask$, fftmpattrib%)
DECLARE FUNCTION FFparse$ ()
DECLARE FUNCTION findfile$ ()

TYPE RegType
 AX AS INTEGER
 BX AS INTEGER
 CX AS INTEGER
 DX AS INTEGER
 BP AS INTEGER
 SI AS INTEGER
 DI AS INTEGER
 FLAGS AS INTEGER
 DS AS INTEGER
 ES AS INTEGER
END TYPE

TYPE FFdatablock
 FDBfill1 AS STRING * 21
 FDBattrib AS STRING * 1
 FDBtime AS INTEGER
 FDBdate AS INTEGER
 FDBsize AS LONG
 FDBname AS STRING * 13
 FDBfill2 AS STRING * 100
END TYPE

DIM SHARED ireg AS RegType
DIM SHARED oreg AS RegType
DIM SHARED FDB AS FFdatablock
DIM SHARED tmpmask AS STRING * 64

COMMON SHARED FFinmask$, FFinattrib%, FFDOSerr%, FFattrib%, FFsize&
COMMON SHARED FFtime%, FFdate%

COMMON SHARED FMlib%, sourcesize&, destsize&, fcount%

CONST TRUE = -1
CONST FALSE = 0

LOCATE , , 1
FMlib% = FREEFILE
OPEN COMMAND$ + "MOONROCK.ALB" FOR OUTPUT AS #FMlib%

COLOR 11
PRINT "Processing:"
COLOR 15
CALL FFinit("*.ASM", 7)
DO
 f$ = findfile$
 IF f$ <> "" THEN CALL Process(f$)
LOOP UNTIL f$ = ""
PRINT #FMlib%, "_end_of_lib:"
destcount& = LOF(FMlib%)
CLOSE #FMlib%
PRINT
PRINT sourcesize&; "bytes source, in"; fcount%; "files."; destcount&; "bytes final library size."
CLOSE

FUNCTION FFexist% (tmpmask$, tmpattrib%)
' Checks for the existence of a file/dir/volume etc.
' Wildcards are allowed.
' File = 7, Dir = 16, see DOS interrupt list for others
CALL FFinit(tmpmask$, tmpattrib%)
res% = 0
DO
 tmp$ = findfile$
 IF tmp$ <> "" THEN res% = -1
LOOP UNTIL tmp$ = ""
FFexist% = res%
END FUNCTION

FUNCTION FFfindfirst$
tmpmask$ = FFinmask$ + CHR$(0)
' FFinmask$ has already been set up by FFinit and is global/common
ireg.AX = &H4E00
ireg.CX = FFinattrib%
ireg.DX = VARPTR(tmpmask$)
ireg.DS = VARSEG(tmpmask$)
CALL interruptx(&H21, ireg, oreg)
' call DOS 'find first' interrupt
FFfindfirst$ = FFparse$
END FUNCTION

FUNCTION FFfindnext$
ireg.AX = &H4F00
CALL interrupt(&H21, ireg, oreg)
' call DOS 'find next' interrupt
FFfindnext$ = FFparse$
END FUNCTION

SUB FFinit (fftmpmask$, fftmpattrib%)
' Example: CALL FFinit ("C:\QB\*.BAS, 7)
' Initialises with filemask C:\QB\*.BAS, type 7 (file)
ireg.AX = &H1A00
ireg.DX = VARPTR(FDB)
CALL interrupt(&H21, ireg, oreg)
FFinmask$ = fftmpmask$
FFinattrib% = fftmpattrib%
END SUB

FUNCTION FFparse$
' Grabs the information from the data block
FFDOSerr% = oreg.AX
IF FFDOSerr% = 0 THEN
 ' Everything went well
 FFfilename$ = FDB.FDBname$
 FFfilename$ = LEFT$(FFfilename$, INSTR(FFfilename$, CHR$(0)) - 1)
 FFattrib% = ASC(FDB.FDBattrib)
 FFsize& = FDB.FDBsize
 FFtime% = FDB.FDBtime
 FFdate% = FDB.FDBdate
 FFparse$ = FFfilename$
ELSE
 ' An error of some kind occurred
 FFparse$ = ""
 FFattrib% = 0
 FFsize& = 0
END IF
END FUNCTION

FUNCTION findfile$
' Finds first or next file. FFinit MUST be called before this.
IF FFinmask$ <> "" THEN
 findfile$ = FFfindfirst$
 FFinmask$ = ""
ELSE
 findfile$ = FFfindnext$
END IF
END FUNCTION

SUB Process (f$)
PRINT LEFT$(f$ + SPACE$(15), 15);
FMasm% = FREEFILE
OPEN f$ FOR INPUT AS #FMasm%
sourcesize& = sourcesize& + LOF(FMasm%)
fcount% = fcount% + 1
popen% = FALSE
WHILE NOT EOF(FMasm%)
 LINE INPUT #FMasm%, l$
 l$ = LTRIM$(RTRIM$(l$))
 IF LEFT$(l$, 2) = ";;" THEN PRINT #FMlib%, MID$(l$, 2): GOTO skip

' IF RIGHT$(l$, 1) = ":" AND LEFT$(l$, 1) = "_" THEN
'  IF popen% = TRUE THEN PRINT #FMlib%, proc$ + "        endp": popen% = FALSE
'  proc$ = LEFT$(l$, LEN(l$) - 1)
'  l$ = proc$ + " proc near": popen% = TRUE
' END IF

 ptr% = INSTR(l$, ";")
 IF ptr% <> 0 THEN
  IF MID$(l$, ptr% + 1, 1) <> ";" THEN
   l$ = RTRIM$(LEFT$(l$, ptr% - 1))
  ELSE
   l$ = LEFT$(l$, ptr%) + MID$(l$, ptr% + 2)
  END IF
 END IF

 IF l$ <> "" THEN
  IF LEFT$(l$, 1) = "#" OR LEFT$(l$, 1) = "@" THEN
   cc$ = ""
   WHILE INSTR("@#", LEFT$(l$, 1)) <> 0
     cc$ = cc$ + LEFT$(l$, 2)
     l$ = LTRIM$(MID$(l$, 3))
   WEND
  ELSE
   cc$ = ""
  END IF
  IF LEFT$(l$, 4) <> "db '" THEN
   DO
    ptr% = INSTR(l$, "  ")
    IF ptr% <> 0 AND MID$(l$, ptr% + 2) <> "'" THEN
     l$ = LEFT$(l$, ptr%) + MID$(l$, ptr% + 2)
    ELSE
     ptr% = 0
    END IF
   LOOP UNTIL ptr% = 0
  END IF
  IF LEFT$(l$, 5) = "push " THEN
   l$ = LTRIM$(MID$(l$, 5)) + ","
   DO
    ptr% = INSTR(l$, ",")
    IF ptr% <> 0 THEN
     PRINT #FMlib%, cc$ + "	push	" + LEFT$(l$, ptr% - 1)
     l$ = LTRIM$(MID$(l$, ptr% + 1))
    END IF
   LOOP UNTIL l$ = ""
   GOTO skip
  END IF
  IF LEFT$(l$, 4) = "pop " THEN
   l$ = LTRIM$(MID$(l$, 4)) + ","
   DO
    ptr% = INSTR(l$, ",")
    IF ptr% <> 0 THEN
     PRINT #FMlib%, cc$ + "	pop	" + LEFT$(l$, ptr% - 1)
     l$ = LTRIM$(MID$(l$, ptr% + 1))
    END IF
   LOOP UNTIL l$ = ""
   GOTO skip
  END IF
 
  IF RIGHT$(l$, 1) = ":" OR LEFT$(l$, 1) = "%" OR LEFT$(l$, 1) = "$" OR INSTR(l$, " equ ") <> 0 OR LEFT$(l$, 1) = "_" THEN
   PRINT #FMlib%, cc$ + l$
  ELSE
   IF INSTR(l$, ": ") = 0 THEN
    ptr% = INSTR(l$, " ")
    IF ptr% = 0 THEN
     PRINT #FMlib%, cc$ + "	" + l$
    ELSE
     PRINT #FMlib%, cc$ + "	" + LEFT$(l$, ptr% - 1) + "	" + LTRIM$(MID$(l$, ptr%))
    END IF
   ELSE
    PRINT #FMlib%, cc$ + "	" + l$
   END IF
  END IF
 END IF
skip:
WEND
CLOSE #FMasm%
'PRINT #FMlib%, proc$ + "        endp"
END SUB

