( Embedded Systems - Sistemi Embedded - 17873)
( Some code for NUCLEO STM32F446RE )
( Daniele Peri, Università degli Studi di Palermo, 2017-2018 )

\ Timers 
\ Uses Nucleo64-STM32F446RE-HAL.f Nucleo64-STM32F446Re-OnBoardIO.f
\  

\ TIM2 Registers are described in
\ RM090 - en.DM00135183.pdf - pages 557-579

$40000000 CONSTANT TIM2
$04 REGS{
    REG CR1  REG CR2  REG SMCR   REG DIER   
    REG SR   REG EGR  REG CCMR1  REG CCMR2 
    REG CCER REG CNT  REG PSC    REG ARR
}REGS

$E000E100  CONSTANT NVIC   ( Base Address of NVIC )
$04 REGS{
    REG ISER0  ( Interrupt Set-Enable R 0, IRQ  0 - 31 ) 
    REG ISER1  ( Interrupt Set-Enable R 1, IRQ 32 - 63 ) 
    REG ISER2  ( Interrupt Set-Enable R 2, IRQ 64 - 80 ) 
}REGS

28 1BIT MASK NVIC ISER0 BIT SET  \ TIM2 triggers IRQ 28 which is enabled by
                                 \ bit 28 in NVIC ISER 0

: +IRQ   DIER $1 SWAP BIT SET ;
: -IRQ   DIER $1 SWAP BIT CLEAR ;
: STOP     ( timer -- ) CR1 $1 SWAP BIT CLEAR ;
: START    ( timer -- ) CR1 $1 SWAP BIT SET ;

0 1BIT MASK RCC APB1ENR bis! \ Enable TIM2 

16000 TIM2 PSC !  \ TIM2 Prescaler value 
3000  TIM2 ARR !  \ Auto-reload value

: TOGGLE		2DUP ON?  IF  OFF  ELSE  ON THEN ;
: ISR-TIM2      LED TOGGLE  0 1BIT MASK TIM2 SR bic! ;
' ISR-TIM2 IRQ-TIM2 !

\ Example: 
\ TIM2 +IRQ
\ TIM2 START
