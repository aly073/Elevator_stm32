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

; --- EXTI Registers ---
AFIO_BASE       EQU 0x40010000
AFIO_EXTICR3    EQU AFIO_BASE + 0x10    
EXTI_BASE       EQU 0x40010400
EXTI_IMR        EQU EXTI_BASE + 0x00    
EXTI_RTSR       EQU EXTI_BASE + 0x08    
EXTI_FTSR       EQU EXTI_BASE + 0x0C    
EXTI_PR         EQU EXTI_BASE + 0x14    
NVIC_ISER0      EQU 0xE000E100          

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
    ; Initialize R10 to 0
    PUSH {R0-R12,LR}
    mov r10, #0

    ; 1. Enable Clocks
    ldr r0, =RCC_APB2ENR
    ldr r1, [r0]
    ldr r2, =0x100D             
    orr r1, r1, r2
    str r1, [r0]

    ; 2. Configure GPIOA (SPI1 Pins: PA7, PA6, PA5, PA4 + RST: PA8)
    ; PA7=B, PA6=4, PA5=B, PA4=4 (NSS must be defined for SPI to work)
    ldr r0, =GPIOA_CRL
    ldr r1, [r0]
    ldr r2, =0x0000FFFF         ; Keep PA0-PA3, Clear PA4-PA7
    and r1, r1, r2              
    ldr r2, =0xB4B40000         ; Set PA7=B, PA6=4, PA5=B, PA4=4
    orr r1, r1, r2
    str r1, [r0]

    ; Configure PA8 (RST) = 3
    ldr r0, =GPIOA_CRH
    ldr r1, [r0]
    ldr r2, =0xFFFFFFF0         ; Keep PA9-PA15, Clear PA8
    and r1, r1, r2              
    orr r1, r1, #0x00000003     ; Set PA8=3
    str r1, [r0]

    ; 3. Configure GPIOB (CS: PB12 + IRQ: PB9)
    ; LED configs (GPIOB_CRL) removed entirely.
    ldr r0, =GPIOB_CRH
    ldr r1, [r0]
    ldr r2, =0xFFF0FF0F         ; Keep PB15-13, PB11-10, PB8. Clear PB12 and PB9.
    and r1, r1, r2              
    ldr r2, =0x00030040         ; Set PB12=3 (Output), PB9=4 (Input Float)
    orr r1, r1, r2
    str r1, [r0]

    ; Set initial states for RST (PA8) and CS (PB12)
    ldr r0, =GPIOA_BSRR
    ldr r1, =(1<<8)
    str r1, [r0]
    ldr r0, =GPIOB_BSRR
    ldr r1, =(1<<12) 
    str r1, [r0]
    bl delay_long               

    ; 4. Setup EXTI9 (Port B, Pin 9)
    ldr r0, =AFIO_EXTICR3
    ldr r1, [r0]
    ldr r2, =0xFFFFFF0F         ; Clear EXTI9 bits (7:4)
    and r1, r1, r2
    orr r1, r1, #(0x1 << 4)     ; Set EXTI9 to Port B
    str r1, [r0]

    ldr r0, =EXTI_FTSR
    ldr r1, [r0]
    orr r1, r1, #(1<<9)         
    str r1, [r0]

    ldr r0, =EXTI_RTSR
    ldr r1, [r0]
    orr r1, r1, #(1<<9)         
    str r1, [r0]

    ldr r0, =EXTI_IMR
    ldr r1, [r0]
    orr r1, r1, #(1<<9)         
    str r1, [r0]

    ldr r0, =NVIC_ISER0
    ldr r1, =(1<<23)            
    str r1, [r0]

    ; 5. Configure SPI1
    ldr r0, =SPI1_CR1
    ldr r1, =0x037C             
    str r1, [r0]
    orr r1, r1, #(1<<6)         
    str r1, [r0]

    ; 6. Initialize RC522 
    mov r0, #CommandReg
    mov r1, #0x0F               
    bl rc522_write
    bl delay_long               

    ; FAST RECOVERY TIMER
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

    mov r0, #TxControlReg
    bl rc522_read
    orr r1, r0, #0x03
    mov r0, #TxControlReg
    bl rc522_write

    mov r0, #DivIEnReg
    mov r1, #0x80               
    bl rc522_write
    bl delay_short      
    POP {R0-R12,LR}
    ENDP
		
;===================================
;       MAIN LOOP
;===================================

	
	EXPORT main_loop
main_loop	PROC
    ; Turn off LEDs and reset elevator flag
    ldr r0, =GPIOB_BRR
    ldr r1, =0x03
    str r1, [r0]
    mov r10, #0

    bl delay_short              

    ; 7. Ping antenna for REQA
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
    bne main_loop               

process_card
    ; 8. Anti-Collision Phase
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
    beq main_loop

    mov r0, #ComIrqReg
    bl rc522_read
    tst r0, #0x01               
    bne main_loop
    tst r0, #0x30               
    beq anti_poll

    mov r0, #FIFOLevelReg
    bl rc522_read
    cmp r0, #5
	beq continue
    b main_loop 
continue
    ldr r4, =uid_buffer
    mov r5, #5
read_uid_loop
    mov r0, #FIFODataReg
    bl rc522_read
    strb r0, [r4], #1           
    subs r5, r5, #1
    bne read_uid_loop

    ; 9. Compare UID
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
    bl delay_long
    b main_loop

wrong_card
    bl delay_long
    b main_loop
    ENDP

; ==========================================
; ISR & SUBROUTINES
; ==========================================
    EXPORT rfid_isr
rfid_isr PROC
    push {r0,r1,r2,lr}
    ldr r0, =EXTI_PR
    ldr r1, =(1<<9)
    str r1, [r0]
    ldr r0, =irq_flag
    mov r1, #1
    str r1, [r0]
    dsb
    isb
    pop {r0,r1,r2,pc}
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
    ldr r0, =EXTI_PR
    ldr r1, =(1<<9)
    str r1, [r0]                
    ldr r0, =irq_flag
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