SECTION "hello"

GET "libhdr"

LET clihook() = start()

LET start() = VALOF
{ wrs("Hello*n")
  RESULTIS 0
}

AND wrc(ch) BE sys(11,ch)   //wrch(ch)

AND wrs(s) BE
  FOR i = 1 TO s%0 DO wrc(s%i)

AND nl() BE wrc('*n')

