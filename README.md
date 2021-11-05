# Temperature-controlled fan
This is a temperature-controlled fan with OLED display, built with Toit. The sensor is the Bosch BME280. The OLED is based on the 1306 OLED driver.

## Prerequisites
You need to install two packages. One for the BME280 driver, and one for the OLED display driver. Use the following Toit commands:
```
toit pkg install github.com/toitware/bme280-driver
toit pkg install github.com/toitware/toit-ssd1306
```

## Fritzing diagram

![Screenshot 2021-11-02 at 00 49 14](https://user-images.githubusercontent.com/58735688/139756946-9dd019a3-a03d-4990-bc9a-a8f8683ed9f5.png)
