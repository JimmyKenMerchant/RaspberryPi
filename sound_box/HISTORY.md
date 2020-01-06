## Compatibility Test

* Hash number on the next of the date indicates the last commit that changed anything except "HISTORY.txt" and "README.md" in any project.

* Tools to be used with each test are described at Technical Notes in "share/aloha_raspi/README.txt". If there is any exception, the detail is described along with the name of models.

* Items of the test are described if the project uses multiple abilities of the system.

* The length of time to be spent for each test may be described because the length affects reliability of the test.

* For validity, describing the environment for the test is helpful, e.g., ambient temperature, place, more details of tools, etc.

**January 6, 2020 (#db69ed8)**

* Raspberry Pi Zero V.1.3 (BCM2835), `make type=zero`
	* MIDI IN at `sound=pwm` (Default)
		* UART Rx (Baud Rate 115200) Directly Connected with UART Tx of Raspberry Pi Zero W, Sending MIDI Data Using [JACK Audio Connection Kit to Serial Interface Bridge](https://github.com/JimmyKenMerchant/Python_Codes) with QjackCtl (Audio I/O Control), a2jmidid (ALSA MIDI to JACK MIDI Bridege), jack-keyboard (Software Keyboard) and Qtractor (MIDI Sequencer)
			* Output of GATE Signal Synchronized with MIDI IN (Note On Event), GPIO20: Connected with 3mm Red LED and 10K ohms resister to limit current. > OK

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`
	* Function of Input GPIOs Connected with Raspberry Pi Zero Using [GPIO Push Button](https://github.com/JimmyKenMerchant/Python_Codes), Including Changing Beat (Command 29 and 30) and Clearing Output (Command 31) > OK
	* Modulation (Command 10) > OK
	* PWM Output GPIO 12 (PWM0) and GPIO 13 (PWM1) on `sound=pwm` (Default) Using [Sound System for PWM Output](../schematics/sound_system_pwm.pdf), Including Tuning of E4 with Triangle Wave (Command 5) > OK
	* Balanced PWM Output GPIO 12 (PWM0) and GPIO 13 (PWM1) on `sound=pwmb` Mixed after [Sound System for PWM Output](../schematics/sound_system_pwm.pdf), Including Tuning of E4 with Triangle Wave (Command 5) > OK (Second Harmonic on Non-balanced Mixing Because of Non-linearity of Transistor)
	* I2S Output GPIO 18 (BCLK), 19 (LRCLK), and 21 (DOUT) on `sound=i2s` Using UDA1334A, Including Tuning of E4 with Triangle Wave (Command 5) > OK
	* Balanced I2S Output GPIO 18 (BCLK), 19 (LRCLK), and 21 (DOUT) on `sound=i2sb` Using UDA1334A, Including Tuning of E4 with Triangle Wave (Command 5) and Confirmation of Counteraction by USB Mono Microphone Input with Recording by Audacity > OK
	* Playing Signal (GPIO 16) at `sound=i2s`: Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
	* Synchronization Clock OUT (GPIO 17) at `sound=i2s`: Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
	* MIDI IN at `sound=i2s`
		* UART Rx (Baud Rate 115200) Directly Connected with UART Tx of Raspberry Pi Zero W, Sending MIDI Data Using [JACK Audio Connection Kit to Serial Interface Bridge](https://github.com/JimmyKenMerchant/Python_Codes) with QjackCtl (Audio I/O Control), a2jmidid (ALSA MIDI to JACK MIDI Bridege), jack-keyboard (Software Keyboard) and Qtractor (MIDI Sequencer)
			* Note On and Off > OK
			* Velocity Change > OK
			* Pitch Bending > Noise on Note Off Because of Null Value (0xFFFF) at SND32_CURRENTCODE
			* Modulation (CC#1) and Changing Its Range (CC#16, General Purpose Controller 1) > OK (Popping Noise on Changing Note)
			* Virtual Parallel Input by CC#19, General Purpose Controller 4 (Coarse 0-127, Multiply by 128 for 14-bit Value) > OK
			* All Notes Off, CC#123 (No Affection to Virtual Parallel) > OK
			* Program Change
				* Sine Wave (Program 0) > OK
				* Sawtooth Wave (Program 1) > OK
				* Square Wave (Program 2) > OK
				* Noise (Program 3) > OK
				* Triangle Wave (Program 4) > OK
				* Distortion Wave (Program 5) > OK
		* MIDI Channel Select Bit[3:0], GPIO 8-11, Channel 0 (0b0000), Channel 2 (0b0001), 3 (0b0010), 5 (0b0100), 9 (0b1000), 7 (0b0110), and 10 (0b1001) > OK

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`
	* MIDI IN at `sound=i2s`
		* UART Rx (Baud Rate 115200) Directly Connected with UART Tx of Raspberry Pi Zero W, Sending MIDI Data Using [JACK Audio Connection Kit to Serial Interface Bridge](https://github.com/JimmyKenMerchant/Python_Codes) with QjackCtl (Audio I/O Control), a2jmidid (ALSA MIDI to JACK MIDI Bridege), jack-keyboard (Software Keyboard) and Qtractor (MIDI Sequencer)
			* Output of GATE Signal Synchronized with MIDI IN (Note On Event), GPIO20: Connected with 3mm Red LED and 10K ohms resister to limit current. > OK

**January 4, 2020 (#db69ed8)**

* Raspberry Pi Zero V.1.3 (BCM2835), `make type=zero`
	* Function of Input GPIOs Connected with Raspberry Pi Zero W Using [GPIO Push Button](https://github.com/JimmyKenMerchant/Python_Codes), Including Changing Beat (Command 29 and 30) and Clearing Output (Command 31) > OK
	* Modulation (Command 10) > OK
	* PWM Output GPIO 12 (PWM0) and GPIO 13 (PWM1) on `sound=pwm` (Default) Using [Sound System for PWM Output](../schematics/sound_system_pwm.pdf), Including Tuning of E4 with Triangle Wave (Command 5) > OK
	* Balanced PWM Output GPIO 12 (PWM0) and GPIO 13 (PWM1) on `sound=pwmb` Mixed after [Sound System for PWM Output](../schematics/sound_system_pwm.pdf), Including Tuning of E4 with Triangle Wave (Command 5) > OK (Second Harmonic on Non-balanced Mixing Because of Non-linearity of Transistor)
	* I2S Output GPIO 18 (BCLK), 19 (LRCLK), and 21 (DOUT) on `sound=i2s` Using UDA1334A, Including Tuning of E4 with Triangle Wave (Command 5) > OK
	* Balanced I2S Output GPIO 18 (BCLK), 19 (LRCLK), and 21 (DOUT) on `sound=i2sb` Using UDA1334A, Including Tuning of E4 with Triangle Wave (Command 5) and Confirmation of Counteraction by USB Mono Microphone Input with Recording by Audacity > OK
	* Playing Signal (GPIO 16) at `sound=i2s`: Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
	* Synchronization Clock OUT (GPIO 17) at `sound=i2s`: Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
	* MIDI IN at `sound=pwm` (Default)
		* UART Rx (Baud Rate 115200) Directly Connected with UART Tx of Raspberry Pi Zero W, Sending MIDI Data Using [JACK Audio Connection Kit to Serial Interface Bridge](https://github.com/JimmyKenMerchant/Python_Codes) with QjackCtl (Audio I/O Control), a2jmidid (ALSA MIDI to JACK MIDI Bridege), jack-keyboard (Software Keyboard) and Qtractor (MIDI Sequencer)
			* Note On and Off > OK
			* Velocity Change > OK
			* Pitch Bending > Popping Noise on Note Off Because of Making Modulation Range Despite of Note Off
			* Modulation (CC#1) and Changing Its Range (CC#16, General Purpose Controller 1) > OK
			* Virtual Parallel Input by CC#19, General Purpose Controller 4 (Coarse 0-127, Multiply by 128 for 14-bit Value) > OK
			* All Notes Off, CC#123 (No Affection to Virtual Parallel) > OK
			* Program Change
				* Sine Wave (Program 0) > OK
				* Sawtooth Wave (Program 1) > OK
				* Square Wave (Program 2) > OK
				* Noise (Program 3) > OK
				* Triangle Wave (Program 4) > OK
				* Distortion Wave (Program 5) > OK
		* MIDI Channel Select Bit[3:0], GPIO 8-11, Channel 0 (0b0000), Channel 2 (0b0001), 3 (0b0010), 5 (0b0100), 9 (0b1000), 7 (0b0110), and 10 (0b1001) > OK

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`
	* Function of Input GPIOs Connected with Raspberry Pi Zero W Using [GPIO Push Button](https://github.com/JimmyKenMerchant/Python_Codes), Including Changing Beat (Command 29 and 30) and Clearing Output (Command 31) > OK
	* Modulation (Command 10) > OK
	* PWM Output GPIO 12 (PWM0) and GPIO 13 (PWM1) on `sound=pwm` (Default) Using [Sound System for PWM Output](../schematics/sound_system_pwm.pdf), Including Tuning of E4 with Triangle Wave (Command 5) > OK
	* Balanced PWM Output GPIO 12 (PWM0) and GPIO 13 (PWM1) on `sound=pwmb` Mixed after [Sound System for PWM Output](../schematics/sound_system_pwm.pdf), Including Tuning of E4 with Triangle Wave (Command 5) > OK (Second Harmonic on Non-balanced Mixing Because of Non-linearity of Transistor)
	* PWM Output GPIO 40 (PWM0) and GPIO 45 (PWM1) on `sound=jack`, Including Tuning of E4 with Triangle Wave (Command 5) > OK
	* Balanced PWM Output GPIO 40 (PWM0) and GPIO 45 (PWM1) on `sound=jackb`, Including Tuning of E4 with Triangle Wave (Command 5) and Confirmation of Counteraction by USB Mono Microphone Input with Recording by Audacity > OK
	* I2S Output GPIO 18 (BCLK), 19 (LRCLK), and 21 (DOUT) on `sound=i2s` Using UDA1334A, Including Tuning of E4 with Triangle Wave (Command 5) > OK
	* Balanced I2S Output GPIO 18 (BCLK), 19 (LRCLK), and 21 (DOUT) on `sound=i2sb` Using UDA1334A, Including Tuning of E4 with Triangle Wave (Command 5) and Confirmation of Counteraction by USB Mono Microphone Input with Recording by Audacity > OK
	* Playing Signal (GPIO 16) at `sound=jackb` and `sound=i2s`: Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
	* Synchronization Clock OUT (GPIO 17) at `sound=jackb` and `sound=i2s`: Connected with 3mm Red LED and 10K ohms resister to limit current. > OK
	* MIDI IN at `sound=i2s`
		* UART Rx (Baud Rate 115200) Directly Connected with UART Tx of Raspberry Pi Zero W, Sending MIDI Data Using [JACK Audio Connection Kit to Serial Interface Bridge](https://github.com/JimmyKenMerchant/Python_Codes) with QjackCtl (Audio I/O Control), a2jmidid (ALSA MIDI to JACK MIDI Bridege), jack-keyboard (Software Keyboard) and Qtractor (MIDI Sequencer)
			* Note On and Off > OK
			* Velocity Change > OK
			* Pitch Bending > Noise on Note Off Because of Null Value (0xFFFF) at SND32_CURRENTCODE
			* Modulation (CC#1) and Changing Its Range (CC#16, General Purpose Controller 1) > OK (Popping Noise on Changing Note)
			* Virtual Parallel Input by CC#19, General Purpose Controller 4 (Coarse 0-127, Multiply by 128 for 14-bit Value) > OK
			* All Notes Off, CC#123 (No Affection to Virtual Parallel) > OK
			* Program Change
				* Sine Wave (Program 0) > OK
				* Sawtooth Wave (Program 1) > OK
				* Square Wave (Program 2) > OK
				* Noise (Program 3) > OK
				* Triangle Wave (Program 4) > OK
				* Distortion Wave (Program 5) > OK
		* MIDI Channel Select Bit[3:0], GPIO 8-11, Channel 0 (0b0000), Channel 2 (0b0001), 3 (0b0010), 5 (0b0100), 9 (0b1000), 7 (0b0110), and 10 (0b1001) > OK
