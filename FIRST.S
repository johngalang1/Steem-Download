; TO DO: fill in your header doc. here
;        (delete this comment)


start:				; TO DO: fill in your code and inline doc. here
	
	jsr	read_char  ;Reads input  
	move.l	d0,d1	   ;Stores input 
	and.l	#$FF,d1	   ;Clears the upper 24 bits 
	
	jsr	read_char 
	move.l	d0,d2 
	and.l	#$FF,d2

	jsr	read_char 
	move.l	d0,d3 
	and.l	#$FF,d3  

	sub.b	#'0',d1	;Subtract characters by '0' to get actual number values	 
	sub.b	#'0',d2 
	sub.b	#'0',d3 

	mulu.w	#$100,d1 ;Convert digits into their digit positions
	mulu.w	#16,d2 

	move.l	d1,d4	;Add all digits together into register d4
	add.w	d2,d4
	add.w	d3,d4

	move.l	d4,d5	;Register d5 will contain (x^2)
	mulu.w	d4,d5
	
	move.l	#13,d0
	jsr	write_char

	move.l	#10,d0
	jsr	write_char

	move.l	d1,d0
	jsr	write_char 

	move.l	d2,d0 
	jsr	write_char 

	move.l	d3,d0 
	jsr	write_char

	jsr	exit


;----- SUBROUTINE: read_char -----
;
; PURPOSE: waits for and reads a single keystroke from the keyboard.
;
; CALLER OUTPUT: returns the ASCII value of the key in the low byte
;                of D0.
;
; IMPORTANT: NOTE THAT THE HIGHER_ORDER BYTES OF D0 ARE UNDEFINED.
;            DON'T ASSUME THEY ARE ZEROED OUT!
;
; E.G. CALL:	jsr	read_char
;		... now use D0.b ...

read_char:	movem.l	d1-d2/a0-a2,-(sp)
		move.w	#1,-(sp)
		trap	#1
		addq.l	#2,sp	
		movem.l	(sp)+,d1-d2/a0-a2
		rts


;----- SUBROUTINE: write_char -----
;
; PURPOSE: writes a single character to the screen.
;
; CALLER INPUT: takes the ASCII value of the character in the low byte
;               of D0.
;
; E.G. CALL:	move.b	#'a',d0
;		jsr	write_char

write_char:	movem.l	d0-d2/a0-a2,-(sp)
		and.w	#$00FF,d0
		move.w	d0,-(sp)
		move.w	#2,-(sp)
		trap	#1
		addq.l	#4,sp
		movem.l	(sp)+,d0-d2/a0-a2
		rts


;----- SUBROUTINE: exit -----
;
; PURPOSE: terminates the program.  This routine never returns.

exit:		clr.w	-(sp)
		trap	#1
