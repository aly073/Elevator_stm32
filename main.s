    AREA	mycode, CODE, READONLY
    EXPORT  __main
    
    ;includes
    GET     registers.inc
    IMPORT  config
    IMPORT  delay_systick
    IMPORT  GO_DOWN
    IMPORT  STOP
    IMPORT  GO_UP

;============================================================
; Main function
;============================================================
	ENTRY

__main FUNCTION
	BL		config

main_loop
    ; === Move elevator down by setting servo angle to 0 degrees
    BL      GO_DOWN
    ; === Wait for 2 seconds
    BL      delay_systick

    BL    STOP
    ; === Wait for 1 second
    BL      delay_systick
    ; === Move elevator up by setting servo angle to 180 degrees
    BL      GO_UP
    ; === Wait for 2 seconds
    BL      delay_systick
    B       main_loop
    ENDFUNC
	
    END
	