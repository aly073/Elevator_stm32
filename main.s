    IMPORT  TIM2_IRQHandler
    IMPORT  EXTI0_IRQHandler
    IMPORT  EXTI1_IRQHandler
    IMPORT  EXTI2_IRQHandler
    IMPORT  EXTI3_IRQHandler
    IMPORT  EXTI9_5_IRQHandler

    AREA    RESET, DATA, READONLY
    ALIGN   2
    EXPORT  __Vectors
    EXPORT  __Vectors_End
    EXPORT  __Vectors_Size
__Vectors
    DCD     0x20005000
    DCD     Reset_Handler
    SPACE   80
    DCD     EXTI0_IRQHandler
    DCD     EXTI1_IRQHandler
    DCD     EXTI2_IRQHandler
    DCD     EXTI3_IRQHandler
    SPACE   52
    DCD     EXTI9_5_IRQHandler
    SPACE   16
    DCD     TIM2_IRQHandler
__Vectors_End
__Vectors_Size  EQU __Vectors_End - __Vectors


    AREA	mycode, CODE, READONLY
    THUMB
    EXPORT  Reset_Handler
    EXPORT  __main
    
    ;includes
    GET     registers.inc
    IMPORT  config
    IMPORT  elevatorState
    IMPORT  currentFloor
    IMPORT  requests
    IMPORT  current_num
    IMPORT  target_num
    IMPORT  anim_step
    IMPORT  anim_active
    IMPORT  pending_stop
    IMPORT  pending_dir
    IMPORT  delay_systick
    IMPORT  GO_DOWN
    IMPORT  STOP
    IMPORT  GO_UP

;============================================================
; Main function
;============================================================
	ENTRY

Reset_Handler FUNCTION
    B		__main
    ENDFUNC

__main FUNCTION
	BL		config

main_loop
    WFI
    B main_loop
	ENDFUNC

    END