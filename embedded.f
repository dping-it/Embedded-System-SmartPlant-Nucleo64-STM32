\ Embedded Systems - Sistemi Embedded - 17873 
\ HAL definition for NUCLEO STM32F446RE 
\ Davide Proietto, Università degli Studi di Palermo, 21-22 

\ GPIO register sets are mapped in memory 
\ starting from address $40020000
\ Each GPIO register set spans $0400 bytes 
\ See en.DM00135183.pdf page 55

: GPIO{  ( addr -- )  ;
: PORT   ( addr -- addr )  DUP CONSTANT $0400 + ;
: }GPIO  ( addr -- )  DROP ;

$40020000 
GPIO{  PORT GPIOA  PORT GPIOB  PORT GPIOC ( ... ) }GPIO
( More GPIO port definitions could be added... )

: REGS{  0  ;
: OFFSET>REGS  ( u -- ) NIP ;
: REG  <builds  DUP , OVER + DOES> @ + ; \ OVER (1 2 - 1 2 1) 
: }REGS  2DROP ;

$04 REGS{
	REG MODER  REG OTYPER  REG OSPEEDR
	REG PUPDR  REG IDR     REG ODR
	REG BSSR   REG LCKR    REG AFRL
	REG AFRH
}REGS

: DELAY  0 DO LOOP ;
: 1BIT   $1 1 ;
: 2BIT   $3 2 ;
: 4BIT   $F 4 ;
: MASK  ( index mask width -- offset_mask ) ROT * LSHIFT ; \ ROT ( 1 2 3 - 2 3 1)

\ 5 GPIOA MODE@ .
\ Shows current mode for pin 5 of GPIO Port A (controlling LED2)
\ 13 GPIOC MODE@ .
\ Shows current mode for pin 13 of GPIO Port C (connected to Button B1 USER)
\ 1 5 GPIOA MODE!
\ Sets Output mode (1) for pin 5 of GPIO Port A (LED2)
\ 5 GPIOA ODR PIN BIT SET
\ Sets pin 5 of GPIO Port A to high (LED2 turns ON)
\ TRUE 5 GPIOA OUT!
\ Sets pin 5 of GPIO Port A to high (LED2 turns ON)


: PIN   SWAP 1BIT MASK SWAP ;
: MODE   OVER 2BIT MASK SWAP ;
: MODE!   >R R@ MODE @ SWAP NOT AND ROT 3 AND ROT 2 * LSHIFT OR R> ! ; \ to R -> from R
\ : (MODE)   MODER OVER 2BIT MASK SWAP ;
\ : MODE@   (MODE) @ AND SWAP 2 * RSHIFT ;
\ : MODE!   >R R@ (MODE) @ SWAP NOT AND ROT $3 AND ROT 2 * LSHIFT OR R> ! ;
: (AF)  OVER 8 < IF AFRL ELSE AFRH SWAP 8 - SWAP THEN  OVER 4BIT MASK SWAP ;
: AF@   (AF) @ AND SWAP 4 * RSHIFT ;
: AF!   (AF) >R R@ @ SWAP NOT AND ROT $F AND ROT 4 * LSHIFT OR R> ! ;
: BIT  ( mask addr -- addr value mask )  DUP @ ROT ;
: SET  ( addr value mask -- )  OR SWAP ! ;
: CLEAR  ( addr value mask -- )  NOT AND SWAP ! ;
: TRUTH  ( addr value mask -- value )  AND 0<> NIP ; \ NIP (1 2 - 2)
: OUT@   ODR PIN BIT TRUTH ;
: OUT!   ODR PIN BIT SWAP OVER NOT AND >R ROT AND R> OR SWAP ! ;

: BUTTON   $2000 GPIOC IDR ; \ Same as 13 GPIOC IDR PIN 
: RELEASED  BIT TRUTH ;
: PRESSED   RELEASED NOT ;
: ?BUTTON   BUTTON PRESSED ;
: CLICKED   BEGIN 2DUP PRESSED UNTIL  BEGIN 2DUP RELEASED UNTIL 2DROP ;

: LED   $20 GPIOA ODR ;      \ Same as 5 GPIOA ODR PIN
: ON    ( mask addr -- ) BIT SET ;  
: OFF   ( mask addr -- ) BIT CLEAR ;  
: ON?   BIT TRUTH ;
: BLINK   2DUP  OFF  1000 DELAY  2DUP ON  1000 DELAY OFF ;

\ Examples:
\
\ LED ON
\ LED BLINK
\ 

( Test code: wait for button click then blink the LED, do it n times )
: TEST  ( n -- ) 0 DO  BUTTON CLICKED  LED BLINK  LOOP ;

\ Configuration: 
1 5 GPIOA MODE!

( Ten click test )
( 10 TEST )


\ TEMPORIZZAZIONI DA MILLISECONDI IN POI
: 1ms 3000 ;
: 1s  1ms 1000 *  ;
: 1m  1s 60 *  ; 
: 1h 1m 60 * ;

\ Definitions for a few Arduino pins on 
\ connectors CN5 and CN9:

: D0    3 GPIOA ;
: D2   10 GPIOA ; 
: D3    3 GPIOB ;
: D4    5 GPIOB ;
: D5    4 GPIOB ;
: D6   10 GPIOB ;
: D7    8 GPIOA ;
: D11   7 GPIOA ;
: D12   6 GPIOA ;
: D13   5 GPIOA ;
\ Examples:
\
\ TRUE D13 OUT!
\ Sets Arduino D13 pin (connector CN5) high
\ This is another way to turn the LD2 LED on.
\

$40023800 constant RCC
$04 REGS{
   $40 OFFSET>REGS
   REG APB1ENR   REG APB2ENR
}REGS

$40012000 constant ADC1
$04 REGS{
    REG SR    REG CR1   REG CR2
    REG SMPR1 REG SMPR2 REG JOFR1
    REG JOFR2 REG JOFR3 REG JOFR4
    REG HTR   REG LTR   REG SQR1
    REG SQR2  REG SQR3  REG JSQR
    REG JDR1  REG JDR2  REG JDR3
    REG JDR4  REG DR
}REGS
$04 REGS{
    $300 OFFSET>REGS
    REG CSR  REG CCR
}REGS

8  1BIT MASK CONSTANT ADC1EN    
0  1BIT MASK CONSTANT ADON      
1  1BIT MASK CONSTANT CONT      
20 4BIT MASK CONSTANT L         \ Regular channel sequence length
4  1BIT MASK CONSTANT STRT      
30 1BIT MASK CONSTANT SWSTART   

: ADC_INIT
    ADC1EN  RCC APB2ENR bis!    \ Abilito il clock dell'adc
    ADON  ADC1 CR2 bis!         \ Accendo l'ADC
    CONT  ADC1 CR2 bis!         \ Modalità di conversione continua
    0 ADC1 SMPR1 !              \ Numero di cicli di campionamento (0 == 3, 1 == 15)
    L  ADC1 SQR1 bic!           \ Canele di tipo regular group e numero di conversioni = 1
    0 ADC1 SQR3 !               \ Seleziono il canale di input
    3 0 GPIOA MODE!             \ Setto la porta GPIOA 0 in modalità Analogica (3)
;

: ADC_ON  ADON  ADC1 CR2 bis!  ;
: ADC_OFF  ADON  ADC1 CR2 bic!  ;

: START_CONVERSION              \ Inizia la conversione dei valori
    STRT ADC1 SR bis!           \ Regular Channel Start Flag
    SWSTART ADC1 CR2 bis!       
;
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
\ Connessioni per la modalità di collegamento parallela a 4 bit
: LCDE   D11 ;
: LCDRS  D12 ; 
: LCD7   D2 ;
: LCD6   D3 ;
: LCD5   D4 ;
: LCD4   D5 ;

\ Word per inizialiazzare LCD: setta in modalità OUTPUT i GPIO;
: LCD_SETUP
   1 LCD4 MODE!   1 LCD5 MODE!  1 LCD6 MODE!
   1 LCD7 MODE!  1 LCDRS MODE!  1 LCDE MODE!
;

: BTST AND 0<> ;

: LCDREG4H!
   DUP $80 BTST LCD7 OUT! DUP $40 BTST LCD6 OUT! 
   DUP $20 BTST LCD5 OUT!     $10 BTST LCD4 OUT! ;

: LCDREG4H@
   0 LCD7 OUT@ $80 AND OR  LCD6 OUT@ $40 AND OR
     LCD5 OUT@ $20 AND OR  LCD4 OUT@ $10 AND OR ;

: LCDRSH   -1 LCDRS OUT! ;
: LCDRSL    0 LCDRS OUT! ;
: LCDEH    -1 LCDE OUT! ;
: LCDEL     0 LCDE OUT! ;

: LCDWR4   LCDEL DUP $100 AND 0<> LCDRS OUT!  
   ( send upper 4 bits: ) DUP LCDEH  LCDREG4H!  LCDEL
   ( send lower 4 bits: ) LCDEH 4 LSHIFT  LCDREG4H!  LCDEL ;

\ Clear display
: CLEAR $1 LCDWR4 ;

\ Move cursor to the beginning of the second line
: >LINE2  $C0 LCDWR4 ;


: LCDEMIT   $100 OR LCDWR4 ;
: LCDTYPE   OVER + SWAP ?DO I C@ LCDEMIT LOOP ;
: LCDINIT   $20 LCDWR4 1s DELAY  $28 LCDWR4 1s DELAY $F LCDWR4 1s DELAY ;
: LCDMESSAGE_FROM_KEYBORAD   HERE 100 + DUP 16 ACCEPT LCDTYPE ; \ Here = address at the top of dictionary
: CLEAN_LCD  $1 lcdwr4 1s DELAY ;     \ Delay per dare il tempo di pulire il display
: NEWLINE   $C0 lcdwr4 ;

\ CODE FOR CUSTOM EMOTICON

: LCDINCRAM  $6 LCDWR4 ;
: LCDDECRAM  $4 LCDWR4 ;

: LCDCG-SET ( cgn -- )  8 * 7 + $3F AND $40 OR LCDWR4  ; 
: LCDCG8 LCDCG-SET LCDDECRAM 8 0 DO $1F AND $100 OR LCDWR4 LOOP LCDINCRAM ; 

: LCD_INIT
   LCD_SETUP
   LCDINIT 
   CLEAN_LCD

   \ EMPTY WATER FALL
   %00100
   %01010
   %10001
   %10001
   %10001
   %10001
   %01110
   %00000
   DECIMAL 0 LCDCG8

   \ WATER FALL
   %00100
   %01110
   %11111
   %11111
   %11111
   %11111
   %01110
   %00000
   DECIMAL 1 LCDCG8

   \ PLANT
   %01110
   %11111
   %01110
   %00100
   %00100
   %11111
   %01110
   %01110
   DECIMAL 2 LCDCG8

   $80 LCDWR4
;

: DRY 1 LCDEMIT 0 LCDEMIT 0 LCDEMIT 0 LCDEMIT 0 LCDEMIT ;
: WET 1 LCDEMIT 1 LCDEMIT 1 LCDEMIT 1 LCDEMIT 1 LCDEMIT ;
: PLANT 2 LCDEMIT ; 

: LCD_WELCOME
    s" X ATTIVARE PREMI" LCDTYPE 
    NEWLINE
    s" IL PULSANTE BLU" LCDTYPE
;

: NUMBER2LCD
    DUP 10 /  48 +  LCDEMIT
    DUP 10 mod  48 +  LCDEMIT
    37 LCDEMIT
;

: DRY_SOIL  
    s" ASCIUTTO   " LCDTYPE DRY
    NEWLINE
    s" LIV. ACQUA: " LCDTYPE  NUMBER2LCD
;

: PERFECT_SOIL 
    PLANT s" CONDIZIONI OK " LCDTYPE PLANT
    NEWLINE
    s" LIV. ACQUA: " LCDTYPE  NUMBER2LCD
;

: WET_SOIL 
    s" BAGNATO   " LCDTYPE WET
    NEWLINE
    s" LIV. ACQUA: " LCDTYPE  NUMBER2LCD
;

: MEAN  
    adc1 dr @  
    1000 1 DO adc1 dr @ + LOOP  
    1000 / 
;

: ?VALUE 
    START_CONVERSION 
    MEAN  
    99 *  4095 /
;

: ?MOISTURE
   CLEAN_LCD 
   DUP 80 > IF  WET_SOIL      ELSE
   DUP 40 > IF  PERFECT_SOIL  ELSE
                DRY_SOIL
   THEN THEN DROP
;

: INIT 
    LCD_INIT 
    LCD_WELCOME
    ADC_INIT
    BUTTON CLICKED 
    BEGIN  ADC_ON ?VALUE ADC_OFF ?MOISTURE 1m DELAY  AGAIN
;

INIT
