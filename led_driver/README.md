# LED Driver

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

### Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**Purpose**

* Programmable LED Sequencer by C Language

* Selectable Sequences Up to 31

* Changeable Beats from 1Hz (for Decorative Illumination) to 2000Hz (for LED Matrix) in Default

**Output/Input**

* GPIO2-15 and GPIO18-21 as Output of GPIO

* GPIO16 as Output of Playing Signal

* GPIO17 as Output of Synchronization Clock OUT

* GPIO27 as Input of Clock IN for Buttons (Detects Status of Buttons on Falling Edge of Clock IN)

* GPIO22-26 as Input of GPIO for Buttons: CAUTION! DON'T MAKE A SHORT CIRCUIT BETWEEN POWER SOURCE AND GROUND. OTHERWISE YOUR RASPBERRY PI WILL BE BROKEN. CHECK OUT GPIO MAP SO CAREFULLY.

* Caution that output of GPIO is voltage, but not current. The total current should be up to 50mA and the current of each pin should be up to 16mA. To handle more current to light LEDs, apply Enhancement-mode N-channel MOSFETs and external power supply. For example, connect an output pin to gate, external power supply (VDD) and a load (register and LED) to drain, and GND to source.

* To Test Input, Use [GPIO Push Button](https://github.com/JimmyKenMerchant/Python_Codes).

### GPIO ARE UP TO VOLTAGE OF 3.3V TO INPUT!!! DON'T INPUT VOLTAGE OVER 3.3V TO GPIO PIN!!! OTHERWISE, YOU WILL BE IN DANGER!!! IF YOU CAN'T UNDERSTAND ABOUT THIS, PLEASE STUDY ELECTRONICS FOR A WHILE BEFORE DOING THIS.

**Compatibility**

* Raspberry Pi Zero V.1.3 (BCM2835), `make type=zero`

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b`

**Electric Schematics**

* [LED Driver with Power MOSFET](../schematics/led_driver_mosfet.pdf)

**About Application**

* Command 16 (with an array named `gpio16[]`) is for a 5x7 dots matrix blue LED (MOA20UB019GJ). Note that the dot pattern is almost a greater-than sign, but the 3rd and 5th rows need to be fixed for becoming the sign. Replace `1<<6` with `1<<5` in 3rd and 5th row. Look out `!?` comments at the 3rd and 5th rows for reference.

* To light many LEDs, you need to boost RasPi's output from its GPIO. My schematic is one of example. However, in the case of lighting multiple LEDs, a transistor array is preferred, e.g., TBD62083A series (inverted), and TBD62783A series (non-inverted). These accept 3.3V input and can also perform as a level shifter.
