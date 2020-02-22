# DMX512 Transmitter Test

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

### Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

## Purpose

* Test of Protocol of DMX512: Not yet tested with a RS485 transceiver.

## Output and Input

* GPIO14 as TXD0

* GPIO15 as Output of Busy Toggle for Acknowledgment of Command from Parallel Bus

* GPIO16 as Output of EOP Toggle

* GPIO27 as Input of Clock IN for Parallel Bus (Detects Status of Parallel Bus on Falling Edge of Clock IN)

* GPIO22-26 as Input of GPIO for Parallel Bus: CAUTION! DON'T MAKE A SHORT CIRCUIT BETWEEN POWER SOURCE AND GROUND. OTHERWISE YOUR RASPBERRY PI WILL BE BROKEN. CHECK OUT GPIO MAP SO CAREFULLY.

* HDMI as VIDEO Output

### GPIO ARE UP TO VOLTAGE OF 3.3V TO INPUT!!! DON'T INPUT VOLTAGE OVER 3.3V TO GPIO PIN!!! OTHERWISE, YOU WILL BE IN DANGER!!! IF YOU CAN'T UNDERSTAND ABOUT THIS, PLEASE STUDY ELECTRONICS FOR A WHILE BEFORE DOING THIS.

## Compatibility

* Raspberry Pi Zero V.1.3 (BCM2835), `make type=zero`

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`
