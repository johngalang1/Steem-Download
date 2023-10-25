;Name:		John Galang
;Email:		jgala861@mtroyal.ca 
;Course:	COMP 2655 - 002 
;		Assignment 3 Phase 2 
;Due:		10-26-2023 
;File_Name:	ASSIGN3.S 
;Instructor:	Paul Pospisil 
;
;Purpose:	TO READ IN A 3 DIGIT NUMBER AND CALCULATE THROUGH THE FORMULA GIVEN 
;		AND THEN WRITE OUT THE 3 DIGIT CALCULATED NUMBER 
;
;Details:	The programmer should only input a 3 digit decimal number and the program should output 
;		a 3 digit decimal number. All calculations are in hexidecimal. 
;
;Status:	Program is successfully working for 3 tested numbers: 180, 999, 284 
;		and provides the desired result at the end of program. 
;
;		For example, using the biggest input number possible, 999, each digit is read as a character in hexidecimal.
;		In order
;
;
;
;
;Register Table:	
;		d0 - Inputs a read character 
;		   - Outputs a character 	
;
;		d1 - Stores the Hundreth position of a number 
;                  - Outputs the Hundreth Position of a number 
;		
;		d2 - Stores the  Tenth position of a number 
; 		   - Outputs the Tenth position of a number 
; 
;		d3 - Stores the Ones position of a number  
; 		   - Outputs the Ones position of a number 
; 
; 		d4 - Stores the value x for calculations 
; 
; 		d5 - Stores x^2 
;		
;		d6 - Stores the calculated number  
; 
;		d7 - Stores 5x

start:				; TO DO: fill in your code and inline doc. here
	
	jsr	read_char  	;Reads input  
	move.l	d0,d1	   	;Stores input 
	and.l	#$FF,d1	   	;Clears the upper 24 bits 
	
	jsr	read_char 
	move.l	d0,d2 
	and.l	#$FF,d2

	jsr	read_char 
	move.l	d0,d3 
	and.l	#$FF,d3  

	sub.b	#'0',d1		;Subtract characters by '0' to get actual number values	 
	sub.b	#'0',d2 
	sub.b	#'0',d3 

	mulu	#100,d1 	;Convert digits into their digit positions
	mulu	#10,d2 

	move.l	d1,d4		;Add all digits together into register d4
	add.w	d2,d4
	add.w	d3,d4

	move.l	d4,d5		;Register d5 will contain (x^2)
	mulu	d5,d5

	move.l	d5,d6	
	lsl.l	#3,d6		;Since 8 is 2^3, we can shift 3 bits to the left which is the same as multiplying by 8

	move.l	d4,d7
	mulu	#5,d7		;Becomes 5x 

	sub.l	d7,d6		;8(x^2) - 5x 
	add.l	#1997,d6

	divu	#10000,d6	;Modulo Operation
	swap	d6

	and.l	#$FFFF,d6

	divu	#10,d6
	and.l	#$FFFF,d6	

	move.l	d6,d1		;Converting Values to decimal and individual digits
	divu	#100,d1  
	and.l	#$FFFF,d1	;Hundreth Digit

	move.l	d6,d2 
	divu	#10,d2
	and.l	#$FFFF,d2
	divu	#10,d2
	swap	d2   
	and.l	#$FFFF,d2 	;Tens Digit

	move.l 	d6,d3 
	divu	#10,d3
	swap	d3 
	and.l	#$FFFF,d3	;Ones Digit
	 
	move.l	#13,d0		;New Line
	jsr	write_char

	move.l	#10,d0
	jsr	write_char
	
	add.b	#'0',d1 	;Converting to ASCII		
	add.b	#'0',d2
	add.b	#'0',d3

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
