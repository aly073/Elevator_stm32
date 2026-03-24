;============================================================
; Basic functions
;============================================================
    AREA	defs, CODE, READONLY
	GET     registers.inc
    EXPORT delay_systick
    EXPORT delay
    EXPORT set_servo_angle

delay_systick ;delay 1 second using SysTick timer
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


;original method of delay the Dr taught us, but it is not as accurate as systick
delay FUNCTION
	push{R2, LR}
    LDR     R2, =14000000          ; Delay counter
delay_loop
    SUBS    R2, R2, #1
    BNE     delay_loop
    pop{R2, pc}
	ENDFUNC



;============================================================
; Function to set servo angle on TIM3_CH4 (PB1)
;============================================================

; Set SG90 angle in degrees (R0: 0..180) on TIM3_CH4 (PB1)
set_servo_angle FUNCTION
    PUSH    {R1, R2, R3, R4, LR}

    ; Clamp signed values below 0 to 0
    CMP     R0, #0
    BPL     angle_non_negative
    MOV     R0, #0

angle_non_negative
    ; Clamp values above 180 to 180
    CMP     R0, #180
    BLS     angle_clamped
    MOV     R0, #180

angle_clamped
    ; pulse_us = 500 + (angle * 2000) / 180
    ; Wider range gives closer to full mechanical travel on many SG90 servos.
    MOV     R1, #100
    MUL     R2, R0, R1
	MOV     R1, #20
    MUL     R2, R2, R1

    MOV     R3, #0
divide_by_180
    CMP     R2, #180
    BLO     division_done
    SUB     R2, R2, #180
    ADD     R3, R3, #1
    B       divide_by_180

division_done
    ADD     R3, R3, #500

    ; Update compare value for TIM3 CH4
    LDR     R4, =TIM3_CCR4
    STR     R3, [R4]

    POP     {R1, R2, R3, R4, PC}
    ENDFUNC


;============================================================
    END