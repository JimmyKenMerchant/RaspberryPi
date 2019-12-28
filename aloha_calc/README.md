# Aloha Calc

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

## Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**About Aloha Calc**

* "Aloha Calc" is a programmable calculator. "Aloha Calc" runs the script, "Aloha Mini Language" that resembles BASIC. E.g., `int @1 @2 + @3` means `@1 = @2 + @3` in integer (@ is prefix for line numbers). "Aloha Mini Language" has no need of declaration any type for variables. Variables, for source or destination, are assigned by each line number or label.

```
* Example of "Aloha Mini Language" to say "Hello World!".
* ".greeting" is a label which is prefixed by a period.
print .greeting
.greeting Hello World!
end
run

```

```
* Example of "Aloha Mini Language" to Multiply Integers.
int .answer .number1 * .number2
.answer
.number1 3
.number2 4
end
run

```

```
* Example of "Aloha Mini Language".
* If input is "e", program will end.
.str_prompt Press "e" then Enter to end: 
.str_bye See Yo!\n
.answer a
.str_end e
.loop print .str_prompt
 input .answer
 ifs .answer != .str_end
  jmp .loop
 endif
print .str_bye
end
run

```

```
* Example of "Aloha Mini Language".
.str_high High\n
.str_low Low\n
.level
.gpionumber 21
.compare 1

ingpio .level .gpionumber
print 'High or Low of GPIO21: 
if .level == .compare
 print .str_high
else
 print .str_low
endif
end
run

```

```
* Example of "Aloha Mini Language", Music Test.
.arr0
.d 9,8,7,6,5,4,3,4,5,6,7,8,
   9,9,9,9,9,9,8,8,8,8,8,8,
   7,7,7,7,7,7,6,6,6,6,6,6,
   5,5,4,4,3,3,3,3,4,4,5,5,
   xFFFF
.d_end
.d_length
.d_ptr
.2_byte_align 1
.repeat_infinite -1

* Get pointer and length of array of data.
ptr .d_ptr .d
* vlen measures length between a label (.d) and a label which is not initialized (.d_end).
vlen .d_length .d
arr .arr0 .d_ptr .d_length .2_byte_align
* Start sound
snd .arr0 .repeat_infinite
* Sleep 10 Seconds then music will end.
sleep '10000000
clrsnd
end
run

```

**Output/Input**

* GPIO 12 as Output of PWM0 on sound=pwm (If you no need, uncomment __SOUND on the top of vector.s)

* GPIO 13 as Output of PWM1 on sound=pwm (If you no need, uncomment __SOUND on the top of vector.s)

* GPIO 2 as SDA1 (Use for EEPROM)

* GPIO 3 as SCL1 (Use for EEPROM)

* GPIO 14 as TXD0

* GPIO 15 as RXD0

* GPIO 22 as Input for Start Up Bit

* GPIO 23-27 as Output

* GPIO 18 (BCLK), 19 (LRCLK), and 21 (DOUT) as Output of I2S on sound=i2s (If you no need, uncomment __SOUND on the top of vector.s)

* GPIO 40 as Output of PWM0 (R of Phone Connector) on sound=jack

* GPIO 45 (GPIO 41 on RasPi 3B) as Output of PWM1 (L of Phone Connector) on sound=jack

* HDMI as VIDEO Output

## YOU'LL MEET BIG SOUND! PLEASE CARE OF YOUR EARS! I RECOMMEND THAT YOU DON'T USE ANY EARPHONE OR HEADPHONE FOR THIS PROJECT.

## GPIO PINS ARE UP TO VOLTAGE OF 3.3V TO INPUT!!! DON'T INPUT VOLTAGE OVER 3.3V TO GPIO PIN!!! OTHERWISE, YOU WILL BE IN DANGER!!! IF YOU CAN'T UNDERSTAND ABOUT THIS, PLEASE STUDY ELECTRONICS FOR A WHILE BEFORE DOING THIS.

**Compatibility**

* Raspberry Pi Zero V.1.3 (BCM2835), `make type=zero sound=i2s` or `make type=zero sound=pwm`

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow sound=i2s` or `make type=zerow sound=pwm`

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b sound=i2s` or `make type=2b sound=pwm` or `make type=2b sound=jack`

* Caution that Raspberry Pi 3 B V.1.2 (BCM2837) is under testing.

**Settings to Check This Test**

```bash
#This Example is for Raspberry Pi 3B and Pi Zero W with Raspbian Stretch 

# 5 Interfacing Options > P6 Serial > No (serial login shell) > Yes (serial interface) > OK > Finish (Reboot)
sudo raspi-config

# If You Can't Find Out "/dev/serial0", Check Out https://www.raspberrypi.org/documentation/configuration/uart.md
# Add dtoverlay=pi3-miniuart-bt and core_freq=250 in /boot/config.txt to Enable serial0 on RasPi with Wireless Module
sudo stty -F /dev/serial0 -a

# Set UART rate to 115200 baud
sudo stty -F /dev/serial0 115200

# Verify changed baud
sudo stty -F /dev/serial0 speed

# To Read and Write
# Ctrl+m Sends CR, Ctrl+j Sends LF, Ctrl+@ Sends Null Character, Similar to Macros of TeraTerm
# sudo apt-get install minicom
sudo minicom -D /dev/serial0

# To Write on another terminal (Write Once per Word, 4 Bytes)
# sudo echo -ne 'GOOD\r\n' > /dev/serial0

# https://unix.stackexchange.com/questions/117037/how-to-send-data-to-a-serial-port-and-see-any-answer
```

**Hardware**

* AT24C1024B: Two-wire Serial EEPROM

* UDA1334A with Adafruit's Breakout: I2S Stereo Decoder

**Electric Schematics**

* [Sound System for PWM Output](../schematics/sound_system_pwm.pdf)

**Version Information**

* Aloha Calc Version 1.0.* (Current Version): BASIC Style

* Aloha Calc Version 0.9.* Beta (Version 1.1.0 of This Repository): Assembly Language Style, Experimental USB Keyboard

**Draft of Description about "UART"**

* UART seems to be 2-wire if you only use Tx and Rx. But, in several case, we need to connect ground to each devices. E.g., we assume that we connect two RasPis by UART. If you don't connect any HDMI cable to one RasPi, there is a need to connect ground to each devices. No connection with any HDMI cable is detected by your RasPi on booting, and it causes signaling analogue video output that changes electrical status (including noise of the voltage on ground) of your RasPi. Otherwise, unavailable characters are received, i.e., communication fails. The reason is the different voltage on ground (by means of chassis) of each device. Ideally, the voltage on ground of each device should be the same as the one of earth. But as long as you don't apply any earth wire, the voltage on ground of each device differs from others. This makes an odd on detection of GPIO status.
