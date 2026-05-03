; --- Register Definitions (EQU) ---
    GET     registers.inc
		
	EXPORT check_weight

; Max weight allowed
THRESHOLD   EQU    50

    ; 1. Define the Vector Table Area
    AREA    RESET, DATA, READONLY
    EXPORT  __Vectors
    EXPORT  Reset_Handler    ; Must match your error's capitalization

__Vectors
    DCD     0x20005000     ; Stack Pointer
    DCD     Reset_Handler  ; Reset Vector (Starting point)

    ; 2. Define the Code Area
    AREA    |.text|, CODE, READONLY
    ENTRY                  ; Mark this as the start of execution

Reset_Handler
    ; Enable Clocks for Port A and C
    LDR     R0, =RCC_APB2ENR
    LDR     R1, [R0]
    ORR     R1, R1, #0x14
    STR     R1, [R0]

    ; Configure PC13 as Output (LED)
    LDR     R0, =GPIOC_CRH
    LDR     R1, [R0]
    BIC     R1, R1, #(0xF << 20)
    ORR     R1, R1, #(0x2 << 20)
    STR     R1, [R0]

    ; Configure PA0 (SCK, Out) and PA1 (DT, In)
    LDR     R0, =GPIOA_CRL
    LDR     R1, [R0]
    BIC     R1, R1, #0xFF
    ORR     R1, R1, #0x42
    STR     R1, [R0]

main_loop
    ; Wait for HX711 (ADC) to be ready to send data
    LDR     R4, =GPIOA_IDR
wait_ready
    LDR     R5, [R4]
    TST     R5, #0x02
    BNE     wait_ready

    ; Read 24 Bits
    MOV     R6, #24
    MOV     R7, #0
read_loop
    LDR     R0, =GPIOA_BSRR
    MOV     R1, #1
    STR     R1, [R0]        ; SCK HIGH
    NOP
    NOP
    MOV     R1, #(1 << 16)
    STR     R1, [R0]        ; SCK LOW
    
    LDR     R5, [R4]
    AND     R5, R5, #0x02
    LSR     R5, R5, #1
    LSL     R7, R7, #1
    ORR     R7, R7, R5
    
    SUBS    R6, R6, #1
    BNE     read_loop

    ; 25th pulse
    LDR     R0, =GPIOA_BSRR
    MOV     R1, #1
    STR     R1, [R0]
    NOP
    MOV     R1, #(1 << 16)
    STR     R1, [R0]

    ; Sign Extension
    LSL     R7, R7, #8
    ASR     R7, R7, #8

    ; Threshold Logic
    LDR     R2, =THRESHOLD
    CMP     R7, R2
    LDR     R3, =GPIOC_BSRR
    BGT     led_on

led_off
    MOV     R1, #(1 << 13)  ; LED Off
    STR     R1, [R3]
    B       main_loop

led_on
    MOV     R1, #(1 << 29)  ; LED On
    STR     R1, [R3]
    B       main_loop
	
check_weight
	
    ALIGN
    END