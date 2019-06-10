# TFT Test

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

### Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**Purpose**

Raspberry Pi has several video outputs; HDMI, MIPI Display Serial Interface (MIPI DSI), and Composite Video. HDMI and MIPI DSI are digital outputs which are regulated by each organization. These regulations include physical layer to application layer. Composite Video is an analog output which are connected by a RCA cable. These give us a big screen. In this project, I'm testing small screens, connecting through Serial Peripheral Interface (SPI). The goal is displaying a small screen with 10 to 15 fps, and the image processing, including processing of several inputs, is enough to run by CPU.

You can find many sorts of LCD/OLED modules in the online catalog. These are our frontier, and may be surpluses from manufactures or not. Anyway, we need to pursue different specifications of modules. Each LCD/OLED display has unique size and gamma characteristic. Plus, display drivers in modules are different products. Unique settings for each module are written in "library" folder of this project. And I noted the difference among display drivers in [tft32.s](../share/aloha_raspi/system32/library/tft32.s).

**Output/Input**

* GPIO 7 as SPI0 CE1 (Chip Enable 1)

* GPIO 8 as SPI0 CE0 (Chip Enable 0)

* GPIO 9 as SPI0 MISO: Make sure to take care of input voltage, up to 3.3 volts. 

* GPIO 10 as SPI0 MOSI

* GPIO 11 as SPI0 SCLK

* GPIO 25 as Outoput for RESET Pin of TFT LCD Module

* GPIO 47 (ACT LED) as Output

* HDMI as VIDEO Output

### GPIO PINS ARE UP TO VOLTAGE OF 3.3V TO INPUT!!! DON'T INPUT VOLTAGE OVER 3.3V TO GPIO PIN!!! OTHERWISE, YOU WILL BE IN DANGER!!! IF YOU CAN'T UNDERSTAND ABOUT THIS, PLEASE STUDY ELECTRONICS FOR A WHILE BEFORE DOING THIS.

**Compatibility**

Under Debugging

**Hardware**

* Note that TFT LCD Modules have various products. These need to have unique settings. I'm planning to add modules to fit this project.

* TFT2P0327-E: 1.77 Inches TFT LCD Module
