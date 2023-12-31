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
;		a 3 digit decimal number. All calculations are in hexidecimal. The formula the program 
;		will calculate is y = ((8*x2 - 5*x + 1997) % 10000) / 10.
;
;Status:	Program is successfully working for 3 tested numbers: 180, 999, 284.  
;		and provides the desired result at the end of program. 
;		
;		For example, using the biggest input number possible, 999, each digit is read as a character in hexidecimal.
;		In order to convert each digit to their actual value number, we subtract by the character '0' or 30 in hexidecimal. 
;		Each character 9, has an actual value of 39, so then it turns into its actual value of 9.
;
;		Once converted and deposited in a register(except d0), we have to clear the upper 24 bits due to the subroutine that affects d0.
;		Afterwards, we multiplty the hundreds digit by a hundred and the tens digit by 10 and add all of them together to achieve our x value. 
;		
;		9 * 100 = 900 
;		9 * 10 = 90 
;		900 + 90 + 9 = 999 - Actual Value / 3E7 in hexidecimal 
;		
;		In order to calculate y = ((8*x2 - 5*x + 1997) % 10000) / 10, 
;		Store x^2 in another register, which then = 998001 or F3A71 in hex
;		Since 8 = 2^3, 8 multipled by x^2 is operated by shifting the as longword 3 bits to the left, which = 7984008 or 79D388 
;		Aferwards we subtract by 5x and add 10000 to equal 7981010 or 79C7D2
;		To use modulous, we have to divide the number, swap, and then clear the upper 16 bits, leaving us with the remainder 
;		Dividing 79C7D2 by 10000 = 03F2031E 
;		Swap: 031E03F2 
;		Clear: 000003F2 
;		Divide by 10: 00000065  or 101 in decimal  
;
;		Now we have to seperate the number into the hundreth, tenth, and ones digit 
;		Hundreth Digit: Divide by 100 and clear the upper 16 bits 
;		065 / 100 = 00010001 -> 00000001
;		Tenth Digit: Divide by 10, clear bits, divide by 10 and swap to get the remainder and then clear the upper 16 bits 
;		065 / 10 = 0001000A -> 0000000A / 10 = 00000001 -> 00010000 -> 00000000
;		Ones Digit: Divide by 10, swap. and clear the upper 16 bits. 
;		065 / 10 = 0001000A -> 000A0001 -> 00000001 
;		
;		Each of these digits are added by '0' or 30 in hexidecimal to turn back into ASCII values to print out
;		And then once it is written on the output screen, it would be 101 
;		
;		Since this process works for the highest digit inputted, it should work for all numbers, such as 180 turning to 029 and 284 turning to 582
;
;Register Table:	
;		d0 - input – holds the character read from the keyboard
;   		- output – holds the character being written to screen
;
;		d1 - inputs the hundreth position of an 3 digit number
;   		- outputs the hundreth number after the calculation
;
;		d2 - inputs the tens position of an 3 digit number
;   		- outputs the tens number after the calculation
;
;		d3 - inputs the ones position of an 3 digit number
;   		- outputs the ones number after the calculation
;
;		d4 - stores in the x value after expanding notation
;
;		d5 - stores in x to the power of 2 (x^2)
;
;		d6 - stores that value y, after the calculation
;
;		d7 - stores in the value 5x for the calculation

reading_input:

	jsr	read_char  	 
	move.l	d0,d1	   	
	and.l	#$FF,d1	   	
	
	jsr	read_char 
	move.l	d0,d2 
	and.l	#$FF,d2

	jsr	read_char 
	move.l	d0,d3 
	and.l	#$FF,d3  

converting_to_actual_number:

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

calculations:

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

converting_to_digits:

	move.l	d6,d1	
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
	 
	move.l	#13,d0		
	jsr	write_char

	move.l	#10,d0
	jsr	write_char

printing:
	
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
