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
; PURPOSE: Prints a string onto the screen
;
; CALLER INPUT: Inputs an array of characters onto the stack 
;		and uses GEMDOS system calls to output to screen               

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
; PURPOSE: Converts each bit of a 32-bit IEEE floating point number 
;	   into its respective characters
; CALLER INPUT: Takes
;
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
; PURPOSE: Converts each bit of a 32-bit IEEE floating point number 
;	   into its respective characters
; CALLER INPUT: Takes
;
float_number:	equ		8 
float_result1:	equ		12
unpackFloat: 
		link		a6,#0 
		movem.l		d0-d2/a0-a2,-(sp) 
		move.l		12(sp),a0		;link structure to a0 
 		move.l		8(a6),d0 
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
		move.b		d1,EXP(a0)
mantissa: 
		move.l		d0,d1 
		lsl.l		#1,d1 
		and.l		#$FFFFFF,d1
		lsr.l		#1,d1
		ror.l		#8,d1
		ror.l		#8,d1
		ror.l		#4,d1
		ror.l		#3,d1
		move.b		#$01,d1 
		rol.l		#3,d1
		rol.l		#4,d1 
		rol.l		#8,d1 
		rol.l		#8,d1
		rol.l		#8,d1 
		move.l		d1,MANTISSA(a0)
		movem.l 	(sp)+,d0-d2/a0-a2
		unlk		a6
		rts 

packFloat:	
		rts 
scale: 
		rts 
renormalize: 
		rts
add_FP:
		rts 
