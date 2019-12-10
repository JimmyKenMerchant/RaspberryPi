## Compatibility Test

* Hash number on the next of the date indicates the last commit that changed anything except "HISTORY.txt" and "README.md" in any project.

* Tools to be used with each test are described at Technical Notes in "share/aloha_raspi/README.txt". If there is any exception, the detail is described along with the name of models.

* Items of the test are described if the project uses multiple abilities of the system.

* The length of time to be spent for each test may be described because the length affects reliability of the test.

* For validity, describing the environment for the test is helpful, e.g., ambient temperature, place, more details of tools, etc.

**December 10, 2019 (#db69ed8)**

* Raspberry Pi Zero V.1.3 (BCM2835), `make type=zero`
	* Function of Input GPIOs Connected with Raspberry Pi 3B Using [GPIO Push Button](https://github.com/JimmyKenMerchant/Python_Codes), Including Changing Beat (Command 29 and 30) and Clearing Output (Command 31) > OK
	* Function of Output GPIOs (GPIO 2-6 and 7-13): Connected with 5x7 Dots Matrix Blue LED (MOA20UB019GJ), each cathode is connected with a 10K ohms resister to limit current (GPIO 7-13 cathodes top to bottom, 2-6 anodes left to right). Command 16 utilizes the Dots Matrix. > OK
	* Playing Signal (GPIO 16) > OK
	* Synchronization Clock OUT (GPIO 17) > OK

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`
	* Function of Input GPIOs Connected with Raspberry Pi 3B Using [GPIO Push Button](https://github.com/JimmyKenMerchant/Python_Codes), Including Changing Beat (Command 29 and 30) and Clearing Output (Command 31) > OK
	* Function of Output GPIOs (GPIO 2-6 and 7-13): Connected with 5x7 Dots Matrix Blue LED (MOA20UB019GJ), each cathode is connected with a 10K ohms resister to limit current (GPIO 7-13 cathodes top to bottom, 2-6 anodes left to right). Command 16 utilizes the Dots Matrix. > OK
	* Playing Signal (GPIO 16) > OK
	* Synchronization Clock OUT (GPIO 17) > OK

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`
	* Function of Input GPIOs, Manually Signaling > OK
	* Function of Output GPIOs (GPIO 2-5): Connected with 3mm Red LED and 10K ohms resister to limit current > OK
	* Playing Signal (GPIO 16) > OK
	* Synchronization Clock OUT (GPIO 17) > OK

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b`
	* Function of Input GPIOs Connected with Raspberry Pi Zero W Using [GPIO Push Button](https://github.com/JimmyKenMerchant/Python_Codes), Including Changing Beat (Command 29 and 30) and Clearing Output (Command 31) > OK
	* Function of Output GPIOs (GPIO 2-6 and 7-13): Connected with 5x7 Dots Matrix Blue LED (MOA20UB019GJ), each cathode is connected with a 10K ohms resister to limit current (GPIO 7-13 cathodes top to bottom, 2-6 anodes left to right). Command 16 utilizes the Dots Matrix. > OK
	* Playing Signal (GPIO 16) > OK
	* Synchronization Clock OUT (GPIO 17) > OK
