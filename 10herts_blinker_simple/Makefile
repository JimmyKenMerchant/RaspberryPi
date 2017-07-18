##
# Makefile
# Author: Kenta Ishii
# License: MIT
# License URL: https://opensource.org/licenses/MIT
##

# This Makefile is tested by GNU Make in Raspbian Jessie

# In GNU Make (gmake on BSD), GNUmakefile will be searched faster than Makefile

# aarch64-linux-gnu @64bit ARM compiler but for amd64 and i386 only (as of July 2017)
COMP = arm-none-eabi
# Available fpu info from Features in /proc/cpuinfo of Raspbian
TARGET = -march=armv7-a -mcpu=cortex-a7 -mfpu=neon
CC = $(COMP)-gcc
AS = $(COMP)-as
LINKER = $(COMP)-ld
COPY = $(COMP)-objcopy
DUMP = $(COMP)-objdump

LDSCRIPT = linker_script.ld
OBJ1 = 10herts_blinker_simple

# "$@" means the target and $^ means all of dependencies and $< is first one.
# If you meets "make: `main' is up to date.", use "touch" command to renew.
# "$?" means ones which are newer than the target.
# Make sure to use tab in command line

kernel.img: inter.elf
	$(COPY) $< -O binary $@
	$(COPY) $< -O ihex kernel.hex
	$(DUMP) -D $< > inter.list

inter.elf: $(OBJ1).o
	$(LINKER) $^ -o $@ -T $(LDSCRIPT) -Map inter.map

$(OBJ1).o: $(OBJ1).s
	$(AS) $< -I include/ -o $@ $(TARGET)

.PHONY: clean
clean:
	rm $(OBJ1).o inter.elf inter.map inter.list kernel.img kernel.hex
