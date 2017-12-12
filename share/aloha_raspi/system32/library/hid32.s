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
 * r3: Split Control
 *
 * Return: r0 (Device Address, -1 and -2 as Error)
 * Error(-1): Failed Memory Allocation
 * Error(-2): No HID
 * Error(-3): Failure of Communication (Time Out)
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
	num_interface   .req r9
	addr_device     .req r10
	packet_max      .req r11

	push {r4-r11,lr}

	mov num_config, character
	mov num_interface, transfer_size
	mov split_ctl, buffer_rq

	push {r0-r3}
	mov r0, #10                        @ 4 Bytes by 2 Words Equals 8 Bytes (Plus 8 Words for Alighment)
	bl heap32_malloc
	mov temp, r0
	pop {r0-r3}
	cmp temp, #0
	beq hid32_hid_activate_error1
	mov buffer_rq, temp

	/* DMA Needs DWORD(32 Bytes) aligned */
	push {r0-r3}
	mov r0, buffer_rq
	bl heap32_align_32
	mov temp, r0
	pop {r0-r3}
	cmp temp, #0
	beq hid32_hid_activate_error1
	mov buffer_rq, temp

	push {r0-r3}
	mov r0, #24                        @ 4 Bytes by 16 Words Equals 64 Bytes (Plus 8 Words for Alignment)
	bl heap32_malloc
	mov buffer_rx, r0
	pop {r0-r3}
	cmp buffer_rx, #0
	beq hid32_hid_activate_error1

	/* DMA Needs DWORD(32 Bytes) aligned */
	push {r0-r3}
	mov r0, buffer_rx
	bl heap32_align_32
	mov buffer_rx, r0
	pop {r0-r3}
	cmp buffer_rx, #0
	beq hid32_hid_activate_error1

	/* Get Device Descriptor  */

	mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_device_to_host @ bmRequest Type
	orr temp, temp, #equ32_usb20_req_get_descriptor<<8           @ bRequest
	orr temp, temp, #0<<16                                       @ wValue, Descriptor Index
	orr temp, temp, #equ32_usb20_val_descriptor_device<<16       @ wValue, Descriptor Type
	str temp, [buffer_rq]
	mov temp, #0                                                 @ wIndex
	orr temp, temp, #8<<16                                       @ wLength
	str temp, [buffer_rq, #4]

	mov character, #8                              @ Maximam Packet Size
	orr character, character, #0<<11               @ Endpoint Number
	orr character, character, #1<<15               @ In(1)/Out(0)
	orr character, character, #0<<16               @ Endpoint Type
	orr character, character, #0<<18               @ Device Address
	orr character, character, #1<<25               @ Full and High Speed(0)/Low Speed(1)

	mov transfer_size, #8                          @ Transfer Size is 8 Bytes
	orr transfer_size, transfer_size, #0x00080000  @ Transfer Packet is 1 Packet
	orr transfer_size, transfer_size, #0x40000000  @ Data Type is DATA1, Otherwise, meet Data Toggle Error

	push {r0-r3}
	push {split_ctl,buffer_rx}
	bl usb2032_control
	add sp, sp, #8
	mov response, r0
	mov temp, r1
	pop {r0-r3}

macro32_debug response, 0, 512
macro32_debug temp, 0, 524
macro32_debug_hexa buffer_rx, 0, 536, 64

	ldrb temp, [buffer_rx, #4]
	cmp temp, #0x00                                @ Device Class is HID (on Device Descriptor) or Not
	bne hid32_hid_activate_error2

	ldrb packet_max, [buffer_rx, #7]

	/* Set Address  */

	ldr temp, HID32_USB2032_ADDRESS_LENGTH
	ldr addr_device, [temp] 
	add addr_device, addr_device, #1
	str addr_device, [temp]

macro32_debug addr_device, 0, 300

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

	cmp response, #1
	beq hid32_hid_activate_error3

	/* Set Configuration  */

	mov temp, #equ32_usb20_reqt_recipient_device|equ32_usb20_reqt_type_standard|equ32_usb20_reqt_host_to_device @ bmRequest Type
	orr temp, temp, #equ32_usb20_req_set_configuration<<8        @ bRequest
	orr temp, temp, num_config, lsl #16                          @ wValue, Descriptor Index
	str temp, [buffer_rq]

	orr character, character, addr_device, lsl #18               @ Device Address

	push {r0-r3}
	push {split_ctl,buffer_rx}
	bl usb2032_control
	add sp, sp, #8
	mov response, r0
	mov temp, r1
	pop {r0-r3}

	/* Remote Wakeup  */

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
		mov r0, buffer_rq
		bl heap32_clear_align
		bl heap32_mfree
		pop {r0-r3}

		push {r0-r3}
		mov r0, buffer_rx
		bl heap32_clear_align
		bl heap32_mfree
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
 * r2: Device Address
 * r3: Buffer
 * r4: Split Control
 *
 * Return: r0 (Status of Channel, -1 and -2 as Error)
 * Error(-1): Failed Memory Allocation
 */
.globl hid32_hid_get
hid32_hid_get:
	/* Auto (Local) Variables, but just Aliases */
	channel         .req r0
	character       .req r1
	transfer_size   .req r2
	buffer          .req r3
	split_ctl       .req r4
	response        .req r5
	temp            .req r6
	num_endpoint    .req r7
	addr_device     .req r8

	push {r4-r8,lr}

	add sp, sp, #24                    @ r4-r8 and lr offset 24 bytes
	pop {split_ctl}                    @ Get Fifth Arguments
	sub sp, sp, #28                    @ Retrieve SP

	mov num_endpoint, character
	mov addr_device, transfer_size

	mov character, #8                               @ Maximam Packet Size
	orr character, character, num_endpoint, lsl #11 @ Endpoint Number
	orr character, character, #1<<15                @ In(1)/Out(0)
	orr character, character, #3<<16                @ Endpoint Type
	orr character, character, addr_device, lsl #18  @ Device Address
	orr character, character, #1<<25                @ Full and High Speed(0)/Low Speed(1)

	mov transfer_size, #8                          @ Transfer Size is 8 Bytes
	orr transfer_size, transfer_size, #0x00080000  @ Transfer Packet is 1 Packet
	orr transfer_size, transfer_size, #0x40000000  @ Data Type is DATA1, Otherwise, meet Data Toggle Error

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
