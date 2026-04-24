    AREA    elevator, CODE, READONLY
    THUMB
    GET     registers.inc

    EXPORT  EXTI0_IRQHandler
    EXPORT  EXTI1_IRQHandler
    EXPORT  EXTI2_IRQHandler
    EXPORT  EXTI3_IRQHandler
    EXPORT  EXTI9_5_IRQHandler
    EXPORT  stopAndServe
    EXPORT  checkNextMove
    EXPORT  elevatorState
    EXPORT  currentFloor
    EXPORT  requests
    EXPORT  current_num
    EXPORT  target_num
    EXPORT  anim_step
    EXPORT  anim_active
    EXPORT  pending_stop
    EXPORT  pending_dir

    IMPORT  GO_DOWN
    IMPORT  STOP
    IMPORT  GO_UP

; =============================================================================
; ELEVATOR LOGIC & INTERRUPTS
; =============================================================================
EXTI0_IRQHandler
    PUSH {LR}
    LDR R0, =EXTI_PR
    MOV R1, #(1 << 0)
    STR R1, [R0]
    LDR R0, =requests
    MOV R1, #1
    STRB R1, [R0, #0]
    LDR R0, =elevatorState
    LDRB R0, [R0]
    BL checkNextMove
    POP {PC}

EXTI1_IRQHandler
    PUSH {LR}
    LDR R0, =EXTI_PR
    MOV R1, #(1 << 1)
    STR R1, [R0]
    LDR R0, =requests
    MOV R1, #1
    STRB R1, [R0, #2]
    LDR R0, =elevatorState
    LDRB R0, [R0]
    BL checkNextMove
    POP {PC}

EXTI2_IRQHandler
    PUSH {LR}
    LDR R0, =EXTI_PR
    MOV R1, #(1 << 2)
    STR R1, [R0]
    LDR R0, =requests
    MOV R1, #1
    STRB R1, [R0, #3]
    LDR R0, =elevatorState
    LDRB R0, [R0]
    BL checkNextMove
    POP {PC}

EXTI3_IRQHandler
    PUSH {LR}
    LDR R0, =EXTI_PR
    MOV R1, #(1 << 3)
    STR R1, [R0]
    LDR R0, =requests
    MOV R1, #1
    STRB R1, [R0, #4]
    LDR R0, =elevatorState
    LDRB R0, [R0]
    BL checkNextMove
    POP {PC}

EXTI9_5_IRQHandler
    PUSH {LR}
    LDR R0, =EXTI_PR
    LDR R1, [R0]

check_line7
    TST R1, #(1 << 7)
    BEQ check_line8
    MOV R2, #(1 << 7)
    STR R2, [R0]
    LDR R3, =requests
    MOV R4, #1
    STRB R4, [R3, #1]
    LDR R0, =elevatorState
    LDRB R0, [R0]
    BL checkNextMove
    B exti9_5_end

check_line8
    TST R1, #(1 << 8)
    BEQ check_line5
    MOV R2, #(1 << 8)
    STR R2, [R0]
    MOV R0, #1
    BL handle_sensor
    B exti9_5_end

check_line5
    TST R1, #(1 << 5)
    BEQ check_line6
    MOV R2, #(1 << 5)
    STR R2, [R0]
    MOV R0, #2
    BL handle_sensor
    B exti9_5_end

check_line6
    TST R1, #(1 << 6)
    BEQ exti9_5_end
    MOV R2, #(1 << 6)
    STR R2, [R0]
    MOV R0, #3
    BL handle_sensor

exti9_5_end
    POP {PC}

handle_sensor
    PUSH {R4-R8, LR}

    ; save direction/state
    LDR R1, =elevatorState
    LDRB R4, [R1]

    ; old display index
    LDR R1, =current_num
    LDR R5, [R1]

    ; update floor from sensor
    LDR R1, =currentFloor
    STRB R0, [R1]
    SUB R6, R0, #1

    BL shouldStop
    CMP R0, #1
    BNE hs_pass

    ; stop floor -> animation and turn off motors
    LDR R1, =pending_stop
    MOV R2, #1
    STR R2, [R1]
    LDR R1, =pending_dir
    STR R4, [R1]

    BL motor_off_only

    CMP R5, R6
    BEQ hs_no_anim_stop_floor

    LDR R1, =current_num
    STR R5, [R1]
    LDR R1, =target_num
    STR R6, [R1]
    LDR R1, =anim_step
    MOV R2, #0
    STR R2, [R1]
    LDR R1, =anim_active
    MOV R2, #1
    STR R2, [R1]
    LDR R1, =TIM2_BASE
    LDR R2, [R1, #0x00]
    ORR R2, R2, #1
    STR R2, [R1, #0x00]
    B hs_done

hs_no_anim_stop_floor
    ; no animation needed; stop now
    LDR R1, =pending_stop
    MOV R2, #0
    STR R2, [R1]
    BL stopAndServe
    MOV R0, R4
    BL checkNextMove
    B hs_done

hs_pass
    CMP R5, R6
    BEQ hs_done
    LDR R1, =current_num
    STR R5, [R1]
    LDR R1, =target_num
    STR R6, [R1]
    LDR R1, =anim_step
    MOV R2, #0
    STR R2, [R1]
    LDR R1, =anim_active
    MOV R2, #1
    STR R2, [R1]
    LDR R1, =TIM2_BASE
    LDR R2, [R1, #0x00]
    ORR R2, R2, #1
    STR R2, [R1, #0x00]

hs_done
    POP {R4-R8, PC}

shouldStop
    LDR R0, =currentFloor
    LDRB R0, [R0]
    LDR R1, =requests

    CMP R0, #1
    BNE ss_chk3
    LDRB R2, [R1, #0]
    CMP R2, #0
    BNE ss_true
    B ss_false
ss_chk3
    CMP R0, #3
    BNE ss_chk2
    LDRB R2, [R1, #4]
    CMP R2, #0
    BNE ss_true
    B ss_false
ss_chk2
    CMP R0, #2
    BNE ss_false
    LDRB R2, [R1, #1]
    CMP R2, #0
    BNE ss_true
    LDR R3, =elevatorState
    LDRB R3, [R3]
    CMP R3, #MOVING_UP
    BNE ss_chk2_down
    LDRB R2, [R1, #2]
    CMP R2, #0
    BNE ss_true
    B ss_false
ss_chk2_down
    CMP R3, #MOVING_DOWN
    BNE ss_false
    LDRB R2, [R1, #3]
    CMP R2, #0
    BNE ss_true
ss_false
    MOV R0, #0
    BX LR
ss_true
    MOV R0, #1
    BX LR

stopAndServe
    PUSH {LR}
    ; turn off motors through motor control module
    BL STOP

    ; set stopped
    LDR R0, =elevatorState
    MOV R1, #STOPPED
    STRB R1, [R0]

    ; clear requests
    LDR R0, =currentFloor
    LDRB R0, [R0]
    LDR R1, =requests
    MOV R2, #0

    CMP R0, #1
    BNE st_chk2
    STRB R2, [R1, #0]
    B st_done
st_chk2
    CMP R0, #2
    BNE st_chk3
    STRB R2, [R1, #1]
    LDR R3, =elevatorState
    LDRB R3, [R3]
    CMP R3, #MOVING_UP
    BNE st_chk_down
    STRB R2, [R1, #2]
    B st_done
st_chk_down
    CMP R3, #MOVING_DOWN
    BNE st_done
    STRB R2, [R1, #3]
    B st_done
st_chk3
    CMP R0, #3
    BNE st_done
    STRB R2, [R1, #4]

st_done
    BL delay_2000ms
    POP {PC}

checkNextMove
    PUSH {R4-R7, LR}
    MOV R4, R0

    LDR R5, =elevatorState
    LDRB R6, [R5]
    CMP R6, #STOPPED
    BNE cnm_end

    LDR R7, =currentFloor
    LDRB R7, [R7]
    LDR R1, =requests

    CMP R4, #MOVING_UP
    BNE cnm_moving_down

cnm_moving_up
    LDRB R2, [R1, #4]
    CMP R2, #0
    BEQ cmu_req_mid
    CMP R7, #3
    BNE set_up
    MOV R2, #0
    STRB R2, [R1, #4]
    B cnm_update_motors
cmu_req_mid
    LDRB R2, [R1, #1]
    LDRB R3, [R1, #2]
    ORR R2, R2, R3
    LDRB R3, [R1, #3]
    ORR R2, R2, R3
    CMP R2, #0
    BEQ cmu_req_down
    CMP R7, #2
    BLT mid_up
    BGT mid_down
    MOV R2, #0
    STRB R2, [R1, #1]
    STRB R2, [R1, #2]
    STRB R2, [R1, #3]
    B cnm_update_motors
cmu_req_down
    LDRB R2, [R1, #0]
    CMP R2, #0
    BEQ cnm_update_motors
    CMP R7, #1
    BNE set_down
    MOV R2, #0
    STRB R2, [R1, #0]
    B cnm_update_motors

cnm_moving_down
    LDRB R2, [R1, #0]
    CMP R2, #0
    BEQ cmd_req_mid
    CMP R7, #1
    BGT set_down
    MOV R2, #0
    STRB R2, [R1, #0]
    B cnm_update_motors
cmd_req_mid
    LDRB R2, [R1, #1]
    LDRB R3, [R1, #2]
    ORR R2, R2, R3
    LDRB R3, [R1, #3]
    ORR R2, R2, R3
    CMP R2, #0
    BEQ cmd_req_up
    CMP R7, #2
    BLT mid_up
    BGT mid_down
    MOV R2, #0
    STRB R2, [R1, #1]
    STRB R2, [R1, #2]
    STRB R2, [R1, #3]
    B cnm_update_motors
cmd_req_up
    LDRB R2, [R1, #4]
    CMP R2, #0
    BEQ cnm_update_motors
    CMP R7, #3
    BLT set_up
    MOV R2, #0
    STRB R2, [R1, #4]
    B cnm_update_motors

mid_up
    MOV R2, #1
    STRB R2, [R1, #1]
set_up
    MOV R2, #MOVING_UP
    STRB R2, [R5]
    B cnm_update_motors
mid_down
    MOV R2, #1
    STRB R2, [R1, #1]
set_down
    MOV R2, #MOVING_DOWN
    STRB R2, [R5]

cnm_update_motors
    BL update_motors

cnm_end
    POP {R4-R7, PC}

update_motors
    PUSH {LR}
    LDR R1, =elevatorState
    LDRB R1, [R1]

    CMP R1, #MOVING_UP
    BEQ um_go_up
    CMP R1, #MOVING_DOWN
    BEQ um_go_down
    BL STOP
    B um_done

um_go_up
    BL GO_UP
    B um_done

um_go_down
    BL GO_DOWN

um_done
    POP {PC}

delay_2000ms
    LDR R0, =4800000
delay_loop
    SUBS R0, R0, #1
    BNE delay_loop
    BX LR

motor_off_only
    PUSH {LR}
    BL STOP
    POP {PC}

    AREA    elevator_data, DATA, READWRITE
    ALIGN   2
    EXPORT  elevatorState
    EXPORT  currentFloor
    EXPORT  requests
    EXPORT  anim_step
    EXPORT  current_num
    EXPORT  target_num
    EXPORT  anim_active
    EXPORT  pending_stop
    EXPORT  pending_dir

elevatorState    SPACE   1
currentFloor     SPACE   1
                 ALIGN   2
requests         SPACE   5
anim_step        SPACE   4
current_num      SPACE   4
target_num       SPACE   4
anim_active      SPACE   4
pending_stop     SPACE   4
pending_dir      SPACE   4

    END