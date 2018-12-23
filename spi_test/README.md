# SPI Test

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

### Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**Output/Input**

* GPIO 7 as SPI0 CE1 (Chip Enable 1)

* GPIO 8 as SPI0 CE0 (Chip Enable 0)

* GPIO 9 as SPI0 MISO: Make sure to take care of input voltage, up to 3.3 volts. 

* GPIO 10 as SPI0 MOSI

* GPIO 11 as SPI0 SCLK

* GPIO 47 (ACT LED) as Output

* HDMI as VIDEO Output

### GPIO PINS ARE UP TO VOLTAGE OF 3.3V TO INPUT!!! DON'T INPUT VOLTAGE OVER 3.3V TO GPIO PIN!!! OTHERWISE, YOU WILL BE IN DANGER!!! IF YOU CAN'T UNDERSTAND ABOUT THIS, PLEASE STUDY ELECTRONICS FOR A WHILE BEFORE DOING THIS.

**Compatibility**

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b`

**Hardware**

* MCP3002-I/P: Check out the Data sheet. If you use this with RaspberryPi, 3.3V is preferred to power VDD because of no need to make a level shifter. MCP3002-I/P works well with 3.3V power source in my experience. Check data sheet of MCP3002-I/P which describes characteristics on 2.7V and 5V.

**SPI Interface**

* Host's clock sends to a selected device only when the host transfers data. That is, if you want receive data from a device, you need to send dummy bytes, with the length you want to receive, to a device after sending bytes for a command. Similarly, if a device needs activation before receiving any command, you need to send dummy bytes before sending commands. This system supports variant clock speed for different devices with a host.

* Host works asynchronous with CPU, so you need to detect completion of a transaction (transferring and, if it exists, receiving). Polling Done bit (end of transferring) in CS register helps the detection. However, Host's RxFIFO has limitation to stack (16 words, seems 64 bytes). You needs to limit length of a transaction up to 16 words and have several transactions in a procedure.

* CS's low means one procedure which consists one and more transactions. If CS highs from low, this means the end of a procedure.

**Electric Schematics**

* [Audio Quantization System](../schematics/audio_quantization.pdf)
