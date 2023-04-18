TYPE PtrType
 LibName AS STRING * 30
 Posi AS LONG
 Length AS INTEGER
END TYPE

DIM SHARED P(500) AS PtrType

OPEN "MOONROCK.ALB" FOR INPUT AS #1
OPEN "MOONROCK.PTR" FOR OUTPUT AS #2: CLOSE #2
OPEN "MOONROCK.PTR" FOR BINARY AS #2

null$ = STRING$(30, CHR$(0))

WHILE NOT EOF(1)
 s& = SEEK(1) - 1
 LINE INPUT #1, l$
 IF LEFT$(LTRIM$(l$), 1) = "_" AND RIGHT$(l$, 4) <> "endp" THEN
  IF INSTR(l$, " proc ") = 0 THEN
   P(i%).LibName = LEFT$(l$, LEN(l$) - 1) + null$
   P(i%).Posi = s&
   IF i% <> 0 THEN P(i% - 1).Length = s& - P(i% - 1).Posi
   i% = i% + 1
  ELSE
   t% = INSTR(l$, " ")
   P(i%).LibName = LEFT$(l$, t% - 1) + null$
   P(i%).Posi = s&
   IF i% <> 0 THEN P(i% - 1).Length = s& - P(i% - 1).Posi
   i% = i% + 1
  END IF
 END IF
WEND
P(i%).LibName = ""
P(i%).Posi = -1
FOR j% = 0 TO i%
 PUT #2, , P(j%)
NEXT
CLOSE
PRINT i%; "functions compiled."

