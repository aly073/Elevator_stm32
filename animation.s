; =============================================================================
; 6. MATRIX ANIMATION DRIVER (90 Deg CCW Adjusted)
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
    SUB R2, R7, #1             ; R2 = hardware row index (now physically a column)
    LDRB R9, [R4, R2]          ; R9 = current_byte for this column
    LDRB R10, [R5, R2]         ; R10 = target_byte for this column

    LDR R3, =target_num
    LDR R3, [R3]
    LDR R8, =current_num
    LDR R8, [R8]
    CMP R3, R8
    BGT calc_up_shift          ; If Target > Current, scroll up

calc_down_shift
    ; Shift logic for downward scroll
    ; Build a 32-bit frame: [Target(8)][Gap(3)][Current(8)]
    LSL R10, R10, #11          ; Shift Target into upper bits [18:11]
    ORR R8, R9, R10            ; Combine with Current at [7:0]
    LSR R8, R8, R6             ; Shift the viewport down by anim_step
    B format_send

calc_up_shift
    ; Shift logic for upward scroll
    ; Build a 32-bit frame: [Current(8)][Gap(3)][Target(8)]
    LSL R9, R9, #11            ; Shift Current into upper bits [18:11]
    ORR R8, R10, R9            ; Combine with Target at [7:0]
    MOV R3, #11                ; Max shift gap is 11
    SUB R3, R3, R6             ; Invert step (11 - anim_step)
    LSR R8, R8, R3             ; Shift the viewport up

format_send
    AND R8, R8, #0xFF          ; Mask out the 8 visible pixels for this column
    LSL R0, R7, #8             ; R7 is hardware row address (1-8)
    ORR R0, R0, R8             ; Combine address + shifted pixel data
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
    LDR R1, =SPI2_BASE
    STRH R0, [R1, #0x0C]
wait_rxne
    LDR R2, [R1, #0x08]
    TST R2, #0x01
    BEQ wait_rxne
    LDRH R2, [R1, #0x0C]
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
    LDR R0, =SPI2_BASE
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
; Bitmaps have been pre-rotated 90-degrees clockwise 
; so they render upright on your rotated screen
bitmap1 DCB 0x00, 0x00, 0x82, 0xFF, 0xFF, 0x80, 0x00, 0x00
bitmap2 DCB 0x00, 0xC2, 0xE3, 0xB1, 0x99, 0x8F, 0x86, 0x00
bitmap3 DCB 0x00, 0x42, 0xC3, 0x89, 0x89, 0xFF, 0x76, 0x00

    END