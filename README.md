# Raspberry Pi System Project Based on Minimalism 

**PURPOSE**

This project is aiming to obtain a conclusion of the software system. Purposes of this project are listed below. I call the sofware system, "Aloha Operating System".

1. To obtain topics on electronics for the future.
	* We are currently (December 25, 2017) facing an odd situation on electronics. It seems that we bit the future of electronics too much. The future, Artificial Intelligence (AI), Augmented Reality (AR), Working Robot, is now on business actually. It's just a real, but we need to get more technological innovations to come true. We are suffering a traffic jam on Internet. The word, Net neutrality, is on trend. This reserves fair treatment of any data, even if it's not for video. According to Cisco (2017), in 2016, Internet video used 73 percents of Internet traffic. Remember, Internet is not only for video. In spite of this, commercially, the business needs more traffic for video. So we are having a problem, how to increase capacity of Internet traffic or reduce data for video. Many think the answer will be brought only by increasing capacity with predictable innovation of computer and network. But we can say in the near future, we will watch a scene that video will occupy Internet traffic, and other data will be stuck, at all. Calm down, we have known that data of video is so huge and resolved this issue many times. So, right now, the business is flying beyond the reality of the technology. I think this project reveals topics on electronics, seeks issues and tasks for further innovation to give newer technology to the business.

2. To build 32-bit system.
	* 64-bit system is absolutely main stream, but 32-bit system has less memory usage than 64-bit system. This means 32-bit system is economical rather than 64-bit in view of cost, but not evolution of the mobile sector which spends much money from banks. 64-bit system traditionally has a problem of treating heat. CPU has a lot of transistors, so if you want 64-bit than 32-bit, simply 64-bit needs to have transistors twice as much as 32-bit needs. Transistor is source of heat. 32-bit is the good choice for mobile gadgets even now, because of treating heat. Plus, mobile needs to be low voltage to activate, because mobile is typically powered from a battery. Besides, if CPU wants high frequency of its clock, CPU needs high voltage. Because higher frequency loses signals, higher voltage is needed to cover this problem. Or, you need a simple circuit in CPU, to fit high frequency. So there is an ideal 32-bit CPU, which is just 32-bit, is a simple circuit, and has less transistor to fit high frequency. Similarly, 8/16-bit system is the good choice for power-control, such as relays and motors for machines. If you wonder if PIC/AVR, microcontrollers, stay 8/16-bit, and want these 32/64-bit, it's a little odd. PIC/AVR is so simple, and no need of virtualization. Developers can concentrate just controlling motors. This makes less cost to develop than 32/64-bit. By the way, I know 64-bit Programmable Logic Array (PLA). This is just a relay-controller I said it's 8/16-bit above. Why the need of 64-bit? The reason is a need that engineers directly program special language, called "ladder" for controlling relays in factory machines. In view of flexibility on manufacturing, big companies may choose 64-bit PLA, but in view of cost, 8/16-bit system is still the suitable one.

**TOPICS FOR THE FUTURE**

1. None-virtual.
	* PowerPC, build by American dream team (Apple, Motorola, IBM), is a renowned CPU. Once, PowerPC had been a main CPU of Apple, and in 2005, Apple decided to use Intel's CPU, not PowerPC. All of developers blew up, PowerMac became IntelMac, but it was a real in the post-IT-boom when many companies tried to cut their developing cost. PowerPC was a special CPU in early 2000's, because the team was seeking an ideal 64-bit CPU with numerous developing cost. Absolutely, PowerPC had a super special one, Virtualization Acceleration. Since Millennium, Virtual OS has been a very tough keyword in the IT world. Windows in Macintosh, Linux in Windows, or NES in Linux in Windows in Macintosh. Virtual OS by software seems to be in success, and Intel has been added Virtualization Acceleration in its main CPU line. So, virtual one by hardware, we need a lot of logical architecture for it, becomes main stream at last. Because of the story above, I can't say Virtualization Acceleration is a dummy, but we need to know it spends a lot of money to develop more than the need. As a developer, building None-virtual system is risk management. I should say that CPU`s break is from spending a lot of cost without a thought of a bad future.

2. Asynchronous Operations and No Guaranteed for Finishes of Forward Operations.
	* To obtain process speed, CPU implemented several pipelines. The pipeline is just a buffer unit which fetches command and data from main memory. Commands in each pipeline will be executed with data in parallel. This is called as "Superscalar". Pipelines are just like "bucket relay". This has efficiency, because everyone has a bucket, and hands it to the next person. There is no break in bucket relay. Superscaler is aiming this. Plus, this bucket relay is so professional, because these buckets are stored in a warehouse where its entrance is so tiny. In front of the warehouse, only one forklift can work on. If you want efficiency, you need to make parallel bucket ways after this forklift. Every bucket puts on a tag for grouping and on a palette, that is exactly an OPERATION. Groups of buckets by each tag have various quantity sizes. Not to confuse, one tag is on one bucket way. So, even if the first team gets the palette of A buckets group forward, the second team for B buckets group afterward may be finished before A group. There is a asynchronous situation, that is possible misleading of data. To hide this, CPUs are using several methods, implicitly or explicitly. If your CPU is handling this issue implicitly, you are happy because you have no need of thought to this. But mathematically, misleading of data by this issue increases by pursuing better specification of CPU, particularly, implementation of cache. For ARM architecture, in case, you will use several explicit solutions for this issue as instructions. In case, you will need of put `DSB`, `DMB`, or `ISB` before/after memory accesses (from ARMv7), particularly, accessing memory mapped devices or coprocessors (system registers), occurring any missing cache, and synchronization of memory spaces with other cores. Manual handling is hard to understand because this makes a daisy chain. To resolve, you may need to make several corrections from some further process.

3. Sonor for Steps of Technology.
	* BCM2835 is a good System-on-a-chips (SoC), so far. The vendor opens its detail of BCM2835, reflecting confidence on the chip. BCM2835 uses ARM11 which is emerged in 2002, and in later 2000's, ARM11 used to be embedded in cell phones, and many renowned gadgets. Spreading ARM11 brings us innovation on the side of content on Internet. I remember that in early 2000's, we were struggling with creating new content on Internet. We had not gotten nice video on Internet yet, because the huge capacity of video didn't admit neither bandwidth of internet nor gadgets at that time, early 2000's. Around 2010, we were reaching the new content, video on Internet. This innovation now gives us many funny stories online. So, right now (December 15, 2017), we should consider of the next innovation. What is the one of SoC which can brings us the next? To get this, technically, we need to clear several issues. I think, secure usage of multi-core and perfect coherency of memory in a SoC are two of these. I/O devices (the side of peripherals) coherency with ARM is key to get the one. According to ARM (2009), "maintaining coherency between the CPU and the data generated or consumed by I/O devices can be challenging" (p.3-4). Completion of ARM11 took a decade. We may need to complete the one for a decade.

**Details of Aloha Operating System**

1. Difference from Unix.
	* Unix is intended to be used as an OS of Mainframe which is for big systems such as an accounting-automation system in a corporation. In contrast of IBM system, Unix was aiming open source, liberty from any platform, and academicism. One characteristic story of Unix is what it is almost made of C language (C), because C gives us easily reforming Unix to fit with every platform or CPU architecture. Unix (and Linux, its family) is most successful OS in the world. Even in mobile sector, Unix is spreading its domain. As a hardware, some phone is not only renowned as a milestone of electronics, but as a software, it made a revolution in mobile sector. Many developers have pursued to made their mobile products of Unix. Unix is initially considering of networking, so if you want to connect your mobile product to Internet or any network, Unix seems to be the best choice at all. Besides, Unix is considering less efficiency than maintenance ability. C is not a fast language, because it is made for maintenance ability. If you want the best efficiency, Assembler language (Asm) becomes a choice. In this system, functions for C is made of Asm, and C is used for handling the higher stage. Writing functions with Asm needs to be a bunch of awareness. One of these is Stack Pointer, which is never seen in C. In view of project managing, Unix is preferred, because many developers are learning this system in universities. Mobile products with Unix are the symbol of a union of corporations and universities. We should applaud to this union. But there is an aspect that many inventions, except Unix, are lost because of difficult to obtain　supports. In Japan, 10 years ago, psychologists ripped off supports for scholars in universities. It was a boom to obtain students. This made a cold winter of whole scholars. Preferring Unix in universities may make a story just like scholars in Japan.

2. Philosophy of Minimalism.
	* Is minimalism as having measles? My opinion is NO, because this thought is a fitting architecture of computer science. This system is with minimalism. On the postmodern world, minimalism is a stream as well as constructivism. Constructivism is like roman, which is enthusiastic to architecture itself. Minimalism is a venture to simple one and study of architecture. Minimalism, in computer science, is relevant to the stance committing with C. C is derived from Natural Language Processing (NLP), which claims the ideal of computer languages is like a natural language such as English, Chinese, Hawaiian, and Japanese language. NLP is developed with mathematical sign and symbol that we used to learn on schools. Mathematical sign and symbol on computer language have given us better understanding than binary (0 and 1 only!) Machine language (Machine) or Asm. Plus, parenthesis from grammar also has given us understanding. One answer of these is C. So is Asm no need? No, Asm is actually needed to understand a computer deeply. Asm is close to Machine, but it gives the least NLP. If you want to handle a computer directly, the best answer is Machine. Machine is used on the world of 8/16-bit microcontrollers even now. But if you want a big computer to handle, it's difficult to stay with Machine. Asm is the alternative to Machine on the 32/64-bit world. In this system, Asm is used for its booting process, exceptions, and functions. C is used for the process after the booting. I'm also attempting to use several macros for Asm. I can say that C is conditioned macros for Asm. If I have a time, I'll show you how C is made of macros.

3. Structure of System.
	* This system is using, so called, Assembler Cascaded Rule (ACR). To code with Asm, for readability, I use a rule as described below. Note that ACR is not my invention, and it has been used by wise developers. One advantage is ACR is close to the flowchart on paper to write the system.
```assembly
/**
 * function arm32_sleep
 * Sleep in Micro Seconds
 *
 * Parameters
 * r0: Micro Seconds to Sleep
 *
 * Return: r0 (0 as Success)
 */
.globl arm32_sleep
arm32_sleep:
	/* Auto (Local) Variables, but just Aliases */
	usecond        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	count_low      .req r1 @ Scratch Register
	count_high     .req r2 @ Scratch Register
	time_low       .req r3 @ Scratch Register
	time_high      .req r4

	push {r4,lr}

	push {r0}
	bl arm32_timestamp
	mov count_high, r1
	mov count_low, r0
	pop {r0}

	adds count_low, usecond                                     @ Add with Changing Status Flags
	adc count_high, #0                                          @ Add with Carry Flag

	arm32_sleep_loop:
		push {r0-r2}
		bl arm32_timestamp
		mov time_low, r0
		mov time_high, r1
		pop {r0-r2}
		cmp count_high, time_high                                   @ Similar to `SUBS`, Compare Higher 32 Bits
		blo arm32_sleep_common                                      @ End Loop If Higher Timer Reaches
		cmpeq count_low, time_low                                   @ Compare Lower 32 Bits If Higher 32 Bits Are Same
		bhi arm32_sleep_loop

	arm32_sleep_common:
		mov r0, #0
		pop {r4,pc}

.unreq usecond
.unreq count_low
.unreq count_high
.unreq time_low
.unreq time_high
```

4. Security of System.
	* Security of computer system will be in danger in several situations. First, any main memory rewriting is occurred by any input/output transaction, such as something from a keyboard or a Internet connection. Intentional memory overflow is a renowned technique among invaders. Second, instructions rewrote by invaders are executed. Then finally, your computer system is manipulated in bad manner. In this system, I am trying to make limited space for input/output transaction, called HEAP, which should never be executed. Framebuffer is assigned by VideoCoreIV, and this space should never be executed too. Plus, I treated memory overflow not to be done intentionally. So, in this system, I'm trying to mock-up Harvard architecture even in Von Neumann architecture. Besides, multi-core made us attention to the security much better, because multi-core is a new architecture. Researchers has not yet gotten the conclusion for secure treating of multi-core. If we handle multi-core, we should consider of the security in a very cautious manner.
	* So, one question is there. `In this system, I have placed pointers of memory address and several parameters near instructions. Is it safe or danger?`. In Harvard, it's never be done because the space for instructions is separated from the space for data. If intentional memory overflow occurs, instructions may be rewrote, and invaders will easily manipulated your system. In Von Neumann, it's possible, and the safety depends on developers. Pointers and parameters near instructions give us speedy accesses to memory. If you can treat memory overflow well, it's safe. We should consider of cons and pros on both architectures. So, ARM has several ways of restriction on memory access. One popular way is usage of user mode and privileged mode to control the restriction. I designed this system that user mode is as well as Harvard, and privileged mode can access instruction memory to rewrite.

**INSTALL**

* On Raspbian Command Line (Linux Bash)

e.g. To get kernel.img of Frequency Counter.
```bash
cd ~/Desktop
git clone https://github.com/JimmyKenMerchant/RaspberryPi.git
cd RaspberryPi/frequency_counter
make type=zerow
```
config.txt in share/assets/ is used with "kernel.img" which is made by the command above.
You need to paste these config.txt and kernel.img to the root directory of your boot media (e.g. FAT32 formatted SD Card).
You also need to get latest start.elf and bootcode.bin from RasPi Official Repository, and paste these to the root directory of your boot media.

The file name, "kernel.img", is for original ARMv6 Raspberry Pi. Besides, "kernel7.img" is for ARMv7 Raspberry Pi and later ("kernel8.img" may be for ARMv8 AArch64, but not yet). But, I experienced that "kernel.img" can run on ARMv7 Raspberry Pi.

**Preprocessor Definition on `Make` Command. Compatibilities are diffrent on each project. Please check README of these.**

* `make type=3b`: Use for Raspberry Pi 3 B

* `make type=2b`: Use for Raspberry Pi 2 B with BCM2836

* `make type=new2b`: Use for Raspberry Pi 2 B with BCM2837

* `make type=1b`: Use for Raspberry Pi 1 B Plus

* `make type=1a`: Use for Raspberry Pi 1 A Plus

* `make type=zero`: Use for Raspberry Pi Zero

* `make type=zerow`: Use for Raspberry Pi Zero W

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

**Links of References**

* [Official Documentation of RasPi](https://www.raspberrypi.org/documentation/hardware/raspberrypi/)

* [Official RasPi Usage](https://www.raspberrypi.org/documentation/usage/)

* [Baking Pi](https://www.cl.cam.ac.uk/projects/raspberrypi/tutorials/os/)

* [Chadderz's Simple USB Driver for Raspberry Pi](https://github.com/Chadderz121/csud)

* [Raspberry Pi ARM based bare metal examples](https://github.com/dwelch67/raspberrypi)

* [PiFox](https://github.com/ICTeam28/PiFox)

* [Rasberry Pi Firmware](https://github.com/raspberrypi/firmware/tree/master/boot)

* [Mailboxes](https://github.com/raspberrypi/firmware/wiki/Mailboxes)

* [VideoCore IV](https://github.com/hermanhermitage/videocoreiv): NON-COMMERCIAL USE ONLY

* [ARM Information Center](http://infocenter.arm.com/): Application Note (AN) 228 "Implementing DMA on ARM SMP Systems", ARM Limited, 2009.

* [Cisco Visual Networking Index: Forecast and Methodology, 2016-2021](https://www.cisco.com/c/en/us/solutions/collateral/service-provider/visual-networking-index-vni/complete-white-paper-c11-481360.html): Cisco Systems, Inc., 2017.

* [JimmyKenMerchant](http://electronics.jimmykenmerchant.com/): My Own Site as a Hobbyist
