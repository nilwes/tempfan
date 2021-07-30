
import gpio
import gpio.pwm as gpio
import serial.protocols.i2c as i2c
import drivers.bme280 as drivers

import bitmap show *
import font show *
import font.x11_100dpi.sans.sans_24_bold as sans_24_bold
import pixel_display.histogram show *
import pixel_display show *
import pixel_display.texture show *
import pixel_display.two_color show *

import gpio
import i2c
import ssd1306 show *
import pixel_display show *

main:
  //Set up I2C bus for BME280 sensor and OLED display
  scl := gpio.Pin 22
  sda := gpio.Pin 21
  bus := i2c.Bus
    --sda=sda
    --scl=scl

  devices := bus.scan
  if not devices.contains 0x3d: throw "No SSD1306 display found"
  if not devices.contains 0x77: throw "No BME280 sensor found"
  
  oled :=
    TwoColorPixelDisplay
      SSD1306 (bus.device 0x3d)
  thp_device := bus.device 0x77
  bme := drivers.Bme280 thp_device

  //Set up PWM pin
  pwm := gpio.Pwm
    --frequency=50
  chan1 := pwm.start
    gpio.Pin 19

  //Set up fan direction control pins
  in1 := gpio.Pin.out 16
  in2 := gpio.Pin.out 17
  
  //Set direction of fan
  in1.set 0
  in2.set 1

  //Parameters for mapping of temperature interval to duty factor 0-1
  input_start   := 25.0
  input_end     := 31.5
  output_start  := 0.0
  output_end    := 1.0

  //Parameters for mapping of temp to histogram range 2-50
  histo_input_start  := input_start
  histo_input_end    := input_end
  histo_output_start := 2.0
  histo_output_end   := 50.0
  histo_data := 0.0

  df   := 0.0
  temp := 0.0
  
  //Set up display and add a histogram plot
  oled.background = BLACK
  histo := TwoColorHistogram 7 7 121 50 oled.landscape 0.5 WHITE
  oled.add histo
  sans := Font.get "sans10"
  sans24b := Font [sans_24_bold.ASCII]
  sans_context := oled.context --landscape --font=sans --color=WHITE
  sans24b_context := sans_context.with --font=sans24b --alignment=TEXT_TEXTURE_ALIGN_RIGHT
  oled_text := (oled as any).text sans24b_context 105 25 "0.0" //"oled as any" is a hack
  
  while true:    
    bme.on
    temp = bme.read_temperature
    bme.off
    print "Temperature: $(%.1f temp) °C"
    oled_text.text = "$(%.1f temp) "
    
    //Map measured temperature to histogram range
    histo_data = (temp - histo_input_start) / (histo_input_end - histo_input_start) * (histo_output_end - histo_output_start) + histo_output_start
    histo.add histo_data
    
    //Map measuret temperature to duty factor 0-1
    df = (temp - input_start) / (input_end - input_start) * (output_end - output_start) + output_start
    if df < 0.16: //Lower duty factor than 0.16 does not start motor
      df = 0.0
    if df >= 1.0: //HACK: Duty factor of 1.0 does not work
      df = 0.99
    print "Duty Factor: $(df)"
    chan1.set_duty_factor df
    
    oled.draw

    sleep --ms=500
