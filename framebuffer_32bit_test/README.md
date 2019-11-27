# Framebuffer 32-bit Test

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

**Output/Input**

* GPIO 47 (ACT LED) as Output

* HDMI as VIDEO Output

**Compatibility**

* Raspberry Pi Zero V.1.3 (BCM2835), `make type=zero`

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b`

## Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**Memorandum on Testing**

* Lacking of the first dot occurs at `fb32_draw_image` on a particular situation (check a character in user32.c.alpha), which seems that the little difference between the prior color and the current color on the first dot causes this issue. So far, data memory barriers does not fix this issue. However, this issue occurs only on my Zero W and 3 B, but not my Zero and 2 B. It may be caused by an individual difference or an issue between the HDMI output and the display.

**Memorandum on BCM2835**

* Flagging "shareable" to the address translation table makes speed of accessing memory slower. This affects writing speed to the framebuffer.
