
//  This will be the machine code library for ARM machines (based on the i386 version)
//  CURRENTLY UNDER DEVELOPMENT.
//  It will be tested on the Raspberry Pi Computer

//  Written by Martin Richards (c) May 2013

	
//  C Linkage:
//    On entry rl =X14  is the return address
//             X0       is the first argument
//             X1       is the second argument
//             etc
// 
//    X4 - X13 must be preserved
// 
//    result in X0

//  BCPL linkage
//    On entry rl   is the return address
//             X1   is entry address
//             X2   is the new P pointer NP (a m/c address)
//             X4   is the first argument
//             NP!4... are the other arguments
// 
//    result in X4

   
.global _callstart
.global divrem
.global _dosys
	
.text
.align 2

_callstart:
 sub sp, sp, #80
 stp X4, X5, [sp, #0]
 stp X6, X7, [sp, #16]
 stp X8, X9, [sp, #32]
 stp X10, X11, [sp, #48]
 str LR, [sp, #56]
             
 //  X0 = stackbase (first argument}
 //  X1 = gvec (second argument}

   mov X10, X0    //  X10=X10 is the P pointer
   mov X11, X1    //  X11=X11 is the G pointer

//  Register usage while executing BCPL compiled code

//  X0       Work register
//  X1       Work register, function entry address
//  X2       Work register, new P pointer in call
//  X3       Work register
//  X4    X4 Cintcode A
//  X5    X5 Cintcode B
//  X6    X6 Cintcode C
//  X7-X9    Work registers
//  X10   X10 The P pointer -- m/c address
//  X11   X11 The G pointer -- m/c address of Global 0
//  X12      Not used

//  make sure global 3 (sys) is defined
   adr X0, sys
   str X0, [X11, #8*3]

//  make sure global 6 (changeco) is defined
   adr X0, changeco
   str X0, [X11, #8*6]

//  BCPL call of clihook(_stackupb)
   adrp X0, _stackupb @PAGE
   add X0, X0, _stackupb @PAGEOFF
   ldr X4, [X0]          //  First arg = _stackupb
   add X2, X10, #8*6      //  New P pointer
   ldr X1, [X11, #8*4]    //  Entry address -- G!4 = clihook
   blr X1            //  Enter clihook
   mov X0, X4            //  return the result of start
   
//  and return
   ldp X4, X5, [sp, #0]
   ldp X6, X7, [sp, #16]
   ldp X8, X9, [sp, #32]
   ldp X10, X11, [sp, #48]
   ldr LR, [sp, #56]
   add sp, sp, #72
   ret

//  res = sys(n, x, y, x,...)  the BCPL callable sys function
sys:
 sub sp, sp, #64
 stp X10,lr,[sp]
 stp X1,X4,[sp, #16]
 ldp X0,X1,[X2, #32]
 stp X0,X1,[sp, #32]
 stp X2,X11,[sp, #48]
//  P = NP -> [<old P>, <return addr>, <entry addr>, <arg1>, ...]
 mov X0, sp         //  first argument  = P
 mov X1, X11        //  second argument = G
 adrp X2, _dosys @PAGE
 add X2, X2, _dosys @PAGEOFF
 blr X2             //  Call _dosys(P, G)

 ldp X2,X11,[sp, #48]
 ldp X1,X4,[sp, #16]
 ldp X10,lr,[sp]
 add sp, sp, #64
 mov X4, X0         //  put result in Cintcode A register
 ret //  BCPL function return

changeco:          //  changeco(val, cptr)
   //  X1 = entry address
   //  X2 = NP (a m/c address) then new P pointer
   //  X4 = val
   //  NP!4 = cptr (a BCPL pointer)
   //  X10 = P pointer (a m/c address) -> [<old P>, <ret addr>, <entry addr>, ...]
   //  X11 = G pointer (m/c address of global zero)
   //  lr = return address
   //  z  = X0 (to hold zero)

 mov X0, #0
 ldr X1, [X2, #8*4]        //  X1 := X2!4  (= cptr) -- a BCPL pointer
 ldr X3,[X11, #8*7]        //  X1 := currco)        -- a BCPL pointer
 str X10, [X0, X3, lsl#3]   //  currco!0 := P       -- save the resumption point
 str X1, [X11, #8*7]        //  currco := cptr      -- set current coroutine
 ldr X10, [X0, X1, lsl#3]    //  P := !cptr          -- get the resumption point
 ret
