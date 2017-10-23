/**
 * usb2032.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * As of September 24, 2017, functions in usb2032.s is under construction and suspending through 10-day attempting.
 *
 * MEMORANDUM
 *
 * 1. No response, handshakes from a device (#0) when USB HCD transmits an OUT transaction (requests such as GET_DESCRIPTOR),
 *    and an IN transaction makes an interrupt of Transaction Error. 
 *
 * 2. Raspberry Pi B, B+, 2 and 3 are having inner USB Hub, LAN9514/9512 (LAN).
 *    LAN has 5 ports, and port #1 is already used by an ethernet adaptor.
 *    GPIO-38 is a USB (and GPIO) current-up handler, and GPIO-44 (ALT0: GPCLK1) is 25Mhz clock source of LAN.
 *
 * 3. The chip is for high-speed, but PHY (Physical Transiver of USB system) of BCM2835 seems to be up to Full-speed.
 * 
 * 4. Tested on RasPi Zero W. It seems that the resetting sequence of USB HCD is placed on some inappropriate place.
 *    So far, a keyboard device issues ACK to GET_DESCRIPTOR, but a self-powered hub dosen't issue any response.
 *    Resetting may be needed on the Hub. 
 */

/**
 * function usb2032_hub_activate
 * Search and Activate Hub
 *
 * Parameters
 * r0: Channel 0-15
 *
 * Return: r0 (0 as success, 1 as Error)
 * Error(1): Failed Memory Allocation
 */
.globl usb2032_hub_activate
usb2032_hub_activate:
	/* Auto (Local) Variables, but just Aliases */
	channel        .req r0
	temp           .req r1
	temp2          .req r2
	temp3          .req r3
	temp4          .req r4
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
	mov r0, #2                           @ 4 Bytes by 2 Words Equals 8 Bytes (64bit)
	bl system32_malloc
	mov buffer, r0
	pop {r0-r3,lr}

	cmp buffer, #0                       @ DMA Needs DWORD(32bit) aligned
	beq usb2032_hub_activate_error1

	/*
	mov temp, #equ32_usb20_reqt_recipient_other|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_host_to_device @ bmRequest Type
	orr temp, temp, #equ32_usb20_req_set_configuration<<8        @ bRequest
	orr temp, temp, #1<<16                                       @ wValue, Descriptor Index
	str temp, [buffer]
	*/

	/*
	mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_class|equ32_usb20_reqt_device_to_host @ bmRequest Type
	orr temp, temp, #equ32_usb20_req_get_descriptor<<8           @ bRequest
	orr temp, temp, #0<<16                                       @ wValue, Descriptor Index
	orr temp, temp, #equ32_usb20_val_descriptor_class<<16        @ wValue, Descriptor Type
	str temp, [buffer]
	mov temp, #equ32_usb20_index_device                          @ wIndex
	orr temp, temp, #64<<16                                      @ wLength
	str temp, [buffer, #4]
	*/

	mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_device_to_host @ bmRequest Type
	orr temp, temp, #equ32_usb20_req_get_descriptor<<8           @ bRequest
	orr temp, temp, #0<<16                                       @ wValue, Descriptor Index
	orr temp, temp, #equ32_usb20_val_descriptor_device<<16       @ wValue, Descriptor Type
	str temp, [buffer]
	mov temp, #equ32_usb20_index_device                          @ wIndex
	orr temp, temp, #64<<16                                      @ wLength
	str temp, [buffer, #4]
	
	/*
	mov temp, #equ32_usb20_reqt_recipient_other|equ32_usb20_reqt_type_class|equ32_usb20_reqt_device_to_host @ bmRequest Type
	orr temp, temp, #equ32_usb20_req_get_status<<8               @ bRequest
	orr temp, temp, #equ32_usb20_val_get_status<<16              @ wValue
	str temp, [buffer]
	mov temp, #1                                                 @ wIndex
	orr temp, temp, #equ32_usb20_len_get_status_port<<16         @ wLength
	str temp, [buffer, #4]
	*/

	push {r0-r3,lr}
	mov r0, buffer
	mov r1, #1                                @ Clean
	bl system32_cache_operation_heap
	pop {r0-r3,lr}

	mov split, #0x0

	/*
	mov split, #0x1                           @ Root Hub Port #1
	orr split, split, #0<<7                   @ Root Hub Address #0
	orr split, split, #0x80000000             @ Split Enable
	orr split, split, #0x0000C000             @ All
	*/

	push {r0-r3,lr}
	mov r1, #64                               @ Maximam Packet Size
	orr r1, r1, #0<<11                        @ Endpoint Number
	orr r1, r1, #0<<15                        @ In(1)/Out(0)
	orr r1, r1, #0<<16                        @ Endpoint Type
	orr r1, r1, #0<<18                        @ Device Address
	mov r2, #8                                @ Transfer Size is 8 Bytes
	orr r2, r2, #0x00080000                   @ Transfer Packet is 1 Packet
	orr r2, r2, #0x60000000                   @ Data Type is Setup
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
	mov temp4, r0
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, buffer
	mov r1, #0                                @ Invalidate
	bl system32_cache_operation_heap
	pop {r0-r3,lr}

	b usb2032_hub_activate_success

	usb2032_hub_activate_error1:
		mov r0, #1
		b usb2032_hub_activate_common

	usb2032_hub_activate_success:
		mov r0, temp4

	usb2032_hub_activate_common:
		macro32_dsb ip                    @ Ensure Completion of Instructions Before
		pop {r4-r9}
		mov pc, lr

.unreq channel
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
	 * On the loop below, we consider of the limitter (Time Out).
	 */
	usb2032_otg_host_receiver_loop:
		ldr temp, [memorymap_base, #equ32_usb20_otg_hcintn]
		tst temp, #0x00000002                                        @ Check Halted (HCD Disabled Channel N)
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
		tst temp, #0x00000080
		orrne r0, r0, #0x00000080                                         @ Transaction Error Bit[7]
		tst temp, #0x00000100
		orrne r0, r0, #0x00000100                                         @ Babble Error Bit[8]
		tst temp, #0x00000200
		orrne r0, r0, #0x00000200                                         @ Frame Overrun Bit[9]
		tst temp, #0x00000400
		orrne r0, r0, #0x00000400                                         @ Data Toggle Error Bit[10]
		tst temp, #0x00000800
		orrne r0, r0, #0x00000800                                         @ Other Errors Bit[11]

	usb2032_otg_host_receiver_common:
		str temp, [memorymap_base, #equ32_usb20_otg_hcintn]               @ write-clear
		mov temp, #0
		str temp, [memorymap_base, #equ32_usb20_otg_hcintmskn]            @ Mask All
		macro32_dsb ip                                                    @ Ensure Completion of Instructions Before
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

	ldr temp, [memorymap_base, #equ32_usb20_otg_hcintn]
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
		ldr temp, [memorymap_base, #equ32_usb20_otg_hccharn]

		orr temp, #0x80000000
		str temp, [memorymap_base, #equ32_usb20_otg_hccharn]              @ Enable Channel

		b usb2032_otg_host_sender_success

	usb2032_otg_host_sender_error:
		mov r0, #1                                                        @ Return with Error
		b usb2032_otg_host_sender_common

	usb2032_otg_host_sender_success:
		mov r0, #0                                                        @ Return with Success

	usb2032_otg_host_sender_common:
		macro32_dsb ip                                                    @ Ensure Completion of Instructions Before
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
 *   r1 Bit[10:0]: Maximum Packet Size (in Low Speed, Fixed to 8 bytes)
 *   r1 Bit[14:11]: Endpoint Number
 *   r1 Bit[15]: Endpoint Direction, 0 Out, 1, In
 *   r1 Bit[17:16]: Endpoint Type, 0 Control, 1 Isochronous, 2 Bulk, 3 Interrupt
 *   r1 Bit[24:18]: Device Address
 *   r1 Bit[25]: Full and High Speed(0)/Low Speed(1)
 *   r1 Bit[26]: Even(0)/Odd(1) Frame in Periodic Transactions
 *
 * r2: Channel N Transfer Size (Virtual Register), Reserved Bits expects SBZ (Zeros)
 *   r2 Bit[18:0]: Transfer Size
 *   r2 Bit[28:19]: Packet Count (Transfer Size divided by Max Packet Size, Round Up)
 *   r2 Bit[30:29]: PID, 00b DATA0, 01b DATA2, 10b DATA1, 11b MDATA (No Control)/SETUP (Control)
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
 
	str hcchar, [memorymap_base, #equ32_usb20_otg_hccharn]

	bic transfer_size, transfer_size, #0x80000000                          @ Only Validate Bit[30:0]

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
		macro32_dsb ip                                                     @ Ensure Completion of Instructions Before
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

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_base

	/**
	 * Reset
	 */
	ldr temp, [memorymap_base, #equ32_usb20_otg_grstctl]      @ Global Reset Control

	tst temp, #0x80000000                                     @ ANDS AHB Idle Bit[31]
	beq usb2032_otg_host_start_error                          @ If Bus is Not in Idle

	orr temp, temp, #0x01                                     @ Core Soft Reset Bit[0]
	str temp, [memorymap_base, #equ32_usb20_otg_grstctl]

	macro32_dsb ip

	usb2032_otg_host_start_resetcore:
		ldr temp, [memorymap_base, #equ32_usb20_otg_grstctl]
		tst temp, #0x01
		bne usb2032_otg_host_start_resetcore

	orr temp, temp, #0x02                                     @ HClk Soft Reset Bit[0]
	str temp, [memorymap_base, #equ32_usb20_otg_grstctl]

	macro32_dsb ip

	usb2032_otg_host_start_resetinternalbus:
		ldr temp, [memorymap_base, #equ32_usb20_otg_grstctl]
		tst temp, #0x02
		bne usb2032_otg_host_start_resetinternalbus

	/**
	 * Core Global CSRs (Base + 0x0)
	 * Global USB Configuration has each default setting in SoCs,
	 * e.g. in BCM2836 has 0x20402700.
	 * So in this section, we need to make DMA on, make Core Reset and FIFO Flush,
	 * and make power on, reset, enable host port.
	 */

	ldr temp, [memorymap_base, #equ32_usb20_otg_gusbcfg]      @ Global USB Configuration
	bic temp, #0x40000000                                     @ Clear Force Device Mode Bit[30]
	orr temp, #0x20000000                                     @ Set Force Host Mode Bit[29]
	str temp, [memorymap_base, #equ32_usb20_otg_gusbcfg]

	/**
	 * AHB Cofiguration (GAHBCFG) Bit[23] may have DMA Incremental(0) or single (1) in case.
	 * BCM2836 has 0x0000000E in Default.
	 * In this function, DMA is enabled and DMA Burst Becomes Incremental
	 */
	mov temp, #0x2E                                           @ Enable DMA Bit[5], BurstType Bit[4:1]
	str temp, [memorymap_base, #equ32_usb20_otg_gahbcfg]      @ Global AHB Configuration

	/**
	 * FIFO Size
	 */
	mov temp, #0x1000
	str temp, [memorymap_base, #equ32_usb20_otg_grxfsiz]      @ RxFIFO Size (Words)

	mov temp, #0x1000                                         @ Start Address Bit[15:0], Equals RxFIFO Size
	orr temp, temp, #0x0100<<16                               @ Size Bit [31:16]
	str temp, [memorymap_base, #equ32_usb20_otg_gnptxfsiz]    @ Non-periodic (NP) TxFIFO Size

	/* Periodic TxFIFO Size Registers (Base + 0x100) */

	add memorymap_base, memorymap_base, #equ32_usb20_otg_ptxfsiz_base

	mov temp, #0x2000                                         @ Start Address Bit[15:0], Equals RxFIFO Size + NPTxFIFO Size
	orr temp, temp, #0x0200<<16                               @ Size Bit [31:16]
	str temp, [memorymap_base, #equ32_usb20_otg_hptxfsiz]     @ Non-periodic TxFIFO Size

	sub memorymap_base, memorymap_base, #equ32_usb20_otg_ptxfsiz_base

	/**
	 * FIFO Flush
	 */
	ldr temp, [memorymap_base, #equ32_usb20_otg_grstctl]      @ Global Reset Control

	bic temp, temp, #0x7C0                                    @ TxFIFO Number Bit[10:6]
	orr temp, temp, #0x400                                    @ Flush All TxFIFOs
	str temp, [memorymap_base, #equ32_usb20_otg_grstctl]

	ldr temp, [memorymap_base, #equ32_usb20_otg_grstctl]
	tst temp, #0x80000000                                     @ ANDS AHB Idle Bit[31]
	beq usb2032_otg_host_start_error                          @ If Bus is Not in Idle

	orr temp, temp, #0x20                                     @ TxFIFO Flush Bit[5]
	str temp, [memorymap_base, #equ32_usb20_otg_grstctl]

	macro32_dsb ip

	usb2032_otg_host_start_flushtxfifo:
		ldr temp, [memorymap_base, #equ32_usb20_otg_grstctl]
		tst temp, #0x20
		bne usb2032_otg_host_start_flushtxfifo

	tst temp, #0x80000000                                     @ ANDS AHB Idle Bit[31]
	beq usb2032_otg_host_start_error                          @ If Bus is Not in Idle

	orr temp, temp, #0x10                                     @ RxFIFO Flush Bit[4]
	str temp, [memorymap_base, #equ32_usb20_otg_grstctl]

	macro32_dsb ip

	usb2032_otg_host_start_flushrxfifo:
		ldr temp, [memorymap_base, #equ32_usb20_otg_grstctl]
		tst temp, #0x10
		bne usb2032_otg_host_start_flushrxfifo

	/**
	 * Host Mode CSRs (Base + 0x400)
	 */

	add memorymap_base, memorymap_base, #equ32_usb20_otg_host_base

	mov temp, #0x04                                           @ Set FS-LS Only Bit[2], PHY Clock to 30Mhz or 60Mhz Bit[1:0]
	str temp, [memorymap_base, #equ32_usb20_otg_hcfg]         @ Host Configuration

	ldr temp, [memorymap_base, #equ32_usb20_otg_hprt]         @ Host Port Control and Status

	tst temp, #0x00001000                                     @ Port Power Bit[12]
	bne usb2032_otg_host_start_jump                           @ If Power On

	orr temp, #0x00001000
	str temp, [memorymap_base, #equ32_usb20_otg_hprt]

	macro32_dsb ip

	usb2032_otg_host_start_jump:

		orr temp, #0x00000100                                      @ Port Reset Bit[8]
		str temp, [memorymap_base, #equ32_usb20_otg_hprt]

		macro32_dsb ip

		push {r0-r3,lr}
		/*mov r0, #0xC400*/                                            @ 50176 us, 50.176 ms (In High-speed, 50 ms is minimum)
		mov r0, #0xEB00                                            @ 60160 us

		bl system32_sleep
		pop {r0-r3,lr}

		bic temp, #0x00000100                                      @ Clear Port Reset Bit[8]
		str temp, [memorymap_base, #equ32_usb20_otg_hprt]

		macro32_dsb ip

		usb2032_otg_host_start_jump_loop:
			ldr temp, [memorymap_base, #equ32_usb20_otg_hprt]
			tst temp, #0x00000008                                  @ Port Enable/Disable Change Bit[3]
			beq usb2032_otg_host_start_jump_loop

			/**
			 * If already connected with devices including Hub,
			 * HPRT bit[1:0] become set, Port Connection Deteched Bit[1] causes
			 * an interrupt on GINTSTS. If you want clear it, you will need to write-clear to Bit[1]
			 * Also, Port Enable/Disable Change Bit[3], Port Overcurrent Change Bit[5] are to write-clear
			 */
			bic temp, #0x4                                         @ Clear Port Enable Bit[2] Because Write-clear
			str temp, [memorymap_base, #equ32_usb20_otg_hprt]

			/* Global OTG Control */
			mov memorymap_base, #equ32_peripherals_base
			add memorymap_base, memorymap_base, #equ32_usb20_otg_base
			ldr temp, [memorymap_base, #equ32_usb20_otg_gotgctl]       @ Global OTG Control and Status
			orr temp, temp, #0x00000400                                @ Host Set HNP Enable Bit[10]
			str temp,  [memorymap_base, #equ32_usb20_otg_gotgctl]

			ldr temp, usb2032_otg_host_setter_addr
			str temp, USB2032_SETTER

			ldr temp, usb2032_otg_host_sender_addr
			str temp, USB2032_SENDER

			ldr temp, usb2032_otg_host_receiver_addr
			str temp, USB2032_RECEIVER

		b usb2032_otg_host_start_success

	usb2032_otg_host_start_error:
		mov r0, #1                           @ Return with Error
		b usb2032_otg_host_start_common

	usb2032_otg_host_start_success:
		mov r0, #0                           @ Return with Success

	usb2032_otg_host_start_common:
		macro32_dsb ip                       @ Ensure Completion of Instructions Before
		mov pc, lr

.unreq memorymap_base
.unreq temp

.globl USB2032_SETTER
.globl USB2032_SENDER
.globl USB2032_RECEIVER
USB2032_SETTER:   .word 0x00
USB2032_SENDER:   .word 0x00
USB2032_RECEIVER: .word 0x00

usb2032_otg_host_setter_addr:   .word usb2032_otg_host_setter
usb2032_otg_host_sender_addr:   .word usb2032_otg_host_sender
usb2032_otg_host_receiver_addr: .word usb2032_otg_host_receiver

