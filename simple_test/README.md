# Simple Test

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

**Output/Input**

* GPIO 20 as Input. If you set voltage high (UP TO 3.3V! DON'T USE VOLTAGE OVER 3.3V!), GPIO 21 keeps lighting.

* GPIO 21 as Output (1Hz Blinker), make sure to attach the appropriate resister to your LED Circuit, otherwise, the LED may be burn out.

* GPIO 47 as Output of Embedded LED (1Hz Blinker): Except Pi 3B

* For more information about GPIO of Raspberry Pi, visit [GPIO](https://www.raspberrypi.org/documentation/usage/gpio/).

**Compatibility**

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b`

### Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.
