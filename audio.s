; -------------------------------------------------------------------------
; STM32 Blue Pill - Audio System File (USART2 on PA2)
; -------------------------------------------------------------------------

        AREA    ROData, DATA, READONLY
        ALIGN

; Volume Max (30 / 0x1E)
cmd_set_volume DCB 0x7E, 0xFF, 0x06, 0x06, 0x00, 0x00, 0x1E, 0xFE, 0xD7, 0xEF
; Track 1 (0001.mp3) - For GO_UP/GO_DOWN
cmd_track_1    DCB 0x7E, 0xFF, 0x06, 0x03, 0x00, 0x00, 0x01, 0xFE, 0xF7, 0xEF
; Track 2 (0002.mp3) - For STOP
cmd_track_2    DCB 0x7E, 0xFF, 0x06, 0x03, 0x00, 0x00, 0x02, 0xFE, 0xF6, 0xEF

        AREA    |.text|, CODE, READONLY
        ALIGN
        EXPORT  PLAY_MOVEMENT_AUDIO
        EXPORT  PLAY_STOP_AUDIO
        EXPORT  uart_send
        EXPORT  hardware_init_audio
		IMPORT delay_systick

; --- Audio Trigger Functions ---
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

; --- Hardware Initialization ---
hardware_init_audio
        PUSH    {LR}
        
        ; 1. Enable Clocks: GPIOA (Bit 2) and GPIOB (Bit 3) on APB2
        LDR     R0, =0x40021018     ; RCC_APB2ENR
        LDR     R1, [R0]
        ORR     R1, R1, #0x000C     ; Enable A and B
        STR     R1, [R0]

        ; 2. Enable Clock for USART2 (Bit 17) on APB1 Bus
        LDR     R0, =0x4002101C     ; RCC_APB1ENR
        LDR     R1, [R0]
        ORR     R1, R1, #0x00020000 
        STR     R1, [R0]

        ; 3. Configure PA2 (TX) and PA3 (RX) 
        ; PA2 = 0xB (Alt Func Push-Pull, 50MHz)
        ; PA3 = 0x4 (Floating Input)
        LDR     R0, =0x40010800     ; GPIOA_CRL
        LDR     R1, [R0]
        LDR     R2, =0xFFFF00FF     ; Clear PA2 and PA3 bits
        AND     R1, R1, R2
        ORR     R1, R1, #0x00004B00 ; Set PA2=B, PA3=4
        STR     R1, [R0]

        ; 4. USART2 Baud Rate (9600 @ 8MHz)
        LDR     R0, =0x40004408     ; USART2_BRR
        LDR     R1, =0x0341
        STR     R1, [R0]

        ; 5. Enable USART2 (UE=1, TE=1, RE=1)
        LDR     R0, =0x4000440C     ; USART2_CR1
        LDR     R1, =0x200C         ; Enable Transmit and Receive
        STR     R1, [R0]

        ; Startup Sequence
        ; short settle delay before first command
		MOV 	R0, #100
		BL      delay_ms
		
        LDR     R0, =cmd_set_volume
        MOV     R1, #10
        BL      uart_send
        
        POP     {PC}

; --- Short millisecond delay for audio startup ---
; R0 = delay count in rough milliseconds
delay_ms
        PUSH    {R1, R2, LR}
        MOV     R2, R0

delay_ms_outer
        CMP     R2, #0
        BEQ     delay_ms_done
        LDR     R1, =6000

delay_ms_inner
        SUBS    R1, R1, #1
        BNE     delay_ms_inner
        SUBS    R2, R2, #1
        B       delay_ms_outer

delay_ms_done
        POP     {R1, R2, PC}

; --- UART Send Helper ---
uart_send
        PUSH    {R4, R5, LR}
        MOV     R4, R0
        MOV     R5, R1
        LDR     R2, =0x40004400     ; USART2 Base Address
tx_loop
        CMP     R5, #0
        BEQ     tx_done
wait_txe
        LDR     R3, [R2, #0x00]     ; USART2_SR
        TST     R3, #0x80           ; TXE flag
        BEQ     wait_txe
        LDRB    R3, [R4]
        STR     R3, [R2, #0x04]     ; USART2_DR
        ADD     R4, R4, #1
        SUB     R5, R5, #1
        B       tx_loop
tx_done
        POP     {R4, R5, PC}
		
        END