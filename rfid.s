	THUMB
    PRESERVE8

; ==========================================
; CONFIGURATION & TARGET UID
; ==========================================
    AREA |.rodata|, DATA, READONLY, ALIGN=2
target_uid  DCB 0x4A, 0x34, 0x8D, 0x02 

; ==========================================
; HARDWARE MEMORY MAP
; ==========================================
RCC_BASE        EQU 0x40021000
RCC_APB2ENR     EQU RCC_BASE + 0x18

GPIOA_BASE      EQU 0x40010800
GPIOA_CRL       EQU GPIOA_BASE + 0x00
GPIOA_CRH       EQU GPIOA_BASE + 0x04
GPIOA_BSRR      EQU GPIOA_BASE + 0x10

GPIOB_BASE      EQU 0x40010C00
GPIOB_CRL       EQU GPIOB_BASE + 0x00
GPIOB_CRH       EQU GPIOB_BASE + 0x04
GPIOB_BSRR      EQU GPIOB_BASE + 0x10
GPIOB_BRR       EQU GPIOB_BASE + 0x14

SPI1_BASE       EQU 0x40013000
SPI1_CR1        EQU SPI1_BASE + 0x00

; --- TIM1 Registers ---
TIM1_BASE       EQU 0x40012C00
TIM1_CR1        EQU TIM1_BASE + 0x00
TIM1_DIER       EQU TIM1_BASE + 0x0C
TIM1_SR         EQU TIM1_BASE + 0x10
TIM1_PSC        EQU TIM1_BASE + 0x28
TIM1_ARR        EQU TIM1_BASE + 0x2C

; --- EXTI Registers ---
AFIO_BASE       EQU 0x40010000
AFIO_EXTICR3    EQU AFIO_BASE + 0x10    
EXTI_BASE       EQU 0x40010400
EXTI_IMR        EQU EXTI_BASE + 0x00    
EXTI_RTSR       EQU EXTI_BASE + 0x08    
EXTI_FTSR       EQU EXTI_BASE + 0x0C    
EXTI_PR         EQU EXTI_BASE + 0x14    
NVIC_ISER0      EQU 0xE000E100
NVIC_ISER1      EQU 0xE000E104          ; Added for IRQ 32-63
NVIC_IPR6       EQU 0xE000E418          ; IRQ 24-27 Priority Register


; --- RC522 Registers ---
CommandReg      EQU 0x01
ComIEnReg       EQU 0x02                
DivIEnReg       EQU 0x03                
ComIrqReg       EQU 0x04
ErrorReg        EQU 0x06
FIFODataReg     EQU 0x09
FIFOLevelReg    EQU 0x0A
BitFramingReg   EQU 0x0D
ModeReg         EQU 0x11
TxControlReg    EQU 0x14
TxASKReg        EQU 0x15
TModeReg        EQU 0x2A
TPrescalerReg   EQU 0x2B
TReloadRegH     EQU 0x2C
TReloadRegL     EQU 0x2D      

; ==========================================
; RAM VARIABLES
; ==========================================
    AREA |.bss|, DATA, READWRITE, ALIGN=2
irq_flag    SPACE 4             
uid_buffer  SPACE 5             

; ==========================================
; MAIN EXECUTION
; ==========================================
    AREA |.text|, CODE, READONLY, ALIGN=2

	EXPORT rfid_init
rfid_init PROC
    push {r0,r1,r2,lr}
    mov r10, #0

    ; 1. Enable Clocks (RMW)
    ldr r0, =RCC_APB2ENR
    ldr r1, [r0]
    ldr r2, =0x180D             ; Bits for TIM1, SPI1, GPIOB, GPIOA, AFIO
    orr r1, r1, r2
    str r1, [r0]

    ; 2. Configure GPIOA (SPI1 + PA8 RST + PA11 EXTI) (RMW)
    ldr r0, =GPIOA_CRL
    ldr r1, [r0]
    ldr r2, =0x0000FFFF         ; Clear upper half (PA7 to PA4)
    and r1, r1, r2
    ldr r2, =0xB4B40000         ; Set Alternate Function for SPI
    orr r1, r1, r2
    str r1, [r0]

    ldr r0, =GPIOA_CRH
    ldr r1, [r0]
    ldr r2, =0xFFFF0FF0         ; Clear PA11 and PA8 configuration bits
    and r1, r1, r2
    ldr r2, =0x00004003         ; PA11 = floating input (4), PA8 = GP output push-pull (3)
    orr r1, r1, r2              
    str r1, [r0]

    ; 3. Configure GPIOB (LEDs + CS) (RMW)
    ldr r0, =GPIOB_CRL
    ldr r1, [r0]
    ldr r2, =0xFFFFFF00         ; Clear PB1 and PB0 configuration bits
    and r1, r1, r2
    orr r1, r1, #0x33           ; Set PB1, PB0 to output push-pull
    str r1, [r0]

    ldr r0, =GPIOB_CRH
    ldr r1, [r0]
    ldr r2, =0xFFF0FFFF         ; Clear PB12 configuration bits
    and r1, r1, r2
    ldr r2, =0x00030000         ; Set PB12 to general purpose output
    orr r1, r1, r2
    str r1, [r0]

    ; BSRR is Write-Only; direct write is hardware mandated
    ldr r0, =GPIOA_BSRR
    ldr r1, =(1<<8)
    str r1, [r0]
    ldr r0, =GPIOB_BSRR
    ldr r1, =(1<<12) 
    str r1, [r0]
    bl delay_long               

    ; 4. Setup EXTI11 for PA11 (RMW)
    ldr r0, =AFIO_EXTICR3
    ldr r1, [r0]
    ldr r2, =0xFFFF0FFF         ; Clear EXTI11 selection bits
    and r1, r1, r2
    ; Port A is mapped to 0x0000, so clearing is sufficient
    str r1, [r0]

    ldr r0, =EXTI_FTSR
    ldr r1, [r0]
    orr r1, r1, #(1<<11)        ; Enable falling edge trigger for Line 11
    str r1, [r0]

    ldr r0, =EXTI_IMR
    ldr r1, [r0]
    orr r1, r1, #(1<<11)        ; Unmask EXTI Line 11
    str r1, [r0]

    ; Enable TIM1_UP (Bit 25) in NVIC_ISER0 (RMW)
    ldr r0, =NVIC_ISER0
    ldr r1, [r0]
    orr r1, r1, #(1<<25)
    str r1, [r0]

    ; Enable EXTI15_10 (Bit 8 -> IRQ 40) in NVIC_ISER1 (RMW)
    ldr r0, =NVIC_ISER1
    ldr r1, [r0]
    orr r1, r1, #(1<<8)
    str r1, [r0]

    ; 5. Configure SPI1 (RMW)
    ldr r0, =SPI1_CR1
    ldr r1, [r0]
    ldr r2, =0xFFFFFC00         ; Clear lower configuration bits
    and r1, r1, r2
    ldr r2, =0x037C             ; Apply SPI setup
    orr r1, r1, r2
    orr r1, r1, #(1<<6)         ; Enable SPI (SPE bit)
    str r1, [r0]

    ; 6. Initialize RC522 
    mov r0, #CommandReg
    mov r1, #0x0F               
    bl rc522_write
    bl delay_long               

    mov r0, #TModeReg
    mov r1, #0x8D               
    bl rc522_write
    mov r0, #TPrescalerReg
    mov r1, #0x3E               
    bl rc522_write
    mov r0, #TReloadRegL
    mov r1, #30                 
    bl rc522_write
    mov r0, #TReloadRegH
    mov r1, #0                
    bl rc522_write
    
    mov r0, #TxASKReg
    mov r1, #0x40               
    bl rc522_write
    mov r0, #ModeReg
    mov r1, #0x3D               
    bl rc522_write

    ; Read-Modify-Write applied via SPI to the RC522 TxControl Reg
    mov r0, #TxControlReg
    bl rc522_read
    orr r1, r0, #0x03
    mov r0, #TxControlReg
    bl rc522_write

    mov r0, #DivIEnReg
    mov r1, #0x80               
    bl rc522_write
    bl delay_short              

    ; 7. Setup TIM1 for 100ms periodic interrupt
    ; RMW to Prescaler
    ldr r0, =TIM1_PSC
    ldr r1, [r0]
    ldr r2, =0xFFFF0000
    and r1, r1, r2
    ldr r2, =7999               ; 8MHz / 8000 = 1kHz timer clock
    orr r1, r1, r2
    str r1, [r0]
    
    ; RMW to Auto-Reload
    ldr r0, =TIM1_ARR
    ldr r1, [r0]
    ldr r2, =0xFFFF0000
    and r1, r1, r2
    ldr r2, =99                 ; 1kHz / 100 = 10Hz (100ms)
    orr r1, r1, r2
    str r1, [r0]
    
    ; RMW to Enable Update Interrupt
    ldr r0, =TIM1_DIER
    ldr r1, [r0]
    orr r1, r1, #1                 
    str r1, [r0]
    
    ; RMW to set lowest priority for TIM1_UP (IRQ 25)
    ldr r0, =NVIC_IPR6
    ldr r1, [r0]
    ldr r2, =0xFFFF00FF         ; Mask out IRQ25 priority byte (bits 8-15)
    and r1, r1, r2
    ldr r2, =0x0000F000         ; Write 0xF0 (Lowest Priority) to IRQ25
    orr r1, r1, r2
    str r1, [r0]

    ; Start TIM1 Counter (RMW)
    ldr r0, =TIM1_CR1
    ldr r1, [r0]
    orr r1, r1, #1                 
    str r1, [r0]

    pop {r0,r1,r2,pc}
    ENDP

;===================================
;       TIMER HANDLER
;===================================
	
    EXPORT TIM1_UP_IRQHandler
TIM1_UP_IRQHandler PROC
    push {r4, r5, r6, lr}       ; Save context

    ; Clear TIM1 update interrupt flag (RMW)
    ldr r0, =TIM1_SR
    ldr r1, [r0]
    bic r1, r1, #1              ; Clear bit 0 (UIF)
    str r1, [r0]

    ; Turn off LEDs and reset elevator flag (Direct Write to Write-Only Register)
    ldr r0, =GPIOB_BRR
    ldr r1, =0x03
    str r1, [r0]
    mov r10, #0

    ; 8. Ping antenna for REQA
    mov r0, #BitFramingReg
    mov r1, #0x07               
    bl rc522_write

    mov r0, #ComIEnReg
    mov r1, #0xA1               
    bl rc522_write

    bl clear_irqs               

    mov r0, #FIFOLevelReg
    mov r1, #0x80               
    bl rc522_write

    mov r0, #CommandReg
    mov r1, #0x00               ; IDLE
    bl rc522_write

    mov r0, #FIFODataReg
    mov r1, #0x26               ; REQA
    bl rc522_write

    mov r0, #CommandReg
    mov r1, #0x0C               ; Transceive
    bl rc522_write

    mov r0, #BitFramingReg
    mov r1, #0x87               ; StartSend
    bl rc522_write

    bl wait_for_mfrc_irq        
    tst r0, #0x01               
    bne tim1_exit               

process_card
    ; 9. Anti-Collision Phase
    mov r0, #ComIEnReg
    mov r1, #0xF7
    bl rc522_write

    mov r0, #ComIrqReg
    mov r1, #0x7F
    bl rc522_write

    mov r0, #FIFOLevelReg
    mov r1, #0x80
    bl rc522_write

    mov r0, #CommandReg
    mov r1, #0x00               ; Must IDLE between commands
    bl rc522_write

    mov r0, #BitFramingReg
    mov r1, #0x00               
    bl rc522_write

    mov r0, #FIFODataReg
    mov r1, #0x93               
    bl rc522_write
    mov r0, #FIFODataReg
    mov r1, #0x20               
    bl rc522_write

    mov r0, #CommandReg
    mov r1, #0x0C               
    bl rc522_write

    mov r0, #BitFramingReg
    mov r1, #0x80               
    bl rc522_write

    ldr r4, =100000            
anti_poll
    subs r4, r4, #1
    beq tim1_exit               

    mov r0, #ComIrqReg
    bl rc522_read
    tst r0, #0x01               
    bne tim1_exit               
    tst r0, #0x30               
    beq anti_poll

    mov r0, #FIFOLevelReg
    bl rc522_read
    cmp r0, #5
    bne tim1_exit               

    ldr r4, =uid_buffer
    mov r5, #5
read_uid_loop
    mov r0, #FIFODataReg
    bl rc522_read
    strb r0, [r4], #1           
    subs r5, r5, #1
    bne read_uid_loop

    ; 10. Compare UID
    ldr r4, =uid_buffer
    ldr r5, =target_uid
    mov r6, #4                  
compare_loop
    ldrb r0, [r4], #1
    ldrb r1, [r5], #1
    cmp r0, r1
    bne wrong_card
    subs r6, r6, #1
    bne compare_loop

correct_card
    mov r10, #1                 ; SET R10 FOR ELEVATOR LOGIC
    ldr r0, =GPIOB_BSRR
    ldr r1, =0x01               
    str r1, [r0]
    bl delay_long
    b tim1_exit

wrong_card
    ldr r0, =GPIOB_BSRR
    ldr r1, =0x02               
    str r1, [r0]
    bl delay_long
    b tim1_exit                 

tim1_exit
    pop {r4, r5, r6, pc}        
    ENDP

    EXPORT rfid_isr
rfid_isr PROC
    push {lr}
    ; EXTI_PR is a "rc_w1" register (read, clear by writing 1).
    ; Performing RMW here would write 1s back to ALL pending interrupts, clearing them erroneously. 
    ; Direct write is required to safely clear ONLY bit 11.
    ldr r0, =EXTI_PR
    ldr r1, =(1<<11)
    str r1, [r0]
    
    ; RMW to RAM Variable
    ldr r0, =irq_flag
    ldr r1, [r0]
    mov r1, #1
    str r1, [r0]
    dsb
    isb
    pop {pc}
    ENDP

clear_irqs PROC
    push {lr}
    mov r0, #ComIrqReg
    mov r1, #0x7F
    bl rc522_write              
    ldr r0, =500
wait_rise
    subs r0, r0, #1
    bne wait_rise
    
    ; EXTI_PR is rc_w1 (Write 1 to clear). Direct write is required.
    ldr r0, =EXTI_PR
    ldr r1, =(1<<11)
    str r1, [r0]                
    
    ; RMW to RAM Variable
    ldr r0, =irq_flag
    ldr r1, [r0]
    mov r1, #0
    str r1, [r0]
    
    pop {pc}
    ENDP

wait_for_mfrc_irq PROC
    push {r4, lr}
wfi_loop
    cpsid i                     
    ldr r0, =irq_flag
    ldr r1, [r0]
    cmp r1, #1
    beq wfi_awake               
    wfi                         
    cpsie i                     
    nop                         
    b wfi_loop                  
wfi_awake
    cpsie i                     
    mov r0, #ComIrqReg
    bl rc522_read
    mov r4, r0                  
    mov r0, #ComIrqReg
    mov r1, #0x7F               
    bl rc522_write
    mov r0, r4                  
    pop {r4, pc}
    ENDP

rc522_write PROC
    push {r4, r5, lr}
    mov r4, r0
    mov r5, r1
    ldr r2, =GPIOB_BRR          
    ldr r3, =(1<<12)
    str r3, [r2]
    lsl r0, r4, #1
    and r0, r0, #0x7E           
    bl spi_transfer
    mov r0, r5
    bl spi_transfer
    ldr r2, =GPIOB_BSRR         
    ldr r3, =(1<<12)
    str r3, [r2]
    pop {r4, r5, pc}
    ENDP

rc522_read PROC
    push {r4, lr}
    mov r4, r0
    ldr r2, =GPIOB_BRR          
    ldr r3, =(1<<12)
    str r3, [r2]
    lsl r0, r4, #1
    and r0, r0, #0x7E
    orr r0, r0, #0x80           
    bl spi_transfer
    mov r0, #0x00               
    bl spi_transfer
    mov r4, r0
    ldr r2, =GPIOB_BSRR         
    ldr r3, =(1<<12)
    str r3, [r2]
    mov r0, r4
    pop {r4, pc}
    ENDP

spi_transfer PROC
    ldr r1, =SPI1_BASE
spi_tx_wait
    ldr r2, [r1, #0x08]         
    tst r2, #(1<<1)             
    beq spi_tx_wait
    strb r0, [r1, #0x0C]        
spi_rx_wait
    ldr r2, [r1, #0x08]         
    tst r2, #(1<<0)             
    beq spi_rx_wait
    ldrb r0, [r1, #0x0C]        
spi_bsy_wait
    ldr r2, [r1, #0x08]         
    tst r2, #(1<<7)             
    bne spi_bsy_wait            
    bx lr
    ENDP

delay_long PROC
    ldr r0, =1500000
dl1 subs r0, r0, #1
    bne dl1
    bx lr
    ENDP

delay_medium PROC
    ldr r0, =50000
dm1 subs r0, r0, #1
    bne dm1
    bx lr
    ENDP

delay_short PROC
    ldr r0, =10000
ds1 subs r0, r0, #1
    bne ds1
    bx lr
    ENDP

    END