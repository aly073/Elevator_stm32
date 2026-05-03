<<<<<<< Updated upstream
    AREA    defs, CODE, READONLY
=======
AREA    defs, CODE, READONLY
>>>>>>> Stashed changes
    GET     registers.inc
    EXPORT  GO_DOWN
    EXPORT  STOP
    EXPORT  GO_UP
    IMPORT  PLAY_MOVEMENT_AUDIO
    IMPORT  PLAY_STOP_AUDIO

; Mask for PB10 and PB11 (Bits 10 and 11) = 0x0C00
DIR_MASK EQU 0x0C00 

GO_DOWN FUNCTION
        PUSH    {R0-R2, LR}
        LDR     R0, =GPIOB_ODR
        LDR     R2, [R0]            ; Read current state
        
        ; Check if PB11=1 and PB10=0 (0x0800)
        AND     R1, R2, #DIR_MASK
        CMP     R1, #0x0800
        BEQ     DONE_DOWN           ; Early exit if already going DOWN
        
        ; Apply new state while preserving other bits
        BIC     R2, R2, #DIR_MASK   ; Clear PB10/11
<<<<<<< Updated upstream
        ORR     R2, R2, #(1 << 11)		    ; Set DOWN state + your base bits
=======
        LDR     R1, =0x0863
        ORR     R2, R2, R1          ; Set DOWN state + base bits
>>>>>>> Stashed changes
        STR     R2, [R0]

        ; === Trigger Audio (Only plays if we weren't already going down)
        BL      PLAY_MOVEMENT_AUDIO

DONE_DOWN
        POP     {R0-R2, PC}
        ENDFUNC

STOP FUNCTION
        PUSH    {R0-R2, LR}
        LDR     R0, =GPIOB_ODR
        LDR     R2, [R0]
        
        ; Check if PB10=0 and PB11=0
        TST     R2, #DIR_MASK
        BEQ     DONE_STOP           ; Early exit if already STOPPED
        
        BIC     R2, R2, #DIR_MASK   ; Clear direction bits
        STR     R2, [R0]

        ; === Trigger Audio (Only plays if we were actually moving)
        BL      PLAY_STOP_AUDIO

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
<<<<<<< Updated upstream
        ORR     R2, R2,	#(1 << 10)		    ; Set UP state
=======
        LDR     R1, =0x0463 
        ORR     R2, R2, R1          ; Set UP state
>>>>>>> Stashed changes
        STR     R2, [R0]

        ; === Trigger Audio
        BL      PLAY_MOVEMENT_AUDIO

DONE_UP
        POP     {R0-R2, PC}
        ENDFUNC

    END