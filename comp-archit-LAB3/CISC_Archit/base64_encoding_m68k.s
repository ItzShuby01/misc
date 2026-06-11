.data
; Base64 Lookup Table 
b64_table: .byte 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'

.org 0x100                         
raw_buffer: .word 0                 ; Temp storage for input string

.text
.org 0x300
_start:
    movea.l 0x1000, A7               ; set Stack Pointer      

    jsr proc_read_input             
    move.l D0, D7                    ; D7 = input length
    
    move.l 0xCCCCCCCC, D1            
    cmp.l D1, D7                     ; Overflow if Length > 0x40
    beq  error_cc

    cmp.l 0, D7                      ; Handle empty input (\n) => empty output
    beq  finish_success

    cmp.l 45, D7                     ; 45 bytes is max that fits in 64-byte B64 buffer
    bgt  error_cc

    move.l D7, D0                    
    jsr proc_encode_base64           ; Encode and stream

finish_success:
    halt

error_cc:
    movea.l 0x84, A1
    move.l 0xCCCCCCCC, (A1)
    halt

; Input : 0x80 -> raw_buffer until '\n'; returns length in D0 or 0xCCCCCCCC if limit exceeded.
proc_read_input:
    link A6, 0
    movea.l 0x80, A0            
    movea.l raw_buffer, A1           
    move.l 0, D0               
read_loop:
    move.b (A0), D1             
    cmp.b 10, D1                ; 10 = ASCII for '\n'
    beq  read_done
    
    cmp.l 63, D0                ; Check buffer boundary (0x40)
    bge  read_ovf
    
    move.b D1, (A1)+            ; Save to buffer
    add.l 1, D0
    jmp  read_loop
read_ovf:
    move.l 0xCCCCCCCC, D0
read_done:
    unlk A6
    rts

; Encoding: Takes 3-byte chunks -> turns them into 4 Base64 characters
proc_encode_base64:
    link A6, -4
    move.l D0, D6               ; counter for Bytes remaining
    movea.l raw_buffer, A0      ; Input pointer
    
encoding_loop:
    cmp.l 0, D6
    ble  encoding_done
    
    move.l 0, D1
    move.l 0, D2
    move.l 0, D3
    
    move.b (A0)+, D1            ; Byte 1
    sub.l 1, D6
    
    cmp.l 0, D6
    beq  pad_2               
    move.b (A0)+, D2            ; Byte 2
    sub.l 1, D6
    
    cmp.l 0, D6
    beq  pad_1               
    move.b (A0)+, D3            ; Byte 3
    sub.l 1, D6

    ; Convert 3 bytes -> 4 indices (6 bits each)
    move.l D1, D4               
    lsr.l 2, D4                 ; Char 1: B1 >> 2
    jsr proc_map_and_output
    
    move.l D1, D4               ; Char 2: ((B1 & 3) << 4) | (B2 >> 4)
    and.l 3, D4
    lsl.l 4, D4
    move.l D2, D5
    lsr.l 4, D5
    or.l D5, D4
    jsr proc_map_and_output

    move.l D2, D4               ; Char 3: ((B2 & 15) << 2) | (B3 >> 6)
    and.l 15, D4
    lsl.l 2, D4
    move.l D3, D5
    lsr.l 6, D5
    or.l D5, D4
    jsr proc_map_and_output
    
    move.l D3, D4               ; Char 4: B3 & 63
    and.l 63, D4
    jsr proc_map_and_output
    jmp  encoding_loop

; Case: only 1 byte left -> XX==
pad_2:
    move.l D1, D4
    lsr.l 2, D4
    jsr proc_map_and_output
    move.l D1, D4
    and.l 3, D4
    lsl.l 4, D4
    jsr proc_map_and_output
    move.l 61, D4               ; ASCII '='
    jsr proc_output_raw
    move.l 61, D4
    jsr proc_output_raw
    jmp  encoding_done

; Case: only 2 bytes left -> XXX=
pad_1:
    move.l D1, D4
    lsr.l 2, D4
    jsr proc_map_and_output
    move.l D1, D4
    and.l 3, D4
    lsl.l 4, D4
    move.l D2, D5
    lsr.l 4, D5
    or.l D5, D4
    jsr proc_map_and_output
    move.l D2, D4
    and.l 15, D4
    lsl.l 2, D4
    jsr proc_map_and_output
    move.l 61, D4               ; ASCII '='
    jsr proc_output_raw

 encoding_done:
    unlk A6
    rts

; Translates 6-bit index D4 -> ASCII character using the lookup table -> sends it to 0x84
proc_map_and_output:
    move.l D0, -(A7)           
    movea.l 0x100, A2           
    move.b 0(A2, D4), D0        
    movea.l 0x84, A1           
    move.b D0, (A1)             
    move.l (A7)+, D0           
    rts

; Streams raw character byte in D4 directly -> address 0x84.
proc_output_raw:
    movea.l 0x84, A1
    move.b D4, (A1)
    rts