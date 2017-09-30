##
# system32.mk
# Author: Kenta Ishii
# License: MIT
# License URL: https://opensource.org/licenses/MIT
##

system32.o: $(ASINC)/system32/system32.s
	$(AS) $^ -I $(ASINC)/ -o $@ $(TARGET)
