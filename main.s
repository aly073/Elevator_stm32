    AREA	mycode, CODE, READONLY
    EXPORT  __main
    
    ;includes
    GET     registers.inc
    IMPORT  config
    IMPORT  delay_systick

;============================================================
; Main function
;============================================================
	ENTRY

__main FUNCTION
	BL		config

main_loop
    ; 3. Turn LED ON (PC13 is active LOW on Blue Pill)
    LDR     R0, =GPIOC_ODR
    LDR     R1, [R0]
    BIC     R1, R1, #(1 << 13)
    STR     R1, [R0]
    BL      delay_systick

    ; 4. Turn LED OFF
    LDR     R1, [R0]
    ORR     R1, R1, #(1 << 13)
    STR     R1, [R0]
    BL      delay_systick

    B       main_loop
    ENDFUNC
	
    END
	