.data
n:      .word 0
count:  .word 0

.text
_start:
    @p 0x80              \ input -> stack
    !p n

    count_zero_procedure 

    @p count
    !p 0x84               \ stack -> output

    halt

count_zero_procedure:     \ Initializes 'count' = 0 and sets 32-iteration loop.
    lit 0
    !p count

    lit 31
    >r

loop:                     \ Isolates the LSB of 'n' to check if it is a 0.
    @p n
    lit 1
    and

    if found_zero

    shift_step ;

found_zero:               \ Adds 1 to current count -> save back to memory
    @p count 
    lit 1
    +
    !p count

shift_step:               \ Shifts 'n' right by 1 and handles loop
    @p n
    2/
    !p n

    next loop
    ;