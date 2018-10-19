# Software UART Test

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

### Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

## Output and Input

* GPIO9 as Input of MIDI Channel Select Bit[0]

* GPIO10 as Input of MIDI Channel Select Bit[1]

* GPIO12 as Output of PWM0 on sound=pwm or sound=pwmb

* GPIO13 as Output of PWM1 on sound=pwm or sound=pwmb, 180 Degrees Phase-shifted from PWM0 if sound=pwmb

* GPIO40 as Output of PWM0 (R of Phone Connector) on sound=jack or sound=jackb

* GPIO45 (GPIO41 on RasPi 3B) as Output of PWM1 (L of Phone Connector) on sound=jack or sound=jackb, 180 Degrees Phase-shifted from PWM0 if sound=jackb

* GPIO16 as Output of Playing Signal

* GPIO17 as Output of Synchronization Clock OUT of Sound Box

* GPIO20 as Output of GATE Signal Synchronized with MIDI IN (On Note Off Event)

* GPIO15 as Input of RXD0 (UART) for MIDI IN

* GPIO22-26 as Input of GPIO for Buttons (Up to 3.3V): CAUTION! DON'T MAKE A SHORT CIRCUIT BETWEEN POWER SOURCE AND GROUND. OTHERWISE YOUR RASPBERRY PI WILL BE BROKEN. CHECK OUT GPIO MAP SO CAREFULLY.

* GPIO 18 (BCLK), 19 (LRCLK), and 21 (DOUT) as Output of I2S (as known as 3-wire I2S) on sound=i2s

* HDMI as VIDEO Output

### GPIO 22-27 ARE UP TO VOLTAGE OF 3.3V TO INPUT!!! DON'T INPUT VOLTAGE OVER 3.3V TO GPIO PIN!!! OTHERWISE, YOU WILL BE IN DANGER!!! IF YOU CAN'T UNDERSTAND ABOUT THIS, PLEASE STUDY ELECTRONICS FOR A WHILE BEFORE DOING THIS.

## Compatibility

Under Construction
