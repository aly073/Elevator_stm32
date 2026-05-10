; this file will hold interrupt for limit switch which plays emergency audio if line is cut
; it will also have code to go down to floor 1 on startup

; -------------------------------------------------------------------------
; STM32 Blue Pill - Audio System File (USART2 on PA2)
; -------------------------------------------------------------------------

EXTI_SWIER  EQU 0x40010410      ; Address for EXTI Software Interrupt Event Register

        AREA    |.data|, DATA, READWRITE
        ALIGN
initialized DCD 0               ; Variable initialized to 0

        AREA    |.text|, CODE, READONLY
        ALIGN
        IMPORT STOP
        IMPORT PLAY_EMERGENCY_AUDIO ; Imported to resolve the branch link

    EXPORT limit_switch_isr
limit_switch_isr
    PUSH {lr}

    ; Load the 'initialized' variable
    LDR     r2, =initialized
    LDR     r3, [r2]
    CMP     r3, #0
    BNE     emergency_action    ; If initialized != 0, skip to emergency audio

startup_action
    ; Set 'initialized' to 1 so this block never runs again
    MOV     r3, #1
    STR     r3, [r2]

    ; Make a request to floor 1 by triggering EXTI Line 0
    LDR     r0, =EXTI_SWIER
    LDR     r1, [r0]
    ORR     r1, r1, #(1 :SHL: 0)      ; Set bit 0 for EXTI line 0
    STR     r1, [r0]
    
    B       end_isr             ; Exit the ISR

emergency_action
    BL STOP                     ; turn off motor
    BL PLAY_EMERGENCY_AUDIO     ; play audio

end_isr
    POP {pc}

        END