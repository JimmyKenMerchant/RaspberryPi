/**
 * usb2032.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 *
 * MEMORANDUM
 *
 * 1. Raspberry Pi B, B+, 2 and 3 are having inner USB Hub, LAN9514/9512 (LAN).
 *    LAN has 5 ports, and port #1 is already used by an ethernet adaptor.
 *    GPIO-44 (ALT0: GPCLK1) is 25Mhz clock source of LAN.
 *    GPIO-38 is a USB (and GPIO) current-up handler (RasPi 3 has already current-upped as default without GPIO-38).
 *
 * 2. Tested on RasPi Zero W and 2B (V1.1).
 *    It seems that the resetting sequence of USB HCD is placed on some inappropriate place.
 *
 * 3. Changed the duration of resetting the host port from appx. 50ms to appx. 60ms. LAN9514 issues ACK after this change.
 *
 * 4. Trial of GET_DESCRIPTOR to Zero W and 2B (V1.1). On Zero W, each device descriptor of HUB and HID can be gotten
 *    successfully. On 2B, the device descriptor of HUB, LAN9514, can be be gotten.
 *
 * 5. On Data stage, its PID must be DATA1. If you choose others, USB HCD interrupts Data Toggle Error.
 *
 * 6. On Status stage, its PID must be DATA1.
 *
 * 7. December 8, 2017. Trial on HUB. Zero W with an external hub worked the enumeration.
 *
 * 8. December 12, 2017. Trial on HUB. 2B (V1.1) with LAN9514 can be fully gotten the device descriptor.
 *    From BCM2836, DMA alignment seems to be 32-bytes (256-bits) from 4-bytes (32-bits) on BCM2835.
 *    Note that 32-bytes alignment is the same as Control Block (CB) of the DMA unit.
 *    Plus, each transfer seems to consist with 4-bytes (one word) blocks,
 *    e.g., if you intended to receive 18 bytes on transfer to get the device descriptor, device returns 20 bytes.
 *    This may cause overflow of memory space that you assigned.
 *    Also, from BCM2836, USB HCD seems to have a buffer on the side of the peripheral to store OUT data from ARM,
 *    for example, requests of set-up. In my experience, this buffer is the same as CB of the DMA unit.
 *    This buffer is tied with memory address on DMA. So if you re-use same memory address for another request,
 *    it causes an odd transaction that makes STALL or transaction error.
 *    Besides, the amount of issuing transaction error is reduced less than BCM2835.
 *
 * 9. December 14, 2017. Reviewed device I/O coherency with DMA of USB HCD of BCM2836.
 *    Flagging shared memory or strongly ordered memory seems not to make data on the peripheral side evicted from the buffer.
 *    Adding latency (by a clock counter) after cleaning to Point of Coherency seems not to make it too.
 *    Anyway, more tests is needed to know this issue, never estimate.
 *    Application Note 228 "Implementing DMA on ARM SMP Systems" of ARM is the reference.
 *
 *10. July 6, 2019. Reviewed device I/O coherency with DMA of USB HCD of BCM2835, BCM2836, and BCM2837.
 *    Using the bus address on the point of (system) coherency (PoC), L2 cache,
 *    gurantees I/O coherency among ARM, GPU, DMA, and peripherals.
 *    In Page 7 of the BCM2835 manual, the need of accessing the uncached alias (from 0xC0000000) by periphrals is described.
 *    Besides, L2 cache is turned on in default, so PoC is expected to be on L2 cache alias.
 */

/**
 * On this system, for convenience, usb2032_* uses "Ticket".
 * If any device is detected by usb2032_hub_search_device, you will get the returned value as below. The address of the device is already assigned.
 *
 * Ticket:
 *    Bit[6:0]: Address of Device, If Zero, Not Allocated Address
 *    Bit[13:7]: Port Number
 *    Bit[20:14]: Address of Hub
 *    Bit[30:29]: 00b High Speed,10b Full Speed, 11b Low Speed
 *
 * You can use this ticket for functions such as for activation of Hubs.
 * If you use any device with direct connection, ticket is not needed. Just use zero for the argument of each function.
 */


/**
 * function usb2032_get_buffer
 * Get Buffer (32 Bytes aligned)
 *
 * Parameters
 * r0: Number of Words, 1 Word means 4 Bytes
 *
 * Return: r0 (Pointer of Start Address of Memory Space, If Zero, Memory Allocation Fails)
 */
.globl usb2032_get_buffer
usb2032_get_buffer:
	/* Auto (Local) Variables, but just Aliases */
	num_words       .req r0

	push {lr}

	add num_words, num_words, #8

	push {r1-r3}
	bl heap32_malloc_noncache
	pop {r1-r3}

	/* DMA Needs 32 Bytes aligned */
	push {r1-r3}
	bl heap32_align_32
	pop {r1-r3}

	usb2032_get_buffer_common:
		macro32_dsb ip                    @ Ensure Completion of Instructions Before
		pop {pc}

.unreq num_words


/**
 * function usb2032_clear_buffer
 * Clear Buffer (32 Bytes aligned)
 *
 * Parameters
 * r0: Address of Memory Space Created by usb2032_get_buffer
 *
 * Return: r0 (0 as Success, 1 as Error)
 * Error: Pointer of Start Address is Null (0)
 */
.globl usb2032_clear_buffer
usb2032_clear_buffer:
	/* Auto (Local) Variables, but just Aliases */
	address       .req r0

	push {lr}

	bl heap32_clear_align
	bl heap32_mfree

	usb2032_clear_buffer_common:
		macro32_dsb ip                    @ Ensure Completion of Instructions Before
		pop {pc}

.unreq address


/**
 * function usb2032_clear_halt
 * Clear Halted Endpoint
 *
 * Parameters
 * r0: Channel 0-15
 * r1: Character
 * r2: Endpoint
 * r3: Split Control
 *
 * Return: r0 (Response, -1 as Error)
 * Error(-1): Failed Memory Allocation
 */
.globl usb2032_clear_halt
usb2032_clear_halt:
	/* Auto (Local) Variables, but just Aliases */
	channel         .req r0
	character       .req r1
	transfer_size   .req r2
	buffer_rq       .req r3
	split_ctl       .req r4
	buffer_rx       .req r5
	temp            .req r6
	response        .req r7
	num_endpoint    .req r8

	push {r4-r8,lr}

	mov num_endpoint, transfer_size
	mov split_ctl, buffer_rq

	push {r0-r3}
	mov r0, #2                                                   @ 4 Bytes by 2 Words Equals 8 Bytes
	bl usb2032_get_buffer
	mov temp, r0
	pop {r0-r3}
	cmp temp, #0
	beq usb2032_clear_halt_error1
	mov buffer_rq, temp

	mov transfer_size, #0
	mov buffer_rx, #0

	/* Clear Endpoint Halt */
	mov temp, #equ32_usb20_reqt_recipient_endpoint|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_host_to_device @ bmRequest Type
	orr temp, temp, #equ32_usb20_req_clear_feature<<8            @ bRequest
	orr temp, temp, #equ32_usb20_val_endpoint_halt<<16           @ wValue
	str temp, [buffer_rq]
	mov temp, num_endpoint                                       @ wIndex
	orr temp, temp, #0<<16                                       @ wLength
	str temp, [buffer_rq, #4]

	push {r0-r3}
	push {split_ctl,buffer_rx}
	bl usb2032_control
	add sp, sp, #8
	mov response, r0
	mov temp, r1
	pop {r0-r3}

	b usb2032_clear_halt_success

	usb2032_clear_halt_error1:
		mvn r0, #0                        @ Return with -1
		b usb2032_clear_halt_common

	usb2032_clear_halt_success:
		mov r0, response

	usb2032_clear_halt_common:
		push {r0-r3}
		mov r0, buffer_rq
		cmp r0, #0                        @ If Not Allocated
		blne usb2032_clear_buffer
		pop {r0-r3}

		macro32_dsb ip                    @ Ensure Completion of Instructions Before
		pop {r4-r8,pc}

.unreq channel
.unreq character
.unreq transfer_size
.unreq buffer_rq
.unreq split_ctl
.unreq buffer_rx
.unreq temp
.unreq response
.unreq num_endpoint


/**
 * function usb2032_hub_activate
 * Search and Activate Hub
 * Caution! This Function Is Only Available for One of USB2.0 High Speed Hub.
 * This Function Is Only Available for No Composite Device, i.e, Configuration Number is Fixed to #1.
 *
 * Parameters
 * r0: Channel 0-15
 * r1: Ticket Issued by usb2032_hub_search_device, or 0 as Direct Connection
 *
 * Return: r0 (Ticket of Hub, 0, -1, -2, and -3 as Error)
 * Error(0): No Connection
 * Error(-1): No Hub
 * Error(-2): Failure of Communication (Stall on Critical Point/Time Out)
 * Error(-3): Failed Memory Allocation
 */
.globl usb2032_hub_activate
usb2032_hub_activate:
	/* Auto (Local) Variables, but just Aliases */
	channel         .req r0
	character       .req r1
	transfer_size   .req r2
	buffer_rq       .req r3
	split_ctl       .req r4
	buffer_rx       .req r5
	response        .req r6
	temp            .req r7
	device_class    .req r8
	i               .req r9
	addr_device     .req r10
	ticket          .req r11

	push {r4-r11,lr}

	mov ticket, character

	mov buffer_rx, #0                  @ To Check Whether Allocated or Not

	mov split_ctl, #0x0                @ High Speed Hub Only

	tst ticket, #0x60000000            @ Check High Speed
	bne usb2032_hub_activate_error1

	cmp ticket, #0
	movne addr_device, ticket
	andne addr_device, addr_device, #0x0000007F @ Bit[6:0]: Device Address
	bne usb2032_hub_activate_buffer

	mov addr_device, #0

	push {r0-r3}
	ldr ip, USB2032_ROOTHUB
	blx ip
	mov temp, r0
	pop {r0-r3}

	tst temp, #equ32_usb20_status_hubport_connection
	beq usb2032_hub_activate_error0

	tst temp, #equ32_usb20_status_hubport_highspeed
	beq usb2032_hub_activate_error1

	usb2032_hub_activate_buffer:

		push {r0-r3}
		mov r0, #2                                                   @ 4 Bytes by 2 Words Equals 8 Bytes
		bl usb2032_get_buffer
		mov temp, r0
		pop {r0-r3}
		cmp temp, #0
		beq usb2032_hub_activate_error3
		mov buffer_rq, temp

		push {r0-r3}
		mov r0, #16                                                  @ 4 Bytes by 16 Words Equals 64 Bytes
		bl usb2032_get_buffer
		mov buffer_rx, r0
		pop {r0-r3}
		cmp buffer_rx, #0
		beq usb2032_hub_activate_error3

		/* Get Device Descriptor */

		mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_device_to_host @ bmRequest Type
		orr temp, temp, #equ32_usb20_req_get_descriptor<<8           @ bRequest
		orr temp, temp, #0<<16                                       @ wValue, Descriptor Index
		orr temp, temp, #equ32_usb20_val_descriptor_device<<16       @ wValue, Descriptor Type
		str temp, [buffer_rq]
		mov temp, #0                                                 @ wIndex
		orr temp, temp, #18<<16                                      @ wLength
		str temp, [buffer_rq, #4]

		mov character, #64                             @ Maximam Packet Size
		orr character, character, #0<<11               @ Endpoint Number
		orr character, character, #1<<15               @ In(1)/Out(0)
		orr character, character, #0<<16               @ Endpoint Type
		orr character, character, addr_device, lsl #18 @ Device Address              @ Device Address

		mov transfer_size, #18                         @ Transfer Size is 18 Bytes
		orr transfer_size, transfer_size, #1<<19       @ Transfer Packet is 1 Packet
		orr transfer_size, transfer_size, #0x40000000  @ Data Type is DATA1, Otherwise, meet Data Toggle Error

		push {r0-r3}
		push {split_ctl,buffer_rx}
		bl usb2032_control
		add sp, sp, #8
		mov response, r0
		mov temp, r1
		pop {r0-r3}

		cmp response, #0
		bne usb2032_hub_activate_error2                      @ Failure of Communication

/*
macro32_debug response, 0, 62
macro32_debug temp, 0, 74
macro32_debug_hexa buffer_rx, 0, 86, 64
*/

		ldrb device_class, [buffer_rx, #4]
		cmp device_class, #9                                 @ Device Class is Hub or Not
		bne usb2032_hub_activate_error1

		.unreq device_class
		num_ports .req r8

		cmp addr_device, #0
		bne usb2032_hub_activate_config

		/* Set Address */

		ldr addr_device, USB2032_ADDRESS_LENGTH
		add addr_device, addr_device, #1
		str addr_device, USB2032_ADDRESS_LENGTH

		mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_host_to_device @ bmRequest Type
		orr temp, temp, #equ32_usb20_req_set_address<<8              @ bRequest
		orr temp, temp, addr_device, lsl #16                         @ wValue, address
		str temp, [buffer_rq]
		mov temp, #0                                                 @ wIndex
		orr temp, temp, #0<<16                                       @ wLength
		str temp, [buffer_rq, #4]

		mov character, #64                            @ Maximam Packet Size
		orr character, character, #0<<11              @ Endpoint Number
		orr character, character, #0<<15              @ In(1)/Out(0)
		orr character, character, #0<<16              @ Endpoint Type
		orr character, character, #0<<18              @ Device Address

		mov transfer_size, #0                         @ Transfer Size is 0 Bytes

		push {r0-r3}
		push {split_ctl,buffer_rx}
		bl usb2032_control
		add sp, sp, #8
		mov response, r0
		mov temp, r1
		pop {r0-r3}

		cmp response, #0
		bne usb2032_hub_activate_error2                      @ Failure of Communication

		mov ticket, addr_device

	usb2032_hub_activate_config:

		/* Set Configuration */

		mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_host_to_device @ bmRequest Type
		orr temp, temp, #equ32_usb20_req_set_configuration<<8        @ bRequest
		orr temp, temp, #1<<16                                       @ wValue, Descriptor Index
		str temp, [buffer_rq]
		mov temp, #0                                                 @ wIndex
		orr temp, temp, #0<<16                                       @ wLength
		str temp, [buffer_rq, #4]

		mov character, #64                             @ Maximam Packet Size
		orr character, character, #0<<11               @ Endpoint Number
		orr character, character, #0<<15               @ In(1)/Out(0)
		orr character, character, #0<<16               @ Endpoint Type
		orr character, character, addr_device, lsl #18 @ Device Address

		mov transfer_size, #0                          @ Transfer Size is 0 Bytes

		push {r0-r3}
		push {split_ctl,buffer_rx}
		bl usb2032_control
		add sp, sp, #8
		mov response, r0
		mov temp, r1
		pop {r0-r3}

		cmp response, #0
		bne usb2032_hub_activate_error2                      @ Failure of Communication

		/* Remote Wakeup  */

		mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_host_to_device @ bmRequest Type
		orr temp, temp, #equ32_usb20_req_set_feature<<8              @ bRequest
		orr temp, temp, #equ32_usb20_val_device_remote_wakeup<<16    @ wValue
		str temp, [buffer_rq]

		mov temp, #0
		str temp, [buffer_rq, #4]

		push {r0-r3}
		push {split_ctl,buffer_rx}
		bl usb2032_control
		add sp, sp, #8
		mov response, r0
		mov temp, r1
		pop {r0-r3}

		cmp response, #0
		bne usb2032_hub_activate_error2                      @ Failure of Communication

		/* Set Local Power  */
		/*
		mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_class|equ32_usb20_reqt_host_to_device @ bmRequest Type
		orr temp, temp, #equ32_usb20_req_set_feature<<8              @ bRequest
		orr temp, temp, #equ32_usb20_val_hub_localpower<<16          @ wValue
		str temp, [buffer_rq]

		mov temp, #0
		str temp, [buffer_rq, #4]

		push {r0-r3}
		push {split_ctl,buffer_rx}
		bl usb2032_control
		add sp, sp, #8
		mov response, r0
		mov temp, r1
		pop {r0-r3}
		*/

		/* Get Hub Descriptor  */

		mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_class|equ32_usb20_reqt_device_to_host @ bmRequest Type
		orr temp, temp, #equ32_usb20_req_get_descriptor<<8           @ bRequest
		orr temp, temp, #0<<16                                       @ wValue, Descriptor Index
		orr temp, temp, #equ32_usb20_val_descriptor_hub<<16          @ wValue, Descriptor Type
		str temp, [buffer_rq]
		mov temp, #0                                                 @ wIndex
		orr temp, temp, #9<<16                                       @ wLength
		str temp, [buffer_rq, #4]

		mov character, #64                             @ Maximam Packet Size
		orr character, character, #0<<11               @ Endpoint Number
		orr character, character, #1<<15               @ In(1)/Out(0)
		orr character, character, #0<<16               @ Endpoint Type
		orr character, character, addr_device, lsl #18 @ Device Address

		mov transfer_size, #9                          @ Transfer Size is 9 Bytes
		orr transfer_size, transfer_size, #0x00080000  @ Transfer Packet is 1 Packet
		orr transfer_size, transfer_size, #0x40000000  @ Data Type is DATA1, Otherwise, meet Data Toggle Error

		push {r0-r3}
		push {split_ctl,buffer_rx}
		bl usb2032_control
		add sp, sp, #8
		mov response, r0
		mov temp, r1
		pop {r0-r3}

		cmp response, #0
		bne usb2032_hub_activate_error2                      @ Failure of Communication

/*
macro32_debug response, 0, 112
macro32_debug temp, 0, 124
macro32_debug_hexa buffer_rx, 0, 136, 64
*/

		ldrb num_ports, [buffer_rx, #2]                   @ Get Number of Ports

	usb2032_hub_activate_powerport:
		mov i, #1

		mov character, #64                             @ Maximam Packet Size
		orr character, character, #0<<11               @ Endpoint Number
		orr character, character, #0<<15               @ In(1)/Out(0)
		orr character, character, #0<<16               @ Endpoint Type
		orr character, character, addr_device, lsl #18 @ Device Address

		mov transfer_size, #0

		usb2032_hub_activate_powerport_loop:

			mov temp, #equ32_usb20_reqt_recipient_other|equ32_usb20_reqt_type_class|equ32_usb20_reqt_host_to_device @ bmRequest Type
			orr temp, temp, #equ32_usb20_req_set_feature<<8              @ bRequest
			orr temp, temp, #equ32_usb20_val_hubport_power<<16           @ wValue
			str temp, [buffer_rq]
			mov temp, i                                                  @ wIndex
			orr temp, temp, #0<<16                                       @ wLength
			str temp, [buffer_rq, #4]

			push {r0-r3}
			push {split_ctl,buffer_rx}
			bl usb2032_control
			add sp, sp, #8
			mov response, r0
			mov temp, r1
			pop {r0-r3}

			cmp response, #0
			bne usb2032_hub_activate_error2                      @ Failure of Communication

			add i, i, #1
			cmp i, num_ports
			ble usb2032_hub_activate_powerport_loop

			push {r0-r3}
			mov r0, #0x19000                          @ 102.400 ms
			bl arm32_sleep
			pop {r0-r3}

			b usb2032_hub_activate_success

	usb2032_hub_activate_error0:
		mov r0, #0                        @ Return with 0
		b usb2032_hub_activate_common

	usb2032_hub_activate_error1:
		mvn r0, #0                        @ Return with -1
		b usb2032_hub_activate_common

	usb2032_hub_activate_error2:
		mvn r0, #1                        @ Return with -2
		b usb2032_hub_activate_common

	usb2032_hub_activate_error3:
		mvn r0, #2                        @ Return with -3
		b usb2032_hub_activate_common

	usb2032_hub_activate_success:
		mov r0, ticket

	usb2032_hub_activate_common:
		push {r0-r3}
		mov r0, buffer_rq
		cmp r0, #0                        @ If Not Allocated
		blne usb2032_clear_buffer
		pop {r0-r3}
		push {r0-r3}
		mov r0, buffer_rx
		cmp r0, #0                        @ If Not Allocated
		blne usb2032_clear_buffer
		pop {r0-r3}

		macro32_dsb ip                    @ Ensure Completion of Instructions Before
		pop {r4-r11,pc}

.unreq channel
.unreq character
.unreq transfer_size
.unreq buffer_rq
.unreq split_ctl
.unreq buffer_rx
.unreq response
.unreq temp
.unreq num_ports
.unreq i
.unreq addr_device
.unreq ticket


/**
 * function usb2032_hub_search_device
 * Search, Reset and Set Address to a Device to Be Attached to Any Port of Targeted Hub
 * This function search and reset one device only.
 * If you attached multiple devices, call this function again after enumeration of the device prior detected. 
 * Caution! This Function Is Only Available for One of USB2.0 High Speed Hub.
 *
 * Parameters
 * r0: Channel 0-15
 * r1: Ticket of Hub
 *
 * Return: r0 (Ticket of Detected Device Described Below, 0, -1, -2, and -3 as Error)
 * Ticket:
 *    Bit[6:0]: Address of Device, If Zero, Not Allocated Address
 *    Bit[13:7]: Port Number
 *    Bit[20:14]: Address of Hub
 *    Bit[30:29]: 00b High Speed,10b Full Speed, 11b Low Speed
 * Error(0): Any Device Was Not Detected (No Connection)
 * Error(-1): No Hub
 * Error(-2): Failure of Communication (Stall on Critical Point/Time Out)
 * Error(-3): Failed Memory Allocation
 */
.globl usb2032_hub_search_device
usb2032_hub_search_device:
	/* Auto (Local) Variables, but just Aliases */
	channel         .req r0
	character       .req r1
	transfer_size   .req r2
	buffer_rq       .req r3
	split_ctl       .req r4
	buffer_rx       .req r5
	response        .req r6
	temp            .req r7
	device_class    .req r8
	i               .req r9
	addr_device     .req r10
	timeout         .req r11

	push {r4-r11,lr}

	mov buffer_rx, #0                                            @ To Check Whether Allocated or Not

	mov split_ctl, #0x0                                          @ High Speed Hub Only

	mov addr_device, character                                   @ Translate Ticket to Address

	tst addr_device, #0x60000000                                 @ Check High Speed
	bne usb2032_hub_search_device_error1

	and addr_device, addr_device, #0x0000007F                    @ Bit[6:0]: Device Address

	push {r0-r3}
	mov r0, #2                                                   @ 4 Bytes by 2 Words Equals 8 Bytes
	bl usb2032_get_buffer
	mov temp, r0
	pop {r0-r3}
	cmp temp, #0
	beq usb2032_hub_search_device_error3
	mov buffer_rq, temp

	push {r0-r3}
	mov r0, #16                                                  @ 4 Bytes by 16 Words Equals 64 Bytes
	bl usb2032_get_buffer
	mov buffer_rx, r0
	pop {r0-r3}
	cmp buffer_rx, #0
	beq usb2032_hub_search_device_error3

	/* Get Device Descriptor */

	mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_device_to_host @ bmRequest Type
	orr temp, temp, #equ32_usb20_req_get_descriptor<<8           @ bRequest
	orr temp, temp, #0<<16                                       @ wValue, Descriptor Index
	orr temp, temp, #equ32_usb20_val_descriptor_device<<16       @ wValue, Descriptor Type
	str temp, [buffer_rq]
	mov temp, #0                                                 @ wIndex
	orr temp, temp, #18<<16                                      @ wLength
	str temp, [buffer_rq, #4]

	mov character, #64                              @ Maximam Packet Size
	orr character, character, #0<<11                @ Endpoint Number
	orr character, character, #1<<15                @ In(1)/Out(0)
	orr character, character, #0<<16                @ Endpoint Type
	orr character, character, addr_device, lsl #18  @ Device Address

	mov transfer_size, #18                        @ Transfer Size is 18 Bytes
	orr transfer_size, transfer_size, #1<<19      @ Transfer Packet is 3 Packet (3 by 8 equals 24)
	orr transfer_size, transfer_size, #0x40000000 @ Data Type is DATA1, Otherwise, meet Data Toggle Error

	push {r0-r3}
	push {split_ctl,buffer_rx}
	bl usb2032_control
	add sp, sp, #8
	mov response, r0
	mov temp, r1
	pop {r0-r3}

	cmp response, #0
	bne usb2032_hub_search_device_error2                 @ Failure of Communication

	ldrb device_class, [buffer_rx, #4]
	cmp device_class, #9                                 @ Device Class is Hub or Not
	bne usb2032_hub_search_device_error1

	.unreq device_class
	num_ports .req r8

	/* Get Hub Descriptor  */

	mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_class|equ32_usb20_reqt_device_to_host @ bmRequest Type
	orr temp, temp, #equ32_usb20_req_get_descriptor<<8           @ bRequest
	orr temp, temp, #0<<16                                       @ wValue, Descriptor Index
	orr temp, temp, #equ32_usb20_val_descriptor_hub<<16          @ wValue, Descriptor Type
	str temp, [buffer_rq]
	mov temp, #0                                                 @ wIndex
	orr temp, temp, #9<<16                                       @ wLength
	str temp, [buffer_rq, #4]

	mov character, #64                              @ Maximam Packet Size
	orr character, character, #0<<11                @ Endpoint Number
	orr character, character, #1<<15                @ In(1)/Out(0)
	orr character, character, #0<<16                @ Endpoint Type
	orr character, character, addr_device, lsl #18  @ Device Address

	mov transfer_size, #9                         @ Transfer Size is 9 Bytes
	orr transfer_size, transfer_size, #0x00080000 @ Transfer Packet is 1 Packet
	orr transfer_size, transfer_size, #0x40000000 @ Data Type is DATA1, Otherwise, meet Data Toggle Error

	push {r0-r3}
	push {split_ctl,buffer_rx}
	bl usb2032_control
	add sp, sp, #8
	mov response, r0
	mov temp, r1
	pop {r0-r3}

	cmp response, #0
	bne usb2032_hub_search_device_error2                @ Failure of Communication

	ldrb num_ports, [buffer_rx, #2]                     @ Get Number of Ports

	usb2032_hub_search_device_main:
		mov i, #1

		/* Get Port Status  */

		mov character, #64                              @ Maximam Packet Size
		orr character, character, #0<<11                @ Endpoint Number
		orr character, character, #1<<15                @ In(1)/Out(0)
		orr character, character, #0<<16                @ Endpoint Type
		orr character, character, addr_device, lsl #18  @ Device Address

		mov transfer_size, #4                         @ Transfer Size is 4 Bytes
		orr transfer_size, transfer_size, #0x00080000 @ Transfer Packet is 1 Packet
		orr transfer_size, transfer_size, #0x40000000 @ Data Type is DATA1, Otherwise, meet Data Toggle Error

		usb2032_hub_search_device_main_loop:

			mov temp, #equ32_usb20_reqt_recipient_other|equ32_usb20_reqt_type_class|equ32_usb20_reqt_device_to_host @ bmRequest Type
			orr temp, temp, #equ32_usb20_req_get_status<<8               @ bRequest
			orr temp, temp, #equ32_usb20_val_get_status<<16              @ wValue
			str temp, [buffer_rq]
			mov temp, i                                                  @ wIndex
			orr temp, temp, #equ32_usb20_len_get_status_port<<16         @ wLength
			str temp, [buffer_rq, #4]

			push {r0-r3}
			push {split_ctl,buffer_rx}
			bl usb2032_control
			add sp, sp, #8
			mov response, r0
			mov temp, r1
			pop {r0-r3}

			cmp response, #0
			bne usb2032_hub_search_device_error2                         @ Failure of Communication

			ldr response, [buffer_rx]                                    @ Get Status
			tst response, #equ32_usb20_status_hubport_connection_change  @ Connection Change Detection
			beq usb2032_hub_search_device_main_loop_common

			/**
			 * Enable Detected Device
			 */

			/* Clear Connection Change */

			mov temp, #equ32_usb20_reqt_recipient_other|equ32_usb20_reqt_type_class|equ32_usb20_reqt_host_to_device @ bmRequest Type
			orr temp, temp, #equ32_usb20_req_clear_feature<<8              @ bRequest
			orr temp, temp, #equ32_usb20_val_hubport_connection_change<<16 @ wValue
			str temp, [buffer_rq]
			mov temp, i                                                    @ wIndex
			orr temp, temp, #0<<16                                         @ wLength
			str temp, [buffer_rq, #4]

			mov character, #64                              @ Maximam Packet Size
			orr character, character, #0<<11                @ Endpoint Number
			orr character, character, #0<<15                @ In(1)/Out(0)
			orr character, character, #0<<16                @ Endpoint Type
			orr character, character, addr_device, lsl #18  @ Device Address

			mov transfer_size, #0                           @ Transfer Size is 4 Bytes

			push {r0-r3}
			push {split_ctl,buffer_rx}
			bl usb2032_control
			add sp, sp, #8
			mov response, r0
			mov temp, r1
			pop {r0-r3}

			cmp response, #0
			bne usb2032_hub_search_device_error2                         @ Failure of Communication

			/* Set Reset Change */

			mov temp, #equ32_usb20_reqt_recipient_other|equ32_usb20_reqt_type_class|equ32_usb20_reqt_host_to_device @ bmRequest Type
			orr temp, temp, #equ32_usb20_req_set_feature<<8              @ bRequest
			orr temp, temp, #equ32_usb20_val_hubport_reset<<16           @ wValue
			str temp, [buffer_rq]
			mov temp, i                                                  @ wIndex
			orr temp, temp, #0<<16                                       @ wLength
			str temp, [buffer_rq, #4]

			push {r0-r3}
			push {split_ctl,buffer_rx}
			bl usb2032_control
			add sp, sp, #8
			mov response, r0
			mov temp, r1
			pop {r0-r3}

			cmp response, #0
			bne usb2032_hub_search_device_error2                         @ Failure of Communication

			/* Get Port Status */

			mov temp, #equ32_usb20_reqt_recipient_other|equ32_usb20_reqt_type_class|equ32_usb20_reqt_device_to_host @ bmRequest Type
			orr temp, temp, #equ32_usb20_req_get_status<<8               @ bRequest
			orr temp, temp, #equ32_usb20_val_get_status<<16              @ wValue
			str temp, [buffer_rq]
			mov temp, i                                                  @ wIndex
			orr temp, temp, #equ32_usb20_len_get_status_port<<16         @ wLength
			str temp, [buffer_rq, #4]

			mov character, #64                             @ Maximam Packet Size
			orr character, character, #0<<11               @ Endpoint Number
			orr character, character, #1<<15               @ In(1)/Out(0)
			orr character, character, #0<<16               @ Endpoint Type
			orr character, character, addr_device, lsl #18 @ Device Address

			mov transfer_size, #4                          @ Transfer Size is 4 Bytes
			orr transfer_size, transfer_size, #0x00080000  @ Transfer Packet is 1 Packet
			orr transfer_size, transfer_size, #0x40000000  @ Data Type is DATA1, Otherwise, meet Data Toggle Error

			mov timeout, #equ32_usb2032_timeout

			usb2032_hub_search_device_main_loop_resetwait:
				cmp timeout, #0
				ble usb2032_hub_search_device_error2

				push {r0-r3}
				push {split_ctl,buffer_rx}
				bl usb2032_control
				add sp, sp, #8
				mov response, r0
				mov temp, r1
				pop {r0-r3}

				cmp response, #0
				bne usb2032_hub_search_device_error2                         @ Failure of Communication

				ldr response, [buffer_rx]                                    @ Get Status
				tst response, #equ32_usb20_status_hubport_enable
				sub timeout, timeout, #1
				beq usb2032_hub_search_device_main_loop_resetwait  

			/* Clear Reset Change */

			mov temp, #equ32_usb20_reqt_recipient_other|equ32_usb20_reqt_type_class|equ32_usb20_reqt_host_to_device @ bmRequest Type
			orr temp, temp, #equ32_usb20_req_clear_feature<<8            @ bRequest
			orr temp, temp, #equ32_usb20_val_hubport_reset_change<<16    @ wValue
			str temp, [buffer_rq]
			mov temp, i                                                  @ wIndex
			orr temp, temp, #0<<16                                       @ wLength
			str temp, [buffer_rq, #4]

			mov character, #64                             @ Maximam Packet Size
			orr character, character, #0<<11               @ Endpoint Number
			orr character, character, #0<<15               @ In(1)/Out(0)
			orr character, character, #0<<16               @ Endpoint Type
			orr character, character, addr_device, lsl #18 @ Device Address

			mov transfer_size, #0                          @ Transfer Size is 4 Bytes

			push {r0-r3}
			push {split_ctl,buffer_rx}
			bl usb2032_control
			add sp, sp, #8
			mov response, r0
			mov temp, r1
			pop {r0-r3}

			cmp response, #0
			bne usb2032_hub_search_device_error2                         @ Failure of Communication

			/* Get Status Again and Ensure Resetting Process is Completed */

			mov temp, #equ32_usb20_reqt_recipient_other|equ32_usb20_reqt_type_class|equ32_usb20_reqt_device_to_host @ bmRequest Type
			orr temp, temp, #equ32_usb20_req_get_status<<8               @ bRequest
			orr temp, temp, #equ32_usb20_val_get_status<<16              @ wValue
			str temp, [buffer_rq]
			mov temp, i                                                  @ wIndex
			orr temp, temp, #equ32_usb20_len_get_status_port<<16         @ wLength
			str temp, [buffer_rq, #4]

			mov character, #64                             @ Maximam Packet Size
			orr character, character, #0<<11               @ Endpoint Number
			orr character, character, #1<<15               @ In(1)/Out(0)
			orr character, character, #0<<16               @ Endpoint Type
			orr character, character, addr_device, lsl #18 @ Device Address

			mov transfer_size, #4                          @ Transfer Size is 4 Bytes
			orr transfer_size, transfer_size, #0x00080000  @ Transfer Packet is 1 Packet
			orr transfer_size, transfer_size, #0x40000000  @ Data Type is DATA1, Otherwise, meet Data Toggle Error

			mov timeout, #equ32_usb2032_timeout

			usb2032_hub_search_device_main_loop_completewait:
				cmp timeout, #0
				ble usb2032_hub_search_device_error2

				push {r0-r3}
				push {split_ctl,buffer_rx}
				bl usb2032_control
				add sp, sp, #8
				mov response, r0
				mov temp, r1
				pop {r0-r3}

				cmp response, #0
				bne usb2032_hub_search_device_error2                         @ Failure of Communication

				ldr response, [buffer_rx]                                    @ Get Status
				tst response, #equ32_usb20_status_hubport_connection_change
				sub timeout, timeout, #1
				bne usb2032_hub_search_device_main_loop_completewait 
/*
macro32_debug timeout, 0, 500
macro32_debug response, 0, 512
macro32_debug temp, 0, 524
macro32_debug_hexa buffer_rx, 0, 536, 64
*/

			/* Set Address  */

			ldr timeout, USB2032_ADDRESS_LENGTH
			add timeout, timeout, #1
			str timeout, USB2032_ADDRESS_LENGTH

			mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_host_to_device @ bmRequest Type
			orr temp, temp, #equ32_usb20_req_set_address<<8              @ bRequest
			orr temp, temp, timeout, lsl #16                             @ wValue, address
			str temp, [buffer_rq]
			mov temp, #0                                                 @ wIndex
			orr temp, temp, #0<<16                                       @ wLength
			str temp, [buffer_rq, #4]

			tst response, #equ32_usb20_status_hubport_lowspeed
			moveq character, #64                          @ Maximam Packet Size
			movne character, #8                           @ Maximam Packet Size
			orr character, character, #0<<11              @ Endpoint Number
			orr character, character, #0<<15              @ In(1)/Out(0)
			orr character, character, #0<<16              @ Endpoint Type
			orr character, character, #0<<18              @ Device Address
			orrne character, character, #1<<25            @ Full and High Speed(0)/Low Speed(1)

			mov transfer_size, #0                         @ Transfer Size is 0 Bytes

			tst response, #equ32_usb20_status_hubport_highspeed
			moveq split_ctl, i                              @ Hub Port Number
			orreq split_ctl, split_ctl, addr_device, lsl #7 @ Hub Address #1
			orreq split_ctl, split_ctl, #0x80000000         @ Split Enable
			movne split_ctl, #0

			push {r0-r3}
			push {split_ctl,buffer_rx}
			bl usb2032_control
			add sp, sp, #8
			mov response, r0
			mov temp, r1
			pop {r0-r3}

			cmp response, #0
			bne usb2032_hub_search_device_error2      @ Failure of Communication

			mov r0, i, lsl #7                         @ Hub Port Number
			orr r0, r0, addr_device, lsl #14          @ Hub Address

			cmp response, #0
			ldreq addr_device, USB2032_ADDRESS_LENGTH
			orreq r0, r0, addr_device                 @ Device Address

			cmp split_ctl, #0
			orrne r0, r0, #0x40000000
			tst character, #1<<25
			orrne r0, r0, #0x20000000

			b usb2032_hub_search_device_common

			usb2032_hub_search_device_main_loop_common:
				add i, i, #1
				cmp i, num_ports
				ble usb2032_hub_search_device_main_loop

				mov r0, #0                @ Return with 0

				b usb2032_hub_search_device_common

	usb2032_hub_search_device_error1:
		mvn r0, #0                        @ Return with -1
		b usb2032_hub_search_device_common

	usb2032_hub_search_device_error2:
		mvn r0, #1                        @ Return with -2
		b usb2032_hub_search_device_common

	usb2032_hub_search_device_error3:
		mvn r0, #2                        @ Return with -3
		b usb2032_hub_search_device_common

	usb2032_hub_search_device_common:
		push {r0-r3}
		mov r0, buffer_rq
		cmp r0, #0                        @ If Not Allocated
		blne usb2032_clear_buffer
		pop {r0-r3}
		push {r0-r3}
		mov r0, buffer_rx
		cmp r0, #0                        @ If Not Allocated
		blne usb2032_clear_buffer
		pop {r0-r3}

		macro32_dsb ip                    @ Ensure Completion of Instructions Before
		pop {r4-r11,pc}

.unreq channel
.unreq character
.unreq transfer_size
.unreq buffer_rq
.unreq split_ctl
.unreq buffer_rx
.unreq response
.unreq temp
.unreq num_ports
.unreq i
.unreq addr_device
.unreq timeout


/**
 * function usb2032_control
 * Control Communication with USB Device or Others
 *
 * Parameters
 * r0: Channel 0-15
 * 
 * r1: Characteristics (Virtual Register), Reserved Bits expects SBZ (Zeros)
 *   r1 Bit[10:0]: Maximum Packet Size (in Low Speed, Fixed to 8 bytes)
 *   r1 Bit[14:11]: Endpoint Number
 *   r1 Bit[15]: Endpoint Direction, 0 Out, 1, In
 *   r1 Bit[17:16]: Endpoint Type, 0 Control, 1 Isochronous, 2 Bulk, 3 Interrupt
 *   r1 Bit[24:18]: Device Address
 *   r1 Bit[25]: Full and High Speed(0)/Low Speed(1)
 *   r1 Bit[26]: Even(0)/Odd(1) Frame in Periodic Transactions
 *
 * r2: Transfer Size (Virtual Register), Reserved Bits expects SBZ (Zeros)
 *   r2 Bit[18:0]: Transfer Size
 *   r2 Bit[28:19]: Packet Count (Transfer Size divided by Max Packet Size, Round Up)
 *   r2 Bit[30:29]: PID, 00b DATA0, 01b DATA2, 10b DATA1, 11b MDATA (No Control)/SETUP (Control)
 *   r2 Bit[31]: Do PING to Device
 *
 * r3: Request Buffer
 *
 * r4: Channel N Split Control (Virtual Register), Reserved Bits expects SBZ (Zeros)
 *   r4 Bit[6:0]: Port Address
 *   r4 Bit[13:7]: Hub Address
 *   r4 Bit[15:14]: Position of Transaction, 0 Middle, 1 End, 2 Begin, 3 All (Only in Isochoronous OUT)
 *   r4 Bit[16]: Complete Split
 *   r4 Bit[31]: Disable(0)/Enable(1) Split Control
 *
 * r5: Receive Buffer
 *
 * Return: r0 (0 as success, 1 and 2 as error), r1 (last status of channel)
 * Error(1): Failure of Communication (Time Out)
 * Error(2): Failure of Communication (STALL Shake Hand)
 */
.globl usb2032_control
usb2032_control:
	/* Auto (Local) Variables, but just Aliases */
	channel            .req r0
	character          .req r1
	transfer_size      .req r2
	buffer_rq          .req r3
	split_ctl          .req r4
	buffer_rx          .req r5
	response           .req r6
	timeout            .req r7

	push {r4-r7,lr}

	add sp, sp, #20                                                        @ r4-r8 and lr offset 24 bytes
	pop {split_ctl,buffer_rx}                                              @ Get Fifth and Sixth Argument
	sub sp, sp, #28

	/* Setup Stage */
	usb2032_control_setup:

		mov timeout, #equ32_usb2032_timeout

		usb2032_control_setup_loop:
			cmp timeout, #0
			ble usb2032_control_error1

			push {r0-r3}
			bic character, character, #1<<15              @ Out(0)
			mov transfer_size, #8                         @ Transfer Size is 8 Bytes
			orr transfer_size, transfer_size, #0x00080000 @ Transfer Packet is 1 Packet
			orr transfer_size, transfer_size, #0x60000000 @ Data Type is Setup
			push {split_ctl}
			bl usb2032_transaction
			add sp, sp, #4
			mov response, r0
			mov ip, r1
			pop {r0-r3}

			sub timeout, timeout, #1

			tst response, #0x10                           @ STALL
			bne usb2032_control_error2

			tst response, #0x4                            @ ACK
			beq usb2032_control_setup_loop

/*
macro32_debug response 500 288
macro32_debug ip 500 300
*/

	/* Data Stage */
	usb2032_control_data:

		cmp transfer_size, #0
		beq usb2032_control_status                  @ If No Need of Data Stage

		mov timeout, #equ32_usb2032_timeout

		usb2032_control_data_loop:
			cmp timeout, #0
			ble usb2032_control_error1

			push {r0-r3}
			mov r3, buffer_rx
			push {split_ctl}
			bl usb2032_transaction
			add sp, sp, #4
			mov response, r0
			mov ip, r1
			pop {r0-r3}

			sub timeout, timeout, #1

			tst response, #0x10                           @ STALL
			bne usb2032_control_error2

			tst response, #0x4                            @ ACK
			beq usb2032_control_data_loop

/*
macro32_debug response 500 312
macro32_debug ip 500 324
*/

	/* Status Stage */
	usb2032_control_status:

		mov timeout, #equ32_usb2032_timeout

		usb2032_control_status_loop:
			cmp timeout, #0
			ble usb2032_control_error1

			push {r0-r3}
			eor character, character, #1<<15              @ Reverse In/Out
			mov transfer_size, #0                         @ Transfer Size is 0 Bytes
			orr transfer_size, transfer_size, #0x00080000 @ Transfer Packet is 1 Packet
			orr transfer_size, transfer_size, #0x40000000 @ Data Type is DATA1 (Status Stage is Always DATA1)
			push {split_ctl}
			bl usb2032_transaction
			add sp, sp, #4
			mov response, r0
			pop {r0-r3}

			sub timeout, timeout, #1

			tst response, #0x10                           @ STALL
			bne usb2032_control_error2

			tst response, #0x4                            @ ACK
			beq usb2032_control_status_loop

			b usb2032_control_success

	usb2032_control_error1:
		mov r0, #1
		b usb2032_control_common

	usb2032_control_error2:
		mov r0, #2
		b usb2032_control_common

	usb2032_control_success:
		mov r0, #0

	usb2032_control_common:
		mov r1, response
		macro32_dsb ip                    @ Ensure Completion of Instructions Before
		pop {r4-r7,pc}

.unreq channel
.unreq character
.unreq transfer_size
.unreq buffer_rq
.unreq split_ctl
.unreq buffer_rx
.unreq response
.unreq timeout


/**
 * Variables to be used in transactions.
 */
USB2032_SETTER:                 .word 0x00
USB2032_SENDER:                 .word 0x00
USB2032_RECEIVER:               .word 0x00
usb2032_otg_host_setter_addr:   .word usb2032_otg_host_setter
usb2032_otg_host_sender_addr:   .word usb2032_otg_host_sender
usb2032_otg_host_receiver_addr: .word usb2032_otg_host_receiver

/**
 * Variable to be used to know status of the root hub.
 */
USB2032_ROOTHUB:                .word 0x00
usb2032_otg_host_roothub_addr:  .word usb2032_otg_host_roothub

/**
 * Activated (1) / Deactivated (0) Bit[0]
 */
USB2032_STATUS:                 .word 0x00
USB2032_ADDRESS_LENGTH:         .word 0x00


/**
 * function usb2032_transaction
 * Sequence of USB2.0 OTG Host Transaction
 * Use in Interrupt/bulk/Isochoronous Communication with USB Devices.
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
 *   r2 Bit[31]: Do PING to Device
 *
 * r3: Channel N DMA Address (Buffer)
 *
 * r4: Channel N Split Control (Virtual Register), Reserved Bits expects SBZ (Zeros)
 *   r4 Bit[6:0]: Port Address
 *   r4 Bit[13:7]: Hub Address
 *   r4 Bit[15:14]: Position of Transaction, 0 Middle, 1 End, 2 Begin, 3 All
 *   r4 Bit[16]: Complete Split
 *   r4 Bit[31]: Disable(0)/Enable(1) Split Control
 *
 * Return: r0 (Status of Channel, -1 and -2 as error), r1 (Current Status of Transfer Register)
 * Bit[0]: Completed
 * Bit[1]: Halted
 * Bit[2]: ACK
 * Bit[3]: NAK
 * Bit[4]: STALL
 * Bit[5]: NYET
 * Bit[6]: Internal Bus Error
 * Bit[7]: Transaction and Other Errors
 * Bit[8] and More May Exist on SoC
 * Bit[29]: USB HCD is Not Activated, r1 will be 0
 * Bit[30]: Channel is Already Enabled, r1 will be 0
 * Bit[31]: Time Out, r1 will be 0
 */
.globl usb2032_transaction
usb2032_transaction:
	/* Auto (Local) Variables, but just Aliases */
	channel            .req r0
	character          .req r1
	transfer_size      .req r2
	buffer             .req r3
	split_ctl          .req r4
	temp               .req r5
	packet_max         .req r6
	packet             .req r7
	timeout_nyet       .req r8
	transfer_size_rsv  .req r9

	push {r4-r9,lr}

	add sp, sp, #28                                                        @ r4-r9 and lr offset 28 bytes
	pop {split_ctl}                                                        @ Get Fifth Argument
	sub sp, sp, #32 	

	ldr temp, USB2032_STATUS
	tst temp, #0x1
	beq usb2032_transaction_error1

	.unreq temp
	buffer_dup .req r5

	mov buffer_dup, buffer

	mov timeout_nyet, #equ32_usb2032_timeout_nyet

	macro32_dsb ip

	push {r0-r3}
	mov r0, buffer
	bl heap32_clear_align
	mov r1, #1                                @ Clean
	bl arm32_cache_operation_heap             @ To PoC
	pop {r0-r3}

	mov transfer_size_rsv, #0

	tst split_ctl, #0x80000000
	beq usb2032_transaction_main

	/**
	 * In Split Transaction, we needed to treat each packet manually.
	 * Caution that if you exceed the transfer size which is intended by device,
	 * Device Returns STALL.
	 */

	bic split_ctl, split_ctl, #0x00010000                    @ Clear Complete Bit[16] Just in Case
	mov transfer_size_rsv, transfer_size

	bic packet, transfer_size_rsv, #0xE0000000               @ Clear PING Bit[31] and PID bit[30:29]
	lsr packet, packet, #19                                  @ Get Only Value of Packet Count
	cmp packet, #1
	movle transfer_size_rsv, #0                              @ If Transfer is Only One Packet
	ble usb2032_transaction_main

	usb2032_transaction_split:

		lsl packet_max, character, #21
		lsr packet_max, packet_max, #21                      @ Get Only Value of Max. Packet

		bic packet, transfer_size_rsv, #0xE0000000           @ Clear PING Bit[31] and PID bit[30:29]
		lsr packet, packet, #19                              @ Get Only Value of Packet Count

		tst split_ctl, #0x00010000                           @ If Already in Multi-packets Sequence of Split
		bicne split_ctl, split_ctl, #0x00010000              @ Clear Bit[16]
		addne buffer, buffer, packet_max                     @ Slide Buffer Position

		cmp packet, #1                                       @ If Last Packet
		movle transfer_size, transfer_size_rsv
		movle transfer_size_rsv, #0                          @ Clear
		ble usb2032_transaction_main                         @ If Last Packet in Multi-packets Sequence of Split

		/* Make Transfer One Packet and Size of Max. Packet Size */
		mov transfer_size, transfer_size_rsv
		and transfer_size, transfer_size, #0xE0000000        @ Mask PING Bit[31] and PID bit[30:29]
		orr transfer_size, transfer_size, packet_max
		orr transfer_size, transfer_size, #1<<19

		sub transfer_size_rsv, transfer_size_rsv, #1<<19     @ Subtract One Packet
		sub transfer_size_rsv, transfer_size_rsv, packet_max @ Subtract Size of Packet to Transfer Size

		eor transfer_size_rsv, transfer_size_rsv, #1<<30     @ Alternate PID DATA0 and DATA1
		
		.unreq packet_max
		.unreq packet
		response           .req r6
		transfer_size_last .req r7

	usb2032_transaction_main:
		macro32_dsb ip

		cmp timeout_nyet, #0
		ble usb2032_transaction_success

		push {r0-r3}
		push {split_ctl}
		ldr ip, USB2032_SETTER
		blx ip
		add sp, sp, #4
		cmp r0, #1
		pop {r0-r3}
		beq usb2032_transaction_error2

		push {r0-r3}
		ldr ip, USB2032_SENDER
		blx ip
		cmp r0, #1
		pop {r0-r3}
		beq usb2032_transaction_error2

		push {r0-r3}
		ldr ip, USB2032_RECEIVER
		blx ip
		mov response, r0
		mov transfer_size_last, r1
		pop {r0-r3}

		tst response, #0x80000000             @ Time Out Bit[31]
		bne usb2032_transaction_error3

		tst split_ctl, #0x80000000            @ Test Split Enable Bit[31]
		beq usb2032_transaction_main_common

		tst split_ctl, #0x00010000            @ Test Complete Bit[16] If Split Enable
		bne usb2032_transaction_main_common

		orr split_ctl, split_ctl, #0x00010000 @ Complete Bit[16] High If No Complete
		b usb2032_transaction_main            @ Complete Transaction

		usb2032_transaction_main_common:
			tst response, #0x20                  @ NYET Bit[5]
			subne timeout_nyet, timeout_nyet, #1 
			bne usb2032_transaction_main

			cmp transfer_size_rsv, #0
			bne usb2032_transaction_split

			mov buffer, buffer_dup

			push {r0-r3}
			mov r0, buffer
			bl heap32_clear_align
			mov r1, #0                                @ Invalidate
			bl arm32_cache_operation_heap             @ From PoC
			pop {r0-r3}

			b usb2032_transaction_success

	usb2032_transaction_error1:
		mov r0, #0x20000000               @ USB HCD is Not Activated
		mov r1, #0
		b usb2032_transaction_common

	usb2032_transaction_error2:
		mov r0, #0x40000000               @ Channel is Already Enabled
		mov r1, #0
		b usb2032_transaction_common

	usb2032_transaction_error3:               @ Time Out
		mov r0, #0x80000000
		mov r1, #0
		b usb2032_transaction_common

	usb2032_transaction_success:
		mov r0, response
		mov r1, transfer_size_last

	usb2032_transaction_common:
		macro32_dsb ip                    @ Ensure Completion of Instructions Before
		pop {r4-r9,pc}

.unreq channel
.unreq character
.unreq transfer_size
.unreq buffer
.unreq split_ctl
.unreq buffer_dup
.unreq response
.unreq transfer_size_last
.unreq timeout_nyet
.unreq transfer_size_rsv


/**
 * function usb2032_otg_host_receiver
 * Wait Receive Responce from Device and Disable Interrupt
 *
 * Parameters
 * r0: Channel 0-15
 *
 * Return: r0 (Status of Channel), r1 (Current Status of Transfer Register)
 * Bit[0]: Completed
 * Bit[1]: Halted
 * Bit[2]: ACK
 * Bit[3]: NAK
 * Bit[4]: STALL
 * Bit[5]: NYET
 * Bit[6]: Internal Bus Error
 * Bit[7]: Transaction and Other Errors
 * Bit[8] and More May Exist on SoC
 * Bit[31]: Time Out
 */
.globl usb2032_otg_host_receiver
usb2032_otg_host_receiver:
	/* Auto (Local) Variables, but just Aliases */
	channel        .req r0
	memorymap_base .req r1
	temp           .req r2
	timeout        .req r3

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_hostchannel_base
	mov temp, #equ32_usb20_otg_hostchannel_offset
	mul temp, channel, temp
	add memorymap_base, memorymap_base, temp                             @ Add Each Channel Offset

	mov timeout, #equ32_usb2032_timeout

	/**
	 * On the loop below, we consider of the limitter (Time Out).
	 */
	usb2032_otg_host_receiver_loop:
		cmp timeout, #0
		ble usb2032_otg_host_receiver_error
		ldr temp, [memorymap_base, #equ32_usb20_otg_hcintn]
		tst temp, #0x00000002                                        @ Check Halted (HCD Disabled Channel N)
		sub timeout, timeout, #1
		beq usb2032_otg_host_receiver_loop


		/**
		 * These Interrupts are on BCM2835
		 * Bit[11] and over may exist in case of some SoC
		 *
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

		b usb2032_otg_host_receiver_common

	usb2032_otg_host_receiver_error:
		mov r0, #0x80000000                                               @ Time Out Bit[31]

	usb2032_otg_host_receiver_common:
		str temp, [memorymap_base, #equ32_usb20_otg_hcintn]               @ write-clear
		mov temp, #0
		str temp, [memorymap_base, #equ32_usb20_otg_hcintmskn]            @ Mask All
		ldr r1, [memorymap_base, #equ32_usb20_otg_hctsizn]
		macro32_dsb ip                                                    @ Ensure Completion of Instructions Before
		mov pc, lr
	
.unreq channel
.unreq memorymap_base
.unreq temp
.unreq timeout


/**
 * function usb2032_otg_host_sender
 * Send Message to Device and Enable Interrupt
 *
 * Parameters
 * r0: Channel 0-15
 *
 * Return: r0 (0 as success, 1 as Error)
 * Error(1): Channel is Already Enabled
 */
.globl usb2032_otg_host_sender
usb2032_otg_host_sender:
	/* Auto (Local) Variables, but just Aliases */
	channel        .req r0
	memorymap_base .req r1
	temp           .req r2

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_hostchannel_base
	mov temp, #equ32_usb20_otg_hostchannel_offset
	mul temp, channel, temp
	add memorymap_base, memorymap_base, temp                              @ Add Each Channel Offset

	ldr temp, [memorymap_base, #equ32_usb20_otg_hccharn]
	tst temp, #0x80000000                                                 @ Channel Enable Bit[31]
	orrne temp, #0x40000000
	strne temp, [memorymap_base, #equ32_usb20_otg_hccharn]
	bne usb2032_otg_host_setter_error                                      @ Channel is Already Enabled

	ldr temp, [memorymap_base, #equ32_usb20_otg_hcintn]
	str temp, [memorymap_base, #equ32_usb20_otg_hcintn]                   @ write-clear

	mvn temp, #0
	str temp, [memorymap_base, #equ32_usb20_otg_hcintmskn]                @ Unmask All

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
 *   r2 Bit[31]: Do PING to Device
 *
 * r3: Channel N DMA Address (Buffer)
 *
 * r4: Channel N Split Control (Virtual Register), Reserved Bits expects SBZ (Zeros)
 *   r4 Bit[6:0]: Port Address
 *   r4 Bit[13:7]: Hub Address
 *   r4 Bit[15:14]: Position of Transaction, 0 Middle, 1 End, 2 Begin, 3 All
 *   r4 Bit[16]: Complete Split
 *   r4 Bit[31]: Disable(0)/Enable(1) Split Control
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Channel is Already Enabled
 */
.globl usb2032_otg_host_setter
usb2032_otg_host_setter:
	/* Auto (Local) Variables, but just Aliases */
	channel        .req r0
	character      .req r1
	transfer_size  .req r2
	buffer         .req r3
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
	orrne temp, #0x40000000
	strne temp, [memorymap_base, #equ32_usb20_otg_hccharn]
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

	str transfer_size, [memorymap_base, #equ32_usb20_otg_hctsizn]

	/* Transform to Bus Address (GPU, DMA, and Peripherals Recognize This Address Space as Point of Coherency with ARM) */
	add buffer, buffer, #equ32_bus_coherence_base
	str buffer, [memorymap_base, #equ32_usb20_otg_hcdman]

	bic split_ctl, split_ctl, #0x7F000000
	bic split_ctl, split_ctl, #0x00FE0000                                  @ Only Validate Bit[31] and Bit[16:0]
	str split_ctl, [memorymap_base, #equ32_usb20_otg_hcspltn]

	b usb2032_otg_host_setter_success

	usb2032_otg_host_setter_error:
		mov r0, #1                                                         @ Return with Error
		b usb2032_otg_host_setter_common

	usb2032_otg_host_setter_success:
		mov r0, #0                                                         @ Return with Success

	usb2032_otg_host_setter_common:
		macro32_dsb ip                                                     @ Ensure Completion of Instructions Before
		pop {r4-r7}
		mov pc, lr

.unreq channel
.unreq character
.unreq transfer_size
.unreq buffer
.unreq split_ctl
.unreq hcchar
.unreq temp
.unreq memorymap_base


/**
 * function usb2032_otg_host_roothub
 * Get Root Hub Staus 
 * Caution! Returned Status is Limited. Device Speed, Power On, Reset, Suspend, Overcurrent, Port Enable, and Port Connection.
 *
 * Return: r0 (Status Similar to Value From GET_STATUS)
 */
.globl usb2032_otg_host_roothub
usb2032_otg_host_roothub:
	/* Auto (Local) Variables, but just Aliases */
	memorymap_base .req r0
	hprt           .req r1
	status         .req r2

	mov status, #0

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_host_base
	ldr hprt, [memorymap_base, #equ32_usb20_otg_hprt]

	macro32_dsb ip                                                     @ Ensure Completion of Instructions Before

	/* Bit[18:17]: Port Speed, 00b High Spped, 10b Low Speed, 01b Full Speed */
	tst hprt, #0x60000
	orreq status, status, #equ32_usb20_status_hubport_highspeed
	tst hprt, #0x40000
	orrne status, status, #equ32_usb20_status_hubport_lowspeed

	/* Bit[12]: Power On */
	tst hprt, #0x1000
	orrne status, status, #equ32_usb20_status_hubport_power

	/* Bit[8]: Reset */
	tst hprt, #0x100
	orrne status, status, #equ32_usb20_status_hubport_reset

	/* Bit[7]: Suspend */
	tst hprt, #0x80
	orrne status, status, #equ32_usb20_status_hubport_suspend

	/* Bit[4]: Overcurrent */
	tst hprt, #0x10
	orrne status, status, #equ32_usb20_status_hubport_overcurrent

	/* Bit[2]: Port Enable */
	tst hprt, #0x4
	orrne status, status, #equ32_usb20_status_hubport_enable

	/* Bit[0]: Port Connection */
	tst hprt, #0x1
	orrne status, status, #equ32_usb20_status_hubport_connection

	usb2032_otg_host_roothub_success:
		mov r0, status                                                     @ Return with Success

	usb2032_otg_host_roothub_common:
		mov pc, lr

.unreq memorymap_base
.unreq hprt
.unreq status


/**
 * function usb2032_otg_host_reset_bcm
 * Reset and Enable USB2.0 OTG of BCM2835-2837
 * In addition to this function, you may need to power on the USB implementation in SoC.
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): AHB (Advanced High-performance Bus) is not in Idle State.
 * Error(2): Time Out
 */
.globl usb2032_otg_host_reset_bcm
usb2032_otg_host_reset_bcm:
	/* Auto (Local) Variables, but just Aliases */
	memorymap_base    .req r0
	temp              .req r1
	timeout           .req r2

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_base

	/**
	 * Reset
	 */
	ldr temp, [memorymap_base, #equ32_usb20_otg_grstctl]      @ Global Reset Control

	tst temp, #0x80000000                                     @ ANDS AHB Idle Bit[31]
	beq usb2032_otg_host_reset_bcm_error1                     @ If Bus is Not in Idle

	orr temp, temp, #0x01                                     @ Core Soft Reset Bit[0]
	str temp, [memorymap_base, #equ32_usb20_otg_grstctl]

	macro32_dsb ip

	mov timeout, #equ32_usb2032_timeout

	usb2032_otg_host_reset_bcm_resetcore:
		cmp timeout, #0
		ble usb2032_otg_host_reset_bcm_error2
		ldr temp, [memorymap_base, #equ32_usb20_otg_grstctl]
		tst temp, #0x01
		sub timeout, timeout, #1
		bne usb2032_otg_host_reset_bcm_resetcore

	orr temp, temp, #0x02                                     @ HClk Soft Reset Bit[1]
	str temp, [memorymap_base, #equ32_usb20_otg_grstctl]

	macro32_dsb ip

	mov timeout, #equ32_usb2032_timeout

	usb2032_otg_host_reset_bcm_resetinternalbus:
		cmp timeout, #0
		ble usb2032_otg_host_reset_bcm_error2
		ldr temp, [memorymap_base, #equ32_usb20_otg_grstctl]
		tst temp, #0x02
		sub timeout, timeout, #1
		bne usb2032_otg_host_reset_bcm_resetinternalbus

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
	mov temp, #0x30                                           @ Enable DMA Bit[5], BurstType Bit[4:1] (Adopted by BCM)
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
	beq usb2032_otg_host_reset_bcm_error1                     @ If Bus is Not in Idle

	orr temp, temp, #0x20                                     @ TxFIFO Flush Bit[5]
	str temp, [memorymap_base, #equ32_usb20_otg_grstctl]

	macro32_dsb ip

	mov timeout, #equ32_usb2032_timeout

	usb2032_otg_host_reset_bcm_flushtxfifo:
		cmp timeout, #0
		ble usb2032_otg_host_reset_bcm_error2
		ldr temp, [memorymap_base, #equ32_usb20_otg_grstctl]
		tst temp, #0x20
		sub timeout, timeout, #1
		bne usb2032_otg_host_reset_bcm_flushtxfifo

	tst temp, #0x80000000                                     @ ANDS AHB Idle Bit[31]
	beq usb2032_otg_host_reset_bcm_error1                     @ If Bus is Not in Idle

	orr temp, temp, #0x10                                     @ RxFIFO Flush Bit[4]
	str temp, [memorymap_base, #equ32_usb20_otg_grstctl]

	macro32_dsb ip

	mov timeout, #equ32_usb2032_timeout

	usb2032_otg_host_reset_bcm_flushrxfifo:
		cmp timeout, #0
		ble usb2032_otg_host_reset_bcm_error2
		ldr temp, [memorymap_base, #equ32_usb20_otg_grstctl]
		tst temp, #0x10
		sub timeout, timeout, #1
		bne usb2032_otg_host_reset_bcm_flushrxfifo

	/**
	 * Host Mode CSRs (Base + 0x400)
	 */

	add memorymap_base, memorymap_base, #equ32_usb20_otg_host_base

	mov temp, #0x0                                            @ Clear FS-LS Only Bit[2], PHY Clock to 30Mhz or 60Mhz Bit[1:0]
	str temp, [memorymap_base, #equ32_usb20_otg_hcfg]         @ Host Configuration

	ldr temp, [memorymap_base, #equ32_usb20_otg_hprt]         @ Host Port Control and Status

	tst temp, #0x00001000                                     @ Port Power Bit[12]
	bne usb2032_otg_host_reset_bcm_jump                       @ If Power On

	orr temp, #0x00001000
	str temp, [memorymap_base, #equ32_usb20_otg_hprt]

	macro32_dsb ip

	usb2032_otg_host_reset_bcm_jump:

		/* Power to Good Delay */
		push {r0-r3,lr}
		mov r0, #0x19000                                           @ 102.400 ms
		bl arm32_sleep
		pop {r0-r3,lr}

		orr temp, #0x00000100                                      @ Port Reset Bit[8]
		str temp, [memorymap_base, #equ32_usb20_otg_hprt]

		macro32_dsb ip

		/* Interval for Set/Clear Reset */
		push {r0-r3,lr}
		mov r0, #0xEB00                                            @ 60160 us, 60.160 ms
		bl arm32_sleep
		pop {r0-r3,lr}

		bic temp, #0x00000100                                      @ Clear Port Reset Bit[8]
		str temp, [memorymap_base, #equ32_usb20_otg_hprt]

		macro32_dsb ip

		mov timeout, #equ32_usb2032_timeout

		usb2032_otg_host_reset_bcm_jump_loop:
			cmp timeout, #0
			ble usb2032_otg_host_reset_bcm_error2
			ldr temp, [memorymap_base, #equ32_usb20_otg_hprt]
			tst temp, #0x00000008                                  @ Port Enable/Disable Change Bit[3]
			sub timeout, timeout, #1
			beq usb2032_otg_host_reset_bcm_jump_loop

			/**
			 * If already connected with devices including Hub,
			 * Port Connect Detected Bit[1] and Port Connect Status Bit[0] become set.
			 * Port Connect Detected Bit[1] causes
			 * an interrupt on GINTSTS. If you want clear it, you need to write-clear to Bit[1].
			 * Also, Port Enable/Disable Change Bit[3], Port Overcurrent Change Bit[5] are needed to write-clear
			 */
			bic temp, #0x4                                         @ Clear Port Enable Bit[2] Because Write-clear
			str temp, [memorymap_base, #equ32_usb20_otg_hprt]

			/**
			 * Global OTG Control and Status
			 * Set Host Negotiation Protocol (Change Host Side to Device Side)
			 */
			mov memorymap_base, #equ32_peripherals_base
			add memorymap_base, memorymap_base, #equ32_usb20_otg_base
			ldr temp, [memorymap_base, #equ32_usb20_otg_gotgctl]   @ Global OTG Control and Status
			orr temp, temp, #0x00000400                            @ Host Set HNP Enable Bit[10]
			str temp,  [memorymap_base, #equ32_usb20_otg_gotgctl]

			ldr temp, usb2032_otg_host_setter_addr
			str temp, USB2032_SETTER

			ldr temp, usb2032_otg_host_sender_addr
			str temp, USB2032_SENDER

			ldr temp, usb2032_otg_host_receiver_addr
			str temp, USB2032_RECEIVER

			ldr temp, usb2032_otg_host_roothub_addr
			str temp, USB2032_ROOTHUB
	
			ldr temp, USB2032_STATUS
			orr temp, temp, #0x1
			str temp, USB2032_STATUS

			mov temp, #0
			str temp, USB2032_ADDRESS_LENGTH

		b usb2032_otg_host_reset_bcm_success

	usb2032_otg_host_reset_bcm_error1:
		mov r0, #1                           @ Return with Error
		b usb2032_otg_host_reset_bcm_common

	usb2032_otg_host_reset_bcm_error2:
		mov r0, #2                           @ Return with Error
		b usb2032_otg_host_reset_bcm_common

	usb2032_otg_host_reset_bcm_success:
		mov r0, #0                           @ Return with Success

	usb2032_otg_host_reset_bcm_common:
		macro32_dsb ip                       @ Ensure Completion of Instructions Before
		mov pc, lr

.unreq memorymap_base
.unreq temp
.unreq timeout
