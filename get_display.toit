// Copyright (C) 2021 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import gpio
import i2c
import ssd1306 show *
import pixel_display show *

get_display -> PixelDisplay:
  scl := gpio.Pin 22
  sda := gpio.Pin 21
  bus := i2c.Bus
    --sda=sda
    --scl=scl
    --frequency=800_000

  devices := bus.scan
  if not devices.contains 0x3d: throw "No SSD1306 display found"

  driver := SSD1306 (bus.device 0x3d)
  return TwoColorPixelDisplay driver
