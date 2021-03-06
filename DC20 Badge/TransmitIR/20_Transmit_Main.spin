'Modified from DEFCON 2012 Badge Example

  
CON

  'Propeller clock mode declarations
  _xinfreq = 5_000_000          'Timing crystal frequency, in Hz
  _clkmode = xtal1 + pll16x     'Use crystal type 1, with the 16x PLL to wind the clock up to 80 MHz


  CLK_FREQ = ((_clkmode - xtal1) >> 6) * _xinfreq
  MS_001   = CLK_FREQ / 1_000
  US_001   = CLK_FREQ / 1_000_000


  'Propeller pin constant definitions.  Works with any Defcon 20 board.

  RX1  = 31                                                     ' programming / terminal
  TX1  = 30

  VGA_BASE_PIN  = 16
  
  MOUSE_DATA_PIN     = 24
  MOUSE_CLOCK_PIN    = 25
  KEYBOARD_DATA_PIN  = 26 
  KEYBOARD_CLOCK_PIN = 27

  LED8 = 23                                                     ' leds / vga
  LED7 = 22
  LED6 = 21
  LED5 = 20
  LED4 = 19
  LED3 = 18
  LED2 = 17
  LED1 = 16

  IRTX = 13                                                     ' ir led
  IRRX = 12                                                     ' ir demodulator


  'IR
  IR_FREQ    = 40_000                                           ' modify to reduce power

  RX_DELAY   = 15_000                                           ' IR hold-off delays
  TX_DELAY   = 30_000 


OBJ

  'object declarations
    term  : "fullduplexserial64"                                  ' serial io         *
    leds  : "jm_pwm8"                                             ' led modulation
    irout : "jm_sircs_tx"                                         ' sircs output      *

' * = consumes cog
                  
  
PUB Go  | code 

  term.start(RX1, TX1, %0000, 115_200)                          ' start serial for temrinal                                      


  leds.start(8, LED1)                                         ' start drivers
  irout.start(IRTX, IR_FREQ)                                  ' start sircs tx

  pause(5)

  'set LED pins to output
  dira[LED1..LED8]~~
  code := 1

  'main loop
  repeat
    if(code==1) 
      outa[LED1] := 1
      outa[LED8] := 0
    else
      !outa[LED1+code-1]
      !outa[LED1+code-2]
    irout.tx(code, 8, 3)
    pause(250)
    irout.tx(code, 8, 3)
    pause(250)
    
    code++
    if(code == 9)
      code := 1


PRI pause(ms) | t

'' Delay program in milliseconds
'' -- use only in full-speed mode 

  if (ms < 1)                                                   ' delay must be > 0
    return
  else
    t := cnt - 1792                                             ' sync with system counter
    repeat ms                                                   ' run delay
      waitcnt(t += MS_001)