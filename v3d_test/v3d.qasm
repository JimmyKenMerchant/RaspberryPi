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
	.set num_element, r0
	.set num_qpu,     r1
	.set temp,        r2
	.set multiple,    r3
	.set output_addr, ra0
	.set input_addr,  ra1
	.set data1,       ra2
	.set data2,       ra3
	.set data3,       ra4
	.set data4,       ra5
	.set data5,       ra6

	mov output_addr, unif # Get Base Address for Output
	mov input_addr, unif  # Get Base Address for Input
	mov num_element, elem_num
	mov num_qpu, qpu_num

	# Obtain Mutex
	mov -, mutex_acq

	# DMA Load (Horizontal)
	# Load to 14 Columns, 5-Deep Rows, Fr. X 0, Y0, 1 Block Row-to-Row Stride:
	# However, VPM read is vertical. A set of 14 columns and 5-deep rows converts to a set of 5 columns and 14-deep rows.
	mov vr_setup, vdr_setup_1(56) # Column Pitch (Distance) 4 Bytes * 14 Rows = 56 Bytes
	mov vr_setup, vdr_setup_0(0, 14, 5, vdr_h32(1,0,0))
	mov vr_addr, input_addr       # Element 0 Only, Other Elements Pass Through
	mov -, vr_wait                # Finished when All Elements Done

	# VPM Read (Vertical)
	#mov vr_setup, vpm_setup(0, 1, h32(0))  # Element 0 Only, Other Elements Pass Through, Automatically Move to Next Column per Element
	mov vr_setup, vpm_setup(0, 1, v32(0,0)) # Element 0 Only, Other Elements Pass Through, Automatically Move to Next Column per Element
	mov data1, vpm
	mov data2, vpm
	mov data3, vpm
	mov data4, vpm
	mov data5, vpm

	# VPM Write (Vertical)
	mov vw_setup, vpm_setup(0, 1, v32(0,0)) # Element 0 Only, Other Elements Pass Through, Automatically Move to Next Column per Element
	# Test Even or Odd of Element
	and.setf -, num_element, 1
	mov.ifnz data4, 0
	mov.ifz data5, 0
	mov vpm, num_element; mul24 multiple, num_element, num_element
	mov vpm, num_qpu; mul24 multiple, multiple, num_element
	mov vpm, multiple
	mov vpm, data1
	mov vpm, data2
	mov vpm, data3
	mov vpm, data4
	mov vpm, data5

	# Count Down
	mov temp, 8
	:_V3D_SAMPLE1_TESTLOOP
		sub.setf temp, temp, 1
		brr.anynz -, :_V3D_SAMPLE1_TESTLOOP # Branch Any Non-zero
		nop                    # 3 Instructions Delay after Branch
		nop
		nop

	# DMA Store (Horizontal)
	mov vw_setup, vdw_setup_1(0)
	mov vw_setup, vdw_setup_0(16, 8, dma_h32(0,0)) # 16 Columns, 8-deep Rows
	mov temp, 0
	add vw_addr, output_addr, temp # Element 0 Only, Other Elements Pass Through
	mov -, vw_wait                 # Finished when All Elements Done

	# Release Mutex
	mov mutex_rel, 1

	# Thread End, 2 Delays after thrend
	# Issuing interrupt seems to be used in the Mailbox command.
	thrend
	#mov interrupt, 1
	nop
	nop

.unset num_element
.unset num_qpu
.unset temp
.unset multiple
.unset output_addr
.unset input_addr
.unset data1
.unset data2
.unset data3
.unset data4
.unset data5
:_V3D_SAMPLE1_END

# 32-bit * 14 * 4 Array
:_V3D_INPUT1
.int 0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D
.int 0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D
.int 0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D
.int 0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D
:_V3D_INPUT1_END
