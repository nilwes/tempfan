# Temperature-controlled fan
This is a temperature-controlled fan with OLED display, built with Toit. The sensor is the Bosch BME280. The OLED is based on the 1306 OLED driver.

## Prerequisites
You need to install two packages. One for the BME280 driver, and one for the OLED display driver. Use the following Toit commands:
```
toit pkg install github.com/toitware/bme280-driver
toit pkg install github.com/toitware/toit-ssd1306
```

## Fritzing diagram
Below you'll see a Fritzing circuit with everything connected. Note that the 5VEN jumper on the L298H board should be closed. This means that the board will be powered from the 6V battery pack. In addition, add a 0.1 uF capacitor between the terminals of the DC motor. This reduces electrical noise induced by the motor.

![Screenshot 2021-11-02 at 00 49 14](https://user-images.githubusercontent.com/58735688/139756946-9dd019a3-a03d-4990-bc9a-a8f8683ed9f5.png)

The following ESP32 GPIO pins are used:

- GPIO 16 - IN1 pin on the L298H motor driver board
- GPIO 17 - IN2 pin on the L298H motor driver board
- GPIO 19 - ENA (Enable) pin on the L298H motor driver board
- GPIO 21 - SDA on the BME280 sensor board and OLED display
- GPIO 22 - SCL on the BME280 sensor board and OLED display

The IN1 (Input 1) and IN2 (Input2) on the L298H controls the direction of motor rotation as follows:

![screenshot_2021-07-23_at_15_57_04_rbPK4i33qv](https://user-images.githubusercontent.com/58735688/144990632-eacc1faa-1c34-45d1-b305-45da3420c213.jpeg)

The ENA (Enable) starts and stops the motor. If a PWM signal is applied to this input, the motor spins at the corresponding speed. Note that if the PWM is set very low, the motor will not start and you might hear a ticking sound from it, since the power put into the motor is not enough to spin it around. For this setup, a PWM > 0.16 is enough to start the engine.

The BME280 sensor and the ESP32 communicates via I2C and since Toit provides a driver for this sensor, using it is really simple: Just hook it up to the corresponding GPIOs. The same goes for the OLED display: Just connect the SDA and CLK to the corresponding GPIOs and your should be fine. However, there is a plethora of SSD1306-based OLED displays out there and they may have different power requirements. The board used in this build need 5V to Vin. 3.3V will NOT suffice. Read more here: https://learn.adafruit.com/monochrome-oled-breakouts/power-requirements

## Picture or it did not happen
[<img width="500" alt="Screenshot 2021-12-07 at 09 16 43" src="https://user-images.githubusercontent.com/58735688/144992233-bd5459a4-c915-4e86-a45b-25030bc62057.png">](https://www.youtube.com/watch?v=iLXiTucIhng)

