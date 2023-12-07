;Name:		John Galang
;Email:		jgala861@mtroyal.ca 
;Course:	COMP 2655 - 002 
;		Assignment 5 
;Due:		12-07-2023 
;File_Name:	A5_LIB.S 
;Instructor:	Paul Pospisil 
;
;Purpose: 	Provides a library of subroutines to add 32-bit IEEE floating point numbers. 
;
;Details: 	Details are listed for each subroutine documentation
;
;Status:	Program does not work, when running will lead to an address/bus error within 
;		the printCstring subroutine. 
;		Issue may be caused by add_FP which may have corrupted some address registers. 
;		This is concluded by testing without the addition of add_FP successfully prints out all the strings on the screen.
;		In a seperate a5_driver I created, I used the values C138ABCD and C35A4800
;		and prints out the result C365D2BC. 
;		packFloat, unpackFloat, and the scale subroutines function properly in this 
;		seperate file testing. 
;		Based on my arithmetic on a sheet of paper, the result I received was C365D2BCD0 
;		but in order to fit the size of a longword the last 9 bits were truncated. 
;		However, I am unable to do any further testing 
;		due to the address/bus error I am receiving within my program.

		xdef		add_FP
 		xdef		unpackFloat 
		xdef		packFloat 
		xdef		scale 
		xdef		renormalize 
		xdef		printCstring 
		xdef 		hex2string
		include		gemdos.i

GEMDOS		equ		1

SIGN		equ		0
BIASED_EXPONENT	equ		1
MANTISSA	equ		2
FLOATRECORD	equ		6

;----- SUBROUTINE: printCstring -----
;
; PURPOSE: 	Prints a string onto the screen
;
; DETAILS: 	Inputs an array of characters onto the stack 
;		and uses GEMDOS system calls to output to screen     
; REGISTER TABLE: 
;		d1 - Will hold each character and push it onto the stack 
; 		a1 - Contains the character array

c_string:	equ		8
printCstring: 	
		link		a6,#0 
		movem.l		d0-d2/a0-a2,-(sp)
		move.l		c_string(a6),a1  
print_loop: 
		move.b		(a1)+,d1 
		tst.b		d1 
		beq		print_done 
		move.w		d1,-(sp) 
		move.w		#c_conout,-(sp) 
		trap		#GEMDOS 
		addq.l		#2,sp  
		move.w		d1,(sp)+
		bra		print_loop		
print_done:
		movem.l 	(sp)+,d0-d2/a0-a2
		unlk		a6
		rts

;----- SUBROUTINE: hex2string -----
;
; PURPOSE: 	Converts each bit of a 32-bit IEEE floating point number 
;	   	into its respective characters
; DETAILS: 	Takes in a floating point number 
;		and an array of characters.
; 		First resets the array of characters to NULL.
;		Moves the number into a data register and uses bit shift
;	   	operations to isolate each digit onto another data register. 
; REGISTER TABLE:
;		d0 - Contains the floating point number
;		d1 - Will hold and convert each digit into characters
;		d2 - Counter to traverse each digit of the longword
;		d3 - Array reset counter
;		a0 - Stores each character

number		equ		8 
cstring		equ		12
hex2string:	
		link		a6,#0 
		movem.l		d0-d3/a0,-(sp) 
		move.b		#1,d2 			;counter
 		move.l		number(a6),d0 
		move.l		cstring(a6),a0 
		move.b		#8,d3			;counter 
reset_array:
		move.b		#0,(a0)+
		dbra		d3,reset_array
		suba.w		#9,a0
		clr.l		d3
hex2str_loop: 
		mulu		#4,d2
		move.l		d0,d1  
		rol.l		d2,d1
		and.l		#$F,d1
		cmp.b		#9,d1 
		bhi		hex_letter
hex_number:
		add.w		#'0',d1 
		move.b		d1,(a0)+
		bra		reset_loop
hex_letter: 
		add.w		#'7',d1 
		move.b		d1,(a0)+ 
reset_loop:
		divu		#4,d2
		cmp.b		#8,d2 
		beq		hex2str_done 
		add.b		#1,d2
		bra		hex2str_loop
hex2str_done: 
		move.b		#0,(a0)
		movem.l 	(sp)+,d0-d3/a0
		unlk		a6
		rts 

;----- SUBROUTINE: unpackFloat -----
;
; PURPOSE: 	Seperates a floating point number into 
;		its 3 components, sign, exponent, mantissa, 
;		and stores them in the floatrecord structure.
;
; DETAILS: 	Takes in a floating point number and an address 
;		for the strucutre.
;		Uses a plethera of bit shifting operations in order 
;		to seperate each component.
;
; REGISTER TABLE: 
;		d0 - Holds the floating point number 
;		d1 - Holds a copy of the floating point number 
;		     and does all the bit operations.
; 		a0 - Contains the structure

float_number	equ		8 
float_result1	equ		12
unpackFloat: 
		link		a6,#0 
		movem.l		d0-d1/a0,-(sp) 
		move.l		float_result1(sp),a0		;link structure to a0 
 		move.l		float_number(a6),d0 
		move.l		d0,d1 
		rol.l		#4,d1			
		and.l		#$F,d1 
		cmp.b		#8,d1 
		blt		sign_pos 
sign_neg:		
		move.b		#1,SIGN(a0)
		bra		exponent
sign_pos:
		move.b		#0,SIGN(a0) 
exponent:
		move.l		d0,d1 
		lsl.l		#1,d1 
		rol.l		#8,d1 
		move.b		d1,BIASED_EXPONENT(a0)
mantissa: 
		move.l		d0,d1 
		lsl.l		#1,d1 
		and.l		#$FFFFFF,d1
		lsr.l		#1,d1
		ror.l		#8,d1
		ror.l		#8,d1
		ror.l		#4,d1
		ror.l		#3,d1
		move.b		#$01,d1 	;place hidden one
		rol.l		#3,d1
		rol.l		#4,d1 
		rol.l		#8,d1 
		rol.l		#8,d1
		rol.l		#8,d1 
		move.l		d1,MANTISSA(a0)
		movem.l 	(sp)+,d0-d1/a0
		unlk		a6
		rts 

;----- SUBROUTINE: packFloat -----
;
; PURPOSE: 	Takes components from the floatrecord structure
;		back into a floating point number and returns it
;
; DETAILS: 	Takes in an address for the strucutre.
;		Uses a plethera of bit shifting operations in order 
;		to combine each component.
;
; REGISTER TABLE: 
;		d1 - Will combine the sign and exponent component
;		d2 - Will combine the mantissa component with d1
; 		a0 - Contains the floatrecord structure

float_rec	equ	8
return_float	equ	12
packFloat:
		link	a6,#0 
		movem.l	d0-d2/a0,-(sp)
		move.l	float_rec(a6),a0 
		move.b	SIGN(a0),d1
		lsl.l	#8,d1 
		move.b	BIASED_EXPONENT(a0),d1
 		lsr.l	#1,d1
 		move.l	MANTISSA(a0),d2
		rol.l	#1,d2 
		move.b	#0,d2 
		ror.l	#1,d2
		move.b	d1,d2 
		ror.l	#8,d2 
		move.l	d2,return_float(a6)
		movem.l	(sp)+,d0-d2/a0		
		unlk	a6
		rts

;----- SUBROUTINE: scale ----
;
; PURPOSE: 	Adjusts the value with the smaller exponent value, and correspondingly the
;		associated mantissa value, so that the two floatRecords have the same exponent value.
;
; DETAILS: 	Takes in two floatrecord address and uses a condition
;		to check which of the exponents of the two are smaller.
;		Then will adjust and place it back into the structure.
;
; REGISTER TABLE: 
;		d3 - Will adjust values if needed for unpack1
;		d4 - Will adjust values if needed for unpack2
;		d5 - Used to subtract and find the difference between the exponents 
;		d6 - Will adjust the mantissa for the structure
; 		a0 - Contains a floatrecord structure for unpack1
;		a1 - Contains a floatrecord structure for unpack2

unpack1		equ	8
unpack2		equ	12
scale: 
		link	a6,#0 
		movem.l	d0-d6/a0-a1,-(sp)
		move.l	unpack1(a6),a0 
		move.l	unpack2(a6),a1
		move.b	BIASED_EXPONENT(a0),d3
		move.b	BIASED_EXPONENT(a1),d4
		cmp.b	d4,d3			;compare pack1 to pack 2
		beq	scale_done
		cmp.b	d4,d3
 		bhi	adjust_pack2		;if pack1 is higher
		
		move.b	d4,d5			;if pack1 is lower
		sub.b	d3,d5
		add.b	d5,d3			;exponents now equal 
		move.b	d3,BIASED_EXPONENT(a0)		
		move.l	MANTISSA(a0),d6		;adjust mantissa
		lsr.l	d5,d6
		move.l	d6,MANTISSA(a0)
		bra	scale_done
adjust_pack2:
		move.b	d3,d5
		sub.b	d4,d5
		add.b	d5,d4
		move.b	d4,BIASED_EXPONENT(a1)
		move.l	MANTISSA(a1),d6
		lsr.l	d5,d6
		move.l	d6,MANTISSA(a1)
scale_done:
		movem.l	(sp)+,d0-d6/a0-a1		
		unlk	a6
		rts

;----- SUBROUTINE: add_FP ----
;
; PURPOSE: 	Adds two floating point numbers and returns the result
;
; DETAILS: 	Takes in two floating point numbers and decomposes
;		each of them using the functions unpack and then scales
;		to match exponents and shift mantissas. Does signed magnitude 
;		addition, then renormalizes result and packs it back 
;		into a 32 bit floating point number.
;
; REGISTER TABLE: 
;		d1 - Holds value for operand1
;		d2 - Holds value for operand 2
;		d3 - Holds the added mantissa
; 		a0 - Contains a floatrecord structure for operand1
;		a1 - Contains a floatrecord structure for operand2
;		a2 - Contains the result of the added floating point numbers

operand1	equ	8
operand2	equ	12
result		equ	16

float_record1	equ	-6	
float_record2	equ	-12			
record_result	equ	-18

add_FP:
		link	a6,#-18 
		movem.l	d0-d6/a0-a2,-(sp)
						;check zeroes 
		move.l	operand1(a6),d1 
		move.l	operand2(a6),d2
 		tst.l	d1 
		beq	resultisop2 
		tst.l	d2 
		beq	resultisop1
		clr.l	d1
		clr.l	d2
		bra 	nonzeros		;both are not zeros 
						
resultisop2:	
		move.l	d2,result(a6)
		bra	add_done
resultisop1:
		move.l	d1,result(a6)
		bra	add_done
nonzeros:					;unpack the floats
		pea	float_record1(a6)
		move.l	operand1(a6),-(sp) 
		jsr	unpackFloat
		addq.l	#8,sp
		
		pea	float_record2(a6)
		move.l	operand2(a6),-(sp)
		jsr	unpackFloat
		addq.l	#8,sp
						;scale the floats
		pea	float_record2(a6)
		pea	float_record1(a6)
		jsr	scale
		addq.l	#8,sp

addition:
		lea	float_record1(a6),a0
		lea	float_record2(a6),a1
		lea	record_result(a6),a2
		move.b	BIASED_EXPONENT(a0),BIASED_EXPONENT(a2)	;place exponent in result
						;check if signs are equal
		move.b	SIGN(a0),d1 
		move.b	SIGN(a1),d2 
		cmp.b	d2,d1 
		bne	not_equal 
						;if equal, add mantissas
		move.b	d1,SIGN(a2)		;place sign in result
		move.l	MANTISSA(a0),d1 
		lsr.l	#1,d1
		move.l	MANTISSA(a1),d2 
		lsr.l	#1,d2
		move.l	d1,d3			;d3 will contain mantissa result
		add.l	d2,d3
		move.l	d3,MANTISSA(a2)		;place mantissa in result
renorm:						;after taking result, renormalize 
		pea	record_result(a6) 
		jsr	renormalize
		addq.l	#4,sp
						;pack the number up
		subq.l	#4,sp 
		pea	record_result(a6) 
		jsr	packFloat
		addq.l	#4,sp  
		move.l	(sp)+,result(a6)
		
		bra	add_done
not_equal:					;find large value and subtract it by smaller
		move.l	MANTISSA(a0),d1 
		move.l	MANTISSA(a1),d2 
		cmp.l	d2,d1			;cmp operand1 to operand 2
		bhi	sub_op2_by_op1		
		move.b	SIGN(a1),SIGN(a2)
		move.l	d2,d3 			;sub_op1_by_op2
		sub.l	d1,d3 
		move.l	d3,MANTISSA(a2)
		bra	renorm
sub_op2_by_op1:
		move.b	SIGN(a0),SIGN(a2)
		move.l	d1,d3 
		sub.l	d2,d3 
		move.l	d3,MANTISSA(a2)
		bra	renorm
add_done:
		;move.l	(sp)+,result(a6)
		movem.l	(sp)+,d0-d6/a0-a2		
		unlk	a6
		rts 

;----- SUBROUTINE: renormalize ----
;
; PURPOSE: 	Normalize the result from the added mantissas to ensure the 
;		MSbit is always a 1.
;
; DETAILS: 	Takes in a floatrecord structure and uses bit operations 
;		to find if there exists a carry, if the result is normal, 
;		or if the result has been subtracted that the hidden 1 of
;		the mantissa is a 0.
;
; REGISTER TABLE: 
;		d0 - Holds the mantissa 
;		d5 - Counter that iterates through each bit of the mantissa
;		a0 - Holds the resulting float structure from the added mantissa

rec_result1	equ	8
renormalize:	link	a6,#0
		movem.l	d0-d6/a0-a2,-(sp)
		move.l	rec_result1(a6),a0 
		move.l	MANTISSA(a0),d0
		move.b	#31,d5		;counter
		btst.l	#$31,d0
		bne	carry		;exists a carry bit
		lsl.l	#1,d0
		btst	#$31,d0		;test if normal result
		bne	renorm_done
find_1:					;if 0, find rightest 1
		lsl.l	#1,d0
		sub.b	#1,BIASED_EXPONENT(a0) 
		btst.l	#$31,d0 
		bne	renorm_done	
		dbra	d5,find_1
		bra	renorm_done	;if no 1, number is 0
carry:				
		lsl.l	#1,d0 
		add.b	#1,BIASED_EXPONENT(a0)
renorm_done:
		move.l	d0,MANTISSA(a0)
		movem.l	(sp)+,d0-d6/a0-a2
		unlk	a6
		rts
