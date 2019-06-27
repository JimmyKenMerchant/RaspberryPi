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

* 1.1.1 on June 27, 2019:
Git: git version 2.11.0
Make: GNU Make 4.1 Built for arm-unknown-linux-gnueabihf
Assembler: arm-none-eabi-as = GNU assembler (2.27-9+9) 2.27
Compiler: arm-none-eabi-gcc (15:5.4.1+svn241155-1) 5.4.1 20160919
Linux Distro `cat /etc/os-release`: Raspbian GNU/Linux 9 (stretch)
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

* June 27, 2019:
Git: git version 2.20.1
Make: GNU Make 4.2.1 Built for arm-unknown-linux-gnueabihf
Assembler: arm-none-eabi-as = GNU assembler (2.31.1-11+rpi1+11) 2.31.1
Compiler: arm-none-eabi-gcc (15:7-2018-q2-6) 7.3.1 20180622 (release) [ARM/embedded-7-branch revision 261907]
Linux Distro `cat /etc/os-release`: Raspbian GNU/Linux 10 (buster)
Machine: Raspberry Pi 3 Model B V1.2
Description:
Having partly testing with forward versions of make, assembler, and compiler as described above.
I'm going to update this project to 1.2.0 using these tools as long as further renewals will not occur in this process. The setting of default optimization (-O2) will be possibly changed to -O1 or -O0.

* June 25, 2019:
Make: GNU Make 4.1
Assembler: arm-none-eabi-as = GNU assembler (2.28-5+9+b3) 2.28
Compiler: arm-none-eabi-gcc (15:5.4.1+svn241155-1) 5.4.1 20160919
Linux Distro: Debian GNU/Linux 9.9 (stretch)
Machine: x86_64
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
