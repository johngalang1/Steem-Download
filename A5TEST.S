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
		movem.l		d0-d2/a0-a2,-(sp) 
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
		movem.l 	(sp)+,d0-d2/a0-a2
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
		movem.l		d0-d2/a0-a2,-(sp) 
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
		movem.l 	(sp)+,d0-d2/a0-a2
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
		movem.l	d0-d2/a0-a2,-(sp)
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
		movem.l	(sp)+,d0-d2/a0-a2		
		unlk	a6
		rts

;----- SUBROUTINE: scale ----
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
; 		a0 - Contains a floatrecord structure to compare
;		a1 - Contains a floatrecord structure to compare

unpack1		equ	8
unpack2		equ	12
scale: 
		link	a6,#0 
		movem.l	d0-d6/a0-a2,-(sp)
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
		movem.l	(sp)+,d0-d6/a0-a2		
		unlk	a6
renormalize: 
		rts
add_FP:
		rts 
