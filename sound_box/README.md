# Sound BOX

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

## Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**Output/Input**

* GPIO12 as Output of PWM0 on sound=pwm

* GPIO13 as Output of PWM1 on sound=pwm, 180 Degrees Phase-shifted from PWM0

* GPIO40 as Output of PWM0 on sound=jack

* GPIO45 (GPIO41 on RasPi 3B) as Output of PWM1 on sound=jack, 180 Degrees Phase-shifted from PWM0

* GPIO17 as Output of Synchronization Clock OUT of Sound Box

* GPIO27 as Input of Synchronization Clock IN of Sound Box, Connect with Any Synchronization Clock OUT.

* GPIO22-26 as Input of GPIO for Buttons (Up to 3.3V): CAUTION! DON'T MAKE A SHORT CIRCUIT BETWEEN POWER SOURCE AND GROUND. OTHERWISE YOUR RASPBERRY PI WILL BE BROKEN. CHECK OUT GPIO MAP SO CAREFULLY.

* GPIO 18 (BCLK), 19 (LRCLK), and 21 (DOUT) as Output of I2S (as known as 3-wire I2S) on sound=i2s

* HDMI as VIDEO Output (For Debug Only)

## GPIO 22-27 ARE UP TO VOLTAGE OF 3.3V TO INPUT!!! DON'T INPUT VOLTAGE OVER 3.3V TO GPIO PIN!!! OTHERWISE, YOU WILL BE IN DANGER!!! IF YOU CAN'T UNDERSTAND ABOUT THIS, PLEASE STUDY ELECTRONICS FOR A WHILE BEFORE DOING THIS.

**About PWM0/1 Output** 

* From PWM1, the sound that is phase-shifted from PWM0 outputs. This aims for balanced monoral.

* By disabling video signal, the output from the 3.5mm jack may be possible for stable use.

* The line level of 3.5mm jack is not tested. It seems to be so high. Absolutely, don't use your earphones for safety of your ears.

* The sample rate is 3.2Khz, so A4 Becomes 444.4Hz with no jitter.

**About PCM Output**

* The sampling rate is adjusted to 3.1680Khz for fitting A4 to 440Hz as opposed to the PWM0/1 output.

* This sampling rate has jitter. Your DAC is needed its jitter remover.

* SCLK (System Clock) / MCLK (Master Clock) is not supported because modern ICs on your DAC generates the clock by itself.

**Compatibility**

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow sound=i2s` or `make type=zerow sound=pwm`

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b sound=i2s` or `make type=2b sound=pwm` or `make type=2b sound=jack`

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b sound=i2s` or `make type=3b sound=pwm` or `make type=3b sound=jack`

* Overall, I don't recommend to use high-spec Raspberry Pis. PWM is analogue output that may affect electrical status on Raspberry Pis. Just Pi Zero (5 dollars Online) may match for this project. There is no need of any radio wave unit.

## Make sure to build your own RC Low-pass Filter for PWM0/1 from GPIO Pins.

## Sound outputs generate unpredictable voltage or current. This affects the digital circuit of your Raspberry Pi as resonance, surge, etc. Basically, separation between a digital circuit (in this case, Raspberry Pi) and a analogue circuit (Low-pass Filter, Amplifier, Speaker, etc.) is common sense among hardware developers, otherwise, break or malfunction occurs on your Raspberry Pi.

**Caution on Sound Output**

* You'll meet big sound. Please care of your ears. I recommend that you don't use any earphone for this project.

* Speaker and other sound outputs are so easy to break if you supply Direct Current to these. Sound outputs are made with considering of supplying Alternating Current. If you apply any sound outputs to GPIO pins directly, it causes to break these your materials. 

* Typically, sound outputs made of coils. The coil generate electric surge that breaks your Raspberry Pi. To hide this, there are some solutions. Please search.

* If you want to check the wave by your oscilloscope, a decoupling capacitor is needed. In my experience, a 1-microfarad-capacitor without any attenuator makes the figure of the wave. Besides, if you don't apply any capacitor, pulses of PWM will be directly caught by your oscilloscope and it will breaks the figure of the wave.

**Draft of Description about "DMA Transfer to PWM"**

* We should NOT use DMA with cached region for Control Block (CB) and Source/Destination. Because DMA is not CPU which is made for using with any cache to have quick speed. Note that DMA is a peripheral block which is made for using with physical main memory. This means we may need of any cache operation to Point of Coherency (PoC) to ensure that intended data is stored in physical main memory.

* If you use cache on your system, you need to assign any `shareable` attribute on the cache table to some memory region which is used by DMA. Again, DMA is a peripheral block, but strongly accesses physical main memory. To ensure data you want to transfer by DMA in physical main memory, make sure to set the `shareable` attribute.

* DMA seems to have its own buffer for CB. On the side of DMA, this performs like data cache. If you want to reuse memory space for CB, CB structure will stay the prior state to the intended state ARM intended. To prevent this, you need to make new memory space for CB.

* DMA mainly depends on Peripheral Bus of SoC (e.g. Advanced Peripheral Bus: APB), so long transfer length may cause a issue on PWM, such as noisy wave. To avoid this, we need to consider of length of transfer by DMA. Peripheral Bus is used by a lot of peripheral blocks to access CPU or other blocks, which may have more dominance than DMA.

* See Application Note (AN) 228, "Implementing DMA on ARM SMP Systems" in Application Notes and Tutorial of ARM website. This article describes relationship between DMA and ARM well.

* RasPi is not a tool to source electric current, but to source electric voltage. If you want to make big sound with your RasPi solely, it will make any possible malfunction. Even if you source PWM from any GPIO, the current from the GPIO should be under 1mA. Furthermore, I tested 2K Resister and 10K Resister to attach to GPIO for PWM output as an attenuator. 10K Resister apparently made RasPi stable, but 2K Resister made RasPi take on unpredictable malfunctions, such as stopping the PWM and Video output. PWM output seems to be more sensitive to electric conditions than others.　Any anti-static measure is needed for the properly working.

* To work an amplifier to attach to GPIO for PWM output, you should not use power pins on RasPi. Power pins have noise. Use batteries (two 1.5-Volts batteries are preferred) to work it, but make sure to check polarity of the batteries. Don't power to GND of RasPi. 
