.text
.org 0x100
_start:
    lui  sp, 1 / addi s1, zero, 128 / nop / nop               ; s1 = Input (0x80)
    addi s2, zero, 132 / addi s3, zero, 3 / nop / nop         ; s2 = Output (0x84), 
    addi s4, zero, 2 / addi s5, zero, 4 / nop / nop           
    addi s7, zero, 31 / nop / nop / nop                      
    
    nop / nop / lw s6, 0(s1) / nop                            ; s6 = N (number of pairs)
    
    nop / nop / nop / blt s6, zero, domain_error
    
    nop / nop / nop / beqz s6, finish

main_loop:
    nop / nop / nop / beqz s6, finish
    
    nop / nop / lw s10, 0(s1) / nop                           ; s10 = x
    nop / nop / lw s11, 0(s1) / nop                           ; s11 = y
    
    ; u = 3*x + 2*y + 5
    mul  t2, s10, s3 / mul  t3, s11, s4 / nop / nop          
    mulh s8, s10, s3 / mulh s9, s11, s4 / nop / nop           ; Get high parts of multiplications
    
    ; Check multiplication overflows
    sra  t5, t2, s7 / sra  t6, t3, s7 / nop / nop             
    nop / nop / nop / bne  t5, s8, overflow          
    nop / nop / nop / bne  t6, s9, overflow         

    add  t4, t2, t3 / nop / nop / nop                         ; t4 = 3*x + 2*y
    
    ; Check Addition Overflows
    xor  t5, t4, t2 / xor  t6, t4, t3 / nop / nop             
    and  t5, t5, t6 / nop / nop / nop                      
    nop / nop / nop / blt  t5, zero, overflow 
    
    addi s8, t4, 5 / nop / nop / nop                          ; s8 = u = 3*x + 2*y + 5
    
    ; Check overflow (+5)
    xor  t5, s8, t4 / xor  t6, s8, zero / nop / nop          
    and  t5, t5, t6 / nop / nop / nop                         
    nop / nop / nop / blt  t5, zero, overflow        
    

    ; v = -x + 4*y - 7
    sub  t2, zero, s10 / lui t5, 524288 / nop / nop           ; t2 = -x, t5 = MinInt
    nop / nop / nop / beq  s10, t5, overflow         
    
    mul  t3, s11, s5 / mulh s9, s11, s5 / nop / nop           ; t3 = 4*y, s9 = high part
    sra  t6, t3, s7 / nop / nop / nop                        
    nop / nop / nop / bne  t6, s9, overflow                   ; Check 4*y overflow
    
    add  t4, t2, t3 / nop / nop / nop                         ; t4 = -x + 4*y
    
    ; Check Addition Overflow
    xor  t5, t4, t2 / xor  t6, t4, t3 / nop / nop           
    and  t5, t5, t6 / nop / nop / nop                         
    nop / nop / nop / blt  t5, zero, overflow        
    
    addi s9, t4, -7 / addi t0, zero, -7 / nop / nop           ; s9 = v = -x + 4*y - 7, t0 = -7 
    
    ; Check overflow (-7)
    xor  t5, s9, t4 / xor  t6, s9, t0 / nop / nop            
    and  t5, t5, t6 / nop / nop / nop                         
    nop / nop / nop / blt  t5, zero, overflow        
    
    ;  Output : write u -> 0x84
    addi s6, s6, -1 / nop / sw s8, 0(s2) / nop               
    nop / nop / sw s9, 0(s2) / j main_loop               

domain_error:
    addi t0, zero, -1 / nop / nop / nop                      
    nop / nop / sw t0, 0(s2) / j finish                 

overflow:
    lui  t0, 838860 / addi t1, zero, 1638 / nop / nop         
    add  t1, t1, t1 / nop / nop / nop                         
    or   t0, t0, t1 / nop / nop / nop                         ; t0 = 0xCCCCCCCC
    nop / nop / sw t0, 0(s2) / j finish                 

finish:
    nop / nop / nop / halt