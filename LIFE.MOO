''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''                                                                    '''
''' LIFE.MOO                   *** released to the public domain ***   '''
'''                                                                    '''
''' Originally by Rowan Crowe, Tuesday, 12-Mar-1996                    '''
'''   3:635/728.1@fidonet                                              '''
'''   rowan@sensation.net.au                                           '''
'''                                                                    '''
''' A variation on the popular game of "Life". There are 3 types of    '''
''' objects in this world:                                             '''
'''   1. A green dot is known as a Wanderer. These simply "wander"     '''
'''      and are not affected by anything else.                        '''
'''   2. A brown/yellow diamond is a Wimp. These run away from         '''
'''      anything which comes within a couple of cells of them.        '''
'''   3. A red dot known as a Parasite. These are more aggressive      '''
'''      and follow anything that is immediately close by. You will    '''
'''      often see a Parasite chasing a Wimp.                          '''
'''                                                                    '''
''' Note this is fairly sloppy coding. The objects also have a         '''
''' tendancy to creep to the top left hand corner due to the way that  '''
''' adjacent cells are checked.                                        '''
'''                                                                    '''
''' Requires MoonRock compiler v0.16 or higher:                        '''
'''   MRC life/-m/-c                                                   '''
'''                                                                    '''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

begin DEF

%Wanderer = 1               ' OK to change
%WandererStart = 0
%WandererEnd = %WandererStart + %Wanderer - 1

%Wimp = 20                  ' OK to change
%WimpStart = %WandererEnd + 1
%WimpEnd = %WimpStart + %Wimp - 1

%Parasite = 20               ' OK to change
%ParasiteStart = %WimpEnd + 1
%ParasiteEnd = %ParasiteStart + %Parasite - 1

%BallCount = %ParasiteEnd + 1

dim x%[%BallCount]           ' current ball x position
dim y%[%BallCount]           ' current ball y position

dim dx%[%BallCount]          ' direction to travel: -1, 0, 1
dim dy%[%BallCount]          '      "     "    "     "

sub Wanderer
sub Wimp
sub MoveWimp (i%)
sub Parasite
sub MoveParasite (i%)

begin CODE

$outstream _tty_str_direct

randomize(0)

colour ?,0
cls

@mov ah, 01h
@mov cx, 2000h
@int 10h
                             ' disable cursor.

for i% = %WandererStart to %WandererEnd
  x%[i%] = rand(78) + 1
  y%[i%] = rand(22) + 1

  dx%[i%] = 0
  while dx%[i%] = 0
    t% = rand(32000) - 16000
    dx%[i%] = sgn(t%)        ' -1, 0, +1
  wend

  dy%[i%] = 0
  while dy%[i%] = 0
    t% = rand(32000) - 16000
    dy%[i%] = sgn(t%)        ' -1, 0, +1
  wend
next

colour 6
for i% = %WimpStart to %WimpEnd
  x%[i%] = rand(76) + 2
  y%[i%] = rand(20) + 2
  cput(x%[i%],y%[i%], 4)
next

colour 12
for i% = %ParasiteStart to %ParasiteEnd
  x%[i%] = rand(73) + 3
  y%[i%] = rand(18) + 3
  cput(x%[i%],y%[i%], 7)
next

k% = -1
while k% = -1

  call Wanderer
  call Wimp
  call Parasite

  delay(1)

  k% = inkey

wend
if k% = 0 then k% = inkey    ' eat up extended keypress
colour 7,0
cls
@mov ah, 01h
@mov cx, 0607h
@int 10h

end(0)



sub Wanderer
colour 2
for i% = %WandererStart to %WandererEnd
  cput(x%[i%],y%[i%],32)

  x%[i%] = x%[i%] + dx%[i%]
  y%[i%] = y%[i%] + dy%[i%]

  cput(x%[i%],y%[i%], 249)

  if x%[i%] > 78 then
    t% = rand(5000) - 4000
    if t% < 0 then
      dx%[i%] = 0
    else
      dx%[i%] = -1
    endif
  endif
  if x%[i%] < 1 then
    t% = rand(5000) - 4000
    if t% < 0 then
      dx%[i%] = 0
    else
      dx%[i%] = 1
    endif
  endif
  if y%[i%] > 23 then
    t% = rand(5000) - 4000
    if t% < 0 then
      dy%[i%] = 0
    else
      dy%[i%] = -1
    endif
  endif
  if y%[i%] < 1 then
    t% = rand(5000) - 4000
    if t% < 0 then
      dy%[i%] = 0
    else
      dy%[i%] = 1
    endif
  endif

next
end sub


sub Wimp
colour 6
for i% = %WimpStart to %WimpEnd

' check matrix:
' x x x
' x * x
' x x x

  x% = x%[i%]
  y% = y%[i%]
  x_1% = x% - 1
  xp1% = x% + 1
  y_1% = y% - 1
  yp1% = y% + 1

  a% = cget(x_1%, y_1%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = 1
    dy%[i%] = 1
    call MoveWimp(i%)
  endif

  a% = cget(x%, y_1%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = 0
    dy%[i%] = 1
    call MoveWimp(i%)
  endif

  a% = cget(xp1%, y_1%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = -1
    dy%[i%] = 1
    call MoveWimp(i%)
  endif

  a% = cget(x_1%, y%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = 1
    dy%[i%] = 0
    call MoveWimp(i%)
  endif

  a% = cget(xp1%, y%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = -1
    dy%[i%] = 0
    call MoveWimp(i%)
  endif

  a% = cget(x_1%, yp1%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = 1
    dy%[i%] = -1
    call MoveWimp(i%)
  endif

  a% = cget(x%, yp1%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = 0
    dy%[i%] = -1
    call MoveWimp(i%)
  endif

  a% = cget(xp1%, yp1%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = -1
    dy%[i%] = -1
    call MoveWimp(i%)
  endif

next
end sub


sub MoveWimp(i%)
oldx% = x%[i%]
oldy% = y%[i%]
a% = 1
while a% <> 32

  x%[i%] = x%[i%] + dx%[i%]
  y%[i%] = y%[i%] + dy%[i%]

  if x%[i%] > 78 then x%[i%] = 78 : dx%[i%] = neg(dx%[i%])
  if x%[i%] < 1 then x%[i%] = 1   : dx%[i%] = neg(dx%[i%])
  if y%[i%] > 22 then y%[i%] = 22 : dy%[i%] = neg(dy%[i%])
  if y%[i%] < 1 then y%[i%] = 1   : dy%[i%] = neg(dy%[i%])

  a% = cget(x%[i%], y%[i%])
  a% = a% and 0FFh

wend
cput(oldx%,oldy%,32)
cput(x%[i%],y%[i%], 4)
end sub


sub Parasite
colour 12
for i% = %ParasiteStart to %ParasiteEnd

' check matrix:
' x x x x x
' x . . . x
' x . * . x
' x . . . x
' x x x x x

  x% = x%[i%]
  y% = y%[i%]

  x_1% = x% - 1
  xp1% = x% + 1

  y_1% = y% - 1
  yp1% = y% + 1

  x_2% = x% - 2
  xp2% = x% + 2

  y_2% = y% - 2
  yp2% = y% + 2

  a% = cget(x_2%, y_2%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = -1
    dy%[i%] = -1
    call MoveParasite(i%)
    'goto pskip
  endif

  a% = cget(x%, y_2%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = 0
    dy%[i%] = -1
    call MoveParasite(i%)
    'goto pskip
  endif

  a% = cget(xp2%, y_2%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = 1
    dy%[i%] = -1
    call MoveParasite(i%)
    'goto pskip
  endif

  a% = cget(x_2%, y%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = -1
    dy%[i%] = 0
    call MoveParasite(i%)
    'goto pskip
  endif

  a% = cget(xp2%, y%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = 1
    dy%[i%] = 0
    call MoveParasite(i%)
    'goto pskip
  endif

  a% = cget(x_2%, yp2%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = -1
    dy%[i%] = 1
    call MoveParasite(i%)
    'goto pskip
  endif

  a% = cget(x%, yp2%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = 0
    dy%[i%] = 1
    call MoveParasite(i%)
    'goto pskip
  endif

  a% = cget(xp2%, yp2%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = 1
    dy%[i%] = 1
    call MoveParasite(i%)
    'goto pskip
  endif


  a% = cget(x_1%, y_2%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = -1
    dy%[i%] = -1
    call MoveParasite(i%)
    'goto pskip
  endif

  a% = cget(xp1%, y_2%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = 1
    dy%[i%] = -1
    call MoveParasite(i%)
    'goto pskip
  endif

  a% = cget(x_2%, y_1%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = -1
    dy%[i%] = -1
    call MoveParasite(i%)
    'goto pskip
  endif

  a% = cget(xp2%, y_1%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = 1
    dy%[i%] = -1
    call MoveParasite(i%)
    'goto pskip
  endif

  a% = cget(x_2%, yp1%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = -1
    dy%[i%] = 1
    call MoveParasite(i%)
    'goto pskip
  endif

  a% = cget(xp2%, yp1%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = 1
    dy%[i%] = 1
    call MoveParasite(i%)
    'goto pskip
  endif

  a% = cget(x_1%, yp2%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = -1
    dy%[i%] = 1
    call MoveParasite(i%)
    'goto pskip
  endif

  a% = cget(xp1%, yp2%)
  a% = a% and 0FFh
  if a% <> 32 then
    dx%[i%] = 1
    dy%[i%] = 1
    call MoveParasite(i%)
    'goto pskip
  endif
pskip:
next
end sub


sub MoveParasite(i%)
oldx% = x%[i%]
oldy% = y%[i%]
a% = 1
while a% <> 32

  x%[i%] = x%[i%] + dx%[i%]
  y%[i%] = y%[i%] + dy%[i%]

  if x%[i%] > 77 then x%[i%] = 77 : dx%[i%] = neg(dx%[i%])
  if x%[i%] < 2 then x%[i%] = 2   : dx%[i%] = neg(dx%[i%])
  if y%[i%] > 22 then y%[i%] = 22 : dy%[i%] = neg(dy%[i%])
  if y%[i%] < 2 then y%[i%] = 2   : dy%[i%] = neg(dy%[i%])

  a% = cget(x%[i%], y%[i%])
  a% = a% and 0FFh

wend
cput(oldx%,oldy%,32)
cput(x%[i%],y%[i%], 7)
end sub
