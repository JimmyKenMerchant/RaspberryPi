# USB Test

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

**Purpose**

* Making Experimental UART Console Inputted by USB Keyboard

**Output/Input**

* GPIO 4 as GPCLK0 for Second Timer

* GPIO 14 as TXD0

* GPIO 15 as RXD0

* GPIO 47 (ACT LED) as Output

* USB as Output

* HDMI as VIDEO Output

**Compatibility**

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`, Using High Speed USB 2.0 Hub Is Preferred to Connect USB 1.x Devices Such as Human Interface Device (HID)

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`, Needs Commented Out of `bl gpio32_gpioreset`, However Only One Is Tested.

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b`

* Add `debug=yes` to these commands to enter the test mode which displays characters received from the USB keyboard.

* Initializing process of USB are almost the same as a project, Aloha Calc. However setting process of GPIO in vector32.s has a difference from Aloha Calc. In this project, `bl gpio32_gpioreset` is commented out because of checking compatibility.

### Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**Draft on USB**

* Originally, USB 1.x devices are not considering of using with connectors of Micro-USB, i.e., connectors of Micro-USB may not be matched with USB 1.x devices in terms of electricity. Difference of impedance may affect communications between USB devices.