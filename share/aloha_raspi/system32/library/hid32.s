/**
 * hid32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


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
	beq hid32_hid_activate_direct

	mov addr_device, ticket                         @ If Ticket Exist (Connected Through Hub)
	and addr_device, addr_device, #0x0000007F       @ Device Address
	mov split_ctl, ticket
	bic split_ctl, split_ctl, #0xFF000000           @ Mask for Bit[20:14]: Address of Hub, and Bit[13:7]: Port Number
	bic split_ctl, split_ctl, #0x00E00000
	lsr split_ctl, split_ctl, #7
	tst ticket, #0x80000000
	orrne split_ctl, split_ctl, #0x80000000         @ Bit[31:30]: 00b High Speed,10b Full Speed, 11b Low Speed
	tst ticket, #0x40000000
	movne packet_max, #8                            @ Low Speed
	moveq packet_max, #64                           @ High/Full Speed
	b hid32_hid_activate_getbuffer

	hid32_hid_activate_direct:

		mov addr_device, #0                         @ If No Ticket (Connected Directly), No Address Yet
		/**
		 * Consider of Low Speed Device, Full Speed Deice Needs to Make Max. Packet Size to 64 Bytes Though
		 * If you want multiple settings on maximum packet size for direct connection, detecting device speed from root hub is needed.
		 */
		mov packet_max, #8

		.unreq ticket
		buffer_rq .req r3

	hid32_hid_activate_getbuffer:

		push {r0-r3}
		mov r0, #16                                                  @ 4 Bytes by 16 Words Equals 64 Bytes
		bl usb2032_get_buffer_in
		mov buffer_rx, r0
		pop {r0-r3}
		cmp buffer_rx, #0
		beq hid32_hid_activate_error1

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
		beq hid32_hid_activate_error1
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
		orr character, character, #1<<25               @ Full and High Speed(0)/Low Speed(1)

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

	macro32_debug response, 0, 100
	macro32_debug temp, 0, 112
	macro32_debug_hexa buffer_rx, 0, 124, 64

		cmp response, #0
		bne hid32_hid_activate_error3

		ldrb temp, [buffer_rx, #4]
		cmp temp, #0                                   @ Device Class is HID or Not
		bne hid32_hid_activate_error2

		ldrb packet_max, [buffer_rx, #7]
		cmp packet_max, #0x0                           @ Failure of Obtaining Device Discriptor 
		beq hid32_hid_activate_error2

		cmp addr_device, #0
		bne hid32_hid_activate_jump

		/* Set Address as #1 If Direct Connection */

		push {r0-r3}
		mov r0, #2                                                   @ 4 Bytes by 2 Words Equals 8 Bytes
		bl usb2032_get_buffer_out
		mov temp, r0
		pop {r0-r3}
		cmp temp, #0
		beq hid32_hid_activate_error1
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
		mov r0, #2                                                   @ 4 Bytes by 2 Words Equals 8 Bytes
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
		orr temp, temp, #0<<16                                       @ wLength
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
		mov r0, #2                                                   @ 4 Bytes by 2 Words Equals 8 Bytes
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
		mov r0, #2                                                   @ 4 Bytes by 2 Words Equals 8 Bytes
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

		/* If Connected with Hub, Pass Getting Other Descriptors */
		cmp addr_device, #1
		/*bne hid32_hid_activate_success*/

		/* Get Configuration, Interface, Endpoint Descriptors  */

		push {r0-r3}
		mov r0, #2                                                   @ 4 Bytes by 2 Words Equals 8 Bytes
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
		orr temp, temp, #16<<16   @ Configuration Descriptor is 9 Bytes Fixed, But Needed A Factor of 8 in Case
		str temp, [buffer_rq, #4]	

		mov character, packet_max                      @ Maximam Packet Size
		orr character, character, #0<<11               @ Endpoint Number
		orr character, character, #1<<15               @ In(1)/Out(0)
		orr character, character, #0<<16               @ Endpoint Type
		orr character, character, addr_device, lsl #18 @ Device Address
		orr character, character, #1<<25               @ Full and High Speed(0)/Low Speed(1)

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

macro32_debug response, 0, 148
macro32_debug temp, 0, 160
macro32_debug_hexa buffer_rx, 0, 172, 64

		ldrb response, [buffer_rx, #0xE]                     @ Interface Class (Interface #0)

macro32_debug response, 0, 196

		cmp response, #3                                     @ Interface Class is HID
		bne hid32_hid_activate_error2

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
 * Get Value from IN Endpoint (8 Bytes Only)
 *
 * Parameters
 * r0: Channel 0-15
 * r1: Number of Endpoint (Starting from 1)
 * r2: Ticket Issued by usb2032_hub_search_device, or Device Address as Direct Connection
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

	tst ticket, #0x001FC000                         @ Bit[20:14]: Address of Hub
	beq hid32_hid_get_direct

	mov addr_device, ticket
	and addr_device, addr_device, #0x0000007F       @ Device Address
	mov split_ctl, ticket
	bic split_ctl, split_ctl, #0xFF000000           @ Mask for Bit[20:14]: Address of Hub, and Bit[13:7]: Port Number
	bic split_ctl, split_ctl, #0x00E00000
	lsr split_ctl, split_ctl, #7
	tst ticket, #0x80000000
	orrne split_ctl, split_ctl, #0x80000000         @ Bit[31:30]: 00b High Speed,10b Full Speed, 11b Low Speed
	tst ticket, #0x40000000
	movne packet_max, #8                            @ Low Speed
	moveq packet_max, #64                           @ High/Full Speed

	b hid32_hid_get_transaction

	hid32_hid_get_direct:

		mov addr_device, ticket
		/**
		 * Consider of Low Speed Device, Full Speed Deice Needs to Make Max. Packet Size to 64 Bytes Though
		 * If you want multiple settings on maximum packet size for direct connection, detecting device speed from root hub is needed.
		 */
		mov packet_max, #8                            @ Direct Connection

	.unreq ticket
	transfer_size .req r2

	hid32_hid_get_transaction:

		mov character, packet_max                       @ Maximam Packet Size
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
.unreq packet_max
.unreq num_endpoint
.unreq addr_device


/**
 * function hid32_keyboard_get
 * Return Ascii Code of Pushed Key on Keyboard
 *
 * Parameters
 * r0: Channel 0-15
 * r1: Number of Endpoint (Starting from 1)
 * r2: Ticket Issued by usb2032_hub_search_device, or Device Address as Direct Connection
 *
 * Return: r0 (Ascii Code of Pused Key on Keyboard, If -1 NAK or Any Transaction Error)
 */
.globl hid32_keyboard_get
hid32_keyboard_get:
	/* Auto (Local) Variables, but just Aliases */
	channel         .req r0
	character       .req r1
	ticket          .req r2
	buffer          .req r3
	data            .req r4
	response        .req r5
	base            .req r6

	push {r4-r6,lr}

	push {r0-r2}
	mov r0, #2                             @ 4 Bytes by 2 Words Equals 8 Bytes
	bl usb2032_get_buffer_in
	mov buffer, r0
	pop {r0-r2}

	push {r0-r3}
	bl hid32_hid_get
	mov response, r0
	pop {r0-r3}

macro32_debug ticket, 320, 0
macro32_debug buffer, 320, 12

	/* In Data of Keyboard is 8 Bytes, but in This Case, First 4 bytes are Needed */
	ldr data, [buffer]

macro32_debug data, 320, 24

	push {r0-r3}
	mov r0, buffer
	bl usb2032_clear_buffer_in
	pop {r0-r3}

	tst response, #0x4                     @ ACK
	beq hid32_keyboard_get_error

	.unreq response
	byte .req r5

	tst data, #0x2                         @ Modifier Is Shift
	ldreq base, hid32_keyboard_get_ascii
	ldrne base, hid32_keyboard_get_ascii_shift
	lsr data, data, #16
	and data, data, #0xFF

	cmp data, #0x39                        @ 0x0 - 0x38 Are Real Characters
	ldrlob byte, [base, data]
	blo hid32_keyboard_get_success

	mov byte, #0x001B
	orr byte, byte, #0x5B00

	cmp data, #0x52                        @ Up Arrow
	orreq byte, byte, #0x410000            @ Escape Sequence, Cursor Up, Esc[A (Shown by Little Endian Order)
	beq hid32_keyboard_get_success

	cmp data, #0x51                        @ Down Arrow
	orreq byte, byte, #0x420000            @ Escape Sequence, Cursor Down, Esc[B (Shown by Little Endian Order)
	beq hid32_keyboard_get_success

	cmp data, #0x50                        @ Left Arrow
	orreq byte, byte, #0x440000            @ Escape Sequence, Cursor Left, Esc[D (Shown by Little Endian Order)
	beq hid32_keyboard_get_success

	cmp data, #0x4F                        @ Right Arrow
	orreq byte, byte, #0x430000            @ Escape Sequence, Cursor Right, Esc[C (Shown by Little Endian Order)
	beq hid32_keyboard_get_success

	b hid32_keyboard_get_success

	hid32_keyboard_get_error:
		mvn r0, #0                         @ Error with -1
		b hid32_keyboard_get_common

	hid32_keyboard_get_success:
		mov r0, byte

	hid32_keyboard_get_common:
		macro32_dsb ip                     @ Ensure Completion of Instructions Before
		pop {r4-r6,pc}

.unreq channel
.unreq character
.unreq ticket
.unreq buffer
.unreq data
.unreq byte
.unreq base

hid32_keyboard_get_ascii:        .word _hid32_keyboard_get_ascii
hid32_keyboard_get_ascii_shift:  .word _hid32_keyboard_get_ascii_shift
_hid32_keyboard_get_ascii: .ascii "\0\0\0\0abcdefghijklmnopqrstuvwxyz1234567890\xD\x1B\x8\x9 -=[]\\#;'`,./"
.space 7 @ Total 64 Bytes (0x40 Bytest)
_hid32_keyboard_get_ascii_shift: .ascii "\0\0\0\0ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()\xD\x1B\x8\x9 _+{}|-:\"~<>?"
.space 7 @ Total 64 Bytes (0x40 Bytest)

