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
TARGET = -mcpu=cortex-a7 -mfpu=neon
CC = $(COMP)-gcc
AS = $(COMP)-as
LINKER = $(COMP)-ld
COPY = $(COMP)-objcopy
DUMP = $(COMP)-objdump

LDSCRIPT = linker_script.ld
OBJ1 = aloha_vector32
OBJ2 = system32
OBJ3 = aloha_user
HEADER = include/stdio.h include/aloha/system32.h 

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

$(OBJ3).o: $(OBJ3).c $(HEADER)
	$(CC) $< -I include/ -o $@ -c -O2 -Wall -nostdlib -ffreestanding $(TARGET)

# Make OBJ2, system32.o
include aloha/system32/system32.mk

$(OBJ1).o: $(OBJ1).s
	$(AS) $< -I aloha/ -o $@ $(TARGET)

.PHONY: warn
warn: all clean

.PHONY: clean
clean:
	rm *.o inter.elf inter.map inter.list kernel.img kernel.hex
