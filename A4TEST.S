;Constants 
CR			equ	13 
LF			equ	10 

TRUE			equ	1
FALSE			equ	0 

MAX_ROMANS		equ	7 
MAX_STRING		equ	20 
NO_ERROR		equ	0 
MAX_DIGIT_COUNT		equ	3 
NULL			equ	0
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

start: 
			lea	all_roman,a6
			clr.l	d0
zero:		
			move.b	#'I',DIGIT(a6,d0.w) 
			move.w	#1,ARAB_VALUE(a6,d0.w) 
			move.w	#-1,SUBTRACTOR_INDEX(a6,d0.w)  
			move.b	#0,COUNT(a6,d0.w)  
			move.b	#FALSE,MODIFIED(a6,d0.w) 
			move.b	#FALSE,MODIFIER(a6,d0.w) 
			move.b	#MAX_DIGIT_COUNT,MAX_TIMES(a6,d0.w) 
			add.w	#ROMAN_DIGIT,d0
first:
			move.b	#'V',DIGIT(a6,d0.w) 
			move.w	#5,ARAB_VALUE(a6,d0.w) 
			move.w	#0,SUBTRACTOR_INDEX(a6,d0.w)  
			move.b	#0,COUNT(a6,d0.w)  
			move.b	#FALSE,MODIFIED(a6,d0.w) 
			move.b	#FALSE,MODIFIER(a6,d0.w) 
			move.b	#1,MAX_TIMES(a6,d0.w) 
			add.w	#ROMAN_DIGIT,d0
second:
			move.b	#'X',DIGIT(a6,d0.w) 
			move.w	#10,ARAB_VALUE(a6,d0.w) 
			move.w	#0,SUBTRACTOR_INDEX(a6,d0.w)  
			move.b	#0,COUNT(a6,d0.w)  
			move.b	#FALSE,MODIFIED(a6,d0.w) 
			move.b	#FALSE,MODIFIER(a6,d0.w) 
			move.b	#MAX_DIGIT_COUNT,MAX_TIMES(a6,d0.w) 
			add.w	#ROMAN_DIGIT,d0
third:
			move.b	#'L',DIGIT(a6,d0.w) 
			move.w	#50,ARAB_VALUE(a6,d0.w) 
			move.w	#2,SUBTRACTOR_INDEX(a6,d0.w)  
			move.b	#0,COUNT(a6,d0.w)  
			move.b	#FALSE,MODIFIED(a6,d0.w) 
			move.b	#FALSE,MODIFIER(a6,d0.w) 
			move.b	#1,MAX_TIMES(a6,d0.w) 
			add.w	#ROMAN_DIGIT,d0
fourth:
			move.b	#'C',DIGIT(a6,d0.w) 
			move.w	#100,ARAB_VALUE(a6,d0.w) 
			move.w	#2,SUBTRACTOR_INDEX(a6,d0.w)  
			move.b	#0,COUNT(a6,d0.w)  
			move.b	#FALSE,MODIFIED(a6,d0.w) 
			move.b	#FALSE,MODIFIER(a6,d0.w) 
			move.b	#MAX_DIGIT_COUNT,MAX_TIMES(a6,d0.w) 
			add.w	#ROMAN_DIGIT,d0
fifth:
			move.b	#'D',DIGIT(a6,d0.w) 
			move.w	#500,ARAB_VALUE(a6,d0.w) 
			move.w	#4,SUBTRACTOR_INDEX(a6,d0.w)  
			move.b	#0,COUNT(a6,d0.w)  
			move.b	#FALSE,MODIFIED(a6,d0.w) 
			move.b	#FALSE,MODIFIER(a6,d0.w) 
			move.b	#1,MAX_TIMES(a6,d0.w) 
			add.w	#ROMAN_DIGIT,d0
sixth:
			move.b	#'M',DIGIT(a6,d0.w) 
			move.w	#1000,ARAB_VALUE(a6,d0.w) 
			move.w	#4,SUBTRACTOR_INDEX(a6,d0.w)  
			move.b	#0,COUNT(a6,d0.w)  
			move.b	#FALSE,MODIFIED(a6,d0.w) 
			move.b	#FALSE,MODIFIER(a6,d0.w) 
			move.b	#MAX_DIGIT_COUNT,MAX_TIMES(a6,d0.w) 
			add.w	#ROMAN_DIGIT,d0

;Print introduction statements 
			lea	string,a0
			lea	intro1,a1
			lea	intro2,a2
			lea	intro3,a3  
			lea	input_str,a4  
			clr.l	d0

intro1_loop:		
			move.b	(a1)+,d0  
			beq	intro2_loop
			jsr	write_char 
			bra	intro1_loop
intro2_loop: 
			move.b	(a2)+,d0  
			beq	intro3_loop
			jsr	write_char 
			bra	intro2_loop
intro3_loop:
			move.b	(a3)+,d0  
			beq	newline_print
			jsr	write_char 
			bra	intro3_loop 
newline_print:	
			lea	newline,a5
newline_loop:		
			move.b	(a5)+,d0 
			beq	input_loop
			jsr	write_char 
			bra	newline_loop
input_loop:		
			move.b	(a4)+,d0 
			beq	get_input
			jsr	write_char 
			bra	input_loop	
get_input:  		
			jsr	read_char 
			move.b	d0,d1    
			and.l	#$FF,d1	 
			cmp.b	#CR,d1
			beq	main_prog
			add.b	#1,d7		;counter for char inputs
			move.b	d1,(a0)+
			bra	get_input

main_prog: 					;while(string[0] != QUIT)
			suba.l	d7,a0		;Go to the 0th index	
			move.b	(a0),d1
			cmp.b	#QUIT,d1 
			beq	done
		
			move.b	#0,d2		 ;sum
			move.b	#0,d3		 ;s_index
			move.b	#MAX_ROMANS-1,d4 ;r_last
			move.b	#NO_ERROR,d5	 ;error 

while1:						;while ((string[s_index] != C_NULL) && error == NO_ERROR)		
			adda.l	d3,a0		
			move.b	(a0),d1		
			cmp.b	#NULL,d1
			beq	if_error
			cmp.b	#NO_ERROR,d5 
			bne	if_error
			move.b	#MAX_ROMANS-1,d6 ;r_index

while2:			 			;while (r_index >= 0 && string[s_index] != all_roman[r_index].digit)
			tst.b	d6 		
			blt	r_less_0
 			move.b	d6,d7 
			muls	#10,d7
			move.b	DIGIT(a6,d7),d0
			cmp.b	d0,d1  
			beq	r_less_0 
			sub.b	#1,d6
			bra	while2
r_less_0: 					;(r_index < 0)
			tst.b	d6 
			bge	else1
			move.b	#1,d5		;error = 1
			bra	check_error
else1: 
			nop
check_error:					;(error == NO_ERROR)
			cmp.b	#NO_ERROR,d5
			bne	while1 
			add.b	#1,d3 
			move.b	d6,d4
			bra	while1
if_error					;if(error)
			tst.b	d5 
			beq	no_error
			lea	intro_error,a1
print_intro_err:
			move.b	(a1)+,d0  
			beq	position_err
			jsr	write_char 
			bra	print_intro_err
position_err:		
			move.b	d3,d0 
			add.b	#'0',d0
			jsr	write_char 
			move.b	#'(',d0
			jsr	write_char 
			move.b	d1,d0 
			jsr	write_char 
			move.b	#')',d0
			jsr	write_char 			
			move.b	#CR,d0 
			jsr	write_char 
			move.b	#LF,d0
			jsr	write_char 
error_case:		
			cmp.b	#1,d5 
			beq	case1
			cmp.b	#2,d5 
			beq	case2
			cmp.b	#3,d5 
			beq	case3 
			cmp.b	#4,d5 
			beq	case4 
			cmp.b	#5,d5 
			beq	case5 
			bra	default
case1:		
			lea	error1,a1
case1_print:
			move.b	(a1)+,d0  
			beq	reset
			jsr	write_char 
			bra	case1_print
case2:
			lea	error2,a1
case2_print:
			move.b	(a1)+,d0  
			beq	reset
			jsr	write_char 
			bra	case2_print
case3:			
			lea	error3,a1	
case3_print:
			move.b	(a1)+,d0  
			beq	reset
			jsr	write_char 
			bra	case3_print
case4:			
			lea	error4,a1
case4_print:
			move.b	(a1)+,d0  
			beq	reset
			jsr	write_char 
			bra	case4_print
case5:			
			lea	error5,a1
case5_print:
			move.b	(a1)+,d0  
			beq	reset
			jsr	write_char 
			bra	case5_print
default:		
			lea	default_error,a1
default_print:
			move.b	(a1)+,d0  
			beq	reset
			jsr	write_char 
			bra	default_print
no_error:					;print sum
			nop

reset: 			
			move.b	#MAX_ROMANS-1,d7
			move.w	#0,d6
reset_loop:
			move.b	#0,COUNT(a6,d6.w)
			move.b	#FALSE,MODIFIED(a6,d6.w) 
			move.b	#FALSE,MODIFIER(a6,d6.w)  
			add.b	#10,d6 
			dbra	d7,reset_loop
			clr.l 	d0
			clr.l 	d1
			clr.l 	d2
			clr.l 	d3
			clr.l 	d4
			clr.l 	d5
			clr.l 	d6
			clr.l 	d7 
 			lea	input_str,a4  
			bra	newline_print
			

done:
			jsr	exit


;Declarations
all_roman:		ds.b	ROMAN_DIGIT*MAX_ROMANS

string:			ds.b	MAX_STRING+1  

intro1:			dc.b	"This program converts numbers in Improved Roman notation to Arabic notation.",CR,LF,NULL 
intro2: 		dc.b	"Input is limited to UPPER case Roman digits only.",CR,LF,NULL 
intro3:			dc.b	"To exit the program type only the Enter key.",CR,LF,NULL 

intro_error:		dc.b	CR,LF,"Character at position ",NULL

error1:			dc.b	"is not a valid Roman digit",CR,LF,NULL

error2:			dc.b	"is out of order for a Improved Roman number",CR,LF,NULL

error3:			dc.b	"has been used as a modifier and can't be used unmodified",CR,LF,NULL

error4:			dc.b	"combination of the modified prior digit and this digit is",CR,LF,"an invalid Roman number",CR,LF,NULL

error5:			dc.b	"has exceeded the maximum occurrences for this digit",CR,LF,NULL 

default_error:		dc.b	"In error handling with an invalid error code",CR,LF,NULL

newline:		dc.b	CR,LF,NULL 

input_str:		dc.b	"Input a Roman number (Press 'Q' to exit): ",NULL


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
