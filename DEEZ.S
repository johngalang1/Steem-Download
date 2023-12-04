SIGN	equ	0
EXP	equ	1
MANTIS	equ	2
FLOAT	equ	6 

start: 
	pea	float_record
	move.l	#$C138ABCD,-(sp) 
	jsr	unpackFloat

unpackFloat: 
		link	a6,#0 
		movem.l	d0-d2/a0-a2,-(sp) 
		move.l	12(a6),a0		


		movem.l	(sp)+,d0-d2/a0-a2 
		unlk	a6		
		rts

float_record:	ds.b	FLOAT
deez:		dc.b	"deeznuts",0