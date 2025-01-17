// (c)  Copyright:  Martin Richards  30 April 2014

SECTION "ARGS"

GET "libhdr"
GET "syscall"

LET clihook() = start()

LET start() BE
{
LET fd = ?
LET s = "Hello, World"
LET v = VEC 100
testargs()
fd := open("temp.txt", O_WRONLY|O_TRUNC|O_CREAT, 384);
FOR I = 1 TO s%0 DO v%(I-1) := s%I
cnt := write(fd, v, s%0)
close(fd);
exit()
}

AND exit() = sys(36, SYS_exit, 0)

AND open(nam, flags, mode) = sys(36, SYS_open, (nam<<3)+1, flags, mode)

AND write(fd, buf, len) = sys(36, SYS_write, fd, buf<<3, len)

AND close(fd) = sys(36, SYS_close, fd)

AND testargs() = sys(37, 1,2,3,4,5,6)
