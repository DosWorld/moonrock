@echo off
rem   Makes the ASM library MOONROCK.ALB and compiles MOONROCK.PTR
cd lib
combine
local
cd ..
lc
del lib\moonrock.alb
