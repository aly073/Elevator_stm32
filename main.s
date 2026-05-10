    IMPORT  TIM2_IRQHandler
    IMPORT  EXTI0_IRQHandler
    IMPORT  EXTI1_IRQHandler
    IMPORT  EXTI2_IRQHandler
    IMPORT  EXTI4_IRQHandler
    IMPORT  EXTI3_IRQHandler
    IMPORT  EXTI9_5_IRQHandler
    IMPORT  EXTI15_10_IRQHandler
	IMPORT  USART1_IRQHandler
	IMPORT 	TIM1_UP_IRQHandler
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
    DCD     EXTI4_IRQHandler
    SPACE   48
    DCD     EXTI9_5_IRQHandler
    DCD     0                       ; IRQ 24: TIM1_BRK (not used)
    DCD     TIM1_UP_IRQHandler      ; IRQ 25: TIM1_UP
    DCD     0                       ; IRQ 26: TIM1_TRG_COM (not used)
    DCD     0                       ; IRQ 27: TIM1_CC (not used)
    DCD     TIM2_IRQHandler
    SPACE   32
    DCD     USART1_IRQHandler
    SPACE   8
    DCD     EXTI15_10_IRQHandler
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
    IMPORT  OPEN_DOOR
	IMPORT  CLOSE_DOOR

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
    WFI			; Put CPU in low power state waiting for interrupt
    B main_loop
	ENDFUNC

    END