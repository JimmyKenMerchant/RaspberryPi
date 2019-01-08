# PWM Driver

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

**Purpose**

* Programmable PWM Sequencer by C Language

* Selectable Sequences Up to 31

**Output/Input**

* GPIO12 as Output of PWM0

* GPIO13 as Output of PWM1

* GPIO16 as Output of Playing Signal of PWM0

* GPIO21 as Output of Playing Signal of PWM1

* GPIO17 as Output of Synchronization Clock OUT

* GPIO22-26 as Input of GPIO for Buttons (Up to 3.3V): CAUTION! DON'T MAKE A SHORT CIRCUIT BETWEEN POWER SOURCE AND GROUND. OTHERWISE YOUR RASPBERRY PI WILL BE BROKEN. CHECK OUT GPIO MAP SO CAREFULLY.

* Caution that output of GPIO is voltage, but not current. The total current should be up to 50mA and the current of each pin should be up to 16mA. To handle more current to light LEDs, apply Enhancement-mode N-channel MOSFETs and external power supply. For example, connect an output pin to gate, external power supply (VDD) and a load (register and LED) to drain, and GND to source. If you use duty ratio, it's OK because of switching (digital) behavior. If you use variable voltage to get behavior like analogue, you need an idea of a buck converter, one of switched-mode power supply.

* There are two modes on PWM; variable frequencies to balance pulses (multiple highs and lows), and fixed frequency (one high and low) in a duty cycle. Default is on variable frequencies. However, fixed frequency has been studied well. In fact, on fixed frequency, elements such as inductors and capacitors are determined easier than variable frequencies. Besides, PWM on variable frequencies might be able to remove several elements to make a switched-mode power supply in my opinion.

* To Test Input, Use [GPIO Push Button](https://github.com/JimmyKenMerchant/Python_Codes).

**Compatibility**

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b`

### GPIO ARE UP TO VOLTAGE OF 3.3V TO INPUT!!! DON'T INPUT VOLTAGE OVER 3.3V TO GPIO PIN!!! OTHERWISE, YOU WILL BE IN DANGER!!! IF YOU CAN'T UNDERSTAND ABOUT THIS, PLEASE STUDY ELECTRONICS FOR A WHILE BEFORE DOING THIS.

### Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**Electrical Schematics**

* [DC Motor Driver with Buck (Step-down) Converter](../schematics/dc_motor_driver.pdf)

