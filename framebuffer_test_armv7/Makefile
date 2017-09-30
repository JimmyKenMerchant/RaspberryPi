##
# Makefile
# Author: Kenta Ishii
# License: MIT
# License URL: https://opensource.org/licenses/MIT
##

# This Makefile is tested by GNU Make in Raspbian Jessie
# In GNU Make (gmake on BSD), GNUmakefile will be searched faster than Makefile

# Values of DEFARCH and DEFTYPE are Needed to be Changed for Types of RasPi.
DEFARCH = __ARMV7__=1
DEFTYPE = __RASPI2B__=1

# Available fpu info from Features in /proc/cpuinfo of Raspbian
ifeq ($(DEFARCH), __ARMV8__=1)
	TARGET = -mcpu=cortex-a53 -mfpu=vfp
endif

ifeq ($(DEFARCH), __ARMV7__=1)
	TARGET = -mcpu=cortex-a7 -mfpu=vfp
endif

ifeq ($(DEFARCH), __ARMV6__=1)
	TARGET = -mcpu=arm1176jzf-s -mfpu=vfp
endif

# aarch64-linux-gnu @64bit ARM compiler but for amd64 and i386 only (as of July 2017)
COMP = arm-none-eabi

CC = $(COMP)-gcc
CCINC = ../share/include
CCHEADER = ../share/include/*.h

AS = $(COMP)-as
ASINC = ../share/aloha_raspi

LINKER = $(COMP)-ld
COPY = $(COMP)-objcopy
DUMP = $(COMP)-objdump

LDSCRIPT = linker_script.ld
OBJ1 = vector32
OBJ2 = system32
OBJ3 = user32

# "$@" means the target and $^ means all of dependencies and $< is first one.
# If you meets "make: `main' is up to date.", use "touch" command to renew.
# "$?" means ones which are newer than the target.
# Make sure to use tab in command line
.PHONY: all
all: kernel.img
kernel.img: inter.elf
	$(COPY) $< -O binary $@
	$(COPY) $< -O ihex kernel.hex
	$(DUMP) -D $< > inter.list

inter.elf: $(OBJ1).o $(OBJ2).o $(OBJ3).o
	$(LINKER) $^ -o $@ -T $(LDSCRIPT) -Map inter.map

$(OBJ3).o: $(OBJ3).c $(CCHEADER)
	$(CC) $< -I $(CCINC)/ -D $(DEFARCH) -D $(DEFTYPE) -o $@ -c -O2 -Wall -nostdlib -ffreestanding $(TARGET)

# Make OBJ2, system32.o
include $(ASINC)/system32/system32.mk

$(OBJ1).o: $(OBJ1).s
	$(AS) $< -I $(ASINC)/ --defsym $(DEFARCH) --defsym $(DEFTYPE) -o $@ $(TARGET)

.PHONY: warn
warn: all clean

.PHONY: clean
clean:
	rm *.o inter.elf inter.map inter.list kernel.img kernel.hex
