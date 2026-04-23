    AREA	defs, CODE, READONLY
	GET     registers.inc
    EXPORT GO_DOWN
    EXPORT STOP
    EXPORT GO_UP

GO_DOWN FUNCTION
        PUSH{R0-R12, LR}
        ; === Set direction  Go DOWN
        LDR     R0, =GPIOB_ODR
		;LDR     R2,[R0]
        LDR     R1, =0x2063  ; 0010 0000 0110 0011; PB12=0, PB13=1 (Motor Reverse)
		;ORR     R2, R2, R1
        STR     R1, [R0]
        POP{R0-R12, PC}
        ENDFUNC

STOP FUNCTION
        PUSH{R0-R12, LR}
        ; === Set direction STOP
        LDR     R0, =GPIOB_ODR
		LDR     R2,[R0]
        LDR     R1, =0x0063  ; 0000 0000 0110 0011 PB12=0, PB13=0 (Motor stop)
		AND     R2, R2, R1
        STR     R2, [R0]
        POP{R0-R12, PC}
        ENDFUNC


GO_UP FUNCTION
        PUSH{R0-R12, LR}
        ; === Set direction  Go UP
        LDR     R0, =GPIOB_ODR
		;LDR     R2,[R0]
		LDR     R1, =0x1063 ; 0001 0000 0110 0011; PB12=1, PB13=0 (Motor forward)
		;ORR     R2, R2, R1
        STR     R1, [R0]
        POP{R0-R12, PC}
        ENDFUNC

    END