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
ROMAN_DIGIT		equ	10	
DIGIT			equ	0	
ARAB_VALUE		equ	2	;words start even	 
SUBTRACTOR_INDEX	equ	4	
COUNT			equ	6	
MODIFIED		equ	7 	
MODIFIER		equ	8	
MAX_TIMES		equ	9	

;Print introduction statements 

			lea	intro1,a1
		




;Declarations
all_roman:		ds.b	ROMAN_DIGIT*MAX_ROMANS
			dc.b 	'I',1,-1,0,0,0,MAX_DIGIT_COUNT	 
           		dc.b 	'V',5,0,0,0,0,1
           		dc.b 	'X',10,0,0,0,0,MAX_DIGIT_COUNT
           		dc.b 	'L',50,2,0,0,0,1
           		dc.b 	'C',100,2,0,0,0,MAX_DIGIT_COUNT
           		dc.b 	'D',500,4,0,0,0,1
           		dc.b 	'M',1000,4,0,0,0,MAX_DIGIT_COUNT 

string:			ds.b	MAX_STRING+1  

;Plan is to move these guys into data registers 
sum: 			ds.l	1
s_index:		ds.l	1
r_last: 		ds.l	1
r_index:		ds.l	1
i: 			ds.l	1
error:			ds.l	1 

intro1:			dc.b	"This program converts numbers in Improved Roman notation to Arabic notation.",NULL,CR,LF 
intro2: 		dc.b	"Input is limited to UPPER case Roman digits only.",NULL,CR,LF 
intro3:			dc.b	"To exit the program type only the Enter key.",NULL,CR,LF 
newline:		dc.b	CR,LF,NULL 

input_str:		dc.b	""Input a Roman number (Press 'Q' to exit): ",NULL



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