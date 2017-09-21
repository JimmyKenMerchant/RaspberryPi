/**
 * usb2032.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * function usb2032_hub_activate
 * Search and Activate Hub
 *
 * Parameters
 * r0: Channel 0-15
 * r1: Split-transaction(1)/Not(0)
 *
 * Return: r0 (0 as success, 1 as Error)
 * Error(1): Failed Memory Allocation
 */
.globl usb2032_hub_activate
usb2032_hub_activate:
	/* Auto (Local) Variables, but just Aliases */
	channel        .req r0
	flag_split     .req r1
	temp           .req r2
	temp2          .req r3
	temp3          .req r4
	exe_setter     .req r5
	exe_sender     .req r6
	exe_receiver   .req r7
	buffer         .req r8
	split          .req r9

	push {r4-r9}

	ldr exe_setter, USB2032_SETTER
	ldr exe_sender, USB2032_SENDER
	ldr exe_receiver, USB2032_RECEIVER

	push {r0-r3,lr}
	mov r0, #16           @ 4 Bytes by 16 Blocks Equals 64 Bytes
	bl system32_malloc
	mov buffer, r0
	pop {r0-r3,lr}

	cmp buffer, #0
	beq usb2032_hub_activate_error1

	mov split, #0
	/*cmp flag_split, #0*/

	push {r0-r3,lr}
	mov r1, #64
	orr r1, #0x8000
	mov r2, #64
	mov r3, buffer
	push {split}
	blx exe_setter
	add sp, sp, #4
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r1, #0
	blx exe_sender
	pop {r0-r3,lr}

	push {r0-r3,lr}
	blx exe_receiver
	mov temp3, r0
	pop {r0-r3,lr}

	b usb2032_hub_activate_success

	usb2032_hub_activate_error1:
		mov r0, #1
		b usb2032_hub_activate_common

	usb2032_hub_activate_success:
		mov r0, temp3

	usb2032_hub_activate_common:
		dsb                                                               @ Ensure Completion of Instructions Before
		pop {r4-r9}
		mov pc, lr

.unreq channel
.unreq flag_split
.unreq temp
.unreq temp2
.unreq temp3
.unreq exe_setter
.unreq exe_sender
.unreq exe_receiver
.unreq buffer
.unreq split


/**
 * function usb2032_otg_host_receiver
 * Wait Receive Responce from Device and Disable Interrupt
 *
 * Parameters
 * r0: Channel 0-15
 *
 * Return: r0 (Status of Channel)
 * Bit[0]: Completed
 * Bit[1]: Halted
 * Bit[2]: ACK
 * Bit[3]: NAK
 * Bit[4]: STALL
 * Bit[5]: NYET
 * Bit[6]: Internal Bus Error
 * Bit[7]: Transaction and Other Errors
 */
.globl usb2032_otg_host_receiver
usb2032_otg_host_receiver:
	/* Auto (Local) Variables, but just Aliases */
	channel        .req r0
	memorymap_base .req r1
	temp           .req r2

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_hostchannel_base
	mov temp, #equ32_usb20_otg_hostchannel_offset
	mul temp, channel, temp
	add memorymap_base, memorymap_base, temp                             @ Add Each Channel Offset

	/**
	 * On the loop below, we should consider of the limitter, but this system is aiming simple.
	 * Implementing the limitter causes complex of codes to treat it.
	 * If you want to escape from loop, set channel-halt from another core. 
	 */
	usb2032_otg_host_receiver_loop:
		ldr temp, [memorymap_base, #equ32_usb20_otg_hcintn]
		tst temp, #0x00000002                                            @ Check Halted (HCD Disabled Channel N)
		beq usb2032_otg_host_receiver_loop

		/**
		 * Bit[11] and over may exist in case of some SoC
		 * Data Toggle Error Bit[10]
		 * Frame Overrun Bit[9]
		 * Babble Error Bit[8]
		 * Transaction Error Bit[7]
		 * NYET (Not Yet) Bit[6] for Split Control
		 * ACK Bit[5]
		 * NAK Bit[4]
		 * STALL Bit[3]
		 * Internal Bus Error Bit[2]
		 * Channel Halted Bit[1]
		 * Transfer Completed Bit[0]
		 */

		dsb

		mov r0, #0

		/* Bit Translation Process */

		tst temp, #0x00000001
		orrne r0, r0, #0x00000001                                         @ Completed Bit[0]
		tst temp, #0x00000002
		orrne r0, r0, #0x00000002                                         @ Halted Bit[1]
		tst temp, #0x00000020
		orrne r0, r0, #0x00000004                                         @ ACK Bit[2]
		tst temp, #0x00000010
		orrne r0, r0, #0x00000008                                         @ NAK Bit[3]
		tst temp, #0x00000008
		orrne r0, r0, #0x00000010                                         @ STALL Bit[4]
		tst temp, #0x00000040
		orrne r0, r0, #0x00000020                                         @ NYET Bit[5]
		tst temp, #0x00000004
		orrne r0, r0, #0x00000040                                         @ Internal Bus Error Bit[6]
		tst temp, #0x00000F80
		orrne r0, r0, #0x00000080                                         @ Transaction and Other Errors Bit[7]

	usb2032_otg_host_receiver_common:
		str temp, [memorymap_base, #equ32_usb20_otg_hcintn]               @ write-clear
		mov temp, #0
		str temp, [memorymap_base, #equ32_usb20_otg_hcintmskn]            @ Mask All
		dsb                                                               @ Ensure Completion of Instructions Before
		mov pc, lr
	
.unreq channel
.unreq memorymap_base
.unreq temp


/**
 * function usb2032_otg_host_sender
 * Send Message to Device and Enable Interrupt
 *
 * Parameters
 * r0: Channel 0-15
 * r1: Split-Complete (1) or Not (0)
 *
 * Return: r0 (0 as success, 1 as Error)
 * Error(1): Channel is Already Enabled
 */
.globl usb2032_otg_host_sender
usb2032_otg_host_sender:
	/* Auto (Local) Variables, but just Aliases */
	channel        .req r0
	complete_splt  .req r1
	memorymap_base .req r2
	temp           .req r3

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_hostchannel_base
	mov temp, #equ32_usb20_otg_hostchannel_offset
	mul temp, channel, temp
	add memorymap_base, memorymap_base, temp                              @ Add Each Channel Offset

	ldr temp, [memorymap_base, #equ32_usb20_otg_hccharn]
	tst temp, #0x80000000                                                 @ Channel Enable Bit[31]
	bne usb2032_otg_host_sender_error                                     @ Channel is Already Enabled

	ldr temp, [memorymap_base, #equ32_usb20_otg_hctsizn]
	dsb
	bic temp, #0x00F80000                                                 @ Clear Packet Count Bit[23:19]
	bic temp, #0x1F000000                                                 @ Clear Packet Count Bit[28:24]
	orr temp, #0x00080000                                                 @ Packet Count Bit[28:19] to 1
	str temp, [memorymap_base, #equ32_usb20_otg_hctsizn]

	ldr temp, [memorymap_base, #equ32_usb20_otg_hcintn]
	dsb
	str temp, [memorymap_base, #equ32_usb20_otg_hcintn]                   @ write-clear

	mvn temp, #0
	str temp, [memorymap_base, #equ32_usb20_otg_hcintmskn]                @ Unmask All

	cmp complete_splt, #0
	beq usb2032_otg_host_sender_jump
	 
	ldr temp, [memorymap_base, #equ32_usb20_otg_hcspltn]
	tst temp, #0x80000000                                                 @ Split Enable Bit[31]
	beq usb2032_otg_host_sender_jump

	orr temp, #0x00010000                                                 @ Do Complete Split Bit[16]
	str temp, [memorymap_base, #equ32_usb20_otg_hcspltn]

	usb2032_otg_host_sender_jump:
		dsb
		ldr temp, [memorymap_base, #equ32_usb20_otg_hccharn]
		dsb

		orr temp, #0x80000000
		str temp, [memorymap_base, #equ32_usb20_otg_hccharn]              @ Enable Channel

		b usb2032_otg_host_sender_success

	usb2032_otg_host_sender_error:
		mov r0, #1                                                        @ Return with Error
		b usb2032_otg_host_sender_common

	usb2032_otg_host_sender_success:
		mov r0, #0                                                        @ Return with Success

	usb2032_otg_host_sender_common:
		dsb                                                               @ Ensure Completion of Instructions Before
		mov pc, lr
	
.unreq channel
.unreq complete_splt
.unreq memorymap_base
.unreq temp


/**
 * function usb2032_otg_host_setter
 * Set Channel
 *
 * Parameters
 * r0: Channel 0-15
 * 
 * r1: Channel N Characteristics (Virtual Register), Reserved Bits expects SBZ (Zeros)
 *   r1 Bit[10:0]: Maximum Packet Size
 *   r1 Bit[14:11]: Endpoint Number
 *   r1 Bit[15]: Endpoint Direction, 0 Out, 1, In
 *   r1 Bit[17:16]: Endpoint Type, 0 Control, 1 Isochronous, 2 Bulk, 3 Interrupt
 *   r1 Bit[24:18]: Device Address
 *   r1 Bit[25]: Full and High Speed(0)/Low Speed(1)
 *   r1 Bit[26]: Even(0)/Odd(1) Frame in Periodic Transactions
 *
 * r2: Channel N Transfer Size (Virtual Register), Reserved Bits expects SBZ (Zeros)
 *   r2 Bit[18:0]: Transfer Size
 *
 * r3: Channel N DMA Address
 *
 * r4: Channel N Split Control (Virtual Register), Reserved Bits expects SBZ (Zeros)
 *   r4 Bit[6:0]: Port Address
 *   r4 Bit[13:7]: Hub Address
 *   r4 Bit[15:14]: Position of Transaction, 0 Middle, 1 End, 2 Begin, 3 All
 *   r4 Bit[31]: Disable(0)/Enable(1) Split Control
 *
 * Return: r0 (0 as success, 1 as error), r1 (Actual Value on Channel N Characteristics Register of SoC)
 * Error(1): Channel is Already Enabled
 */
.globl usb2032_otg_host_setter
usb2032_otg_host_setter:
	/* Auto (Local) Variables, but just Aliases */
	channel        .req r0
	character      .req r1
	transfer_size  .req r2
	dma_addr       .req r3
	split_ctl      .req r4
	hcchar         .req r5
	temp           .req r6
	memorymap_base .req r7

	push {r4-r7}

	add sp, sp, #16                                                        @ r4-r7 offset 16 bytes
	pop {split_ctl}                                                        @ Get Fifth Argument
	sub sp, sp, #20 

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_hostchannel_base
	mov temp, #equ32_usb20_otg_hostchannel_offset
	mul temp, channel, temp
	add memorymap_base, memorymap_base, temp                               @ Add Each Channel Offset

	ldr temp, [memorymap_base, #equ32_usb20_otg_hccharn]
	tst temp, #0x80000000                                                  @ Channel Enable Bit[31]
	bne usb2032_otg_host_setter_error                                      @ Channel is Already Enabled

	mov hcchar, #0

	and temp, character, #0x00FF                                           @ Bit[7:0]
	orr hcchar, hcchar, temp
	and temp, character, #0xFF00                                           @ Bit[15:8]
	orr hcchar, hcchar, temp

	and temp, character, #0x00030000                                       @ Endpoint Type Bit[17:16]
	lsl temp, temp, #2
	orr hcchar, hcchar, temp

	and temp, character, #0x01FC0000                                       @ Device Address Bit[24:18]
	lsl temp, temp, #4
	orr hcchar, hcchar, temp

	tst character, #0x02000000                                             @ Full and High Speed(0)/Low Speed(1) Bit[25]
	orrne hcchar, hcchar, #0x00020000
	
	tst character, #0x04000000                                             @ Even(0)/Odd(1) Frame Bit[26]
	orrne hcchar, hcchar, #0x20000000

	/* Force Setting */
	orr hcchar, hcchar, #0x00100000                                        @ Multi Count/ Error Count Bit[21:20] in OTG

	dsb
 
	str hcchar, [memorymap_base, #equ32_usb20_otg_hccharn]

	bic transfer_size, transfer_size, #0xFF000000
	bic transfer_size, transfer_size, #0x00F80000                          @ Only Validate Bit[18:0]
	str transfer_size, [memorymap_base, #equ32_usb20_otg_hctsizn]

	str dma_addr, [memorymap_base, #equ32_usb20_otg_hcdman]

	bic split_ctl, split_ctl, #0x7F000000
	bic split_ctl, split_ctl, #0x00FF0000                                  @ Only Validate Bit[31] and Bit[15:0]
	str split_ctl, [memorymap_base, #equ32_usb20_otg_hcspltn]

	b usb2032_otg_host_setter_success

	usb2032_otg_host_setter_error:
		mov r0, #1                                                         @ Return with Error
		mov r1, #0
		b usb2032_otg_host_setter_common

	usb2032_otg_host_setter_success:
		mov r0, #0                                                         @ Return with Success
		mov r1, hcchar

	usb2032_otg_host_setter_common:
		dsb                                                                @ Ensure Completion of Instructions Before
		pop {r4-r7}
		mov pc, lr

.unreq channel
.unreq character
.unreq transfer_size
.unreq dma_addr
.unreq split_ctl
.unreq hcchar
.unreq temp
.unreq memorymap_base


/**
 * function usb2032_otg_host_start
 * Enable USB2.0 OTG
 * In addition to this function, you may need to power on the USB implementation in SoC.
 *
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
			tst temp, #0x00000004                                  @ Port Enable Bit[2]
			beq usb2032_otg_host_start_jump_loop

			dsb

			/**
			 * If already connected with devices including Hub,
			 * HPRT bit[1:0] become set, Port Connection Deteched Bit[1] causes
			 * an interrupt on GINTSTS. If you want clear it, you will need to write-clear to Bit[1]
			 * Also, Port Enable/Disable Change Bit[3], Port Overcurrent Change Bit[5] are to write-clear
			 */
			bic temp, #0x4                                         @ Clear Port Enable Bit[2] Because Write-clear

			str temp, [memorymap_base, #equ32_usb20_otg_hprt]

			ldr temp, usb2032_otg_host_setter_addr
			dsb
			str temp, USB2032_SETTER

			ldr temp, usb2032_otg_host_sender_addr
			dsb
			str temp, USB2032_SENDER

			ldr temp, usb2032_otg_host_receiver_addr
			dsb
			str temp, USB2032_RECEIVER

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

.globl USB2032_SETTER
.globl USB2032_SENDER
.globl USB2032_RECEIVER
USB2032_SETTER:   .word 0x00
USB2032_SENDER:   .word 0x00
USB2032_RECEIVER: .word 0x00

usb2032_otg_host_setter_addr:   .word usb2032_otg_host_setter
usb2032_otg_host_sender_addr:   .word usb2032_otg_host_sender
usb2032_otg_host_receiver_addr: .word usb2032_otg_host_receiver

