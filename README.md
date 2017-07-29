# Multi-core Raspberry Pi Baremetal Project

**INDEX**

* [10Hz blinker on Hyp mode](https://github.com/JimmyKenMerchant/RaspberryPi/tree/master/10herts_blinker_hyp)

* [10Hz blinker on Hyp mode (Simple Version)](https://github.com/JimmyKenMerchant/RaspberryPi/tree/master/10herts_blinker_simple)

* [Framebuffer Test](https://github.com/JimmyKenMerchant/RaspberryPi/tree/master/framebuffer_test)

**INSTALL**

* On Raspbian Command Line (Linux Bash)

e.g. To get kernel.img of 10Hz blinker on Hyp mode
```
cd ~/Desktop
git clone https://github.com/JimmyKenMerchant/RaspberryPi.git
cd RaspberryPi/10herts_blinker_hyp
make
```
config.txt in assets folder is used with each kernel.img.
You need to paste these config.txt and kernel.img to the root directory of your boot media (e.g. FAT32 formatted SD Card).
You also need to get latest start.elf and bootcode.bin from RasPi Official Repository, and paste these to the root directory of your boot media.

The file name, "kernel.img", is for original ARMv6 Raspberry Pi. Besides, "kernel7.img" is for ARMv7 Raspberry Pi and later ("kernel8.img" may be for ARMv8 AArch64, but not yet). But, I experienced that "kernel.img" can run on ARMv7 Raspberry Pi.

**Boot Process of Raspberry Pi (Including My Hypothesis)**

1. Power on, then VideoCore runs the first boot code on EEPROM embedded in RasPi like a microcontroller.

2. VideoCore searches the boot media, then loads bootcode.bin to the memory (L2?) and runs it.

3. VideoCore activates ARM Processor and other peripherals including Main Memory. On this time, VideCore loads start.elf to Main Memory for ARM Processor? (accessible through Mailbox afterward).

4. ARM Processor runs start.elf to initialize itself, and check config.txt and cmdline.txt.

5. start.elf sets several configurations from config.txt and cmdline.txt. In default, several configurations, like the framebuffer and the physical memory, are recorded on ATAGs from Address 0x100.

6. start.elf starts kernel.img.

**LICENSE**

Copyright 2017 Kenta Ishii

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

**LINKS**

* [Baking Pi](https://www.cl.cam.ac.uk/projects/raspberrypi/tutorials/os/)

* [PiFox](https://github.com/ICTeam28/PiFox)

* [Rasberry Pi Firmware](https://github.com/raspberrypi/firmware/tree/master/boot)

* [Mailboxes](https://github.com/raspberrypi/firmware/wiki/Mailboxes): 6 words per Mailbox, I mean.

* [VideoCore IV](https://github.com/hermanhermitage/videocoreiv): NON-COMMERCIAL USE ONLY

* [JimmyKenMerchant](http://electronics.jimmykenmerchant.com/)
