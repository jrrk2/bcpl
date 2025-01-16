// (c)  Copyright:  Martin Richards  30 April 2014

SECTION "WRITEF"

GET "libhdr"

LET clihook() = start()

LET start() BE
{
writen(-12345)
nl()
writen(42)
nl()
writef("goodbye %D *n", 42)
writes("finish*n")
FINISH
}

AND wrc(ch) BE sys(11,ch)   //wrch(ch)

AND nl() BE wrc('*n')

AND sardch() = sys(Sys_sardch)

AND sawrch(ch) = sys(Sys_sawrch,ch)

AND writed(n, d) BE writedz(n, d, FALSE, n<0)

AND writez(n, d) BE writedz(n, d, TRUE,  n<0)

AND writedz(n, d, zeroes, neg) BE
{ LET t = VEC 10
  LET i = 0
  LET k = -n

  IF neg DO { d := d - 1; k := n }

  { t!i := -(k MOD 10)
    k   := k/10
    i   := i + 1
  } REPEATWHILE k

  IF neg & zeroes DO wrc('-')
  FOR j = i+1 TO d DO wrc(zeroes -> '0', '*s')
  IF neg & ~zeroes DO wrc('-')
  FOR j = i-1 TO 0 BY -1 DO wrc(t!j+'0')
}

AND writen(n) BE writed(n, 0)

AND writehex(n, d) BE 
{ IF d>1 DO writehex(n>>4, d-1)
  wrc((n&15)!TABLE '0','1','2','3','4','5','6','7',
                    '8','9','A','B','C','D','E','F')
}

AND writeoct(n, d) BE
{ IF d > 1 DO writeoct(n>>3, d-1)
  wrc((n&7)+'0')
}

AND writebin(n, d) BE
{ IF d > 1 DO writebin(n>>1, d-1)
  wrc((n&1)+'0')
}

AND writes(s) BE
{ // UNLESS 0 < s < rootnode!rtn_memsize DO s := "##Bad string##"
  FOR i = 1 TO s%0 DO wrc(s%i)
}

AND writet(s, d) BE
{ writes(s)
  FOR i = 1 TO d-s%0 DO wrc('*s')
}

AND writeu(n, d) BE
{ LET m = (n>>1)/5
  IF m DO { writed(m, d-1); d := 1 }
  writed(n-m*10, d)
}

/*
        The following routines provide and extended version of writef.
They support the following extra substitution items:

        1. %F   - Takes next argument as a writef format string and
                calls writef recursively using the remaining arguments.
                The argument pointer is positioned to the next available
                argument on return.

        2. %M   - The next argument is taken as a message number and processed
                as for %F above. The message format string is looked up by
                get_text(messno, str, upb) where str is a vector local to
                writef to hold the message string. This is provided to easy
                the generation of messages in different languages.

        3. %+   - The argument pointer is incremented by 1.

        4. %-   - The argument pointer is decremented by 1.

        5. %P   - Plural formation. The singular form is use if and only if
                the next argument is one. So that the argument can be used
                twice it is normal to preceed or follow the %P item with %-.
                There are two forms as follows:

                a. %Pc  - The character c is output if the the next argument
                        not one.

                b. %P\singular\plural\  - The appropriate text is printed,
                        skipping the other. The '\' chars are not printed.

Example: FOR count = 0 TO 2 DO
            writef("There %p\is\are\ %-%n thing%-%ps.*n", count)
outputs:
         There are 0 things.
         There is 1 thing.
         There are 2 things.

        6. %nOp  eg %12i as an alternative to %iB
                 where n is a decimal number and Op is a format letter
                 expecting a field width. If n is given it specifies the
                 field width otherwise it is specified, as before, by the
                 single character (0-9, A-Z) following Op.

        7. %n.md  eg %8.2d
                  print a fixed point scaled decimal number in a field
                  width of n with m digits after the decimal point. For
                  example writef("%8.2d", 1234567) would output: 12345.67
                  and     writef("%8.0d", 1234567) would output:  1234567

        8. %#     Write the next argument using codewrch, ie convert the
                  next argument to UTF-8 format.
*/

// The following version of writef is new -- MR 21/1/04

// get_textblib and get_text have the same global variable number
AND get_textblib(n, str, upb) = VALOF  // Default definition of get_text
                                       // This is normally overridden 
                                       // by get_text, defined elsewhere.
{ LET s = "<mess:%-%n>"
  IF upb>s%0 DO upb := s%0
  str%0 := upb
  FOR i = 1 TO upb DO str%i := s%i
  RESULTIS str
}

AND writef(format,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) BE
{ LET nextarg = @a
  write_format(format, @nextarg)
}

AND sawritef(format,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) BE
{ LET nextarg = @a
  LET wrch, rdch = wrc, rdch
  wrch, rdch := sawrch, sardch
  write_format(format, @nextarg)
  wrch, rdch := wrc, rdch
}

AND write_format(format, lvnextarg) BE
{ // writef and sawritef must preserve result2
  LET res2 = result2

  writes("write_format called*n")
  
  FOR p = 1 TO format%0 DO
  { LET k, type, f, n, m, arg = format%p, ?, ?, ?, ?, ?
    LET widthgiven = FALSE
    nl()
    writen(p)
    wrc(' ')
    UNLESS k='%' DO { wrc(k); LOOP }

    // Deal with a substitution item
    p := p + 1
    type, arg, n, m := format%p, !!lvnextarg, 0, 0
    wrc(type)
    writen(arg)

sw: SWITCHON capitalch(type) INTO
    { DEFAULT:    wrc(type)
                  LOOP

      CASE '0':CASE '1':CASE '2':CASE '3':CASE '4':
      CASE '5':CASE '6':CASE '7':CASE '8':CASE '9':
                  { n := 10*n + type - '0'
                    p := p+1
                    type := format%p
                    widthgiven := TRUE
                  } REPEATWHILE '0'<=type<='9'
                  IF type='.' DO
                  { p := p+1
                    type := format%p
                    WHILE '0'<=type<='9' DO
                    { m := 10*m + type - '0'
                      p := p+1
                      type := format%p
                    }
                  }
                  GOTO sw

      CASE 'D':   IF m DO
                  { // Write a scaled number of the form nnn.nn
                    LET scale = 1
                    FOR i = 1 TO m DO scale := scale * 10
                    writedz(arg/scale, n-1-m, FALSE, arg<0)
                    wrc('.')
                    writez( ABS arg MOD scale, m)
                    !lvnextarg := !lvnextarg + 1
                    LOOP
                  }
                  f := writed;    GOTO getarg


      CASE 'S':   f := writes;    GOTO noargs
      CASE 'T':   f := writet;    GOTO getarg
      CASE 'C':   f := wrc;      GOTO noargs
      CASE '#':   f := codewrch;  GOTO noargs
      CASE 'O':   f := writeoct;  GOTO getarg
      CASE 'X':   f := writehex;  GOTO getarg
      CASE 'I':   f := writed;    GOTO getarg
      CASE 'N':   f := writen;    GOTO noargs
      CASE 'U':   f := writeu;    GOTO getarg
      CASE 'Z':   f := writez;    GOTO getarg
      CASE 'B':   f := writebin;  GOTO getarg

    getarg:       UNLESS widthgiven DO
                  { p := p + 1
                    n := capitalch(format%p)
                    n := '0' <= n <= '9' -> n - '0', 10 + n - 'A'
                  }

    noargs:       f(arg, n)
                  !lvnextarg := !lvnextarg + 1
                  LOOP

      CASE '$':
      CASE '+':   !lvnextarg := !lvnextarg + 1
                  LOOP

      CASE '-':   !lvnextarg := !lvnextarg - 1
                  LOOP

      CASE 'M': { LET buf = VEC 256/bytesperword
                  !lvnextarg := !lvnextarg + 1
                  UNLESS get_text(arg, buf, 256/bytesperword) DO
                    buf := "<<mess:%-%n>>"  // No message text
                  write_format(buf, lvnextarg)
                  LOOP
                }

      CASE 'F':   !lvnextarg := !lvnextarg + 1
                  write_format(arg, lvnextarg)
                  LOOP

      CASE 'P': { LET plural = arg ~= 1
                  !lvnextarg := !lvnextarg + 1
                  p := p+1
                  type := format%p
                  IF type = '\' DO
                  { // Deal with %P\singular\plural\ item
                    LET skipping = plural
                    p := p + 1
                    UNTIL p > format%0 DO
                    { LET ch = format%p
                      TEST ch = '\' THEN { skipping := ~skipping
                                           IF skipping = plural BREAK
                                         }
                                    ELSE UNLESS skipping DO wrc(ch)
                      p := p + 1
                    }
                    LOOP
                  }

                  // Deal with simple %Pc items
                  IF plural DO wrc(type)
                  LOOP
                }
    } // End of SWITCHON ...
  } // End of FOR p = ...

  result2 := res2
}
