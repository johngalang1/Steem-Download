

GEMDOS                equ        1

SIGN                  equ        0 
BIASED_EXPONENT       equ        1 
MANTISSA              equ        2 
FLOATRECORD           equ        6



print_str:            link       a6,#0 
                      move.l      a0,-(sp) 
                      move.w      #c_conout,-(sp) 
                      TRAP        #GEMDOS 
                      tst.b       (sp) 
                      beq          print_done
                      bra          print_str        
                     

move array into stack 
print out each element of the stack until null 




