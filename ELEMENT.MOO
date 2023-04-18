''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''' ELEMENT.MOO                *** released to the public domain ***   '''
'''                                                                    '''
''' Originally by Rowan Crowe, Thursday 26-Oct-1995                    '''
'''   3:635/728@fidonet                                                '''
'''   rowan@sensation.net.au                                           '''
'''                                                                    '''
''' Separates a source file into discrete elements such as variable    '''
''' names, commands, functions etc.  If output is redirected to a file '''
''' then sorted, mis-spelt variable names and other errors become      '''
''' immediately apparent.                                              '''
'''                                                                    '''
''' This is handy for languages which do not require strict variable   '''
''' declarations: BASIC, MoonRock etc.                                 '''
'''                                                                    '''
''' Requires MoonRock compiler:                                        '''
'''   MRC element/-m/-c                                                '''
'''                                                                    '''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

begin def

#include ffblk.h
#include mrc.h

  strsegsize 64k

' Sub LoadSource    ' Read the entire source file into memory
' Sub GetLine       ' Get a line from the source file
  Sub Block         ' Break up a line into discrete elements
  Sub Setup         ' General program initialisation
  Sub Element       ' Main section of code.

  %MaxElementRecords = 10000       ' If you change this you may run
                                   ' out of memory. :-)
  %DiscreteElementsPerLine = 200   ' Just a nice sounding number. Any
                                   ' line with more than 200 discrete
                                   ' variables/commands/keywords is,
                                   ' well, yeah.

  dim bp$[%DiscreteElementsPerLine]

  dim va$[%MaxElementRecords]

  common FMin%, inline$, bpp%, currentline%, Term$

begin code


''' ************************************************************* '''

call Setup
call Element
end(%EXIT_SUCCESS)


''' ============================================================= '''

sub Block
tmp$ = inline$
bpp% = 0
while tmp$ <> ""

  if bpp% > %DiscreteElementsPerLine then
    print "\nInternal error, or line contains more than "
    print %DiscreteElementsPerLine + " discrete elements.\n"
    print ": " + inline$ + "\n"
    end(%EXIT_FAIL)
  endif

  ptr% = sinstr(tmp$, Term$)
  if ptr% <> 0 then


    c% = sbyte(tmp$, ptr%) ' used again below
    if c% = 39 then exit while  ' comment

    ptr2% = ptr% - 1
    if ptr2% > 0 then
      bp$[bpp%] = left(tmp$, ptr2%)
      bpp% = bpp% + 1
    endif

    if c% <> 32 then       ' space
      bp$[bpp%] = mid(tmp$, ptr%, 1)
      bpp% = bpp% + 1
    endif

    ptr2% = ptr% + 1
    tmp$ = mid(tmp$, ptr2%)
    tmp$ = ltrim(tmp$)
    if c% = 34 then      '    "
      p% = cinstr(tmp$, 34)
      if p% <> 0 then
        p% = p% + 1
        tmp$ = mid(tmp$, p%)
      endif
    endif

  else

    bp$[bpp%] = tmp$
    bpp% = bpp% + 1
    tmp$ = ""

  endif

wend
bpp% = bpp% - 1
end sub

''' ============================================================= '''

Sub Setup

Term$ = " \h22'<>=+-*/(),[]:;"
''' These are the terminators we search for. \h22 is the " character

cmd$ = cmdline : cmd$ = ltrim(cmd$) : cmd$ = ucase(cmd$)

if cmd$ = "" then
  print "Element lister v0.02 [DOS], by Rowan Crowe. (PUBLIC DOMAIN)"
  print "\n\n  Usage:\n    ELEMENT <source filename>\n"
  end(%EXIT_SUCCESS)
endif

in$ = ftruename(cmd$)
if in$ = "" then
  print "*fatal*  Invalid filespec passed in commandline.\n"
  end(%EXIT_FAIL)
endif

if fexist (in$, 7) = FALSE then
  print "*fatal*  Specified source file not found: " + in$ + "\n"
  end(%EXIT_FAIL)
endif

FMin% = fopen(in$, readonly)

end sub


Sub Element

eof% = feof(FMin%)
while eof% = FALSE
  finput(FMin%, inline$)
  currentline% = currentline% + 1
  call Block
  if bpp% <> -1 then
    for i% = 0 to bpp%
      tmpbp$ = bp$[i%]
'''            ^^^^^^^
''' We could simply use bp$[i%] instead of tmpbp$ below, but
''' using an array variable is slower, so let's make a local copy.

      matched% = FALSE
      for z% = 0 to vaptr%
        if tmpbp$ = va$[z%] then
          matched% = TRUE
          exit for
        endif
      next
      if matched% = FALSE then
        print tmpbp$ + "\n"
        vaptr% = vaptr% + 1
        if vaptr% > %MaxElementRecords then
          print "\n\n\nout of element records (craaasssshhhhhhhhh)\n"
          end(%EXIT_FAIL)
        endif
        va$[vaptr%] = tmpbp$
      endif
    next
  endif
  eof% = feof(FMin%)
wend
print "\n\n  lines processed:   " + currentline%
print "\n  discrete elements: " + vaptr%
end sub
