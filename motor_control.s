    AREA    defs, CODE, READONLY
    GET     registers.inc
    EXPORT  GO_DOWN
    EXPORT  STOP
    EXPORT  GO_UP
    IMPORT  PLAY_MOVEMENT_AUDIO
    IMPORT  PLAY_STOP_AUDIO
    IMPORT  check_weight

; Mask for PB1 and PB11 (Bits 1 and 11) = 0x0802
DIR_MASK EQU 0x0802 

GO_DOWN FUNCTION
        PUSH    {R0-R3, LR}
        LDR     R0, =GPIOB_ODR
        LDR     R2, [R0]            ; Read current state
        LDR     R3, =DIR_MASK
        
        ; Check if PB11=1 and PB1=0 (0x0800)
        AND     R1, R2, R3
        CMP     R1, #0x0800
        BEQ     DONE_DOWN           ; Early exit if already going DOWN

        ; Check weight < Threshold
        BL check_weight
        
        ; Apply new state while preserving other bits
        BIC     R2, R2, R3          ; Clear PB1/PB11
        ORR     R2, R2, #(1 << 11)		    ; Set DOWN state + your base bits
		
        STR     R2, [R0]

        ; === Trigger Audio (Only plays if we weren't already going down)
        BL      PLAY_MOVEMENT_AUDIO

DONE_DOWN
        POP     {R0-R3, PC}
        ENDFUNC

STOP FUNCTION
        PUSH    {R0-R3, LR}
        LDR     R0, =GPIOB_ODR
        LDR     R2, [R0]
        LDR     R3, =DIR_MASK
        
        ; Check if PB1=0 and PB11=0
        TST     R2, R3
        BEQ     DONE_STOP           ; Early exit if already STOPPED
        
        BIC     R2, R2, R3          ; Clear direction bits
        STR     R2, [R0]

        ; === Trigger Audio (Only plays if we were actually moving)
        BL      PLAY_STOP_AUDIO

DONE_STOP
        POP     {R0-R3, PC}
        ENDFUNC

GO_UP FUNCTION
        PUSH    {R0-R3, LR}
        LDR     R0, =GPIOB_ODR
        LDR     R2, [R0]
        LDR     R3, =DIR_MASK
        
        ; Check if PB1=1 and PB11=0 (0x0002)
        AND     R1, R2, R3
        CMP     R1, #0x0002
        BEQ     DONE_UP             ; Early exit if already going UP

        ; Check weight < Threshold
        BL check_weight
        
        BIC     R2, R2, R3          ; Clear PB1/PB11
        ORR     R2, R2,	#(1 << 1)		    ; Set UP state
        STR     R2, [R0]

        ; === Trigger Audio
        BL      PLAY_MOVEMENT_AUDIO

DONE_UP
        POP     {R0-R3, PC}
        ENDFUNC

    END