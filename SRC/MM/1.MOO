begin def

common a%, b%, c%, d%, e%, a&, b&, c&, d&, a@, b@, c@, d@, a$, b$

sub fred1 ($, %, %, %, %, %)
sub fred2
sub fprint(%, %)
function hello%(%,%)
function f1%
function f2%
function f3%

begin code

fred1(((b% - 3) + (3-c%) + (a% + (c% - 2)) + (c% - 2)),((b%-2) + (5+d%) - (d%-5)), ((c%+4)+ 2), (a%+3), (b%+5), ((c% -2)+5) )

a% = c% * (5 + 3) - ((2 - d% + (e% * 3) * 5) + (c% * 2) + (e% - 2) - 3)
a% = 2 * (c% + 2)
a% = (c% + 2) * 2
a% = d% * (b% + 2 - (c% - 3))
fred1(a%-hello(a%,b%),f2 * f1,c%,d%,e%,a%)
fred1(a%-hello(a%,b%),f2 * f1,c%,f1 * hello(c%,d%),e%,a%)
fred1(a%*3+d%+((e%-5)+(c%+2)),b%,c%,d%,e%,a%)
print (c% * (5 + 3) - ((2 - d% + (e% * 3) * 5) + (c% * 2) + (e% - 2) - 3))
#include 3.moo
a% = 5
a& = b& * 3
