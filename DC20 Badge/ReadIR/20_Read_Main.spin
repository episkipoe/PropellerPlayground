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


   'term
   #1, HOME, GOTOXY, #8, BKSP, TAB, LF, CLREOL, CLRDN, CR       ' PST formmatting control

  'IR
  IR_FREQ    = 40_000                                           ' modify to reduce power

  RX_DELAY   = 15_000                                           ' IR hold-off delays
  TX_DELAY   = 30_000 


  'screen character size definitions
  COLS = vga#COLS               'value is actually defined in the 
  ROWS = vga#ROWS               'VGA_Text_Defcon object's constant section

  'bitwise map for the mouse buttons
  MOUSE_LEFT    = 1<<0
  MOUSE_RIGHT   = 1<<1
  MOUSE_CENTER  = 1<<2
  MOUSE_L_SIDE  = 1<<3
  MOUSE_R_SIDE  = 1<<4

  'constant definitions for VGA screen manipulation functionality
  VGA_CLS       = $00           'clear screen
  VGA_HOME      = $01           'home
  VGA_BACKSPACE = $08           'backspace
  VGA_TAB       = $09           'tab (8 spaces per)
  VGA_SET_X     = $0A           'set X position (X follows)
  VGA_SET_Y     = $0B           'set Y position (Y follows)
  VGA_SET_COLOR = $0C           'set color (color follows)
  VGA_CR        = $0D           'carriage return



OBJ

  'object declarations
    term  : "fullduplexserial64"                                  ' serial io         *
  VGA     : "VGA_Text_Defcon.spin"
  Mouse   : "Mouse.spin"
  Keyboard: "Keyboard.spin"
    leds  : "jm_pwm8"                                             ' led modulation
    irin  : "jm_sircs_rx"                                         ' sircs input       *  
    irout : "jm_sircs_tx"                                         ' sircs output      *

' * = consumes cog
                  
VAR

  long xPos           'raw X value for the mouse
  long yPos           'raw Y value for the mouse
  long zPos           'raw Z value for the mouse wheel
  byte mouse_buttons  'bitwise variable, holds which mouse buttons are pressed
  
  long cursorX        'scale and limited mouse cursor position
  long cursorY

  long keyVal         'variable to hold the last keyboard keypress value
  
PUB Go | i, oldChar, oldX, oldY

  'Start drivers for the various software peripherals in this application.

  VGA.Start(VGA_BASE_PIN)

  Mouse.Start(MOUSE_DATA_PIN, MOUSE_CLOCK_PIN)
  Mouse.Bound_limits(0, 0, 0, cols - 1, rows - 2, 0)    'set cursor limits
  Mouse.Bound_scales(15, -15, 0)                        'scale the raw values to make mouse actions smoother
  
  Keyboard.Start(KEYBOARD_DATA_PIN, KEYBOARD_CLOCK_PIN)

  term.start(RX1, TX1, %0000, 115_200)                          ' start serial for temrinal                                      


  'initialize the oldChar and cursor values
  cursorX := cursorY := 0
  oldChar := VGA.GetChar(cursorX, cursorY)

  leds.start(8, LED1)                                         ' start drivers
  irin.start(IRRX)                                              ' start sircs rx
  irout.start(IRTX, IR_FREQ)                                    ' start sircs tx

  pause(5)

  dira[LED8]~~

  irin.enable    
  'main loop
  repeat
    '!outa[LED8]
    
    'Print the static text to the screen
    VGA.Out(0)
    VGA.Str(string("Waiting for signal",13))
    '0irout.tx(8, 12, 3) 
    readCode


pri pause(ms) | t

'' Delay program in milliseconds
'' -- use only in full-speed mode 

  if (ms < 1)                                                   ' delay must be > 0
    return
  else
    t := cnt - 1792                                             ' sync with system counter
    repeat ms                                                   ' run delay
      waitcnt(t += MS_001)

pri readCode | ircode
    ircode := irin.rx
    if(ircode => 0)
      term.str(string("Read "))
      printBin(ircode, irin.bit_count)
      term.str(string(CR)) 
      VGA.Out(0)
      VGA.Str(string("IR: ",13)) 
      VGA.Bin(ircode, irin.bit_count)
      VGA.Str(string("Bits: ",13))
      VGA.Dec(irin.bit_count)
      irin.disable
      pause(1000)

pri printHex(value, digits)
  value <<= (8 - digits) << 2
  repeat digits
    term.str(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))

pri printBin(value, digits)

'' Print a binary number

  value <<= 32 - digits
  repeat digits
    term.str((value <-= 1) & 1 + "0")

