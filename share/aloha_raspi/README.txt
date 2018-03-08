**Naming Domain**

1. Full Name: Aloha Operating System for Raspberry Pi

2. Abbreviation: aloha_raspi

**Hardware Information**

1. System-on-a-chip: BCM2835, BCM2836, BCM2837

2. Chassis: Series of Raspberry Pi

**Contributors**

* Kenta Ishii

**Version Information**

* 0.9.2 Beta on March 7, 2018:
Assembler: arm-none-eabi-as = GNU assembler (2.27-9+9) 2.27
Compiler: arm-none-eabi-gcc (15:5.4.1+svn241155-1) 5.4.1 20160919

Added Several Files and Modified Functions.

* 0.9.1 Beta on December 30, 2017:
Assembler: arm-none-eabi-as = GNU assembler (2.27-9+9) 2.27
Compiler: arm-none-eabi-gcc (15:5.4.1+svn241155-1) 5.4.1 20160919

The option of arm-none-eabi-gcc, -O2 (Normal Optimization) seems not to ensure to store r0-r3 registers to the stack, before calling a function that doesn't have four arguments (@ Ver. 5.4.1 20160919).

* 0.9 Beta on September 27, 2017
