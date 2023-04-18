''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''                                                                    '''
''' CALC.MOO                   *** released to the public domain ***   '''
'''                                                                    '''
''' Originally by Rowan Crowe, released Friday 30-Aug-1996             '''
'''   3:635/728@fidonet                                                '''
'''   rowan@sensation.net.au                                           '''
'''                                                                    '''
''' Demonstrates a simple recursive calculation method.  Used in the   '''
''' development of the new MoonRock compiler.  Based on a program by   '''
''' Andrew Bromage.                                                    '''
'''                                                                    '''
''' Features operator precedence and order of evaluation.  Returns     '''
''' identical results to QBasic/QuickBASIC.                            '''
'''                                                                    '''
''' Requires MoonRock compiler v0.15 or higher:                        '''
'''   MRC calc/-m/-c                                                   '''
'''           or                                                       '''
'''   MRC calc/-m/-c !DEBUG                                            '''
'''                                                                    '''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

begin def

stack 4k

%BPLIMIT = 512        ' max number of discrete elements: convenient number
dim bp$[%BPLIMIT]
dim bpt%[%BPLIMIT]

%NUMBER = 0           ' digit 0-9
%OPERATOR = 1         ' + - / *
%BRACKET = 3          ' (

pointer word ptr1~
pointer word ptr2~
pointer word ptr3~

common bpp%, bpptr%, negflag%

sub Parse(t$)
sub Evaluate(t$)
sub AddSubtract(ptr1~)
sub DivideMultiply(ptr2~)
sub Bracket(ptr3~)

begin code


print "enter expression: "
input(exp$, 200)
print "\n"
call Evaluate(exp$)
#ifdef DEBUG
  s% = unusedstack
  print "unused stack space=" + s% + "\n"
#endif
end


sub Evaluate(t$)
call Parse(t$)
#ifdef DEBUG
  for i% = 0 to bpp%
    print bp$[i%] + "ú"
  next
  print "\n"
#endif

bpptr% = 0
answer% = 0  ' just for completeness

while bpptr% <= bpp%
  call AddSubtract(varptr(answer%))
wend

print "answer is: " + answer% + "\n"
end sub


#preserve
sub AddSubtract(ptr1~)
#ifdef DEBUG
  print "as, token=" + bpptr% + ", work=" + [ptr1~] + "\n"
#endif
t% = 0 : call DivideMultiply(varptr(t%))
[ptr1~] = t%
if bpptr% > bpp% then
  #ifdef DEBUG
    print "return="+ [ptr1~] + "\n"
  #endif
  exit sub
endif
r% = sinstr(bp$[bpptr%], "+-")
while r% <> 0
  if bp$[bpptr%] = "+" then
    bpptr% = bpptr% + 1
    t% = 0 : call DivideMultiply(varptr(t%))
    #ifdef DEBUG
      print "add " + [ptr1~] + "+" + t% + "\n"
    #endif
    [ptr1~] = [ptr1~] + t%
  else
    bpptr% = bpptr% + 1
    t% = 0 : call DivideMultiply(varptr(t%))
    #ifdef DEBUG
      print "sub " + [ptr1~] + "-" + t% + "\n"
    #endif
    [ptr1~] = [ptr1~] - t%
  endif
  r% = sinstr(bp$[bpptr%], "+-")
wend

#ifdef DEBUG
  print "return="+ [ptr1~] + "\n"
#endif
end sub


#preserve
sub DivideMultiply(ptr2~)
#ifdef DEBUG
  print "  dm, token=" + bpptr% + ", work=" + [ptr2~] + "\n"
#endif
t% = 0 : call Bracket(varptr(t%))
[ptr2~] = t%
if bpptr% > bpp% then
  #ifdef DEBUG
    print "  return=" + [ptr2~] + "\n"
  #endif
  exit sub
endif
r% = sinstr(bp$[bpptr%], "*/")
while r% <> 0
  if bp$[bpptr%] = "*" then
    bpptr% = bpptr% + 1
    t% = 0 : call Bracket(varptr(t%))
    #ifdef DEBUG
      print "  mul " [ptr2~] + "*" + t% + "\n"
    #endif
    [ptr2~] = [ptr2~] * t%
  else
    bpptr% = bpptr% + 1
    t% = 0 : call Bracket(varptr(t%))
    #ifdef DEBUG
      print "  div " + [ptr2~] + "/" + t% + "\n"
    #endif
    [ptr2~] = [ptr2~] \ t%
  endif
  r% = sinstr(bp$[bpptr%], "*/")
wend
#ifdef DEBUG
  print "  return=" + [ptr2~] + "\n"
#endif
end sub


#preserve
sub Bracket(ptr3~)
if bpptr% > bpp% then exit sub
#ifdef DEBUG
  print "    b, token=" + bpptr% + ", work=" + [ptr3~] + "\n"
#endif

negjump:

select case bpt%[bpptr%]
  case %NUMBER
    [ptr3~] = val(bp$[bpptr%])
    if negflag% = TRUE then
      [ptr3~] = neg([ptr3~])
      negflag% = FALSE
    endif
    bpptr% = bpptr% + 1
  case %BRACKET
    #ifdef DEBUG
      print "    '(' bracket\n"
    #endif
    bpptr% = bpptr% + 1
    t% = 0 : call AddSubtract(varptr(t%))
    [ptr3~] = t%
    if bp$[bpptr%] <> ")" then
      print "syntax error: expected ')'\n"
      end
    endif
    bpptr% = bpptr% + 1
  case else
    ' handle negative numbers
    if bp$[bpptr%] = "-" then
      if negflag% = FALSE then
        bpptr% = bpptr% + 1
        negflag% = TRUE
        goto negjump
      else
        ' too many '-'s
        print "syntax error: unexpected token '" + bp$[bpptr%] + "' (too many negates)\n"
       end
      endif
    else
      print "syntax error: unexpected token '" + bp$[bpptr%] + "'\n"
      end
    endif
end select

#ifdef DEBUG
  print "    return=" + [ptr3~] + "\n"
#endif
end sub


sub Parse(t$)
bpp% = 0

if t$ = "" then exit sub

while t$ <> ""
  ptr% = sinstr(t$, " +-/*()")   ' Search for next terminator
  if ptr% <> 0 then

    if ptr% > 1 then
      ptr2% = ptr% - 1
      bp$[bpp%] = left(t$, ptr2%)
      bpt%[bpp%] = %NUMBER
      bpp% = bpp% + 1

      c% = sbyte(t$, ptr%)
      if c% <> 32 then
        bp$[bpp%] = chr(c%)
        bpt%[bpp%] = %OPERATOR
        if c% = 40 then bpt%[bpp%] = %BRACKET
        bpp% = bpp% + 1
      endif

    else
      c% = asc(t$)
      if c% <> 32 then
        bp$[bpp%] = chr(c%)
        bpt%[bpp%] = %OPERATOR
        if c% = 40 then bpt%[bpp%] = %BRACKET
        bpp% = bpp% + 1
      endif

    endif

    ptr2% = ptr% + 1
    t$ = mid(t$, ptr2%)

  else

    bp$[bpp%] = t$
    bpp% = bpp% + 1
    t$ = ""

  endif

wend
bpp% = bpp% - 1
end sub
