''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''                                                                    '''
''' UDATE.MOO                  *** released to the public domain ***   '''
'''                                                                    '''
''' Originally by Rowan Crowe, Friday, 09-May-1997                     '''
'''   3:635/728@fidonet                                                '''
'''   rowan@sensation.net.au                                           '''
'''                                                                    '''
''' Similar to the UNIX 'date' command, except that this utility is    '''
''' exclusively for producing a formatted date as output; it does not  '''
''' allow resetting of the date or time.                               '''
'''                                                                    '''
''' example:  udate %A, %d-%b-%Y                                       '''
'''                                                                    '''
''' Requires MoonRock compiler v0.18 or higher:                        '''
'''   MRC udate/-m/-c                                                  '''
'''                                                                    '''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

begin def

#include datetime.h

dim dow$[7]
dim mon$[12]

pointer string retval~

sub strftime(retval~, s$)

#ifdef 0


Borrowed from the UNIX manpage for strftime(3)

NOTE: '---' means not yet implemented in this utility.

     %A    is replaced by national representation of the full weekday name.

     %a    is replaced by national representation of the abbreviated weekday
           name, where the abbreviation is the first three characters.

     %B    is replaced by national representation of the full month name.

     %b    is replaced by national representation of the abbreviated month
           name, where the abbreviation is the first three characters.

     %C    is replaced by (year / 100) as decimal number; single digits are
           preceded by a zero.

     %c    is replaced by national representation of time and date (the format
           is similar with produced by asctime(3)).

     %D    is equivalent to ``%m/%d/%y''.

     %d    is replaced by the day of the month as a decimal number (01-31).

---  %E*   POSIX locale extensions.  The sequences %Ec %EC %Ex %Ey %EY %Od %Oe
           %OH %OI %Om %OM %OS %Ou %OU %OV %Ow %OW %Oy are supposed to provide
           alternate representations.

     %e    is replaced by the day of month as a decimal number (1-31); single
           digits are preceded by a blank.

     %H    is replaced by the hour (24-hour clock) as a decimal number
           (00-23).

     %h    the same as %b.

     %I    is replaced by the hour (12-hour clock) as a decimal number
           (01-12).

---  %j    is replaced by the day of the year as a decimal number (001-366).

     %k    is replaced by the hour (24-hour clock) as a decimal number (0-23);
           single digits are preceded by a blank.

     %l    is replaced by the hour (12-hour clock) as a decimal number (1-12);
           single digits are preceded by a blank.

     %M    is replaced by the minute as a decimal number (00-59).

     %m    is replaced by the month as a decimal number (01-12).

     %n    is replaced by a newline.

---  %O*   the same as %E*.

---  %p    is replaced by national representation of either "ante meridiem" or
           "post meridiem" as appropriate.

     %R    is equivalent to ``%H:%M''.

     %r    is equivalent to ``%I:%M:%S %p''.

     %S    is replaced by the second as a decimal number (00-60).

---  %s    is replaced by the number of seconds since the Epoch, UTC (see
           mktime(3)).

     %T    is equivalent to ``%H:%M:%S''.

     %t    is replaced by a tab.

---  %U    is replaced by the week number of the year (Sunday as the first day
           of the week) as a decimal number (00-53).

     %u    is replaced by the weekday (Monday as the first day of the week) as
           a decimal number (1-7).

---  %V    is replaced by the week number of the year (the first Monday as the
           first day of week 1) as a decimal number (01-53).

     %v    is equivalent to ``%e-%b-%Y''.

---  %W    is replaced by the week number of the year (Monday as the first day
           of the week) as a decimal number (00-53).

     %w    is replaced by the weekday (Sunday as the first day of the week) as
           a decimal number (0-6).

---  %X    is replaced by national representation of the time.

---  %x    is replaced by national representation of the date.

     %Y    is replaced by the year with century as a decimal number.

     %y    is replaced by the year without century as a decimal number
           (00-99).

---  %Z    is replaced by the time zone name.

---  %+    is replaced by national representation of the date and time (the
           format is similar with produced by date(1)).

     %%    is replaced by `%'.

#endif


begin code

dow$[0] = "Sunday" : dow$[1] = "Monday" : dow$[2] = "Tuesday"
dow$[3] = "Wednesday" : dow$[4] = "Thursday" : dow$[5] = "Friday"
dow$[6] = "Saturday"

mon$[1] = "January" : mon$[2] = "February" : mon$[3] = "March"
mon$[4] = "April" : mon$[5] = "May" : mon$[6] = "June" : mon$[7] = "July"
mon$[8] = "August" : mon$[9] = "September" : mon$[10] = "October"
mon$[11] = "November" : mon$[12] = "December"

cmd$ = cmdline : cmd$ = ltrim(cmd$) : cmd$ = rtrim(cmd$)
if cmd$ = "" then cmd$ = "%c"
call strftime(varptr(t$), cmd$)
print t$
end


sub strftime(retval~, s$)
dummy$ = time
dummy$ = date
ptr% = cinstr(s$, 37)  '%'
while ptr% <> 0
  ptr% = ptr% - 1
  o$ = o$ + left(s$, ptr%)
  ptr% = ptr% + 2
  t$ = mid(s$, ptr%, 1)
  ptr% = ptr% + 1
  s$ = mid(s$, ptr%)
  select case t$    ' string used for readability
    case "%"
      o$ = o$ + "%"
    case "A"
      o$ = o$ + dow$[DATEBLK.dow@]
    case "a"
      o$ = o$ + left(dow$[DATEBLK.dow@], 3)
    case "B"
      o$ = o$ + mon$[DATEBLK.month@]
    case "b", "h"
      o$ = o$ + left(mon$[DATEBLK.month@], 3)
    case "C"
      t$ = str(DATEBLK.year%)
      o$ = o$ + left(t$, 2)
    case "c"
      s$ = "%a %b %e %H:%M:%S %Y"
    case "D"
      s$ = "%m/%d/%y" + s$
    case "d"
      t$ = str(DATEBLK.day@)
      if DATEBLK.day@ < 10 then t$ = "0" + t$
      o$ = o$ + t$
    case "e"
      t$ = str(DATEBLK.day@)
      if DATEBLK.day@ < 10 then t$ = " " + t$
      o$ = o$ + t$
    case "H"
      t$ = str(TIMEBLK.hour@)
      if TIMEBLK.hour@ < 10 then t$ = "0" + t$
      o$ = o$ + t$
    case "I"
      t% = TIMEBLK.hour@
      if t% > 12 then t% = t% - 12
      t$ = str(t%)
      if t% < 10 then t$ = "0" + t$
      o$ = o$ + t$
    case "l"
      t$ = str(TIMEBLK.hour@)
      if TIMEBLK.hour@ < 10 then t$ = " " + t$
      o$ = o$ + t$
    case "M"
      t$ = str(TIMEBLK.minute@)
      if TIMEBLK.minute@ < 10 then t$ = "0" + t$
      o$ = o$ + t$
    case "m"
      t$ = str(DATEBLK.month@)
      if DATEBLK.month@ < 10 then t$ = "0" + t$
      o$ = o$ + t$
    case "n"
      o$ = o$ + "\n"
    case "p"
      t% = TIMEBLK.hour@
      if t% = 12 then t% = 0
      if t% < 12 then
        o$ = o$ + "am"
      else
        o$ = o$ + "pm"
      endif
    case "R"
      s$ = "%H:%M" + s$
    case "r"
      s$ = "%I:%M:%S %p" + s$
    case "S"
      t$ = str(TIMEBLK.second@)
      if TIMEBLK.second@ < 10 then t$ = "0" + t$
      o$ = o$ + t$
    case "T"
      s$ = "%H:%M:%S" + s$
    case "t"
      o$ = o$ + "\t"
    case "u"
      if DATEBLK.dow@ = 0 then
        o$ = o$ + "7"
      else
        o$ = o$ + str(DATEBLK.dow@)
      endif
    case "v"
      s$ = "%e-%b-%Y" + s$
    case "w"
      o$ = o$ + str(DATEBLK.dow@)
    case "Y"
      o$ = o$ + str(DATEBLK.year%)
    case "y"
      t$ = str(DATEBLK.year%)
      o$ = o$ + right(t$, 2)
  end select
  ptr% = cinstr(s$, 37)  '%'
wend
[retval~] = o$
end sub
