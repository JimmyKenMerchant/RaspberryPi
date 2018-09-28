# Sound Box

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

### Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**Table of Contents**

* [Purpose](#purpose)

* [Output and Input](#output-and-input)

* [Compatibility](#compatibility)

* [MIDI IN](#midi-in)

* [Sound](#sound)

* [Draft](#draft)

## Purpose

* Programmable Sound Generator, Wave Forms Have Been Stored to RAM in Advance with Booting Codes

* Mono Selectable Sound. Sine Wave, Sawtooth Wave, Square Wave, Noise, Triangle Wave, and Distortion Wave

* Flat and Powerful Sound Like Analogue, Tunable Tones

* 4 Steps Volume, Predefined Macros of Music Codes and Scales.

* MIDI IN, Modulation, Pitch Bend

* Output by DMA Control, Low CPU Usage

## Output and Input

* GPIO9 as Input of MIDI Channel Select Bit[0]

* GPIO10 as Input of MIDI Channel Select Bit[1]

* GPIO12 as Output of PWM0 on sound=pwm or sound=pwmb

* GPIO13 as Output of PWM1 on sound=pwm or sound=pwmb, 180 Degrees Phase-shifted from PWM0 if sound=pwmb

* GPIO40 as Output of PWM0 (R of Phone Connector) on sound=jack or sound=jackb

* GPIO45 (GPIO41 on RasPi 3B) as Output of PWM1 (L of Phone Connector) on sound=jack or sound=jackb, 180 Degrees Phase-shifted from PWM0 if sound=jackb

* GPIO16 as Output of Playing Signal

* GPIO20 as Output of GATE Signal Synchronized with MIDI IN (On Note Off Event)

* GPIO17 as Output of Synchronization Clock OUT of Sound Box

* GPIO15 as Input of RXD0 (UART) for MIDI IN

* GPIO27 as Input of Synchronization Clock IN of Sound Box, Connect with Any Synchronization Clock OUT.

* GPIO22-26 as Input of GPIO for Buttons (Up to 3.3V): CAUTION! DON'T MAKE A SHORT CIRCUIT BETWEEN POWER SOURCE AND GROUND. OTHERWISE YOUR RASPBERRY PI WILL BE BROKEN. CHECK OUT GPIO MAP SO CAREFULLY.

* GPIO 18 (BCLK), 19 (LRCLK), and 21 (DOUT) as Output of I2S (as known as 3-wire I2S) on sound=i2s

* HDMI as VIDEO Output (For Debug Only)

* To Test Input of GPIO for Buttons, Use [GPIO Push Button](https://github.com/JimmyKenMerchant/Python_Codes).

* To Test MIDI IN, Use [JACK Audio Connection Kit to Serial Interface Bridge](https://github.com/JimmyKenMerchant/Python_Codes).

### YOU'LL MEET BIG SOUND! PLEASE CARE OF YOUR EARS! I RECOMMEND THAT YOU DON'T USE ANY EARPHONE OR HEADPHONE FOR THIS PROJECT.

### GPIO 22-27 ARE UP TO VOLTAGE OF 3.3V TO INPUT!!! DON'T INPUT VOLTAGE OVER 3.3V TO GPIO PIN!!! OTHERWISE, YOU WILL BE IN DANGER!!! IF YOU CAN'T UNDERSTAND ABOUT THIS, PLEASE STUDY ELECTRONICS FOR A WHILE BEFORE DOING THIS.

![Output Connection of I2S](../images/i2s_1.jpg "(DON'T USE ANY EARPHONE!) Output Connection Between RasPi 2B and UDA1334 on Module: GPIO17 and GPIO27 are connected by a sanguine jumper.")

**About PWM0/1 Output**

* You would see this project can be a digitally controlled oscillator (digital VCO or DCO) of your modular synthesizer. Yes, it can be. But I recognized that the signal level of modular synthesizers are higher (in my research, +-5V, 10Vp-p on Eurorack) than the output of this project. To fit the signal level, I recommend that you use balanced PWM output. This allows you to cancel noise and obtain high voltage (max. 2.6928Vp-p) by connecting two outputs with an Op-amp (positive input to normal output and negative input to inverted output; usage of an Op-amp as a buffer. Use resisters on appropriate points). Plus, amplify the second output by another Op-amp.

* You may consider of possible making of triangle wave and changing duty ratio of square wave. These are possible by external filters. A high-pass filter makes square wave that is changed duty ratio, and a low-pass filter makes triangle wave from square wave (triangle wave is selectable on the latest version).

* By disabling the video signal, the sound signal from the 3.5mm jack may be possible for stable use. Otherwise, the analogue video signal outputs from the 3.5mm jack (on Zero, TV pin) when any HDMI cable is not plugged in. This seems to make possible noise.

* This Project aims its output as line level (appx. -10 dBV, 316mVrms, 894mVp-p and higher). The voltage of the signal from 3.5mm jack seems to be aimed usage as RCA because the 3.5mm jack can output video signal too. If you connect your RasPi with other devices as microphone level, the voltage of the signal is much higher than expected as a microphone. Besides, as line level, the voltage of the signal may be slight lower than expected. However, LR combinational monaural makes high level because typically an Op-amp voltage adder mixes L and R in a monaural receiver (e.g. Mono Aux In).

* The sampling rate is adjusted to 3.1680Khz in A4. This rate varies on each note, depending on snd32/soundadjust.h.

* You can hear noise, this derives from several causes. Audible clock jitter, steps of volume, steps of frequency on pitch bend and modulation, power source, resonance in the circuit caused by static electricity, magnetic energy in the circuit, external radio wave and unexpected antenna in the circuit, etc. Noise directions are normal mode and common mode. I recommend that you use analogue Low-pass filter (Cut off) to intermediate digital output and any input. Balanced PWM output reduces noise from common mode.

**About PCM Output**

* SCLK (System Clock) / MCLK (Master Clock) is not supported because the modern IC on your DAC generates the clock by itself.

* I'm using UDA1334A, one of I2S Stereo DAC. As of July 2018, you can purchase online a module which UDA1334A is boarded on.

* The sampling rate is adjusted to 3.1680Khz in A4. This rate varies on each note, depending on snd32/soundadjust.h.

**Caution on Sound Output**

* You'll meet big sound. Please care of your ears. I recommend that you don't use any earphone or headphone for this project.

* Speaker and other sound outputs are so easy to break if you supply Direct Current to these. Sound outputs are made with considering of supplying Alternating Current. If you apply any sound outputs to GPIO pins directly, it causes to break these your materials.

* Typically, sound outputs made of coils. The coil generate electric surge that breaks your Raspberry Pi. To hide this, there are some solutions. Please search.

* If you want to check the wave by your oscilloscope, a decoupling capacitor is needed. In my experience, a 1-microfarad-capacitor without any attenuator makes the figure of the wave. Besides, if you don't apply any capacitor, pulses of PWM will be directly caught by your oscilloscope and it will breaks the figure of the wave.

* Sound outputs change your RasPi's electrical status. The big problem is the change of the voltage of ground (by means of chassis). This may make black-out/brown-out of your RasPi. If possible and having your skills, you can apply earth wire with the chassis of your RasPi.

## Compatibility

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow sound=i2s` or `make type=zerow sound=pwm`

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b sound=i2s` or `make type=2b sound=pwm` or `make type=2b sound=jack`

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b sound=i2s` or `make type=3b sound=pwm` or `make type=3b sound=jack`

* If you add `b` on the tail of sound parameter such as `sound=i2sb` or `sound=pwmb` or `sound=jackb`, it becomes balanced output. If you select balanced output, R (or PWM0) is HOT, L (or PWM1) is COLD.

* Overall, I don't recommend to use high-spec Raspberry Pis. PWM is analogue output that may affect electrical status on Raspberry Pis. Just Pi Zero (5 dollars Online) may match for this project. There is no need of any radio wave unit.

* I highly recommend that you use `sound=i2s` because of its good sound.

* `sound=pwm` is for specialists who want customized filters.

* I recommend that you use `sound=jack` for debugging. DON'T USE ANY EARPHONE OR HEADPHONE. MAKE SURE TO TURN DOWN SOUND VOLUME OF CONNECTED SPEAKER.

### Make sure to build your own RC Low-pass Filter for PWM0/1 from GPIO Pins.

### Sound outputs generate unpredictable voltage or current. This affects the digital circuit of your Raspberry Pi as resonance, surge, etc. Basically, separation between a digital circuit (in this case, Raspberry Pi) and a analogue circuit (Low-pass Filter, Amplifier, Speaker, etc.) is common sense among hardware developers, otherwise, break or malfunction occurs on your Raspberry Pi.

## MIDI IN

* Sound Box can accept MIDI messages from RXD0 (UART). Caution that the default baud rate in Sound Box is 115200 baud, even though the MIDI standard is 31250. This is because of usage on serial communication with another microcontroller. If you build a MIDI standard interface, uncomment `.equ __MIDIIN, 1` in vector32.s to set baud rate as 31250 baud. To test MIDI IN with another RasPi, use [JACK Audio Connection Kit to Serial Interface Bridge](https://github.com/JimmyKenMerchant/Python_Codes).

* MIDI channel of Sound Box is selectable through MIDI channel select Bit[1:0] (GPIO9 and GPIO10, high means 1, low means 0) and `__MIDI_BASECHANNEL` in vector32.s. The number of MIDI channel is the sum of the value of `__MIDI_BASECHANNEL` and the value of MIDI channel select Bit[1:0] and one: `__MIDI_BASECHANNEL` + MIDI channel select Bit[1:0] + 1.

* Virtual parallel input can be accepted by CC#19 (General Purpose Controller 4). This is useful to control commands in user32.c from MIDI IN, e.g., playing Music code.

## Sound

* Sine Wave (Program 0 in MIDI IN): Scale range is A1 to C7.

* Sawtooth Wave (Program 1 in MIDI IN): Scale range is A1 to C7.

* Square Wave (Program 2 in MIDI IN): Scale range is A1 to C8. High notes are possible.

* Noise (Program 3 in MIDI IN): No Scale (Keys A1 to C6 are used).

* Triangle Wave (Program 4 in MIDI IN): Scale range is A1 to C7.

* Distortion Wave (Program 5 in MIDI IN): Scale range is A1 to C7. Sound colors of notes differ on each power on.

## Draft

**Draft of Description about "DMA Transfer to PWM"**

* We should NOT use DMA with cached region for Control Block (CB) and Source/Destination. Because DMA is not CPU which is made for using with any cache to have quick speed. Note that DMA is a peripheral block which is made for using with physical main memory. This means we may need of any cache operation to Point of Coherency (PoC) to ensure that intended data is stored in physical main memory.

* If you use cache on your system, you need to assign any `shareable` attribute on the cache table to some memory region which is used by DMA. Again, DMA is a peripheral block, but strongly accesses physical main memory. To ensure data you want to transfer by DMA in physical main memory, make sure to set the `shareable` attribute.

* DMA seems to have its own buffer for CB. On the side of DMA, this performs like data cache. If you want to reuse memory space for CB, CB structure will stay the prior state to the intended state ARM intended. To prevent this, you need to make new memory space for CB.

* DMA mainly depends on Peripheral Bus of SoC (e.g. Advanced Peripheral Bus: APB), so long transfer length may cause a issue on PWM, such as noisy wave. To avoid this, we need to consider of length of transfer by DMA. Peripheral Bus is used by a lot of peripheral blocks to access CPU or other blocks, which may have more dominance than DMA.

* See Application Note (AN) 228, "Implementing DMA on ARM SMP Systems" in Application Notes and Tutorial of ARM website. This article describes relationship between DMA and ARM well.

* RasPi is not a tool to source electric current, but to source electric voltage. If you want to make big sound with your RasPi solely, it will make any possible malfunction. Even if you source PWM from any GPIO, the current from the GPIO should be under 1mA. Furthermore, I tested 2K Resister and 10K Resister to attach to GPIO for PWM output as an attenuator. 10K Resister apparently made RasPi stable, but 2K Resister made RasPi take on unpredictable malfunctions, such as stopping the PWM and Video output. PWM output seems to be more sensitive to electric conditions than others.　Any anti-static measure is needed for the properly working.

* To work an amplifier to attach to GPIO for PWM output, you should not use power pins on RasPi. Power pins have noise. Use batteries (two 1.5-Volts batteries are preferred) to work it, but make sure to check polarity of the batteries. Don't power to GND of RasPi.
