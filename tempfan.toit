
import gpio
import gpio.pwm
import serial.protocols.i2c as i2c
import drivers.bme280

import bitmap show *
import font show *
import font.x11_100dpi.sans.sans_24_bold as sans_24_bold
import pixel_display.histogram show *
import pixel_display show *
import pixel_display.texture show *
import pixel_display.two_color show *

import .get_display

main:
  //set up I2C bus
  bus := i2c.Bus
    --sda=gpio.Pin.out 21
    --scl=gpio.Pin.out 22
  device := bus.device 0x77
  bme    := drivers.Bme280 device
  //set up PWM
  pwm := gpio.Pwm
    --frequency=50
  chan1 := pwm.start
    gpio.Pin 19
  //set up fan direction control pins
  in1 := gpio.Pin.out 16
  in2 := gpio.Pin.out 17
  //Set direction of fan
  in1.set 0
  in2.set 1

  //Mapping of temp interval to duty factor 0-1
  input_start   := 26.0
  input_end     := 29.0
  output_start  := 0.0
  output_end    := 1.0

  df   := 0.0
  temp := 0.0
  
  //Set up display
  oled := get_display
  oled.background = BLACK
  histo := TwoColorHistogram 7 7 45 50 oled.landscape 0.5 WHITE
  oled.add histo

  sans := Font.get "sans10"
  sans24b := Font [sans_24_bold.ASCII]
  sans_context := oled.context --landscape --font=sans --color=WHITE
  sans24b_context := sans_context.with --font=sans24b --alignment=TEXT_TEXTURE_ALIGN_RIGHT

  fps := (oled as any).text sans24b_context 105 25 "30.0"
  
  while true:    
    bme.on
    temp = bme.read_temperature
    bme.off
    print "Temperature: $(%.1f temp) °C"
    fps.text = "$(%.1f temp) "
    histo.add temp
    df = (temp - input_start) / (input_end - input_start) * (output_end - output_start) + output_start
    if df < 0.16: //Lower duty factor than 0.16 does not start motor
      df = 0.0
    if df >= 1.0:
      df = 0.99
    print "Duty Factor: $(df)"
    chan1.set_duty_factor df
    oled.draw

    sleep --ms=1000