; -------------------------------------------------------------------------
; STM32 Audio System & Hardware Initialization
; -------------------------------------------------------------------------

        AREA    ROData, DATA, READONLY
        ALIGN

cmd_set_volume DCB 0x7E, 0xFF, 0x06, 0x06, 0x00, 0x00, 0x1E, 0xFE, 0xD7, 0xEF
cmd_track_1    DCB 0x7E, 0xFF, 0x06, 0x01, 0x00, 0x00, 0x00, 0xFE, 0xFA, 0xEF
cmd_track_2    DCB 0x7E, 0xFF, 0x06, 0x0D, 0x00, 0x00, 0x00, 0xFE, 0xEE, 0xEF

; -------------------------------------------------------------------------
; TEXT SECTION (Audio Logic and Init)
; -------------------------------------------------------------------------
        AREA    |.text|, CODE, READONLY
        ALIGN
        EXPORT  PLAY_MOVEMENT_AUDIO
        EXPORT  PLAY_STOP_AUDIO
        EXPORT  uart_send
        EXPORT  delay_ms

PLAY_MOVEMENT_AUDIO
        PUSH    {R0, R1, LR}
        LDR     R0, =cmd_track_1
        MOV     R1, #10
        BL      uart_send
        POP     {R0, R1, PC}

PLAY_STOP_AUDIO
        PUSH    {R0, R1, LR}
        LDR     R0, =cmd_track_2
        MOV     R1, #10
        BL      uart_send
        POP     {R0, R1, PC}

; -------------------------------------------------------------------------
; UTILITY FUNCTIONS
; -------------------------------------------------------------------------
uart_send
        PUSH    {R4, R5, LR}
        MOV     R4, R0
        MOV     R5, R1
        LDR     R2, =0x40013800     ; USART1_SR
tx_loop
        CMP     R5, #0
        BEQ     tx_done
wait_txe
        LDR     R3, [R2, #0x00]
        TST     R3, #0x80
        BEQ     wait_txe
        LDRB    R3, [R4]
        STR     R3, [R2, #0x04]     ; USART_DR
        ADD     R4, R4, #1
        SUB     R5, R5, #1
        B       tx_loop
tx_done
        POP     {R4, R5, PC}

delay_ms
        PUSH    {R1, LR}
delay_outer
        CMP     R0, #0
        BEQ     delay_exit
        LDR     R1, =8000           
delay_inner
        SUBS    R1, R1, #1
        BNE     delay_inner
        SUBS    R0, R0, #1
        B       delay_outer
delay_exit
        POP     {R1, PC}

        END