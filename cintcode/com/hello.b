
SECTION "hello"

GET "libhdr"

LET clihook() = start()

LET start() BE
{
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
  FINISH
}

AND fact(n) = n=0 -> 1, n*fact(n-1)

AND wrc(ch) BE sys(11,ch)   //wrch(ch)

AND wrs(s) BE
  FOR i = 1 TO s%0 DO wrc(s%i)

AND nl() BE wrc('*n')

AND WRU(U) BE { IF U > 9 THEN WRU(U/10); wrc(U REM 10 + '0') }

AND WRN(N) BE { TEST N < 0 THEN { wrc('-'); WRU(-N) } ELSE WRU(N); wrc(' ') }
