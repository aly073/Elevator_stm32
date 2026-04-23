;============================================================
; STM32F103 register addresses only (DO NOT ADD VARIABLES HERE)
; Complete register definitions for STM32F103C8 microcontroller
;============================================================

;============================================================
; MEMORY MAP BASE ADDRESSES
;============================================================
RCC_BASE                EQU 0x40021000
GPIO_BASE               EQU 0x40010800
GPIOA_BASE              EQU 0x40010800
GPIOB_BASE              EQU 0x40010C00
GPIOC_BASE              EQU 0x40011000
GPIOD_BASE              EQU 0x40011400
GPIOE_BASE              EQU 0x40011800
USART1_BASE             EQU 0x40013800
USART2_BASE             EQU 0x40004400
USART3_BASE             EQU 0x40004800
SPI1_BASE               EQU 0x40013000
TIM1_BASE               EQU 0x40012C00
TIM2_BASE               EQU 0x40000000
TIM3_BASE               EQU 0x40000400
TIM4_BASE               EQU 0x40000800
ADC1_BASE               EQU 0x40012400
ADC2_BASE               EQU 0x40012800
AFIO_BASE               EQU 0x40010000
NVIC_BASE               EQU 0xE000E000
STK_BASE                EQU 0xE000E010
SCB_BASE                EQU 0xE000ED00
EXTI_BASE               EQU 0x40010400

;============================================================
; RCC REGISTERS
;============================================================
RCC_CR                  EQU (RCC_BASE + 0x00)
RCC_CFGR                EQU (RCC_BASE + 0x04)
RCC_CIR                 EQU (RCC_BASE + 0x08)
RCC_APB2RSTR            EQU (RCC_BASE + 0x0C)
RCC_APB1RSTR            EQU (RCC_BASE + 0x10)
RCC_AHBENR              EQU (RCC_BASE + 0x14)
RCC_APB2ENR             EQU (RCC_BASE + 0x18)
RCC_APB1ENR             EQU (RCC_BASE + 0x1C)
RCC_BDCR                EQU (RCC_BASE + 0x20)
RCC_CSR                 EQU (RCC_BASE + 0x24)

;============================================================
; AFIO REGISTERS
;============================================================
AFIO_EVCR               EQU (AFIO_BASE + 0x00)
AFIO_MAPR               EQU (AFIO_BASE + 0x04)
AFIO_EXTICR1            EQU (AFIO_BASE + 0x08)
AFIO_EXTICR2            EQU (AFIO_BASE + 0x0C)
AFIO_EXTICR3            EQU (AFIO_BASE + 0x10)
AFIO_EXTICR4            EQU (AFIO_BASE + 0x14)

;============================================================
; GPIOA REGISTERS
;============================================================
GPIOA_CRL               EQU (GPIOA_BASE + 0x00)
GPIOA_CRH               EQU (GPIOA_BASE + 0x04)
GPIOA_IDR               EQU (GPIOA_BASE + 0x08)
GPIOA_ODR               EQU (GPIOA_BASE + 0x0C)
GPIOA_BSRR              EQU (GPIOA_BASE + 0x10)
GPIOA_BRR               EQU (GPIOA_BASE + 0x14)
GPIOA_LCKR              EQU (GPIOA_BASE + 0x18)

;============================================================
; GPIOB REGISTERS
;============================================================
GPIOB_CRL               EQU (GPIOB_BASE + 0x00)
GPIOB_CRH               EQU (GPIOB_BASE + 0x04)
GPIOB_IDR               EQU (GPIOB_BASE + 0x08)
GPIOB_ODR               EQU (GPIOB_BASE + 0x0C)
GPIOB_BSRR              EQU (GPIOB_BASE + 0x10)
GPIOB_BRR               EQU (GPIOB_BASE + 0x14)
GPIOB_LCKR              EQU (GPIOB_BASE + 0x18)

;============================================================
; GPIOC REGISTERS
;============================================================
GPIOC_CRL               EQU (GPIOC_BASE + 0x00)
GPIOC_CRH               EQU (GPIOC_BASE + 0x04)
GPIOC_IDR               EQU (GPIOC_BASE + 0x08)
GPIOC_ODR               EQU (GPIOC_BASE + 0x0C)
GPIOC_BSRR              EQU (GPIOC_BASE + 0x10)
GPIOC_BRR               EQU (GPIOC_BASE + 0x14)
GPIOC_LCKR              EQU (GPIOC_BASE + 0x18)

;============================================================
; GPIOD REGISTERS
;============================================================
GPIOD_CRL               EQU (GPIOD_BASE + 0x00)
GPIOD_CRH               EQU (GPIOD_BASE + 0x04)
GPIOD_IDR               EQU (GPIOD_BASE + 0x08)
GPIOD_ODR               EQU (GPIOD_BASE + 0x0C)
GPIOD_BSRR              EQU (GPIOD_BASE + 0x10)
GPIOD_BRR               EQU (GPIOD_BASE + 0x14)
GPIOD_LCKR              EQU (GPIOD_BASE + 0x18)

;============================================================
; GPIOE REGISTERS
;============================================================
GPIOE_CRL               EQU (GPIOE_BASE + 0x00)
GPIOE_CRH               EQU (GPIOE_BASE + 0x04)
GPIOE_IDR               EQU (GPIOE_BASE + 0x08)
GPIOE_ODR               EQU (GPIOE_BASE + 0x0C)
GPIOE_BSRR              EQU (GPIOE_BASE + 0x10)
GPIOE_BRR               EQU (GPIOE_BASE + 0x14)
GPIOE_LCKR              EQU (GPIOE_BASE + 0x18)

;============================================================
; USART REGISTERS
;============================================================
USART1_SR               EQU (USART1_BASE + 0x00)
USART1_DR               EQU (USART1_BASE + 0x04)
USART1_BRR              EQU (USART1_BASE + 0x08)
USART1_CR1              EQU (USART1_BASE + 0x0C)
USART1_CR2              EQU (USART1_BASE + 0x10)
USART1_CR3              EQU (USART1_BASE + 0x14)
USART1_GTPR             EQU (USART1_BASE + 0x18)

USART2_SR               EQU (USART2_BASE + 0x00)
USART2_DR               EQU (USART2_BASE + 0x04)
USART2_BRR              EQU (USART2_BASE + 0x08)
USART2_CR1              EQU (USART2_BASE + 0x0C)
USART2_CR2              EQU (USART2_BASE + 0x10)
USART2_CR3              EQU (USART2_BASE + 0x14)
USART2_GTPR             EQU (USART2_BASE + 0x18)

USART3_SR               EQU (USART3_BASE + 0x00)
USART3_DR               EQU (USART3_BASE + 0x04)
USART3_BRR              EQU (USART3_BASE + 0x08)
USART3_CR1              EQU (USART3_BASE + 0x0C)
USART3_CR2              EQU (USART3_BASE + 0x10)
USART3_CR3              EQU (USART3_BASE + 0x14)
USART3_GTPR             EQU (USART3_BASE + 0x18)

;============================================================
; TIM2 REGISTERS
;============================================================
TIM2_CR1                EQU (TIM2_BASE + 0x00)
TIM2_CR2                EQU (TIM2_BASE + 0x04)
TIM2_SMCR               EQU (TIM2_BASE + 0x08)
TIM2_DIER               EQU (TIM2_BASE + 0x0C)
TIM2_SR                 EQU (TIM2_BASE + 0x10)
TIM2_EGR                EQU (TIM2_BASE + 0x14)
TIM2_CCMR1              EQU (TIM2_BASE + 0x18)
TIM2_CCMR2              EQU (TIM2_BASE + 0x1C)
TIM2_CCER               EQU (TIM2_BASE + 0x20)
TIM2_CNT                EQU (TIM2_BASE + 0x24)
TIM2_PSC                EQU (TIM2_BASE + 0x28)
TIM2_ARR                EQU (TIM2_BASE + 0x2C)
TIM2_CCR1               EQU (TIM2_BASE + 0x34)
TIM2_CCR2               EQU (TIM2_BASE + 0x38)
TIM2_CCR3               EQU (TIM2_BASE + 0x3C)
TIM2_CCR4               EQU (TIM2_BASE + 0x40)

;============================================================
; TIM3 REGISTERS
;============================================================
TIM3_CR1                EQU (TIM3_BASE + 0x00)
TIM3_CR2                EQU (TIM3_BASE + 0x04)
TIM3_SMCR               EQU (TIM3_BASE + 0x08)
TIM3_DIER               EQU (TIM3_BASE + 0x0C)
TIM3_SR                 EQU (TIM3_BASE + 0x10)
TIM3_EGR                EQU (TIM3_BASE + 0x14)
TIM3_CCMR1              EQU (TIM3_BASE + 0x18)
TIM3_CCMR2              EQU (TIM3_BASE + 0x1C)
TIM3_CCER               EQU (TIM3_BASE + 0x20)
TIM3_CNT                EQU (TIM3_BASE + 0x24)
TIM3_PSC                EQU (TIM3_BASE + 0x28)
TIM3_ARR                EQU (TIM3_BASE + 0x2C)
TIM3_CCR1               EQU (TIM3_BASE + 0x34)
TIM3_CCR2               EQU (TIM3_BASE + 0x38)
TIM3_CCR3               EQU (TIM3_BASE + 0x3C)
TIM3_CCR4               EQU (TIM3_BASE + 0x40)

;============================================================
; EXTI / NVIC / SYSTICK / SCB
;============================================================
EXTI_IMR                EQU (EXTI_BASE + 0x00)
EXTI_EMR                EQU (EXTI_BASE + 0x04)
EXTI_RTSR               EQU (EXTI_BASE + 0x08)
EXTI_FTSR               EQU (EXTI_BASE + 0x0C)
EXTI_SWIER              EQU (EXTI_BASE + 0x10)
EXTI_PR                 EQU (EXTI_BASE + 0x14)

NVIC_ISER0              EQU (NVIC_BASE + 0x100)
NVIC_ISER1              EQU (NVIC_BASE + 0x104)

STK_CTRL                EQU (STK_BASE + 0x00)
STK_LOAD                EQU (STK_BASE + 0x04)
STK_VAL                 EQU (STK_BASE + 0x08)
STK_CALIB               EQU (STK_BASE + 0x0C)

SCB_CPUID               EQU (SCB_BASE + 0x00)
SCB_ICSR                EQU (SCB_BASE + 0x04)
SCB_VTOR                EQU (SCB_BASE + 0x08)
SCB_AIRCR               EQU (SCB_BASE + 0x0C)
SCB_SCR                 EQU (SCB_BASE + 0x10)
SCB_CCR                 EQU (SCB_BASE + 0x14)

;============================================================
; COMMON BIT DEFINITIONS
;============================================================
RCC_APB2ENR_AFIOEN      EQU (1 :SHL: 0)
RCC_APB2ENR_GPIOA       EQU (1 :SHL: 2)
RCC_APB2ENR_GPIOB       EQU (1 :SHL: 3)
RCC_APB2ENR_GPIOC       EQU (1 :SHL: 4)

RCC_APB1ENR_TIM2        EQU (1 :SHL: 0)
RCC_APB1ENR_TIM3        EQU (1 :SHL: 1)

GPIOx_CRL               EQU 0x00
GPIOx_CRH               EQU 0x04
GPIOx_ODR               EQU 0x0C
GPIOx_BSRR              EQU 0x10

CS_PIN                  EQU (1 :SHL: 4)

STOPPED                 EQU 0
MOVING_UP               EQU 1
MOVING_DOWN             EQU 2

STK_CTRL_ENABLE         EQU (1 :SHL: 0)
STK_CTRL_TICKINT        EQU (1 :SHL: 1)
STK_CTRL_CLKSOURCE      EQU (1 :SHL: 2)

    END