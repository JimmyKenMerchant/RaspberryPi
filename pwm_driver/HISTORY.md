## Compatibility Test

* Hash number on the next of the date indicates the last commit that changed anything except "HISTORY.txt" and "README.md" in any project.

* Tools to be used with each test are described at Technical Notes in "share/aloha_raspi/README.txt". If there is any exception, the detail is described along with the name of models.

* Items of the test are described if the project uses multiple abilities of the system.

* The length of time to be spent for each test may be described because the length affects reliability of the test.

* For validity, describing the environment for the test is helpful, e.g., ambient temperature, place, more details of tools, etc.

**December 17, 2019 (#db69ed8)**

* Raspberry Pi Zero V.1.3 (BCM2835), `make type=zero`
	* Function of Input GPIOs Connected with Raspberry Pi 3B Using [GPIO Push Button](https://github.com/JimmyKenMerchant/Python_Codes), Including Changing Beat (Command 29 and 30) and Clearing Output (Command 31) > OK
	* Function of Output GPIOs (GPIO 12 and 13): Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
	* Playing Signal (GPIO 16 for PWM0 and 21 for PWM1): Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
	* Synchronization Clock OUT (GPIO 17): Connected with 3mm Red LED and 10K ohms resister to limit current. > OK

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`
	* Function of Input GPIOs Connected with Raspberry Pi 3B Using [GPIO Push Button](https://github.com/JimmyKenMerchant/Python_Codes), Including Changing Beat (Command 29 and 30) and Clearing Output (Command 31) > OK
	* Function of Output GPIOs (GPIO 12 and 13): Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
	* Playing Signal (GPIO 16 for PWM0 and 21 for PWM1): Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
	* Synchronization Clock OUT (GPIO 17): Connected with 3mm Red LED and 10K ohms resister to limit current. > OK

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`
	* Function of Input GPIOs Connected with Raspberry Pi 3B Using [GPIO Push Button](https://github.com/JimmyKenMerchant/Python_Codes), Including Changing Beat (Command 29 and 30) and Clearing Output (Command 31) > OK
	* Function of Output GPIOs (GPIO 12 and 13): Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
	* Playing Signal (GPIO 16 for PWM0 and 21 for PWM1): Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
	* Synchronization Clock OUT (GPIO 17): Connected with 3mm Red LED and 10K ohms resister to limit current. > OK

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b`
	* Function of Input GPIOs Connected with Raspberry Pi Zero W Using [GPIO Push Button](https://github.com/JimmyKenMerchant/Python_Codes), Including Changing Beat (Command 29 and 30) and Clearing Output (Command 31) > OK
	* Function of Output GPIOs (GPIO 12 and 13): Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
	* Playing Signal (GPIO 16 for PWM0 and 21 for PWM1): Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
	* Synchronization Clock OUT (GPIO 17): Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
