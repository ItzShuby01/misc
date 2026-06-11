.data
buffer: .byte 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f

.text
.org 0x200
_start:

    lui  sp, %hi(0x1000)
    addi sp, sp, %lo(0x1000)

    ; Input Port
    lui  s1, %hi(0x80)        
    addi s1, s1, %lo(0x80)    

    ; Output Port
    lui  s2, %hi(0x84)       
    addi s2, s2, %lo(0x84)    

    ; Buffer
    lui  s3, %hi(buffer)     
    addi s3, s3, %lo(buffer)
    
    jal  ra, proc_read_string
    
    halt

proc_read_string:
    addi sp, sp, -12
    sw   ra, 8(sp)
    sw   s4, 4(sp)          ; index i
    sw   s5, 0(sp)          ; current char
    
    addi s4, zero, 0

read_loop:
    lw   s5, 0(s1)         
    addi t1, zero, 255      ; Mask
    and  s5, s5, t1         ; Get byte
    
    addi t0, zero, 10       ; ASCII '\n' = 10
    beq  s5, t0, read_finished

    addi t1, zero, 30
    bgt  s4, t1, error_overflow
    
    add  t2, s3, s4
    sb   s5, 0(t2)
    
    addi s4, s4, 1
    j    read_loop

read_finished:
    add  t2, s3, s4
    sb   zero, 0(t2)
    
    addi a0, s3, 0        
    jal  ra, proc_transform_recursive
    j    proc_read_done

error_overflow:
    lui  t0, 838860         ; Upper 0xCCCCC
    addi t1, zero, 1638     ; 0x666
    add  t1, t1, t1         ; 0xCCC
    or   t0, t0, t1         
    sw   t0, 0(s2)          ; Output error -> 0x84
    j    proc_read_done

proc_read_done:
    lw   s5, 0(sp)
    lw   s4, 4(sp)
    lw   ra, 8(sp)
    addi sp, sp, 12
    jr   ra

proc_transform_recursive:
    addi sp, sp, -8
    sw   ra, 4(sp)
    sw   s6, 0(sp)          ; current ptr
    
    addi s6, a0, 0
    
    lw   t0, 0(s6)
    addi t1, zero, 255
    and  t0, t0, t1         ; Load and mask
    
    beqz t0, proc_rec_done  ; Base case: null terminator
    
    addi a0, t0, 0
    jal  ra, proc_convert_char
    
    sb   a0, 0(s6)
    sw   a0, 0(s2)
    
    addi a0, s6, 1
    jal  ra, proc_transform_recursive  ; Recurse

proc_rec_done:
    lw   s6, 0(sp)
    lw   ra, 4(sp)
    addi sp, sp, 8
    jr   ra

proc_convert_char:
    addi t0, zero, 97       ; 'a'
    addi t1, zero, 122      ; 'z'
    
    ble  a0, t0, conv_skip
    bgt  a0, t1, conv_skip
    
    addi a0, a0, -32        ; to Upper

conv_skip:
    jr   ra