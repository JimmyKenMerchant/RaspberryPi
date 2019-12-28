## Compatibility Test

* Hash number on the next of the date indicates the last commit that changed anything except "HISTORY.txt" and "README.md" in any project.

* Tools to be used with each test are described at Technical Notes in "share/aloha_raspi/README.txt". If there is any exception, the detail is described along with the name of models.

* Items of the test are described if the project uses multiple abilities of the system.

* The length of time to be spent for each test may be described because the length affects reliability of the test.

* For validity, describing the environment for the test is helpful, e.g., ambient temperature, place, more details of tools, etc.

**December 28, 2019 (#db69ed8)**

* Raspberry Pi Zero V.1.3 (BCM2835), `make type=zero`
	* Function of UART Tx and Rx Connected with Raspberry Pi Zero W Using Minicom
		* Examples in README.md of Aloha Calc > OK
	* Examples in [UART Console Using pySerial](https://github.com/JimmyKenMerchant/Python_Codes) > OK
		* example.txt > OK
		* example_time.txt  > OK
		* example_snd.txt
			* GPIO 12 (PWM0) and GPIO 13 (PWM1) on `sound=pwm` (Default) Using [Sound System for PWM Output](../schematics/sound_system_pwm.pdf) > OK
			* I2S Output `sound=i2s` Using UDA1334A > OK
		* example_gpio.txt
			* Output GPIOs (GPIO 23-27): Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
		* Function of Saving and Loading with AT24C1024B (Two-wire Serial EEPROM)
			* Loading Code in example_save.txt by example_load.txt > OK
			* Loading Code in example_save.txt on Start Up (High State to GPIO 22 as Start Up Bit) > OK
	* Meta Commands
		* `insert` > OK
		* `delete` > OK
		* `set` > OK

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`
	* Function of UART Tx and Rx Connected with Raspberry Pi Zero Using Minicom
		* Examples in README.md of Aloha Calc > OK
	* Examples in [UART Console Using pySerial](https://github.com/JimmyKenMerchant/Python_Codes) > OK
		* example.txt > OK
		* example_time.txt  > OK
		* example_snd.txt
			* GPIO 12 (PWM0) and GPIO 13 (PWM1) on `sound=pwm` (Default) Using [Sound System for PWM Output](../schematics/sound_system_pwm.pdf) > OK
			* I2S Output `sound=i2s` Using UDA1334A > OK
		* example_gpio.txt
			* Output GPIOs (GPIO 23-27): Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
		* Function of Saving and Loading with AT24C1024B (Two-wire Serial EEPROM)
			* Loading Code in example_save.txt by example_load.txt > OK
			* Loading Code in example_save.txt on Start Up (High State to GPIO 22 as Start Up Bit) > OK
	* Meta Commands
		* `insert` > OK
		* `delete` > OK
		* `set` > OK

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`
	* Function of UART Tx and Rx Connected with Raspberry Pi Zero W Using Minicom
		* Examples in README.md of Aloha Calc > OK
	* Examples in [UART Console Using pySerial](https://github.com/JimmyKenMerchant/Python_Codes) > OK
		* example.txt > OK
		* example_time.txt  > OK
		* example_snd.txt
			* GPIO 12 (PWM0) and GPIO 13 (PWM1) on `sound=pwm` (Default) Using [Sound System for PWM Output](../schematics/sound_system_pwm.pdf) > OK
			* Sound Jack Output GPIO 40 (PWM0) and GPIO 45 (PWM1) on `sound=jack` > OK
			* I2S Output `sound=i2s` Using UDA1334A > OK
		* example_gpio.txt
			* Output GPIOs (GPIO 23-27): Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
		* Function of Saving and Loading with AT24C1024B (Two-wire Serial EEPROM)
			* Loading Code in example_save.txt by example_load.txt > OK
			* Loading Code in example_save.txt on Start Up (High State to GPIO 22 as Start Up Bit) > OK
	* Meta Commands
		* `insert` > OK
		* `delete` > OK
		* `set` > OK
