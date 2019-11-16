# Frequency Counter

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

**Output/Input**

* GPIO 47 (ACT LED) as Output

* GPIO 12 as PWM0 Output

* GPIO 4 as GPCLK0 Output

* HDMI as VIDEO Output

* GPIO 21 as Input (Caution! Voltage Limitation Is Up To 3.3V!)

### GPIO 21 IS UP TO VOLTAGE OF 3.3V TO INPUT!!! DON'T INPUT VOLTAGE OVER 3.3V TO GPIO PIN!!! OTHERWISE, YOU WILL BE IN DANGER!!! IF YOU CAN'T UNDERSTAND ABOUT THIS, PLEASE STUDY ELECTRONICS FOR A WHILE BEFORE DOING THIS.

**Compatibility**

* Raspberry Pi Zero V.1.3 (BCM2835), `make type=zero`

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b`

**Specification**

* Range: 0 Hz to 5 MHz (On Raspberry Pi Zero V.1.3 and Raspberry Pi Zero W V.1.1)

### Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.
