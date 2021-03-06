## Compatibility Test

* Hash number on the next of the date indicates the last commit that changed anything except "HISTORY.txt" and "README.md" in any project.

* Tools to be used with each test are described at Technical Notes in "share/aloha_raspi/README.txt". If there is any exception, the detail is described along with the name of models.

* Items of the test are described if the project uses multiple abilities of the system.

* The length of time to be spent for each test may be described because the length affects reliability of the test.

* For validity, describing the environment for the test is helpful, e.g., ambient temperature, place, more details of tools, etc.

**November 21, 2019 (#db69ed8)**

* Raspberry Pi Zero V.1.3 (BCM2835), `make type=zero`
	* Typing in Test Mode, `debug=yes` > OK
	* Function as Console Connected with Raspberry Pi Zero or Zero W Running Aloha Calc 1.0.0 through UART > OK

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`
	* Typing in Test Mode, `debug=yes` > OK
	* Function as Console Connected with Raspberry Pi Zero or Zero W Running Aloha Calc 1.0.0 through UART > OK

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`
	* Typing in Test Mode, `debug=yes` > OK
	* Function as Console Connected with Raspberry Pi Zero or Zero W Running Aloha Calc 1.0.0 through UART > OK

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b`
	* Typing in Test Mode, `debug=yes` > OK
	* Function as Console Connected with Raspberry Pi Zero or Zero W Running Aloha Calc 1.0.0 through UART > Confirmed Receiving Characters
