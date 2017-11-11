# Sound Test

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

**Output/Input**

* GPIO12 as Output of PWM0, Caution! There is No RC Filter Like Minijack

* GPIO13 as Output of PWM1, Caution! There is No RC Filter Like Minijack

* GPIO40 (3.5mm Minijack) as Output of PWM0 (Except Zero, Zero W)

* GPIO45 (3.5mm Minijack) as Output of PWM1 (Except Zero, Zero W)

* HDMI as VIDEO Output

**Compatibility**

UNDER CONSTRUCTION!! PLEASE WAIT FOR...

## Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**DMA Transfer to PWM **

* DMA depends on Peripheral Bus of SoC (e.g. Advanced Peripheral Bus: APB), so long transfer length may cause a issue on PWM, such as noisy wave. To avoid this, we need to consider of length of transfer by DMA. Peripheral Bus is used by a lot of peripheral blocks to access CPU or other blocks, which may have more dominance than DMA.

* We should NOT use DMA with non-cache region on Control Block (CB) and Source/Destination. Because DMA is not CPU which is made for using with any cache to have speed. Note that DMA is a peripheral block which is made for using with physical memory. This means we may need of any cache operation to Point of Coherency (PoC) to ensure that intended data is stored in physical memory.

* If you use cache on your system, you need to assign any `shareable` attribute on the cache table to memory region which is used by DMA. DMA is a peripheral block, but strongly access physical memory. To ensure data you want to transfer by DMA in physical memory, make sure to set the `shareable` attribute.
