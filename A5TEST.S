		xdef		add_FP
 		xdef		unpackFloat 
		xdef		packFloat 
		xdef		scale 
		xdef		renormalize 
		xdef		printCstring 
		xdef 		hex2string

		include		gemdos.i

GEMDOS		equ		1


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


number		equ		8 
cstring		equ		12
hex2string:	
		link		a6,#0 
		movem.l		d0-d2/a0-a2,-(sp) 
		move.b		#1,d2 			;counter
 		move.l		number(a6),d0 
		lea		cstring(a6),a0
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

add_FP:
		rts 
unpackFloat: 
		rts 
packFloat:	
		rts 
scale: 
		rts 
renormalize: 
		rts
