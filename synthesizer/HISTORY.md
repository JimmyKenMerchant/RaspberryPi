## Compatibility Test

* Hash number on the next of the date indicates the last commit that changed anything except "HISTORY.txt" and "README.md" in any project.

* Tools to be used with each test are described at Technical Notes in "share/aloha_raspi/README.txt". If there is any exception, the detail is described along with the name of models.

* Items of the test are described if the project uses multiple abilities of the system.

* The length of time to be spent for each test may be described because the length affects reliability of the test.

* For validity, describing the environment for the test is helpful, e.g., ambient temperature, place, more details of tools, etc.

**January 11, 2020 (#db69ed8)**

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`
	* Function of Input GPIOs Connected with Raspberry Pi Zero W Using [GPIO Push Button](https://github.com/JimmyKenMerchant/Python_Codes), Including Changing Beat (Command 29 and 30) and Clearing Output (Command 31) > OK
	* `user32.c.alpha` > OK
	* `user32.c.beta` > OK
	* PWM Output GPIO 12 (PWM0) and GPIO 13 (PWM1) on `sound=pwm` (Default) Using [Sound System for PWM Output](../schematics/sound_system_pwm.pdf), Including Tuning of D7 for R with Sine Wave (Command 1); and C2, C3, C4, C5, C6, C7, C8, and A4 for L with Sine Wave (Command 3) > OK
	* PWM Output GPIO 40 (PWM0) and GPIO 45 (PWM1) on `sound=jack`, Including Tuning of D7 for R with Sine Wave (Command 1); and C2, C3, C4, C5, C6, C7, C8, and A4 for L with Sine Wave (Command 3) > OK
	* I2S Output GPIO 18 (BCLK), 19 (LRCLK), and 21 (DOUT) on `sound=i2s` Using UDA1334A, Including Tuning of D7 for R with Sine Wave (Command 1); and C2, C3, C4, C5, C6, C7, C8, and A4 for L with Sine Wave (Command 3) > OK
	* Playing Signal (GPIO 16) at `sound=i2s` and `sound=jack`: Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
	* Synchronization Clock OUT (GPIO 5) at `sound=i2s` and `sound=jack`: Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
	* MIDI IN at `sound=i2s`
		* UART Rx (Baud Rate 115200) Directly Connected with UART Tx of Raspberry Pi Zero W, Sending MIDI Data Using [JACK Audio Connection Kit to Serial Interface Bridge](https://github.com/JimmyKenMerchant/Python_Codes) with QjackCtl (Audio I/O Control), a2jmidid (ALSA MIDI to JACK MIDI Bridege), jack-keyboard (Software Keyboard) and Qtractor (MIDI Sequencer)
			* Note On and Off > OK
			* Velocity Change > OK
			* Pitch Bending > OK (Needed to Simplify Process)
			* Modulation (CC#1 for Coarse and CC#33 for Fine) and Changing Its Range (CC#16 for Coarse and CC#48 for Fine, General Purpose Controller 1) > Possible Noise and Mulfunction Because of Floating Base on Changing Range
			* Digital LFO modulation
				* CC#12 (Effect Control 1 Coarse) and CC#44 (Effect Control 1 Fine) to Set Changing Speed (Delta) of Frequency > OK
				* CC#13 (Effect Control 2 Coarse) and CC#45 (Effect Control 2 Fine) to Set Range (Interval) of Highest-lowest Frequency > OK
			* Frequency modulation
				* CC#17 (General Purpose Controller 2 Coarse) and CC#49 (General Purpose Controller 2 Fine) to Set Pitch of Sub Frequency > OK
				* CC#18 (General Purpose Controller 3 Coarse) and CC#50 (General Purpose Controller 3 Fine) to Set Amplitude of Sub Frequency > OK
			* Envelope
				* CC#72 to Set Release Time
				* CC#73 to Set Attack Time
				* CC#75 to Set Decay Time
				* CC#79 to Set Sustain Level.
			* Volume by CC#7
			* Tone (Low-pass Filter) by CC#9.
			* Virtual Parallel Input by CC#19, General Purpose Controller 4 (Coarse 0-127, Multiply by 128 for 14-bit Value) > OK
			* All Notes Off, CC#123 (No Affection to Virtual Parallel) > OK
			* Program Change > OK
		* MIDI Channel Select Bit[3:0], GPIO 8-11, Channel 1 (0b0000), Channel 2 (0b0001), 3 (0b0010), 5 (0b0100), 9 (0b1000), 7 (0b0110), and 10 (0b1001) > OK

**January 10, 2020 (#db69ed8)**

* Raspberry Pi Zero V.1.3 (BCM2835), `make type=zero`
	* Function of Input GPIOs Connected with Raspberry Pi Zero W Using [GPIO Push Button](https://github.com/JimmyKenMerchant/Python_Codes), Including Changing Beat (Command 29 and 30) and Clearing Output (Command 31) > OK
	* `user32.c.alpha` > OK
	* `user32.c.beta` > OK
	* PWM Output GPIO 12 (PWM0) and GPIO 13 (PWM1) on `sound=pwm` (Default) Using [Sound System for PWM Output](../schematics/sound_system_pwm.pdf), Including Tuning of D7 for R with Sine Wave (Command 1); and C2, C3, C4, C5, C6, C7, C8, and A4 for L with Sine Wave (Command 3) > OK
	* I2S Output GPIO 18 (BCLK), 19 (LRCLK), and 21 (DOUT) on `sound=i2s` Using UDA1334A, Including Tuning of D7 for R with Sine Wave (Command 1); and C2, C3, C4, C5, C6, C7, C8, and A4 for L with Sine Wave (Command 3) > OK
	* Playing Signal (GPIO 16) at `sound=i2s`: Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
	* Synchronization Clock OUT (GPIO 5) at `sound=i2s`: Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
	* MIDI IN at `sound=i2s`
		* UART Rx (Baud Rate 115200) Directly Connected with UART Tx of Raspberry Pi Zero W, Sending MIDI Data Using [JACK Audio Connection Kit to Serial Interface Bridge](https://github.com/JimmyKenMerchant/Python_Codes) with QjackCtl (Audio I/O Control), a2jmidid (ALSA MIDI to JACK MIDI Bridege), jack-keyboard (Software Keyboard) and Qtractor (MIDI Sequencer)
			* Note On and Off > OK
			* Velocity Change > OK
			* Pitch Bending > OK (Needed to Simplify Process)
			* Modulation (CC#1 for Coarse and CC#33 for Fine) and Changing Its Range (CC#16 for Coarse and CC#48 for Fine, General Purpose Controller 1) > Possible Noise and Mulfunction Because of Floating Base on Changing Range
			* Digital LFO modulation
				* CC#12 (Effect Control 1 Coarse) and CC#44 (Effect Control 1 Fine) to Set Changing Speed (Delta) of Frequency > OK
				* CC#13 (Effect Control 2 Coarse) and CC#45 (Effect Control 2 Fine) to Set Range (Interval) of Highest-lowest Frequency > OK
			* Frequency modulation
				* CC#17 (General Purpose Controller 2 Coarse) and CC#49 (General Purpose Controller 2 Fine) to Set Pitch of Sub Frequency > OK
				* CC#18 (General Purpose Controller 3 Coarse) and CC#50 (General Purpose Controller 3 Fine) to Set Amplitude of Sub Frequency > OK
			* Envelope
				* CC#72 to Set Release Time
				* CC#73 to Set Attack Time
				* CC#75 to Set Decay Time
				* CC#79 to Set Sustain Level.
			* Volume by CC#7
			* Tone (Low-pass Filter) by CC#9.
			* Virtual Parallel Input by CC#19, General Purpose Controller 4 (Coarse 0-127, Multiply by 128 for 14-bit Value) > OK
			* All Notes Off, CC#123 (No Affection to Virtual Parallel) > OK
			* Program Change > OK
		* MIDI Channel Select Bit[3:0], GPIO 8-11, Channel 1 (0b0000), Channel 2 (0b0001), 3 (0b0010), 5 (0b0100), 9 (0b1000), 7 (0b0110), and 10 (0b1001) > OK
