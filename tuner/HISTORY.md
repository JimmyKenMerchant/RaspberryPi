## Compatibility Test

* Hash number on the next of the date indicates the last commit that changed anything except "HISTORY.txt" and "README.md" in any project.

* Tools to be used with each test are described at Technical Notes in "share/aloha_raspi/README.txt". If there is any exception, the detail is described along with the name of models.

* Items of the test are described if the project uses multiple abilities of the system.

* The length of time to be spent for each test may be described because the length affects reliability of the test.

* For validity, describing the environment for the test is helpful, e.g., ambient temperature, place, more details of tools, etc.

**November 19, 2019 (#db69ed8)**

* Raspberry Pi Zero V.1.3 (BCM2835), `make type=zero`
	* Function with HDMI Video Output > OK
	* Function with Character LCD Module > OK

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`
	* Function with HDMI Video Output > OK
	* Function with Character LCD Module > OK

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`
	* Function with HDMI Video Output > OK
	* Function with Character LCD Module > OK

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b`
	* Function with HDMI Video Output > OK
	* Function with Character LCD Module > OK
