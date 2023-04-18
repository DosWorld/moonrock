DECLARE SUB Sort ()
CONST FALSE = 0
CONST TRUE = -1

TYPE IdxType
 HName AS STRING * 25
 HPosi AS LONG
END TYPE

COMMON SHARED idxptr%

DIM SHARED Idx(500)  AS IdxType

OPEN "\mr\zip\mr-ref.doc" FOR INPUT AS #1
OPEN "\mr\ide\mrhelp.idx" FOR OUTPUT AS #2
CLOSE #2
OPEN "\mr\ide\mrhelp.idx" FOR BINARY AS #2

LOCATE , , 1
PRINT "Indexing... ";
idxptr% = 0
WHILE NOT EOF(1)
 DO
  LINE INPUT #1, l$
 LOOP UNTIL l$ = "--------------------------------------------------------------------------"
 IF SEEK(1) + 100 > LOF(1) THEN GOTO fred
 LINE INPUT #1, l$
 myposi& = SEEK(1) - 1
 Idx(idxptr%).HPosi& = myposi&
 LINE INPUT #1, l$
 l$ = LTRIM$(l$)
 ptr% = INSTR(l$, " ")
 c$ = LCASE$(LTRIM$(MID$(l$, ptr%)))
 Idx(idxptr%).HName$ = c$ + STRING$(30, CHR$(0))
 idxptr% = idxptr% + 1
 DO
  LINE INPUT #1, l$
  IF LEFT$(l$, 18) = SPACE$(18) THEN
   c$ = LCASE$(LTRIM$(l$))
   Idx(idxptr%).HPosi& = myposi&
   Idx(idxptr%).HName$ = c$ + STRING$(30, CHR$(0))
   idxptr% = idxptr% + 1
  END IF
 LOOP UNTIL LEFT$(l$, 18) <> SPACE$(18)
 DO
  s& = SEEK(1)
  LINE INPUT #1, l$
 LOOP UNTIL l$ = "--------------------------------------------------------------------------"
 SEEK #1, s&
WEND
fred:
idxptr% = idxptr% - 1
PRINT
PRINT "Sorting...("; idxptr%; ") ";
CALL Sort
PRINT
FOR i% = 0 TO idxptr%
 PUT #2, , Idx(i%)
NEXT
Idx(0).HPosi& = -1
PUT #2, , Idx(0)

CLOSE

SUB Sort
sw% = FALSE
WHILE sw% = FALSE
 sw% = TRUE
 FOR i% = 0 TO idxptr% - 1
  IF Idx(i%).HName$ > Idx(i% + 1).HName$ THEN
   SWAP Idx(i%), Idx(i% + 1)
   sw% = FALSE
   EXIT FOR
  END IF
 NEXT
WEND
END SUB

