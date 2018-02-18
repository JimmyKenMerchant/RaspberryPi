# UART Test

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

## Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**Output/Input**

* GPIO 14 as TXD0

* GPIO 15 as RXD0

* USB as Output

* HDMI as VIDEO Output

## GPIO PINS ARE UP TO VOLTAGE OF 3.3V TO INPUT!!! DON'T INPUT VOLTAGE OVER 3.3V TO GPIO PIN!!! OTHERWISE, YOU WILL BE IN DANGER!!! IF YOU CAN'T UNDERSTAND ABOUT THIS, PLEASE STUDY ELECTRONICS FOR A WHILE BEFORE DOING THIS.

**Compatibility**

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b`

**Settings for Another Raspberry Pi to Check This Test**

```bash
#This Example is for Raspberry Pi 3B and Pi Zero W with Raspbian Stretch 

# 5 Interfacing Options > P6 Serial > No (serial login shell) > Yes (serial interface) > OK > Finish (Reboot)
sudo raspi-config

# Make Sure of comment "enable_uart=1" if RasPi 3B which uses UART1 for the interface
sudo less /boot/config.txt

# Check current status
sudo stty -F /dev/serial0 -a

# Set UART rate to 115200 baud
sudo stty -F /dev/serial0 115200

# Verify changed baud
sudo stty -F /dev/serial0 speed

# To Read and Write
# Ctrl+m Sends CR, Ctrl+j Sends LF, Ctrl+@ Sends Null Character, Similar to Macros of TeraTerm
sudo minicom -D /dev/serial0
# sudo apt-get install minicom

# To Write on another terminal (Write Once per Word, 4 Bytes)
# sudo echo -ne 'GOOD\r\n' > /dev/serial0

# https://unix.stackexchange.com/questions/117037/how-to-send-data-to-a-serial-port-and-see-any-answer
```

**Draft of Description about "UART"**

* UART seems to need to connect with HDMI device on Booting Process. If not, UART will send unavailable characters. This may be relevant to HDMI ground pin with GND. Check the discussion, [UART problem and HDMI](https://www.raspberrypi.org/forums/viewtopic.php?t=61971&p=460906).
