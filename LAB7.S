CR		equ	13
LF		equ	10


start:		pea	greeting
		bsr	write_string
		addq.l	#4,sp 
exercise2:	
		move.l	s1,a0
		move.l	s2,a1 
		bsr	strcat
	
		bsr	exit


greeting:	dc.b	"hi, it worked!",CR,LF,0
		even
s1:		dc.b	"hello",0
		ds.b	50
		even
s2:		dc.b	", world!",CR,LF,0
		even


;----- SUBROUTINE: write_string -----
;
; [to do for exercise 1]

ws_str		equ	12

write_string:	
		movem.l	a0/d0,-(sp) 
		move.l	ws_str(sp),a0

ws_print_loop:	
		move.b	(a0)+,d0 
		beq	ws_done 
		move.b	d0,-(sp) 
		jsr	write_char 
		addq.l	#2,sp 
		bra	ws_print_loop

ws_done: 
		movem.l	(sp)+,a0/d0 
		rts


;----- SUBROUTINE: strcat -----
;
; [to do for exercise 2]

strcat:
		movem.l	a0/a1,-(sp)
strcat_loop: 
		move.b	(a1)+,d0 
		beq	strcat_done 
		move.b	d0,(a0)+ 
		bra	strcat_loop 
strcat_done 
		movem.l	(sp)+,a0/a1
		rts


;----- SUBROUTINE: write_char -----
;
; PURPOSE: writes a single character to the screen.
;
; CALLER INPUT: takes the ASCII value of the character as a byte on the stack.
;
; E.G. CALL:	move.b	#'a',-(sp)
;		bsr	write_char
;		addq.l	#2,sp

ch		equ	8

write_char:	link	a6,#0
		movem.l	d0-d2/a0-a2,-(sp)
		clr.w	d0
		move.b	ch(a6),d0
		move.w	d0,-(sp)
		move.w	#2,-(sp)
		trap	#1
		addq.l	#4,sp
		movem.l	(sp)+,d0-d2/a0-a2
		unlk	a6
		rts


;----- SUBROUTINE: exit -----
;
; PURPOSE: terminates the program.  This routine never returns.

exit:		clr.w	-(sp)
		move.w	#$4C,-(sp)
		trap	#1
