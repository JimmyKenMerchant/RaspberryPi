# DMX512 Receiver Test

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

### Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

## Purpose

* Test of Protocol of DMX512: Not yet tested with a RS485 receiver.

## Output and Input

* GPIO12 as Output of PWM0

* GPIO13 as Output of PWM1

* GPIO15 as RXD0

* GPIO19-27 as Bit[8:0] of DMX512 Channel Select: CAUTION! DON'T MAKE A SHORT CIRCUIT BETWEEN POWER SOURCE AND GROUND. OTHERWISE YOUR RASPBERRY PI WILL BE BROKEN. CHECK OUT GPIO MAP SO CAREFULLY.

* HDMI as VIDEO Output (For Debug Only)

### GPIO ARE UP TO VOLTAGE OF 3.3V TO INPUT!!! DON'T INPUT VOLTAGE OVER 3.3V TO GPIO PIN!!! OTHERWISE, YOU WILL BE IN DANGER!!! IF YOU CAN'T UNDERSTAND ABOUT THIS, PLEASE STUDY ELECTRONICS FOR A WHILE BEFORE DOING THIS.

## Compatibility

* Raspberry Pi Zero V.1.3 (BCM2835), `make type=zero`

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b`
