; --- Register Definitions (EQU) ---
    GET     registers.inc
        
    EXPORT check_weight
    EXPORT weight_sensor_init
    IMPORT PLAY_WARNING_AUDIO
    IMPORT delay_systick

; Max weight allowed
THRESHOLD   EQU    50

    ;Define the Code Area
    AREA    |.text|, CODE, READONLY

; initialize pins needed for weight sensor
weight_sensor_init
    PUSH {R1, LR}            ; Corrected: Push LR, not PC

	LDR     R0, =RCC_APB2ENR
    LDR     R1, [R0]
    ORR     R1, R1, #0x18       ; CHANGED: Bit 3 (IOPB) and Bit 4 (IOPC)
    STR     R1, [R0]

    ; Configure PC13 as Output (LED)
    LDR     R0, =GPIOC_CRH
    LDR     R1, [R0]
    BIC     R1, R1, #(0xF << 20)
    ORR     R1, R1, #(0x2 << 20)
    STR     R1, [R0]

    ; Configure PB14 (DT, In) and PB15 (SCK, Out)
    LDR     R0, =GPIOB_CRH      ; CHANGED: Pins 14/15 are in CRH
    LDR     R1, [R0]
    ; Clear bits 24-31 (PB14 and PB15)
    BIC     R1, R1, #(0xFF << 24)
    ; PB14: Input Floating (0x4), PB15: Output 2MHz (0x2) -> 0x24
    ORR     R1, R1, #(0x24 << 24)
    STR     R1, [R0]

    POP {R1, PC}             ; Corrected: Pop into PC to return

; checks weight. acts like while (weight > Threshold) { play warning sound } return
check_weight
	PUSH {R1, LR}

    ; Wait for HX711 Ready (PB14 goes LOW)
    LDR     R4, =GPIOB_IDR
wait_ready
    LDR     R5, [R4]
    TST     R5, #(1 << 14)      ; CHANGED: Check bit 14
    BNE     wait_ready

    ; Read 24 Bits
    MOV     R6, #24
    MOV     R7, #0
read_loop
    LDR     R0, =GPIOB_BSRR
    MOV     R1, #(1 << 15)      ; CHANGED: PB15 (SCK) HIGH
    STR     R1, [R0]        
    NOP
    NOP
    MOV     R1, #(1 << 31)      ; CHANGED: PB15 (SCK) LOW (15 + 16 = 31)
    STR     R1, [R0]        
    
    LDR     R5, [R4]
    TST     R5, #(1 << 14)      ; CHANGED: Check PB14
    ITE     NE                  ; Conditional instruction for compact bit handling
    MOVNE   R5, #1
    MOVEQ   R5, #0
    
    LSL     R7, R7, #1
    ORR     R7, R7, R5
    
    SUBS    R6, R6, #1
    BNE     read_loop

    ; 25th pulse
    LDR     R0, =GPIOB_BSRR
    MOV     R1, #(1 << 15)      ; CHANGED: PB15 HIGH
    STR     R1, [R0]
    NOP
    MOV     R1, #(1 << 31)      ; CHANGED: PB15 LOW
    STR     R1, [R0]

    ; Sign Extension
    LSL     R7, R7, #8
    ASR     R7, R7, #8

    ; Threshold Logic
    LDR     R2, =THRESHOLD
    CMP     R7, R2
    LDR     R3, =GPIOC_BSRR
    BGT     weight_over

weight_under
    MOV     R1, #(1 << 13)      ; LED Off (PC13 High)
    STR     R1, [R3]
    POP 	{R1, PC}

weight_over
    MOV     R1, #(1 << 29)      ; LED On (PC13 Low)
    STR     R1, [R3]
	BL		PLAY_WARNING_AUDIO
	BL 		delay_audio
    B       wait_ready

; small delay for audio
delay_audio
    PUSH    {R2, LR}
    LDR     R2, =2800000       ; Loop counter for ~2 second delay
delay_audio_loop
    SUBS    R2, R2, #1
    BNE     delay_audio_loop
    POP     {R2, PC}

    ALIGN
    END