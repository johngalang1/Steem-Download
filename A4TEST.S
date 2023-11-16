;Name:		John Galang
;Email:		jgala861@mtroyal.ca 
;Course:	COMP 2655 - 002 
;		Assignment 4 
;Due:		11-16-2023 
;File_Name:	ROMANS.S 
;Instructor:	Paul Pospisil 
;
;Purpose:	Convert numbers in Improved Roman notation to
;Arabic notation.
;
;Details:
;
;Program will input values from Roman notation and check if they are legal numbers to convert into Arabic notation. 
;
;Roman Characters to input: M,D,C,L,X,V,I  
;
;These numbers are represented by sequences of symbols in decreasing order of value. 
;
;There limitations on the maximum occurrences of certain symbols: 
;User can input D, L, V at most once, and C, X, I at most three times 
;
;User cannot input a string size that is greater than 21 characters since 21 bytes are reserved for input value 
;
;The program will check the order of these characters to see if it is valid, if not, 
;the program will print a error message as the output  
;
;If it is a legal number, will print out the sum through a “repeated division by 10” algorithm. 
;
;Status:	
;
;Tested with IM, and it successfully generates an error for case 2 when it checks the subtractor field, 
;it is not equivalent to r_last  
;
;Result in debugger: ( 04 != 0)
;
;Tested with CMC, successfully generates an error for case 3 when it checks the modifier field, it is non-zero   
;
;Result in debugger: (01 != 0) 
;
;Tested with XCL, successfully generates an error for case 4, when it compares the subratctor field of one index of an array, 
;to the next and both are equivalent. 
;
;Result in debugger: (01 == 01)   
;
;Tested with MMMM, successfully generates an error for case 5, 
; when it checks if the count field is less or equal to the max_times field 
;
;Result in debugger: (07 > 03) - checks if false 
;
;Tested with various legal numbers and generates expected results: 
;MMMCMXCIX = 3999 
;MCCXXXIV = 1234 
;MMXXIII = 2023
;
;
;Register Table:	
;	d0 - Takes in characters and prints it out 
;	   - Takes values from the array of structures
;
;	d1 - Holds each input character  
;
;	d2 - Counter for the amount of input characters 
;	   -sum variable 
;
;	d3 - s_index variable 
;
;	d4 - r_last variable 
;
;	d5 - error variable
;
;	d6 - r_index variable 
;	   -Index Counter for i variable 
;	   -Used for finding fields in the structure array
;
;	d7 - counter for amount of character inputs 
;	   - Takes values from the array of structures
;
;	a0 - Holds input values
;
;	a1 - Holds introduction strings 
;	   - Prints out error outputs
;
;	a2 - Holds introduction strings 
;	   - Reserves bytes to print the output sum
;
;	a3 - Holds introduction strings
;
;	a4 - Print Input string 
;
;	a5 - newline string 
;
;	a6 - Array structure

;Constants 
CR			equ	13 
LF			equ	10  
TAB			equ	9

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
			clr.l	d0
			suba.l	d7,a0		;Go to the 0th index	
			move.b	(a0),d1
			cmp.b	#QUIT,d1 
			beq	done
		
			move.w	#0,d2		 ;sum
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
			blt	error_check1
			mulu	#10,d6
			move.b	DIGIT(a6,d6.w),d0
			divu	#10,d6
			cmp.b	d0,d1  
			beq	error_check1 
			sub.b	#1,d6
			bra	while2
error_check1: 					;(r_index < 0)
			tst.b	d6 
			bge	error_check2
			move.b	#1,d5		
			bra	check_error

error_check2: 					;(r_index > r_last)
			cmp.b	d4,d6
			ble	error_check3 

			mulu	#10,d6
			move.w	SUBTRACTOR_INDEX(a6,d6.w),d0  
			divu	#10,d6
			cmp.b	d4,d0  
			bne	set_error2	;check if true, then branch
			mulu	#10,d4
			move.b	COUNT(a6,d4.w),d0  
			divu	#10,d4
			cmp.b	#1,d0 
			ble	calc_sum_1 
set_error2: 		
			move.b	#2,d5 
			bra	check_error
calc_sum_1:			
			mulu	#10,d6
			move.w	ARAB_VALUE(a6,d6.w),d0 
			add.w	d0,d2 			;sum = sum + all_roman[r_index].arab_value   
			mulu	#10,d4			
			move.w	ARAB_VALUE(a6,d4.w),d0 
			divu	#10,d4
			mulu	#2,d0 
			sub.w	d0,d2			;sum = sum - 2 * all_roman[r_last].arab_value; 

			move.w	SUBTRACTOR_INDEX(a6,d6.w),d7 
			muls	#10,d7 
			sub.b	#1,COUNT(a6,d7.w) 
			add.b	#1,COUNT(a6,d6.w) 
			move.b	#TRUE,MODIFIED(a6,d6.w) 
			move.b	#TRUE,MODIFIER(a6,d7.w)
			clr.l	d7
			divu	#10,d6 
			bra	check_error
error_check3: 							;(all_roman[r_index].modifier)
			mulu	#10,d6
 			move.b	MODIFIER(a6,d6.w),d0 
			divu	#10,d6
			tst.b	d0 
			beq	error_check4 
			move.b	#3,d5
			bra	check_error 

error_check4:							
			mulu	#10,d6 
			move.w	SUBTRACTOR_INDEX(a6,d6.w),d0 
			add.b	#10,d6 
			move.w	SUBTRACTOR_INDEX(a6,d6.w),d7 
			sub.b	#10,d6
			divu	#10,d6
			cmp.b	d7,d0  
			bne	calc_sum2 
 
			muls	#10,d7
			move.b	MODIFIER(a6,d7.w),d0 
			tst.b	d0 
			beq	calc_sum2 

			move.b	#4,d5 
			bra	check_error

calc_sum2: 			
			mulu	#10,d6
			add.b	#1,COUNT(a6,d6.w) 
			move.b	COUNT(a6,d6.w),d0 
			move.b	MAX_TIMES(a6,d6.w),d7 
			cmp.b	d7,d0
			bgt	error_check5

			add.w	ARAB_VALUE(a6,d6.w),d2 
			divu	#10,d6 
			move.b	d6,d4
			bra	check_error
			
error_check5:
			move.b	#5,d5 
			bra	check_error

check_error:					;(error == NO_ERROR)
			cmp.b	#NO_ERROR,d5
			suba.l	d3,a0
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
			divu	#10,d2
			swap	d2 
			add.b	#'0',d2 
			move.b	d2,(a2)+ 
			clr.w	d2 
			swap	d2
			bne	no_error
			move.b	#CR,d0 
			jsr	write_char 
			move.b	#LF,d0
			jsr	write_char 
print_sum:
			cmpa.l	#intro2+52,a2
			beq	reset
			move.b	-(a2),d0 
			jsr	write_char 
			bra	print_sum

reset: 			
			move.l	#MAX_ROMANS-1,d6
			clr.w	d7
reset_loop:
			move.b	#0,COUNT(a6,d7.w)
			move.b	#FALSE,MODIFIED(a6,d7.w) 
			move.b	#FALSE,MODIFIER(a6,d7.w)  
			add.b	#10,d7
			dbra	d6,reset_loop
find_0_index:						;reset the string array 
			move.b	-(a0),d0 
			cmp.b	#MAX_DIGIT_COUNT,d0
 			beq	find_last_index			
			bra	find_0_index
find_last_index: 
			adda.l	#22,a0  
			move.b	#MAX_STRING,d7
reset_string: 
			move.b	#0,-(a0)
			dbra	d7,reset_string 
clear:
			adda.l	#1,a0
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
intro2: 		dc.b	TAB,"Input is limited to UPPER case Roman digits only.",CR,LF,NULL 
			ds.b	MAX_STRING

intro3:			dc.b	TAB,"To exit the program type only the Enter key.",CR,LF,NULL 

intro_error:		dc.b	CR,LF,"Character at position ",NULL

error1:			dc.b	TAB,"is not a valid Roman digit",CR,LF,NULL

error2:			dc.b	TAB,"is out of order for a Improved Roman number",CR,LF,NULL

error3:			dc.b	TAB,"has been used as a modifier and can't be used unmodified",CR,LF,NULL

error4:			dc.b	TAB,"combination of the modified prior digit and this digit is",CR,LF,TAB,"an invalid Roman number",CR,LF,NULL

error5:			dc.b	TAB,"has exceeded the maximum occurrences for this digit",CR,LF,NULL 

default_error:		dc.b	TAB,"In error handling with an invalid error code",CR,LF,NULL

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
