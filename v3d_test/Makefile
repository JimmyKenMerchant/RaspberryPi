##
# Makefile
# Author: Kenta Ishii
# License: MIT
# License URL: https://opensource.org/licenses/MIT
##

V3D := v3d
V3D_AS := vc4asm
V3D_DIS := vc4dis
V3D_OBJ := $(V3D).o
V3D_BIN := $(V3D).bin
V3D_SRC := $(V3D).qasm
V3D_SRC_DIS := $(V3D).qasm.dis
V3D_INC_PATH := /usr/local/share/vc4inc/
V3D_INC := vc4.qinc

include ../share/aloha_raspi/aloha32.mk

# Making V3D Object: The object file is linked to the ".rodata" section.
$(V3D_OBJ): $(V3D_SRC)
	$(V3D_AS) -V -o $(V3D_BIN) -e $@ -I $(V3D_INC_PATH) -i $(V3D_INC) $^
	$(V3D_DIS) -V -o $(V3D_SRC_DIS) -v $(V3D_BIN)

# Override to "clean" in aloha32.mk: Double colons allow to execute all recipes when overriding.
clean::
	rm $(V3D_BIN) $(V3D_SRC_DIS)
