;============================================================
; STM32F103 register addresses only (DO NOT ADD VARIABLES HERE)
; Complete register definitions for STM32F103C8 microcontroller
;============================================================

;============================================================
; MEMORY MAP BASE ADDRESSES
;============================================================
RCC_BASE    EQU 0x40021000
GPIO_BASE   EQU 0x40010800
GPIOA_BASE  EQU 0x40010800
GPIOB_BASE  EQU 0x40010C00
GPIOC_BASE  EQU 0x40011000
GPIOD_BASE  EQU 0x40011400
GPIOE_BASE  EQU 0x40011800
USART1_BASE EQU 0x40013800
USART2_BASE EQU 0x40004400
USART3_BASE EQU 0x40004800
TIM1_BASE   EQU 0x40012C00
TIM2_BASE   EQU 0x40000000
TIM3_BASE   EQU 0x40000400
TIM4_BASE   EQU 0x40000800
ADC1_BASE   EQU 0x40012400
ADC2_BASE   EQU 0x40012800
AFIO_BASE   EQU 0x40010000
NVIC_BASE   EQU 0xE000E000
STK_BASE    EQU 0xE000E010

;============================================================
; RCC (Reset and Clock Control) REGISTERS
;============================================================
RCC_CR      EQU RCC_BASE + 0x00        ; Clock Control Register
RCC_CFGR    EQU RCC_BASE + 0x04        ; Clock Configuration Register
RCC_CIR     EQU RCC_BASE + 0x08        ; Clock Interrupt Register
RCC_APB2RSTR EQU RCC_BASE + 0x0C       ; APB2 Peripheral Reset Register
RCC_APB1RSTR EQU RCC_BASE + 0x10       ; APB1 Peripheral Reset Register
RCC_AHBENR  EQU RCC_BASE + 0x14        ; AHB Peripheral Clock Enable Register
RCC_APB2ENR EQU RCC_BASE + 0x18        ; APB2 Peripheral Clock Enable Register
RCC_APB1ENR EQU RCC_BASE + 0x1C        ; APB1 Peripheral Clock Enable Register
RCC_BDCR    EQU RCC_BASE + 0x20        ; Backup Domain Control Register
RCC_CSR     EQU RCC_BASE + 0x24        ; Control/Status Register

;============================================================
; AFIO (Alternate Function I/O) REGISTERS
;============================================================
AFIO_EVCR   EQU AFIO_BASE + 0x00       ; Event Control Register
AFIO_MAPR   EQU AFIO_BASE + 0x04       ; Remap and Debug I/O Configuration
AFIO_EXTICR1 EQU AFIO_BASE + 0x08      ; External Interrupt Configuration Register 1
AFIO_EXTICR2 EQU AFIO_BASE + 0x0C      ; External Interrupt Configuration Register 2
AFIO_EXTICR3 EQU AFIO_BASE + 0x10      ; External Interrupt Configuration Register 3
AFIO_EXTICR4 EQU AFIO_BASE + 0x14      ; External Interrupt Configuration Register 4

;============================================================
; GPIOA REGISTERS
;============================================================
GPIOA_CRL   EQU GPIOA_BASE + 0x00      ; Port A Configuration Register Low
GPIOA_CRH   EQU GPIOA_BASE + 0x04      ; Port A Configuration Register High
GPIOA_IDR   EQU GPIOA_BASE + 0x08      ; Port A Input Data Register
GPIOA_ODR   EQU GPIOA_BASE + 0x0C      ; Port A Output Data Register
GPIOA_BSRR  EQU GPIOA_BASE + 0x10      ; Port A Bit Set/Reset Register
GPIOA_BRR   EQU GPIOA_BASE + 0x14      ; Port A Bit Reset Register
GPIOA_LCKR  EQU GPIOA_BASE + 0x18      ; Port A Lock Register

;============================================================
; GPIOB REGISTERS
;============================================================
GPIOB_CRL   EQU GPIOB_BASE + 0x00      ; Port B Configuration Register Low
GPIOB_CRH   EQU GPIOB_BASE + 0x04      ; Port B Configuration Register High
GPIOB_IDR   EQU GPIOB_BASE + 0x08      ; Port B Input Data Register
GPIOB_ODR   EQU GPIOB_BASE + 0x0C      ; Port B Output Data Register
GPIOB_BSRR  EQU GPIOB_BASE + 0x10      ; Port B Bit Set/Reset Register
GPIOB_BRR   EQU GPIOB_BASE + 0x14      ; Port B Bit Reset Register
GPIOB_LCKR  EQU GPIOB_BASE + 0x18      ; Port B Lock Register

;============================================================
; GPIOC REGISTERS
;============================================================
GPIOC_CRL   EQU GPIOC_BASE + 0x00      ; Port C Configuration Register Low
GPIOC_CRH   EQU GPIOC_BASE + 0x04      ; Port C Configuration Register High
GPIOC_IDR   EQU GPIOC_BASE + 0x08      ; Port C Input Data Register
GPIOC_ODR   EQU GPIOC_BASE + 0x0C      ; Port C Output Data Register
GPIOC_BSRR  EQU GPIOC_BASE + 0x10      ; Port C Bit Set/Reset Register
GPIOC_BRR   EQU GPIOC_BASE + 0x14      ; Port C Bit Reset Register
GPIOC_LCKR  EQU GPIOC_BASE + 0x18      ; Port C Lock Register

;============================================================
; GPIOD REGISTERS
;============================================================
GPIOD_CRL   EQU GPIOD_BASE + 0x00      ; Port D Configuration Register Low
GPIOD_CRH   EQU GPIOD_BASE + 0x04      ; Port D Configuration Register High
GPIOD_IDR   EQU GPIOD_BASE + 0x08      ; Port D Input Data Register
GPIOD_ODR   EQU GPIOD_BASE + 0x0C      ; Port D Output Data Register
GPIOD_BSRR  EQU GPIOD_BASE + 0x10      ; Port D Bit Set/Reset Register
GPIOD_BRR   EQU GPIOD_BASE + 0x14      ; Port D Bit Reset Register
GPIOD_LCKR  EQU GPIOD_BASE + 0x18      ; Port D Lock Register

;============================================================
; GPIOE REGISTERS
;============================================================
GPIOE_CRL   EQU GPIOE_BASE + 0x00      ; Port E Configuration Register Low
GPIOE_CRH   EQU GPIOE_BASE + 0x04      ; Port E Configuration Register High
GPIOE_IDR   EQU GPIOE_BASE + 0x08      ; Port E Input Data Register
GPIOE_ODR   EQU GPIOE_BASE + 0x0C      ; Port E Output Data Register
GPIOE_BSRR  EQU GPIOE_BASE + 0x10      ; Port E Bit Set/Reset Register
GPIOE_BRR   EQU GPIOE_BASE + 0x14      ; Port E Bit Reset Register
GPIOE_LCKR  EQU GPIOE_BASE + 0x18      ; Port E Lock Register

;============================================================
; USART1 REGISTERS
;============================================================
USART1_SR   EQU USART1_BASE + 0x00     ; Status Register
USART1_DR   EQU USART1_BASE + 0x04     ; Data Register
USART1_BRR  EQU USART1_BASE + 0x08     ; Baud Rate Register
USART1_CR1  EQU USART1_BASE + 0x0C     ; Control Register 1
USART1_CR2  EQU USART1_BASE + 0x10     ; Control Register 2
USART1_CR3  EQU USART1_BASE + 0x14     ; Control Register 3
USART1_GTPR EQU USART1_BASE + 0x18     ; Guard Time and Prescaler Register

;============================================================
; USART2 REGISTERS
;============================================================
USART2_SR   EQU USART2_BASE + 0x00     ; Status Register
USART2_DR   EQU USART2_BASE + 0x04     ; Data Register
USART2_BRR  EQU USART2_BASE + 0x08     ; Baud Rate Register
USART2_CR1  EQU USART2_BASE + 0x0C     ; Control Register 1
USART2_CR2  EQU USART2_BASE + 0x10     ; Control Register 2
USART2_CR3  EQU USART2_BASE + 0x14     ; Control Register 3
USART2_GTPR EQU USART2_BASE + 0x18     ; Guard Time and Prescaler Register

;============================================================
; USART3 REGISTERS
;============================================================
USART3_SR   EQU USART3_BASE + 0x00     ; Status Register
USART3_DR   EQU USART3_BASE + 0x04     ; Data Register
USART3_BRR  EQU USART3_BASE + 0x08     ; Baud Rate Register
USART3_CR1  EQU USART3_BASE + 0x0C     ; Control Register 1
USART3_CR2  EQU USART3_BASE + 0x10     ; Control Register 2
USART3_CR3  EQU USART3_BASE + 0x14     ; Control Register 3
USART3_GTPR EQU USART3_BASE + 0x18     ; Guard Time and Prescaler Register

;============================================================
; TIM1 (Advanced Control Timer) REGISTERS
;============================================================
TIM1_CR1    EQU TIM1_BASE + 0x00       ; Control Register 1
TIM1_CR2    EQU TIM1_BASE + 0x04       ; Control Register 2
TIM1_SMCR   EQU TIM1_BASE + 0x08       ; Slave Mode Control Register
TIM1_DIER   EQU TIM1_BASE + 0x0C       ; DMA/Interrupt Enable Register
TIM1_SR     EQU TIM1_BASE + 0x10       ; Status Register
TIM1_EGR    EQU TIM1_BASE + 0x14       ; Event Generation Register
TIM1_CCMR1  EQU TIM1_BASE + 0x18       ; Capture/Compare Mode Register 1
TIM1_CCMR2  EQU TIM1_BASE + 0x1C       ; Capture/Compare Mode Register 2
TIM1_CCER   EQU TIM1_BASE + 0x20       ; Capture/Compare Enable Register
TIM1_CNT    EQU TIM1_BASE + 0x24       ; Counter Register
TIM1_PSC    EQU TIM1_BASE + 0x28       ; Prescaler Register
TIM1_ARR    EQU TIM1_BASE + 0x2C       ; Auto-Reload Register
TIM1_RCR    EQU TIM1_BASE + 0x30       ; Repetition Counter Register
TIM1_CCR1   EQU TIM1_BASE + 0x34       ; Capture/Compare Register 1
TIM1_CCR2   EQU TIM1_BASE + 0x38       ; Capture/Compare Register 2
TIM1_CCR3   EQU TIM1_BASE + 0x3C       ; Capture/Compare Register 3
TIM1_CCR4   EQU TIM1_BASE + 0x40       ; Capture/Compare Register 4
TIM1_BDTR   EQU TIM1_BASE + 0x44       ; Break and Dead Time Register
TIM1_DCR    EQU TIM1_BASE + 0x48       ; DMA Control Register
TIM1_DMAR   EQU TIM1_BASE + 0x4C       ; DMA Address for Full Transfer Register

;============================================================
; TIM2 (General Purpose Timer) REGISTERS
;============================================================
TIM2_CR1    EQU TIM2_BASE + 0x00       ; Control Register 1
TIM2_CR2    EQU TIM2_BASE + 0x04       ; Control Register 2
TIM2_SMCR   EQU TIM2_BASE + 0x08       ; Slave Mode Control Register
TIM2_DIER   EQU TIM2_BASE + 0x0C       ; DMA/Interrupt Enable Register
TIM2_SR     EQU TIM2_BASE + 0x10       ; Status Register
TIM2_EGR    EQU TIM2_BASE + 0x14       ; Event Generation Register
TIM2_CCMR1  EQU TIM2_BASE + 0x18       ; Capture/Compare Mode Register 1
TIM2_CCMR2  EQU TIM2_BASE + 0x1C       ; Capture/Compare Mode Register 2
TIM2_CCER   EQU TIM2_BASE + 0x20       ; Capture/Compare Enable Register
TIM2_CNT    EQU TIM2_BASE + 0x24       ; Counter Register
TIM2_PSC    EQU TIM2_BASE + 0x28       ; Prescaler Register
TIM2_ARR    EQU TIM2_BASE + 0x2C       ; Auto-Reload Register
TIM2_CCR1   EQU TIM2_BASE + 0x34       ; Capture/Compare Register 1
TIM2_CCR2   EQU TIM2_BASE + 0x38       ; Capture/Compare Register 2
TIM2_CCR3   EQU TIM2_BASE + 0x3C       ; Capture/Compare Register 3
TIM2_CCR4   EQU TIM2_BASE + 0x40       ; Capture/Compare Register 4
TIM2_DCR    EQU TIM2_BASE + 0x48       ; DMA Control Register
TIM2_DMAR   EQU TIM2_BASE + 0x4C       ; DMA Address for Full Transfer Register

;============================================================
; TIM3 (General Purpose Timer) REGISTERS
;============================================================
TIM3_CR1    EQU TIM3_BASE + 0x00       ; Control Register 1
TIM3_CR2    EQU TIM3_BASE + 0x04       ; Control Register 2
TIM3_SMCR   EQU TIM3_BASE + 0x08       ; Slave Mode Control Register
TIM3_DIER   EQU TIM3_BASE + 0x0C       ; DMA/Interrupt Enable Register
TIM3_SR     EQU TIM3_BASE + 0x10       ; Status Register
TIM3_EGR    EQU TIM3_BASE + 0x14       ; Event Generation Register
TIM3_CCMR1  EQU TIM3_BASE + 0x18       ; Capture/Compare Mode Register 1
TIM3_CCMR2  EQU TIM3_BASE + 0x1C       ; Capture/Compare Mode Register 2
TIM3_CCER   EQU TIM3_BASE + 0x20       ; Capture/Compare Enable Register
TIM3_CNT    EQU TIM3_BASE + 0x24       ; Counter Register
TIM3_PSC    EQU TIM3_BASE + 0x28       ; Prescaler Register
TIM3_ARR    EQU TIM3_BASE + 0x2C       ; Auto-Reload Register
TIM3_CCR1   EQU TIM3_BASE + 0x34       ; Capture/Compare Register 1
TIM3_CCR2   EQU TIM3_BASE + 0x38       ; Capture/Compare Register 2
TIM3_CCR3   EQU TIM3_BASE + 0x3C       ; Capture/Compare Register 3
TIM3_CCR4   EQU TIM3_BASE + 0x40       ; Capture/Compare Register 4
TIM3_DCR    EQU TIM3_BASE + 0x48       ; DMA Control Register
TIM3_DMAR   EQU TIM3_BASE + 0x4C       ; DMA Address for Full Transfer Register

;============================================================
; TIM4 (General Purpose Timer) REGISTERS
;============================================================
TIM4_CR1    EQU TIM4_BASE + 0x00       ; Control Register 1
TIM4_CR2    EQU TIM4_BASE + 0x04       ; Control Register 2
TIM4_SMCR   EQU TIM4_BASE + 0x08       ; Slave Mode Control Register
TIM4_DIER   EQU TIM4_BASE + 0x0C       ; DMA/Interrupt Enable Register
TIM4_SR     EQU TIM4_BASE + 0x10       ; Status Register
TIM4_EGR    EQU TIM4_BASE + 0x14       ; Event Generation Register
TIM4_CCMR1  EQU TIM4_BASE + 0x18       ; Capture/Compare Mode Register 1
TIM4_CCMR2  EQU TIM4_BASE + 0x1C       ; Capture/Compare Mode Register 2
TIM4_CCER   EQU TIM4_BASE + 0x20       ; Capture/Compare Enable Register
TIM4_CNT    EQU TIM4_BASE + 0x24       ; Counter Register
TIM4_PSC    EQU TIM4_BASE + 0x28       ; Prescaler Register
TIM4_ARR    EQU TIM4_BASE + 0x2C       ; Auto-Reload Register
TIM4_CCR1   EQU TIM4_BASE + 0x34       ; Capture/Compare Register 1
TIM4_CCR2   EQU TIM4_BASE + 0x38       ; Capture/Compare Register 2
TIM4_CCR3   EQU TIM4_BASE + 0x3C       ; Capture/Compare Register 3
TIM4_CCR4   EQU TIM4_BASE + 0x40       ; Capture/Compare Register 4
TIM4_DCR    EQU TIM4_BASE + 0x48       ; DMA Control Register
TIM4_DMAR   EQU TIM4_BASE + 0x4C       ; DMA Address for Full Transfer Register

;============================================================
; ADC1 REGISTERS
;============================================================
ADC1_SR     EQU ADC1_BASE + 0x00       ; Status Register
ADC1_CR1    EQU ADC1_BASE + 0x04       ; Control Register 1
ADC1_CR2    EQU ADC1_BASE + 0x08       ; Control Register 2
ADC1_SMPR1  EQU ADC1_BASE + 0x0C       ; Sample Time Register 1
ADC1_SMPR2  EQU ADC1_BASE + 0x10       ; Sample Time Register 2
ADC1_JOFR1  EQU ADC1_BASE + 0x14       ; Injected Channel Data Offset Register 1
ADC1_JOFR2  EQU ADC1_BASE + 0x18       ; Injected Channel Data Offset Register 2
ADC1_JOFR3  EQU ADC1_BASE + 0x1C       ; Injected Channel Data Offset Register 3
ADC1_JOFR4  EQU ADC1_BASE + 0x20       ; Injected Channel Data Offset Register 4
ADC1_HTR    EQU ADC1_BASE + 0x24       ; High Threshold Register
ADC1_LTR    EQU ADC1_BASE + 0x28       ; Low Threshold Register
ADC1_SQR1   EQU ADC1_BASE + 0x2C       ; Regular Channel Sequence Register 1
ADC1_SQR2   EQU ADC1_BASE + 0x30       ; Regular Channel Sequence Register 2
ADC1_SQR3   EQU ADC1_BASE + 0x34       ; Regular Channel Sequence Register 3
ADC1_JSQR   EQU ADC1_BASE + 0x38       ; Injected Channel Sequence Register
ADC1_JDR1   EQU ADC1_BASE + 0x3C       ; Injected Channel Data Register 1
ADC1_JDR2   EQU ADC1_BASE + 0x40       ; Injected Channel Data Register 2
ADC1_JDR3   EQU ADC1_BASE + 0x44       ; Injected Channel Data Register 3
ADC1_JDR4   EQU ADC1_BASE + 0x48       ; Injected Channel Data Register 4
ADC1_DR     EQU ADC1_BASE + 0x4C       ; Regular Channel Data Register

;============================================================
; ADC2 REGISTERS
;============================================================
ADC2_SR     EQU ADC2_BASE + 0x00       ; Status Register
ADC2_CR1    EQU ADC2_BASE + 0x04       ; Control Register 1
ADC2_CR2    EQU ADC2_BASE + 0x08       ; Control Register 2
ADC2_SMPR1  EQU ADC2_BASE + 0x0C       ; Sample Time Register 1
ADC2_SMPR2  EQU ADC2_BASE + 0x10       ; Sample Time Register 2
ADC2_JOFR1  EQU ADC2_BASE + 0x14       ; Injected Channel Data Offset Register 1
ADC2_JOFR2  EQU ADC2_BASE + 0x18       ; Injected Channel Data Offset Register 2
ADC2_JOFR3  EQU ADC2_BASE + 0x1C       ; Injected Channel Data Offset Register 3
ADC2_JOFR4  EQU ADC2_BASE + 0x20       ; Injected Channel Data Offset Register 4
ADC2_HTR    EQU ADC2_BASE + 0x24       ; High Threshold Register
ADC2_LTR    EQU ADC2_BASE + 0x28       ; Low Threshold Register
ADC2_SQR1   EQU ADC2_BASE + 0x2C       ; Regular Channel Sequence Register 1
ADC2_SQR2   EQU ADC2_BASE + 0x30       ; Regular Channel Sequence Register 2
ADC2_SQR3   EQU ADC2_BASE + 0x34       ; Regular Channel Sequence Register 3
ADC2_JSQR   EQU ADC2_BASE + 0x38       ; Injected Channel Sequence Register
ADC2_JDR1   EQU ADC2_BASE + 0x3C       ; Injected Channel Data Register 1
ADC2_JDR2   EQU ADC2_BASE + 0x40       ; Injected Channel Data Register 2
ADC2_JDR3   EQU ADC2_BASE + 0x44       ; Injected Channel Data Register 3
ADC2_JDR4   EQU ADC2_BASE + 0x48       ; Injected Channel Data Register 4
ADC2_DR     EQU ADC2_BASE + 0x4C       ; Regular Channel Data Register

;============================================================
; SysTick Timer REGISTERS
;============================================================
STK_CTRL    EQU STK_BASE + 0x00        ; Control and Status Register
STK_LOAD    EQU STK_BASE + 0x04        ; Reload Value Register
STK_VAL     EQU STK_BASE + 0x08        ; Current Value Register
STK_CALIB   EQU STK_BASE + 0x0C        ; Calibration Value Register

;============================================================
; NVIC (Nested Vectored Interrupt Controller) REGISTERS
;============================================================
NVIC_ISER0  EQU NVIC_BASE + 0x00       ; Interrupt Set-Enable Register 0
NVIC_ISER1  EQU NVIC_BASE + 0x04       ; Interrupt Set-Enable Register 1
NVIC_ICER0  EQU NVIC_BASE + 0x80       ; Interrupt Clear-Enable Register 0
NVIC_ICER1  EQU NVIC_BASE + 0x84       ; Interrupt Clear-Enable Register 1
NVIC_ISPR0  EQU NVIC_BASE + 0x100      ; Interrupt Set-Pending Register 0
NVIC_ISPR1  EQU NVIC_BASE + 0x104      ; Interrupt Set-Pending Register 1
NVIC_ICPR0  EQU NVIC_BASE + 0x180      ; Interrupt Clear-Pending Register 0
NVIC_ICPR1  EQU NVIC_BASE + 0x184      ; Interrupt Clear-Pending Register 1
NVIC_IABR0  EQU NVIC_BASE + 0x200      ; Interrupt Active Bit Register 0
NVIC_IABR1  EQU NVIC_BASE + 0x204      ; Interrupt Active Bit Register 1
NVIC_IPR0   EQU NVIC_BASE + 0x300      ; Interrupt Priority Register 0
NVIC_IPR1   EQU NVIC_BASE + 0x304      ; Interrupt Priority Register 1
NVIC_IPR2   EQU NVIC_BASE + 0x308      ; Interrupt Priority Register 2
NVIC_IPR3   EQU NVIC_BASE + 0x30C      ; Interrupt Priority Register 3
NVIC_IPR4   EQU NVIC_BASE + 0x310      ; Interrupt Priority Register 4
NVIC_IPR5   EQU NVIC_BASE + 0x314      ; Interrupt Priority Register 5
NVIC_IPR6   EQU NVIC_BASE + 0x318      ; Interrupt Priority Register 6
NVIC_IPR7   EQU NVIC_BASE + 0x31C      ; Interrupt Priority Register 7

;============================================================
; SCB (System Control Block) REGISTERS
;============================================================
SCB_BASE    EQU 0xE000ED00
SCB_ACTLR   EQU SCB_BASE + 0x08        ; Auxiliary Control Register
SCB_CPUID   EQU SCB_BASE + 0x00        ; CPUID Base Register
SCB_ICSR    EQU SCB_BASE + 0x04        ; Interrupt Control and State Register
SCB_VTOR    EQU SCB_BASE + 0x08        ; Vector Table Offset Register
SCB_AIRCR   EQU SCB_BASE + 0x0C        ; Application Interrupt and Reset Control Register
SCB_SCR     EQU SCB_BASE + 0x10        ; System Control Register
SCB_CCR     EQU SCB_BASE + 0x14        ; Configuration and Control Register
SCB_SHPR1   EQU SCB_BASE + 0x18        ; System Handler Priority Register 1
SCB_SHPR2   EQU SCB_BASE + 0x1C        ; System Handler Priority Register 2
SCB_SHPR3   EQU SCB_BASE + 0x20        ; System Handler Priority Register 3
SCB_SHCSR   EQU SCB_BASE + 0x24        ; System Handler Control and State Register
SCB_CFSR    EQU SCB_BASE + 0x28        ; Configurable Fault Status Register
SCB_HFSR    EQU SCB_BASE + 0x2C        ; Hard Fault Status Register
SCB_MMAR    EQU SCB_BASE + 0x34        ; Memory Manage Fault Address Register

;============================================================
; EXTI (External Interrupt/Event Controller) REGISTERS
;============================================================
EXTI_BASE   EQU 0x40010400
EXTI_IMR    EQU EXTI_BASE + 0x00       ; Interrupt Mask Register
EXTI_EMR    EQU EXTI_BASE + 0x04       ; Event Mask Register
EXTI_RTSR   EQU EXTI_BASE + 0x08       ; Rising Trigger Selection Register
EXTI_FTSR   EQU EXTI_BASE + 0x0C       ; Falling Trigger Selection Register
EXTI_SWIER  EQU EXTI_BASE + 0x10       ; Software Interrupt Event Register
EXTI_PR     EQU EXTI_BASE + 0x14       ; Pending Register

;============================================================
; COMMON BIT DEFINITIONS (useful constants)
;============================================================
; RCC_APB2ENR clock enable bits
RCC_APB2ENR_AFIOEN EQU (1 << 0)        ; Alternate Function I/O clock enable
RCC_APB2ENR_GPIOA  EQU (1 << 2)        ; GPIO Port A clock enable
RCC_APB2ENR_GPIOB  EQU (1 << 3)        ; GPIO Port B clock enable
RCC_APB2ENR_GPIOC  EQU (1 << 4)        ; GPIO Port C clock enable
RCC_APB2ENR_GPIOD  EQU (1 << 5)        ; GPIO Port D clock enable
RCC_APB2ENR_GPIOE  EQU (1 << 6)        ; GPIO Port E clock enable
RCC_APB2ENR_USART1 EQU (1 << 14)       ; USART1 clock enable
RCC_APB2ENR_ADC1   EQU (1 << 9)        ; ADC1 clock enable
RCC_APB2ENR_TIM1   EQU (1 << 11)       ; TIM1 clock enable

; RCC_APB1ENR clock enable bits
RCC_APB1ENR_TIM2   EQU (1 << 0)        ; TIM2 clock enable
RCC_APB1ENR_TIM3   EQU (1 << 1)        ; TIM3 clock enable
RCC_APB1ENR_TIM4   EQU (1 << 2)        ; TIM4 clock enable
RCC_APB1ENR_USART2 EQU (1 << 17)       ; USART2 clock enable
RCC_APB1ENR_USART3 EQU (1 << 18)       ; USART3 clock enable

; GPIO Configuration Register bit patterns
GPIO_MODE_INPUT    EQU 0x0             ; Input mode
GPIO_MODE_OUTPUT_10 EQU 0x1            ; Output mode, max speed 10 MHz
GPIO_MODE_OUTPUT_2  EQU 0x2            ; Output mode, max speed 2 MHz
GPIO_MODE_OUTPUT_50 EQU 0x3            ; Output mode, max speed 50 MHz

GPIO_CNF_ANALOG    EQU (0x0 << 2)      ; Analog input
GPIO_CNF_FLOATING  EQU (0x1 << 2)      ; Floating input
GPIO_CNF_PULL      EQU (0x2 << 2)      ; Input with pull-up/pull-down
GPIO_CNF_PUSHPULL  EQU (0x0 << 2)      ; General purpose output push-pull
GPIO_CNF_OPENDRAIN EQU (0x1 << 2)      ; General purpose output open-drain
GPIO_CNF_ALTPUSH   EQU (0x2 << 2)      ; Alternate function output push-pull
GPIO_CNF_ALTOPEN   EQU (0x3 << 2)      ; Alternate function output open-drain

; SysTick control bits
STK_CTRL_ENABLE    EQU (1 << 0)        ; Enable SysTick
STK_CTRL_TICKINT   EQU (1 << 1)        ; SysTick Interrupt Enable
STK_CTRL_CLKSOURCE EQU (1 << 2)        ; Clock source (0=external, 1=processor)

    END