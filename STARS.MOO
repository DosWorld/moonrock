' STARS.MOO

' Rowan Crowe, 3:635/728@fidonet
' rowan@sensation.net.au

' Unconditionally released to the public domain

' Requires MoonRock v0.17 or higher:
'   MRC stars /-c /-m

begin def

%Pixel = 101
dim x%[%Pixel]
dim y%[%Pixel]

sub ProcessPlane(start1%, end1%, speed1%)

common FactorX%
common FactorY%

%Escape = 27
%Down   = 80
%Up     = 72
%Left   = 75
%Right  = 77

begin code


FactorX% = -60
FactorY% = 60

setgraphmode(6)
screen_dest% = getgraphseg
screen_source% = farmalloc(16384)
setgraphseg(screen_source%)
gcls

for i% = 0 to %Pixel
  x%[i%] = rand(6390)
  y%[i%] = rand(1990)
next

exitnow% = FALSE
while exitnow% = FALSE

  ti& = timertick
  if FactorX% > 0 then FactorX% = FactorX% - 1
  if FactorX% < 0 then FactorX% = FactorX% + 1
  if FactorY% > 0 then FactorY% = FactorY% - 1
  if FactorY% < 0 then FactorY% = FactorY% + 1

  if keystatus(%Left) = TRUE then FactorX% = FactorX% - 10
  if keystatus(%Right) = TRUE then FactorX% = FactorX% + 10
  if keystatus(%Up) = TRUE then FactorY% = FactorY% - 5
  if keystatus(%Down) = TRUE then FactorY% = FactorY% + 5

  if FactorX% > 60 then FactorX% = 60
  if FactorX% < -60 then FactorX% = -60
  if FactorY% > 60 then FactorY% = 60
  if FactorY% < -60 then FactorY% = -60

  call ProcessPlane(1, 20, 1)
  call ProcessPlane(21, 40, 2)
  call ProcessPlane(41, 60, 3)
  call ProcessPlane(61, 80, 4)

WaitRetrace:
@mov   dx,03DAh
@in    al,dx
@and   al,8
@je    __WaitRetrace

  farmemcopys(screen_source%, screen_dest%, 16350)

  t& = timertick
  while t& = ti&   ' set above
    t& = timertick
  wend

  k% = 0
  while k% <> - 1
    k% = inkey
    if k% = 27 then exitnow% = TRUE
  wend
wend
end


sub ProcessPlane(start1%, end1%, speed1%)
for i% = start1% to end1%
  tx% = x%[i%] \ 10
  ty% = y%[i%] \ 10
  putpixel(tx%, ty%, 0)

  t% = FactorX% * speed1%
  x%[i%] = x%[i%] + t%

  t% = FactorY% * speed1%
  y%[i%] = y%[i%] + t%

  if x%[i%] <= -1 then
    x%[i%] = 6390
    y%[i%] = rand(1990)
  endif
  if x%[i%] >= 6400 then
    x%[i%] = 0
    y%[i%] = rand(1990)
  endif
  if y%[i%] <= -1 then
    y%[i%] = 1990
    x%[i%] = rand(6390)
  endif
  if y%[i%] >= 2000 then
    y%[i%] = 0
    x%[i%] = rand(6390)
  endif

  tx% = x%[i%] \ 10
  ty% = y%[i%] \ 10
  putpixel(tx%, ty%, 1)

next
end sub
