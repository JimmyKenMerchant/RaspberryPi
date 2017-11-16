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

**Memorandum of DMA Transfer to PWM **

* DMA mainly depends on Peripheral Bus of SoC (e.g. Advanced Peripheral Bus: APB), so long transfer length may cause a issue on PWM, such as noisy wave. To avoid this, we need to consider of length of transfer by DMA. Peripheral Bus is used by a lot of peripheral blocks to access CPU or other blocks, which may have more dominance than DMA.

* We should NOT use DMA with cached region for Control Block (CB) and Source/Destination. Because DMA is not CPU which is made for using with any cache to have quick speed. Note that DMA is a peripheral block which is made for using with physical main memory. This means we may need of any cache operation to Point of Coherency (PoC) to ensure that intended data is stored in physical main memory.

* If you use cache on your system, you need to assign any `shareable` attribute on the cache table to some memory region which is used by DMA. Again, DMA is a peripheral block, but strongly accesses physical main memory. To ensure data you want to transfer by DMA in physical main memory, make sure to set the `shareable` attribute.

* Don't forget that DMA transfer may be missed by inappropriate voltage. Check its voltage supply. If you watch a lightning mark on the right top corner of your output display. It may cause some odd sound.

* See Application Note (AN) 228, "Implementing DMA on ARM SMP Systems" in Application Notes and Tutorial of ARM website. This article describes relationship between DMA and ARM well.

* DMA watches data cache for the source at first, then if it's invalidated, watch physical main memory. This function is independent from settings of ARM. So on the side of ARM, you need to make sure of storing data to physical main memory, and invalidating cache at all.

* DMA seems to have its own buffer for CB. On the side of DMA, this performs like data cache. If you want to reuse memory space for CB, CB structure will stay the prior state to the intended state ARM intended. To prevent this, you need to make new memory space for CB.

