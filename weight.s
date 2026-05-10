; --- Register Definitions (EQU) ---
    GET     registers.inc

    EXPORT  __main
    EXPORT  weight_sensor_init
    EXPORT  check_weight

; THE FOLLOWING VALUES ASSUME A 5V INPUT TO THE HX711 ADC
; Max weight allowed (raw value after tare subtraction)
THRESHOLD   EQU    100

; Tare offset – subtract this from raw sensor reading to get zero weight.
; Adjust this value to zero the sensor when no load is applied.
TARE_OFFSET EQU    65000            ; change to calibration value

    AREA    |.text|, CODE, READONLY

__main
    BL      weight_sensor_init

main_loop
    BL      check_weight
    BL      delay_simple
    B       main_loop

; initialize pins
weight_sensor_init
    PUSH    {R1, LR}
    LDR     R0, =RCC_APB2ENR
    LDR     R1, [R0]
    ORR     R1, R1, #0x18
    STR     R1, [R0]
    LDR     R0, =GPIOC_CRH
    LDR     R1, [R0]
    BIC     R1, R1, #(0xF << 20)
    ORR     R1, R1, #(0x2 << 20)
    STR     R1, [R0]
    LDR     R0, =GPIOB_CRH
    LDR     R1, [R0]
    BIC     R1, R1, #(0xFF << 24)
    ORR     R1, R1, #(0x24 << 24)
    STR     R1, [R0]
    POP     {R1, PC}

; checks weight, applies tare offset, and updates LED
check_weight
    PUSH    {R4-R7, LR}

    ; Wait for HX711 Ready (PB14 LOW)
    LDR     R4, =GPIOB_IDR
wait_ready
    LDR     R5, [R4]
    TST     R5, #(1 << 14)
    BNE     wait_ready

    ; Read 24 bits
    MOV     R6, #24
    MOV     R7, #0
read_loop
    LDR     R0, =GPIOB_BSRR
    MOV     R1, #(1 << 15)      ; SCK HIGH
    STR     R1, [R0]
    NOP
    NOP
    MOV     R1, #(1 << 31)      ; SCK LOW
    STR     R1, [R0]

    LDR     R5, [R4]
    TST     R5, #(1 << 14)
    ITE     NE
    MOVNE   R5, #1
    MOVEQ   R5, #0

    LSL     R7, R7, #1
    ORR     R7, R7, R5
    SUBS    R6, R6, #1
    BNE     read_loop

    ; 25th pulse (gain = 128)
    LDR     R0, =GPIOB_BSRR
    MOV     R1, #(1 << 15)
    STR     R1, [R0]
    NOP
    MOV     R1, #(1 << 31)
    STR     R1, [R0]

    ; Sign extend to 32-bit
    LSL     R7, R7, #8
    ASR     R7, R7, #8

    ; Apply tare offset (subtract constant)
    LDR     R0, =TARE_OFFSET
    SUB     R7, R7, R0          ; R7 = raw_value - tare_offset

    ; Threshold check
    LDR     R2, =THRESHOLD
    CMP     R7, R2
    LDR     R3, =GPIOC_BSRR
    BGT     weight_over

weight_under
    MOV     R1, #(1 << 13)      ; LED off (PC13 high)
    STR     R1, [R3]
    POP     {R4-R7, PC}

weight_over
    MOV     R1, #(1 << 29)      ; LED on (PC13 low)
    STR     R1, [R3]
    POP     {R4-R7, PC}

; simple delay
delay_simple
    PUSH    {R2, LR}
    LDR     R2, =120000
delay_simple_loop
    SUBS    R2, R2, #1
    BNE     delay_simple_loop
    POP     {R2, PC}

    ALIGN
    END