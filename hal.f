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
