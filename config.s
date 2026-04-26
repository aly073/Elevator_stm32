    AREA	myconfig, CODE, READONLY
    EXPORT config
    GET     registers.inc
    IMPORT  matrix_init
    IMPORT  draw_initial_state
    IMPORT  elevatorState
    IMPORT  currentFloor
    IMPORT  requests
    IMPORT  current_num
    IMPORT  target_num
    IMPORT  anim_step
    IMPORT  anim_active
    IMPORT  pending_stop
    IMPORT  pending_dir


;============================================================
;   PIN CONNECTIONS:
;   - PC13: Onboard LED
;   - PB0: Elevator motor control (TIM3_CH3 PWM output)
;   - PB10: Elevator up Direction control (GPIO output)
;   - PB11: Elevator down Direction control (GPIO output)
;
;   - Buttons (functional mapping used by IRQ code):
;     - PA0: Floor 1 request button (EXTI0)
;     - PA1: Floor 2 up button (EXTI1)
;     - PA2: Floor 2 down button (EXTI2)
;     - PA3: Floor 3 request button (EXTI3)
;     - PB7: Floor 2 car button (inside elevator) (EXTI7)
;
;   - Sensors (functional mapping used by IRQ code):
;     - PB8: Floor 1 sensor (EXTI8)
;     - PB5: Floor 2 sensor (EXTI5)
;     - PA6: Floor 3 sensor (EXTI6)
;
;   - LED Matrix:
;     - SPI Pins: PA5 (CLK), PA7 (DIN), PA4 (CS)
;============================================================

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
    
    LDR R0, =RCC_APB2ENR
    LDR R1, [R0]
    LDR R2, =0x100D
    ORR R1, R1, R2
    STR R1, [R0]
    
    LDR R0, =RCC_APB1ENR
    LDR R1, [R0]
    ORR R1, R1, #0x01
    STR R1, [R0]

    LDR R0, =GPIOA_BASE
    LDR R1, =0xB8B38888
    STR R1, [R0, #GPIOx_CRL]
    MOV R1, #CS_PIN
    STR R1, [R0, #GPIOx_ODR]

    LDR R0, =GPIOB_BASE
    LDR R1, [R0, #GPIOx_CRL]
    LDR R2, =0xF0F00000
    BIC R1, R1, R2
    LDR R2, =0x80800000
    ORR R1, R1, R2
    STR R1, [R0, #GPIOx_CRL]

    LDR R1, [R0, #GPIOx_CRH]
    LDR R2, =0x0000FF0F
    BIC R1, R1, R2
    LDR R2, =0x00007708
    ORR R1, R1, R2
    STR R1, [R0, #GPIOx_CRH]
    
    MOV R1, #0
    STR R1, [R0, #GPIOx_ODR]

    LDR R0, =AFIO_EXTICR2
    LDR R1, =0x1010
    STR R1, [R0]
    LDR R0, =AFIO_EXTICR3
    LDR R1, =0x0001
    STR R1, [R0]

    LDR R0, =EXTI_IMR
    LDR R1, =0x01EF
    STR R1, [R0]
    LDR R0, =EXTI_RTSR
    STR R1, [R0]

    LDR R0, =TIM2_BASE
    LDR R1, =7999
    STR R1, [R0, #0x28]
    LDR R1, =99
    STR R1, [R0, #0x2C]
    MOV R1, #1
    STR R1, [R0, #0x0C]
    MOV R1, #0
    STR R1, [R0, #0x00]

    LDR R0, =NVIC_ISER0
    LDR R1, =0x108003C0
    STR R1, [R0]

;============================================================
; INITIAL STATE
;============================================================

    LDR R0, =elevatorState
    MOV R1, #STOPPED
    STRB R1, [R0]
    LDR R0, =currentFloor
    MOV R1, #1
    STRB R1, [R0]
    
    LDR R0, =requests
    MOV R1, #0
    STRB R1, [R0, #0]
    STRB R1, [R0, #1]
    STRB R1, [R0, #2]
    STRB R1, [R0, #3]
    STRB R1, [R0, #4]

    LDR R0, =current_num
    MOV R1, #0
    STR R1, [R0]
    LDR R0, =target_num
    STR R1, [R0]
    LDR R0, =anim_step
    STR R1, [R0]
    LDR R0, =anim_active
    STR R1, [R0]
    LDR R0, =pending_stop
    STR R1, [R0]
    LDR R0, =pending_dir
    STR R1, [R0]

    BL matrix_init
    BL draw_initial_state


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
; Configurations for elevator motor on PB0
;============================================================
	
	LDR     R0, =RCC_APB2ENR
    LDR     R1, [R0]
    ORR     R1, R1, #0x0000000D    ; AFIO, GPIOA, GPIOB enable
    STR     R1, [R0]

    ; Configure PB0 as Alternate Function Push-Pull, 50MHz (TIM3_CH3 PWM output)
    LDR     R0, =GPIOB_CRL
    LDR     R1, [R0]
    BIC     R1, R1, #0xF
    ORR     R1, R1, #0xB
    STR     R1, [R0]

    LDR R0, =RCC_APB1ENR
    LDR R1, [R0]
    ORR R1, R1, #0x02    ; Use ORR instead of STR to keep TIM2 running
    STR R1, [R0]

    
	
	; TIM3 Configuration
    LDR     R0, =0x40000400    ; TIM3 base
    ; Set prescaler for 1 MHz timer clock (if APB1 = 8 MHz, prescaler = 7)
    LDR     R1, =7
    STRH    R1, [R0, #0x28]    ; TIM3_PSC
    ; Set auto-reload register for 1 kHz PWM (ARR = 999 for 1 kHz)
    LDR     R1, =199
    STR     R1, [R0, #0x2C]    ; TIM3_ARR
    ; Duty cycle for Channel 3 (PB0) = 30%
    LDR     R1, =200
    STR     R1, [R0, #0x3C]    ; TIM3_CCR3
	; Set PWM Mode 1 + preload for channel 3
    LDRH    R1, [R0, #0x1C]    ; TIM3_CCMR2
    BIC     R1, R1, #0x0078
    ORR     R1, R1, #0x0068    ; OC3M = 110, OC3PE = 1
    STRH    R1, [R0, #0x1C]    ; TIM3_CCMR2
    ; Enable Channel 3 output
    LDRH    R1, [R0, #0x20]
    ORR     R1, R1, #0x0100    ; CC3E = 1
    STRH    R1, [R0, #0x20]    ; TIM3_CCER
    ; Enable auto-reload preload (ARPE)
    LDRH    R1, [R0, #0x00]
    ORR     R1, R1, #0x0080
    STRH    R1, [R0, #0x00]    ; TIM3_CR1
    ; Enable counter (CEN)
    LDRH    R1, [R0, #0x00]
    ORR     R1, R1, #1
    STRH    R1, [R0, #0x00]

	POP     {R0-R12, PC}
	ENDFUNC

    END