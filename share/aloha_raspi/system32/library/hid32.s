/**
 * hid32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

HID32_USB2032_ADDRESS_LENGTH: .word USB2032_ADDRESS_LENGTH


/**
 * function hid32_hid_activate
 * Search and Activate Human Interface Device (HID) of USB2.0
 *
 * Parameters
 * r0: Channel 0-15
 * r1: Number of Configuration for HID on Device (Starting from 1)
 * r2: Number of Interface for HID on Device (Starting from 0)
 * r3: Ticket Issued by usb2032_hub_search_device, or 0 as Direct Connection
 *
 * Return: r0 (Device Address, -1 and -2 as Error)
 * Error(-1): Failed Memory Allocation
 * Error(-2): No HID
 * Error(-3): Failure of Communication (Stall on Critical Point/Time Out)
 */
.globl hid32_hid_activate
hid32_hid_activate:
	/* Auto (Local) Variables, but just Aliases */
	channel         .req r0
	character       .req r1
	transfer_size   .req r2
	ticket          .req r3
	split_ctl       .req r4
	buffer_rx       .req r5
	response        .req r6
	temp            .req r7
	num_config      .req r8
	num_interface   .req r9
	addr_device     .req r10
	packet_max      .req r11

	push {r4-r11,lr}

	mov num_config, character
	mov num_interface, transfer_size

	cmp ticket, #0
	movne addr_device, ticket
	andne addr_device, addr_device, #0x0000007F @ Device Address
	moveq addr_device, #0

	mov split_ctl, ticket
	bic split_ctl, split_ctl, #0xFF000000       @ Mask Only Bit[20:14]: Address of Hub and Bit[13:7]: Port Number and 
	bic split_ctl, split_ctl, #0x00E00000
	lsr split_ctl, split_ctl, #7
	tst ticket, #0x80000000
	orrne split_ctl, split_ctl, #0x80000000     @ Bit[31:30]: 00b High Speed,10b Full Speed, 11b Low Speed

	.unreq ticket
	buffer_rq .req r3

	push {r0-r3}
	mov r0, #24                        @ 4 Bytes by 16 Words Equals 64 Bytes (Plus 8 Words for Alignment)
	bl usb2032_get_buffer_in
	mov buffer_rx, r0
	pop {r0-r3}
	cmp buffer_rx, #0
	beq hid32_hid_activate_error1

	/* Get Device Descriptor */

	push {r0-r3}
	mov r0, #10                        @ 4 Bytes by 2 Words Equals 8 Bytes (Plus 8 Words for Alighment)
	bl usb2032_get_buffer_out
	mov temp, r0
	pop {r0-r3}
	cmp temp, #0
	beq hid32_hid_activate_error1
	mov buffer_rq, temp

	mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_device_to_host @ bmRequest Type
	orr temp, temp, #equ32_usb20_req_get_descriptor<<8           @ bRequest
	orr temp, temp, #0<<16                                       @ wValue, Descriptor Index
	orr temp, temp, #equ32_usb20_val_descriptor_device<<16       @ wValue, Descriptor Type
	str temp, [buffer_rq]
	mov temp, #0                                                 @ wIndex
	orr temp, temp, #8<<18                                       @ wLength
	str temp, [buffer_rq, #4]

	mov character, #8                              @ Maximam Packet Size
	orr character, character, #0<<11               @ Endpoint Number
	orr character, character, #1<<15               @ In(1)/Out(0)
	orr character, character, #0<<16               @ Endpoint Type
	orr character, character, addr_device, lsl #18 @ Device Address
	orr character, character, #1<<25               @ Full and High Speed(0)/Low Speed(1)

	mov transfer_size, #8                          @ Transfer Size is 8 Bytes
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
	bne hid32_hid_activate_error3

/*
macro32_debug response, 0, 62
macro32_debug temp, 0, 74
macro32_debug_hexa buffer_rx, 0, 86, 64
*/


	ldrb temp, [buffer_rx, #4]
	cmp temp, #0                                   @ Device Class is HID or Not
	bne hid32_hid_activate_error2

	ldrb packet_max, [buffer_rx, #7]

	cmp addr_device, #0
	bne hid32_hid_activate_jump

	/* Set Address  */

	push {r0-r3}
	mov r0, #10                        @ 4 Bytes by 2 Words Equals 8 Bytes (Plus 8 Words for Alighment)
	bl usb2032_get_buffer_out
	mov temp, r0
	pop {r0-r3}
	cmp temp, #0
	beq hid32_hid_activate_error1
	mov buffer_rq, temp

	ldr temp, HID32_USB2032_ADDRESS_LENGTH
	ldr addr_device, [temp]
	add addr_device, addr_device, #1
	str addr_device, [temp]

	mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_host_to_device @ bmRequest Type
	orr temp, temp, #equ32_usb20_req_set_address<<8              @ bRequest
	orr temp, temp, addr_device, lsl #16                         @ wValue, address
	str temp, [buffer_rq]
	mov temp, #0                                                 @ wIndex
	orr temp, temp, #0<<18                                       @ wLength
	str temp, [buffer_rq, #4]

	mov character, packet_max                     @ Maximam Packet Size
	orr character, character, #0<<11              @ Endpoint Number
	orr character, character, #0<<15              @ In(1)/Out(0)
	orr character, character, #0<<16              @ Endpoint Type
	orr character, character, #0<<18              @ Device Address
	orr character, character, #1<<25              @ Full and High Speed(0)/Low Speed(1)

	mov transfer_size, #0                         @ Transfer Size is 0 Bytes

	push {r0-r3}
	push {split_ctl,buffer_rx}
	bl usb2032_control
	add sp, sp, #8
	mov response, r0
	mov temp, r1
	pop {r0-r3}

	cmp response, #0
	bne hid32_hid_activate_error3

	hid32_hid_activate_jump:

		/* Set Configuration  */

		push {r0-r3}
		mov r0, #10                         @ 4 Bytes by 2 Words Equals 8 Bytes (Plus 8 Words for Alighment)
		bl usb2032_get_buffer_out
		mov temp, r0
		pop {r0-r3}
		cmp temp, #0
		beq hid32_hid_activate_error1
		mov buffer_rq, temp

		mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_host_to_device @ bmRequest Type
		orr temp, temp, #equ32_usb20_req_set_configuration<<8        @ bRequest
		orr temp, temp, num_config, lsl #16                          @ wValue, Descriptor Index
		str temp, [buffer_rq]
		mov temp, #0                                                 @ wIndex
		orr temp, temp, #0<<18                                       @ wLength
		str temp, [buffer_rq, #4]

		mov character, #8                              @ Maximam Packet Size
		orr character, character, #0<<11               @ Endpoint Number
		orr character, character, #0<<15               @ In(1)/Out(0)
		orr character, character, #0<<16               @ Endpoint Type
		orr character, character, addr_device, lsl #18 @ Device Address
		orr character, character, #1<<25               @ Full and High Speed(0)/Low Speed(1)

		mov transfer_size, #0                          @ Transfer Size is 0 Bytes

		push {r0-r3}
		push {split_ctl,buffer_rx}
		bl usb2032_control
		add sp, sp, #8
		mov response, r0
		mov temp, r1
		pop {r0-r3}

		/* Remote Wakeup  */

		push {r0-r3}
		mov r0, #10                         @ 4 Bytes by 2 Words Equals 8 Bytes (Plus 8 Words for Alighment)
		bl usb2032_get_buffer_out
		mov temp, r0
		pop {r0-r3}
		cmp temp, #0
		beq hid32_hid_activate_error1
		mov buffer_rq, temp

		mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_host_to_device @ bmRequest Type
		orr temp, temp, #equ32_usb20_req_set_feature<<8              @ bRequest
		orr temp, temp, #equ32_usb20_val_device_remote_wakeup<<16    @ wValue
		str temp, [buffer_rq]

		push {r0-r3}
		push {split_ctl,buffer_rx}
		bl usb2032_control
		add sp, sp, #8
		mov response, r0
		mov temp, r1
		pop {r0-r3}

		/* Set Idle */

		push {r0-r3}
		mov r0, #10                         @ 4 Bytes by 2 Words Equals 8 Bytes (Plus 8 Words for Alighment)
		bl usb2032_get_buffer_out
		mov temp, r0
		pop {r0-r3}
		cmp temp, #0
		beq hid32_hid_activate_error1
		mov buffer_rq, temp

		mov temp, #equ32_usb20_reqt_recipient_interface|equ32_usb20_reqt_type_class|equ32_usb20_reqt_host_to_device @ bmRequest Type
		orr temp, temp, #equ32_usb20_req_hid_set_idle<<8             @ bRequest
		orr temp, temp, #0<<16                                       @ wValue
		str temp, [buffer_rq]
		mov temp, num_interface                                      @ wIndex
		orr temp, temp, #0<<16                                       @ wLength
		str temp, [buffer_rq, #4]

		push {r0-r3}
		push {split_ctl,buffer_rx}
		bl usb2032_control
		add sp, sp, #8
		mov response, r0
		mov temp, r1
		pop {r0-r3}

macro32_debug response, 0, 312
macro32_debug temp, 0, 324

		/* Get Device Descriptor Again */

		push {r0-r3}
		mov r0, #10                         @ 4 Bytes by 2 Words Equals 8 Bytes (Plus 8 Words for Alighment)
		bl usb2032_get_buffer_out
		mov temp, r0
		pop {r0-r3}
		cmp temp, #0
		beq hid32_hid_activate_error1
		mov buffer_rq, temp

		mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_device_to_host @ bmRequest Type
		orr temp, temp, #equ32_usb20_req_get_descriptor<<8           @ bRequest
		orr temp, temp, #0<<16                                       @ wValue, Descriptor Index
		orr temp, temp, #equ32_usb20_val_descriptor_device<<16       @ wValue, Descriptor Type
		str temp, [buffer_rq]
		mov temp, #0                                                 @ wIndex
		orr temp, temp, #18<<16                                      @ wLength
		str temp, [buffer_rq, #4]

		mov character, packet_max                      @ Maximam Packet Size
		orr character, character, #0<<11               @ Endpoint Number
		orr character, character, #1<<15               @ In(1)/Out(0)
		orr character, character, #0<<16               @ Endpoint Type
		orr character, character, addr_device, lsl #18 @ Device Address
		orr character, character, #1<<25               @ Full and High Speed(0)/Low Speed(1)

		mov transfer_size, #18                         @ Transfer Size is 18 Bytes
		orr transfer_size, transfer_size, #3<<19       @ Transfer Packet is 3 Packets
		orr transfer_size, transfer_size, #0x40000000  @ Data Type is DATA1, Otherwise, meet Data Toggle Error

		push {r0-r3}
		push {split_ctl,buffer_rx}
		bl usb2032_control
		add sp, sp, #8
		mov response, r0
		mov temp, r1
		pop {r0-r3}

		/* Get Configuration, Interface, Endpoint Descriptors  */

		push {r0-r3}
		mov r0, #10                         @ 4 Bytes by 2 Words Equals 8 Bytes (Plus 8 Words for Alighment)
		bl usb2032_get_buffer_out
		mov temp, r0
		pop {r0-r3}
		cmp temp, #0
		beq hid32_hid_activate_error1
		mov buffer_rq, temp

		mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_device_to_host @ bmRequest Type
		orr temp, temp, #equ32_usb20_req_get_descriptor<<8            @ bRequest
		orr temp, temp, #0<<16                                        @ wValue, Descriptor Index
		orr temp, temp, #equ32_usb20_val_descriptor_configuration<<16 @ wValue, Descriptor Type
		str temp, [buffer_rq]
		mov temp, #0                                                  @ wIndex
		orr temp, temp, #32<<16                                       @ wLength
		str temp, [buffer_rq, #4]	

		mov character, packet_max                      @ Maximam Packet Size
		orr character, character, #0<<11               @ Endpoint Number
		orr character, character, #1<<15               @ In(1)/Out(0)
		orr character, character, #0<<16               @ Endpoint Type
		orr character, character, addr_device, lsl #18 @ Device Address
		orr character, character, #1<<25               @ Full and High Speed(0)/Low Speed(1)

		mov transfer_size, #32                         @ Transfer Size is 64 Bytes
		orr transfer_size, transfer_size, #4<<19       @ Transfer Packet is 8 Packets
		orr transfer_size, transfer_size, #0x40000000  @ Data Type is DATA1, Otherwise, meet Data Toggle Error

		push {r0-r3}
		push {split_ctl,buffer_rx}
		bl usb2032_control
		add sp, sp, #8
		mov response, r0
		mov temp, r1
		pop {r0-r3}

		ldrb response, [buffer_rx, #2]                     @ Total Length

macro32_debug response, 0, 348

		/* Get Configuration, Interface, Endpoint Descriptors Again */

		push {r0-r3}
		mov r0, #10                         @ 4 Bytes by 2 Words Equals 8 Bytes (Plus 8 Words for Alighment)
		bl usb2032_get_buffer_out
		mov temp, r0
		pop {r0-r3}
		cmp temp, #0
		beq hid32_hid_activate_error1
		mov buffer_rq, temp

		mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_device_to_host @ bmRequest Type
		orr temp, temp, #equ32_usb20_req_get_descriptor<<8            @ bRequest
		orr temp, temp, #0<<16                                        @ wValue, Descriptor Index
		orr temp, temp, #equ32_usb20_val_descriptor_configuration<<16 @ wValue, Descriptor Type
		str temp, [buffer_rq]
		mov temp, #0                                                  @ wIndex
		orr temp, temp, response, lsl #16                             @ wLength
		str temp, [buffer_rq, #4]

		mov character, packet_max                      @ Maximam Packet Size
		orr character, character, #0<<11               @ Endpoint Number
		orr character, character, #1<<15               @ In(1)/Out(0)
		orr character, character, #0<<16               @ Endpoint Type
		orr character, character, addr_device, lsl #18 @ Device Address
		orr character, character, #1<<25               @ Full and High Speed(0)/Low Speed(1)

		mov transfer_size, response                    @ Transfer Size

		add response, response, packet_max
		sub response, response, #1
		mov temp, #0
		hid32_hid_activate_loop2:
			subs response, response, packet_max
			addge temp, temp, #1
			bge hid32_hid_activate_loop2

macro32_debug temp, 0, 360
	
		orr transfer_size, transfer_size, temp, lsl #19 @ Transfer Packet is 8 Packets
		orr transfer_size, transfer_size, #0x40000000   @ Data Type is DATA1, Otherwise, meet Data Toggle Error

		push {r0-r3}
		push {split_ctl,buffer_rx}
		bl usb2032_control
		add sp, sp, #8
		mov response, r0
		mov temp, r1
		pop {r0-r3}

macro32_debug response, 0, 560
macro32_debug temp, 0, 572
sub buffer_rx, buffer_rx, #4
macro32_debug_hexa buffer_rx, 0, 584, 64
add buffer_rx, buffer_rx, #4

		cmp response, #2
		bne hid32_hid_activate_success            @ If Not STALL

		push {r0-r3}
		mov r2, #0
		mov r3, split_ctl
		bl usb2032_clear_halt
		mov response, r0
		pop {r0-r3}

macro32_debug response, 0, 608

	/* Get HID Report */

		b hid32_hid_activate_success

	hid32_hid_activate_error1:
		mvn r0, #0                        @ Return with -1
		b hid32_hid_activate_common

	hid32_hid_activate_error2:
		mvn r0, #1                        @ Return with -2
		b hid32_hid_activate_common

	hid32_hid_activate_error3:
		mvn r0, #2                        @ Return with -3
		b hid32_hid_activate_common

	hid32_hid_activate_success:
		mov r0, addr_device

	hid32_hid_activate_common:
		push {r0-r3}
		mov r0, buffer_rx
		bl usb2032_clear_buffer_in
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
.unreq num_config
.unreq num_interface
.unreq addr_device
.unreq packet_max


/**
 * function hid32_hid_get
 * Get Value from IN Endpoint
 *
 * Parameters
 * r0: Channel 0-15
 * r1: Number of Endpoint (Starting from 1)
 * r2: Ticket Issued by usb2032_hub_search_device, or Device Address as Direct Connection
 * r3: Buffer
 *
 * Return: r0 (Status of Channel, -1 and -2 as Error)
 * Error(-1): Failed Memory Allocation
 */
.globl hid32_hid_get
hid32_hid_get:
	/* Auto (Local) Variables, but just Aliases */
	channel         .req r0
	character       .req r1
	ticket          .req r2
	buffer          .req r3
	split_ctl       .req r4
	response        .req r5
	temp            .req r6
	num_endpoint    .req r7
	addr_device     .req r8

	push {r4-r8,lr}

	mov num_endpoint, character

	mov addr_device, ticket
	and addr_device, addr_device, #0x0000007F   @ Device Address

	mov split_ctl, ticket
	bic split_ctl, split_ctl, #0xFF000000       @ Mask Only Bit[20:14]: Address of Hub and Bit[13:7]: Port Number and 
	bic split_ctl, split_ctl, #0x00E00000
	lsr split_ctl, split_ctl, #7
	tst ticket, #0x80000000
	orrne split_ctl, split_ctl, #0x80000000     @ Bit[31:30]: 00b High Speed,10b Full Speed, 11b Low Speed

	.unreq ticket
	transfer_size .req r2

	mov character, #8                               @ Maximam Packet Size
	orr character, character, num_endpoint, lsl #11 @ Endpoint Number
	orr character, character, #1<<15                @ In(1)/Out(0)
	orr character, character, #3<<16                @ Endpoint Type
	orr character, character, addr_device, lsl #18  @ Device Address
	orr character, character, #1<<25                @ Full and High Speed(0)/Low Speed(1)

	mov transfer_size, #8                           @ Transfer Size is 8 Bytes
	orr transfer_size, transfer_size, #0x00080000   @ Transfer Packet is 1 Packet
	orr transfer_size, transfer_size, #0x40000000   @ Data Type is DATA1, Otherwise, meet Data Toggle Error

	push {r0-r3}
	push {split_ctl}
	bl usb2032_transaction
	add sp, sp, #4
	mov response, r0
	pop {r0-r3}

	hid32_hid_get_common:
		mov r0, response
		macro32_dsb ip                    @ Ensure Completion of Instructions Before
		pop {r4-r8,pc}

.unreq channel
.unreq character
.unreq transfer_size
.unreq buffer
.unreq split_ctl
.unreq response
.unreq temp
.unreq num_endpoint
.unreq addr_device
