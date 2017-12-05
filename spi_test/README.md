# SPI Test

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

## Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**Output/Input**

* GPIO 7 as SPI0 CE1 (Chip Enable 1)

* GPIO 8 as SPI0 CE0 (Chip Enable 0)

* GPIO 9 as SPI0 MISO: Make sure to take care of input voltage, up to 3.3 volts. 

* GPIO 10 as SPI0 MOSI

* GPIO 11 as SPI0 SCLK

* GPIO 47 (ACT LED) as Output

* HDMI as VIDEO Output

## GPIO PINS ARE UP TO VOLTAGE OF 3.3V TO INPUT!!! DON'T INPUT VOLTAGE OVER 3.3V TO GPIO PIN!!! OTHERWISE, YOU WILL BE IN DANGER!!! IF YOU CAN'T UNDERSTAND ABOUT THIS, PLEASE STUDY ELECTRONICS FOR A WHILE BEFORE DOING THIS.

**Compatibility**

Under Construction

**Hardware**

* MCP3002-I/P: Check out the Data sheet.
