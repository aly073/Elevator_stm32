;   connections
;	TIM4_CH2  PB7  -> servo 1
;   TIM4_CH3  PB8  -> servo 2
;   TIM4_CH4  PB9  -> servo 3

;   pwm parameters
;   PSC  = 7       -> Timer clock = 8 MHz / (7+1) = 1 MHz  (1 count = 1 us)
;   ARR  = 19999   -> Period = 20 ms  (50 hz)
;   CCR  OPEN = 1000  
;   CCR  CLOSE = 2000  
; difference of 1 ms = 90 deg angle difference i think

        AREA    doors, CODE, READONLY
        THUMB
        GET     registers.inc

        EXPORT  doors_init
        EXPORT  OPEN_DOOR ;R0 = floor (1, 2, 3). open that door's floor
        EXPORT  CLOSE_DOOR ;RO = floor (1, 2, 3). close that door's floor
        EXPORT  CLOSE_ALL_DOORS ;closes all doors before moving

; TIM4 register offsets
TIM4_CR1        EQU     0x00
TIM4_EGR        EQU     0x14
TIM4_CCMR1      EQU     0x18    ; CH1 [7:0]  CH2 [15:8] ;ch2 for b7
TIM4_CCMR2      EQU     0x1C    ; CH3 [7:0]  CH4 [15:8] ;ch3 and ch4 for b8 and b9
TIM4_CCER       EQU     0x20
TIM4_PSC        EQU     0x28
TIM4_ARR        EQU     0x2C
TIM4_CCR2       EQU     0x38   
TIM4_CCR3       EQU     0x3C    
TIM4_CCR4       EQU     0x40    

TIM4_CLK_BIT     EQU    (1 << 2)
GPIOB_CLK_BIT    EQU     (1 << 3)

; servo pulse widths in microseconds 
DOOR_OPEN_CCR   EQU     1000 ;1ms
DOOR_CLOSE_CCR  EQU     2000  ;2ms 

; delay variable if needed?
DOOR_SETTLE_CNT EQU     12000000

; configure TIM4 CH2/CH3/CH4 for 50 Hz PWM on PB7/PB8/PB9
; all three doors are driven to the closed position
; call during startup
doors_init PROC
        PUSH    {R0-R3, LR}
	    ; Enable GPIOB clock (already done in config but needed to separately enable it to test)
        LDR     R0, =RCC_APB2ENR
        LDR     R1, [R0]
        ORR     R1, R1, #GPIOB_CLK_BIT
        STR     R1, [R0]

        ; enable TIM4 clock on APB1
        LDR     R0, =RCC_APB1ENR
        LDR     R1, [R0]
        ORR     R1, R1, #TIM4_CLK_BIT
        STR     R1, [R0]

        ; CRL: PB7 -> bits [31:28] = 0xB
        LDR     R0, =GPIOB_CRL
        LDR     R1, [R0]
        BIC     R1, R1, #0xF0000000
        ORR     R1, R1, #0xB0000000
        STR     R1, [R0]

        ; CRH: PB8 bits [3:0] = 0xB, PB9 bits [7:4] = 0xB
        LDR     R0, =GPIOB_CRH
        LDR     R1, [R0]
        BIC     R1, R1, #0x000000FF     ; clear both nibbles
        ORR     R1, R1, #0x000000BB     ; PB9=0xB, PB8=0xB
        STR     R1, [R0]

        ; TIM4 PWM setup
        LDR     R0, =TIM4_BASE

        ; PSC = 7
        LDR     R1, =7
        STR     R1, [R0, #TIM4_PSC]

        ; ARR = 19999
        LDR     R1, =19999
        STR     R1, [R0, #TIM4_ARR]

        ; CCMR1: configure CH2 (bits [15:8]) as PWM Mode 1 with preload
        ;   OC2M [14:12] = 110, OC2PE [11] = 1  -> upper byte = 0x68
        ;   Leave CH1 bits [7:0] as zero (bec pb6 not not used)
        LDR     R1, [R0, #TIM4_CCMR1]
        BIC     R1, R1, #0xFF00
        ORR     R1, R1, #0x6800
        STR     R1, [R0, #TIM4_CCMR1]

        ; CCMR2: configure CH3 [7:0] and CH4 [15:8] as PWM Mode 1 with preload
        ;   Both bytes = 0x68
        LDR     R1, =0x6868
        STR     R1, [R0, #TIM4_CCMR2]

        ; CCER: enable CH2 output (bit 4), CH3 output (bit 8), CH4 output (bit 12)
        LDR     R1, [R0, #TIM4_CCER]
		LDR     R2, =0x1110
		ORR     R1, R1, R2
        STR     R1, [R0, #TIM4_CCER]

        ; start with closed position before starting counter
        LDR     R1, =DOOR_CLOSE_CCR
        STR     R1, [R0, #TIM4_CCR2]   ; PB7 Floor 1 closed
        STR     R1, [R0, #TIM4_CCR3]   ; PB8 Floor 2 closed
        STR     R1, [R0, #TIM4_CCR4]   ; PB9 Floor 3 closed

        ; force update event to push PSC/ARR/CCR into shadow registers
        MOV     R1, #1
        STR     R1, [R0, #TIM4_EGR]

        ; Start counter: ARPE=1 (bit 7), CEN=1 (bit 0)
        LDR     R1, [R0, #TIM4_CR1]
        ORR     R1, R1, #0x81
        STR     R1, [R0, #TIM4_CR1]

        POP     {R0-R3, PC}
        ENDP


OPEN_DOOR PROC
        PUSH    {R0-R3, LR}

        LDR     R1, =TIM4_BASE
        LDR     R2, =DOOR_OPEN_CCR

        CMP     R0, #1
        BEQ     od_floor1
        CMP     R0, #2
        BEQ     od_floor2
        CMP     R0, #3
        BEQ     od_floor3
        B       od_done

od_floor1
        STR     R2, [R1, #TIM4_CCR2]   ; PB7
        B       od_settle
od_floor2
        STR     R2, [R1, #TIM4_CCR3]   ; PB8
        B       od_settle
od_floor3
        STR     R2, [R1, #TIM4_CCR4]   ; PB9

od_settle
        LDR     R3, =DOOR_SETTLE_CNT
od_settle_loop
        SUBS    R3, R3, #1
        BNE     od_settle_loop

od_done
        POP     {R0-R3, PC}
        ENDP


CLOSE_DOOR PROC
        PUSH    {R0-R3, LR}

        LDR     R1, =TIM4_BASE
        LDR     R2, =DOOR_CLOSE_CCR

        CMP     R0, #1
        BEQ     cd_floor1
        CMP     R0, #2
        BEQ     cd_floor2
        CMP     R0, #3
        BEQ     cd_floor3
        B       cd_done

cd_floor1
        STR     R2, [R1, #TIM4_CCR2]   ; PB7
        B       cd_settle
cd_floor2
        STR     R2, [R1, #TIM4_CCR3]   ; PB8
        B       cd_settle
cd_floor3
        STR     R2, [R1, #TIM4_CCR4]   ; PB9

cd_settle
        LDR     R3, =DOOR_SETTLE_CNT
cd_settle_loop
        SUBS    R3, R3, #1
        BNE     cd_settle_loop

cd_done
        POP     {R0-R3, PC}
        ENDP


; drive all doors to closed position
CLOSE_ALL_DOORS PROC
        PUSH    {R0-R3, LR}

        LDR     R0, =TIM4_BASE
        LDR     R1, =DOOR_CLOSE_CCR

        STR     R1, [R0, #TIM4_CCR2]   ; PB7 
        STR     R1, [R0, #TIM4_CCR3]   ; PB8 
        STR     R1, [R0, #TIM4_CCR4]   ; PB9 

        LDR     R3, =DOOR_SETTLE_CNT
cad_settle_loop
        SUBS    R3, R3, #1
        BNE     cad_settle_loop

        POP     {R0-R3, PC}
        ENDP

        END