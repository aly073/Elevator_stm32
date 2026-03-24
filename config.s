    AREA	myconfig, CODE, READONLY
    EXPORT config
    GET     registers.inc

;============================================================
; Configurations for the stm32 pins etc
;============================================================

config	FUNCTION
	PUSH    {R0-R12, LR}
	; Enable clocks for AFIO(Alternate Function I/O, used for alternate function configuration such as interrupts and for pwm signals), GPIOB, GPIOC
    LDR     R0, =RCC_APB2ENR
    LDR     R1, [R0]
    ORR     R1, R1, #(1 << 0)
    ORR     R1, R1, #(1 << 3)
    ORR     R1, R1, #(1 << 4)
    STR     R1, [R0]



;============================================================
; Configurations for the servo on PB1 (TIM3_CH4)
;============================================================

    ; Enable TIM3 clock (APB1)
    LDR     R0, =RCC_APB1ENR
    LDR     R1, [R0]
    ORR     R1, R1, #(1 << 1)
    STR     R1, [R0]

    ; PB1 -> TIM3_CH4 as Alternate Function Push-Pull (50MHz)
    ; Pin 1 config is bits [7:4] in GPIOB_CRL
    LDR     R0, =GPIOB_CRL
    LDR     R1, [R0]
    BIC     R1, R1, #(0xF << 4)
    ORR     R1, R1, #(0xB << 4) ; Alternate Function Push-Pull, 50MHz 1010
    STR     R1, [R0]

    ; TIM3 setup for SG90 servo PWM (50Hz, 1us tick)
    ; Timer clock assumed 72MHz: PSC=71 -> 1MHz, ARR=19999 -> 20ms period
    LDR     R0, =TIM3_PSC
    LDR     R1, =71
    STR     R1, [R0]

    LDR     R0, =TIM3_ARR
    LDR     R1, =19999
    STR     R1, [R0]

    ; CH4 PWM mode 1 with preload enable (OC4M=110, OC4PE=1)
    LDR     R0, =TIM3_CCMR2
    LDR     R1, [R0]
    BIC     R1, R1, #(0xFF << 8)
    ORR     R1, R1, #((6 << 12) :OR: (1 << 11))
    STR     R1, [R0]

    ; Enable CH4 output, active high
    LDR     R0, =TIM3_CCER
    LDR     R1, [R0]
    ORR     R1, R1, #(1 << 12)
    STR     R1, [R0]

    ; Neutral pulse width for SG90: 1500us
    LDR     R0, =TIM3_CCR4
    LDR     R1, =1500
    STR     R1, [R0]

    ; Load registers and start timer (ARPE + CEN)
    LDR     R0, =TIM3_EGR
    MOV     R1, #1
    STR     R1, [R0]

    LDR     R0, =TIM3_CR1
    LDR     R1, [R0]
    ORR     R1, R1, #(1 << 7)
    ORR     R1, R1, #(1 << 0)
    STR     R1, [R0]


;============================================================
; Configurations for the onboard LED on PC13
;============================================================

    ; Configure PC13 as Output Push-Pull (50MHz)
    ; Mode bits for Pin 13 are in CRH (Control Register High)
    LDR     R0, =GPIOC_CRH
    LDR     R1, [R0]
    BIC     R1, R1, #(0xF << 20) ; Clear bits 20-23
    ORR     R1, R1, #(0x3 << 20) ; Set bits 20-21 (Output mode 50MHz, Push-Pull)
    STR     R1, [R0]


	POP     {R0-R12, PC}
	ENDFUNC

    END