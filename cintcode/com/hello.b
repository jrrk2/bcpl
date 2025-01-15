
SECTION "hello"

GET "libhdr"

GLOBAL { f:200; g:401; h:602
         testno:203; failcount:204
         v:205; testcount:206; quiet:207; t:208
         bitsperword:210; msb:211; allones:212
         on64:213 // TRUE if running on a 64-bit system 
}

STATIC { a=10; b=11; c=12; w=15; minus1=-1  }

MANIFEST { k0=0; k1=1; k2=2  }

LET clihook() = start()

LET start() BE
{
  LET ww = 65
  LET v1 = VEC 200
  AND v2 = VEC 200
  LET x, a, f = 5, 15, 105
  wrs("Hello*n")
  WRN(1024)
  WRN(1025)
  WRN(1048576)
  WRN(1000000000)
  WRN(-1048576)
  WRN(-12345)
  WRN(-123456789012)
  WRN(10000200001)
  FOR i = 1 TO 10 DO { LET f = fact(i); nl(); wrs("fact("); WRN(i); wrs(") = "); WRN(f) }
  nl();
  tester(0, 1, 2, v1, v2)
  switcher()
  }

AND switcher() BE
    { LET s1, s1f = 0, 0
      FOR i = -200 TO 200 DO SWITCHON i INTO
      { DEFAULT: s1 := s1+1000; ENDCASE
        CASE -1000: s1f := s1f + i; ENDCASE
        CASE -200: s1 := s1 + 1
        CASE -190: s1 := s1 + 1
        CASE -180: s1 := s1 + 1
        CASE   -5: s1 := s1 + 1
        CASE    0: s1 := s1 + 1
        CASE -145: s1 := s1 + 1
        CASE    7: s1 := s1 + 1
        CASE    8: s1 := s1 + 1
        CASE  200: s1 := s1 + 1
    }
}

AND tester(x,y,z,v1,v2) BE
{
  f, g, h := 100, 101, 102
  testno, testcount, failcount := 0, 0, 0
  v, w := v1, v2

  FOR i = 0 TO 200 DO v!i, w!i := 1000+i, 10000+i

  quiet := FALSE

//  TEST SIMPLE VARIABLES AND EXPRESSIONS

  testno := 1

  t(a+b+c, 33)        // 1
  t(f+g+h, 303)
  t(x+y+z, 3)

  t(123+321-400, 44)  // 4
  t(x=0, TRUE)
  t(y=0, FALSE)
  t(!(@y+x), 1)
  t(!(@b+x), 11)
  t(!(@g+x), 101)

  x, a, f := 5, 15, 105
  t(x, 5)            // 10
  t(a, 15)
  t(f, 105)

  v!1, v!2 := 1234, 5678
  t(v!1, 1234)       // 13
  t(v!z, 5678)

  t(x*a, 75)         //  15
  t(1*x+2*y+3*z+f*4,433)
  t(x*a+a*x, 150)

  testno := 18

  t(100/(a-a+2), 50) //  18
  t(a/x, 3)
  t(a/-x, -3)
  t((-a)/x, -3)
  t((-a)/(-x), 3)
  
}

AND t(x, y) = VALOF
{ testcount := testcount + 1
  wrd(testno, 4)
  wrs("         ")
  wrd(x, (on64->21,13))
  wrc('(')
  wrx(x, (on64->16,8))
  wrs(")    ")
  wrd(y, (on64->21,13))
  wrc('(')
  wrx(y, (on64->16,8))
  wrs(")")
  TEST x=y
  THEN { wrs(" OK")
       }
  ELSE { wrs(" FAILED")
         failcount := failcount + 1
       }
  nl()
  testno := testno + 1
  RESULTIS y
}

AND fact(n) = n=0 -> 1, n*fact(n-1)

AND wrc(ch) BE sys(11,ch)   //wrch(ch)

AND wrs(s) BE
  FOR i = 1 TO s%0 DO wrc(s%i)

AND nl() BE wrc('*n')

AND WRU(U) BE { IF U > 9 THEN WRU(U/10); wrc(U REM 10 + '0') }

AND WRN(N) BE { TEST N < 0 THEN { wrc('-'); WRU(-N) } ELSE WRU(N); wrc(' ') }

AND wrd(n, d) BE //wrx(n,8)
///*
{ LET t = VEC 30
  AND i, k = 0, -n
  IF n<0 DO d, k := d-1, n
  t!i, i, k := -(k REM 10), i+1, k/10 REPEATUNTIL k=0
  FOR j = i+1 TO d DO wrc('*s')
  IF n<0 DO wrc('-')
  FOR j = i-1 TO 0 BY -1 DO wrc(t!j+'0')
}
//*/

AND wrn(n) BE wrd(n, 0)

AND wrx(n, d) BE
{ IF d>1 DO wrx(n>>4, d-1)
  wrc((n&15)!TABLE '0','1','2','3','4','5','6','7',
                   '8','9','A','B','C','D','E','F' )
}
