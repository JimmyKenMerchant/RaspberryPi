# Segment LCD Test

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

### Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**Purpose**

Typically, a segment LCD is on your clock. If you want clear visibility, a segment LCD is still chosen.

The driver for segment LCDs should be brief in view of readability to modify codes, because segment patterns of LCDs, on each module, are different. To fit this condition, I wrote such codes by C language.

**Output/Input**

* GPIO 5 as Input, Increment

* GPIO 6 as Input, Decrement

* GPIO 20 as Input, Toggle Display Mode

* GPIO 21 as Input, Change Subject to Be Incremented or Decremented

* GPIO 22 as Input, Alarm On (High) or Off (Low)

* GPIO 47 as Output of Embedded LED (1Hz Blinker): Except Pi 3B

* GPIO 13 as CS of Segment LCD Module

* GPIO 19 as WR of Segment LCD Module

* GPIO 26 as DATA of Segment LCD Module

* For more information about GPIO of Raspberry Pi, visit [GPIO](https://www.raspberrypi.org/documentation/usage/gpio/).

**Compatibility**

* Raspberry Pi Zero V.1.3 (BCM2835), `make type=zero`

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b`

**Hardware**

It may be your segment LCD module. The LCD controller is HT1621. Unlike general purpose LCDs controlled by HD44780, any popular module doesn't exist, because segment patterns of LCDs are various to be applied. However, you can search your one in the online catalog. HT1621 is used on segment LCD modules whose sizes are fit with portable monitor.

Caution that, typically, segment LCD modules are used with 5 volts. Besides, your RasPi outputs 3.3 volts. If so, a level shifter (logic level converter) is needed to convert 3.3 volts to 5 volts. Several LCDs don't show segments with 3.3 volts, because of avoiding errors on displaying by static electricity.

My module is driven with 5 volts, so a logic level converter (FXMA108) is applied. No external pull-ups are needed for CS, WR, and Data. RD is not used. However, in case, you need to externally pull-up RD pin if it exists, i.e, connect VDD (5 volts) with RD through a 20K ohms resistor.

So, this project is experimental, so far, because of its power consumption. Table clocks lined up in shops can drive at least ONE YEAR without replacing batteries. Don't forget it relies on chips with low power consumption and technologies that strictly pursued the goal. Table clocks with segment LCDs are the answer. To replace the golden rule to new one, we need to take a huge effort to do so.
