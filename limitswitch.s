; this file will hold interrupt for limit switch which plays emergency audio if line is cut
; it will also have code to go down to floor 1 on startup

; -------------------------------------------------------------------------
; STM32 Blue Pill - Audio System File (USART2 on PA2)
; -------------------------------------------------------------------------

        AREA    |.data|, DATA, READWRITE
        ALIGN
initialized DCD 0               ; Variable initialized to 0

        AREA    |.text|, CODE, READONLY
        ALIGN
        GET registers.inc
        IMPORT STOP
        IMPORT PLAY_EMERGENCY_AUDIO ; Imported to resolve the branch link
		IMPORT currentFloor
		IMPORT GO_UP
		EXPORT initialized

    EXPORT limit_switch_init
limit_switch_init

    PUSH {r0,r1,lr}

    ; Enable clocks: AFIO and GPIOA (RCC_APB2ENR |= AFIOEN | GPIOA)
    LDR r0, =RCC_APB2ENR
    LDR r1, [r0]
    LDR r2, =RCC_APB2ENR_AFIOEN
    ORR r1, r1, r2
    LDR r2, =RCC_APB2ENR_GPIOA
    ORR r1, r1, r2
    STR r1, [r0]

    ; Configure PA8 as input pull-up (CRH bits for pin8 = CNF=10, MODE=00 -> 0x8)
    LDR r0, =GPIOA_CRH
    LDR r1, [r0]
    BIC r1, r1, #0xF        ; clear bits [3:0] for pin8
    ORR r1, r1, #0x8        ; set CNF=10, MODE=00
    STR r1, [r0]

    ; Set ODR bit for PA8 to select pull-up
    LDR r0, =GPIOA_ODR
    LDR r1, [r0]
    ORR r1, r1, #(1 << 8)
    STR r1, [r0]

    ; Map EXTI8 --> Port A via AFIO_EXTICR3[3:0] = 0 (use RMW)
    LDR r0, =AFIO_EXTICR3
    LDR r1, [r0]
    BIC r1, r1, #0xF        ; clear EXTI8 field
    STR r1, [r0]

    ; Unmask EXTI line 8 (RMW)
    LDR r0, =EXTI_IMR
    LDR r1, [r0]
    ORR r1, r1, #(1 << 8)
    STR r1, [r0]

    ; Trigger on falling edge only (RMW)
    LDR r0, =EXTI_RTSR
    LDR r1, [r0]
    BIC r1, r1, #(1 << 8)
    STR r1, [r0]
    LDR r0, =EXTI_FTSR
    LDR r1, [r0]
    ORR r1, r1, #(1 << 8)
    STR r1, [r0]

    ; Clear any pending EXTI8 (W1C - write only the bit to clear)
    LDR r0, =EXTI_PR
    MOV r1, #(1 << 8)
    STR r1, [r0]
	
	LDR R0, =initialized
	MOV R1, #0
	STR R1, [R0]

    POP {r0,r1,pc}



    EXPORT limit_switch_isr
limit_switch_isr
    PUSH {lr}
	
	; clear pending bit for EXTI8 (W1C - do NOT RMW here)
    LDR R0, =EXTI_PR
    MOV R1, #(1 << 8)
    STR R1, [R0]

    ; Load the 'initialized' variable
    LDR     r2, =initialized
    LDR     r3, [r2]
    CMP     r3, #0
    BNE     emergency_action    ; If initialized != 0, skip to emergency audio

startup_action
	
	BL GO_UP

wait_pa15_low
    LDR     r0, =GPIOA_IDR
    LDR     r1, [r0]
    TST     r1, #(1 << 15)
    BNE     wait_pa15_low	
	
	BL STOP
    
	
	; Set 'initialized' to 1 so this block never runs again
	LDR 	r2, =initialized
    MOV     r3, #1
    STR     r3, [r2]

	B       end_isr             ; Exit the ISR

	
emergency_action
    CPSID i                     ; disable all maskable interrupts

    ; Disable all NVIC IRQ lines (ICER0..2) with all-ones mask
    MVN     R1, #0              ; 0xFFFFFFFF
    LDR     R0, =0xE000E180     ; NVIC_ICER0
    STR     R1, [R0]
    LDR     R0, =0xE000E184     ; NVIC_ICER1
    STR     R1, [R0]
    LDR     R0, =0xE000E188     ; NVIC_ICER2
    STR     R1, [R0]

    ; Clear all pending NVIC IRQs (ICPR0..2)
    LDR     R0, =0xE000E280     ; NVIC_ICPR0
    STR     R1, [R0]
    LDR     R0, =0xE000E284     ; NVIC_ICPR1
    STR     R1, [R0]
    LDR     R0, =0xE000E288     ; NVIC_ICPR2
    STR     R1, [R0]

    BL STOP                     ; turn off motor
    BL PLAY_EMERGENCY_AUDIO     ; play audio

end_isr
	
	MOV R0, 1000
small_loop
	subs r0, r0, #1
	bne small_loop
	
	
	; clear pending bit for EXTI8 (W1C - do NOT RMW here)
    LDR R0, =EXTI_PR
    MOV R1, #(1 << 8)
    STR R1, [R0]

    POP {pc}

        END