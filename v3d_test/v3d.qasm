##
# v3d.qasm
# Author: Kenta Ishii
# License: MIT
# License URL: https://opensource.org/licenses/MIT
##

# Global Label
.global _V3D_SAMPLE1
.global _V3D_INPUT1

# Global Symbol
.global _V3D_SAMPLE1_SIZE, :_V3D_SAMPLE1_END - :_V3D_SAMPLE1
.global _V3D_INPUT1_SIZE, :_V3D_INPUT1_END - :_V3D_INPUT1

:_V3D_SAMPLE1
	.set element,     r0
	.set temp,        r1
	.set multiple,    r2
	.set output_addr, ra0
	.set input_addr,  ra1
	.set data1,       ra2
	.set data2,       ra3
	.set data3,       ra4
	.set data4,       ra5

	mov output_addr, unif # Get Base Address for Output
	mov input_addr, unif  # Get Base Address for Input
	mov element, elem_num

	# DMA Load, 2 Rows * 2 Times
	mov vr_setup, vdr_setup_1(8)                        # Row to Row Pitch (Distance) 8 * 8 Bytes
	mov vr_setup, vdr_setup_0(0, 16, 0, vdr_v32(0,0,0)) # Read to 16 Columns, Position from X 0, Y0
	mov vr_addr, input_addr       # Element 0 Only, Other Elements Pass Through
	mov -, vr_wait                # Finished when All Elements Done

	mov temp, 128
	mov vr_setup, vdr_setup_0(0, 16, 0, vdr_v32(0,0,2)) # Read to 16 Columns, Position from X 0, Y2
	add vr_addr, input_addr, temp # Element 0 Only, Other Elements Pass Through
	mov -, vr_wait                # Finished when All Elements Done

	# VPM Read
	mov vr_setup, vpm_setup(0, 1, v32(0,0)) # Element 0 Only, Other Elements Pass Through, Automatically Move to Next Column per Element
	mov data1, vpm
	mov data2, vpm
	mov data3, vpm
	mov data4, vpm

	# VPM Write, Set to Vertical
	mov vw_setup, vpm_setup(0, 1, v32(0,0)) # Element 0 Only, Other Elements Pass Through, Automatically Move to Next Column per Element
	mov vpm, element; mul24 multiple, element, element
	mov vpm, multiple; mul24 multiple, multiple, element
	mov vpm, multiple
	mov vpm, data1
	mov vpm, data2
	mov vpm, data3
	mov vpm, data4

	# DMA Store
	mov vw_setup, vdw_setup_1(0)
	mov vw_setup, vdw_setup_0(16, 8, dma_h32(0,0)) # 16 Columns, 8-deep Rows
	mov temp, 0
	add vw_addr, output_addr, temp # Element 0 Only, Other Elements Pass Through
	mov -, vw_wait                 # Finished when All Elements Done

	# Thread End, 2 Delays after thrend
	# Issuing interrupt seems to be used in the Mailbox command.
	thrend
	#mov interrupt, 1
	nop
	nop

.unset element
.unset temp
.unset multiple
.unset output_addr
.unset input_addr
.unset data1
.unset data2
.unset data3
.unset data4
:_V3D_SAMPLE1_END

# 32-bit * 64 Array
:_V3D_INPUT1
.int 0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,0x3F
.int 0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x2E,0x2F
.int 0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,0x1F
.int 0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F
:_V3D_INPUT1_END
