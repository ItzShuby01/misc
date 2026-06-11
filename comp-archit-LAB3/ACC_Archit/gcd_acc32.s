.text
_start:
    ; --- Single input port at 0x80 ---
    load_addr 0x80      ; first: a -> Acc 
    store_addr a_val    
    
    load_addr 0x80      ; second: b -> Acc 
    store_addr b_val  

    load_addr a_val
    ble handle_neg 
    load_addr b_val
    ble handle_neg

loop:
    load_addr b_val
    beqz end         
    
    load_addr a_val
    rem b_val           ; Acc = a % b
    
    store_addr temp     
    load_addr b_val
    store_addr a_val
    load_addr temp
    store_addr b_val
    
    jmp loop

end:
    load_addr a_val
    store_addr 0x84     ; result -> output port
    halt

handle_neg:
    load_imm -1
    store_addr 0x84
    halt

.data
a_val:  .word 0
b_val:  .word 0
temp:   .word 0