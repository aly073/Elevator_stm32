	AREA	myaddresses, DATA, READONLY

; RCC register addresses
RCC_APB2ENR EQU 0x40021018
; GPIOC register addresses
GPIOC_CRH     EQU 0x40011004
GPIOC_ODR     EQU 0x4001100C
	
; SysTick Register Addresses
STK_CTRL    EQU 0xE000E010    ; Control and Status Register
STK_LOAD    EQU 0xE000E014    ; Reload Value Register
STK_VAL     EQU 0xE000E018    ; Current Value Register

    AREA	mycode, CODE, READONLY
    EXPORT  __main
    ENTRY

config	FUNCTION
	push{R0,R1,LR}
	; 1. Enable Clock for GPIOC (Bit 4 in RCC_APB2ENR)
    LDR     R0, =RCC_APB2ENR
    LDR     R1, [R0]
    ORR     R1, R1, #(1 << 4)
    STR     R1, [R0]

    ; 2. Configure PC13 as Output Push-Pull (50MHz)
    ; Mode bits for Pin 13 are in CRH (Control Register High)
    LDR     R0, =GPIOC_CRH
    LDR     R1, [R0]
    BIC     R1, R1, #(0xF << 20) ; Clear bits 20-23
    ORR     R1, R1, #(0x3 << 20) ; Set bits 20-21 (Output mode 50MHz, Push-Pull)
    STR     R1, [R0]
	pop{R0,R1,pc}
	ENDFUNC




__main FUNCTION
	BL		config

loop
    ; 3. Turn LED ON (PC13 is active LOW on Blue Pill)
    LDR     R0, =GPIOC_ODR
    LDR     R1, [R0]
    BIC     R1, R1, #(1 << 13)
    STR     R1, [R0]
    BL      delay_systick
	BL      delay_systick
	BL      delay_systick
	BL      delay_systick

    ; 4. Turn LED OFF
    LDR     R1, [R0]
    ORR     R1, R1, #(1 << 13)
    STR     R1, [R0]
    BL      delay_systick

    B       loop
	ENDFUNC
	
delay FUNCTION
	push{R2, LR}
    LDR     R2, =14000000          ; Delay counter
delay_loop
    SUBS    R2, R2, #1
    BNE     delay_loop
    pop{R2, pc}
	ENDFUNC
	
	
delay_systick
    PUSH    {R0, R1, R4, LR}
    
    ; We will loop 100 times (100 * 10ms = 1 second)
    MOV     R4, #100          

outer_loop
    ; 1. Set 10ms reload value (720,000 - 1, equation for delay: (clock/delay) -1, this gives us 10ms with a 72MHz clock as 72,000,000 / 100 - 1= 719,999)
    LDR     R0, =STK_LOAD
    LDR     R1, =719999
	STR		R1, [R0]

    ; 2. Clear current value(also clears COUNTFLAG)
    LDR     R0, =STK_VAL
    MOV     R1, #0
    STR     R1, [R0]

    ; 3. Enable SysTick (Source = AHB (uses processor clock 72MHz), Enable = 1)
    LDR     R0, =STK_CTRL
    MOV     R1, #0x5
    STR     R1, [R0]

wait_10ms
    LDR     R1, [R0]
    ANDS    R1, R1, #(1 << 16) ; Check COUNTFLAG
    BEQ     wait_10ms          ; Wait for 10ms to pass

    ; 4. Decouple and check if we hit 100 iterations
    SUBS    R4, R4, #1
    BNE     outer_loop

    ; 5. Turn off SysTick before leaving
    MOV     R1, #0
    STR     R1, [R0]
    
    POP     {R0, R1, R4, PC}

    END