# LED Driver

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

**Purpose**

* Programmable LED Sequencer by C Language

* Selectable Sequences Up to 31

* Changeable Beats from 1Hz (for Decorative Illumination) to 2000Hz (for LED Matrix) in Default

**Output/Input**

* GPIO2-15 and GPIO18-21 as Output of GPIO

* GPIO16 as Output of Playing Signal

* GPIO17 as Output of Synchronization Clock OUT

* GPIO22-26 as Input of GPIO for Buttons (Up to 3.3V): CAUTION! DON'T MAKE A SHORT CIRCUIT BETWEEN POWER SOURCE AND GROUND. OTHERWISE YOUR RASPBERRY PI WILL BE BROKEN. CHECK OUT GPIO MAP SO CAREFULLY.

* Caution that output of GPIO is voltage, but not current. The total current should be up to 50mA and the current of each pin should be up to 16mA. To handle more current to light LEDs, apply Enhancement-mode N-channel MOSFETs and external power supply. For example, connect an output pin to gate, external power supply (VDD) and a load (register and LED) to drain, and GND to source.

* To Test Input, Use [GPIO Push Button](https://github.com/JimmyKenMerchant/Python_Codes).

**Compatibility**

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b`

### GPIO ARE UP TO VOLTAGE OF 3.3V TO INPUT!!! DON'T INPUT VOLTAGE OVER 3.3V TO GPIO PIN!!! OTHERWISE, YOU WILL BE IN DANGER!!! IF YOU CAN'T UNDERSTAND ABOUT THIS, PLEASE STUDY ELECTRONICS FOR A WHILE BEFORE DOING THIS.

### Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.
