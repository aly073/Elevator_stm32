    AREA	myconfig, CODE, READONLY
    EXPORT config
    GET     registers.inc

;============================================================
; Configurations for the stm32 pins etc
;============================================================

config	FUNCTION
	PUSH    {R0, R1, LR}
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
	POP     {R0, R1, PC}
	ENDFUNC

    END