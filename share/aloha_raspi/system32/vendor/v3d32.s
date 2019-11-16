/**
 * v3d32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

V3D32_BCM32_GENERIC0_ADDR: .word BCM32_GENERIC0


/**
 * function v3d32_enable_qpu
 * Utilize QPU of VideoCore IV from ARM
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: 0 as Disable, 1 as Enable
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): Error in Response
 * Error(2): Failure to Enable QPU
 */
.globl v3d32_enable_qpu
v3d32_enable_qpu:
	/* Auto (Local) Variables, but just Aliases */
	flag_enable .req r0
	addr_value  .req r1
	temp        .req r2

	push {lr}

	ldr addr_value, V3D32_BCM32_GENERIC0_ADDR
	str flag_enable, [addr_value] @ BCM32_GENERIC0

	mov temp, #0
	str temp, [addr_value, #4]    @ BCM32_GENERIC1
	str temp, [addr_value, #8]    @ BCM32_GENERIC2
	str temp, [addr_value, #12]   @ BCM32_GENERIC3
	str temp, [addr_value, #16]   @ BCM32_GENERIC4
	str temp, [addr_value, #20]   @ BCM32_GENERIC5

	push {r0-r2}
	mov r0, #0x00030000
	orr r0, r0, #0x00000012
	mov r1, #4
	bl bcm32_genericmail
	cmp r0, #0
	pop {r0-r2}

	macro32_dsb ip

	bne v3d32_enable_qpu_error1

	ldr flag_enable, [addr_value]
	cmp flag_enable, #0
	beq v3d32_enable_qpu_success
	bne v3d32_enable_qpu_error2

	v3d32_enable_qpu_error1:
		mov r0, #1
		b v3d32_enable_qpu_common

	v3d32_enable_qpu_error2:
		mov r0, #2
		b v3d32_enable_qpu_common

	v3d32_enable_qpu_success:
		mov r0, #0

	v3d32_enable_qpu_common:
		pop {pc}

.unreq flag_enable
.unreq addr_value
.unreq temp


/**
 * function v3d32_control_qpul2cache
 * Control L2 Cache for QPU of VideoCore IV from ARM
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Bit[2]: Write 1 as Clear L2 Cache, Bit[1]: Write 1 as Disable L2 Cache, Bit[0]: Write 1 as Enable L2 Cache
 *
 * Return: r0 (0 as success)
 */
.globl v3d32_control_qpul2cache
v3d32_control_qpul2cache:
	/* Auto (Local) Variables, but just Aliases */
	ctrl_l2  .req r0
	addr_qpu .req r1

	push {lr}

	mov addr_qpu, #equ32_peripherals_base
	orr addr_qpu, addr_qpu, #v3d32_base

	and ctrl_l2, ctrl_l2, #0b111
	str ctrl_l2, [addr_qpu, #v3d32_l2cactl]

	v3d32_control_qpul2cache_success:
		mov r0, #0

	v3d32_control_qpul2cache_common:
		macro32_dsb ip
		pop {pc}

.unreq ctrl_l2
.unreq addr_qpu


/**
 * function v3d32_clear_qpucache
 * Clear Cache Near QPU of VideoCore IV from ARM
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Bit[27:24]: TMU1, Bit[19:16]: TMU0, Bit[11:8]: Uniforms, Bit[3:0] Instruction (per Slice, Write 0b1 to Clear Specified Slice's Cache)
 *
 * Return: r0 (0 as success)
 */
.globl v3d32_clear_qpucache
v3d32_clear_qpucache:
	/* Auto (Local) Variables, but just Aliases */
	clear_bit .req r0
	addr_qpu  .req r1

	push {lr}

	mov addr_qpu, #equ32_peripherals_base
	orr addr_qpu, addr_qpu, #v3d32_base

	/* Clear Caches Near QPU */
	str clear_bit, [addr_qpu, #v3d32_slcactl]

	v3d32_clear_qpucache_success:
		mov r0, #0

	v3d32_clear_qpucache_common:
		macro32_dsb ip
		pop {pc}

.unreq clear_bit
.unreq addr_qpu


/**
 * function v3d32_control_qpuinterrupt
 * Control Interrupt for QPU of VideoCore IV from ARM
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Bit[15:0] (Bit[15]: 0 as Disable, 1 as Enable QPU15 Interrupt, ...Bit[0]: 0 as Disable, 1 as Enable QPU0 Interrupt)
 *
 * Return: r0 (0 as success)
 */
.globl v3d32_control_qpuinterrupt
v3d32_control_qpuinterrupt:
	/* Auto (Local) Variables, but just Aliases */
	flags_enable .req r0
	addr_qpu     .req r1
	temp         .req r2

	push {lr}

	mov addr_qpu, #equ32_peripherals_base
	orr addr_qpu, addr_qpu, #v3d32_base

	/* Write Clear QPU Interrupt */
	ldr temp, [addr_qpu, #v3d32_dbqitc]
	str temp, [addr_qpu, #v3d32_dbqitc]

	/* Disable Interrupt */
	str flags_enable, [addr_qpu, #v3d32_dbqite]

	v3d32_control_qpuinterrupt_success:
		mov r0, #0

	v3d32_control_qpuinterrupt_common:
		macro32_dsb ip
		pop {pc}

.unreq flags_enable
.unreq addr_qpu
.unreq temp


/**
 * function v3d32_execute_qpu
 * Execute User Program for QPU of VideoCore IV from ARM
 * This function is using a vendor-implemented process.
 * This function is similar to the mail #0x00030011. However, in this funtion, QPU is controlled from ARM.
 * You need to make QPU enabled from ARM using "v3d32_enable_qpu".
 *
 * Parameters
 * r0: Number of QPUs to Be Executed
 * r1: Pointer of Array of Jobs, Pointer of Array of Uniforms and Pointer of Codes for QPU Alternatively
 * r2: 0 as Flush, 1 as No Flush
 * r3: Timeout in Turns
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): Time Out
 * Error(2): FIFO is Full
 */
.globl v3d32_execute_qpu
v3d32_execute_qpu:
	/* Auto (Local) Variables, but just Aliases */
	number_qpu     .req r0
	buffer_job     .req r1
	flag_noflush   .req r2
	timeout        .req r3
	addr_qpu       .req r4
	temp           .req r5
	dup_number_qpu .req r6

	push {r4-r6,lr}

	mov dup_number_qpu, number_qpu

	mov addr_qpu, #equ32_peripherals_base
	orr addr_qpu, addr_qpu, #v3d32_base

	/* Clear Counters */
	mov temp, #1|1<<7
	orr temp, temp, #1<<8
	orr temp, temp, #1<<16
	str temp, [addr_qpu, #v3d32_srqcs]

	macro32_dsb ip

	cmp flag_noflush, #1
	beq v3d32_execute_qpu_execute

	v3d32_execute_qpu_flush:
		/* Clear L2 Cache */
		mov temp, #0b100
		str temp, [addr_qpu, #v3d32_l2cactl]

		/* Clear Caches Near QPU */
		mov temp, #0xF<<24
		orr temp, temp, #0xF<<16
		orr temp, temp, #0xF<<8
		orr temp, temp, #0xF
		str temp, [addr_qpu, #v3d32_slcactl]

		macro32_dsb ip

	v3d32_execute_qpu_execute:
		subs dup_number_qpu, #1
		blo v3d32_execute_qpu_wait

		/* Store Uniforms Address */
		ldr temp, [buffer_job]
		str temp, [addr_qpu, #v3d32_srqua]
		add buffer_job, buffer_job, #4

		/* Store Uniforms Length as Unlimited */
		mov temp, #1024
		str temp, [addr_qpu, #v3d32_srqul]

		/* Store Code Address */
		ldr temp, [buffer_job]
		str temp, [addr_qpu, #v3d32_srqpc]
		add buffer_job, buffer_job, #4

		/* Test Queue Error, FIFO is Full */
		ldr temp, [addr_qpu, #v3d32_srqcs]
		tst temp, #1<<7
		bne v3d32_execute_qpu_error2

		macro32_dsb ip
		b v3d32_execute_qpu_execute

	v3d32_execute_qpu_wait:
		subs timeout, #1
		blo v3d32_execute_qpu_error1

		ldr temp, [addr_qpu, #v3d32_srqcs]

/*
macro32_debug temp, 400, 436
*/
		lsr temp, temp, #16
		cmp temp, number_qpu
		blo v3d32_execute_qpu_wait

		macro32_dsb ip

		b v3d32_execute_qpu_success

	v3d32_execute_qpu_error1:

/*
ldr temp, [addr_qpu, #v3d32_errstat]
macro32_debug temp, 400, 448
*/

		mov r0, #1
		b v3d32_execute_qpu_common

	v3d32_execute_qpu_error2:
		mov temp, #1<<7
		str temp, [addr_qpu, #v3d32_srqcs]
		mov r0, #2
		b v3d32_execute_qpu_common

	v3d32_execute_qpu_success:
		mov r0, #0

	v3d32_execute_qpu_common:
		macro32_dsb ip
		pop {r4-r6,pc}

.unreq number_qpu
.unreq buffer_job
.unreq flag_noflush
.unreq timeout
.unreq addr_qpu
.unreq temp
.unreq dup_number_qpu


/**
 * function v3d32_make_cl_binning
 * Initialize Control List for Binning
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Width in Pixel
 * r1: Height in Pixel
 * r2: Configuration Flags (8-bit)
 *     Bit[7]: Double-buffer in Non-ms (Non-multisample) Mode
 *     Bit[6:5]: Tile Allocation Block Size, 0 = 32 Bytes, 1 = 64 Bytes, 2 = 128 Bytes, 3 = 256 Bytes
 *     Bit[4:3]: Tile Allocation Initial Block Size, 0 = 32 Bytes, 1 = 64 Bytes, 2 = 128 Bytes, 3 = 256 Bytes
 *     Bit[2]: Auto-initialize Tile State Data Array
 *     Bit[1]: Tile Buffer 64-bit Color Depth
 *     Bit[0]: Multisample Mode 4x
 *
 * Return: r0 (0 as success, 1, 2 and 3 as error)
 * Error(1): _ObjectV3D Is Not Binded
 * Error(2): Failure of Allocating Memory
 * Error(3): Channel of DMA or CB Number is Overflow
 */
.globl v3d32_make_cl_binning
v3d32_make_cl_binning:
	/* Auto (Local) Variables, but just Aliases */
	width        .req r0
	height       .req r1
	flags_config .req r2
	num_tiles    .req r3
	temp         .req r4
	ptr_ctl_list .req r5
	offset       .req r6
	width_tile   .req r7
	height_tile  .req r8
	shaderstate  .req r9
	uniforms     .req r10
	objectv3d    .req r11

	push {r4-r11,lr}

	ldr objectv3d, V3D32_OBJECTV3D
	cmp objectv3d, #0
	beq v3d32_make_cl_binning_error1

	/* Calculate Number of Tiles */
	tst flags_config, #0b1
	addne width_tile, width, #31          @ Addition for Remainder
	lsrne width_tile, width_tile, #5      @ Divison by 32
	addne height_tile, height, #31        @ Addition for Remainder
	lsrne height_tile, height_tile, #5    @ Divison by 32
	addeq width_tile, width, #63          @ Addition for Remainder
	lsreq width_tile, width_tile, #6      @ Divison by 64
	addeq height_tile, height, #63        @ Addition for Remainder
	lsreq height_tile, height_tile, #6    @ Divison by 64
	mul num_tiles, width_tile, height_tile

	/* Load Template of Binning Control List to GPU Memory Space */

	push {r0-r3}
	ldr r0, V3D32_TML_CL_BIN_SIZE
	mov r1, #16
	mov r2, #0xC
	bl bcm32_allocate_memory
	cmp r0, #0
	mov temp, r0
	pop {r0-r3}

	ble v3d32_make_cl_binning_error2
	str temp, [objectv3d, #v3d32_make_cl_binning_handle0]

	push {r0-r3}
	mov r0, temp
	bl bcm32_lock_memory
	cmp r0, #-1
	mov ptr_ctl_list, r0
	pop {r0-r3}

	beq v3d32_make_cl_binning_error2

	push {r0-r3}
	mov r0, ptr_ctl_list
	ldr r1, V3D32_TML_CL_BIN
	orr r1, r1, #equ32_bus_coherence_base @ Convert to Bus Address
	ldr r2, V3D32_TML_CL_BIN_SIZE
	bl dma32_datacopy
	cmp r0, #0
	pop {r0-r3}

	bne v3d32_make_cl_binning_error3

	str ptr_ctl_list, [objectv3d, #v3d32_cl_bin]
	and ptr_ctl_list, ptr_ctl_list, #bcm32_mailbox_armmask

	/* Allocate Tile Allocation Memory at GPU Memory Space */

	push {r0-r3}
	lsl r0, num_tiles, #v3d32_make_cl_binning_buffersize
	mov r1, #256                          @ 256-byte Align
	mov r2, #0xC
	bl bcm32_allocate_memory
	cmp r0, #0
	mov temp, r0
	pop {r0-r3}

	ble v3d32_make_cl_binning_error2
	str temp, [objectv3d, #v3d32_make_cl_binning_handle1]

	push {r0-r3}
	mov r0, temp
	bl bcm32_lock_memory
	cmp r0, #-1
	mov temp, r0
	pop {r0-r3}

	beq v3d32_make_cl_binning_error2

	str temp, [objectv3d, #v3d32_tile_allocation]

	ldr offset, V3D32_TML_CL_BIN_CONFIG
	add offset, ptr_ctl_list, offset
	macro32_store_word temp, offset
	add offset, offset, #4

	/* Size of Tile Allocation Memory */
	lsl temp, num_tiles, #v3d32_make_cl_binning_buffersize
	macro32_store_word temp, offset
	add offset, offset, #4

	/* Allocate Tile State Data Array at GPU Memory Space */

	push {r0-r3}
	mov r0, #48
	mul r0, num_tiles, r0
	mov r1, #16
	mov r2, #0xC
	bl bcm32_allocate_memory
	cmp r0, #0
	mov temp, r0
	pop {r0-r3}

	ble v3d32_make_cl_binning_error2
	str temp, [objectv3d, #v3d32_make_cl_binning_handle2]

	push {r0-r3}
	mov r0, temp
	bl bcm32_lock_memory
	cmp r0, #-1
	mov temp, r0
	pop {r0-r3}

	beq v3d32_make_cl_binning_error2

	macro32_store_word temp, offset
	add offset, offset, #4

	/* Width in Tiles */
	strb width_tile, [offset]
	add offset, offset, #1

	/* Height in Tiles */
	strb height_tile, [offset]
	add offset, offset, #1

	/* Configuration */
	and flags_config, flags_config, #0xFF
	strb flags_config, [offset]

	/* Width and Height of Clip Window */
	ldr offset, V3D32_TML_CL_BIN_CLIP_WINDOW
	add offset, ptr_ctl_list, offset
	add offset, offset, #4
	macro32_store_hword width, offset
	add offset, offset, #2
	macro32_store_hword height, offset

	/* Load Template of NV Shader State to GPU Memory Space */

	push {r0-r3}
	ldr r0, V3D32_TML_NV_SHADERSTATE_SIZE
	mov r1, #16
	mov r2, #0xC
	bl bcm32_allocate_memory
	cmp r0, #0
	mov temp, r0
	pop {r0-r3}

	ble v3d32_make_cl_binning_error2
	str temp, [objectv3d, #v3d32_make_cl_binning_handle3]

	push {r0-r3}
	mov r0, temp
	bl bcm32_lock_memory
	cmp r0, #-1
	mov shaderstate, r0
	pop {r0-r3}

	beq v3d32_make_cl_binning_error2

	push {r0-r3}
	mov r0, shaderstate
	ldr r1, V3D32_TML_NV_SHADERSTATE
	orr r1, r1, #equ32_bus_coherence_base @ Convert to Bus Address
	ldr r2, V3D32_TML_NV_SHADERSTATE_SIZE
	bl dma32_datacopy
	cmp r0, #0
	pop {r0-r3}

	bne v3d32_make_cl_binning_error3

	/* Store GPU Memory Address of Shader State to Variable and Control List */
	str shaderstate, [objectv3d, #v3d32_nv_shaderstate]
	ldr offset, V3D32_TML_CL_BIN_NV_SHADERSTATE
	add offset, ptr_ctl_list, offset
	macro32_store_word shaderstate, offset

	and shaderstate, shaderstate, #bcm32_mailbox_armmask

	/* Load Template of Uniforms to GPU Memory Space */

	push {r0-r3}
	ldr r0, V3D32_TML_UNIFORMS_SIZE
	mov r1, #16
	mov r2, #0xC
	bl bcm32_allocate_memory
	cmp r0, #0
	mov temp, r0
	pop {r0-r3}

	ble v3d32_make_cl_binning_error2
	str temp, [objectv3d, #v3d32_make_cl_binning_handle4]

	push {r0-r3}
	mov r0, temp
	bl bcm32_lock_memory
	cmp r0, #-1
	mov uniforms, r0
	pop {r0-r3}

	beq v3d32_make_cl_binning_error2

	push {r0-r3}
	mov r0, uniforms
	ldr r1, V3D32_TML_UNIFORMS
	orr r1, r1, #equ32_bus_coherence_base @ Convert to Bus Address
	ldr r2, V3D32_TML_UNIFORMS_SIZE
	bl dma32_datacopy
	cmp r0, #0
	pop {r0-r3}

	bne v3d32_make_cl_binning_error3

	/* Store GPU Memory Address of Uniforms to Variable and NV Shader State */
	str uniforms, [objectv3d, #v3d32_uniforms]
	str uniforms, [shaderstate, #8]

	b v3d32_make_cl_binning_success

	v3d32_make_cl_binning_error1:
		mov r0, #1
		b v3d32_make_cl_binning_common

	v3d32_make_cl_binning_error2:
		mov r0, #2
		b v3d32_make_cl_binning_common

	v3d32_make_cl_binning_error3:
		mov r0, #3
		b v3d32_make_cl_binning_common

	v3d32_make_cl_binning_success:
		mov r0, #0

	v3d32_make_cl_binning_common:
		macro32_dsb ip
		pop {r4-r11,pc}

.unreq width
.unreq height
.unreq flags_config
.unreq num_tiles
.unreq temp
.unreq ptr_ctl_list
.unreq offset
.unreq width_tile
.unreq height_tile
.unreq shaderstate
.unreq uniforms
.unreq objectv3d


/**
 * function v3d32_unmake_cl_binning
 * Free Control List for Binning
 * This function is using a vendor-implemented process.
 * Caution that this function needs to follow v3d32_make_cl_binning which is set the tile allocation memory.
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): _ObjectV3D Is Not Binded
 * Error(2): Error in Response from Mailbox
 */
.globl v3d32_unmake_cl_binning
v3d32_unmake_cl_binning:
	/* Auto (Local) Variables, but just Aliases */
	handle     .req r0
	objectv3d  .req r1

	push {lr}

	ldr objectv3d, V3D32_OBJECTV3D
	cmp objectv3d, #0
	beq v3d32_unmake_cl_binning_error1

	ldr handle, [objectv3d, #v3d32_make_cl_binning_handle0]

	push {r0-r1}
	bl bcm32_unlock_memory
	cmp r0, #-1
	pop {r0-r1}

	beq v3d32_unmake_cl_binning_error2

	push {r0-r1}
	bl bcm32_release_memory
	cmp r0, #-1
	pop {r0-r1}

	beq v3d32_unmake_cl_binning_error2

	ldr handle, [objectv3d, #v3d32_make_cl_binning_handle1]

	push {r0-r1}
	bl bcm32_unlock_memory
	cmp r0, #-1
	pop {r0-r1}

	beq v3d32_unmake_cl_binning_error2

	push {r0-r1}
	bl bcm32_release_memory
	cmp r0, #-1
	pop {r0-r1}

	beq v3d32_unmake_cl_binning_error2

	ldr handle, [objectv3d, #v3d32_make_cl_binning_handle2]

	push {r0-r1}
	bl bcm32_unlock_memory
	cmp r0, #-1
	pop {r0-r1}

	beq v3d32_unmake_cl_binning_error2

	push {r0-r1}
	bl bcm32_release_memory
	cmp r0, #-1
	pop {r0-r1}

	beq v3d32_unmake_cl_binning_error2

	ldr handle, [objectv3d, #v3d32_make_cl_binning_handle3]

	push {r0-r1}
	bl bcm32_unlock_memory
	cmp r0, #-1
	pop {r0-r1}

	beq v3d32_unmake_cl_binning_error2

	push {r0-r1}
	bl bcm32_release_memory
	cmp r0, #-1
	pop {r0-r1}

	beq v3d32_unmake_cl_binning_error2

	ldr handle, [objectv3d, #v3d32_make_cl_binning_handle4]

	push {r0-r1}
	bl bcm32_unlock_memory
	cmp r0, #-1
	pop {r0-r1}

	beq v3d32_unmake_cl_binning_error2

	push {r0-r1}
	bl bcm32_release_memory
	cmp r0, #-1
	pop {r0-r1}

	beq v3d32_unmake_cl_binning_error2

	mov handle, #0
	str handle, [objectv3d, #v3d32_make_cl_binning_handle0]
	str handle, [objectv3d, #v3d32_make_cl_binning_handle1]
	str handle, [objectv3d, #v3d32_make_cl_binning_handle2]
	str handle, [objectv3d, #v3d32_make_cl_binning_handle3]
	str handle, [objectv3d, #v3d32_make_cl_binning_handle4]
	str handle, [objectv3d, #v3d32_cl_bin]
	str handle, [objectv3d, #v3d32_tile_allocation]
	str handle, [objectv3d, #v3d32_nv_shaderstate]
	str handle, [objectv3d, #v3d32_uniforms]

	b v3d32_unmake_cl_binning_success

	v3d32_unmake_cl_binning_error1:
		mov r0, #1
		b v3d32_unmake_cl_binning_common

	v3d32_unmake_cl_binning_error2:
		mov r0, #2
		b v3d32_unmake_cl_binning_common

	v3d32_unmake_cl_binning_success:
		mov r0, #0

	v3d32_unmake_cl_binning_common:
		macro32_dsb ip
		pop {pc}

.unreq handle
.unreq objectv3d


/**
 * function v3d32_config_cl_binning
 * Set Configuration Bits in Control List for Binning
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Configuration Flags (18-bit)
 *     Bit[17]: Early Z Updates Enable
 *     Bit[16]: Early Z Enable
 *     Bit[15]: Z Updates Enable
 *     Bit[14:12]: Depth Test Function, 0 = never, 1 = lt, 2 = eq, 3 = le, 4 = gt, 5 = ne, 6 = ge, 7 = always
 *     Bit[11]: Coverage Read Mode, 0 = Clear on Read, 1 = Leave on Read
 *     Bit[10:9]: Coverage Update Mode, 0 = Non-zero, 1 = Odd, 2 = Or, 3 = Zero
 *     Bit[8]: Coverage Pipe Select
 *     Bit[7:6]: Rasteriser Oversample Mode, 0 = None, 1 = 4x, 2 = 16x
 *     Bit[5]: Coverage Read Type, 0 = 32-bit, 1 = 16-bit
 *     Bit[4]: Antialiased Points and Lines
 *     Bit[3]: Enable Depth Offset
 *     Bit[2]: Clockwise Primitives (Actually Counter-clockwise by Set)
 *     Bit[1]: Enable Reverse Facing Primitive
 *     Bit[0]: Enable Forward Facing Primitive
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): _ObjectV3D Is Not Binded
 * Error(2): Control List for Binning Is Not Initialized
 */
.globl v3d32_config_cl_binning
v3d32_config_cl_binning:
	/* Auto (Local) Variables, but just Aliases */
	flags_config .req r0
	ptr_ctl_list .req r1
	offset       .req r2
	objectv3d    .req r3

	push {lr}

	ldr objectv3d, V3D32_OBJECTV3D
	cmp objectv3d, #0
	beq v3d32_config_cl_binning_error1
	ldr ptr_ctl_list, [objectv3d, #v3d32_cl_bin]
	cmp ptr_ctl_list, #0
	beq v3d32_config_cl_binning_error2

	and ptr_ctl_list, ptr_ctl_list, #bcm32_mailbox_armmask
	ldr offset, V3D32_TML_CL_BIN_CONFIG_BITS
	bic flags_config, flags_config, #0xFF000000
	bic flags_config, flags_config, #0x00F00000

	strb flags_config, [ptr_ctl_list, offset]
	add offset, offset, #1
	lsr flags_config, flags_config, #8

	strb flags_config, [ptr_ctl_list, offset]
	add offset, offset, #1
	lsr flags_config, flags_config, #8

	strb flags_config, [ptr_ctl_list, offset]

	b v3d32_config_cl_binning_success

	v3d32_config_cl_binning_error1:
		mov r0, #1
		b v3d32_config_cl_binning_common

	v3d32_config_cl_binning_error2:
		mov r0, #2
		b v3d32_config_cl_binning_common

	v3d32_config_cl_binning_success:
		mov r0, #0

	v3d32_config_cl_binning_common:
		macro32_dsb ip
		pop {pc}

.unreq flags_config
.unreq ptr_ctl_list
.unreq offset
.unreq objectv3d


/**
 * function v3d32_make_cl_rendering
 * Initialize Control List for Rendering
 * This function is using a vendor-implemented process.
 * Caution that this function needs to follow v3d32_make_cl_binning which is set the tile allocation memory.
 *
 * Parameters
 * r0: Width in Pixel
 * r1: Height in Pixel
 * r2: Configuration Flags (16-bit)
 *     Bit[15:13]: Reserved
 *     Bit[12]: Double-buffer in Non-ms (Non-multisample) Mode
 *     Bit[11]: Early Z / Early Coverage Disable
 *     Bit[10]: Early Z Update Direction, 0 = lt/le, 1 = gt/ge
 *     Bit[9]: Select Coverage Mode
 *     Bit[8]: Enable VG (Alpha) Mask Buffer
 *     Bit[7:6]: Texture Memory Format, 0 = Linear, 1 = T-format, 2 = LT-format
 *     Bit[5:4]: Decimate Mode, 0 = 1x, 1 = 4x, 2 = 16x
 *     Bit[3:2]: Non-HDR Frame Buffer Color Format, 0 = BGR565 Dithered, 1 = RGBA8888, 2 = BGR565
 *     Bit[1]: Tile Buffer 64-bit Color Depth (HDR Mode)
 *     Bit[0]: Multisample Mode 4x
 *
 * Return: r0 (0 as success, 1, 2 and 3 as error)
 * Error(1): _ObjectV3D Is Not Binded
 * Error(2): Failure of Allocating Memory
 * Error(3): Channel of DMA or CB Number is Overflow
 */
.globl v3d32_make_cl_rendering
v3d32_make_cl_rendering:
	/* Auto (Local) Variables, but just Aliases */
	width        .req r0
	height       .req r1
	flags_config .req r2
	buffer_addr  .req r3
	num_tiles    .req r4
	ptr_ctl_list .req r5
	offset       .req r6
	temp         .req r7
	size         .req r8
	width_tile   .req r9
	height_tile  .req r10
	objectv3d    .req r11

	push {r4-r11,lr}

	ldr objectv3d, V3D32_OBJECTV3D
	cmp objectv3d, #0
	beq v3d32_make_cl_rendering_error1

	/* Calculate Number of Tiles */
	tst flags_config, #0b1
	addne width_tile, width, #31          @ Addition for Remainder
	lsrne width_tile, width_tile, #5      @ Divison by 32
	addne height_tile, height, #31        @ Addition for Remainder
	lsrne height_tile, height_tile, #5    @ Divison by 32
	addeq width_tile, width, #63          @ Addition for Remainder
	lsreq width_tile, width_tile, #6      @ Divison by 64
	addeq height_tile, height, #63        @ Addition for Remainder
	lsreq height_tile, height_tile, #6    @ Divison by 64
	mul num_tiles, width_tile, height_tile

	/* Calculate Size of Control List */
	mov temp, #9                          @ Calculate Size for Multi-sample Tile Buffer on Each Tile, 9 Bytes per Tile
	mul size, num_tiles, temp
	ldr temp, V3D32_TML_CL_RENDER_SIZE    @ Size for Template
	add size, temp, size
	str size, [objectv3d, #v3d32_cl_render_size]

	/* Load Template of Rendring Control List to GPU Memory Space */

	push {r0-r3}
	mov r0, size
	mov r1, #16
	mov r2, #0xC
	bl bcm32_allocate_memory
	cmp r0, #0
	mov temp, r0
	pop {r0-r3}

	ble v3d32_make_cl_rendering_error2
	str temp, [objectv3d, #v3d32_make_cl_rendering_handle0]

	push {r0-r3}
	mov r0, temp
	bl bcm32_lock_memory
	cmp r0, #-1
	mov ptr_ctl_list, r0
	pop {r0-r3}

	beq v3d32_make_cl_rendering_error2

	push {r0-r3}
	mov r0, ptr_ctl_list
	ldr r1, V3D32_TML_CL_RENDER
	orr r1, r1, #equ32_bus_coherence_base         @ Convert to Bus Address
	mov r2, size
	bl dma32_datacopy
	cmp r0, #0
	pop {r0-r3}

	bne v3d32_make_cl_rendering_error3

	str ptr_ctl_list, [objectv3d, #v3d32_cl_render]
	and ptr_ctl_list, ptr_ctl_list, #bcm32_mailbox_armmask

	ldr offset, V3D32_TML_CL_RENDER_CONFIG
	add offset, ptr_ctl_list, offset
	add offset, offset, #4

	/* Width in Pixel */
	macro32_store_hword width, offset
	add offset, offset, #2

	/* Height in Pixel */
	macro32_store_hword height, offset
	add offset, offset, #2

	/* Configuration */
	bic flags_config, flags_config, #0xFF000000
	bic flags_config, flags_config, #0xFF0000
	macro32_store_hword flags_config, offset

	.unreq width
	.unreq height
	i .req r0
	j .req r1

	/* Tiles */
	ldr offset, V3D32_TML_CL_RENDER_SIZE
	add offset, ptr_ctl_list, offset

	ldr buffer_addr, [objectv3d, #v3d32_tile_allocation]
	mov j, #0                        @ Row (Height of Tiles)

	v3d32_make_cl_rendering_tiles:
		cmp j, height_tile
		bhs v3d32_make_cl_rendering_success
		mov i, #0                        @ Column (Width of Tiles)

		v3d32_make_cl_rendering_tiles_column:
			cmp i, width_tile
			addhs j, j, #1
			bhs v3d32_make_cl_rendering_tiles

			/**
			 * Tile Coordinates
			 * 1. Tile Column Number (8-bit)
			 * 2. Tile Row Number (8-bit)
			 */
			mov temp, #v3d32_cl_tile_coordinates
			strb temp, [offset]
			add offset, offset, #1
			strb i, [offset]
			add offset, offset, #1
			strb j, [offset]
			add offset, offset, #1

			mov temp, #v3d32_cl_branch_sublist
			strb temp, [offset]
			add offset, offset, #1

			mul temp, j, width_tile
			add temp, temp, i
			lsl temp, temp, #5                          @ Multiply by 32
			add temp, temp, buffer_addr
			macro32_store_word temp, offset
			add offset, offset, #4

			/* Last Tile Should Be with Signal End */
			add i, i, #1                                @ Increment
			add j, j, #1                                @ Increment for Test
			cmp i, width_tile
			cmphs j, height_tile
			movhs temp, #v3d32_cl_store_tilebuffer_multiend
			movlo temp, #v3d32_cl_store_tilebuffer_multi
			sub j, j, #1                                @ Decrement to Retrieve
			strb temp, [offset]
			add offset, offset, #1

			b v3d32_make_cl_rendering_tiles_column

	v3d32_make_cl_rendering_error1:
		mov r0, #1
		b v3d32_make_cl_rendering_common

	v3d32_make_cl_rendering_error2:
		mov r0, #2
		b v3d32_make_cl_rendering_common

	v3d32_make_cl_rendering_error3:
		mov r0, #3
		b v3d32_make_cl_rendering_common

	v3d32_make_cl_rendering_success:
		mov r0, #0

	v3d32_make_cl_rendering_common:
		macro32_dsb ip
		pop {r4-r11,pc}

.unreq i
.unreq j
.unreq buffer_addr
.unreq flags_config
.unreq num_tiles
.unreq ptr_ctl_list
.unreq offset
.unreq temp
.unreq size
.unreq width_tile
.unreq height_tile
.unreq objectv3d


/**
 * function v3d32_unmake_cl_rendering
 * Free Control List for Rendering
 * This function is using a vendor-implemented process.
 * Caution that this function needs to follow v3d32_make_cl_binning which is set the tile allocation memory.
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): _ObjectV3D Is Not Binded
 * Error(2): Error in Response from Mailbox
 */
.globl v3d32_unmake_cl_rendering
v3d32_unmake_cl_rendering:
	/* Auto (Local) Variables, but just Aliases */
	handle    .req r0
	objectv3d .req r1

	push {lr}

	ldr objectv3d, V3D32_OBJECTV3D
	cmp objectv3d, #0
	beq v3d32_unmake_cl_rendering_error1

	ldr handle, [objectv3d, #v3d32_make_cl_rendering_handle0]

	push {r0-r1}
	bl bcm32_unlock_memory
	cmp r0, #-1
	pop {r0-r1}

	beq v3d32_unmake_cl_rendering_error2

	push {r0-r1}
	bl bcm32_release_memory
	cmp r0, #-1
	pop {r0-r1}

	beq v3d32_unmake_cl_rendering_error2

	mov handle, #0
	str handle, [objectv3d, #v3d32_make_cl_rendering_handle0]
	str handle, [objectv3d, #v3d32_cl_render]
	str handle, [objectv3d, #v3d32_cl_render_size]

	b v3d32_unmake_cl_rendering_success

	v3d32_unmake_cl_rendering_error1:
		mov r0, #1
		b v3d32_unmake_cl_rendering_common

	v3d32_unmake_cl_rendering_error2:
		mov r0, #2
		b v3d32_unmake_cl_rendering_common

	v3d32_unmake_cl_rendering_success:
		mov r0, #0

	v3d32_unmake_cl_rendering_common:
		macro32_dsb ip
		pop {pc}

.unreq handle
.unreq objectv3d


/**
 * function v3d32_clear_cl_rendering
 * Set Value of Clear Color, Z, VG (Alpha) Mask, and Stencil
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Clear Color, RGBA8888 (32-bit)
 * r1: Clear Z (24-bit)
 * r2: Clear VG (Alpha) Mask (8-bit)
 * r3: Clear Stencil (8-bit)
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): _ObjectV3D Is Not Binded
 * Error(2): Control List for Rendering Is Not Initialized
 */
.globl v3d32_clear_cl_rendering
v3d32_clear_cl_rendering:
	/* Auto (Local) Variables, but just Aliases */
	clear_color   .req r0
	clear_z       .req r1
	clear_alpha   .req r2
	clear_stencil .req r3
	ptr_ctl_list  .req r4
	objectv3d     .req r5

	push {r4-r5,lr}

	ldr objectv3d, V3D32_OBJECTV3D
	cmp objectv3d, #0
	beq v3d32_clear_cl_rendering_error1
	ldr ptr_ctl_list, [objectv3d, #v3d32_cl_render]
	cmp ptr_ctl_list, #0
	beq v3d32_clear_cl_rendering_error2

	and ptr_ctl_list, ptr_ctl_list, #bcm32_mailbox_armmask
	add ptr_ctl_list, ptr_ctl_list, #1

	/* Two Sets of RGBA8888 (64-bit) */
	macro32_store_word clear_color, ptr_ctl_list
	add ptr_ctl_list, ptr_ctl_list, #4
	macro32_store_word clear_color, ptr_ctl_list
	add ptr_ctl_list, ptr_ctl_list, #4

	/* Z (24-bit) */
	strb clear_z, [ptr_ctl_list]
	add ptr_ctl_list, ptr_ctl_list, #1
	lsr clear_z, clear_z, #8

	strb clear_z, [ptr_ctl_list]
	add ptr_ctl_list, ptr_ctl_list, #1
	lsr clear_z, clear_z, #8

	strb clear_z, [ptr_ctl_list]
	add ptr_ctl_list, ptr_ctl_list, #1
	lsr clear_z, clear_z, #8

	/* VG (Alpha) Mask (8-bit) */
	strb clear_alpha, [ptr_ctl_list]
	add ptr_ctl_list, ptr_ctl_list, #1

	/* Clear Stencil (8-bit) */
	strb clear_stencil, [ptr_ctl_list]

/*
ldr ptr_ctl_list, V3D32_CL_RENDER
and ptr_ctl_list, ptr_ctl_list, #bcm32_mailbox_armmask
macro32_debug_hexa ptr_ctl_list, 0, 12, 1280
*/

	b v3d32_clear_cl_rendering_success

	v3d32_clear_cl_rendering_error1:
		mov r0, #1
		b v3d32_clear_cl_rendering_common

	v3d32_clear_cl_rendering_error2:
		mov r0, #2
		b v3d32_clear_cl_rendering_common

	v3d32_clear_cl_rendering_success:
		mov r0, #0

	v3d32_clear_cl_rendering_common:
		macro32_dsb ip
		pop {r4-r5,pc}

.unreq clear_color
.unreq clear_z
.unreq clear_alpha
.unreq clear_stencil
.unreq ptr_ctl_list
.unreq objectv3d


/**
 * function v3d32_setbuffer_cl_rendering
 * Change Framebuffer to Render
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Pointer of Start Address of Framebuffer (ARM Side)
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): _ObjectV3D Is Not Binded
 * Error(2): Control List for Rendering Is Not Initialized
 */
.globl v3d32_setbuffer_cl_rendering
v3d32_setbuffer_cl_rendering:
	/* Auto (Local) Variables, but just Aliases */
	buffer_addr  .req r0
	ptr_ctl_list .req r1
	offset       .req r2
	objectv3d    .req r3

	push {lr}

	ldr objectv3d, V3D32_OBJECTV3D
	cmp objectv3d, #0
	beq v3d32_setbuffer_cl_rendering_error1
	ldr ptr_ctl_list, [objectv3d, #v3d32_cl_render]
	cmp ptr_ctl_list, #0
	beq v3d32_setbuffer_cl_rendering_error2

	and ptr_ctl_list, ptr_ctl_list, #bcm32_mailbox_armmask
	ldr offset, V3D32_TML_CL_RENDER_CONFIG
	add ptr_ctl_list, ptr_ctl_list, offset
	macro32_store_word buffer_addr, ptr_ctl_list

/*
ldr ptr_ctl_list, V3D32_CL_RENDER
and ptr_ctl_list, ptr_ctl_list, #bcm32_mailbox_armmask
macro32_debug_hexa ptr_ctl_list, 0, 12, 1280
*/

	b v3d32_setbuffer_cl_rendering_success

	v3d32_setbuffer_cl_rendering_error1:
		mov r0, #1
		b v3d32_setbuffer_cl_rendering_common

	v3d32_setbuffer_cl_rendering_error2:
		mov r0, #2
		b v3d32_setbuffer_cl_rendering_common

	v3d32_setbuffer_cl_rendering_success:
		mov r0, #0

	v3d32_setbuffer_cl_rendering_common:
		macro32_dsb ip
		pop {pc}

.unreq buffer_addr
.unreq ptr_ctl_list
.unreq offset
.unreq objectv3d


/**
 * function v3d32_execute_cl_binning
 * Execute Control List for Binning
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Primitive Mode, 0 = Points, 1 = Lines, 2 = Line_loop, 3 = Line_strip, 4 = Triangles, 5 = Triangle_strip, 6 = Triangle_fan (8-bit)
 * r1: Number of Vertices (32-bit)
 * r2: Index of First Vertex (32-bit)
 * r3: Timeout in Turns
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): _ObjectV3D Is Not Binded
 * Error(2): Time Out
 */
.globl v3d32_execute_cl_binning
v3d32_execute_cl_binning:
	/* Auto (Local) Variables, but just Aliases */
	primitive    .req r0
	num_vertex   .req r1
	index_vertex .req r2
	timeout      .req r3
	addr_qpu     .req r4
	ptr_ctl_list .req r5
	temp         .req r6
	objectv3d    .req r7

	push {r4-r7,lr}

	ldr objectv3d, V3D32_OBJECTV3D
	cmp objectv3d, #0
	beq v3d32_execute_cl_binning_error1

	mov addr_qpu, #equ32_peripherals_base
	orr addr_qpu, addr_qpu, #v3d32_base

	/* Write 1 to Clear */
	mov temp, #1
	str temp, [addr_qpu, #v3d32_bfc]

	ldr ptr_ctl_list, [objectv3d, #v3d32_cl_bin]
	and ptr_ctl_list, ptr_ctl_list, #bcm32_mailbox_armmask

	/* Set Vertex Array Primitives */
	ldr temp, V3D32_TML_CL_BIN_VERTEXARRAY_PRIMITIVES
	add temp, temp, ptr_ctl_list
	strb primitive, [temp]
	add temp, temp, #1
	macro32_store_word num_vertex, temp
	add temp, temp, #4
	macro32_store_word index_vertex, temp

	ldr ptr_ctl_list, [objectv3d, #v3d32_cl_bin]
	str ptr_ctl_list, [addr_qpu, #v3d32_ct0ca]
	macro32_dsb ip

	ldr temp, V3D32_TML_CL_BIN_SIZE
	add ptr_ctl_list, ptr_ctl_list, temp
	str ptr_ctl_list, [addr_qpu, #v3d32_ct0ea]
	macro32_dsb ip

	v3d32_execute_cl_binning_loop:
		subs timeout, #1
		blo v3d32_execute_cl_binning_error2
/*
ldr temp, [addr_qpu, #v3d32_intctl]
str temp, [addr_qpu, #v3d32_intctl]
macro32_debug temp, 300, 300
*/
		ldr temp, [addr_qpu, #v3d32_bfc]
		macro32_dsb ip
		cmp temp, #0
		bls v3d32_execute_cl_binning_loop

		/* Write 1 to Clear */
		mov temp, #1
		str temp, [addr_qpu, #v3d32_bfc]

		b v3d32_execute_cl_binning_success

	v3d32_execute_cl_binning_error1:
		mov r0, #1
		b v3d32_execute_cl_binning_common

	v3d32_execute_cl_binning_error2:
		mov r0, #2
		b v3d32_execute_cl_binning_common

	v3d32_execute_cl_binning_success:
		mov r0, #0

	v3d32_execute_cl_binning_common:
		macro32_dsb ip
		pop {r4-r7,pc}

.unreq primitive
.unreq num_vertex
.unreq index_vertex
.unreq timeout
.unreq addr_qpu
.unreq ptr_ctl_list
.unreq temp
.unreq objectv3d


/**
 * function v3d32_execute_cl_rendering
 * Execute Control List for Rendering
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Timeout in Turns
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): _ObjectV3D Is Not Binded
 * Error(2): Time Out
 */
.globl v3d32_execute_cl_rendering
v3d32_execute_cl_rendering:
	/* Auto (Local) Variables, but just Aliases */
	timeout      .req r0
	addr_qpu     .req r1
	ptr_ctl_list .req r2
	temp         .req r3
	objectv3d    .req r4

	push {r4,lr}

	ldr objectv3d, V3D32_OBJECTV3D
	cmp objectv3d, #0
	beq v3d32_execute_cl_rendering_error1

	mov addr_qpu, #equ32_peripherals_base
	orr addr_qpu, addr_qpu, #v3d32_base

	/* Write 1 to Clear */
	mov temp, #1
	str temp, [addr_qpu, #v3d32_rfc]

	ldr ptr_ctl_list, [objectv3d, #v3d32_cl_render]
	str ptr_ctl_list, [addr_qpu, #v3d32_ct1ca]
	macro32_dsb ip

	ldr temp, [objectv3d, #v3d32_cl_render_size]
	add ptr_ctl_list, ptr_ctl_list, temp
	str ptr_ctl_list, [addr_qpu, #v3d32_ct1ea]
	macro32_dsb ip

	v3d32_execute_cl_rendering_loop:
		subs timeout, #1
		blo v3d32_execute_cl_rendering_error2

		ldr temp, [addr_qpu, #v3d32_rfc]
		macro32_dsb ip
		cmp temp, #0
		bls v3d32_execute_cl_rendering_loop

		/* Write 1 to Clear */
		mov temp, #1
		str temp, [addr_qpu, #v3d32_rfc]

		b v3d32_execute_cl_rendering_success

	v3d32_execute_cl_rendering_error1:
		mov r0, #1
		b v3d32_execute_cl_rendering_common

	v3d32_execute_cl_rendering_error2:
		mov r0, #2
		b v3d32_execute_cl_rendering_common

	v3d32_execute_cl_rendering_success:
		mov r0, #0

	v3d32_execute_cl_rendering_common:
		macro32_dsb ip
		pop {r4,pc}

.unreq timeout
.unreq addr_qpu
.unreq ptr_ctl_list
.unreq temp
.unreq objectv3d


/**
 * function v3d32_set_nv_shaderstate
 * Set NV Shader State
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Pointer of Fragment Shader Code Address (GPU Side)
 * r1: Pointer of Shaded Vertex Data Address (GPU Side)
 * r2: Fragment Shader Number of Varyings
 * r3: Shaded Vertex Data Stride in Bytes
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): _ObjectV3D Is Not Binded
 * Error(2): Address of NV Shader State in _ObjectV3D Is Not Initialized
 */
.globl v3d32_set_nv_shaderstate
v3d32_set_nv_shaderstate:
	/* Auto (Local) Variables, but just Aliases */
	shader        .req r0
	vertex        .req r1
	num_varying   .req r2
	stride_vertex .req r3
	shaderstate   .req r4
	objectv3d     .req r5

	push {r4-r5,lr}

	ldr objectv3d, V3D32_OBJECTV3D
	cmp objectv3d, #0
	beq v3d32_set_nv_shaderstate_error1
	ldr shaderstate, [objectv3d, #v3d32_nv_shaderstate]
	cmp shaderstate, #0
	beq v3d32_set_nv_shaderstate_error2

	and shaderstate, shaderstate, #bcm32_mailbox_armmask
	str shader, [shaderstate, #4]
	str vertex, [shaderstate, #12]
	strb num_varying, [shaderstate, #3]
	strb stride_vertex, [shaderstate, #1]

	b v3d32_set_nv_shaderstate_success

	v3d32_set_nv_shaderstate_error1:
		mov r0, #1
		b v3d32_set_nv_shaderstate_common

	v3d32_set_nv_shaderstate_error2:
		mov r0, #2
		b v3d32_set_nv_shaderstate_common

	v3d32_set_nv_shaderstate_success:
		mov r0, #0

	v3d32_set_nv_shaderstate_common:
		macro32_dsb ip
		pop {r4-r5,pc}

.unreq shader
.unreq vertex
.unreq num_varying
.unreq stride_vertex
.unreq shaderstate
.unreq objectv3d


/**
 * function v3d32_texture2d_init
 * Set _Texture2D Struct (Texture Data is 32-bit per Pixel)
 * This function is using a vendor-implemented process.
 * Note that this function reserves new memory space at GPU side.
 *
 * The _Texture2D is structured by 4 words as decribed below.
 *
 * typedef struct v3d32_Texture2D {
 *  uint32 gpu; // Address of GPU Memory (GPU Side)
 *  uint32 handle_gpu_memory;
 *  uint16 width; // In Pixel
 *  uint16 height; // In Pixel
 *  uchar8 num_mipmap; // Number of Mipmap Levels - 1
 *  uchar8 log2_lod0; // Log Base 2 of Size of Texture LOD 0 in Bytes
 *  uint16 rsv16; // For 4-byte Align
 * } _Texture2D;
 *
 * The start address of the texture level-of-detail (LOD) 0 needs to be aligned by 4096 bytes.
 * To store mipmaps before the start address,
 * the size of the texture image for LOD 0 has to be at least 16384 bytes, e.g., 64 (width) * 64 (height) * 4 (bytes).
 *
 * Parameters
 * r0: Pointer of _Texture2D to Set (ARM Side)
 * r1: Bit[31:16]: Height in Pixel, Bit[15:0]: Width in Pixel, Up to 2047
 * r2: Size of Texture Level-of-Detail (LOD) 0 in Bytes, Needs to Be Power of 4, Minimum 4096
 * r3: Number of Mipmap Levels Minus 1, Up to 15
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Error in Response from Mailbox
 */
.globl v3d32_texture2d_init
v3d32_texture2d_init:
	/* Auto (Local) Variables, but just Aliases */
	texture2d  .req r0
	width      .req r1
	size       .req r2
	num_mipmap .req r3
	height     .req r4
	temp       .req r5

	push {r4-r5,lr}

	/* Extract Width and Height Separately */
	lsr height, width, #16
	mov temp, #0x700
	orr temp, temp, #0x0FF
	and width, width, temp
	strh width, [texture2d, #8]
	and height, height, temp
	strh height, [texture2d, #10]

	/* Calculate Log Base 2 of Size of Texture LOD 0 in Bytes */
	clz size, size                        @ Count Leading Zeros
	mov temp, #31
	sub size, temp, size
	cmp size, #12                         @ At Least log2(4096) = 12
	movlt size, #12
	strb size, [texture2d, #13]

	/* Clear Number of Mipmap Level Minus 1 If Size Is Up to 16384 */
	and num_mipmap, num_mipmap, #0xF
	cmp size, #14                         @ From log2(16384)
	movlo num_mipmap, #0
	strb num_mipmap, [texture2d, #12]

	/* Calculate Size to Allocate GPU Memory in Bytes */
	mov temp, #1
	lsl size, temp, size

	/* Make Buffer for Texture at GPU Side */

	push {r0-r3}
	/* Add Half of Size of Texture LOD 0 If Any Mimmap Exist */
	cmp num_mipmap, #0
	addhi r0, size, size, lsr #1
	movls r0, size
	mov r1, #4096
	mov r2, #0xC
	bl bcm32_allocate_memory
	cmp r0, #-1
	mov temp, r0
	pop {r0-r3}

	beq v3d32_texture2d_init_error

	str temp, [texture2d, #4]             @ Error Number (0xFFFFFFFF) in bcm32_allocate_memory Is Also Stored

	push {r0-r3}
	mov r0, temp
	bl bcm32_lock_memory
	cmp r0, #-1
	mov temp, r0
	pop {r0-r3}

	beq v3d32_texture2d_init_error

	cmp num_mipmap, #0
	addhi temp, temp, size, lsr #1
	str temp, [texture2d]

	b v3d32_texture2d_init_success

	v3d32_texture2d_init_error:
		mov r0, #1
		b v3d32_texture2d_init_common

	v3d32_texture2d_init_success:
		mov r0, #0

	v3d32_texture2d_init_common:
		macro32_dsb ip
		pop {r4-r5,pc}

.unreq texture2d
.unreq width
.unreq size
.unreq num_mipmap
.unreq height
.unreq temp


/**
 * function v3d32_texture2d_free
 * Clear _Texture2D Struct with Freeing Memory Space at GPU Side
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Pointer of _Texture2D to to Clear (ARM Side)
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Error in Response from Mailbox
 */
.globl v3d32_texture2d_free
v3d32_texture2d_free:
	/* Auto (Local) Variables, but just Aliases */
	texture2d .req r0
	temp      .req r1

	push {lr}

	ldr temp, [texture2d, #4]

	push {r0-r1}
	mov r0, temp
	bl bcm32_unlock_memory
	cmp r0, #-1
	pop {r0-r1}

	beq v3d32_texture2d_free_error

	push {r0-r1}
	mov r0, temp
	bl bcm32_release_memory
	cmp r0, #-1
	pop {r0-r1}

	beq v3d32_texture2d_free_error

	mov temp, #0
	str temp, [texture2d]
	str temp, [texture2d, #4]
	str temp, [texture2d, #8]
	str temp, [texture2d, #12]

	b v3d32_texture2d_free_success

	v3d32_texture2d_free_error:
		mov r0, #1
		b v3d32_texture2d_free_common

	v3d32_texture2d_free_success:
		mov r0, #0

	v3d32_texture2d_free_common:
		macro32_dsb ip
		pop {pc}

.unreq texture2d
.unreq temp


/**
 * function v3d32_load_texture2d
 * Load Texture Image to _Texture2D Struct (Texture Image is 32-bit per Pixel)
 * This function is using a vendor-implemented process.
 * Note that this function reserves new memory space at GPU side.
 *
 * Parameters
 * r0: Pointer of _Texture2D to Set (ARM Side)
 * r1: Pointer of Start Address of Texture Image (ARM Side)
 * r2: Mipmap Level
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): Channel of DMA or CB Number is Overflow
 * Error(2): Overflow of Mipmap Level
 */
.globl v3d32_load_texture2d
v3d32_load_texture2d:
	/* Auto (Local) Variables, but just Aliases */
	texture2d    .req r0
	texture      .req r1
	mipmap_level .req r2
	num_mipmap   .req r3
	size         .req r4
	addr_gpu     .req r5
	temp         .req r6
	addr_cache   .req r7

	push {r4-r7,lr}

	ldr addr_gpu, [texture2d]
	ldr num_mipmap, [texture2d, #12]
	ldr size, [texture2d, #13]
	mov temp, #1
	lsl size, temp, size

	v3d32_load_texture2d_loop:
		subs mipmap_level, mipmap_level, #1
		blo v3d32_load_texture2d_jump
		subs num_mipmap, num_mipmap, #1
		blo v3d32_load_texture2d_error2

		lsr size, size, #2
		sub addr_gpu, addr_gpu, size

		b v3d32_load_texture2d_loop

	v3d32_load_texture2d_jump:
		mov addr_cache, texture
		add temp, addr_cache, size
		bic addr_cache, addr_cache, #0x1F
		bic temp, temp, #0x1F

		v3d32_load_texture2d_cleancache:
			cmp addr_cache, temp
			bhi v3d32_load_texture2d_jump2

			macro32_clean_cache addr_cache ip
			macro32_dsb ip

			add addr_cache, addr_cache, #0x20 @ 32 Bytes (4 Words) Align
			b v3d32_load_texture2d_cleancache

	v3d32_load_texture2d_jump2:
		push {r0-r3}
		mov r0, addr_gpu
		orr r1, r1, #equ32_bus_coherence_base @ Convert to Bus Address
		mov r2, size
		bl dma32_datacopy
		cmp r0, #0
		pop {r0-r3}

		beq v3d32_load_texture2d_success

	v3d32_load_texture2d_error1:
		mov r0, #1
		b v3d32_load_texture2d_common

	v3d32_load_texture2d_error2:
		mov r0, #2
		b v3d32_load_texture2d_common

	v3d32_load_texture2d_success:
		mov r0, #0

	v3d32_load_texture2d_common:
		macro32_dsb ip
		pop {r4-r7,pc}

.unreq texture2d
.unreq texture
.unreq mipmap_level
.unreq num_mipmap
.unreq size
.unreq addr_gpu
.unreq temp
.unreq addr_cache


/**
 * function v3d32_set_texture2d
 * Clear Texture Object with Freeing Memory Space at GPU Side
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Pointer of Texture Object (ARM Side)
 * r1: Configuration Flags (9-bit)
 *     Bit[8]: Flip Texture Y Axis
 *     Bit[7]: Magnification Filter, 0 = LINEAR, 1 = NEAREST
 *     Bit[6:4]: Minification Filter, 0 = LINEAR, 1 = NEAREST, 2 = NEAR_MIP_NEAR, 3 = NEAR_MIP_LIN, 4 = LIN_MIP_NEAR, 5 = LIN_MIP_LIN
 *     Bit[3:2]: T Wrap Mode, 0 = Repeat, 1 = Clamp, 2 = Mirror, 3 = Border
 *     Bit[1:0]: S Wrap Mode, 0 = Repeat, 1 = Clamp, 2 = Mirror, 3 = Border
 * r2: Texture Data Type, 0 as RGBA8888, etc. (5-bit)
 * r3: Pointer of Additional Uniforms, Needed to Read Uniform (ra32/rb32) 3 Times in Fragment Shader
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): _ObjectV3D Is Not Binded
 * Error(2): Address of Uniforms in _ObjectV3D Is Not Initialized
 */
.globl v3d32_set_texture2d
v3d32_set_texture2d:
	/* Auto (Local) Variables, but just Aliases */
	texture2d    .req r0
	flags_config .req r1
	data_type    .req r2
	additional   .req r3
	uniforms     .req r4
	addr_gpu     .req r5
	width        .req r6
	height       .req r7
	num_mipmap   .req r8
	objectv3d    .req r9

	push {r4-r9,lr}

	ldr objectv3d, V3D32_OBJECTV3D
	cmp uniforms, #0
	beq v3d32_set_texture2d_error1
	ldr uniforms, [objectv3d, #v3d32_uniforms]
	cmp uniforms, #0
	beq v3d32_set_texture2d_error2

	and uniforms, uniforms, #bcm32_mailbox_armmask

	ldr addr_gpu, [texture2d]
	ldrh width, [texture2d, #8]
	ldrh height, [texture2d, #10]
	ldrb num_mipmap, [texture2d, #12]

	/* Set Texture Config Parameter 0 about Bit[8]: Flip Texture Y Axis */
	tst flags_config, #0x100                        @ Check Bit[8]
	orrne addr_gpu, addr_gpu, #0x100

	/* Store Texture Config Parameter 1 */
	lsl width, width, #8
	orr width, width, height, lsl #20
	tst data_type, #0x10
	orrne width, width, #0x80000000
	and flags_config, flags_config, #0xFF
	orr width, width, flags_config
	str width, [uniforms, #4]

	/* Store Texture Config Parameter 0 */
	orr addr_gpu, addr_gpu, num_mipmap
	and data_type, data_type, #0xF
	orr addr_gpu, addr_gpu, data_type, lsl #4
	str addr_gpu, [uniforms]

	mov num_mipmap, #0
	str num_mipmap, [uniforms, #8]
	str num_mipmap, [uniforms, #12]
	str additional, [uniforms, #16]

	b v3d32_set_texture2d_success

	v3d32_set_texture2d_error1:
		mov r0, #1
		b v3d32_set_texture2d_common

	v3d32_set_texture2d_error2:
		mov r0, #2
		b v3d32_set_texture2d_common

	v3d32_set_texture2d_success:
		mov r0, #0

	v3d32_set_texture2d_common:
		macro32_dsb ip
		pop {r4-r9,pc}

.unreq texture2d
.unreq flags_config
.unreq data_type
.unreq additional
.unreq uniforms
.unreq addr_gpu
.unreq width
.unreq height
.unreq num_mipmap
.unreq objectv3d


/**
 * function v3d32_gpumemory_init
 * Set _GPUMemory Strunct
 * This function is using a vendor-implemented process.
 * Note that this function reserves new memory space at GPU side.
 *
 * The _GPUMemmory is structured by 3 words as decribed below.
 *
 * typedef struct v3d32_GPUMemory {
 *  uint32 gpu; // Address of GPU Memory (GPU Side)
 *  uint32 handle_gpu_memory;
 *  union _arm {
 *   char8 s8;
 *   uchar8 u8;
 *   int16 s16;
 *   uint16 u16;
 *   int32 s32;
 *   uint32 u32;
 *   float32 f32;
 *  } *arm; // Address of GPU Memory (ARM Side)
 * } _GPUMemory;
 *
 * Parameters
 * r0: Pointer of _GPUMemory to Set (ARM Side)
 * r1: Size in Bytes
 * r2: Alignment in Bytes
 * r3: Bit[6]: Permanent Lock, Bit[5]: No Filled by 1 at Init, Bit[4]: Init by 0, Bit[3]: L2 Coherent "0x8", Bit[2]: Uncached "0xC", Bit[0]: Resizable with Cached, Bit[3]|Bit[2]: PoC
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Error in Response from Mailbox
 */
.globl v3d32_gpumemory_init
v3d32_gpumemory_init:
	/* Auto (Local) Variables, but just Aliases */
	gpumemory .req r0
	size      .req r1
	alignment .req r2
	flags     .req r3
	handle    .req r4
	addr_gpu  .req r5

	push {r4-r5,lr}

	push {r0-r3}
	mov r0, size
	mov r1, alignment
	mov r2, flags
	bl bcm32_allocate_memory
	cmp r0, #0
	mov handle, r0
	pop {r0-r3}

	ble v3d32_gpumemory_init_error

	str handle, [gpumemory, #4]

	push {r0-r3}
	mov r0, handle
	bl bcm32_lock_memory
	cmp r0, #-1
	mov addr_gpu, r0
	pop {r0-r3}

	beq v3d32_gpumemory_init_error

	str addr_gpu, [gpumemory]
	and addr_gpu, addr_gpu, #bcm32_mailbox_armmask
	str addr_gpu, [gpumemory, #8]

	b v3d32_gpumemory_init_success

	v3d32_gpumemory_init_error:
		mov r0, #1
		b v3d32_gpumemory_init_common

	v3d32_gpumemory_init_success:
		mov r0, #0

	v3d32_gpumemory_init_common:
		macro32_dsb ip
		pop {r4-r5,pc}

.unreq gpumemory
.unreq size
.unreq alignment
.unreq flags
.unreq handle
.unreq addr_gpu


/**
 * function v3d32_gpumemory_free
 * Clear _GPUMemory Struct with Freeing Memory Space at GPU Side
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Pointer of _GPUMemory to to Clear (ARM Side)
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Error in Response from Mailbox
 */
.globl v3d32_gpumemory_free
v3d32_gpumemory_free:
	/* Auto (Local) Variables, but just Aliases */
	gpumemory .req r0
	temp      .req r1

	push {lr}

	ldr temp, [gpumemory, #4]

	push {r0-r1}
	mov r0, temp
	bl bcm32_unlock_memory
	cmp r0, #-1
	pop {r0-r1}

	beq v3d32_gpumemory_free_error

	push {r0-r1}
	mov r0, temp
	bl bcm32_release_memory
	cmp r0, #-1
	pop {r0-r1}

	beq v3d32_gpumemory_free_error

	mov temp, #0
	str temp, [gpumemory]
	str temp, [gpumemory, #4]
	str temp, [gpumemory, #8]

	b v3d32_gpumemory_free_success

	v3d32_gpumemory_free_error:
		mov r0, #1
		b v3d32_gpumemory_free_common

	v3d32_gpumemory_free_success:
		mov r0, #0

	v3d32_gpumemory_free_common:
		macro32_dsb ip
		pop {pc}

.unreq gpumemory
.unreq temp


/**
 * function v3d32_fragmentshader_init
 * Set _FragmentShader Struct
 * This function is using a vendor-implemented process.
 * Note that this function reserves new memory space at GPU side.
 *
 * The _FragmentShader is structured by 2 words as decribed below.
 *
 * typedef struct v3d32_FragmentShader {
 *  uint32 gpu; // Address of GPU Memory (GPU Side)
 *  uint32 handle_gpu_memory;
 * } _FragmentShader;
 *
 * Parameters
 * r0: Pointer of _FragmentShader to Set (ARM Side)
 * r1: Pointer of Start Address of Code for Fragment Shader (ARM Side)
 * r2: Size of Code for Fragment Shader in Bytes
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): Error in Response from Mailbox
 * Error(2): Channel of DMA or CB Number is Overflow
 */
.globl v3d32_fragmentshader_init
v3d32_fragmentshader_init:
	/* Auto (Local) Variables, but just Aliases */
	fragmentshader .req r0
	code           .req r1
	size           .req r2
	temp           .req r3

	push {lr}

	/* Make Buffer for Texture at GPU Side */

	push {r0-r2}
	mov r0, size
	mov r1, #16
	mov r2, #0xC
	bl bcm32_allocate_memory
	cmp r0, #-1
	mov temp, r0
	pop {r0-r2}

	beq v3d32_fragmentshader_init_error1

	str temp, [fragmentshader, #4]             @ Error Number (0xFFFFFFFF) in bcm32_allocate_memory Is Also Stored

	push {r0-r2}
	mov r0, temp
	bl bcm32_lock_memory
	cmp r0, #-1
	mov temp, r0
	pop {r0-r2}

	beq v3d32_fragmentshader_init_error1

	push {r0-r3}
	mov r0, temp
	orr r1, r1, #equ32_bus_coherence_base      @ Convert to Bus Address
	bl dma32_datacopy
	cmp r0, #0
	pop {r0-r3}

	bne v3d32_fragmentshader_init_error2

	str temp, [fragmentshader]

	b v3d32_fragmentshader_init_success

	v3d32_fragmentshader_init_error1:
		mov r0, #1
		b v3d32_fragmentshader_init_common

	v3d32_fragmentshader_init_error2:
		mov r0, #2
		b v3d32_fragmentshader_init_common

	v3d32_fragmentshader_init_success:
		mov r0, #0

	v3d32_fragmentshader_init_common:
		macro32_dsb ip
		pop {pc}

.unreq fragmentshader
.unreq code
.unreq size
.unreq temp


/**
 * function v3d32_fragmentshader_free
 * Clear _FragmentShader Struct with Freeing Memory Space at GPU Side
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Pointer of _FragmentShader to to Clear (ARM Side)
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Error in Response from Mailbox
 */
.globl v3d32_fragmentshader_free
v3d32_fragmentshader_free:
	/* Auto (Local) Variables, but just Aliases */
	fragmentshader .req r0
	temp           .req r1

	push {lr}

	ldr temp, [fragmentshader, #4]

	push {r0-r1}
	mov r0, temp
	bl bcm32_unlock_memory
	cmp r0, #-1
	pop {r0-r1}

	beq v3d32_fragmentshader_free_error

	push {r0-r1}
	mov r0, temp
	bl bcm32_release_memory
	cmp r0, #-1
	pop {r0-r1}

	beq v3d32_fragmentshader_free_error

	mov temp, #0
	str temp, [fragmentshader]
	str temp, [fragmentshader, #4]

	b v3d32_fragmentshader_free_success

	v3d32_fragmentshader_free_error:
		mov r0, #1
		b v3d32_fragmentshader_free_common

	v3d32_fragmentshader_free_success:
		mov r0, #0

	v3d32_fragmentshader_free_common:
		macro32_dsb ip
		pop {pc}

.unreq fragmentshader
.unreq temp


/**
 * function v3d32_set_overspillmemory
 * Set Overspill Memory Block for QPU of VideoCore IV from ARM
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Pointer of Overspill Memory Block (GPU Side)
 * r1: Size of Overspill Memory Block
 *
 * Return: r0 (0 as success)
 */
.globl v3d32_set_overspillmemory
v3d32_set_overspillmemory:
	/* Auto (Local) Variables, but just Aliases */
	overspillmemory .req r0
	size            .req r1
	addr_qpu        .req r2

	push {lr}

	mov addr_qpu, #equ32_peripherals_base
	orr addr_qpu, addr_qpu, #v3d32_base

	str overspillmemory, [addr_qpu, #v3d32_bpoa]
	str size, [addr_qpu, #v3d32_bpos]

	v3d32_set_overspillmemory_success:
		mov r0, #0

	v3d32_set_overspillmemory_common:
		macro32_dsb ip
		pop {pc}

.unreq overspillmemory
.unreq size
.unreq addr_qpu


V3D32_OBJECTV3D: .word 0x00


/**
 * function v3d32_bind_objectv3d
 * Bind _ObjectV3D Struct
 * This function is using a vendor-implemented process.
 *
 * The _V3D is structured by 12 words as decribed below.
 *
 * typedef struct v3d32_ObjectV3D {
 *  uint32 v3d32_make_cl_binning_handle0;
 *  uint32 v3d32_make_cl_binning_handle1;
 *  uint32 v3d32_make_cl_binning_handle2;
 *  uint32 v3d32_make_cl_binning_handle3;
 *  uint32 v3d32_make_cl_binning_handle4;
 *  uint32 v3d32_make_cl_rendering_handle0;
 *  uint32 v3d32_cl_bin;
 *  uint32 v3d32_tile_allocation;
 *  uint32 v3d32_nv_shaderstate;
 *  uint32 v3d32_uniforms;
 *  uint32 v3d32_cl_render;
 *  uint32 v3d32_cl_render_size;
 * } _ObjectV3D;
 *
 * Parameters
 * r0: Pointer of _ObjectV3D to to Bind (ARM Side)
 *
 * Return: r0 (0 as success)
 */
.globl v3d32_bind_objectv3d
v3d32_bind_objectv3d:
	/* Auto (Local) Variables, but just Aliases */
	objectv3d .req r0

	str objectv3d, V3D32_OBJECTV3D

	v3d32_bind_objectv3d_success:
		mov r0, #0

	v3d32_bind_objectv3d_common:
		macro32_dsb ip
		mov pc, lr

.unreq objectv3d

.equ v3d32_make_cl_binning_handle0,   0x00
.equ v3d32_make_cl_binning_handle1,   0x04
.equ v3d32_make_cl_binning_handle2,   0x08
.equ v3d32_make_cl_binning_handle3,   0x0C
.equ v3d32_make_cl_binning_handle4,   0x10
.equ v3d32_make_cl_rendering_handle0, 0x14
.equ v3d32_cl_bin,                    0x18
.equ v3d32_tile_allocation,           0x1C
.equ v3d32_nv_shaderstate,            0x20
.equ v3d32_uniforms,                  0x24
.equ v3d32_cl_render,                 0x28
.equ v3d32_cl_render_size,            0x2C

V3D32_TML_CL_BIN:                             .word _V3D32_TML_CL_BIN
V3D32_TML_CL_BIN_SIZE:                        .word _V3D32_TML_CL_BIN_END - _V3D32_TML_CL_BIN
V3D32_TML_CL_BIN_CONFIG:                      .word _V3D32_TML_CL_BIN_CONFIG - _V3D32_TML_CL_BIN
V3D32_TML_CL_BIN_CONFIG_BITS:                 .word _V3D32_TML_CL_BIN_CONFIG_BITS - _V3D32_TML_CL_BIN
V3D32_TML_CL_BIN_CLIP_WINDOW:                 .word _V3D32_TML_CL_BIN_CLIP_WINDOW - _V3D32_TML_CL_BIN
V3D32_TML_CL_BIN_VIEWPORT_OFFSET:             .word _V3D32_TML_CL_BIN_VIEWPORT_OFFSET - _V3D32_TML_CL_BIN
V3D32_TML_CL_BIN_VERTEXARRAY_PRIMITIVES:      .word _V3D32_TML_CL_BIN_VERTEXARRAY_PRIMITIVES - _V3D32_TML_CL_BIN
V3D32_TML_CL_BIN_NV_SHADERSTATE:              .word _V3D32_TML_CL_BIN_NV_SHADERSTATE - _V3D32_TML_CL_BIN
V3D32_TML_CL_RENDER:                          .word _V3D32_TML_CL_RENDER
V3D32_TML_CL_RENDER_SIZE:                     .word _V3D32_TML_CL_RENDER_END - _V3D32_TML_CL_RENDER
V3D32_TML_CL_RENDER_CLEAR:                    .word _V3D32_TML_CL_RENDER_CLEAR - _V3D32_TML_CL_RENDER
V3D32_TML_CL_RENDER_CONFIG:                   .word _V3D32_TML_CL_RENDER_CONFIG - _V3D32_TML_CL_RENDER
V3D32_TML_NV_SHADERSTATE:                     .word _V3D32_TML_NV_SHADERSTATE
V3D32_TML_NV_SHADERSTATE_SIZE:                .word _V3D32_TML_NV_SHADERSTATE_END - V3D32_TML_NV_SHADERSTATE
V3D32_TML_UNIFORMS:                           .word _V3D32_TML_UNIFORMS
V3D32_TML_UNIFORMS_SIZE:                      .word _V3D32_TML_UNIFORMS_END - _V3D32_TML_UNIFORMS

.section	.data
.balign 4
/**
 * Templates of Control Lists, Binning and Rendering
 * The binning control list is for NV (no vertex shading) mode.
 * So, fragment (pixel) shading will be executed. Shaded vertex data, including varyings, will be interpolated per pixel.
 * V3D uses tiled rendering. Binning makes tiles for rendering afterward.
 */
_V3D32_TML_CL_BIN:

	/**
	 * Tile Binning Mode Configuration
	 * 1. Tile Allocation Memory Address (32-bit)
	 * 2. Tile Allocation Memory Size (32-bit), 256-byte Aligned; If Overflown, Overspill Occurs
	 * 3. Tile State Data Array Base Address (32-bit), 16-byte Aligned, 48 Bytes * Tiles
	 * 4. Width in Tile (8-bit): 32 Pixels in Multisample mode, 64 Pixels in Non-multisample Mode
	 * 5. Height in Tile (8-bit): 32 Pixels in Multisample mode, 64 Pixels in Non-multisample Modee
	 * 6. Multisample Mode 4x (1-bit): For Anti-aliasing
	 * 7. Tile Buffer 64-bit Color Depth (1-bit)
	 * 8. Auto-initialize Tile State Data Array (1-bit)
	 * 9. Tile Allocation Initial Block Size, 0 = 32 Bytes, 1 = 64 Bytes, 2 = 128 Bytes, 3 = 256 Bytes (2-bit)
	 * 10. Tile Allocation Block Size, 0 = 32 Bytes, 1 = 64 Bytes, 2 = 128 Bytes, 3 = 256 Bytes (2-bit)
	 * 11. Double-buffer in Non-ms Mode (1-bit)
	 */
	.byte v3d32_cl_config_binning
_V3D32_TML_CL_BIN_CONFIG:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

	/**
	 * Start Tile Binning
	 */
	.byte v3d32_cl_start_tile_binning

	/**
	 * Clip Window
	 * 1. Clip Window Left Pixel Coordinate (Unsigned 16-bit)
	 * 2. Clip Window Bottom Pixel Coordinate (Unsigned 16-bit)
	 * 3. Clip Window Width in Pixel (Unsigned 16-bit): Actual Size to Be Rendered
	 * 4. Clip Window Height in Pixel (Unsigned 16-bit): Actual Size to Be Rendered
	 */
	.byte v3d32_cl_clip_window
_V3D32_TML_CL_BIN_CLIP_WINDOW:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

	/**
	 * Configuration Bits
	 * 1. Enable Forward Facing Primitive (1-bit)
	 * 2. Enable Reverse Facing Primitive (1-bit)
	 * 3. Clockwise Primitives (Actually Counter-clockwise by Set) (1-bit)
	 * 4. Enable Depth Offset (1-bit)
	 * 5. Antialiased Points and Lines (1-bit)
	 * 6. Coverage Read Type, 0 = 32-bit, 1 = 16-bit (1-bit)
	 * 7. Rasteriser Oversample Mode, 0 = None, 1 = 4x, 2 = 16x (2-bit)
	 * 8. Coverage Pipe Select (1-bit)
	 * 9. Coverage Update Mode, 0 = Non-zero, 1 = Odd, 2 = Or, 3 = Zero (2-bit)
	 * 10. Coverage Read Mode, 0 = Clear on Read, 1 = Leave on Read (1-bit)
	 * 11. Depth Test Function, 0 = never, 1 = lt, 2 = eq, 3 = le, 4 = gt, 5 = ne, 6 = ge, 7 = always (3-bit)
	 * 12. Z Updates Enable (1-bit)
	 * 13. Early Z Enable (1-bit)
	 * 14. Early Z Updates Enable (1-bit)
	 * 15. Reserved (6-bit)
	 */
	.byte v3d32_cl_config
_V3D32_TML_CL_BIN_CONFIG_BITS:
	.byte 0x03, 0x90, 0x00

	/**
	 * Viewport Offset
	 * 1. Viewport Centre X-coordinate (Signed 16-bit)
	 * 2. Viewport Centre Y-coordinate (Signed 16-bit)
	 */
	.byte v3d32_cl_viewport_offset
_V3D32_TML_CL_BIN_VIEWPORT_OFFSET:
	.byte 0x00, 0x00, 0x00, 0x00

	/**
	 * Z Min and Max Clipping Planes
	 * 1. Minimum Zw (Float 32-bit) Forward
	 * 2. Maximum Zw (Float 32-bit) Backward
	 */
	.byte v3d32_cl_z_clipping_plane
	.float 0.0
	.float 1.0

	/**
	 * NV Shader State
	 * 1. 16-byte Aligned Memory Address of Shader Recored (32-bit)
	 */
	.byte v3d32_cl_nv_shaderstate
_V3D32_TML_CL_BIN_NV_SHADERSTATE:
	.word 0x00000000

	/**
	 * Vertex Array Primitives
	 * 1. Primitive Mode, 0 = Points, 1 = Lines, 2 = Line_loop, 3 = Line_strip, 4 = Triangles, 5 = Triangle_strip, 6 = Triangle_fan (8-bit)
	 * 2. Number of Vertices (32-bit)
	 * 3. Index of First Vertex (32-bit)
	 */
	.byte v3d32_cl_vertexarray_primitives
_V3D32_TML_CL_BIN_VERTEXARRAY_PRIMITIVES:
	.byte 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

	.byte v3d32_cl_flush
_V3D32_TML_CL_BIN_END:

.balign 4
_V3D32_TML_CL_RENDER:

	/**
	 * Clear Colors
	 * 1. Clear Color, Two RGBA8888 or RGBA16161616 (64-bit)
	 * 2. Clear Z (24-bit)
	 * 3. Clear VG (Alpha) Mask (8-bit)
	 * 4. Clear Stencil (8-bit)
	 */
	.byte v3d32_cl_clear
_V3D32_TML_CL_RENDER_CLEAR:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

	/**
	 * Offset 2 Bytes to Make 16 Bytes Distance Between Last and Next Items
	 */
	.byte v3d32_cl_nop
	.byte v3d32_cl_nop

	/**
	 * Tile Rendering Mode Configuration
	 * 1. Memory Address to Be Rendered (32-bit)
	 * 2. Width in Pixels (16-bit)
	 * 3. Height in Pixels (16-bit)
	 * 4. Multisample Mode 4x (1-bit)
	 * 5. Tile Buffer 64-bit Color Depth (HDR Mode) (1-bit)
	 * 6. Non-HDR Frame Buffer Color Format, 0 = BGR565 Dithered, 1 = RGBA8888, 2 = BGR565 (2-bit)
	 * 7. Decimate Mode, 0 = 1x, 1 = 4x, 2 = 16x (2-bit)
	 * 8. Texture Memory Format, 0 = Linear, 1 = T-format, 2 = LT-format (2-bit)
	 * 9. Enable VG (Alpha) Mask Buffer (1-bit)
	 * 10. Select Coverage Mode (1-bit)
	 * 11. Early Z Update Direction, 0 = lt/le, 1 = gt/ge (1-bit)
	 * 12. Early Z / Early Coverage Disable (1-bit)
	 * 13. Double-buffer in Non-ms (Non-multisample) Mode (1-bit)
	 * 14. Reserved (3-bit)
	 */
	.byte v3d32_cl_config_rendering
_V3D32_TML_CL_RENDER_CONFIG:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

	/**
	 * Tile Coordinates (from Upper Left Corner)
	 * 1. Tile Column Number (8-bit)
	 * 2. Tile Row Number (8-bit)
	 */
	.byte v3d32_cl_tile_coordinates
	.byte 0x00, 0x00

	/**
	 * Store Tile Buffer General
	 * 1. Buffer to Store, 0 = None, 1 = Color, 2 = Z/Stencil, 3 = Z, 4 = VG-Mask, 5 = Full Dump (3-bit)
	 * 2. Reserved (1-bit)
	 * 3. Format, 0 = Raster Format, 1 = T-format, 2 = LT-format (2-bit)
	 * ...
	 */
	.byte v3d32_cl_store_tilebuffer_general
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

_V3D32_TML_CL_RENDER_END:


/**
 * NV Shader State
 */
.balign 16
_V3D32_TML_NV_SHADERSTATE:

	/**
	 * Flag Bits
	 * Bit[3]: Clip Coordinates Header Included in Shaded Vertex Data
	 * Bit[2]: Enable Clipping
	 * Bit[1]: Point Size Included in Shaded Vertex Data
	 * Bit[0]: Fragment Shader is Single Threaded
	 */
	.byte 0x00

	/**
	 * Shaded Vertex Data Stride in Bytes
	 */
	.byte 0x00

	/**
	 * Fragment Shader Number of Uniforms
	 */
	.byte 0x00

	/**
	 * Fragment Shader Number of Varyings
	 */
	.byte 0x00

	/**
	 * Fragment Shader Code Address
	 */
	.word 0x00000000

	/**
	 * Fragment Shader Uniforms Address
	 */
	.word 0x00000000

	/**
	 * Shaded Vertex Data Address
	 */
	.word 0x00000000
_V3D32_TML_NV_SHADERSTATE_END:

/**
 * Uniforms (Texture Setup)
 */
.balign 16
_V3D32_TML_UNIFORMS:
	/**
	 * Texture Config Parameter 0
	 * Bit[31:12]: 4096-byte Aligned Texture Base Pointer
	 * Bit[11:10]: Cache Swizzle
	 * Bit[9]: Cube Map Mode
	 * Bit[8]: Flip Texture Y Axis
	 * Bit[7:4]: Texture Data Type
	 * Bit[3:0]: Number of Mipmap Levels Minus 1
	 */
	.word 0x00000000

	/**
	 * Texture Config Parameter 1
	 * Bit[31]: Fifth Bit of Texture Data Type
	 * Bit[30:20]: Image Height
	 * Bit[19]: Flip ETC Y (per Block)
	 * Bit[18:8]: Image Width
	 * Bit[7]: Magnification Filter, 0 = LINEAR, 1 = NEAREST
	 * Bit[6:4]: Minification Filter, 0 = LINEAR, 1 = NEAREST, 2 = NEAR_MIP_NEAR, 3 = NEAR_MIP_LIN, 4 = LIN_MIP_NEAR, 5 = LIN_MIP_LIN
	 * Bit[3:2]: T Wrap Mode, 0 = Repeat, 1 = Clamp, 2 = Mirror, 3 = Border
	 * Bit[1:0]: S Wrap Mode, 0 = Repeat, 1 = Clamp, 2 = Mirror, 3 = Border
	 */
	.word 0x00000000

	/**
	 * Texture Config Parameter 2 for Cube Map Mode
	 */
	.word 0x00000000

	/**
	 * Texture Config Parameter 3 for Cube Map Mode
	 */
	.word 0x00000000

	/**
	 * Pointer of Additional Uniforms
	 */
	.word 0x00000000

	/**
	 * Pointer of Additional Uniforms (Reserve 1)
	 */
	.word 0x00000000

	/**
	 * Pointer of Additional Uniforms (Reserve 2)
	 */
	.word 0x00000000

	/**
	 * Pointer of Additional Uniforms (Reserve 3)
	 */
	.word 0x00000000
_V3D32_TML_UNIFORMS_END:
.section	.vendor_system32


/**
 * Definition Used for V3D
 */

.equ v3d32_base,    0x00C00000

/* V3D Identity Registers */
.equ v3d32_ident0,  0x0000
.equ v3d32_ident1,  0x0004
.equ v3d32_ident2,  0x0008

/* V3D Miscellaneous Registers */
.equ v3d32_scratch, 0x0010

/* Cache Control Registers */
.equ v3d32_l2cactl, 0x0020 @ L2 Cache Control, Bit[2]: L2 Cache Clear, Bit[1]: L2 Cache Disable, Bit[0]: L2 Cache Enable
.equ v3d32_slcactl, 0x0024 @ Slices Cache Control, Bit[27:24]: TMU1 Cache Clear (Per Slices), Bit[19:16]: TMU0, Bit[11:8]: Uniform, Bit[3:0]: Instruction

/**
 * Pipeline Interrupt Control
 * Bit[3]: Binner Used Overspill Memory
 * Bit[2]: Binner Out of Memory
 * Bit[1]: Binner Mode Flush Done
 * Bit[0]: Render Mode Frame Done
 */
.equ v3d32_intctl,  0x0030 @ Interrupt Control, Write Clear
.equ v3d32_intena,  0x0034 @ Interrupt Enable
.equ v3d32_intdis,  0x0038 @ Interrupt Disable

/* Control List Executor Registers */
.equ v3d32_ct0cs,   0x0100 @ Control List Executer Thread 0 (CT0) Cntrol and Status
.equ v3d32_ct1cs,   0x0104 @ Control List Executer Thread 1 (CT1) Cntrol and Status
.equ v3d32_ct0ea,   0x0108 @ CT0 End Address
.equ v3d32_ct1ea,   0x010C @ CT1 End Address
.equ v3d32_ct0ca,   0x0110 @ CT0 Current / First Record Address
.equ v3d32_ct1ca,   0x0114 @ CT1 Current / First Record Address
.equ v3d32_ct0ra,   0x0118 @ CT0 Return Address
.equ v3d32_ct1ra,   0x011C @ CT1 Return Address
.equ v3d32_ct0lc,   0x0120 @ CT0 List Counter, Bit[31:16]: Major List, Bit[15:0] Sub List
.equ v3d32_ct1lc,   0x0124 @ CT1 List Counter, Bit[31:16]: Major List, Bit[15:0] Sub List
.equ v3d32_ct0pc,   0x0128 @ CT0 Primitive List Counter
.equ v3d32_ct1pc,   0x012C @ CT1 Primitive List Counter

/* V3D Pipeline Registers */
.equ v3d32_pcs,     0x0130 @ Pipeline Control and Status
.equ v3d32_bfc,     0x0134 @ Binning Mode Flush Count
.equ v3d32_rfc,     0x0138 @ Rendering Mode Frame Count
.equ v3d32_bpca,    0x0300 @ Current Address of Binning Memory Pool
.equ v3d32_bprs,    0x0304 @ Remaining Size of Binning Memory Pool
.equ v3d32_bpoa,    0x0308 @ Address of Overspill Binning Memory Block
.equ v3d32_bpos,    0x030C @ Size of Overspill Binning Memory Block

.equ v3d32_bxcf,    0x0310 @ Binner Debug, Bit[1]: Disable Clipping, Bit[0]: Disable Forwarding in State Cache

/* QPU Scheduler Registers */
.equ v3d32_sqrsv0,  0x0410 @ Reserve QPUs 0-7, Bit[3]: No Coordinate Shader, Bit[2]: No Vertex Shader, Bit[1]: No Fragment Shader, Bit[0]: No User Programs
.equ v3d32_sqrsv1,  0x0414 @ Reserve QPUs 8-15
.equ v3d32_sqcntl,  0x0418 @ QPU Scheduler Control
.equ v3d32_srqpc,   0x0430 @ QPU User Program Request Program Address, 16 Deep FIFO
.equ v3d32_srqua,   0x0434 @ QPU User Program Request Uniforms Address
.equ v3d32_srqul,   0x0438 @ QPU User Program Request Uniforms Length
.equ v3d32_srqcs,   0x043C @ QPU User Program Request Control and Status
.equ v3d32_vpacntl, 0x0500 @ VPM Allocator Control
.equ v3d32_vpmbase, 0x0504 @ VPM Base Memory Reservation for QPU User Program Request: Size is in Multiples of 256 Bytes (4 of 16-Way 32-bit Vectors).

/* Performance Counters: There are 30 count sources. */
.equ v3d32_pctrc,   0x0670 @ Performance Counter Clear, Bit[15:0]: Counter 0 to Counter 15
.equ v3d32_pctre,   0x0674 @ Performance Counter Enable
.equ v3d32_pctr0,   0x0680 @ Performance Count
.equ v3d32_pctrs0,  0x0684 @ Performance Counter Mapping (Source ID)
.equ v3d32_pctr1,   0x0688
.equ v3d32_pctrs1,  0x068C
.equ v3d32_pctr2,   0x0690
.equ v3d32_pctrs2,  0x0694
.equ v3d32_pctr3,   0x0698
.equ v3d32_pctrs3,  0x069C
.equ v3d32_pctr4,   0x06A0
.equ v3d32_pctrs4,  0x06A4
.equ v3d32_pctr5,   0x06A8
.equ v3d32_pctrs5,  0x06AC
.equ v3d32_pctr6,   0x06B0
.equ v3d32_pctrs6,  0x06B4
.equ v3d32_pctr7,   0x06B8
.equ v3d32_pctrs7,  0x06BC
.equ v3d32_pctr8,   0x06C0
.equ v3d32_pctrs8,  0x06C4
.equ v3d32_pctr9,   0x06C8
.equ v3d32_pctrs9,  0x06CC
.equ v3d32_pctr10,  0x06D0
.equ v3d32_pctrs10, 0x06D4
.equ v3d32_pctr11,  0x06D8
.equ v3d32_pctrs11, 0x06DC
.equ v3d32_pctr12,  0x06E0
.equ v3d32_pctrs12, 0x06E4
.equ v3d32_pctr13,  0x06E8
.equ v3d32_pctrs13, 0x06EC
.equ v3d32_pctr14,  0x06F0
.equ v3d32_pctrs14, 0x06F4
.equ v3d32_pctr15,  0x06F8
.equ v3d32_pctrs15, 0x06FC

/* QPU Interrupt Control */
.equ v3d32_dbqitc,  0x0E2C
.equ v3d32_dbqite,  0x0E30

/* Error and Diagnostic Registers */
.equ v3d32_dbge,    0x0F00 @ PSE Error Signals
.equ v3d32_fdbgo,   0x0F04 @ FEP Overrun Error Signals
.equ v3d32_fdbgb,   0x0F08 @ FEP Interface Ready and Stall Signals, Plus FEP Busy Signals
.equ v3d32_fdbgr,   0x0F0C @ FEP Internal Ready Signals
.equ v3d32_fdbgs,   0x0F10 @ FEP Internal Stall Input Signals
.equ v3d32_errstat, 0x0F20 @ Miscellaneous Error Signals

/* Control Record ID (Abstracted): Several ID are followed by Data Bytes */
.equ v3d32_cl_halt,                      0
.equ v3d32_cl_nop,                       1
.equ v3d32_cl_flush,                     4   @ Binning Only
.equ v3d32_cl_flush_all,                 5   @ Binning Only
.equ v3d32_cl_start_tile_binning,        6   @ Binning Only, Start Tile Binning
.equ v3d32_cl_inc_semaphore,             7   @ Increment Semaphore
.equ v3d32_cl_wait_semaphore,            8   @ Wait on Semaphore
.equ v3d32_cl_branch,                    16  @ Branch, Bit[31:0]: Absolute Branch Address
.equ v3d32_cl_branch_sublist,            17  @ Branch to Sub-list, Bit[31:0]: Tile Allocation Memory Address + (32 * (Tile Row * Column Length + Tile Column))
.equ v3d32_cl_return_sublist,            18  @ Return from Sub-list
.equ v3d32_cl_store_tilebuffer_multi,    24  @ Rendering Only, Store Multi-sample Tile Color Buffer, Place from First
.equ v3d32_cl_store_tilebuffer_multiend, 25  @ Rendering Only, Store Multi-sample Tile Color Buffer and Signal End of Frame, Place at Last
.equ v3d32_cl_store_tilebuffer_full,     26  @ Rendering Only, Bit[31:4]: Memory Address, Bit[3]: Last Tile of Frame, Bit[2]: Disable Clear on Write, Bit[1]: Disable Z/Stencil Buffer Write, Bit[0]: Disable Color Buffer Write
.equ v3d32_cl_load_tilebuffer_full,      27  @ Rendering Only, Bit[31:4]: Memory Address, Bit[3]: Last Tile of Frame, Bit[1]: Disable Z/Stencil Buffer Read, Bit[0]: Disable Color Buffer Read
.equ v3d32_cl_store_tilebuffer_general,  28  @ Rendering Only
.equ v3d32_cl_load_tilebuffer_general,   29  @ Rendering Only
.equ v3d32_cl_vertexarray_primitives,    33  @ Bit[71:40]: Index of First Vertex, Bit[39:8]: Length, Bit[7:0]: Primitive Mode, 0 = Points, 4 = Triangles, etc.
.equ v3d32_cl_nv_shaderstate,            65  @ No Vertex Shading State, Bit[31:0]: Memory Address of Shader Record (16-byte aligned)
.equ v3d32_cl_config,                    96  @ Followed by 6-byte Data
.equ v3d32_cl_points_size,               98  @ Bit[31:0]: Size in Single Precision Float
.equ v3d32_cl_line_width,                99  @ Bit[31:0]: Line Width in Single Precision Float
.equ v3d32_cl_clip_window,               102 @ Bit[63:48]: Height in Pixels, Bit[47:32]: Width in Pixels, Bit[31:16]: Bottom, Bit[15:0]: Left
.equ v3d32_cl_viewport_offset,           103 @ Bit[31:16]: Y-coordinate (Signed), Bit[15:0]: X-coordinate (Signed)
.equ v3d32_cl_z_clipping_plane,          104 @ Bit[64:32]: Maximum Zw (float32), Bit[32:0]: Minimum Zw (float32)
.equ v3d32_cl_clipper_z,                 106 @ Bit[64:32]: Viewport Z Offset (float32), Bit[32:0]: Viewport Z Scale (float32)
.equ v3d32_cl_config_binning,            112 @ Binning Only, Followed by 15-byte Data
.equ v3d32_cl_config_rendering,          113 @ Rendering Only, Followed by 10-byte Data
.equ v3d32_cl_clear,                     114 @ Rendering Only, Bit[103:96]: Stencil, Bit[95:88]: VG (Alpha) Mask, Bit[87:64]: Clear Z, Bit[63:0]: Clear Color (Two RGBA8888 or RGBA16161616)
.equ v3d32_cl_tile_coordinates,          115 @ Rendering Only, Bit[15:8]: Tile Row Number, Bit[7:0]: Tile Column Number, from Upper Left Corner

/* Parameters */
.equ v3d32_make_cl_binning_buffersize,   7   @ Value of Logical Shift Left to Number of Tiles, i.e., 128 (2^7) Bytes per Tiles; More Number to Prevent Overspill
