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
test:
	clr.l	d1
	clr.l	d2
	clr.l	d3
	subq.l	#4,sp
	move.l	#$FFFFFFFF,-(sp)
	move.l	#$FFFFFFFF,-(sp)
	jsr	add_FP
	addq.l	#8,sp
	addq.l	#4,sp
	move.l	(sp)+,d5
	
operand1	equ	8
operand2	equ	12
result		equ	16
add_FP:
		link	a6,#0 
		movem.l	d0-d6/a0-a2,-(sp)
						;check zeroes 
		move.l	operand1(a6),d1 
		move.l	operand2(a6),d2
 		tst.l	d1 
		beq	resultisop2 
		tst.l	d2 
		beq	resultisop1
		bra 	nonzeros		;both are not zeros 
						
resultisop2:	
		move.l	d2,result(a6)
		bra	add_done
resultisop1:
		move.l	d1,result(a6)
		bra	add_done
nonzeros:					;unpack the floats
		pea	float_record1
		move.l	operand1(a6),-(sp) 
		jsr	unpackFloat
		addq.l	#8,sp
		
		pea	float_record2
		move.l	operand2(a6),-(sp)
		jsr	unpackFloat
		addq.l	#8,sp
						;scale the floats
		pea	float_record2
		pea	float_record1
		jsr	scale
		addq.l	#8,sp

addition:
		pea	record_result		;holds the result of addition
		pea	float_record2
		pea	float_record1
		move.l	(sp),a0 
		move.l	4(sp),a1
		move.l	8(sp),a2
		move.b	BIASED_EXPONENT(a0),BIASED_EXPONENT(a2)	;place exponent in result
						;check if signs are equal
		move.b	SIGN(a0),d1 
		move.b	SIGN(a1),d2 
		cmp.b	d2,d1 
		bne	not_equal 
						;if equal, add mantissas
		move.b	d1,SIGN(a2)		;place sign in result
		move.l	MANTISSA(a0),d1 
		move.l	MANTISSA(a0),d2 
		move.l	d1,d3			;d3 will contain mantissa result
		add.l	d2,d3 
		move.l	d3,MANTISSA(a2)		;place mantissa in result
						;after taking result, renormalize 
		pea	record_result 
		jsr	renormalize
		addq.l	#4,sp
						;pack the number up
		subq.l	#4,sp 
		pea	record_result 
		jsr	packFloat
		addq.l	#4,sp  
		bra	add_done



add_done:
		addq.l	#8,sp 
		addq.l	#4,sp
		movem.l	(sp)+,d0-d6/a0-a2		
		unlk	a6
		rts 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
renormalize:	link	a6,#0
		movem.l	d0-d6/a0-a2,-(sp)
		movem.l	(sp)+,d0-d6/a0-a2
		unlk	a6
		rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
record_result:	ds.b	FLOAT
