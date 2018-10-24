# Aloha Calc

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

## Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**About Aloha Calc**

* "Aloha Calc" is a programmable calculator. "Aloha Calc" runs the script, "Aloha Mini Language", that resembles assembly languages. Several commands of "Aloha Mini Language" are derived from BASIC, but its syntax is just simpler than BASIC, e.g., `add %1 %2 %3` means `%1 = %2 + %3` in natural (% is prefix for line numbers). This simplicity is not only usable for learning assembly language, but also usable for development with a flowchart. "Aloha Mini Language" has no need of declaration any type for variables. Variables, for source or destination, are assigned by each line number or label.

```
|01| * Example of "Aloha Mini Language" to say "Hello World!".
|02| * ".greeting" is a label which is prefixed by a period.
|03| print .greeting
|04| .greeting Hello World!
|05| end
|06| run
```

**Output/Input**

* GPIO12 as Output of PWM0 on sound=pwm (If you no need, uncomment __SOUND on the top of vector.s)

* GPIO13 as Output of PWM1 on sound=pwm (If you no need, uncomment __SOUND on the top of vector.s)

* GPIO 2 as SDA1 (Use for EEPROM)

* GPIO 3 as SCL1 (Use for EEPROM)

* GPIO 14 as TXD0

* GPIO 15 as RXD0

* GPIO22 as Input for Start Up Bit

* GPIO23-27 as Output

* GPIO 18 (BCLK), 19 (LRCLK), and 21 (DOUT) as Output of I2S on sound=i2s (If you no need, uncomment __SOUND on the top of vector.s)

* USB as Input/Output (Use for Keyboard): It is experimental and needed your USB and electrical acknowledgment.

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

* UART seems to be 2-wire if you only use Tx and Rx. But, in several case, we need to connect ground to each devices. E.g., we assume that we connect two RasPis by UART. If you don't connect any HDMI cable to one RasPi, there is a need to connect ground to each devices. No connection with any HDMI cable is detected by your RasPi on booting, and it causes signaling analogue video output that changes electrical status (including noise of the voltage on ground) of your RasPi. Otherwise, unavailable characters are received, i.e., communication fails. The reason is the different voltage on ground (by means of chassis) of each device. Ideally, the voltage on ground of each device should be the same as the one of earth. But as long as you don't apply any earth wire, the voltage on ground of each device differs from others. This makes an odd on detection of GPIO status.
