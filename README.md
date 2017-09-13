# Multi-core Raspberry Pi Baremetal Project

**PURPOSE**

This project is aiming to obtain a conclusion of the software system in Multi-core Raspberry Pi (BCM2836/BCM2837). Purposes of this project are listed below.

1. 32-bit system. 64-bit system is absolutely main stream, but 32-bit system has less memory usage than 64-bit system. This means 32-bit system is economical rather than 64-bit in view of cost, but not evolution of the mobile sector which spends much money from banks. 64-bit system traditionally has a problem of treating heat. CPU has a lot of transistors, so if you want 64-bit than 32-bit, simply 64-bit needs to have transistors twice as much as 32-bit needs. Transistor is source of heat. 32-bit is the good choice for mobile gadgets even now, because of treating heat. Plus, mobile needs to be low voltage to activate, because mobile is typically powered from a battery. Besides, if CPU wants high frequency of its clock, CPU needs high voltage. Because higher frequency loses signals, higher voltage is needed to cover this problem. Or, you need a simple circuit in CPU, to fit high frequency. So there is an ideal 32-bit CPU, which is just 32-bit, is a simple circuit, and has less transistor to fit high frequency. Similarly, 8/16-bit system is the good choice for power-control, such as relays and motors for machines. If you wonder if PIC/AVR, microcontrollers, stay 8/16-bit, and want these 32/64-bit, it's a little odd. PIC/AVR is so simple, and no need of virtualization. Developers can concentrate just controlling motors. This makes less cost to develop than 32/64-bit. By the way, I know 64-bit Programmable Logic Array (PLA). This is just a relay-controller I said it's 8/16-bit above. Why the need of 64-bit? The reason is a need that engineers directly program special language, called "ladder" for controlling relays in factory machines. In view of flexibility on manufacturing, big companies may choose 64-bit PLA, but in view of cost, 8/16-bit system is still the suitable one.

2. None-virtual. PowerPC, build by American dream team (Apple, Motorola, IBM), is a renowned CPU. Once, PowerPC had been a main CPU of Apple, and in 2005, Apple decided to use Intel's CPU, not PowerPC. All of developers blew up, PowerMac became IntelMac, but it was a real in the post-IT-boom when many companies tried to cut their developing cost. PowerPC was a special CPU in early 2000's, because the team was seeking an ideal 64-bit CPU with numerous developing cost. Absolutely, PowerPC had a super special one, Virtualization Acceleration. Since Millennium, Virtual OS has been a very tough keyword in the IT world. Windows in Macintosh, Linux in Windows, or NES in Linux in Windows in Macintosh. Virtual OS by software seems to be in success, and Intel has been added Virtualization Acceleration in its main CPU line. So, virtual one by hardware, we need a lot of logical architecture for it, becomes main stream at last. Because of the story above, I can't say Virtualization Acceleration is a dummy, but we need to know it spends a lot of money to develop more than the need. As a developer, building None-virtual system is risk management. I should say that CPU`s break is from spending a lot of cost without a thought of a bad future.

3. Asynchronous Operations and No Guaranteed for Finishes of Forward Operations. To obtain process speed, CPU implemented several pipelines. The pipeline is just a buffer unit which fetches command and data from main memory. Commands in each pipeline will be executed with data in parallel. This is called as "Superscalar". Pipelines are just like "bucket relay". This has efficiency, because everyone has a bucket, and hands it to the next person. There is no break in bucket relay. Superscaler is aiming this. Plus, this bucket relay is so professional, because these buckets are stored in a warehouse where its entrance is so tiny. In front of the warehouse, only one forklift can work on. If you want efficiency, you need to make parallel bucket ways after this forklift. Every bucket puts on a tag for grouping and on a palette, that is exactly an OPERATION. Groups of buckets by each tag have various quantity sizes. Not to confuse, one tag is on one bucket way. So, even if the first team gets the palette of A buckets group forward, the second team for B buckets group afterward may be finished before A group. There is a asynchronous situation, that is possible misleading of data. To hide this, CPUs are using several methods, implicitly or explicitly. If your CPU is handling this issue implicitly, you are happy because you have no need of thought to this. But mathematically, misleading of data by this issue increases by pursuing better specification of CPU. In ARM architecture, you will use several explicit solutions for this issue as instructions. In case, you will need of put `DSB`, `DMB`, or `ISB` before/after memory accesses, particularly, accessing memory mapped devices or coprocessors (system registers). Manual handling is hard to understand because this makes a daisy chain. To resolve, you may need to make several corrections from some further process.

4. Multi-core Handling, Easily.

5. Difference from Unix.
 
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

2. VideoCore searches the boot media, then loads bootcode.bin to the special memory and runs it.

3. VideoCore activates ARM Processor and other peripherals including Main Memory. On this time, VideCore loads start.elf to Main Memory for ARM Processor (VideoCore is accessible from ARM through Mailbox afterward).

4. ARM Processor runs start.elf to initialize itself, and check config.txt.

5. start.elf sets several configurations from config.txt. In default, several configurations, like the framebuffer and the physical memory, are recorded on ATAGs from Address 0x100.

6. start.elf starts kernel.img.

**LICENSE**

Copyright 2017 Kenta Ishii

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

**LINKS**

* [Official Documentation of RasPi](https://www.raspberrypi.org/documentation/hardware/raspberrypi/)

* [Official RasPi Usage](https://www.raspberrypi.org/documentation/usage/)

* [Baking Pi](https://www.cl.cam.ac.uk/projects/raspberrypi/tutorials/os/)

* [PiFox](https://github.com/ICTeam28/PiFox)

* [Rasberry Pi Firmware](https://github.com/raspberrypi/firmware/tree/master/boot)

* [Mailboxes](https://github.com/raspberrypi/firmware/wiki/Mailboxes)

* [VideoCore IV](https://github.com/hermanhermitage/videocoreiv): NON-COMMERCIAL USE ONLY

* [ARM Information Center](http://infocenter.arm.com/)

* [JimmyKenMerchant](http://electronics.jimmykenmerchant.com/)
