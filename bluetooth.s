; ==========================================
; BLUETOOTH MODULE - STM32F103 UART Integration
; ==========================================
; Receives commands via UART1 (PA9=RX, PA10=TX)
; Sets elevator floor requests based on authentication
; ==========================================

        AREA    BLUETOOTH, CODE, READONLY
        THUMB
        GET     registers.inc
        
        EXPORT  bluetooth_init
        EXPORT  process_bluetooth_message
        EXPORT  USART1_IRQHandler

; ==========================================
; CONSTANTS & SECURE CREDENTIALS
; ==========================================
        AREA    |.rodata|, DATA, READONLY
        ALIGN
; REPLACE "12345678" WITH YOUR ACTUAL FOB UID.
; The colon at the end is strictly required by the parser!
expected_prefix DCB     "UID:4A348D02:", 0
msg_granted     DCB     "GRANTED", 0x0A, 0    ; 0x0A is newline (\n)
msg_denied      DCB     "DENIED", 0x0A, 0
        ALIGN                         ; Align memory after strings

; ==========================================
; RAM VARIABLES
; ==========================================
        AREA    |.bss|, DATA, READWRITE
        ALIGN
msg_ready       SPACE   4             ; Flag: 1 when full string is received
rx_index        SPACE   4             ; Current index in rx_buffer
rx_buffer       SPACE   32            ; Buffer to hold "UID:XXXX:Y"

; ==========================================
; INITIALIZATION FUNCTION
; ==========================================
        AREA    |.text|, CODE, READONLY
        THUMB

        IMPORT  requests
        IMPORT  checkNextMove
        IMPORT  elevatorState
        IMPORT  PLAY_BLUETOOTH_PAIRING_AUDIO

bluetooth_init PROC
        PUSH    {r0-r12, lr}
        
        ; 0. Clear RAM Variables
        MOV     r1, #0
        LDR     r0, =msg_ready
        STR     r1, [r0]
        LDR     r0, =rx_index
        STR     r1, [r0]

        ; 1. Enable Clocks for USART1 (GPIOA already enabled by config)
        LDR     r0, =RCC_APB2ENR
        LDR     r1, [r0]
        MOVW    r12, #0x4000
        ORR     r1, r1, r12         
        STR     r1, [r0]

        ; 2. Configure PA9 (USART1 TX) and PA10 (USART1 RX) in CRH
        LDR     r0, =GPIOA_CRH
        LDR     r1, [r0]
        
        ; Clear the configuration bits for PA9 (4-7) and PA10 (8-11)
        LDR     r2, =0x00000FF0
        BIC     r1, r1, r2      
        
        ; Set PA9 to 0xB (Alternate Function Push-Pull, 50MHz)
        ; Set PA10 to 0x4 (Input Floating - standard for UART RX)
        LDR     r2, =0x000004B0
        ORR     r1, r1, r2      
        STR     r1, [r0]
        
        ; 3. Configure USART1 (9600 Baud @ 8MHz)
        LDR     r0, =USART1_BRR
        LDR     r1, =0x0341            
        STR     r1, [r0]

        ; Enable USART (UE), Receiver (RE), Transmitter (TE), AND RX Interrupt Enable (RXNEIE)
        LDR     r0, =USART1_CR1
        LDR     r1, =0x202C              
        STR     r1, [r0]

        ; 4. Enable USART1 Interrupt in NVIC (IRQ 37 -> Bit 5 of ISER1)
        LDR     r0, =NVIC_ISER1
        LDR     r1, [r0]
        ORR     r1, r1, #(1<<5)          
        STR     r1, [r0]

        POP     {r0-r12, pc}
        ENDP

; ==========================================
; UART TRANSMIT FUNCTION
; ==========================================
send_string PROC
        PUSH    {r4, lr}
        MOV     r4, r0                ; r4 holds string pointer
tx_loop
        LDRB    r0, [r4], #1          ; Load char and increment pointer
        CMP     r0, #0
        BEQ     tx_done               ; If null terminator, exit
tx_wait
        LDR     r1, =USART1_SR
        LDR     r2, [r1]
        TST     r2, #(1 :SHL: 7)      ; Check TXE (Transmit Data Register Empty)
        BEQ     tx_wait
        LDR     r1, =USART1_DR
        STR     r0, [r1]              ; Send character
        B       tx_loop
tx_done
        POP     {r4, pc}
        ENDP

; ==========================================
; MESSAGE PROCESSING FUNCTION
; ==========================================
; Processes pending bluetooth messages and sets floor requests
; Call this periodically from the main elevator loop
process_bluetooth_message PROC
        PUSH    {r0-r7, lr}
        
        ; Check if a full message string was assembled by the ISR
        LDR     r0, =msg_ready
        LDR     r1, [r0]
        CMP     r1, #1
        BNE     pbm_exit              ; If no new message, exit
        
        ; Compare rx_buffer against the hardcoded expected_prefix
        LDR     r4, =rx_buffer
        LDR     r5, =expected_prefix
compare_loop
        LDRB    r6, [r5], #1
        CMP     r6, #0                ; Reached end of null terminator?
        BEQ     match_success         ; If yes, prefix matches perfectly
        LDRB    r7, [r4], #1
        CMP     r6, r7                  
        BEQ     compare_loop          ; Continue if chars match
        B       match_fail            ; Jump to fail if a char mismatch occurs

match_fail
        LDR     r0, =msg_denied
        BL      send_string           ; Send DENIED to Flutter
        B       reset_buffer

match_success
        LDRB    r6, [r4]              ; r6 now contains the floor number ('0', '1', etc)
        LDR     r0, =msg_granted
        BL      send_string           ; Send GRANTED to Flutter

        ; Evaluate floor command and set appropriate request
        mov r10, #2
        CMP     r6, #0x31             ; '1'
        BEQ     floor1_request
        CMP     r6, #0x32             ; '2'
        BEQ     floor2_request
        CMP     r6, #0x33             ; '3'
        BEQ     floor3_request
		BL      PLAY_BLUETOOTH_PAIRING_AUDIO
        B       reset_buffer          ; If '0' (probe) or unknown, just reset buffer

floor1_request
        LDR     r0, =EXTI_SWIER
        LDR     r1, [r0]
        ORR     r1, r1, #(1 :SHL: 0)      ; EXTI line 0
        STR     r1, [r0]
        B       reset_buffer

floor2_request
        LDR     r0, =EXTI_SWIER
        LDR     r1, [r0]
        ORR     r1, r1, #(1 :SHL: 4)      ; EXTI line 4
        STR     r1, [r0]
        B       reset_buffer

floor3_request
        LDR     r0, =EXTI_SWIER
        LDR     r1, [r0]
        ORR     r1, r1, #(1 :SHL: 3)      ; EXTI line 3
        STR     r1, [r0]
        B       reset_buffer
        
reset_buffer
        LDR     r0, =rx_index
        MOV     r1, #0
        STR     r1, [r0]              ; 1. Reset buffer index to 0

        LDR     r0, =msg_ready
        STR     r1, [r0]              ; 2. Unlock the ISR (msg_ready = 0)

pbm_exit
        POP     {r0-r7, pc}
        ENDP

; ==========================================
; USART1 INTERRUPT HANDLER (RX ONLY)
; ==========================================
        EXPORT  USART1_IRQHandler
USART1_IRQHandler PROC
        PUSH    {r4, lr}

        ; Read SR then DR to clear RXNE and ORE flags
        LDR     r0, =USART1_SR
        LDR     r1, [r0]                
        
        LDR     r0, =USART1_DR
        LDR     r1, [r0]                
        
        ; Check if main loop hasn't processed previous message
        LDR     r2, =msg_ready
        LDR     r3, [r2]
        CMP     r3, #1
        BEQ     isr_exit              ; Ignore incoming chars if buffer is locked
        
        LDR     r2, =rx_index
        LDR     r3, [r2]
        CMP     r3, #14               ; Max 14 chars expected
        BGE     isr_exit
        
        CMP     r3, #0                ; Is this the very first character?
        BNE     store_char            ; If not, proceed normally
        CMP     r1, #0x55             ; If it is, is it 'U' (0x55)?
        BNE     isr_exit              ; If not 'U', ignore it and exit!

store_char
        LDR     r4, =rx_buffer
        STRB    r1, [r4, r3]          ; Store char in rx_buffer[rx_index]
        ADD     r3, r3, #1
        STR     r3, [r2]              ; rx_index++
        
        ; Check if we've received all 14 characters
        CMP     r3, #14
        BNE     isr_exit
        
        ; Message complete - append null terminator and process
        LDR     r4, =rx_buffer
        MOV     r1, #0
        STRB    r1, [r4, #14]         ; Null terminate at index 14
        
        ; Set msg_ready flag to 1
        LDR     r2, =msg_ready
        MOV     r3, #1
        STR     r3, [r2]
        
        ; Process the complete message immediately
        BL      process_bluetooth_message
        
isr_exit
        POP     {r4, pc}
        ENDP

        END