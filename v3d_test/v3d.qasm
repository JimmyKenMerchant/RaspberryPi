##
# v3d.qasm
# Author: Kenta Ishii
# License: MIT
# License URL: https://opensource.org/licenses/MIT
##

# Global Label
.global _V3D_SAMPLE1
# Global Symbol
.global _V3D_SAMPLE1_SIZE, :_V3D_SAMPLE1_END - :_V3D_SAMPLE1

:_V3D_SAMPLE1
.set element,   r0
.set temp,      r1
.set multiple,  r2
.set base_addr, ra0

mov base_addr, unif # Get Base Address for Output
mov element, elem_num

# VPM Write, Set to Vertical
mov temp, vpm_setup(16, 1, v32(0,0))
mov vw_setup, temp           # Element 0 Only, Other Elements Pass Through, Automatically Move to Next Column per Element
mov vpm, element; mul24 multiple, element, element
mov vpm, multiple; mul24 multiple, multiple, element
mov vpm, multiple

# DMA Store
mov vw_setup, vdw_setup_1(0)
mov vw_setup, vdw_setup_0(16, 3, dma_h32(0,0)) # 16 Columns, 3-deep Rows
mov temp, 16
add vw_addr, base_addr, temp # Element 0 Only, Other Elements Pass Through
mov -, vw_wait               # Finished when All Elements Done

# Thread End, 2 Delays after thrend
# Issuing interrupt seems to be used in the Mailbox command.
thrend
#mov interrupt, 1
nop
nop

.unset element
.unset temp
.unset multiple
.unset base_addr

:_V3D_SAMPLE1_END
