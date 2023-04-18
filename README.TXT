                Moonrock Version 0.50 Beta Release
                =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


A PERSONAL NOTE FROM THE AUTHOR
-------------------------------

This is probably the last major release of MoonRock. My life has been
busy with other things, especially as I'm now working more than full
time running my own internet service provider. Over the past couple of
years the focus of my programming has gradually moved away from DOS, and
more to unix. I program mainly in sh (like a DOS batch file on a severe
dose of steroids, very powerful) and a little C.

I still do a bit of DOS programming here and there, and my main
workstation still runs DOS; however, it's used mainly for telnetting to
my unix servers!

I am still interested in compiler technology and in fact recently
developed an ultra simple language and compiler in a couple of weekends.
It's written in MoonRock and it's less than 1,000 lines source/15k
executable. It looks a little more like C than BASIC, but the general
philosophy is to have as few "built in" commands and functions as
possible, to a) make the compiler more simple and b) make the standard
library routines more flexible. By abstracting the language and not
specifically including DOSish type things like "near" and "far", I can
also make it more portable between operating systems and even
processors. Only small porting changes need to be made to the standard
library and "glue" functions, instead of rewriting the entire library
from scratch in assembler. MoonRock has about 100k/7200 lines of
assembler, and that's with the comments and other extraneous fields
stripped out.

My dream:

I'm not too advanced when it comes to C, so perhaps one day the new
compiler I've developed will spit out a *.s file (using 32 bit code and
registers) that can be assembled by gcc on a unix machine, or a z80
format ASM file to be used on my embedded z80 network monitor that I'm
currently building.

Back to MoonRock.

I'm sure many of you know how difficult it is to come back to a program
after even a month, and try to work out exactly how it works. The 6
*.BAS files that comprise MoonRock total almost 280k/10,000 lines, so
whilst it's not a huge project, it is not exactly a simple one. As a
"hobby" programmer my documentation and general planning skills are
pretty lacking, so it's quite easy to lose track of things. Plus, there
is also the problem that MoonRock has become a huge monster full of
kludges and exceptions, rather than a compiler designed from the ground
up with a few optimisations here and there.

I still do some work on MoonRock when I get a bug report, often they are
simple bugs which are easily fixed. I also add functions here and there
as I need them in my own programming. However, I have not done any major
new additions to MoonRock for quite some time, and I don't see there
being a great future for it in terms of active development.

I'm releasing this version as v0.50, to show it's a significant release
(significant because it's probably the last, rather than being
significantly better than v0.17 apart from the bugfixes), plus as a kind
of joke - it's half (0.5) finished.

Thank you all for your support of MoonRock! You can still contact me by
email or fidonet netmail if you have any queries.


Rowan Crowe, 3:635/728.1@fidonet
             rowan@sensation.net.au
             http://www.rowan.sensation.net.au/


PLEASE NOTE
-----------
This is a Beta release, and will most likely have bugs.

It is far from complete. Please do not expect it to perform like
commercial compilers.

The compiler has several quirks which cannot be easily fixed without a
rewrite from scratch (which is now happening). Please see MR-REF.DOC for
hints on how to bypass these quirks.

           *** MoonRock is proudly "Australian Made" ***


FIRST TIME USERS
----------------
If you do not have an existing assembler on your system, unzip
ARROWSOFT.ZIP. This file contains the ArrowSoft "public domain"
assembler. It is a little slow, and does not support 186+ instructions,
but it is adequate.

If you have TASM, MASM, or A86 already, then unzip CONFIG.ZIP, and
rename the appropriate CFG file to MRC.CFG. Edit MRC.CFG if desired.

No further setting up or configuration is required.


New features for v0.18
----------------------

* CHDIR/RMDIR/MKDIR/FRENAME

* Support for STRUCs and TYPEs

* MALLOC/MFREE/MSIZE/PREALLOC near memory functions

* INT86/INT86X software interrupt



New features for v0.17
----------------------

* A new set of FOSSIL functions added. These allow access to more than
  one serial port at a time. They are prefixed with "M" (eg: FOSINIT
  becomes MFOSINIT). These functions use a handle to specify the
  intended destination or source. Please see MR-REF.DOC for more
  information.


* Redundant segment register reloads reduced: many functions use code to
  save ES, load ES with the value of DS, then restore ES at the end of
  the function. If the compiled code does not use ES, then this extra
  code is now excluded. Under most circumstances ES will only be used by
  the compiled code if you have FAR or HUGE arrays or pointers.

  Example: LISTF.COM is just under 100 bytes smaller.


* New commandline switch:   /S  Compile for speed

  This option will compile for maximum speed, at the expense of size. By
  default MoonRock will compile for smallest size.

  NOTE: prior versions of MoonRock compromise between size and speed,
  but generally favour smaller size. However, some programs may have a
  noticeable slow down when compiled with the newer version, especially
  those with a lot of string manipulation, since by default MoonRock now
  generates the smallest possible executable. In this case, the /S
  switch should solve this problem.


* When compiled as a DPMI (386+) executable, HUGE pointers now use a 32
  bit register with a flat address space. Note this can be used to
  address 0-1023k contiguously (depending on your DPMI host, it may be
  possible to address memory above the 1Mb mark directly). Previously a
  DPMI executable with huge pointers would cause an exception error.


* RAND() will now return an identical sequence of numbers at each run of
  your program. To seed the random number generator, use RANDOMIZE(<value>)
  where <value> is a doubleword number between -2,147,483,648 and
  +2,147,483,647. If <value> is 0, then the value of the timer tick
  counter is used. For most programs it is probably not desirable to
  have an identical sequence of "random" numbers returned. Place the
  following command in your program before using RAND()

     randomize(0)

  NOTE: Do not reseed the random number generator before each call to
        RAND() -- it only needs to be done once.


New features for v0.16.b0
-------------------------

* A fairly major bungle by myself: MOONROCK.ALB and MOONROCK.PTR were
  not included in the release archive for MR v0.15. The older versions
  of these files *should* work, but the use of any new functions or
  commands will result in an unresolved library reference error.

  I am releasing another full archive to prevent problems with people
  having to pick up a supplementary file for v0.15. My apologies to
  those inconvenienced -- hopefully I have caught it before the file has
  become available for FTP.


* STARS.MOO included to wet your appetite. Graphics are far from
  complete, but this sample program should compile correctly.


* FW.MOO is another sample program included with this release.


New features for v0.15.b0
-------------------------

* Strings may now be used in a SELECT CASE..CASE..END SELECT block.


* Several new functions and commands added. See MR-REF.DOC.


* Lots of bugfixes, too numerous to list.


* MRHELP.COM included in this release. It is a simple menu-based system
  which allows you to view the command reference in MR-REF.DOC
  interactively.


* BYTE support added to most commands and functions. Previously there
  was little support for BYTE size variables.


* Pointers added. These are still in their infancy. A brief explanation
  is available under the POINTER definition keyword in MR-REF.DOC.


* A couple more sample programs added.


* The memory manager has been rewritten from scratch, utilising linked
  lists to keep track of memory blocks. Allocation times are similar
  to the previous manager, however deallocation is several times
  faster. An example, filling 2,000 array string variables, then
  clearing them:

    MoonRock v0.14 memory manager
        Fill:  37 ticks (2.1 sec)
        Clear: 44 ticks (2.4 sec)
        Total: 81       (4.5 sec)

    MoonRock v0.15 memory manager
        Fill:  31 ticks (1.7 sec)
        Clear: 1 tick   (0.05 sec)
        Total: 32       (1.75 sec)


*  "#include <file>" directive added. This will include <file> as if it
   was part of the current source file. This is handy for DEF or CODE
   which is common between programs. See MR-REF.DOC for more
   information.


*  Constant definitions in the BEGIN DEF area can now be evaluated with
   simple math { - + * / } and other constants. Example:

     %Constant1  = 55
     %Constant2  = 20
     %MyConstant = %Constant1 + 2 - %Constant2 ' Value of
                                               ' %MyConstant is 37


* Some statistics as of this release.

  Keywords:              164
  ASM library functions: 190


New features for v0.14.b0
-------------------------

* Trash register bugs fixed with ASM functions _delay and _mul32


* Inline ASM will accept a MoonRock variable name as referenced in the
  MoonRock source rather than the format it appears in the ASM output
  file. Example:

    @mov  ax, ds:[myvar%]

  ... is converted in the output ASM file to something like:

    @mov  ax, ds:[w_0@MYVAR]

  Prior versions of MoonRock required you to specify the variable name
  exactly as it was referenced in the ASM output, which caused problems
  when the order of SUBs was rearranged.

  Note: Take care not to use confusing variable names with your inline
  ASM. The following will confuse MoonRock:

    @mov  ax, ds:[__my$var]
    @__my$var: dw ?

  "__my$var" will be misinterpreted as a MoonRock variable with the
  name "__my$"


* Flashing colours are now supported with the _tty_str_direct screen
  driver. Foreground colours between 16-31 are the equivalent of 0-15,
  but flashing. It is not possible to have a background flashing colour.


* Nesting checking added. If MoonRock finds an unexpected nesting
  statement, it will warn you. For example, if your code is in an
  IF/THEN nest, and the compiler comes across a "WEND":

    while a% < 20
      if a% = 2 then
        print "a% is 2!"
      a% = a% + 2
    wend            ' ENDIF expected
      endif         ' We accidentally put the ENDIF here

  Prior versions of the compiler will compile a file with globally even
  nesting statements (same number of FOR and NEXT statements, same
  number of WHILE and WEND statements etc), even if they are incorrectly
  nested such as the example above. This can produce strange results at
  runtime.


* Input text line from file function added. Format:

    finput(handle%, l$)


* Bug with FOSINIT and TASM/MASM interpretation of code fixed.


* The function to process null strings in bundles returned an incorrect
  pointer when an empty string was converted. This bug would go
  un-noticed 99% of the time due to the incorrect pointer actually
  pointing to an equivalent null string.


* Some minor changes made to the memory manager code. For programs which
  have a lot of allocated memory (such as an string array with 1000
  elements), this will result in faster execution.


* Some statistics as of this release.

  Keywords:              134
  ASM library functions: 160


New features for v0.13.b0                        Released 05-Sep-1995
-------------------------

* DOSERR psuedovariable added. If you compile with the /R switch, your
  MoonRock executable will not abort when a DOS error occurs; instead it
  will set the psuedovariable DOSERR for you to interrogate. After each
  operation which may produce a DOS error (such as fopen, fcreate,
  farmalloc), you *must* check DOSERR for a non zero value. Example:

    handle% = fopen("c:\\command.com", readonly)
    if doserr <> 0 then
      print "DOS error " + doserr + " occurred."
      end(1)
    endif

  Note: Failure to act after a DOS error has occurred will have
  unpredictable results.

  MoonRock internally generated errors are considered fatal and will
  cease execution of program.


* SELECT CASE...CASE...[CASE ELSE]...END SELECT added. This is
  equivalent to the MicroSoft BASIC format, except that only numerical
  variables are permitted as the "SELECT CASE" parameter. Numerical
  constants or variables can be used as the "CASE" parameter. Example:

    select case a%
      case 1
        print "a% is 1!"
      case 2
        print "a% is 2!"
      case 3,4,5
        print "a% is 3, 4, or 5!"
      case else
        print "I don't know what a% is."
    end select


* DPMI protected mode code generation added (/P). MRC can create a DPMI
  compatible executable which runs in protected mode. Good for programs
  which use a lot of far memory (the new MoonRock compiler is an example
  of such a program). Support for linear/protected mode arrays plus
  total string memory larger than 64k will be provided in a future
  release.

  Some library functions are not yet fully DPMI compliant and will cause
  an exception error (which should be handled gracefully by the host).
  Please report any such strange results to the author.

  Currently known DPMI broken functions:

     1. ftruename
     (end of list)

  Using the /P switch explicitly forces the following switches:

     /-C   Exclude critical error handling
     /3    386+ code generation


* New IF...THEN statement format added. You may now include IF...THEN
  and the conditionally executed code on the same line. Successive
  IF...THEN statements may be "stacked" onto the same line.

    IF (expression) THEN (conditional code)

  Examples:

    if a% <> 2 then print "a% is not 2!"

    if a% >= 2 then if a% <= 4 then print "a% is between 2 and 4"

  Note that ELSE cannot be used with this format, and ENDIF is not
  required.


* Statements may be "stacked" onto a single line if they are separated
  by a colon ':' character.

  Examples:

    print "Hello.\n" : a% = a% * 3
    if f% = TRUE then print "File exists" : call loadfile : end(1)


* Output ASM and library functions now use TABs instead of spaces for
  neater spacing and smaller files (faster assembly!)


* Creation of EXE (/E) cleaned up. Startup code is entirely different
  for an EXE as are several other parts of the runtime code and library.
  String constants are stored in a separate segment, as is the stack.
  Therefore there can be up to 64k code, 64k data, 64k string constants,
  64k stack in a MoonRock EXE type executable (Note that in practice the
  latter 2 are unlikely to ever get anywhere near 64k).

  COMs are limited to 64k code+string constants+stack, 64k data.


* MRC's 64k input file size restriction removed, due to removal of
  internal buffering which was causing MRC to misbehave. Input file is
  now read line by line.


* Limited FOSSIL (Fido/Opus/SEAdog Standard Interface Layer) functions
  added:

    fosinit               Initialise FOSSIL
    fosdeinit             Deinitialise FOSSIL
    fostx                 Transmit string
    fosflush              Flush serial output buffer
    foscarrier            Determine carrier present/lost
    fosdatawaiting        Determine data waiting/not waiting
    fosgetchar            Get character from serial input buffer

  See MR-REF.DOC for more information.


* Conditional code compilation using #IFDEF/#IFNDEF added. Conditions
  may be specified in the commandline preceded by an exclamation mark
  '!', for example:

    mrc mm/p !dpmi !debug

  There should be a leading and trailing space between conditional
  keywords.

  #IFDEF (If DEFined) or #IFNDEF (If Not DEFined) and #ENDIF are placed
  around the code to be conditionally compiled.

  Examples:

    #ifdef 386
      if not is386 then
        print "This executable requires a 386+ processor.\n"
        end(1)
      endif
    #endif
    #ifdef dpmi
      print "ACME program v1.00 [DPMI]\n"
    #endif
    #ifndef dpmi
      print "ACME program v1.00 [DOS]\n"
    #endif

  Note that #IFDEF/#IFNDEF/#ENDIF cannot be nested, nor does an #ELSE
  directive exist.


* Numerical constants may be defined in the BEGIN DEF area, in the form:

    %<name> = <value>

  They are then referenced as %<name> throughout the code. Note that
  numerical constants are global.

  Example:

    begin def

      %MaxLines   = 20

    begin code

      for i% = 1 to %MaxLines
        print repstr("*", 78) + "\n"
      next

* Some statistics as of this release.

  Keywords:              121
  ASM library functions: 150


New features for v0.12.b0                        Released 15-Aug-1995
-------------------------

* MASM/TASM support added. The output of MRC is now in "generic MASM"
  format, so MASM, TASM, and clones should be able to directly assemble
  it. The ArrowSoft assembler is included with this release; it is a
  freeware assembler. A86 is no longer distributed with MoonRock. Also
  included is MRLINK convert the OBJ output of the ArrowSoft assembler
  to a COM file.

  Note that there may still be parts of the ASM library that have not
  been properly converted to generic MASM format. Please inform the
  author of any assemble errors which appear to be due to the library
  functions.

* Configuration file added. You can now configure the program and
  parameters to execute for: assembling COM, assembling EXE, linking
  COM, linking EXE.

  See archive CONFIG.ZIP and CFG.ZIP within for explanation of sample
  configuration files.

* MRC.EXE will now look for MRC.CFG, MOONROCK.PTR, MOONROCK.ALB in the
  directory it was executed from. Therefore, you can place MRC.EXE and
  the above 3 files in any directory in your PATH, and compile files
  from any directory.

* 386+ code generation added. For several mathematical operations,
  particularly those using doublewords/longs, 32 bit registers will be
  used. Note: The ArrowSoft assembler does not support 186+ or 386+
  instructions.

* Several bugs with numeric functions fixed. Under certain circumstances
  the function call was ignored totally, but the resultant ASM file
  still assembled faultlessly. It was only possible to see the problem
  by looking at the compiled ASM output directly.

* Bug with str() with a doubleword/long as a parameter fixed.

* farmemresize() command was incorrectly documented as a function. Please
  refer to MR-REF.DOC for correct usage.

* Memory usage for MRC.EXE is slightly less so bigger files can be
  compiled.

* Memory allocation errors (such as insufficient memory) during runtime
  initialisation of a compiled executable are now trapped appropriately.


New features for v0.11.b0                        Released 09-Aug-1995
-------------------------

* MAJOR CHANGE: Please see reference for "COMMON" keyword in MR-REF.DOC.
  Several existing programs will need to be modified.

* This release has been compiled with QuickBASIC rather than VB/DOS. It
  is almost twice as fast, but will run out of memory more quickly for
  large (500+ lines) programs.

* Some new commands added; see MR-REF.DOC

* HUGE arrays added: these can use all available conventional memory and
  can support more than 32768 elements.

* Array bounds checking added. When compiling with the /D option, every
  array access will be checked to ensure that an illegal element is not
  accessed.

* Language dependent SUB/FUNCTION production added. MoonRock can be
  interfaced and linked directly with QuickBASIC programs.

* Limited support added for strings in bundles. You can read them, but
  not write them.

* More detailed command documentation written.

* Bug with instr(), space() and null() functions fixed.


New features for v0.10.b0                        Released 16-Jul-1995
-------------------------
* LISTF.MOO included as a new sample program.

* Some new commands added. See end of MR-REF.DOC.

* Bug with comments in BEGIN DEF area fixed.

* Bug with _str_release function fixed.

* Bug with mixed case SUB names fixed.

* 32 bit for/next support added.

* Bug with 386+ parallel function plugging fixed.

* Bug with fopen() READONLY access mode parameter being ignored fixed.


New features for v0.09.b3                        Released 19-Jun-1995
-------------------------
* Several new commands added, see MR-REF.DOC.

* Array support added. See MR-REF.DOC for more information.

* 32 bit multiplication, 32 bit compare (eg: a& < 643792) added.

* Several optimisations added. Where possible MoonRock will use a
  register rather than load from memory. This is still incomplete, so
  there will still be blatantly obvious optimisations that MoonRock
  misses.

  Compile normally and then with the /-O switch to compare.

* Lots of general bugfixes. Some severe memory allocation bugs fixed.






General
-------
Information on the commands and functions available can be found in
MR-REF.DOC

MoonRock and DOS error numbers are in ERROR.LST

Running MRC.EXE without any arguments produces a brief help display.


