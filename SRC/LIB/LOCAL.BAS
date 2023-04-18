DIM pl$(500)

OPEN "MOONROCK.ALB" FOR INPUT AS #1
OPEN "..\MOONROCK.ALB" FOR OUTPUT AS #2

LINE INPUT #1, func$
PRINT #2, func$

DO
 pltop% = -1
 DO
  pltop% = pltop% + 1
  LINE INPUT #1, pl$(pltop%)
 LOOP UNTIL LEFT$(pl$(pltop%), 1) = "_" AND RIGHT$(pl$(pltop%), 4) <> "endp"
 func$ = pl$(pltop%): pltop% = pltop% - 1
 PRINT func$ + SPACE$(40 - LEN(func$)); : LOCATE , 1

 DO
  li% = -1
  DO
   li% = li% + 1
  LOOP UNTIL (LEFT$(pl$(li%), 1) = "L" AND MID$(pl$(li%), 3, 1) = ":") OR (LEFT$(pl$(li%), 1) = "#" AND MID$(pl$(li%), 3, 1) = "L" AND MID$(pl$(li%), 5, 1) = ":") OR li% = pltop%
  IF ((LEFT$(pl$(i%), 1) <> "L" AND MID$(pl$(li%), 3, 1) <> ":") OR (LEFT$(pl$(li%), 1) = "#" AND MID$(pl$(li%), 3, 1) = "L" AND MID$(pl$(li%), 5, 1) = ":")) AND li% = pltop% THEN GOTO passdone
  lc% = lc% + 1
  newla$ = "I" + LTRIM$(STR$(lc%))
  IF LEFT$(pl$(li%), 1) = "#" THEN
   la$ = MID$(pl$(li%), 3, 2)
   pl$(li%) = LEFT$(pl$(li%), 2) + newla$ + ":"
  ELSE
   la$ = LEFT$(pl$(li%), 2)
   pl$(li%) = newla$ + ":"
  END IF
 
  i% = -1
  DO
   i% = i% + 1
   IF INSTR(pl$(i%), la$) <> 0 AND pl$(i%) <> la$ + ":" AND MID$(pl$(i%), 3, 3) <> la$ + ":" THEN
    ptr% = INSTR(pl$(i%), ">" + la$)
    IF ptr% <> 0 THEN
     IF i% < li% THEN pl$(i%) = LEFT$(pl$(i%), ptr% - 1) + newla$ + MID$(pl$(i%), ptr% + 3)
    ELSE
     ptr% = INSTR(pl$(i%), la$)
     pl$(i%) = LEFT$(pl$(i%), ptr% - 1) + newla$ + MID$(pl$(i%), ptr% + 2)
    END IF
   END IF
  LOOP UNTIL pl$(i%) = la$ + ":" OR MID$(pl$(i%), 3, 3) = la$ + ":" OR i% = pltop%
 LOOP
passdone:
FOR i% = 0 TO pltop%
 PRINT #2, pl$(i%)
NEXT
PRINT #2, func$
LOOP UNTIL func$ = "_end_of_lib:"
CLOSE

