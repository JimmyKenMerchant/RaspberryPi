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
.equ v3d32_ctl_halt,                      0
.equ v3d32_ctl_nop,                       1
.equ v3d32_ctl_flush,                     4   @ Binning Only
.equ v3d32_ctl_flush_all,                 5   @ Binning Only
.equ v3d32_ctl_start_tile_binning,        6   @ Binning Only, Start Tile Binning
.equ v3d32_ctl_inc_semaphore,             7   @ Increment Semaphore
.equ v3d32_ctl_wait_semaphore,            8   @ Wait on Semaphore
.equ v3d32_ctl_branch,                    16  @ Branch, Bit[31:0]: Absolute Branch Address
.equ v3d32_ctl_branch_sublist,            17  @ Branch to Sub-list, Bit[31:0]: Tile Allocation Memory Address + (32 * (Tile Row * Column Length + Tile Column))
.equ v3d32_ctl_return_sublist,            18  @ Return from Sub-list
.equ v3d32_ctl_store_tilebuffer_multi,    24  @ Rendering Only, Store Multi-sample Tile Buffer, Place from First
.equ v3d32_ctl_store_tilebuffer_multiend, 25  @ Rendering Only, Store Multi-sample Tile Buffer and Signal End of Frame, Place at Last
.equ v3d32_ctl_store_tilebuffer_general,  28  @ Rendering Only, from Sub-list, Followed by 3-byte/6-byte Data (for full-dump), Place Before Multi-sample
.equ v3d32_ctl_vertexarray_primitives,    33  @ Bit[71:40]: Index of First Vertex, Bit[39:8]: Length, Bit[7:0]: Primitive Mode, 0 = Points, 4 = Triangles, etc.
.equ v3d32_ctl_nv_shaderstate,            65  @ No Vertex Shading State, Bit[31:0]: Memory Address of Shader Record (16-byte aligned)
.equ v3d32_ctl_config,                    96  @ Followed by 6-byte Data
.equ v3d32_ctl_points_size,               98  @ Bit[31:0]: Size in Single Precision Float
.equ v3d32_ctl_line_width,                99  @ Bit[31:0]: Line Width in Single Precision Float
.equ v3d32_ctl_clip_window,               102 @ Bit[63:48]: Height in Pixels, Bit[47:32]: Width in Pixels, Bit[31:16]: Bottom, Bit[15:0]: Left
.equ v3d32_ctl_viewport_offset,           103 @ Bit[31:16]: Y-coordinate (Signed), Bit[15:0]: X-coordinate (Signed)
.equ v3d32_ctl_config_binning,            112 @ Binning Only, Followed by 15-byte Data
.equ v3d32_ctl_config_rendering,          113 @ Rendering Only, Followed by 10-byte Data
.equ v3d32_ctl_clear,                     114 @ Rendering Only, Bit[103:96]: Stencil, Bit[95:88]: VG Mask, Bit[87:64]: Clear Z, Bit[63:0]: Clear Color (Two RGBA8888 or RGBA16161616)
.equ v3d32_ctl_tile_coordinates,          115 @ Rendering Only, Bit[15:8]: Tile Row Number, Bit[7:0]: Tile Column Number

