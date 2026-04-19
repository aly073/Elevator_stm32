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
; Configurations for the onboard LED on PC13
;============================================================

    ; Configure PC13 as Output Push-Pull (50MHz)
    ; Mode bits for Pin 13 are in CRH (Control Register High)
    LDR     R0, =GPIOC_CRH
    LDR     R1, [R0]
    BIC     R1, R1, #(0xF << 20) ; Clear bits 20-23
    ORR     R1, R1, #(0x3 << 20) ; Set bits 20-21 (Output mode 50MHz, Push-Pull)
    STR     R1, [R0]


;============================================================
; Configurations for elevator motor on PA0
;============================================================
	
	LDR     R0, =RCC_APB2ENR
    LDR     R1, =0x0000000C    ; 1100 to (GPIOA, GPIOB enable)
    STR     R1, [R0]
	
	LDR     R0, =0x4002101C    ; RCC_APB1ENR 
    LDR     R1, =0x00000001    ; TIM2EN
    STR     R1, [R0]
	
	LDR     R0, =GPIOB_CRH
    LDR     R1, =0x00330000  ; PB12–PB13: Output push-pull, 50MHz
    STR     R1, [R0]
	
	; for pull-up, you must set the ODR bits to 1
	LDR R0, =GPIOB_ODR
    LDR R1, =0x00F3         ; set PB0–PB7 high 
    STR R1, [R0]
	
	; === Configure PA1–PA6 as output (direction pins) and PA0 as PWM
    LDR     R0, =GPIOA_CRL
    LDR     R1, =0x3333333B  ; PA1–PA7: Output push-pull, PA0 = Alternate function push-pull, 50MHz
	; GPIOA Configuration:  CNF=10 (AF-PP), MODE=11 (50MHz)
    STR     R1, [R0]
	
	; TIM2 Configuration
    LDR     R0, =0x40000000    ; TIM2 base
    ; Set prescaler for 1 MHz timer clock (if APB1 = 8 MHz, prescaler = 7)
    LDR     R1, =7
    STRH    R1, [R0, #0x28]    ; TIM2_PSC
    ; Set auto-reload register for 1 kHz PWM (ARR = 999 for 1 kHz)
    LDR     R1, =199
    STR     R1, [R0, #0x2C]    ; TIM2_ARR
    ; Duty cycle for Channel 1 (PA0) = 30%
    LDR     R1, =200
    STR     R1, [R0, #0x34]    ; TIM2_CCR1
	; Set PWM Mode 1 + preload for both channels
    LDR     R1, =0x0060        ; OC1M = 110, OC1PE = 1
    ORR     R1, R1, #0x6000    ; OC2M = 110, OC2PE = 1 (bits 14:12)
    STRH    R1, [R0, #0x18]    ; TIM2_CCMR1
    ; Enable Channel 1 and 2 outputs
    LDRH    R1, [R0, #0x20]
    ORR     R1, R1, #0x0011    ; CC1E = 1, CC2E = 1
    STRH    R1, [R0, #0x20]    ; TIM2_CCER
    ; Enable auto-reload preload (ARPE)
    LDRH    R1, [R0, #0x00]
    ORR     R1, R1, #0x0080
    STRH    R1, [R0, #0x00]    ; TIM2_CR1
    ; Enable counter (CEN)
    LDRH    R1, [R0, #0x00]
    ORR     R1, R1, #1
    STRH    R1, [R0, #0x00]

	POP     {R0-R12, PC}
	ENDFUNC

    END