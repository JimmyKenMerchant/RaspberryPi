##
# system32.mk
# Author: Kenta Ishii
# License: MIT
# License URL: https://opensource.org/licenses/MIT
##

system32.o: $(INC)/system32/system32.s
	$(AS) $^ -I $(INC)/ -o $@ $(TARGET)
