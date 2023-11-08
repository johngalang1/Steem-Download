;Constants 
CR			equ	13 
LF			equ	10 

TRUE			equ	1
FALSE			equ	0 

MAX_ROMANS		equ	7 
MAX_STRING		equ	20 
NO_ERROR		equ	0 
MAX_DIGIT_COUNT		equ	3 
C_NULL			equ	'\0'
QUIT			equ	'Q' 

;Roman_digit structure 
ROMAN_DIGIT		equ	14	;Has 14 bytes of memory 
DIGIT			equ	0	;takes in a byte 
ARAB_VALUE		equ	1 	;takes in 2 bytes/ 1 word, contains a padding 
SUBTRACTOR_INDEX	equ	4	;words start at even address 
COUNT			equ	6	;takes in 1 byte, + padding
MODIFIED		equ	8 	;takes in 1 byte, + padding
MODIFIER		equ	10	;takes in 1 byte, + padding
MAX_TIMES		equ	12	;takes in 1 byte, + padding


;initializing array of structures 
			lea	all_roman,a0 
			clr.l	d0			;index couner
			move.b	#MAX_ROMANS-1,d1	
init_roman:		
			

;declare array of structures 
all_roman:		ds.b	ROMAN_DIGIT*MAX_ROMANS


















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
