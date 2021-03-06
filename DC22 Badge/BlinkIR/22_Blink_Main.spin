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

  LED8 = 23                                                     ' leds / vga
  LED7 = 22
  LED6 = 21
  LED5 = 20
  LED4 = 19
  LED3 = 18
  LED2 = 17
  LED1 = 16

  IRTX = 14                                                     ' ir led
  IRRX = 15                                                     ' ir demodulator


   'term
   #1, HOME, GOTOXY, #8, BKSP, TAB, LF, CLREOL, CLRDN, CR       ' PST formmatting control

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
                  
  
PUB Go 

  term.start(RX1, TX1, %0000, 115_200)                          ' start serial for temrinal                                      


  leds.start(8, LED1)                                         ' start drivers
  irout.start(IRTX, IR_FREQ)                                    ' start sircs tx

  pause(5)

  dira[LED8]~~

  'main loop
  repeat
    !outa[LED8]
    
    irout.tx(8, 12, 3)
    pause(500)


pri pause(ms) | t

'' Delay program in milliseconds
'' -- use only in full-speed mode 

  if (ms < 1)                                                   ' delay must be > 0
    return
  else
    t := cnt - 1792                                             ' sync with system counter
    repeat ms                                                   ' run delay
      waitcnt(t += MS_001)