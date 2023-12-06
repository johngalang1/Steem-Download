SIGN	equ	0
BIASED_EXPONENT	equ	1
MANTISSA	equ	2
FLOAT	equ	6 

start: 
	pea	float_record1
	move.l	#$C138ABCD,-(sp) 
	jsr	unpackFloat
	addq.l	#8,sp

	pea	float_record2
	move.l	#$44640000,-(sp) 
	jsr	unpackFloat
	addq.l	#8,sp
	
	subq.l	#4,sp 
	pea	float_record1 
	jsr	packFloat
	addq.l	#4,sp
	move.l	(sp)+,d1

	subq.l	#4,sp 
	pea	float_record2 
	jsr	packFloat
	addq.l	#4,sp
	move.l	(sp)+,d2
	
	pea	float_record2
	pea	float_record1
	jsr	scale 
	addq.l	#8,sp

operand1	equ	8
operand2	equ	12
add_FP:
		link	a6,#0 
		movem.l	d0-d6/a0-a2,-(sp)
		move.l	
	

		movem.l	(sp)+,d0-d6/a0-a2		
		unlk	a6
		rts 

unpack1		equ	8
unpack2		equ	12
scale: 
		link	a6,#0 
		movem.l	d0-d6/a0-a2,-(sp)
		move.l	unpack1(a6),a0 
		move.l	unpack2(a6),a1
		move.b	BIASED_EXPONENT(a0),d3
		move.b	BIASED_EXPONENT(a1),d4
		cmp.b	d4,d3		;compare pack1 to pack 2
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

float_num	equ	8
float_res	equ	12
unpackFloat: 
		link	a6,#0 
		movem.l	d0-d2/a0-a2,-(sp) 
		move.l	float_res(a6),a0		;structure in a0
 		move.l	float_num(a6),d0 
		move.l	d0,d1 
		rol.l	#4,d1			
		and.l	#$F,d1 
		cmp.b	#8,d1 
		blt	sign_pos 
sign_neg:		
		move.b	#1,SIGN(a0)
		bra	exponent
sign_pos:
		move.b	#0,SIGN(a0) 
exponent:
		move.l	d0,d1 
		lsl.l	#1,d1 
		rol.l	#8,d1 
		move.b	d1,BIASED_EXPONENT(a0)
mantissa: 
		move.l	d0,d1 
		lsl.l	#1,d1 
		and.l	#$FFFFFF,d1
		lsr.l	#1,d1
		ror.l	#8,d1
		ror.l	#8,d1
		ror.l	#4,d1
		ror.l	#3,d1
		move.b	#$01,d1 
		rol.l	#3,d1
		rol.l	#4,d1 
		rol.l	#8,d1 
		rol.l	#8,d1
		rol.l	#8,d1 
		move.l	d1,MANTISSA(a0)
		movem.l	(sp)+,d0-d2/a0-a2 
		unlk	a6		
		rts

float_record1:	ds.b	FLOAT
float_record2:	ds.b	FLOAT
deez:		dc.b	"deeznuts",0
