/**
 * hid32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

HID32_USB2032_ROOTHUB_ADDR:        .word USB2032_ROOTHUB
HID32_USB2032_ADDRESS_LENGTH_ADDR: .word USB2032_ADDRESS_LENGTH

/**
 * function hid32_hid_activate
 * Search and Activate Human Interface Device (HID) of USB2.0
 * Caution! This Function Only Activates Interface #0 of The Assigned Configuration.
 *
 * Parameters
 * r0: Channel 0-15
 * r1: Number of Configuration for HID on Device (Starting from 1)
 * r2: Ticket Issued by usb2032_hub_search_device, or 0 as Direct Connection
 *
 * Return: r0 (Ticket of HID, 0, -1, -2, and -3 as Error)
 * Error(0): No Connection
 * Error(-1): No HID
 * Error(-2): Failure of Communication (Stall on Critical Point/Time Out)
 * Error(-3): Failed Memory Allocation
 */
.globl hid32_hid_activate
hid32_hid_activate:
	/* Auto (Local) Variables, but just Aliases */
	channel         .req r0
	character       .req r1
	transfer_size   .req r2
	buffer_rq       .req r3
	split_ctl       .req r4
	buffer_rx       .req r5
	response        .req r6
	temp            .req r7
	num_config      .req r8
	addr_device     .req r9
	packet_max      .req r10
	ticket          .req r11

	push {r4-r11,lr}

	mov num_config, character
	mov ticket, transfer_size

	mov buffer_rx, #0                               @ To Check Whether Allocated or Not

	cmp ticket, #0
	beq hid32_hid_activate_direct

	mov addr_device, ticket                         @ If Ticket Exist (Connected Through Hub)
	and addr_device, addr_device, #0x0000007F       @ Device Address
	mov split_ctl, ticket
	bic split_ctl, split_ctl, #0xFF000000           @ Mask for Bit[20:14]: Address of Hub, and Bit[13:7]: Port Number
	bic split_ctl, split_ctl, #0x00E00000
	lsr split_ctl, split_ctl, #7
	tst ticket, #0x40000000
	orrne split_ctl, split_ctl, #0x80000000         @ Bit[30:29]: 00b High Speed,10b Full Speed, 11b Low Speed
	tst ticket, #0x20000000
	movne packet_max, #8                            @ Low Speed
	moveq packet_max, #64                           @ High/Full Speed
	b hid32_hid_activate_getbuffer

	hid32_hid_activate_direct:

		mov split_ctl, #0
		mov addr_device, #0                         @ If No Ticket (Connected Directly), No Address Yet

		push {r0-r3}
		ldr ip, HID32_USB2032_ROOTHUB_ADDR
		ldr ip, [ip]
		blx ip
		mov temp, r0
		pop {r0-r3}

		tst temp, #equ32_usb20_status_hubport_connection
		beq hid32_hid_activate_error0

		tst temp, #equ32_usb20_status_hubport_lowspeed
		movne packet_max, #8
		movne ticket, #0b11<<29
		bne hid32_hid_activate_getbuffer

		mov packet_max, #64

		tst temp, #equ32_usb20_status_hubport_highspeed
		moveq ticket, #0b10<<29                    @ Full Speed

	hid32_hid_activate_getbuffer:

		push {r0-r3}
		mov r0, #16                                                  @ 4 Bytes by 16 Words Equals 64 Bytes
		bl usb2032_get_buffer_in
		mov buffer_rx, r0
		pop {r0-r3}
		cmp buffer_rx, #0
		beq hid32_hid_activate_error3

		/* Get Device Descriptor */

		/**
		 * Overall, on each low speed device, the method for accurate collection of descriptors varies.
		 * e.g., if you get the device descriptor overing 8 maximum packets, you'll get the latter half of this. 
		 */

		push {r0-r3}
		mov r0, #2                                                   @ 4 Bytes by 2 Words Equals 8 Bytes
		bl usb2032_get_buffer_out
		mov temp, r0
		pop {r0-r3}
		cmp temp, #0
		beq hid32_hid_activate_error3
		mov buffer_rq, temp

		mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_device_to_host @ bmRequest Type
		orr temp, temp, #equ32_usb20_req_get_descriptor<<8           @ bRequest
		orr temp, temp, #0<<16                                       @ wValue, Descriptor Index
		orr temp, temp, #equ32_usb20_val_descriptor_device<<16       @ wValue, Descriptor Type
		str temp, [buffer_rq]
		mov temp, #0                                                 @ wIndex
		orr temp, temp, #8<<16                                       @ wLength
		str temp, [buffer_rq, #4]

		mov character, packet_max                      @ Maximam Packet Size
		orr character, character, #0<<11               @ Endpoint Number
		orr character, character, #1<<15               @ In(1)/Out(0)
		orr character, character, #0<<16               @ Endpoint Type
		orr character, character, addr_device, lsl #18 @ Device Address
		cmp packet_max, #8
		orreq character, character, #1<<25             @ Full and High Speed(0)/Low Speed(1)

		/**
		 * On some devices with split-control,
		 * transferring multiple packets makes halt because the rest of data length doesn't meet maximum packet size. 
		 * e.g., receiving 10 bytes where the maximum packet size is 8 bytes gets 2 packets, but the last packet is only 2 bytes.
		 * This case may make halt on transferring. To hide this, we change the transfer size from original to a factor of maximum packet size.
		 */

		mov response, #8
		tst response, #0b0111
		bicne response, response, #0b0111
		addne response, response, #0b1000

		mov transfer_size, response                    @ Transfer Size is 24 Bytes (Actually 18 Bytes)

		add response, response, packet_max
		sub response, response, #1
		mov temp, #0
		hid32_hid_activate_devdesc_packet:
			subs response, response, packet_max
			addge temp, temp, #1
			bge hid32_hid_activate_devdesc_packet

		orr transfer_size, transfer_size, temp, lsl #19 @ Transfer Packet
		orr transfer_size, transfer_size, #0x40000000   @ Data Type is DATA1, Otherwise, meet Data Toggle Error

		push {r0-r3}
		push {split_ctl,buffer_rx}
		bl usb2032_control
		add sp, sp, #8
		mov response, r0
		mov temp, r1
		pop {r0-r3}

/*
macro32_debug response, 0, 100
macro32_debug temp, 0, 112
macro32_debug_hexa buffer_rx, 0, 124, 64
*/

		cmp response, #0
		bne hid32_hid_activate_error2                  @ Failure of Communication

		ldrb temp, [buffer_rx, #4]
		cmp temp, #0                                   @ Device Class is Zero (Described in Interface Descriptor) or Not
		bne hid32_hid_activate_error1

		ldrb packet_max, [buffer_rx, #7]
		cmp packet_max, #0x0                           @ Failure of Obtaining Device Discriptor

		beq hid32_hid_activate_error2

		/* Set Configuration  */

		push {r0-r3}
		mov r0, #2                                                   @ 4 Bytes by 2 Words Equals 8 Bytes
		bl usb2032_get_buffer_out
		mov temp, r0
		pop {r0-r3}
		cmp temp, #0
		beq hid32_hid_activate_error3
		mov buffer_rq, temp

		mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_host_to_device @ bmRequest Type
		orr temp, temp, #equ32_usb20_req_set_configuration<<8        @ bRequest
		orr temp, temp, num_config, lsl #16                          @ wValue, Descriptor Index
		str temp, [buffer_rq]
		mov temp, #0                                                 @ wIndex
		orr temp, temp, #0<<16                                       @ wLength
		str temp, [buffer_rq, #4]

		mov character, packet_max                      @ Maximam Packet Size
		orr character, character, #0<<11               @ Endpoint Number
		orr character, character, #0<<15               @ In(1)/Out(0)
		orr character, character, #0<<16               @ Endpoint Type
		orr character, character, addr_device, lsl #18 @ Device Address
		cmp packet_max, #8
		orreq character, character, #1<<25             @ Full and High Speed(0)/Low Speed(1)

		mov transfer_size, #0                          @ Transfer Size is 0 Bytes

		push {r0-r3}
		push {split_ctl,buffer_rx}
		bl usb2032_control
		add sp, sp, #8
		mov response, r0
		mov temp, r1
		pop {r0-r3}

		cmp response, #0
		bne hid32_hid_activate_error2                  @ Failure of Communication

		/* Get Configuration, Interface, Endpoint Descriptors  */

		push {r0-r3}
		mov r0, #2                                                   @ 4 Bytes by 2 Words Equals 8 Bytes
		bl usb2032_get_buffer_out
		mov temp, r0
		pop {r0-r3}
		cmp temp, #0
		beq hid32_hid_activate_error3
		mov buffer_rq, temp

		mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_device_to_host @ bmRequest Type
		orr temp, temp, #equ32_usb20_req_get_descriptor<<8            @ bRequest
		orr temp, temp, #0<<16                                        @ wValue, Descriptor Index
		orr temp, temp, #equ32_usb20_val_descriptor_configuration<<16 @ wValue, Descriptor Type
		str temp, [buffer_rq]
		mov temp, #0                                                  @ wIndex
		orr temp, temp, #16<<16   @ Configuration Descriptor is 9 Bytes Fixed, But Needed A Factor of 8 in Case
		str temp, [buffer_rq, #4]	

		mov character, packet_max                      @ Maximam Packet Size
		orr character, character, #0<<11               @ Endpoint Number
		orr character, character, #1<<15               @ In(1)/Out(0)
		orr character, character, #0<<16               @ Endpoint Type
		orr character, character, addr_device, lsl #18 @ Device Address
		cmp packet_max, #8
		orreq character, character, #1<<25             @ Full and High Speed(0)/Low Speed(1)

		mov response, #16
		tst response, #0b0111
		bicne response, response, #0b0111
		addne response, response, #0b1000

		mov transfer_size, response                    @ Transfer Size

		add response, response, packet_max
		sub response, response, #1
		mov temp, #0
		hid32_hid_activate_configdesc_packet:
			subs response, response, packet_max
			addge temp, temp, #1
			bge hid32_hid_activate_configdesc_packet

		orr transfer_size, transfer_size, temp, lsl #19 @ Transfer Packet
		orr transfer_size, transfer_size, #0x40000000   @ Data Type is DATA1, Otherwise, meet Data Toggle Error

		push {r0-r3}
		push {split_ctl,buffer_rx}
		bl usb2032_control
		add sp, sp, #8
		mov response, r0
		mov temp, r1
		pop {r0-r3}

		cmp response, #0
		bne hid32_hid_activate_error2                        @ Failure of Communication

/*
macro32_debug response, 0, 148
macro32_debug temp, 0, 160
macro32_debug_hexa buffer_rx, 0, 172, 64
*/

		ldrb response, [buffer_rx, #0xE]                     @ Interface Class (Interface #0)

/*
macro32_debug response, 0, 196
*/

		cmp response, #3                                     @ Interface Class is HID
		bne hid32_hid_activate_error1

		cmp addr_device, #0
		bne hid32_hid_activate_jump

		/* Set Address to #1 If Direct Connection */

		ldr temp, HID32_USB2032_ADDRESS_LENGTH_ADDR
		ldr addr_device, [temp]
		add addr_device, addr_device, #1
		str addr_device, [temp]
		orr ticket, ticket, addr_device

		push {r0-r3}
		mov r0, #2                                                   @ 4 Bytes by 2 Words Equals 8 Bytes
		bl usb2032_get_buffer_out
		mov temp, r0
		pop {r0-r3}
		cmp temp, #0
		beq hid32_hid_activate_error3
		mov buffer_rq, temp

		mov addr_device, #1

		mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_host_to_device @ bmRequest Type
		orr temp, temp, #equ32_usb20_req_set_address<<8              @ bRequest
		orr temp, temp, addr_device, lsl #16                         @ wValue, address
		str temp, [buffer_rq]
		mov temp, #0                                                 @ wIndex
		orr temp, temp, #0<<16                                       @ wLength
		str temp, [buffer_rq, #4]

		mov character, packet_max                     @ Maximam Packet Size
		orr character, character, #0<<11              @ Endpoint Number
		orr character, character, #0<<15              @ In(1)/Out(0)
		orr character, character, #0<<16              @ Endpoint Type
		orr character, character, #0<<18              @ Device Address
		cmp packet_max, #8
		orreq character, character, #1<<25             @ Full and High Speed(0)/Low Speed(1)

		mov transfer_size, #0                         @ Transfer Size is 0 Bytes

		push {r0-r3}
		push {split_ctl,buffer_rx}
		bl usb2032_control
		add sp, sp, #8
		mov response, r0
		mov temp, r1
		pop {r0-r3}

		cmp response, #0
		bne hid32_hid_activate_error2

	hid32_hid_activate_jump:

		/* Remote Wakeup  */

		push {r0-r3}
		mov r0, #2                                                   @ 4 Bytes by 2 Words Equals 8 Bytes
		bl usb2032_get_buffer_out
		mov temp, r0
		pop {r0-r3}
		cmp temp, #0
		beq hid32_hid_activate_error3
		mov buffer_rq, temp

		mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_host_to_device @ bmRequest Type
		orr temp, temp, #equ32_usb20_req_set_feature<<8              @ bRequest
		orr temp, temp, #equ32_usb20_val_device_remote_wakeup<<16    @ wValue
		str temp, [buffer_rq]

		mov character, packet_max                      @ Maximam Packet Size
		orr character, character, #0<<11               @ Endpoint Number
		orr character, character, #0<<15               @ In(1)/Out(0)
		orr character, character, #0<<16               @ Endpoint Type
		orr character, character, addr_device, lsl #18 @ Device Address
		cmp packet_max, #8
		orreq character, character, #1<<25             @ Full and High Speed(0)/Low Speed(1)

		mov transfer_size, #0                          @ Transfer Size is 0 Bytes

		push {r0-r3}
		push {split_ctl,buffer_rx}
		bl usb2032_control
		add sp, sp, #8
		mov response, r0
		mov temp, r1
		pop {r0-r3}

		cmp response, #0
		bne hid32_hid_activate_error2                  @ Failure of Communication

		b hid32_hid_activate_success

	hid32_hid_activate_error0:
		mov r0, #0                        @ Return with 0
		b hid32_hid_activate_common

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
		mov r0, ticket

	hid32_hid_activate_common:
		push {r0-r3}
		mov r0, buffer_rx
		cmp r0, #0                        @ If Not Allocated
		blne usb2032_clear_buffer_in
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
.unreq addr_device
.unreq packet_max
.unreq ticket


/**
 * function hid32_hid_setidle
 * Set Idle of HID, Use for Mouse, etc.
 *
 * Parameters
 * r0: Channel 0-15
 * r1: Number of Interface (Starting from 0)
 * r2: Ticket Issued by hid32_hid_activate
 *
 * Return: r0 (0 as Success, -1 and -2 as Error)
 * Error(-1): Failure of Communication (Stall on Critical Point/Time Out)
 * Error(-2): Failed Memory Allocation
 */
.globl hid32_hid_setidle
hid32_hid_setidle:
	/* Auto (Local) Variables, but just Aliases */
	channel         .req r0
	character       .req r1
	ticket          .req r2
	buffer_rq       .req r3
	split_ctl       .req r4
	buffer_rx       .req r5
	response        .req r6
	packet_max      .req r7
	num_interface   .req r8
	addr_device     .req r9
	temp            .req r10

	push {r4-r10,lr}

	mov num_interface, character

	mov addr_device, ticket
	and addr_device, addr_device, #0x0000007F       @ Device Address
	mov split_ctl, ticket
	bic split_ctl, split_ctl, #0xFF000000           @ Mask for Bit[20:14]: Address of Hub, and Bit[13:7]: Port Number
	bic split_ctl, split_ctl, #0x00E00000
	lsr split_ctl, split_ctl, #7
	tst ticket, #0x40000000
	orrne split_ctl, split_ctl, #0x80000000         @ Bit[30:29]: 00b High Speed,10b Full Speed, 11b Low Speed
	tst ticket, #0x20000000
	movne packet_max, #8                            @ Low Speed
	moveq packet_max, #64                           @ High/Full Speed

	tst ticket, #0x001FC000                         @ Bit[20:14]: Address of Hub
	biceq split_ctl, split_ctl, #0x80000000         @ If Direct Connection, No Split Control

	.unreq ticket
	transfer_size .req r2

	/* Set Idle */

	push {r0-r3}
	mov r0, #2                                                   @ 4 Bytes by 2 Words Equals 8 Bytes
	bl usb2032_get_buffer_out
	mov temp, r0
	pop {r0-r3}
	cmp temp, #0
	beq hid32_hid_setidle_error2
	mov buffer_rq, temp

	mov temp, #equ32_usb20_reqt_recipient_interface|equ32_usb20_reqt_type_class|equ32_usb20_reqt_host_to_device @ bmRequest Type
	orr temp, temp, #equ32_usb20_req_hid_set_idle<<8             @ bRequest
	orr temp, temp, #0<<16                                       @ wValue
	str temp, [buffer_rq]
	mov temp, num_interface                                      @ wIndex, Interface Number
	orr temp, temp, #0<<16                                       @ wLength
	str temp, [buffer_rq, #4]

	mov character, packet_max                       @ Maximam Packet Size
	orr character, character, #0<<11                @ Endpoint Number
	orr character, character, #0<<15                @ In(1)/Out(0)
	orr character, character, #0<<16                @ Endpoint Type
	orr character, character, addr_device, lsl #18  @ Device Address
	cmp packet_max, #8
	orreq character, character, #1<<25              @ Full and High Speed(0)/Low Speed(1)

	mov transfer_size, #0                           @ Transfer Size is 0 Bytes
	mov buffer_rx, #0                               @ No Use

	push {r0-r3}
	push {split_ctl,buffer_rx}
	bl usb2032_control
	add sp, sp, #8
	mov response, r0
	mov temp, r1
	pop {r0-r3}

/*
macro32_debug response, 0, 148
macro32_debug temp, 0, 160
*/

	cmp response, #0
	beq hid32_hid_setidle_success

	hid32_hid_setidle_error1:
		mvn r0, #0
		b hid32_hid_setidle_common

	hid32_hid_setidle_error2:
		mvn r0, #1
		b hid32_hid_setidle_common

	hid32_hid_setidle_success:
		mov r0, #0

	hid32_hid_setidle_common:
		macro32_dsb ip                    @ Ensure Completion of Instructions Before
		pop {r4-r10,pc}

.unreq channel
.unreq character
.unreq transfer_size
.unreq buffer_rq
.unreq split_ctl
.unreq buffer_rx
.unreq response
.unreq packet_max
.unreq num_interface
.unreq addr_device
.unreq temp


/**
 * function hid32_hid_get
 * Get Value from IN Endpoint (8 Bytes Only)
 *
 * Parameters
 * r0: Channel 0-15
 * r1: Number of Endpoint (Starting from 1)
 * r2: Ticket Issued by hid32_hid_activate
 * r3: Buffer
 *
 * Return: r0 (Response of USB Transaction)
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
	packet_max      .req r6
	num_endpoint    .req r7
	addr_device     .req r8

	push {r4-r8,lr}

	mov num_endpoint, character

	mov addr_device, ticket
	and addr_device, addr_device, #0x0000007F       @ Device Address
	mov split_ctl, ticket
	bic split_ctl, split_ctl, #0xFF000000           @ Mask for Bit[20:14]: Address of Hub, and Bit[13:7]: Port Number
	bic split_ctl, split_ctl, #0x00E00000
	lsr split_ctl, split_ctl, #7
	tst ticket, #0x40000000
	orrne split_ctl, split_ctl, #0x80000000         @ Bit[30:29]: 00b High Speed,10b Full Speed, 11b Low Speed
	tst ticket, #0x20000000
	movne packet_max, #8                            @ Low Speed
	moveq packet_max, #64                           @ High/Full Speed

	tst ticket, #0x001FC000                         @ Bit[20:14]: Address of Hub
	biceq split_ctl, split_ctl, #0x80000000         @ If Direct Connection, No Split Control

	.unreq ticket
	transfer_size .req r2

	mov character, packet_max                       @ Maximam Packet Size
	orr character, character, num_endpoint, lsl #11 @ Endpoint Number
	orr character, character, #1<<15                @ In(1)/Out(0)
	orr character, character, #3<<16                @ Endpoint Type
	orr character, character, addr_device, lsl #18  @ Device Address
	cmp packet_max, #8
	orreq character, character, #1<<25              @ Full and High Speed(0)/Low Speed(1)

	mov transfer_size, #8                           @ Transfer Size is 8 Bytes
	orr transfer_size, transfer_size, #0x00080000   @ Transfer Packet is 1 Packet
	orr transfer_size, transfer_size, #0x40000000   @ Data Type is DATA1, Otherwise, meet Data Toggle Error

	macro32_dsb ip

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
.unreq packet_max
.unreq num_endpoint
.unreq addr_device


/**
 * function hid32_keyboard_get
 * Return Ascii Code of Pushed Key on Keyboard
 * Note that this function makes new memory space to be needed to make the memory free.
 *
 * Parameters
 * r0: Channel 0-15
 * r1: Number of Endpoint (Starting from 1)
 * r2: Ticket Issued by usb2032_hub_search_device, or hid32_hid_activate
 *
 * Return: r0 (Pointer of Ascii Codes of Pushed Keys on Keyboard, If 0 NAK, Any Transaction Error, or Memory Allocation Fails)
 */
.globl hid32_keyboard_get
hid32_keyboard_get:
	/* Auto (Local) Variables, but just Aliases */
	channel         .req r0
	character       .req r1
	ticket          .req r2
	buffer          .req r3
	data_lower      .req r4
	data_upper      .req r5
	response        .req r6
	base            .req r7
	i               .req r8
	j               .req r9
	increment       .req r10
	modifier        .req r11

	push {r4-r11,lr}

	push {r0-r2}
	mov r0, #2                             @ 4 Bytes by 2 Words Equals 8 Bytes
	bl usb2032_get_buffer_in
	mov buffer, r0
	pop {r0-r2}

	cmp buffer, #0
	beq hid32_keyboard_get_error

	push {r0-r3}
	bl hid32_hid_get
	mov response, r0
	pop {r0-r3}

/*
macro32_debug ticket, 320, 0
macro32_debug buffer, 320, 12
*/

	/* In Data of Keyboard is 8 Bytes */
	ldr data_lower, [buffer]
	ldr data_upper, [buffer, #4]

/*
macro32_debug data_lower, 320, 24
*/

	push {r0-r3}
	mov r0, buffer
	bl usb2032_clear_buffer_in
	pop {r0-r3}

	tst response, #0x4                     @ ACK
	beq hid32_keyboard_get_error

	/* If we get any arrows at all, we need 24 bytes, because 6 bytes are for characters and 3 bytes needs per one arrow */

	push {r0-r2}
	mov r0, #7                             @ 4 Bytes by 7 Words Equals 28 Bytes
	bl heap32_malloc
	mov buffer, r0
	pop {r0-r2}

	cmp buffer, #0
	beq hid32_keyboard_get_error

	.unreq channel
	temp  .req r0
	.unreq character
	shift .req r1
	.unreq ticket
	maxi  .req r2
	.unreq response
	byte  .req r6

	mov modifier, #0

	tst data_lower, #0x2                   @ Modifier Is Shift
	ldreq base, hid32_keyboard_get_ascii
	ldrne base, hid32_keyboard_get_ascii_shift
	orrne modifier, modifier, #0x2
	lsr data_lower, data_lower, #16        @ First and Second Bytes Are for Modifier and Reserved
	
	mov increment, #0
	mov i, #0
	mov maxi, #1

	hid32_keyboard_get_loop:
		mov shift, #0
		mov byte, #0xFF
		lsl i, i, #3                       @ Substitute of Multiplication by 8
		lsl byte, byte, i

		and temp, data_lower, byte
		lsr temp, temp, i

		cmp temp, #0x39                    @ 0x0 - 0x38 Are Real Characters
		ldrlob byte, [base, temp]
		movlo j, #1
		blo hid32_keyboard_get_loop_store

		cmp temp, #0x87                    @ International1
		beq hid32_keyboard_get_loop_intl1

		mov byte, #0x001B
		orr byte, byte, #0x5B00

		cmp temp, #0x52                    @ Up Arrow
		orreq byte, byte, #0x410000        @ Escape Sequence, Cursor Up, Esc[A (Shown by Little Endian Order)
		moveq j, #3
		beq hid32_keyboard_get_loop_store

		cmp temp, #0x51                    @ Down Arrow
		orreq byte, byte, #0x420000        @ Escape Sequence, Cursor Down, Esc[B (Shown by Little Endian Order)
		moveq j, #3
		beq hid32_keyboard_get_loop_store

		cmp temp, #0x50                    @ Left Arrow
		orreq byte, byte, #0x440000        @ Escape Sequence, Cursor Left, Esc[D (Shown by Little Endian Order)
		moveq j, #3
		beq hid32_keyboard_get_loop_store

		cmp temp, #0x4F                    @ Right Arrow
		orreq byte, byte, #0x430000        @ Escape Sequence, Cursor Right, Esc[C (Shown by Little Endian Order)
		moveq j, #3
		beq hid32_keyboard_get_loop_store

		b hid32_keyboard_get_success

		hid32_keyboard_get_loop_intl1:
			tst modifier, #0x2
			movne byte, #0x5F            @ Ascii Code of Underbar
			moveq byte, #0x5C            @ Ascii Code of Backslash

		hid32_keyboard_get_loop_store:
			mov temp, #0xFF
			lsl temp, temp, shift
			and temp, byte, temp
			lsr temp, temp, shift
			strb temp, [buffer, increment]
			add increment, increment, #1
			add shift, shift, #8
			subs j, j, #1
			bgt hid32_keyboard_get_loop_store

		hid32_keyboard_get_loop_common:
			macro32_dsb ip 
			lsr i, i, #3                           @ Division of Multiplication by 8
			add i, i, #1
			cmp i, maxi
			ble hid32_keyboard_get_loop

			cmp maxi, #1                           @ If Loop for Lower Half of Data
			moveq i, #0
			moveq maxi, #3
			moveq data_lower, data_upper
			beq hid32_keyboard_get_loop

			b hid32_keyboard_get_success

	hid32_keyboard_get_error:
		mov r0, #0                         @ Error with -0
		b hid32_keyboard_get_common

	hid32_keyboard_get_success:
		mov r0, buffer

	hid32_keyboard_get_common:
		macro32_dsb ip                     @ Ensure Completion of Instructions Before
		pop {r4-r11,pc}

.unreq temp
.unreq shift
.unreq maxi
.unreq buffer
.unreq data_lower
.unreq data_upper
.unreq byte
.unreq base
.unreq i
.unreq j
.unreq increment
.unreq modifier

hid32_keyboard_get_ascii:        .word _hid32_keyboard_get_ascii
hid32_keyboard_get_ascii_shift:  .word _hid32_keyboard_get_ascii_shift
_hid32_keyboard_get_ascii: .ascii "\0\0\0\0abcdefghijklmnopqrstuvwxyz1234567890\xD\x1B\x8\x9 -=[]\\#;'`,./"
.space 7 @ Total 64 Bytes (0x40 Bytest)
_hid32_keyboard_get_ascii_shift: .ascii "\0\0\0\0ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()\xD\x1B\x8\x9 _+{}|-:\"~<>?"
.space 7 @ Total 64 Bytes (0x40 Bytest)

