##
# sample1.qasm
# Author: Kenta Ishii
# License: MIT
# License URL: https://opensource.org/licenses/MIT
##

.set element,   r0
.set offset,    r1
.set temp,      r2
.set base_addr, ra0

mov base_addr, unif; # Get Base Address for Output
mov element, elem_num;
shl offset, element, 3;

# VPM Write
mov temp, vpm_setup(16, 1, v32(0,0));
add vw_setup, temp, offset;
mov vpm, element;

# DMA Store
mov vw_setup, vdw_setup_1(0);
mov vw_setup, vdw_setup_0(16, 16, dma_h32(0,0));
add vw_addr, base_addr, offset;
mov -, vw_wait;

# Thread End, 2 Delays after thrend
thrend
mov interrupt, 1;
nop;

.unset element
.unset offset
.unset temp
