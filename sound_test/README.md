# Sound Test

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

## Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**Output/Input**

* GPIO12 as Output of PWM0

* GPIO13 as Output of PWM1

* GPIO20-27 as Input of GPIO for Buttons (Up to 3.3V)

* HDMI as VIDEO Output

## GPIO 20-27 ARE UP TO VOLTAGE OF 3.3V TO INPUT!!! DON'T INPUT VOLTAGE OVER 3.3V TO GPIO PIN!!! OTHERWISE, YOU WILL BE IN DANGER!!! IF YOU CAN'T UNDERSTAND ABOUT THIS, PLEASE STUDY ELECTRONICS FOR A WHILE BEFORE DOING THIS.

## Don't use a minijack on Raspberry Pi as a sound output on this project, because an analogue circuit affects a digital circuit, and vice versa. The minijack does not assume usage on this project. This affection causes possible break of your Raspberry Pi.

**Compatibility**

* (Not Recommended) Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`

* (Not Recommended) Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`

* (Not Recommended) Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b`

## Make sure to build your own RC Low-pass Filter.

## Sound outputs generate unpredictable voltage or current. This affects the digital circuit of your Raspberry Pi as resonance, surge, etc. Basically, separation between a digital circuit (in this case, Raspberry Pi) and a analogue circuit (Low-pass Filter, Amplifier, Speaker, etc.) is common sense among hardware developers, otherwise, break or malfunction occurs on your Raspberry Pi.

**Caution on Sound Output**

* You'll meet big sound. Please care of your ears. I recommend that you don't use any earphone for this project.

* Speaker and other sound outputs are so easy to break if you supply Direct Current to these. Sound outputs are made with considering of supplying Alternating Current. If you apply any sound outputs to GPIO pins directly, it causes to break these your materials. 

* Typically, sound outputs made of coils. The coil generate electric surge that breaks your Raspberry Pi. To hide this, there are some solutions. Please search.

**Draft of Description about "DMA Transfer to PWM" **

* We should NOT use DMA with cached region for Control Block (CB) and Source/Destination. Because DMA is not CPU which is made for using with any cache to have quick speed. Note that DMA is a peripheral block which is made for using with physical main memory. This means we may need of any cache operation to Point of Coherency (PoC) to ensure that intended data is stored in physical main memory.

* If you use cache on your system, you need to assign any `shareable` attribute on the cache table to some memory region which is used by DMA. Again, DMA is a peripheral block, but strongly accesses physical main memory. To ensure data you want to transfer by DMA in physical main memory, make sure to set the `shareable` attribute.

* DMA seems to have its own buffer for CB. On the side of DMA, this performs like data cache. If you want to reuse memory space for CB, CB structure will stay the prior state to the intended state ARM intended. To prevent this, you need to make new memory space for CB.

* DMA mainly depends on Peripheral Bus of SoC (e.g. Advanced Peripheral Bus: APB), so long transfer length may cause a issue on PWM, such as noisy wave. To avoid this, we need to consider of length of transfer by DMA. Peripheral Bus is used by a lot of peripheral blocks to access CPU or other blocks, which may have more dominance than DMA.

* See Application Note (AN) 228, "Implementing DMA on ARM SMP Systems" in Application Notes and Tutorial of ARM website. This article describes relationship between DMA and ARM well.
