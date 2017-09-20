/**
 * usb2032.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * function usb2032_otg_host_wait
 * Wait Receive Responce from Device and Disable Interrupt
 *
 * Parameters
 * r0: Channel 0-15
 *
 * Usage: r0-r2
 * Return: r0 (Host Channel Interrupt Status)
 */
.globl usb2032_otg_host_wait
usb2032_otg_host_wait:
	/* Auto (Local) Variables, but just Aliases */
	channel        .req r0
	memorymap_base .req r1
	temp           .req r2

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_hostchannel_base
	mov temp, #equ32_usb20_otg_hostchannel_offset
	mul temp, channel, temp
	add memorymap_base, memorymap_base, temp                               @ Add Each Channel Offset

	usb2032_otg_host_wait_loop:
		ldr temp, [memorymap_base, #equ32_usb20_otg_hcintn]
		cmp temp, #0
		beq usb2032_otg_host_wait_loop

		dsb

		/**
		 * Data Toggle Error Bit[10]
		 * Frame Overrun Bit[9]
		 * Babble Error Bit[8]
		 * Transaction Error Bit[7]
		 * NYET Bit[6]
		 * ACK Bit[5]
		 * NAK Bit[4]
		 * STALL Bit[3]
		 * Internal Bus Error Bit[2]
		 * Channel Halted Bit[1]
		 * Transfer Completed Bit[0]
		 */

		mov r0, temp

	usb2032_otg_host_wait_common:
		str temp, [memorymap_base, #equ32_usb20_otg_hcintn]               @ Set-clear
		mov temp, #0
		str temp, [memorymap_base, #equ32_usb20_otg_hcintmskn]            @ Mask All
		dsb                                                               @ Ensure Completion of Instructions Before
		mov pc, lr
	
.unreq channel
.unreq memorymap_base
.unreq temp


/**
 * function usb2032_otg_host_send
 * Send Message to Device and Enable Interrupt
 *
 * Parameters
 * r0: Channel 0-15
 *
 * Usage: r0-r2
 * Return: r0 (0 as success, 1 as Error)
 * Error(1): Channel is Already Enabled
 */
.globl usb2032_otg_host_send
usb2032_otg_host_send:
	/* Auto (Local) Variables, but just Aliases */
	channel        .req r0
	memorymap_base .req r1
	temp           .req r2

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_hostchannel_base
	mov temp, #equ32_usb20_otg_hostchannel_offset
	mul temp, channel, temp
	add memorymap_base, memorymap_base, temp                               @ Add Each Channel Offset

	ldr temp, [memorymap_base, #equ32_usb20_otg_hccharn]
	tst temp, #0x80000000                                                  @ Channel Enable Bit[31]
	bne usb2032_otg_host_send_error                                        @ Channel is Already Enabled

	ldr temp, [memorymap_base, #equ32_usb20_otg_hcintn]
	dsb
	str temp, [memorymap_base, #equ32_usb20_otg_hcintn]                    @ Set-clear

	mvn temp, #0
	str temp, [memorymap_base, #equ32_usb20_otg_hcintmskn]                 @ Unmask All

	ldr temp, [memorymap_base, #equ32_usb20_otg_hccharn]
	dsb
	orr temp, #0x80000000

	str temp, [memorymap_base, #equ32_usb20_otg_hccharn]

	b usb2032_otg_host_send_success

	usb2032_otg_host_send_error:
		mov r0, #1                                                        @ Return with Error
		b usb2032_otg_host_send_common

	usb2032_otg_host_send_success:
		mov r0, #0                                                        @ Return with Success

	usb2032_otg_host_send_common:
		dsb                                                               @ Ensure Completion of Instructions Before
		mov pc, lr
	
.unreq channel
.unreq memorymap_base
.unreq temp


/**
 * function usb2032_otg_host_set_channel
 * Set Channel
 *
 * Parameters
 * r0: Channel 0-15
 * r1: Value of Host Channel N Characteristics Register
 * r2: Value of Host Channel N Split Control Register
 * r3: Value of Host Channel N Transfer Size Register
 * r4: Value of Host Channel N DMA Address Register
 *
 * Usage: r0-r6
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Channel is Already Enabled
 */
.globl usb2032_otg_host_set_channel
usb2032_otg_host_set_channel:
	/* Auto (Local) Variables, but just Aliases */
	channel        .req r0
	hcchar         .req r1
	hcsplt         .req r2
	hctsiz         .req r3
	hcdma          .req r4
	memorymap_base .req r5
	temp           .req r6

	push {r4-r6}

	add sp, sp, #12                                                        @ r4-r6 offset 12 bytes
	pop {hcdma}                                                            @ Get Fifth Argument
	sub sp, sp, #16 

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_hostchannel_base
	mov temp, #equ32_usb20_otg_hostchannel_offset
	mul temp, channel, temp
	add memorymap_base, memorymap_base, temp                               @ Add Each Channel Offset

	ldr temp, [memorymap_base, #equ32_usb20_otg_hccharn]
	tst temp, #0x80000000                                                  @ Channel Enable Bit[31]
	bne usb2032_otg_host_set_channel_error                                 @ Channel is Already Enabled

	str hcchar, [memorymap_base, #equ32_usb20_otg_hccharn]
	str hcsplt, [memorymap_base, #equ32_usb20_otg_hcspltn]
	str hctsiz, [memorymap_base, #equ32_usb20_otg_hctsizn]
	str hcdma, [memorymap_base, #equ32_usb20_otg_hcdman]

	b usb2032_otg_host_set_channel_success

	usb2032_otg_host_set_channel_error:
		mov r0, #1                                                         @ Return with Error
		b usb2032_otg_host_set_channel_common

	usb2032_otg_host_set_channel_success:
		mov r0, #0                                                         @ Return with Success

	usb2032_otg_host_set_channel_common:
		dsb                                                                @ Ensure Completion of Instructions Before
		pop {r4-r6}
		mov pc, lr

.unreq channel
.unreq hcchar
.unreq hcsplt
.unreq hctsiz
.unreq hcdma
.unreq memorymap_base
.unreq temp


/**
 * function usb2032_otg_host_start
 * Enable USB2.0 OTG
 * In addition to this function, you may need to power on the USB implementation in SoC.
 *
 * Usage: r0-r2
 * Return: r0 (0 as success, 1 as error)
 * Error(1): AHB (Advanced High-performance Bus) is not in Idle State.
 */
.globl usb2032_otg_host_start
usb2032_otg_host_start:
	/* Auto (Local) Variables, but just Aliases */
	memorymap_base    .req r0
	temp              .req r1
	temp2             .req r2

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_base

	/**
	 * Core Global CSRs (Base + 0x0)
	 * Core USB Configuration has each default setting in SoCs,
	 * e.g. in BCM2836 has 0x20402700.
	 * So in this section, we need to make DMA on, make Core Reset and FIFO Flush,
	 * and make power on, reset, enable host port.
	 */

	ldr temp, [memorymap_base, #equ32_usb20_otg_gusbcfg]      @ Global USB Configuration
	bic temp, #0x40000000                                     @ Clear Force Device Mode Bit[30]
	orr temp, #0x20000000                                     @ Set Force Host Mode Bit[29]
	str temp, [memorymap_base, #equ32_usb20_otg_gusbcfg]

	dsb

	/**
	 * AHB Cofiguration (GAHBCFG) Bit[23] may have DMA Incremental(0) or single (1) in case.
	 * BCM2836 has 0x0000000E in Default.
	 * In this function, DMA is enabled and DMA Burst Becomes Incremental16
	 */
	mov temp, #0x2E                                           @ Enable DMA Bit[5], BurstType Bit[4:1]
	str temp, [memorymap_base, #equ32_usb20_otg_gahbcfg]      @ Global AHB Configuration

	dsb

	ldr temp, [memorymap_base, #equ32_usb20_otg_grstctl]      @ Core Global Reset Control

	bic temp, temp, #0x7C0                                    @ TxFIFO Number Bit[10:6]
	orr temp, temp, #0x400                                    @ Flush All TxFIFOs
	str temp, [memorymap_base, #equ32_usb20_otg_grstctl]

	dsb

	tst temp, #0x80000000                                     @ ANDS AHB Idle Bit[31]
	beq usb2032_otg_host_start_error                               @ If Bus is Not in Idle

	orr temp, temp, #0x20                                     @ TxFIFO Reset Bit[5]
	str temp, [memorymap_base, #equ32_usb20_otg_grstctl]

	dsb

	usb2032_otg_host_start_loop1:
		ldr temp2, [memorymap_base, #equ32_usb20_otg_grstctl]
		cmp temp, temp2
		beq usb2032_otg_host_start_loop1

	mov temp, temp2

	dsb

	tst temp, #0x80000000                                     @ ANDS AHB Idle Bit[31]
	beq usb2032_otg_host_start_error                               @ If Bus is Not in Idle

	orr temp, temp, #0x10                                     @ RxFIFO Reset Bit[4]
	str temp, [memorymap_base, #equ32_usb20_otg_grstctl]

	dsb

	usb2032_otg_host_start_loop2:
		ldr temp2, [memorymap_base, #equ32_usb20_otg_grstctl]
		cmp temp, temp2
		beq usb2032_otg_host_start_loop2

	mov temp, temp2

	dsb

	tst temp, #0x80000000                                     @ ANDS AHB Idle Bit[31]
	beq usb2032_otg_host_start_error                               @ If Bus is Not in Idle

	orr temp, temp, #0x01                                     @ Core Soft Reset Bit[0]
	str temp, [memorymap_base, #equ32_usb20_otg_grstctl]

	dsb

	usb2032_otg_host_start_loop3:
		ldr temp2, [memorymap_base, #equ32_usb20_otg_grstctl]
		cmp temp, temp2
		beq usb2032_otg_host_start_loop3

	dsb

	/**
	 * Host Mode CSRs (Base + 0x400)
	 */

	add memorymap_base, memorymap_base, #equ32_usb20_otg_host_base

	ldr temp, [memorymap_base, #equ32_usb20_otg_hprt]         @ Host Port Control and Status

	tst temp, #0x00001000                                     @ Port Power Bit[12]
	bne usb2032_otg_host_start_jump                                @ If Power On

	orr temp, #0x00001000
	str temp, [memorymap_base, #equ32_usb20_otg_hprt]

	dsb

	usb2032_otg_host_start_jump:
		orr temp, #0x00000100                                      @ Port Reset Bit[8]
		str temp, [memorymap_base, #equ32_usb20_otg_hprt]

		dsb

		push {r0-r3,lr}
		mov r0, #0xC400                                            @ 50176 us, 50.176 ms (In High-speed, 50 ms is minimum)
		bl system32_sleep
		pop {r0-r3,lr}

		bic temp, #0x00000100                                      @ Clear Port Reset Bit[8]
		str temp, [memorymap_base, #equ32_usb20_otg_hprt]

		dsb

		usb2032_otg_host_start_jump_loop:
			ldr temp, [memorymap_base, #equ32_usb20_otg_hprt]
			tst temp, #0x00000004                                       @ Port Enable Bit[2]
			beq usb2032_otg_host_start_jump_loop

		/**
		 * If already connected with devices including Hub,
		 * HPRT bit[1:0] become set, Port Connection Deteched Bit[1] causes
		 * an interrupt on GINTSTS. If you want clear it, you will need to set-clear to Bit[1] after initializing devices
		 */

		b usb2032_otg_host_start_success

	usb2032_otg_host_start_error:
		mov r0, #1                           @ Return with Error
		b usb2032_otg_host_start_common

	usb2032_otg_host_start_success:
		mov r0, #0                           @ Return with Success

	usb2032_otg_host_start_common:
		dsb                                  @ Ensure Completion of Instructions Before
		mov pc, lr

.unreq memorymap_base
.unreq temp
.unreq temp2
