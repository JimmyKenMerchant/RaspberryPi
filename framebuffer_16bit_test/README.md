# Framebuffer 16-bit Test

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

**Output/Input**

* GPIO 47 (ACT LED) as Output

* HDMI as VIDEO Output

**Compatibility**

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b`

## Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**Usage of 16-bit Color Depth**

* 5 Bits for Red, 6 Bits for Green, and 5 Bits for Blue.

* You may want to use 16-bit color because it has a rendering speed quicker than 32-bit color. There is one issue how to determine full transparent, even though an alpha channel is not available. Check a file named "equ32.s" and a parameter, "equ32_fb32_image_16bit_tp_color". This defines color code for full transparent in 16-bit color. In default, "0x0000" is defined, and it's a color code for black. Note that this specialty is only on a function, "fb32_image".
