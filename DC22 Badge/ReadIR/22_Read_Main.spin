'Modified from DEFCON 2012 Badge Example

  
CON

  'Propeller clock mode declarations
  _xinfreq = 5_000_000          'Timing crystal frequency, in Hz
  _clkmode = xtal1 + pll16x     'Use crystal type 1, with the 16x PLL to wind the clock up to 80 MHz


  CLK_FREQ = ((_clkmode - xtal1) >> 6) * _xinfreq
  MS_001   = CLK_FREQ / 1_000
  US_001   = CLK_FREQ / 1_000_000


  'Propeller pin constant definitions.  

  RX1  = 31                                                     ' programming / terminal
  TX1  = 30

  LED8 = 23                                                 
  LED7 = 22
  LED6 = 21
  LED5 = 20
  LED4 = 19
  LED3 = 18
  LED2 = 17
  LED1 = 16

  IRTX = 14                                                     ' ir led
  IRRX = 15                                                     ' ir demodulator


  'IR
  IR_FREQ    = 40_000                                           ' modify to reduce power

  RX_DELAY   = 15_000                                           ' IR hold-off delays
  TX_DELAY   = 30_000 

  #1, HOME, GOTOXY, #8, BKSP, TAB, LF, CLREOL, CLRDN, CR

OBJ

  'object declarations
    term  : "fullduplexserial64"                                  ' serial io         *
    leds  : "jm_pwm8"                                             ' led modulation
    irin : "jm_sircs_rx"                                         ' sircs input      *

' * = consumes cog
                  
  
PUB Go  | ircode 
  term.start(RX1, TX1, %0000, 115_200)                          ' start serial for temrinal                                      
  leds.start(8, LED1)                                         ' start drivers
  irin.start(IRRX)                                  ' start sircs tx

  pause(5)

  'set LED pins to output
  dira[LED1..LED8]~~

  'main loop
  repeat
    outa[LED1..LED8] := 0
    ircode := irin.rx
    term.bin(ircode, irin.bit_count)
    term.tx(CR)
    term.dec(ircode)
    term.tx(CR)
    if(ircode > 0 AND ircode < 9)
      outa[LED1+ircode-1] := 1
      pause(500)  


PRI pause(ms) | t

'' Delay program in milliseconds
'' -- use only in full-speed mode 

  if (ms < 1)                                                   ' delay must be > 0
    return
  else
    t := cnt - 1792                                             ' sync with system counter
    repeat ms                                                   ' run delay
      waitcnt(t += MS_001)