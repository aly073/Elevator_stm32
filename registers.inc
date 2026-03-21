;============================================================
; STM32F103 register addresses only (DO NOT ADD VARIABLES HERE)
;============================================================
; RCC register addresses
RCC_APB2ENR EQU 0x40021018

; GPIOC register addresses
GPIOC_CRH   EQU 0x40011004
GPIOC_ODR   EQU 0x4001100C


; SysTick Register Addresses
STK_CTRL    EQU 0xE000E010    ; Control and Status Register
STK_LOAD    EQU 0xE000E014    ; Reload Value Register
STK_VAL     EQU 0xE000E018    ; Current Value Register