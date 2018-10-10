# Synthesizer

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

### Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**Table of Contents**

* [Purpose](#purpose)

* [Output and Input](#output-and-input)

* [Compatibility](#compatibility)

* [MIDI IN](#midi-in)

* [Synthesizer Pre-code](#synthesizer-pre-code)

## Purpose

* Programmable Synthesizer, MIDI IN Acceptable

* Polyphonic Up to 8 Voices

* Multipurpose, Drum Machine to Music Sequencer

* Programmable Drum Machine / Music Sequencer Time Up to 29 Minutes with Two Voices for Entire Tracks

* Two Types of Synthesis, Digital LFO Modulation and Frequency Modulation

## Output and Input

* GPIO9 as Input of MIDI Channel Select Bit[0]

* GPIO10 as Input of MIDI Channel Select Bit[1]

* GPIO12 as Output of PWM0 on sound=pwm

* GPIO13 as Output of PWM1 on sound=pwm

* GPIO40 as Output of PWM0 on sound=jack

* GPIO45 (GPIO41 on RasPi 3B) as Output of PWM1 on sound=jack

* GPIO16 as Output of Playing Signal

* GPIO5 as Output of Synchronization Clock OUT

* GPIO15 as Input of RXD0 (UART) for MIDI IN

* GPIO6 as Input of Synchronization Clock IN, Connect with Any Synchronization Clock OUT.

* GPIO22-26 as Input of GPIO for Buttons (Up to 3.3V): CAUTION! DON'T MAKE A SHORT CIRCUIT BETWEEN POWER SOURCE AND GROUND. OTHERWISE YOUR RASPBERRY PI WILL BE BROKEN. CHECK OUT GPIO MAP SO CAREFULLY.

* GPIO 18 (BCLK), 19 (LRCLK), and 21 (DOUT) as Output of I2S (as known as 3-wire I2S) on sound=i2s

* HDMI as VIDEO Output (For Debug Only)

* To Test Input, Use [GPIO Push Button](https://github.com/JimmyKenMerchant/Python_Codes).

### GPIO 22-27 ARE UP TO VOLTAGE OF 3.3V TO INPUT!!! DON'T INPUT VOLTAGE OVER 3.3V TO GPIO PIN!!! OTHERWISE, YOU WILL BE IN DANGER!!! IF YOU CAN'T UNDERSTAND ABOUT THIS, PLEASE STUDY ELECTRONICS FOR A WHILE BEFORE DOING THIS.

![Output Connection of I2S (There Are Differences on New Version)](../images/i2s_1.jpg "(DON'T USE ANY EARPHONE!) Output Connection Between RasPi 2B and UDA1334 on Module: GPIO17 and GPIO27 are connected by a sanguine jumper.")

**About PCM Output**

* PCM outputs L and R with each 16-bit depth. DACs' maximum Vrms are 900m to 2100m in my experience, besides line level is appx. -10 dBV, 316mVrms, 894mVp-p.

* This sampling rate has jitter. Your DAC is needed its jitter remover.

* SCLK (System Clock) / MCLK (Master Clock) is not supported because the modern IC on your DAC generates the clock by itself.

* I'm using UDA1334A, one of I2S Stereo DAC. As of July 2018, you can purchase online a module which UDA1334A is boarded on.

**Caution on Sound Output**

* You'll meet big sound. Please care of your ears. I recommend that you don't use any earphone or headphone for this project.

* Speaker and other sound outputs are so easy to break if you supply Direct Current to these. Sound outputs are made with considering of supplying Alternating Current. If you apply any sound outputs to GPIO pins directly, it causes to break these your materials.

* Typically, sound outputs made of coils. The coil generate electric surge that breaks your Raspberry Pi. To hide this, there are some solutions. Please search.

* If you want to check the outputting wave by your oscilloscope, a decoupling capacitor (or a low-pass filter) is needed. In my experience, a 1-microfarad-capacitor makes the figure of the wave. Besides, if you don't apply any capacitor, pulses of PWM will be directly caught by your oscilloscope and it will breaks the figure of the wave.

* Sound outputs change your RasPi's electrical status. The big problem is the change of the voltage of ground (by means of chassis). This may make black-out/brown-out of your RasPi. If possible and having your skills, you can apply earth wire with the chassis of your RasPi.

* When you input from PCM or PWM output directly, you can hear buggy high tone noise (appx. 2KHz) such as bass and high tones. It's harmonics. I recommend that you use analogue Low-pass filter (Cut Off) to intermediate digital output and any input. Digital output has high frequency noise that hold harmonics bigger than anologue output. This seems to derive from steps of changing volume or pulses of a digital-analogue converter. It sometimes takes pre-sound state that is not natural to be heard.

## Compatibility

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow sound=i2s` or `make type=zerow sound=pwm`

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b sound=i2s` or `make type=2b sound=pwm` or `make type=2b sound=jack`

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b sound=i2s` or `make type=3b sound=pwm` or `make type=3b sound=jack`

* I highly recommend that you use `sound=i2s` because of its good sound.

* `sound=pwm` is for specialists who wants customized filters.

* I recommend that you use `sound=jack` for debugging. DON'T USE ANY EARPHONE OR HEADPHONE. MAKE SURE TO TURN DOWN SOUND VOLUME OF CONNECTED SPEAKER.

### Make sure to build your own RC Low-pass Filter for PWM0/1 from GPIO Pins.

### Sound outputs generate unpredictable voltage or current. This affects the digital circuit of your Raspberry Pi as resonance, surge, etc. Basically, separation between a digital circuit (in this case, Raspberry Pi) and a analogue circuit (Low-pass Filter, Amplifier, Speaker, etc.) is common sense among hardware developers, otherwise, break or malfunction occurs on your Raspberry Pi.

## MIDI IN

* Synthesizer can accept MIDI messages from RXD0 (UART). Caution that the default baud rate in Sound Box is 115200 baud, even though the MIDI standard is 31250. This is because of usage on serial communication with another microcontroller. If you build a MIDI standard interface, uncomment `.equ __MIDIIN, 1` in vector32.s to set baud rate as 31250 baud. To test MIDI IN with another RasPi, use [JACK Audio Connection Kit to Serial Interface Bridge](https://github.com/JimmyKenMerchant/Python_Codes).

* MIDI channel of Synthesizer is selectable through MIDI channel select Bit[1:0] (GPIO9 and GPIO10, high means 1, low means 0) and `__MIDI_BASECHANNEL` in vector32.s. The number of MIDI channel is the sum of the value of `__MIDI_BASECHANNEL` and the value of MIDI channel select Bit[1:0] and one: `__MIDI_BASECHANNEL` + MIDI channel select Bit[1:0] + 1.

* Virtual parallel input can be accepted by CC#19 (General Purpose Controller 4). This is useful to control commands in user32.c from MIDI IN, e.g., playing a sequence of Synthesizer codes.

* Note on / Note off is acceptable and polyphonic up to 8 voices, playing a sequence of Synthesizer codes subtracts voices to use.

* Pitch bend is acceptable.

* There are two types of synthesis, digital modulation and frequency modulation.
	* Digital LFO modulation is in fact low-frequency oscillator. This modulation is under a chaotic complex nonlinear system, so you sets high changing speed (delta) of frequency, the sound becomes noise. This modulation is made from frequently changing a variable value, which effects the result complexly, in the function which makes sound waves. CC#1 (Modulation Coarse) and CC#33 (Modulation Fine) sets changing speed (delta) of frequency, and CC#16 (General Purpose Controller 1 Coarse) and CC#48 (General Purpose Controller 1 Fine) sets range (interval) of highest-lowest frequency.
	* Frequency modulation is implemented. CC#17 (General Purpose Controller 2 Coarse) and CC#49 (General Purpose Controller 2 Fine) sets the pitch of the sub frequency. CC#18 (General Purpose Controller 3 Coarse) and CC#50 (General Purpose Controller 3 Fine) sets the amplitude of the sub frequency.

* Envelope is changeable.
	* CC#72 sets release time. 64 is the default value.
	* CC#73 sets attack time. 64 is the default value.
	* CC#75 sets decay time. 64 is the default value.
	* CC#79 sets sustain level. 127 is the default value (100% sustain).

* Volume is changeable thorough CC#7.

## Synthesizer Pre-code

* Other than MIDI IN, there is unique programmable codes, called "Synthesizer Code". To decode this, "Synthesizer Pre-code" helps you.