# Segment LCD Test

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

### Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**Purpose**

Typically, a segment LCD is on your clock. If you want clear visibility, a segment LCD is still chosen.

The driver for segment LCD should be brief in view of readability, so I write such codes by C language.

**Output/Input**

* GPIO 20 as Input. If you set voltage high (UP TO 3.3V! DON'T USE VOLTAGE OVER 3.3V!), GPIO 21 keeps lighting.

* GPIO 21 as Output (1Hz Blinker), make sure to attach the appropriate resister to your LED Circuit, otherwise, the LED may be burn out.

* GPIO 47 as Output of Embedded LED (1Hz Blinker): Except Pi 3B

* GPIO 6 as CS of Segment LCD Module

* GPIO 13 as RD of Segment LCD Module

* GPIO 19 as WR of Segment LCD Module

* GPIO 26 as DATA of Segment LCD Module

* For more information about GPIO of Raspberry Pi, visit [GPIO](https://www.raspberrypi.org/documentation/usage/gpio/).

**Compatibility**

Under Debugging

**Hardware**

It may be your segment LCD. The LCD controller is HT1621. Unlike general purpose LCDs controlled by HD44780, any popular module doesn't exist, because patterns of segment LCDs are various to be applied. However, you can search your one in the online catalog.

Caution that modules may be used with 5 volts. Besides, your RasPi outputs 3.3 volts. If so, a level shifter (logic level converter) is needed to convert 3.3 volts to 5 volts.
