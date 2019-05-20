# Raspberry Pi System Project Based on Minimalism

**Table of Contents**

* [Demonstration on Video](#demonstration-on-video)

* [Purpose](#purpose)

* [Installation](#installation)

* [Licenses](#licenses)

* [Vocabulary](#vocabulary)

* [Links of References](#links-of-references)

## Demonstration on Video

[![Demonstration of Sound Projects on Video](https://img.youtube.com/vi/hjSrRYd4Wx0/0.jpg "Demonstration of Synthesizer on Video")](https://www.youtube.com/watch?v=hjSrRYd4Wx0)

## Purpose

This project is aiming to obtain a conclusion of the software system. Purposes of this project are listed below. I call the software system, "Aloha Operating System".

1. To obtain themes on electronics for the future.
	* We are currently (December 25, 2017) facing an odd situation on electronics. It seems that we bite the future of electronics too much. The future, Artificial Intelligence (AI), Augmented Reality (AR), Working Robot, is now on business actually. It's just a real, but we need to get more technological innovations to come true. We are suffering a traffic jam on Internet. The word, Net neutrality, is on trend. This reserves fair treatment of any data, even if it's not for video. According to Cisco (2017), in 2016, Internet video used 73 percents of Internet traffic. Remember, Internet is not only for video. In spite of this, commercially, the business needs more traffic for video. So we are having a problem, how to increase capacity of Internet traffic or reduce data for video. Many think the answer will be brought only by increasing capacity with predictable innovation of computer and network. But we can say in the near future, we will watch a scene that video will occupy Internet traffic, and other data will be stuck, at all. Calm down, we have known that data of video is so huge and resolved this issue many times. So, right now, the business is flying beyond the reality of the technology. I think this project reveals themes on electronics, seeks issues and tasks for further innovation to give newer technology to the business.

2. To build 32-bit system.
	* 64-bit system is absolutely main stream, but 32-bit system has less memory usage than 64-bit system. This means 32-bit system is economical rather than 64-bit in view of cost, but not evolution of the mobile sector which spends much money from banks. 64-bit system traditionally has a problem of treating heat. CPU has a lot of transistors, so if you want 64-bit than 32-bit, simply 64-bit needs to have transistors twice as much as 32-bit needs. Transistor is source of heat. 32-bit is the good choice for mobile gadgets even now, because of treating heat. Plus, mobile needs to be low voltage to activate, because mobile is typically powered from a battery. Besides, if CPU wants high frequency of its clock, CPU needs high voltage. Because higher frequency loses signals, higher voltage is needed to cover this problem. Or, you need a simple circuit in CPU, to fit high frequency. So there is an ideal 32-bit CPU, which is just 32-bit, is a simple circuit, and has less transistor to fit high frequency. Similarly, 8/16-bit system is the good choice for power-control, such as relays and motors for machines. If you wonder if PIC/AVR, microcontrollers, stay 8/16-bit, and want these 32/64-bit, it's a little odd. PIC/AVR is so simple, and no need of virtualization. Developers can concentrate just controlling motors. This makes less cost to develop than 32/64-bit. By the way, I know 64-bit Programmable Logic Array (PLA). This is just a relay-controller I said it's 8/16-bit above. Why the need of 64-bit? The reason is a need that engineers directly program special language, called "ladder" for controlling relays in factory machines. In view of flexibility on manufacturing, big companies may choose 64-bit PLA, but in view of cost, 8/16-bit system is still the suitable one.

**THEMES FOR THE FUTURE**

1. None-virtual.
	* PowerPC, build by American dream team (Apple, Motorola, IBM), is a renowned CPU. Once, PowerPC had been a main CPU of Apple, and in 2005, Apple decided to use Intel's CPU, not PowerPC. All of developers blew up, PowerMac became IntelMac, but it was a real in the post-IT-boom when many companies tried to cut their developing cost. PowerPC was a special CPU in early 2000's, because the team was seeking an ideal 64-bit CPU with numerous developing cost. Absolutely, PowerPC had a super special one, Virtualization Acceleration. Since Millennium, Virtual OS has been a very tough keyword in the IT world. Windows in Macintosh, Linux in Windows, or NES in Linux in Windows in Macintosh. Virtual OS by software seems to be in success, and Intel has been added Virtualization Acceleration in its main CPU line. So, virtual one by hardware, we need a lot of logical architecture for it, becomes main stream at last. Because of the story above, I can't say Virtualization Acceleration is a dummy, but we need to know it spends a lot of money to develop more than the need. As a developer, building None-virtual system is risk management. I should say that CPU`s break is from spending a lot of cost without a thought of a bad future.

2. Asynchronous Operations and No Guaranteed for Finishes of Forward Operations.
	* To obtain process speed, CPU implemented several pipelines. The pipeline is just a buffer unit which fetches command and data from main memory. Commands in each pipeline will be executed with data in parallel. This is called as "Superscalar". Pipelines are just like "bucket relay". This has efficiency, because everyone has a bucket, and hands it to the next person. There is no break in bucket relay. Superscaler is aiming this. Plus, this bucket relay is so professional, because these buckets are stored in a warehouse where its entrance is so tiny. In front of the warehouse, only one forklift can work on. If you want efficiency, you need to make parallel bucket ways after this forklift. Every bucket puts on a tag for grouping and on a palette, that is exactly an OPERATION. Groups of buckets by each tag have various quantity sizes. Not to confuse, one tag is on one bucket way. So, even if the first team gets the palette of A buckets group forward, the second team for B buckets group afterward may be finished before A group. There is a asynchronous situation, that is possible misleading of data. To hide this, CPUs are using several methods, implicitly or explicitly. If your CPU is handling this issue implicitly, you are happy because you have no need of thought to this. But mathematically, misleading of data by this issue increases by pursuing better specification of CPU, particularly, implementation of cache. For ARM architecture, in case, you will use several explicit solutions for this issue as instructions. In case, you will need of put `DSB`, `DMB`, or `ISB` before/after memory accesses (from ARMv7), particularly, accessing memory mapped devices or coprocessors (system registers), occurring any missing cache, and synchronization of memory spaces with other cores. Manual handling is hard to understand because this makes a daisy chain. To resolve, you may need to make several corrections from some further process.

3. Sonor for Steps of Technology.
	* BCM2835 is a good System-on-a-chips (SoC), so far. A significant advantage of BCM2835 is its low energy consumption, therefore RasPi Zeros are able to be powered by rechargeable battery packs. This is a huge advantage to make a device. The vendor also opens its detail of BCM2835, reflecting confidence on the chip. BCM2835 uses ARM11 which is emerged in 2002, and in later 2000's, ARM11 used to be embedded in cell phones, and many renowned gadgets. Spreading ARM11 brings us innovation on the side of content on Internet. I remember that in early 2000's, we were struggling with creating new content on Internet. We had not gotten nice video on Internet yet, because the huge capacity of video didn't admit neither bandwidth of internet nor gadgets at that time, early 2000's. Around 2010, we were reaching the new content, video on Internet. This innovation now gives us many funny stories online. So, right now (December 15, 2017), we should consider of the next innovation. What is the one of SoC which can brings us the next? To get this, technically, we need to clear several issues. I think, secure usage of multi-core and perfect coherency of memory in a SoC are two of these. I/O devices (the side of peripherals) coherency with ARM is key to get the one. According to ARM (2009), "maintaining coherency between the CPU and the data generated or consumed by I/O devices can be challenging" (p.3-4). Completion of ARM11 took a decade. We may need to complete the one for a decade. Plus, multi-core consumes higher energy than single-core. This issue is a huge matter in mobile sector. High capacity of battery packs, to apply high energy consumption, has a risk of rapid chemical reaction. I believe that this issue can be resolved through innovations of production technology of chips.
	* The business selling microprocessors is special rather than selling other chips such as CPUs for smartphones. Chip makers for smartphones have a premise, that each CPU is developed with each customer (i.e., smartphone producer). Until early 2010's, this business seemed to dominate the market. This business doesn't need to make open documents, even electric specifications, because the chip is only for a customer. Chips as microprocessors, at least to sell, need to have open documents because many customers check and examine specifications of microprocessors, to determine whether the chip is the best to buy. If any company need to have the new business, I suggest that the company creates official open documents of specifications. This business makes mass production of one model of chips, which can reduce the cost of production. Not only for reducing the cost of production, but chips can keep their popularity for a while because chips have their reliability and dependability to use. Z80 is the case to make success as a microprocessor. Z80 is an 8-bit processor intended for use as CPU in computers at first. However, Z80 is also used as a hard disk controller. The birth of Z80 is mid 1970's, and even today, Z80 keeps its popularity. Don't ignore that specifications of Z80 are open. You can't ignore pirating the chip. Open documents make a risk of pirating. Business people should think of the deficit caused by pirating, and imagine the profit line you drew may be slashed by such a thing. Besides, pirating is just a tort that your company can claim the damage, even internationally. Open documents also make opportunities of licensing. If your chip has popularity, other companies consider of producing the chip through licensing, but not through pirating.

4. March for Peace and Non-violence.
	* I now declare this project is only for the peace and the non-violence. Committing any war and violence is a strong jail against people to restrains themselves to a nation. Modern states were originally built through World Wars by politicians who wanted to take people stay in a jail, i.e., a nation. When I was a student, I got a book in a library. Newcomb (1950) studied in the U.S. Strategic Bombing Survey. This study aimed to know what service members in World War II build a sense of fellowship and belonging. They wanted to find out how to make "diligent citizens" for a modern state where its main business became from agriculture to industry which was needed to be labor-intensive. We are forced to be abandoned a view, independent human from a nation. Every modern state attempts to show us a perfect figure as a ruler, but we have learned this figure is suspicious. Furthermore, industry now becomes from labor-intensive to automation which frees people from modern states. We can jump over modern states, and have new internationalism. We will reach our figures as independent people.

**Details of Aloha Operating System**

1. Difference from Unix.
	* Unix is intended for use as an OS of Mainframe which is for big systems such as an accounting-automation system in a corporation. In contrast of IBM system, Unix was aiming open source, liberty from any platform, and academic science. One characteristic story of Unix is what it is almost made of C language (C), because C gives us easily reforming Unix to fit with every platform or CPU architecture. Unix (and Linux, its family) is most successful OS in the world. Even in mobile sector, Unix is spreading its domain. As a hardware, some phone is not only renowned as a milestone of electronics, but as a software, it made a revolution in mobile sector. Many developers have pursued to made their mobile products of Unix. Unix is initially considering of networking, so if you want to connect your mobile product to Internet or any network, Unix seems to be the best choice at all. Besides, Unix is considering less efficiency than maintenance ability. C is not a fast language, because it is made for maintenance ability. If you want the best efficiency, Assembler language (Asm) becomes a choice. In this system, functions for C is made of Asm, and C is used for handling the higher stage. Writing functions with Asm needs to be a bunch of awareness. One of these is Stack Pointer, which is never seen in C. In view of project managing, Unix is preferred, because many developers are learning this system in universities. Mobile products with Unix are the symbol of a union of corporations and universities. We should applaud to this union. But there is an aspect that many inventions, except Unix, are lost because of difficult to obtain supports. In Japan, 10 years ago, psychologists took all supports for other scholars in universities. It was a boom to obtain students. This made a cold winter of scholars of all divisions. Preferring Unix in universities may make a story just like scholars in Japan.

2. Philosophy of Minimalism.
	* Is minimalism as having measles? My opinion is NO, because this thought is a fitting architecture of computer science. This system is with minimalism. On the postmodern world, minimalism is a stream as well as constructivism. Constructivism is like roman, which is enthusiastic to architecture itself. Minimalism is a venture to simple one and study of architecture. Minimalism, in computer science, is relevant to the stance committing with C. C is derived from Natural Language Processing (NLP), which claims the ideal of computer languages is like a natural language such as English, Chinese, Hawaiian, and Japanese language. NLP is developed with mathematical sign and symbol that we used to learn on schools. Mathematical sign and symbol on computer language have given us better understanding than binary (0 and 1 only!) Machine language (Machine) or Asm. Plus, parenthesis from grammar also has given us understanding. One answer of these is C. So is Asm no need? No, Asm is actually needed to understand a computer deeply. Asm is close to Machine, but it gives the least NLP. If you want to handle a computer directly, the best answer is Machine. Machine is used on the world of 8/16-bit microcontrollers even now. But if you want a big computer to handle, it's difficult to stay with Machine. Asm is the alternative to Machine on the 32/64-bit world. In this system, Asm is used for its booting process, exceptions, and functions. C is used for the process after the booting. I'm also attempting to use several macros for Asm. I can say that C is conditioned macros for Asm. If I have a time, I'll show you how C is made of macros. In economy, minimalism is against over-consuming. Sometimes, atmosphere to like over-consuming take people out of their ethics. Minimalism defines global economic conflicts these days are caused by over-consuming. Over-consuming means under-consuming in the future. We tend to borrow money for over-consuming, even though your debt is money for consuming in the future. So we have to fear the future that will be lack of money for consuming. Global economic conflicts are just figures to fear the future to be destroyed by over-consuming these days, if minimalism tells. The foreseeing of minimalism in economy gets only nations in their trouble because their budget systems depends on their debt and over-consuming by people. Nations tells over-consuming as their economical growth and it's a delightful thing. We can't forget their hypocrisy get us in our sadness as independent people.

3. Structure of System.

* This system is using, so called, Assembler Cascaded Rule (ACR). To code with Asm, for readability, I use a rule as described below. There are two essences, "indents by tabs" and "labels like postal addresses". Note that ACR is not my invention, and it has been used by wise developers. One advantage is ACR is close to the flowchart on paper to write the system. Before discovering ACR, visit [ARM Information Center](http://infocenter.arm.com/help) and enter ARM Architecture Reference Manuals. Instruction set quick reference cards are good to know what is going on with ACR.

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

* Lines written above are all codes of arm32_sleep in share/aloha_raspi/system32/arm/arm32.s. This function counts microseconds and waits for end of counting. `.globl arm32_sleep` makes this functions usable in other files to link after assembling or compiling, such as files written by C Language. `arm32_sleep` in the next line is a global label, which is used for branching from other process. In contrast to a global label, `arm32_sleep_loop` and `arm32_sleep_common` are local labels which are referenced only in a function, `arm32_sleep`. `usecond .req r0` is naming. r0 is a register, which is assigned as `usecond`. To clear this assignation, `.unreq usecond` is used at the end of this function. There is a big difference from other computer languages. It's just a local variable in C Language. `push {r4,lr}` is used for saving data in r4, which is used as `time_high` in this function, and Link Register (lr). Data in Link Register is changed by calling other functions like a line, `bl arm32_timestamp`. `pop {r4,pc}` at `arm32_sleep_common` retrieves data in r4 and back to the previous process through storing the original data of Link Register to Program Counter. `mov r0, #0` makes a return value. In this system, r0 and r1 can be return values. If you want 64-bit value to return, use r1 in addition to r0. r4 to r11 are needed to save at first and load at last if you use these. r12 is Intra-procedure Call Scratch Register (ip) which is used for temporary usage, so you don't need to save and load. r0 to r3 are scratch registers, you don't need to save and load in a function, but you may need to save and load before or after calling a function. These rules of registers are used by gcc-arm-none-eabi.

* If you want `arm32_sleep` in files written by C language. More processes are needed.

```c
/* Relative System Calls  */

__attribute__((noinline)) void _sleep( uint32 u_seconds );

/* ... */

/* Regular Functions */

extern void arm32_dsb();
```

* Lines written above are codes in share/include/system32.h. The function, `arm32_sleep`, accesses restricted memory area, so this should be a system call. Besides, `arm32_dsb` does not access restricted memory area, so just coding like `extern void arm32_dsb()`. An under bar before the name of a function like `_sleep` indicates the function is a system call. An under bar indicates labels for interrupt vectors of this system. `_sleep` is defined as a void type (no return), even though this function returns zero in Asm with ACR.

```c
__attribute__((noinline)) void _sleep( uint32 u_seconds )
{
	asm volatile ("svc #0x08");
}
```

* Lines written above are codes in share/include/system32.c. Since arm32_sleep is a system call, `asm volatile ("svc #0x08")` calls Supervisor mode of Arm architecture with a value, 0x08.

```assembly
_os_svc:
	push {lr}                                @ Push fp and lr
	ldr ip, [lr, #-4]                        @ Load SVC Instruction
	bic ip, #0xFF000000                      @ Immediate Bit[23:0]
	cmp ip, #0x47                            @ Prevent Overflow SVC Table
	bhi _os_svc_common
	lsl ip, ip, #3                           @ Substitution of Multiplication by 8
	add pc, pc, ip

/* ... */

	_os_svc_0x08:
		bl arm32_sleep
		b _os_svc_common
```

* Lines written above are codes in share/aloha_raspi/vector32/os.s. `arm32_sleep` is called at this point in Supervisor mode.

* gcc-arm-none-eabi uses registers r0 to r3 as scratch registers to call a function. To save data in these registers, you may need to push values in r0 - r3 to stack before calling a function, and pop values to r0 - r3 after calling a function.

```assembly
	push {r0-r3}                             @ Equals to stmfd (stack pointer full, decrement order)
	ldr r0, [font_ascii_base, string_byte]   @ Character Pointer
	mov r3, color
	push {char_width,char_height}            @ Push Character Width and Hight
	bl fb32_char
	add sp, sp, #8
	cmp r0, #0                               @ Compare Return 0
	pop {r0-r3}                              @ Retrieve Registers Before Error Check, POP does not flags-update
	bne print32_string_error
```

* If you assign five arguments and over to call a function, push the value to stack. For example, a function fb32_char in share/aloha_raspi/system32/library/fb32.s needs six arguments. Before calling this functions, char_width and char_height, fifth and sixth arguments are pushed. After calling this functions, stack pointer is retrieved through `add sp, sp, #8` (two words backed). Error is tested before popping values to r0 - r3.

```assembly
	/* Auto (Local) Variables, but just Aliases */
	char_point  .req r0  @ Parameter, Register for Argument and Result, Scratch Register
	x_coord     .req r1  @ Parameter, Register for Argument and Result, Scratch Register
	y_coord     .req r2  @ Parameter, Register for Argument, Scratch Register
	color       .req r3  @ Parameter, Register for Argument, Scratch Register
	char_width  .req r4  @ Parameter, have to PUSH/POP in ARM C lang Regulation, Use for Vertical Counter
	char_height .req r5  @ Parameter, have to PUSH/POP in ARM C lang Regulation, Horizontal Counter Reserved Number
	f_buffer    .req r6  @ Pointer of Framebuffer
	width       .req r7
	depth       .req r8
	size        .req r9
	char_byte   .req r10
	j           .req r11 @ Use for Horizontal Counter

	push {r4-r11}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                    @ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #32                                  @ r4-r11 offset 32 bytes
	pop {char_width,char_height}                     @ Get Fifth and Sixth Arguments
	sub sp, sp, #40                                  @ Retrieve SP
```

* Lines written above are codes in fb32_char. These lines enumerate registers for naming and get fifth and sixth parameters from stack. Retrieving stack pointer is needed.

```assembly
	push {r0-r3}                             @ Equals to stmfd (stack pointer full, decrement order)
	mov r3, x_coord
	mov r1, #0
	push {temp}
	bl fb32_block_color
	add sp, sp, #4
	pop {r0-r3}
```

* Lines written above are calling a function in print32_esc_sequence in share/aloha_raspi/system32/library/print32.s. A value is substituted for Register r3 (fourth argument) before r1 (second argument).

```assembly
/**
 * function print32_esc_sequence
 * Escape Sequence of ANSI Standard
 *
 * Parameters
 * r0: Pointer of Array of String
 * r1: X Coordinate
 * r2: Y Coordinate
 * r3: Length of String
 *
 * Return: r0 (X Coordinate), r1 (Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
.globl print32_esc_sequence
print32_esc_sequence:
	/* Auto (Local) Variables, but just Aliases */
	string_point      .req r0
	x_coord           .req r1
	y_coord           .req r2
	length            .req r3
	byte              .req r4
	number            .req r5
	temp              .req r6
	temp2             .req r7

	push {r4-r7,lr}
```

* Lines written above naming registers. Check that x_coord is r1. If you substitute a value for r1 before r3, the value of x_coord becomes zero. Substituting for r1 after r3 prevents this odd.

```assembly
	/* Set Location to Render the Character */

	cmp y_coord, #0                                  @ If Value of y_coord is Signed Minus
	addlt char_height, char_height, y_coord          @ Subtract y_coord Value from char_height
	sublt char_point, char_point, y_coord            @ Add y_coord Value to char_point
	mulge y_coord, width, y_coord                    @ Vertical Offset Bytes, Rd should not be Rm in `MUL` from Warning
	addge f_buffer, f_buffer, y_coord

	.unreq y_coord
	width_check .req r2                              @ Store the Limitation of Width on this Y Coordinate

	mov width_check, f_buffer
	add width_check, width
```

* Lines written above are codes in fb32_char. Naming of a register, r2, is changed. Be careful when you modify this function. If you change a register for naming at the first lines, you also need to change the register to be renamed.

```assembly
/**
 * "arm_system32" is to be used for drivers of ARM system registers, and standard peripherals,
 * USB, I2C, UART, etc. These are usually aiming compatibility with other ARM CPUs,
 * but memory mapping differs among CPUs. Addresses of peripherals in "equ32.s" should be changed. 
 */
.section	.arm_system32

.balign 4
.include "system32/arm/arm32.s"

/* ... */

/**
 * "library_system32" is to be used for libraries, Drawing, Sound, Color, Font, etc. which have
 * compatibility with other ARM CPUs.
 */
.section	.library_system32

.balign 4
.include "system32/library/fb32.s"            @ Having Section .data
.balign 4
.include "system32/library/print32.s"         @ Having Section .data
```

* Lines written above are codes in share/aloha_raspi/system32/system32.s. Asm files are included. If you add your original files, include your Asm files to system32.s.

* So at last you can use functions for your project. Let's go to a sample project, simple_test. Each project has at least four files; vector32.s, user32.s, Makefile, and README.md. REMADME.md introduces each project such as purpose and compatibility. Makefile makes a file kernel.img through assembling, compiling, and linking several files including vector32.s and user32.s. share/aloha_raspi/aloha32.mk, which is included in Makefile, is the core file to work for making kernel.img. share/aloha_raspi/linker_script32.ld is a linker script to define memory allocation for codes in kernel.img.

```assembly
	/* GPIO */
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	ldr r1, [r0, #equ32_gpio_gpfsel20]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_1   @ Clear GPIO 21
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_1  @ Set GPIO 21 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel20]
```

* Lines written above are codes in simple_test/vector32.s. These codes set GPIO 21 as OUTPUT. In vector32.s, you can set status of peripherals, and write codes for interrupts before starting codes in simple_test/user32.s.

```c
#include "system32.h"
#include "system32.c"

int32 _user_start()
{
	_gpiomode( 20, _GPIOMODE_IN );
	//_gpiomode( 21, _GPIOMODE_OUT ); // Already Set in vector32.s

	while( True ) {
		// If GPIO 20 Detects Voltage, GPIO 21 Keeps Lighting
		if ( _gpio_in( 20 ) ) _gpiotoggle( 21, _GPIOTOGGLE_HIGH );

		_sleep( 1000 ); // Wait for 1000 Microseconds
	}

	return EXIT_SUCCESS;
}
```

* Lines written above are all codes of simple_test/user32.c. `_sleep( 1000 )` is definitely used!

* This system uses `-O2` option (Optimize even more) to compile C codes in share/aloha_raspi/aloha32.mk (at the line No. 162 on this version). `-O2` option can reduce machine codes after compiling. To learn optimization in gcc, visit [Using the GNU Compiler Collection (GCC): Optimize Options](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html). If you have no need of optimization and debugging after compiling, remove this option. In my experience, `-O2` seems not to ensure to store r0 - r3 registers to the stack, before calling a function that doesn't have four arguments (@ Ver. 5.4.1 20160919). To hide this issue, you need to change several local variables to global variables. Global variables are ensured to store values to memory spaces; and are declared outside of functions, or prefix `static` to variables inside functions on declaring. If you are a C++ learner, you might feel like a mess for it. C++ can use `new` syntax, which ensures to store values to memory spaces. However, `new` syntax depends on prebuild systems.

4. Security of System.
	* Security of computer system will be in danger in several situations. First, any main memory rewriting is occurred by any input/output transaction, such as something from a keyboard or a Internet connection. Intentional memory overflow is a renowned technique among invaders. Second, instructions rewrote by invaders are executed. Then finally, your computer system is manipulated in bad manner. In this system, I am trying to make limited space for input/output transaction, called HEAP, which should never be executed. Framebuffer is assigned by VideoCoreIV, and this space should never be executed too. Plus, I treated memory overflow not to be done intentionally. So, in this system, I'm trying to mock-up Harvard architecture even in Von Neumann architecture. Besides, multi-core made us attention to the security much better, because multi-core is a new architecture. Researchers has not yet gotten the conclusion for secure treating of multi-core. If we handle multi-core, we should consider of the security in a very cautious manner.
	* In January 2018, amid a boom of crypto coins, reserchers issued [three warnings about high performance CPUs](https://googleprojectzero.blogspot.com/2018/01/reading-privileged-memory-with-side.html). These warnings point out the risk of modern designs for high performance CPUs; such as memory cache, speculative execution, hardware threads. One of three is the risk of the same address space between kernel and userspace. This is remarkable because the risk is described as an issue in hardwares, even though softwares, operating systems, had managed this risk for a while. The warnings indicate the danger of cached data, which may be gotten through unpredicted ways. Also, the warnings include a method called "branch target injection"; which rewrites an address of a code to be executed, and may be used for executing malicious codes by attackers. This method is introduced using hardware threads in the warnings. We should consider of the risk of multi-core and hardware threads. A hardware thread means one logical core; i.e., if two hardware threads exist in a CPU, we virtually have two CPUs. It comes "Risk of Clones". If a CPU has a clone, the clone may observe and handle the CPU for attackers. We need one simple answer to resolve "Risk of Clones". One keyword for resolving is complexity. We tends to make systems more complex to modify, but complexity makes another problem. Minimalism stands against complexity. This is a proof how minimalism dedicates for the security of the system.
	* So, one question is there. `In this system, I have placed pointers of memory address and several parameters near instructions. Is it safe or danger?`. In Harvard, it's never be done because the space for instructions is separated from the space for data. If intentional memory overflow occurs, instructions may be rewrote, and invaders will easily manipulated your system. In Von Neumann, it's possible, and the safety depends on developers. Pointers and parameters near instructions give us speedy accesses to memory. If you can treat memory overflow well, it's safe. We should consider of cons and pros on both architectures. So, ARM has several ways of restriction on memory access. One popular way is usage of user mode and privileged mode to control the restriction. I designed this system that user mode is as well as Harvard, and privileged mode can access instruction memory to rewrite.
	* This system does not allow you to make empty (zero) arrays, which are placed in ".bss" section, in user32.s because functions to allocate memory spaces are only allowed to make dynamic arrays.
	* If you are aware of inconsistency of using a function -- heap32_mcount which detects whether the memory address pointer is in heap area or not -- in peripheral I/O functions, you are right. Functions in i2c.s only uses heap32_mcount (unused on later version). Peripheral I/O functions with unintended memory area make security issues. However, you can protect the pointer not to be changed in several ways. Manipulating memory address pointer is one of big targets of hackers. Processes in codes should consider of this issue. Peripheral I/O functions called after external usage of heap32_mcount are as well as functions in i2c.s.

5. Coconuts
	* Some of projects in Aloha Operating System are aiming to make RasPi act like a dedicated IC such as Sound Box, Synthesizer, LED Driver nicknamed "Coconut". Coconuts are made of admiration for microprocessors. Microprocessors are general-purpose, and can transform any ICs by installed programs. Coconuts are evidences which RasPi can be a good microprocessor. I think, even today, microprocessors can alter a lot of digital signal processors (dedicated DSPs) to theirselves. Actually, video processors need to have more registers and memory caches to get a quick procedure than ordinary microprocessors. But innovation of microprocessors can surpass the advantages of dedicated DSPs. We tends to ignore the production cost of ICs. Microprocessors can be made with mass production, which reduces its cost. Don't forget, REDUCING COST MAKES FURTHER INNOVATION. If the speed, the reliability and dependability, and the validity to estimate cost of microprocessors are just as good as DSPs, we have to consider of the change for the innovation. Even if the change erases the advantage of us, we need to accept it for the future.

## Installation

* Codes of this system will be compiled and assembled in Linux, and allowed to be cross-compiled by other CPUs. This system is premised on compiling with arm-none-eabi-gcc, and on assembling with arm-none-eabi-as. Note that arm-none-eabi-as is contained in binutils-arm-none-eabi (package names may differ in Linux distros). These tools are updated by GNU community. Please access [GNU Compiler Collection](https://gcc.gnu.org/) and [GNU Binutils](https://www.gnu.org/software/binutils/).

**Guide for Installation On Raspbian command line (Linux Bash)**

* In advance, prepare FAT32 formatted SD card as a boot media. Several ways are introduced to format FAT32 SD card online, even by video. If you haven't installed Git, a open source version control system, install Git to your operating system.

```bash
# Do as Superuser, Install Git and Make
sudo apt-get update
sudo apt-get install git
sudo apt-get install make
# Install Cross Compiler Tool for ARM Microprocessors, "none" Means No OS, "eabi" Means Embedded Application Binary Interface (ABI)
sudo apt-get install gcc-arm-none-eabi
# binutils-arm-none-eabi is also installed with gcc-arm-none-eabi automatically.
```

* Clone this project using Git.

```bash
cd ~/Desktop
git clone https://github.com/JimmyKenMerchant/RaspberryPi.git
# Enter Directory
cd RaspberryPi
```

* Assembly and compile a program you want.

e.g. To get kernel.img of Frequency Counter for Raspberry Pi 3 B.
```bash
cd frequency_counter
make type=3b
```

e.g. To get kernel.img of Sound Box for Raspberry Pi Zero W with I2S Output.
```bash
cd sound_box
make type=zerow sound=i2s
```

* You obtain inter.elf, inter.list, inter.map, kernel.hex, kernel.img, system32.o, user32.o, and vector32.o through `make`. kernel.img is what you want, but inter.list is useful to know memory mapping of codes.

* Paste kernel.img, config.txt, and LICENSE.aloha to the root directory of your boot media. config.txt and LICENSE.aloha are in share/assets/ of this project. If you fail to `make` with any error, check share/aloha_raspi/README.txt which describes versions of Assembler and Compiler.

* You also need to download latest start.elf, fixup.dat, bootcode.bin, and LICENSE.broadcom from [Rasberry Pi Firmware](https://github.com/raspberrypi/firmware), and paste these to the root directory of your boot media.
	* fixup.dat makes a partition of SDRAM between VideoCore (GPU) and ARM.
	* The file name, "kernel.img", is for original ARMv6 Raspberry Pi. Besides, "kernel7.img" is for ARMv7 Raspberry Pi and later ("kernel8.img" may be for ARMv8 AArch64, but not yet). But, I experienced that "kernel.img" can run on Raspberry Pi with ARMv7 and later.

**Arguments for 'make'. Compatibilities are different on each project. Please check README of programs.**

* `type=3b`: Use for Raspberry Pi 3 B

* `type=2b`: Use for Raspberry Pi 2 B with BCM2836

* `type=zerow`: Use for Raspberry Pi Zero W

* `type=zero`: Use for Raspberry Pi Zero (tested only by Zero W so far)

* `type=new2b`: Use for Raspberry Pi 2 B with BCM2837 (not tested its compatibility so far)

* `type=1b`: Use for Raspberry Pi 1 B Plus (not tested its compatibility so far)

* `type=1a`: Use for Raspberry Pi 1 A Plus (not tested its compatibility so far)

* `sound=pwm`: PWM Output, use only in sound projects (Synthesizer, Sound Box, and Aloha Calc)

* `sound=i2s`: I2S Output, use only in sound projects (Synthesizer, Sound Box, and Aloha Calc)

* `sound=jack`: Audio Jack Output, use only in sound projects (Synthesizer, Sound Box, and Aloha Calc)

* `sound=pwmb`: Balanced PWM Output, use only in Sound Box.

* `sound=i2sb`: Balanced I2S Output, use only in Sound Box.

* `sound=jackb`: Balanced Audio Jack Output, use only in Sound Box.

**Boot Process of Raspberry Pi (Including My Hypothesis)**

1. Power on, then VideoCore runs the first boot codes in a ROM embedded on the SoC.

2. VideoCore searches the boot media, then loads bootcode.bin to the special memory for booting and runs it. Undocumented SD0 (one of Secure Digital host controllers) seems to be used, therefore documented SD1 seems to be free on this time.

3. VideoCore activates ARM Processor and other peripherals including Main Memory. On this time, VideCore loads start.elf to Main Memory for ARM Processor (VideoCore is accessible from ARM through Mailbox afterward).

4. ARM Processor runs start.elf to initialize itself, and check config.txt.

5. start.elf sets several configurations from config.txt. In default, several configurations, like the framebuffer and the physical memory, are recorded on ATAGs from Address 0x100.

6. start.elf starts kernel.img.

**GPIO Maximum Current Source and USB Current Source**

* GPIO pins have four types. 3.3V power source, 5.0V power source, Input/Output, and Ground.

* About Input/Output pins, the total current should be up to 50mA and the current of each pin should be up to 16mA. System-on-a-chip like BCM283x is not designed as a current source, because its electrical wire is so thin.

* 3.3V power source is derived from the DC/DC converter (PAM2306AYPKE, etc.). Check electrical characteristics of the chip to check the maximum current.

* 5.0V power source seems to be derived from the power-in, but has a fuse (MS-MSMF200, etc.).

* About USB current source, there are experiences online. 600mA/1200mA switchable (RasPi3B is 1200mA in default) seems to be an answer. But, [there is no official document about the USB maximum ratings](https://www.raspberrypi.org/documentation/hardware/raspberrypi/usb/README.md), and [the official document restricts the total usage of the current on a RasPi for peripherals including USB devices up to 1A](https://www.raspberrypi.org/documentation/hardware/raspberrypi/power/README.md). 

## Licenses

**LICENSE ABOUT CODES**

Copyright 2017 Kenta Ishii

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

**LICENSE ABOUT OTHER PROPERTIES**

Copyright © 2017-2018 Kenta Ishii. All Rights Reserved.

Texts in READMEs, images, designs of symbols ("BugUFO", "Moon Symbol", etc.), melodies of musics, and other properties except codes are retained these intellectual property rights by Kenta Ishii. For example, texts in READMEs are restricted your commercial usage except fair use which is described in copyright cases of United States Courts.

**PUBLICLY AVAILABLE TECHNOLOGY AND SOFTWARE**

The software is made of publicly available technology, is not including any proprietary technology, is not any encryption software, and is not any malicious software.

## Vocabulary

* Several vocabularies are ambiguous or vague in this project.
	* You can see "heap" word in *.s files. This means memory space to be used in a process dynamically. But in this project, the meaning of "heap" word is expanded. It's a pointer of a memory space. The heap, in this project, can be accessed by User mode which is low privileged. In User mode, data only can be written to the heap and predefined arrays. Several functions (heap32_malloc*, etc.) assigns a pointer in the heap for dynamic usage in a process. To distinguish between high privileged memory space and low privileged memory space, "heap" word is used as a pointer of a special memory space assigned from the heap.

## Links of References

**About Raspberry Pi**

* [Baking Pi](https://www.cl.cam.ac.uk/projects/raspberrypi/tutorials/os/)

* [Chadderz's Simple USB Driver for Raspberry Pi](https://github.com/Chadderz121/csud)

* [Mailboxes](https://github.com/raspberrypi/firmware/wiki/Mailboxes)

* [Official Documentation of RasPi](https://www.raspberrypi.org/documentation/hardware/raspberrypi/)

* [Official RasPi Usage](https://www.raspberrypi.org/documentation/usage/)

* [PiFox](https://github.com/ICTeam28/PiFox)

* [Raspberry Pi ARM based bare metal examples](https://github.com/dwelch67/raspberrypi)

* [Rasberry Pi Firmware](https://github.com/raspberrypi/firmware)

* [VideoCore IV](https://github.com/hermanhermitage/videocoreiv): NON-COMMERCIAL USE ONLY

**About Primaries**

* [Anton's OpenGL4 Tutorials](http://antongerdelan.net/opengl/)

* [ARM Information Center](http://infocenter.arm.com/help): Application Note (AN) 228 "Implementing DMA on ARM SMP Systems", ARM Limited, 2009.

* [Cisco Visual Networking Index: Forecast and Methodology, 2016-2021](https://www.cisco.com/c/en/us/solutions/collateral/service-provider/visual-networking-index-vni/complete-white-paper-c11-481360.html): Cisco Systems, Inc., 2017.

* [Statics](http://philschatz.com/statistics-book/)

**About Securities**

* [Reading privileged memory with a side-channel](https://googleprojectzero.blogspot.com/2018/01/reading-privileged-memory-with-side.html)

**About Others**

* Newcomb, Theodore M. 1950 Social Psychology. Dryden Press.

* [Mills,D.L. & Venters,S. 2012 Timestamp Capture Principle.](https://www.eecis.udel.edu/~mills/stamp.html)

* Chowning,J. 1973 The Synthesis of Complex Audio Spectra by Means of Frequency Modulation. Journal of the Audio Engineering Society, 21, 526-534.

* [JimmyKenMerchant](http://electronics.jimmykenmerchant.com/): My Own Site as a Hobbyist
