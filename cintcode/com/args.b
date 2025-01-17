// (c)  Copyright:  Martin Richards  30 April 2014

SECTION "ARGS"

GET "libhdr"
GET "syscall"

LET clihook() = start()

LET start() BE
{
LET fd, rslt = ?, ?
LET time = VEC 100
LET days = VEC 100
LET tz = VEC 100
LET s = "Hello, World"
LET v = VEC 100
testargs()
fd := open("temp.txt", O_WRONLY|O_TRUNC|O_CREAT, 384);
FOR I = 1 TO s%0 DO v%(I-1) := s%I
rslt := write(fd, v, s%0)
close(fd)
rslt := gettimeofday(time, tz)
writef("gettimeofday returned %d *n", rslt)
writef("time!0 = %x8 *n", time!0)
days!0 := time!0 / 86400
days!1 := time!0 REM 86400
days!2 := -1
dat_to_strings(days, v)
writef("%s %s %s *n", v+10, v, v+5)
exit()
}

AND exit() = sys(36, SYS_exit, 0)

AND open(nam, flags, mode) = sys(36, SYS_open, (nam<<3)+1, flags, mode)

AND write(fd, buf, len) = sys(36, SYS_write, fd, buf<<3, len)

AND close(fd) = sys(36, SYS_close, fd)

AND gettimeofday(tp, tzp) = sys(36, SYS_gettimeofday, tp<<3, tzp<<3)

AND testargs() = sys(37, 1,2,3,4,5,6)
