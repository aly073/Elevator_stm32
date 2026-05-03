<<<<<<< Updated upstream
    AREA    defs, CODE, READONLY
    GET     registers.inc
    EXPORT  GO_DOWN
    EXPORT  STOP
    EXPORT  GO_UP

; Mask for PB10 and PB11 (Bits 10 and 11) = 0x0C00
DIR_MASK EQU 0x0C00 

GO_DOWN FUNCTION
        PUSH    {R0-R2, LR}         ; Reduced register push for efficiency
        LDR     R0, =GPIOB_ODR
        LDR     R2, [R0]            ; Read current state
        
        ; Check if PB11=1 and PB10=0 (0x0800)
        AND     R1, R2, #DIR_MASK
        CMP     R1, #0x0800
        BEQ     DONE_DOWN           ; Early exit if already going DOWN
        
        ; Apply new state while preserving other bits
        BIC     R2, R2, #DIR_MASK   ; Clear PB10/11
        LDR     R1, =0x0863
		ORR     R2, R2, R1		    ; Set DOWN state + your base bits
        STR     R2, [R0]

DONE_DOWN
        POP     {R0-R2, PC}
        ENDFUNC

STOP FUNCTION
        PUSH    {R0-R2, LR}
        LDR     R0, =GPIOB_ODR
        LDR     R2, [R0]
        
        ; Check if PB10=0 and PB11=0
        TST     R2, #DIR_MASK
        BEQ     DONE_STOP           ; Early exit if already STOPPED (bits are 0)
        
        BIC     R2, R2, #DIR_MASK   ; Clear direction bits
        STR     R2, [R0]

DONE_STOP
        POP     {R0-R2, PC}
        ENDFUNC

GO_UP FUNCTION
        PUSH    {R0-R2, LR}
        LDR     R0, =GPIOB_ODR
        LDR     R2, [R0]
        
        ; Check if PB10=1 and PB11=0 (0x0400)
        AND     R1, R2, #DIR_MASK
        CMP     R1, #0x0400
        BEQ     DONE_UP             ; Early exit if already going UP
        
        BIC     R2, R2, #DIR_MASK   ; Clear PB10/11
        LDR		R1, =0x0463 
		ORR     R2, R2,	R1		    ; Set UP state
        STR     R2, [R0]

DONE_UP
        POP     {R0-R2, PC}
=======
    AREA	defs, CODE, READONLY
	GET     registers.inc
    EXPORT GO_DOWN
    EXPORT STOP
    EXPORT GO_UP
        IMPORT PLAY_MOVEMENT_AUDIO
        IMPORT PLAY_STOP_AUDIO

GO_DOWN FUNCTION
        PUSH    {R0-R12, LR}
        ; === Set direction Go DOWN
        LDR     R0, =GPIOB_ODR
        LDR     R1, =0x0863  ; PB10=0, PB11=1 (Motor Reverse)
        STR     R1, [R0]
        
        ; === Trigger Audio
        BL      PLAY_MOVEMENT_AUDIO
        
        POP     {R0-R12, PC}
        ENDFUNC

STOP FUNCTION
        PUSH    {R0-R12, LR}
        ; === Set direction STOP
        LDR     R0, =GPIOB_ODR
        LDR     R2, [R0]
        LDR     R1, =0x0063  ; PB10=0, PB11=0 (Motor stop)
        AND     R2, R2, R1
        STR     R2, [R0]
        
        BL      PLAY_STOP_AUDIO
        
        POP     {R0-R12, PC}
        ENDFUNC

GO_UP FUNCTION
        PUSH    {R0-R12, LR}
        ; === Set direction Go UP
        LDR     R0, =GPIOB_ODR
        LDR     R1, =0x0463 ; PB10=1, PB11=0 (Motor forward)
        STR     R1, [R0]
        
        ; === Trigger Audio
        BL      PLAY_MOVEMENT_AUDIO
        
        POP     {R0-R12, PC}
>>>>>>> Stashed changes
        ENDFUNC

    END