**Naming Domain**

1. Full Name: Aloha Operating System for Raspberry Pi

2. Abbreviation: aloha_raspi

**Hardware Information**

1. System-on-a-chip: BCM2835, BCM2836, BCM2837

2. Chassis: Series of Raspberry Pi

**Contributors**

* Kenta Ishii

**Version Information**

* Notice: Versions of Linker (GNU ld), Copier (GNU objcopy), and Dumper (GNU objdump) are the same as Assembler because these are included in a package, binutils-arm-none-eabi.

* 1.1.9 on January 12, 2020:
Git: git version 2.20.1
Make: GNU Make 4.2.1 Built for arm-unknown-linux-gnueabihf
Assembler (Binary Utilities): arm-none-eabi-as = GNU assembler (2.31.1-11+rpi1+11) 2.31.1
Compiler: arm-none-eabi-gcc (15:7-2018-q2-6) 7.3.1 20180622 (release) [ARM/embedded-7-branch revision 261907]
Linux Distro `lsb_release -a`: Raspbian GNU/Linux 10 (buster)
Machine to Compile:
 1. Raspberry Pi 3 Model B V1.2 (Main)
 2. Raspberry Pi Zero W V.1.1
 3. Raspberry Pi Zero V.1.3
 4. Raspberry Pi 2 B V.1.1
Firmware:
 1. LICENCE.broadcom: https://raw.githubusercontent.com/raspberrypi/firmware/1.20190925/boot/LICENCE.broadcom
 2. bootcode.bin: https://raw.githubusercontent.com/raspberrypi/firmware/1.20190925/boot/bootcode.bin
 3. fixup.dat: https://raw.githubusercontent.com/raspberrypi/firmware/1.20190925/boot/fixup.dat
 4. start.elf: https://raw.githubusercontent.com/raspberrypi/firmware/1.20190925/boot/start.elf
 5. dt-blob.dts: https://raw.githubusercontent.com/raspberrypi/firmware/1.20190925/extra/dt-blob.dts
Device Tree Compiler: device-tree-compiler = DTC 1.4.7
Test Target:
 1. First Priority: Raspberry Pi Zero W V.1.1 (BCM2835)
 2. Second Priority: Raspberry Pi 3 B V.1.2 (BCM2837)
 3. Third Priority: Raspberry Pi Zero V.1.3 (BCM2835)
 4. Back Up: Raspberry Pi 2 B V.1.1 (BCM2836)
Outstanding Issues:
 1. Synthesizer (Functions in sts32.s): CC#16 and CC#48 to Changing Frequency Range of Modulation in MIDI IN > Noise and Freeze
 2. Sound Box (Functions in snd32.s): Pitch Bending in MIDI IN > Noise on Note Off
 3. Tuner (Functions in fft32.s): Incorrect Calculation of Power Spectrum
 4. Synthesizer and Sound Box: No Test with MIDI Hardware
 5. Schematics: No Bypass Capacitor on External Power Supply (dc_motor_driver.pdf, dc_motor_driver2.pdf)
Description:
Getting firmware using `wget`. To make dt-blob.bin, `sudo dtc -I dts -O dtb -o dt-blob.bin -q dt-blob.dts`.

* 1.1.1 on June 27, 2019:
Git: git version 2.11.0
Make: GNU Make 4.1 Built for arm-unknown-linux-gnueabihf
Assembler: arm-none-eabi-as = GNU assembler (2.27-9+9) 2.27
Compiler: arm-none-eabi-gcc (15:5.4.1+svn241155-1) 5.4.1 20160919
Linux Distro `lsb_release -a`: Raspbian GNU/Linux 9.9 (stretch)
Machine: Raspberry Pi 3 Model B V1.2
Description:
Commits up to this version depend on the versions of tools as described above.
To fit with renewals of tools, future commits will depend on new versions of tools. Check the technical note on June 27, 2019.

* 1.1.0 on November 6, 2018:
Assembler: arm-none-eabi-as = GNU assembler (2.27-9+9) 2.27
Compiler: arm-none-eabi-gcc (15:5.4.1+svn241155-1) 5.4.1 20160919

* 1.0.0 on August 12, 2018:
Assembler: arm-none-eabi-as = GNU assembler (2.27-9+9) 2.27
Compiler: arm-none-eabi-gcc (15:5.4.1+svn241155-1) 5.4.1 20160919

* 0.9.3 Beta on July 26, 2018:
Assembler: arm-none-eabi-as = GNU assembler (2.27-9+9) 2.27
Compiler: arm-none-eabi-gcc (15:5.4.1+svn241155-1) 5.4.1 20160919

Added Several Files and Modified Functions.

* 0.9.2 Beta on March 7, 2018:
Assembler: arm-none-eabi-as = GNU assembler (2.27-9+9) 2.27
Compiler: arm-none-eabi-gcc (15:5.4.1+svn241155-1) 5.4.1 20160919

Added Several Files and Modified Functions.

* 0.9.1 Beta on December 30, 2017:
Assembler: arm-none-eabi-as = GNU assembler (2.27-9+9) 2.27
Compiler: arm-none-eabi-gcc (15:5.4.1+svn241155-1) 5.4.1 20160919

The option of arm-none-eabi-gcc, -O2 (Optimize even more) seems not to ensure to store r0-r3 registers to the stack, before calling a function that doesn't have four arguments (@ Ver. 5.4.1 20160919).

* 0.9 Beta on September 27, 2017

**Technical Notes**

* October 27, 2019:
Test Target (Back Up): Raspberry Pi 2 B V.1.1 (BCM2836)
Description: I'll use the back up for Aloha Calc, DMX512 Transmitter Test, and USB Test instead of 3 B. GPIO 14 for TXD0 (UART) of My 3 B is broken because of accidental 5 volts input. In view of the compatibility, I think 2 B is close to 3 B, but it's unsure that "init_uart_clock=7500000" in config.txt can be accepted by TXD0 of 3 B. GPIO 15 for RXD0 of My 3 B is not broken, so MIDI IN of Sound Box and Synthesizer will be tested by a 3 B. By the way, I'm planning to buy another 3 B, however I haven't selected the reseller yet -- in fact, I have other BOMs for the next season. 3 B has been produced by several vendors. In the consensus among Media, a plant in Aichi makes 3 B. U.K. and China also make 3 B, i.e., 3 3 Bs. Really?

* October 21, 2019:
Test Target (First Priority): Raspberry Pi Zero W V.1.1 (BCM2835)
Test Target (Second Priority): Raspberry Pi 3 B V.1.2 (BCM2837)
Test Target (Third Priority): Raspberry Pi Zero V.1.3 (BCM2835)
Description: In view of easy-obtainable products, openness to details, and readiness for hobbies; I set test targets and these priorities. I'll test RasPis at first and second priorities, and might test one at third priority in HISTORY.md of each project. I think that Zero is almost the same as Zero W. However, the firmware recognizes these as different ones, which causing possible incompatibility between Zero and Zero W. Note that Zero WH is actually Zero W V.1.1. I recognize that 1 B+ and 1 A+ are also popular with developers. In aloha32.mk, I defined CPU, BASE, MEMORY, etc. to check differences among RasPis.

* October 7, 2019:
LICENCE.broadcom: https://raw.githubusercontent.com/raspberrypi/firmware/1.20190925/boot/LICENCE.broadcom
bootcode.bin: https://raw.githubusercontent.com/raspberrypi/firmware/1.20190925/boot/bootcode.bin
fixup.dat: https://raw.githubusercontent.com/raspberrypi/firmware/1.20190925/boot/fixup.dat
start.elf: https://raw.githubusercontent.com/raspberrypi/firmware/1.20190925/boot/start.elf
dt-blob.dts: https://raw.githubusercontent.com/raspberrypi/firmware/1.20190925/extra/dt-blob.dts
Device Tree Compiler: device-tree-compiler = DTC 1.4.7
Description:
Getting firmware using `wget`. To make dt-blob.bin, `sudo dtc -I dts -O dtb -o dt-blob.bin -q dt-blob.dts`.

* June 28, 2019:
Description:
Having partly testing with forward versions of make, assembler, and compiler as described on June 27, 2019.
I decided to change the default optimization of GCC in this project from -O2 to -O1.
I checked several "inter.list" files made of old and new tools to check binaries. Binaries of -O2 is changed between new tools and old tools. Newer versions of GCC seems to be trying to make optimization more effective than older ones. So, -O2 is progressed to optimize in the new one. I assess the old -O2 is similar to the new -O1.

* June 27, 2019:
Git: git version 2.20.1
Make: GNU Make 4.2.1 Built for arm-unknown-linux-gnueabihf
Assembler: arm-none-eabi-as = GNU assembler (2.31.1-11+rpi1+11) 2.31.1
Compiler: arm-none-eabi-gcc (15:7-2018-q2-6) 7.3.1 20180622 (release) [ARM/embedded-7-branch revision 261907]
Linux Distro `lsb_release -a`: Raspbian GNU/Linux 10 (buster)
Machine: Raspberry Pi 3 Model B V1.2
Description:
Having partly testing with forward versions of make, assembler, and compiler as described above.
I'm going to update this project to 1.2.0 using these tools as long as further renewals will not occur in this process. The setting of default optimization (-O2) will be possibly changed to -O1 or -O0.

* June 25, 2019:
Git: git version 2.11.0
Make: GNU Make 4.1 Built for x86_64-pc-linux-gnu
Assembler: arm-none-eabi-as = GNU assembler (2.28-5+9+b3) 2.28
Compiler: arm-none-eabi-gcc (15:5.4.1+svn241155-1) 5.4.1 20160919
Linux Distro `lsb_release -a`: Debian GNU/Linux 9.9 (stretch)
Machine: x86_64 with WSL
Description:
Having partly testing with forward versions of make, assembler, and compiler as described above.
 1. GNU assembler 2.28 has an odd on vpop/vpush.
    The assembler issues errors if vpop/vpush is with single precision floating point over 16 registers.
    vpop/vpush can handle single precision values over 16 registers in the architecture.
    However, vpop/vpush (full descending stack) is a synonym of stmdb/ldm, and both print the same binaries in my experience.
    Check the commit "80212fbc98864944aae66f89ac174a01ff1df479".
 2. Optimizations of GCC are arts of each computer age.
    We should consider of no optimization with our C projects in any age of GCC.
    In the "Make" process in this project, the option for optimization becomes changeable with "optimize=*".
    Note that the default setting is still "-O2".
 3. Progression/Regression of codes in projects are usual as long as the project is going on.
    To hide this issue, we have several ways.
    Using the particular version of Linux distro on a virtual machine is a way to solve this issue.
