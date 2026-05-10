; =============================================================================
; 6. MATRIX ANIMATION DRIVER
; =============================================================================

    AREA    animation, CODE, READONLY
    THUMB
    GET     registers.inc

    ; ========= Exports (functions provided by this file) =========
    EXPORT  TIM2_IRQHandler
    EXPORT  get_bitmap_ptr_current
    EXPORT  get_bitmap_ptr_target
    EXPORT  send_16bit
    EXPORT  matrix_init
    EXPORT  draw_initial_state
    EXPORT  get_bitmap_ptr
    EXPORT  bitmap1
    EXPORT  bitmap2
    EXPORT  bitmap3

    ; ========= Imports (symbols/functions used from other files) =========
    ; state variables
    IMPORT  anim_active
    IMPORT  current_num
    IMPORT  target_num
    IMPORT  anim_step
    IMPORT  pending_stop
    IMPORT  pending_dir

    ; cross-module functions
    IMPORT  stopAndServe
    IMPORT  checkNextMove
    
TIM2_IRQHandler
    PUSH {R4-R11, LR}
    
    LDR R0, =TIM2_BASE
    MOV R1, #0
    STR R1, [R0, #0x10]

    LDR R0, =anim_active
    LDR R1, [R0]
    CMP R1, #0
    BEQ irq_exit

    LDR R0, =current_num
    LDR R1, [R0]
    LDR R2, =target_num
    LDR R3, [R2]
    CMP R1, R3
    BEQ finish_anim

    LDR R4, =anim_step
    LDR R6, [R4]

    BL get_bitmap_ptr_current
    MOV R4, R0
    BL get_bitmap_ptr_target
    MOV R5, R0

    MOV R7, #1
row_loop
    SUB R2, R7, #1
    LDR R3, =target_num
    LDR R3, [R3]
    LDR R8, =current_num
    LDR R8, [R8]
    CMP R3, R8
    BGT calc_up

calc_down
    ADD R3, R2, R6
    CMP R3, #8
    BLT load_curr_down
    CMP R3, #11
    BLT load_gap_down
    SUB R3, R3, #11
    LDRB R8, [R5, R3]
    B send_row
load_curr_down
    LDRB R8, [R4, R3]
    B send_row
load_gap_down
    MOV R8, #0
    B send_row

calc_up
    SUBS R3, R2, R6
    CMP R3, #0
    BGE load_curr_up
    CMP R3, #-3
    BGE load_gap_up
    ADD R3, R3, #11
    LDRB R8, [R5, R3]
    B send_row
load_curr_up
    LDRB R8, [R4, R3]
    B send_row
load_gap_up
    MOV R8, #0

send_row
    LSL R0, R7, #8
    ORR R0, R0, R8
    BL send_16bit
    ADD R7, R7, #1
    CMP R7, #9
    BLT row_loop

    LDR R4, =anim_step
    LDR R6, [R4]
    ADD R6, R6, #1
    STR R6, [R4]
    CMP R6, #12
    BLT irq_exit

    MOV R6, #0
    STR R6, [R4]
    LDR R4, =current_num
    LDR R5, =target_num
    LDR R6, [R5]
    STR R6, [R4]

finish_anim
    LDR R0, =anim_active
    MOV R1, #0
    STR R1, [R0]

    LDR R0, =TIM2_BASE
    LDR R1, [R0, #0x00]
    BIC R1, R1, #1
    STR R1, [R0, #0x00]

    LDR R0, =pending_stop
    LDR R1, [R0]
    CMP R1, #1
    BNE irq_exit

    MOV R1, #0
    STR R1, [R0]
    BL stopAndServe

    LDR R0, =pending_dir
    LDR R0, [R0]
    BL checkNextMove

irq_exit
    POP {R4-R11, PC}

get_bitmap_ptr_current
    PUSH {LR}
    LDR R0, =current_num
    LDR R1, [R0]
    BL get_bitmap_ptr
    POP {PC}

get_bitmap_ptr_target
    PUSH {LR}
    LDR R0, =target_num
    LDR R1, [R0]
    BL get_bitmap_ptr
    POP {PC}

send_16bit
    PUSH {R4, LR}
    LDR R1, =GPIOA_BASE
    LDR R2, [R1, #0x0C]
    BIC R2, #CS_PIN
    STR R2, [R1, #0x0C]
    LDR R1, =SPI1_BASE
    STR R0, [R1, #0x0C]
wait_rxne
    LDR R2, [R1, #0x08]
    TST R2, #0x01
    BEQ wait_rxne
    LDR R2, [R1, #0x0C]
wait_bsy
    LDR R2, [R1, #0x08]
    TST R2, #0x80
    BNE wait_bsy
    LDR R1, =GPIOA_BASE
    LDR R2, [R1, #0x0C]
    ORR R2, #CS_PIN
    STR R2, [R1, #0x0C]
    POP {R4, PC}

matrix_init
    PUSH {LR}
    LDR R0, =SPI1_BASE
    LDR R1, =0x0B1C
    STR R1, [R0, #0x00]
    ORR R1, #0x0040
    STR R1, [R0, #0x00]
    MOVW R0, #0x0F00
    BL send_16bit
    MOVW R0, #0x0B07
    BL send_16bit
    MOVW R0, #0x0900
    BL send_16bit
    MOVW R0, #0x0A08
    BL send_16bit
    MOVW R0, #0x0C01
    BL send_16bit
    POP {PC}

draw_initial_state
    PUSH {LR}
    LDR R4, =bitmap1
    MOV R7, #1
draw_init_loop
    SUB R3, R7, #1
    LDRB R8, [R4, R3]
    LSL R0, R7, #8
    ORR R0, R0, R8
    BL send_16bit
    ADD R7, R7, #1
    CMP R7, #9
    BLT draw_init_loop
    POP {PC}

get_bitmap_ptr
    CMP R1, #0
    BEQ is_0
    CMP R1, #1
    BEQ is_1
is_2
    LDR R0, =bitmap3
    BX LR
is_0
    LDR R0, =bitmap1
    BX LR
is_1
    LDR R0, =bitmap2
    BX LR

    AREA    animation_data, DATA, READONLY
    ALIGN   2
bitmap1 DCB 0x18, 0x38, 0x18, 0x18, 0x18, 0x18, 0x18, 0x3C
bitmap2 DCB 0x3C, 0x66, 0x06, 0x0C, 0x18, 0x30, 0x60, 0x7E
bitmap3 DCB 0x3C, 0x66, 0x06, 0x1C, 0x06, 0x06, 0x66, 0x3C

    END
