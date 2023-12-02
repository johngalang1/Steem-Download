

GEMDOS                equ         1

SIGN                  equ         0 
BIASED_EXPONENT       equ         1 
MANTISSA              equ         2 
FLOAT_RECORD          equ         6

main: 



;----- SUBROUTINE: printCstring -----

c_string:	            equ		       8

printCstring: 	      
                      link		     a6,#0 
    		              addq.l	     #c_string,sp  
		                  move.l		   (sp),a1 
print_loop: 
		                  move.b		   (a1)+,d1 
		                  tst.b		     d1 
                  		beq		       print_done 
                  		move.w		   d1,-(sp) 
                  		move.w		   #c_conout,-(sp) 
                  		trap		     #GEMDOS 
                  		addq.l		   #2,sp  
                  		move.w		   d1,(sp)+
		                  bra		       print_loop		
print_done: 
                      move.l       (sp)+,string
		                  rts 

;----- SUBROUTINE: hex2string ----- 

hex2string:
                      link		     a6,#0 
                      



float_operand2:       ds.l         1                
float_operand1:       ds.l         1         
float_number:         ds.l         1         
char_string:          ds.b         17          ;16 bytes + NULL terminator

result:               ds.b         FLOAT_RECORD
unpack1:              ds.b         FLOAT_RECORD
unpack2:              ds.b         FLOAT_RECORD


