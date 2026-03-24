    AREA	mycode, CODE, READONLY
    EXPORT  __main
    
    ;includes
    GET     registers.inc
    IMPORT  config
    IMPORT  delay_systick
    IMPORT  set_servo_angle

;============================================================
; Main function
;============================================================
	ENTRY

__main FUNCTION
	BL		config

main_loop
    ; Move servo to 180 degrees
    LDR     R0, =180
    BL      set_servo_angle
    BL      delay_systick

    ; Move servo to 0 degrees
    MOV     R0, #0
    BL      set_servo_angle
    BL      delay_systick

    ; Blink onboard LED once per sweep cycle (PC13 active low)
    LDR     R0, =GPIOC_ODR
    LDR     R1, [R0]
    BIC     R1, R1, #(1 << 13)
    STR     R1, [R0]

    BL      delay_systick

    LDR     R1, [R0]
    ORR     R1, R1, #(1 << 13)
    STR     R1, [R0]

    B       main_loop
    ENDFUNC
	
    END
	