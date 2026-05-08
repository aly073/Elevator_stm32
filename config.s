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
	IMPORT  hardware_init_audio
    IMPORT  weight_sensor_init
    IMPORT  bluetooth_init
    IMPORT  rfid_init


;============================================================
;	Pins with UART capabilities: 
;	  UART1: PA9 (TX), PA10 (RX)
;	  UART2: PA2 (TX), PA3 (RX)
;	  UART3: PB10 (TX), PB11 (RX)
;
;   PIN CONNECTIONS:
;   - PC13: Onboard LED
;   - PB0: Elevator motor control (TIM3_CH3 PWM output)
;   - PB1: Elevator up Direction control (GPIO output)
;   - PB11: Elevator down Direction control (GPIO output)
;
;   - Buttons (functional mapping used by IRQ code):
;     - PA0: Floor 1 request button (EXTI0)
;     - PA1: Floor 2 up button (EXTI1)
;     - PB4: Floor 2 down button (EXTI4)
;     - PB3: Floor 3 request button (EXTI3)
;     - PB7: Floor 2 cabin button (inside elevator) (EXTI7)
;
;   - Sensors (functional mapping used by IRQ code):
;     - PB8: Floor 1 sensor (EXTI8)
;     - PB5: Floor 2 sensor (EXTI5)
;     - PB6: Floor 3 sensor (EXTI6) -- SHOULD BE CHANGED
;
;   - LED Matrix:
;     - SPI Pins: PA5 (CLK), PA7 (DIN), PA4 (CS)

;    - RFID:
;      - SPI Pins: PA5 (CLK), PA7 (DIN), PA6 (MISO), PB12 (CS), PA8 (RST)
;
;	- Audio:
;	  - PA2 (RX)
;      - PA3 (TX)
;
;	- Load Cell:
;	  - PB14: DT
;	  - PB15: SCK

;
;	- Bluetooth:
;	  - PA9: TX
;	  - PA10: RX

;    - REMAINING PINS:
;        PA11, PA12, PA15
;        PB2, PB9, PB10, PB13

;============================================================

;============================================================
; Configurations for the stm32 pins etc
;============================================================

config    FUNCTION
    PUSH    {R0-R12, LR}
	
	BL 		rfid_init 	; Keep this first because it doesnt modify safely (breaks if you try to change)
	
    ; Enable clocks for AFIO, GPIOB, GPIOC
    LDR     R0, =RCC_APB2ENR
    LDR     R1, [R0]
    ORR     R1, R1, #(1 << 0)
    ORR     R1, R1, #(1 << 3)
    ORR     R1, R1, #(1 << 4)
    STR     R1, [R0]

    ; Disable JTAG but keep SWD so PB3 can be used as EXTI3
    LDR     R0, =AFIO_MAPR
    LDR     R1, [R0]
    BIC     R1, R1, #(0x7 << 24)
    ORR     R1, R1, #(0x2 << 24)
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

    ; --- GPIOA CONFIGURATION ---
    LDR R0, =GPIOA_BASE
    LDR R1, =0xB8B38888
    STR R1, [R0, #GPIOx_CRL]
    MOV R1, #CS_PIN
    ORR R1, R1, #(1 << 6)      ; <--- MODIFIED: Set PA6 bit in ODR to activate Pull-Up
    STR R1, [R0, #GPIOx_ODR]

	; Disable JTAG but keep SWD (SWJ_CFG = 010)
	
	
    ; --- GPIOB CONFIGURATION ---
    LDR R0, =GPIOB_BASE
    LDR R1, [R0, #GPIOx_CRL]
    LDR R2, =0x000FF000
    BIC R1, R1, R2
    BIC R1, R1, #0xF0
    LDR R2, =0x00088000
    ORR R1, R1, R2
    ORR R1, R1, #0x30
    STR R1, [R0, #GPIOx_CRL]

    LDR R1, [R0, #GPIOx_CRH]
    LDR R2, =0x0000FF0F
    BIC R1, R1, R2
    LDR R2, =0x00007708
    ORR R1, R1, R2
    STR R1, [R0, #GPIOx_CRH]
    
    LDR R1, [R0, #GPIOx_ODR]
    LDR R2, =0x00000138        ; PB3/PB4 pull-down, PB5/PB6/PB8 pull-up
    BIC R1, R1, R2
    LDR R2, =0x0160
    ORR R1, R1, R2
    STR R1, [R0, #GPIOx_ODR]

    ; --- AFIO EXTI MAPPING ---
    ; EXTICR1: Controls EXTI0, EXTI1, EXTI2, EXTI3
    ; PA0 (0x0), PA1 (0x0), PA2 (0x0), PB3 (0x1) -> Target value: 0x1000
    LDR R0, =AFIO_EXTICR1
    LDR R1, =0x1000            ; EXTI3 mapped to PB3
    STR R1, [R0]

    ; EXTICR2: Controls EXTI4, EXTI5, EXTI6, EXTI7
    ; PB4 (0x1), PB5 (0x1), PB6 (0x1), PB7 (0x1)
    ; EXTI7: [15:12] = 1 (PB)
    ; EXTI6: [11:8]  = 1 (PB)
    ; EXTI5: [7:4]   = 1 (PB)
    ; EXTI4: [3:0]   = 1 (PB)
    ; Target hex: 1111
    LDR R0, =AFIO_EXTICR2
    LDR R1, =0x1111            
    STR R1, [R0]

    ; EXTICR3: Controls EXTI8, EXTI9, EXTI10, EXTI11
    ; PB8 (0x1)
    ; EXTI8: [3:0] = 1 (PB)
    ; Target hex: 0001
    LDR R0, =AFIO_EXTICR3
    LDR R1, =0x0011            
    STR R1, [R0]


    ; --- EXTI EDGE CONFIGURATION ---
    LDR R0, =EXTI_IMR
    LDR R1, =0x01FB
    STR R1, [R0]
    
    LDR R0, =EXTI_RTSR
    LDR R1, =0x009B            ; Rising edge for lines 0,1,3,4,7
    STR R1, [R0]
    
    LDR R0, =EXTI_FTSR         ; <--- MODIFIED: Load Falling Trigger Selection Register
    LDR R1, =0x0160            ; <--- MODIFIED: Falling edge for lines 5, 6, 8
    STR R1, [R0]

    ; Clear stale pending EXTI flags before enabling NVIC
    LDR R0, =EXTI_PR
    LDR R1, =0x01FB
    STR R1, [R0]

    ; --- TIMER 2 CONFIGURATION ---
    LDR R0, =TIM2_BASE
    LDR R1, =7999
    STR R1, [R0, #0x28]
    LDR R1, =99
    STR R1, [R0, #0x2C]
    MOV R1, #1
    STR R1, [R0, #0x0C]
    MOV R1, #0
    STR R1, [R0, #0x00]
	
    ; --- NVIC CONFIGURATION ---
    LDR R0, =NVIC_ISER0
    LDR R1, =0x108006C0
    STR R1, [R0]
	
	BL hardware_init_audio
    BL bluetooth_init
    ; BL weight_sensor_init
	
;============================================================
; INITIAL STATE
;============================================================

    LDR R0, =elevatorState
    MOV R1, #STOPPED
    STRB R1, [R0]
    LDR R0, =currentFloor
    MOV R1, #1
    STRB R1, [R0]
    
	; Initialize all request array items to 0
    LDR R0, =requests
    MOV R1, #0
    STRB R1, [R0, #0]
    STRB R1, [R0, #1]
    STRB R1, [R0, #2]
    STRB R1, [R0, #3]
    STRB R1, [R0, #4]

	; Initialize all varaibles to 0
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
    ; Set auto-reload register for 5 kHz PWM (ARR = 999 for 1 kHz)
    LDR     R1, =199
    STR     R1, [R0, #0x2C]    ; TIM3_ARR
    ; Duty cycle for Channel 3 (PB0) = 75%
    LDR     R1, =150 
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
