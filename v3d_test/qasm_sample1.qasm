##
# sample1.qasm
# Author: Kenta Ishii
# License: MIT
# License URL: https://opensource.org/licenses/MIT
##

.set element,   r0
.set offset,    r1
.set temp,      r2
.set multiple,  r3
.set base_addr, ra0

mov base_addr, unif # Get Base Address for Output
mov element, elem_num
shl offset, element, 3

# VPM Write
mov temp, vpm_setup(16, 1, v32(0,0))
add vw_setup, temp, offset
# Slide Column
mov vpm, element; mul24 multiple, element, element
mov vpm, multiple

# DMA Store
mov vw_setup, vdw_setup_1(0)
mov vw_setup, vdw_setup_0(16, 3, dma_h32(0,0)) # 16 Columns, 3-deep Rows
mov temp, 16
add vw_addr, base_addr, temp # Triggered at Element 0 Only, Other Elements Pass Through
mov -, vw_wait               # Finished when All Elements Done

# Thread End, 2 Delays after thrend
# Issuing interrupt seems to be used in the Mailbox command.
thrend
#mov interrupt, 1
nop
nop

.unset element
.unset offset
.unset temp
.unset multiple
.unset base_addr
