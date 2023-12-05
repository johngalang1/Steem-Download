SIGN	equ	0
BIASED_EXPONENT	equ	1
MANTISSA	equ	2
FLOAT	equ	6 

start: 
	pea	float_record
	move.l	#$44640000,-(sp) 
	jsr	unpackFloat
	addq.l	#8,sp
	
	subq.l	#4,sp 
	pea	float_record 
	jsr	packFloat
	addq.l	#4,sp
	move.l	(sp)+,d1

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

unpackFloat: 
		link	a6,#0 
		movem.l	d0-d2/a0-a2,-(sp) 
		move.l	12(a6),a0		;structure in a0
 		move.l	8(a6),d0 
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

float_record:	ds.b	FLOAT
deez:		dc.b	"deeznuts",0
