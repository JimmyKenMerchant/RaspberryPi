##
# aloha32.mk
# Author: Kenta Ishii
# License: MIT
# License URL: https://opensource.org/licenses/MIT
##

# This Makefile is tested by GNU Make in Raspbian Jessie
# In GNU Make (gmake on BSD), GNUmakefile will be searched faster than Makefile

# Values of DEFARCH and DEFTYPE are Needed to be Changed for Types of RasPi.
# type ?= 2b

# Available fpu info from Features in /proc/cpuinfo of Raspbian
# `-mcpu=cortex-a53` is unavailable on early GCC versions. You can use `-mcpu=cortex-a7` instead.
ifeq ($(type), 3b)
	PRODUCT:=__RASPI3B=1
	TARGET := -mcpu=cortex-a53 -mfpu=vfp
	ARCH := __ARMV8=1
	CPU := __BCM2837=1
	BASE := __B=1
	GPU := __GPU400=1
endif

ifeq ($(type), new2b)
	PRODUCT:=__RASPI2B=1
	TARGET := -mcpu=cortex-a7 -mfpu=vfp
	ARCH := __ARMV8=1
	CPU := __BCM2837=1
	BASE := __B=1
	GPU := __GPU400=1
endif

ifeq ($(type), 2b)
	PRODUCT:=__RASPI2B=1
	TARGET := -mcpu=cortex-a7 -mfpu=vfp
	ARCH := __ARMV7=1
	CPU := __BCM2836=1
	BASE := __B=1
	GPU := __GPU250=1
endif

ifeq ($(type), zero)
	PRODUCT:=__RASPIZERO=1
	TARGET := -mcpu=arm1176jzf-s -mfpu=vfp
	ARCH := __ARMV6=1
	CPU := __BCM2835=1
	BASE := __ZERO=1
	GPU := __GPU400=1
endif

ifeq ($(type), zerow)
	PRODUCT:=__RASPIZEROW=1
	TARGET := -mcpu=arm1176jzf-s -mfpu=vfp
	ARCH := __ARMV6=1
	CPU := __BCM2835=1
	BASE := __ZERO=1
	GPU := __GPU400=1
endif

# aarch64-linux-gnu @64bit ARM compiler but for amd64 and i386 only (as of July 2017)
COMP := arm-none-eabi
BIT := __AARCH32=1

CC := $(COMP)-gcc
CCINC := ../share/include
CCHEADER := ../share/include/*.h
CCDEF := -D $(PRODUCT) -D $(ARCH) -D $(CPU) -D $(BASE) -D $(GPU) -D $(BIT)

AS := $(COMP)-as
ASINC := ../share/aloha_raspi
ASDEF := --defsym $(PRODUCT) --defsym $(ARCH) --defsym $(CPU) --defsym $(BASE) --defsym $(GPU) --defsym $(BIT)

LINKER := $(COMP)-ld
COPY := $(COMP)-objcopy
DUMP := $(COMP)-objdump

LDSCRIPT := $(ASINC)/linker_script32.ld
OBJ1 := vector32
OBJ2 := system32
OBJ3 := user32

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
	$(CC) $< -I $(CCINC)/ $(CCDEF) -o $@ -c -O2 -Wall -nostdlib -ffreestanding $(TARGET)

$(OBJ2).o: $(ASINC)/$(OBJ2)/$(OBJ2).s
	$(AS) $< -I $(ASINC)/ $(ASDEF) -o $@ $(TARGET)

$(OBJ1).o: $(OBJ1).s
	$(AS) $< -I $(ASINC)/ $(ASDEF) -o $@ $(TARGET)

.PHONY: warn
warn: all clean

.PHONY: clean
clean:
	rm *.o inter.elf inter.map inter.list kernel.img kernel.hex
