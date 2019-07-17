/**
 * bcm32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

.section	.data

/* Frame Buffer Physical */

.balign 16                      @ Need of 16 bytes align, otherwise, you can't get Framebuffer from VideoCoreIV
.globl BCM32_DISPLAY_WIDTH
.globl BCM32_DISPLAY_HEIGHT
.globl BCM32_WIDTH
.globl BCM32_HEIGHT
.globl BCM32_DEPTH
.globl BCM32_PIXELORDER
.globl BCM32_ALPHAMODE
.globl BCM32_ADDRESS
.globl BCM32_SIZE
bcm32_mail_framebuffer:
	.word bcm32_mail_framebuffer_end - bcm32_mail_framebuffer @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00048003        @ Tag Identifier, Set Physical Width/Height (Size in Physical Display)
	.word 0x00000008        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
BCM32_DISPLAY_WIDTH:
	.word equ32_bcm32_display_width  @ Value Buffer, Width in Pixels
BCM32_DISPLAY_HEIGHT:
	.word equ32_bcm32_display_height @ Value Buffer, Height in Pixels
.balign 4
	.word 0x00048004        @ Tag Identifier, Set Virtual Width/Height (Actual Buffer Size just like Viewport in OpenGL)
	.word 0x00000008        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
BCM32_WIDTH:
	.word equ32_bcm32_width  @ Value Buffer, Width in Pixels
BCM32_HEIGHT:
	.word equ32_bcm32_height @ Value Buffer, Height in Pixels
.balign 4
	.word 0x00048005        @ Tag Identifier, Set Depth
	.word 0x00000004        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
BCM32_DEPTH:
	.word equ32_bcm32_alpha @ Value Buffer, Bits per Pixel, 32 would be 32 ARGB
.balign 4
	.word 0x00048006        @ Tag Identifier, Set Pixel Order
	.word 0x00000004        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
BCM32_PIXELORDER:
	.word 0x01              @ 0x00 is BGR, 0x01 is RGB
.balign 4
	.word 0x00048007        @ Tag Identifier, Set Alpha Mode (This Value is just for INNER of VideoCore, NOT CPU SIDE)
	.word 0x00000004        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
BCM32_ALPHAMODE:
	.word 0x00              @ 0x00 is Enabled(0:Fully Opaque<exist>), 0x01 is Reversed(0:Fully Transparent), 0x02 is Ignored
.balign 4
	.word 0x00040001        @ Tag Identifier, Allocate Buffer
	.word 0x00000008        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
BCM32_ADDRESS:
	.word 0x00000000        @ Value Buffer, Alignment in Bytes (in Response, Frame Buffer Base Address in Bytes)
BCM32_SIZE:
	.word 0x00000000        @ Value Buffer, Reserved for Response (in Response, Frame Buffer Size in Bytes)
.balign 4
	.word 0x00000000        @ End Tag
bcm32_mail_framebuffer_end:

.balign 16
bcm32_mail_unframebuffer:   @ Release Framebuffer
	.word bcm32_mail_unframebuffer_end - bcm32_mail_unframebuffer @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00048001        @ Tag Identifier, Release Framebuffer
	.word 0x00000000        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
.balign 4
	.word 0x00000000        @ End Tag
bcm32_mail_unframebuffer_end:

.balign 16
.globl BCM32_CELCIUS
bcm32_mail_getcelcius:      @ Get Temperature in Celcius
	.word bcm32_mail_getcelcius_end - bcm32_mail_getcelcius @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00030006        @ Tag Identifier, Get Temperature
	.word 0x00000008        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
	.word 0x00000000        @ Temperature ID (Always 0)
BCM32_CELCIUS:
	.word 0x00000000        @ Temperature in Millidegree Celcius
.balign 4
	.word 0x00000000        @ End Tag
bcm32_mail_getcelcius_end:

.balign 16
.globl BCM32_MAXCELCIUS
bcm32_mail_getmaxcelcius:   @ Get Max Temperature in Celcius
	.word bcm32_mail_getmaxcelcius_end - bcm32_mail_getmaxcelcius @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x0003000A        @ Tag Identifier, Get Maximum Temperature
	.word 0x00000008        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
	.word 0x00000000        @ Temperature ID (Always 0)
BCM32_MAXCELCIUS:
	.word 0x00000000        @ Temperature in Millidegree Celcius
.balign 4
	.word 0x00000000        @ End Tag
bcm32_mail_getmaxcelcius_end:

.balign 16
.globl BCM32_VOLTAGE
bcm32_mail_getvoltage:      @ Get Voltage
	.word bcm32_mail_getvoltage_end - bcm32_mail_getvoltage @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00030003        @ Tag Identifier, Get Voltage (0x00030005 is Maximum, 0x00030008 is Minimum, 0x00038003 is Set)
	.word 0x00000008        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
	.word 0x00000001        @ Voltage ID (1 Core, 2 SDRAM_C[Controller], 3 SDRAM_P[Physical], 4 SDRAM_I[I/O])
BCM32_VOLTAGE:
	.word 0x00000000        @ Voltage in Microvolt
.balign 4
	.word 0x00000000        @ End Tag
bcm32_mail_getvoltage_end:

.balign 16
.globl BCM32_CLOCKRATE
bcm32_mail_getclockrate:    @ Get Clock Rate
	.word bcm32_mail_getclockrate_end - bcm32_mail_getclockrate @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00030002        @ Tag Identifier, Get Clock Rate (0x00030004 is Get Maximum)
	.word 0x00000008        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
	.word 0x00000001        @ Clock ID (1 EMMC, 2 UART, 3 ARM, 4 Core, 5 V3D, 6 H264, 7 ISP, 8 SDRAM, 9 PIXEL, A PWM)
BCM32_CLOCKRATE:
	.word 0x00000000        @ Clock Rate in Herts
.balign 4
	.word 0x00000000        @ End Tag
bcm32_mail_getclockrate_end:

.balign 16
bcm32_mail_blank:           @ Blank Screen
	.word bcm32_mail_blank_end - bcm32_mail_blank @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00040002        @ Tag Identifier, Blank Screen
	.word 0x00000004        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
	.word 0x00000000        @ Value Buffer, State (1 means off, 0 means on)
.balign 4
	.word 0x00000000        @ End Tag
bcm32_mail_blank_end:

.balign 16
bcm32_mail_getedid:         @ get EDID (Extended Display Identification Data) from Disply to Get Display Resolution ,etc.
	.word bcm32_mail_getedid_end - bcm32_mail_getedid @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00030020        @ Tag Identifier, get EDID
	.word 0x00000136        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
	.word 0x00000000        @ EDID Block Number Requested/ Responded
	.word 0x00000000        @ Status
.fill 128, 1, 0x00          @ 128 * 1 byte EDID Block
.balign 4
	.word 0x00000000        @ End Tag
bcm32_mail_getedid_end:

.balign 16
bcm32_mail_setpowerstate:   @ Set Power State of Peripheral Devices
	.word bcm32_mail_setpowerstate_end - bcm32_mail_setpowerstate @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00028001        @ Tag Identifier, Set PowerState: 0x00028001; Get PowerState: 0x00020001; Get Timing: 0x00020002
	.word 0x00000008        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
	.word 0x00000000        @ DeviceID, 0x0:SDCard,0x1:UART0,0x2:UART1,0x3:USBHCD,0x4:I2C0,0x5:I2C1,0x6:I2C2,0x7:SPI,0x8:CCP2TX (= Compact Camera Port 2)
	.word 0x00000000        @ State, Bit[0]: 0 off, 1 on; Bit[1]: (Req 0 No Wait, 1 Wait), (Res 0 Device Exists, 1 Device No Exists)
.balign 4
	.word 0x00000000        @ End Tag
bcm32_mail_setpowerstate_end:

.balign 16
.globl BCM32_ARMMEMORY_BASE
.globl BCM32_ARMMEMORY_SIZE
bcm32_mail_getarmmemory:    @ Get ARM Memory
	.word bcm32_mail_getarmmemory_end - bcm32_mail_getarmmemory @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00010005        @ Tag Identifier, Get ARM Memory
	.word 0x00000008        @ Value Buffer Size in Bytes, Request 0 Bytes, Response 8 Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
BCM32_ARMMEMORY_BASE:
	.word 0x00000000        @ Base Address in Response
BCM32_ARMMEMORY_SIZE:
	.word 0x00000000        @ Size (Bytes) in Response
.balign 4
	.word 0x00000000        @ End Tag
bcm32_mail_getarmmemory_end:

.balign 16
.globl BCM32_VCMEMORY_BASE
.globl BCM32_VCMEMORY_SIZE
bcm32_mail_getvcmemory:    @ Get VideoCore Memory
	.word bcm32_mail_getvcmemory_end - bcm32_mail_getvcmemory @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00010006        @ Tag Identifier, Get VideoCore Memory
	.word 0x00000008        @ Value Buffer Size in Bytes, Request 0 Bytes, Response 8 Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
BCM32_VCMEMORY_BASE:
	.word 0x00000000        @ Base Address in Response
BCM32_VCMEMORY_SIZE:
	.word 0x00000000        @ Size (Bytes) in Response
.balign 4
	.word 0x00000000        @ End Tag
bcm32_mail_getvcmemory_end:

.balign 16
.globl BCM32_GENERIC0
.globl BCM32_GENERIC1
.globl BCM32_GENERIC2
.globl BCM32_GENERIC3
.globl BCM32_GENERIC4
.globl BCM32_GENERIC5
bcm32_mail_generic:    @ For Getting Up to 8 Bytes Response
	.word bcm32_mail_generic_end - bcm32_mail_generic @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00000000        @ Any Tag Identifier
	.word 0x00000000        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
BCM32_GENERIC0:
	.word 0x00000000        @ First 4 Bytes Response
BCM32_GENERIC1:
	.word 0x00000000        @ Second 4 Bytes Response
BCM32_GENERIC2:
	.word 0x00000000        @ Third 4 Bytes Response
BCM32_GENERIC3:
	.word 0x00000000        @ Fourth 4 Bytes Response
BCM32_GENERIC4:
	.word 0x00000000        @ Fifth 4 Bytes Response
BCM32_GENERIC5:
	.word 0x00000000        @ Sixth 4 Bytes Response
.balign 4
	.word 0x00000000        @ End Tag
bcm32_mail_generic_end:

.section 	.vendor_system32

/* Pointers */
.balign 4
bcm32_mail_framebuffer_addr:
	.word bcm32_mail_framebuffer   @ Address of bcm32_mail_framebuffer
bcm32_mail_unframebuffer_addr:
	.word bcm32_mail_unframebuffer @ Address of bcm32_mail_unframebuffer
bcm32_mail_getcelcius_addr:
	.word bcm32_mail_getcelcius    @ Address of bcm32_mail_getcelcius
bcm32_mail_getmaxcelcius_addr:
	.word bcm32_mail_getmaxcelcius @ Address of bcm32_mail_getmaxcelcius
bcm32_mail_getvoltage_addr:
	.word bcm32_mail_getvoltage    @ Address of bcm32_mail_getvoltage
bcm32_mail_getclockrate_addr:
	.word bcm32_mail_getclockrate  @ Address of bcm32_mail_getclockrate
bcm32_mail_blank_addr:
	.word bcm32_mail_blank         @ Address of bcm32_mail_blank
bcm32_mail_getedid_addr:
	.word bcm32_mail_getedid       @ Address of bcm32_mail_getedid
bcm32_mail_setpowerstate_addr:
	.word bcm32_mail_setpowerstate @ Address of bcm32_mail_setpowerstate
bcm32_mail_getarmmemory_addr:
	.word bcm32_mail_getarmmemory  @ Address of bcm32_mail_getarmmemory
bcm32_mail_getvcmemory_addr:
	.word bcm32_mail_getvcmemory   @ Address of bcm32_mail_getvcmemory
bcm32_mail_generic_addr:
	.word bcm32_mail_generic       @ Address of bcm32_mail_generic

bcm32_FB32_FRAMEBUFFER_addr:
	.word FB32_FRAMEBUFFER

.globl BCM32_EDID_ADDR
BCM32_EDID_ADDR:
	.word bcm32_mail_getedid + 20


/**
 * function bcm32_get_framebuffer
 * Get Framebuffer from VideoCore IV
 * This function is using a vendor-implemented process.
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): When Framebuffer is not Defined
 */
.globl bcm32_get_framebuffer
bcm32_get_framebuffer:
	/* Auto (Local) Variables, but just Aliases */
	mail_address .req r0
	fb_address   .req r1
	temp         .req r2

	push {lr}

	ldr mail_address, bcm32_mail_framebuffer_addr
	mov temp, #0
	str temp, [mail_address, #36]                  @ Reset Additional Tag
	str temp, [mail_address, #56]                  @ Reset Additional Tag
	str temp, [mail_address, #72]                  @ Reset Additional Tag
	str temp, [mail_address, #88]                  @ Reset Additional Tag
	str temp, [mail_address, #104]                 @ Reset Additional Tag

	macro32_dsb ip

	push {r0-r2}
	bl bcm32_onemail
	cmp r0, #0
	pop {r0-r2}

	bne bcm32_get_framebuffer_error

	ldr temp, [mail_address, #108]                 @ BCM32_ADDRESS
	cmp temp, #0
	beq bcm32_get_framebuffer_error

	ldr fb_address, bcm32_FB32_FRAMEBUFFER_addr
	ldr fb_address, [fb_address]

	and temp, temp, #bcm32_mailbox_armmask         @ Change BCM32_ADDRESS VideoCore's to ARM's
	str temp, [fb_address]

	ldr temp, [mail_address, #40]                  @ BCM32_WIDTH
	str temp, [fb_address, #4]

	ldr temp, [mail_address, #44]                  @ BCM32_HEIGHT
	str temp, [fb_address, #8]

	ldr temp, [mail_address, #112]                 @ BCM32_SIZE
	str temp, [fb_address, #12]

	ldr temp, [mail_address, #60]                  @ BCM32_DEPTH
	str temp, [fb_address, #16]

	macro32_dsb ip

	mov r0, fb_address
	bl fb32_attach_buffer
	cmp r0, #0
	bne bcm32_get_framebuffer_error

	mov r0, #0                                     @ Return with Success

	b bcm32_get_framebuffer_common

	bcm32_get_framebuffer_error:
		mov r0, #1                             @ Return with Error

	bcm32_get_framebuffer_common:
		macro32_dsb ip                             @ Ensure Completion of Instructions Before
		pop {pc}

.unreq mail_address
.unreq fb_address
.unreq temp


/**
 * function bcm32_release_framebuffer
 * Release Framebuffer from VideoCore IV
 * This function is using a vendor-implemented process.
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Error in Response
 */
.globl bcm32_release_framebuffer
bcm32_release_framebuffer:
	/* Auto (Local) Variables, but just Aliases */
	addr_tag .req r0

	push {lr}

	ldr addr_tag, bcm32_mail_unframebuffer_addr

	macro32_dsb ip

	bl bcm32_onemail

	bcm32_release_framebuffer_common:
		macro32_dsb ip                       @ Ensure Completion of Instructions Before
		pop {pc}

.unreq addr_tag


/**
 * function bcm32_get_celcius
 * Get SoC Temperature in Millidegree Celcius from VideoCore IV
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: 0 as Current Temperature, 1 as Maximum Temperature
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Error in Response
 */
.globl bcm32_get_celcius
bcm32_get_celcius:
	/* Auto (Local) Variables, but just Aliases */
	addr_tag .req r0

	push {lr}

	cmp addr_tag, #0
	ldreq addr_tag, bcm32_mail_getcelcius_addr
	ldrne addr_tag, bcm32_mail_getmaxcelcius_addr

	macro32_dsb ip

	bl bcm32_onemail

	bcm32_get_celcius_common:
		macro32_dsb ip                       @ Ensure Completion of Instructions Before
		pop {pc}

.unreq addr_tag


/**
 * function bcm32_get_voltage
 * Get SoC Voltage in Microvolt from VideoCore IV
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Voltage ID, 1 as Core, 2 as SDRAM_C[Controller], 3 as SDRAM_P[Physical], 4 as SDRAM_I[I/O]
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Error in Response
 */
.globl bcm32_get_voltage
bcm32_get_voltage:
	/* Auto (Local) Variables, but just Aliases */
	addr_tag .req r0
	temp     .req r1

	push {lr}

	mov temp, addr_tag

	ldr addr_tag, bcm32_mail_getvoltage_addr
	str temp, [addr_tag, #20]

	macro32_dsb ip

	bl bcm32_onemail

	bcm32_get_voltage_common:
		macro32_dsb ip                       @ Ensure Completion of Instructions Before
		pop {pc}

.unreq addr_tag
.unreq temp


/**
 * function bcm32_get_clockrate
 * Get Clock Rate in Herts from VideoCore IV
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Clock ID, 0x2 as UART, 0x3 as ARM, 0x4 as Core, 0x5 as V3D, 0x8 as SDRAM, 0xA as PWM
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Error in Response
 */
.globl bcm32_get_clockrate
bcm32_get_clockrate:
	/* Auto (Local) Variables, but just Aliases */
	addr_tag .req r0
	temp     .req r1

	push {lr}

	mov temp, addr_tag

	ldr addr_tag, bcm32_mail_getclockrate_addr
	str temp, [addr_tag, #20]

	macro32_dsb ip

	bl bcm32_onemail

	bcm32_get_clockrate_common:
		macro32_dsb ip                       @ Ensure Completion of Instructions Before
		pop {pc}

.unreq addr_tag
.unreq temp


/**
 * function bcm32_set_powerstate
 * Set Power State of Peripheral Device by Transmitting command to VideocoreIV
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: DeviceID, 0x0:SDCard,0x1:UART0,0x2:UART1,0x3:USBHCD,0x4:I2C0,0x5:I2C1,0x6:I2C2,0x7:SPI,0x8:CCP2TX
 * r1: State, Bit[0]: 0 off, 1 on; Bit[1]: 0 No Wait, 1 Wait
 *
 * Return: r0 (Bit[0]: 0 off, 1 on; Bit[1] 0 Device Exists, 1 Device No Exists)
 * Error(0xFFFFFFFF): Invalid of Mailing
 */
.globl bcm32_set_powerstate
bcm32_set_powerstate:
	/* Auto (Local) Variables, but just Aliases */
	deviceid    .req r0
	state       .req r1
	addr_tag    .req r2
	temp        .req r3

	push {lr}

	ldr addr_tag, bcm32_mail_setpowerstate_addr
	str deviceid, [addr_tag, #20]
	str state, [addr_tag, #24]

	macro32_dsb ip

	push {r0-r2}
	mov r0, addr_tag
	bl bcm32_onemail
	mov temp, r0
	pop {r0-r2}

	cmp temp, #0
	bne bcm32_set_powerstate_error

	ldr r0, [addr_tag, #24]

	b bcm32_set_powerstate_common

	bcm32_set_powerstate_error:
		mvn r0, #0                           @ Return with Error

	bcm32_set_powerstate_common:
		macro32_dsb ip                       @ Ensure Completion of Instructions Before
		pop {pc}

.unreq deviceid
.unreq state
.unreq addr_tag
.unreq temp


/**
 * function bcm32_poweron_usb
 * Power on USB
 * This function is using a vendor-implemented process.
 *
 * Return: r0 (0 ag Success, 1 as Error)
 * Error(1): Powering on USB is not in Success
 */
.globl bcm32_poweron_usb
bcm32_poweron_usb:
	/* Auto (Local) Variables, but just Aliases */
	temp              .req r0

	push {lr}
	
	mov temp, #0x80
	bl bcm32_mailbox_send
	bl bcm32_mailbox_read

	cmp temp, #0x80
	bne bcm32_poweron_usb_error

	b bcm32_poweron_usb_success

	bcm32_poweron_usb_error:
		mov r0, #1                               @ Return with Error
		b bcm32_poweron_usb_common

	bcm32_poweron_usb_success:
		mov r0, #0                               @ Return with Success

	bcm32_poweron_usb_common:
		macro32_dsb ip                           @ Ensure Completion of Instructions Before
		pop {pc}

.unreq temp


/**
 * function bcm32_display_off
 * Display Screen Off
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: 0 as Display On, 1 as Display Off
 *
 * Return: r0 (0 as Success, 1 as Error)
 * Error(1): Request Failures
 */
.globl bcm32_display_off
bcm32_display_off:
	/* Auto (Local) Variables, but just Aliases */
	addr_tag    .req r0
	temp        .req r1

	push {lr}

	mov temp, r0                                 @ Parameter
	
	ldr addr_tag, bcm32_mail_blank_addr
	str temp, [addr_tag, #20]                    @ Set Value

	macro32_dsb ip

	bl bcm32_onemail

	bcm32_display_off_common:
		macro32_dsb ip                           @ Ensure Completion of Instructions Before
		pop {pc}

.unreq addr_tag
.unreq temp


/**
 * function bcm32_get_armmemory
 * Get ARM Memory from VideoCore IV
 * This function is using a vendor-implemented process.
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Request Failures
 */
.globl bcm32_get_armmemory
bcm32_get_armmemory:
	/* Auto (Local) Variables, but just Aliases */
	addr_tag .req r0

	push {lr}

	ldr addr_tag, bcm32_mail_getarmmemory_addr

	macro32_dsb ip

	bl bcm32_onemail

	bcm32_get_armmemory_common:
		macro32_dsb ip                                        @ Ensure Completion of Instructions Before
		pop {pc}

.unreq addr_tag


/**
 * function bcm32_get_vcmemory
 * Get VideoCore Memory from VideoCore IV
 * This function is using a vendor-implemented process.
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Request Failures
 */
.globl bcm32_get_vcmemory
bcm32_get_vcmemory:
	/* Auto (Local) Variables, but just Aliases */
	addr_tag .req r0

	push {lr}

	ldr addr_tag, bcm32_mail_getvcmemory_addr

	macro32_dsb ip

	bl bcm32_onemail

	bcm32_get_vcmemory_common:
		macro32_dsb ip                                        @ Ensure Completion of Instructions Before
		pop {pc}

.unreq addr_tag


/**
 * function bcm32_get_edid
 * Get EDID Information from VideoCore IV
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: EDID Block Number
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Request Failures
 */
.globl bcm32_get_edid
bcm32_get_edid:
	/* Auto (Local) Variables, but just Aliases */
	addr_tag    .req r0
	temp        .req r1
	block       .req r2

	push {lr}

	mov block, addr_tag

	ldr addr_tag, bcm32_mail_getedid_addr
	str block, [addr_tag, #20]                  @ Block Number
	mov temp, #0
	str temp, [addr_tag, #24]                   @ Status

	macro32_dsb ip

	bl bcm32_onemail

	bcm32_get_edid_common:
		macro32_dsb ip                                        @ Ensure Completion of Instructions Before
		pop {pc}

.unreq addr_tag
.unreq temp
.unreq block


/**
 * function bcm32_genericmail
 * Send and Receive Generic Mail Up to 24 Bytes from VideoCore IV
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Tag Identifier
 * r1: Value Buffer Size in Bytes, Up to 24 Bytes
 *
 * Return: r0 (0 as success, 1 as error)
 */
.globl bcm32_genericmail
bcm32_genericmail:
	/* Auto (Local) Variables, but just Aliases */
	addr_tag .req r0
	size     .req r1
	temp     .req r2

	push {lr}

	mov temp, addr_tag
	cmp size, #24
	movhi size, #24

	ldr addr_tag, bcm32_mail_generic_addr
	str temp, [addr_tag, #8]
	str size, [addr_tag, #12]

	macro32_dsb ip

	bl bcm32_onemail

	bcm32_genericmail_common:
		macro32_dsb ip                       @ Ensure Completion of Instructions Before
		pop {pc}

.unreq addr_tag
.unreq size
.unreq temp


/**
 * function bcm32_onemail
 * Send and Read One Tag Mail to Get Parameters, etc.
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Tag Address
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Error in Response
 */
.globl bcm32_onemail
bcm32_onemail:
	/* Auto (Local) Variables, but just Aliases */
	addr_tag     .req r0
	addr_tag_dup .req r1
	temp         .req r2

	push {lr}

	mov addr_tag_dup, addr_tag
	mov temp, #0
	str temp, [addr_tag_dup, #bcm32_mailbox_gpuconfirm] @ Reset Request
	str temp, [addr_tag_dup, #16]                       @ Reset Tag
	ldr temp, [addr_tag_dup]                            @ Get Size
	add temp, addr_tag_dup, temp

	macro32_dsb ip

	bcm32_onemail_loop1:
		macro32_clean_cache addr_tag_dup, ip
		add addr_tag_dup, addr_tag_dup, #4
		cmp addr_tag_dup, temp
		blo bcm32_onemail_loop1

	macro32_dsb ip

	push {r0-r2}
	orr r0, r0, #bcm32_mailbox_gpuoffset|bcm32_mailbox_channel8
	bl bcm32_mailbox_send
	bl bcm32_mailbox_read
	pop {r0-r2}

	macro32_dsb ip

	mov addr_tag_dup, addr_tag
	ldr temp, [addr_tag_dup]                            @ Get Size
	add temp, addr_tag_dup, temp

	macro32_dsb ip

	bcm32_onemail_loop2:
		macro32_invalidate_cache addr_tag_dup, ip
		add addr_tag_dup, addr_tag_dup, #4
		cmp addr_tag_dup, temp
		blo bcm32_onemail_loop2

	macro32_dsb ip

	ldr temp, [addr_tag, #bcm32_mailbox_gpuconfirm]
	cmp temp, #0x80000000
	bne bcm32_onemail_error

	mov r0, #0

	b bcm32_onemail_common

	bcm32_onemail_error:
		mov r0, #1                           @ Return with Error

	bcm32_onemail_common:
		macro32_dsb ip                       @ Ensure Completion of Instructions Before
		pop {pc}

.unreq addr_tag
.unreq addr_tag_dup
.unreq temp


/**
 * function bcm32_mailbox_read
 * Wait and Read Mail from VideoCore IV (Mailbox0 on Old System Only)
 * This function is using a vendor-implemented process.
 *
 * Usage: r0-r3
 * Return: r0 (Reply Content)
 */
.globl bcm32_mailbox_read
bcm32_mailbox_read:
	/* Auto (Local) Variables, but just Aliases */
	memorymap_base  .req r0
	temp            .req r1
	status          .req r2
	read            .req r3

	mov status, #bcm32_mailbox0_status
	mov read, #bcm32_mailbox0_read

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #bcm32_mailbox_base

	macro32_dsb ip

	bcm32_mailbox_read_waitforread:
		ldr temp, [memorymap_base, status]
		tst temp, #0x40000000                  @ Wait for Empty Flag is Cleared
		bne bcm32_mailbox_read_waitforread

	macro32_dsb ip                           @ `DMB` Data Memory Barrier, completes all memory access before
                                             @ `DSB` Data Synchronization Barrier, completes all instructions before
                                             @ `ISB` Instruction Synchronization Barrier, flushes the pipeline before,
                                             @ to ensure fetching instructions from cache/ memory
                                             @ These are useful in multi-core/ threads usage, etc.

	ldr r0, [memorymap_base, read]

	macro32_dsb ip

	bcm32_mailbox_read_common:
		mov pc, lr

.unreq memorymap_base
.unreq temp
.unreq status
.unreq read


/**
 * function bcm32_mailbox_send
 * Wait and Send Mail to VideoCore IV (Mailbox 0 on Old System Only)
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Content of Mail to Send
 *
 * Usage: r0-r4
 * Return: r0 (0 as success, 1 as error)
 * Error: Number of Mailbox does not exist
 */
.globl bcm32_mailbox_send
bcm32_mailbox_send:
	/* Auto (Local) Variables, but just Aliases */
	mail_content    .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	memorymap_base  .req r1
	temp            .req r2
	status          .req r3
	write           .req r4

	push {r4}

	mov status, #bcm32_mailbox0_status
	mov write, #bcm32_mailbox0_write

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #bcm32_mailbox_base

	macro32_dsb ip

	bcm32_mailbox_send_waitforwrite:
		ldr temp, [memorymap_base, status]
		tst temp, #0x80000000                  @ Wait for Full Flag is Cleared
		bne bcm32_mailbox_send_waitforwrite

	macro32_dsb ip

	str mail_content, [memorymap_base, write]

	macro32_dsb ip

	b bcm32_mailbox_send_success

	bcm32_mailbox_send_error:
		mov r0, #1
		b bcm32_mailbox_send_common

	bcm32_mailbox_send_success:
		mov r0, #0

	bcm32_mailbox_send_common:
		pop {r4}
		mov pc, lr

.unreq mail_content
.unreq memorymap_base
.unreq temp
.unreq status
.unreq write

/* Definition Only in ARMv7/AArch32 */
.ifndef __ARMV6

/**
 * function bcm32_route_gpuinterrupt
 * Route GPU IRQ and GPU FIQ to Particular Core
 * This function is using a vendor-implemented process.
 *
 * Parameters
 * r0: Number of Core to Route GPU IRQ
 * r1: Number of Core to Route GPU FIQ
 *
 * Return: r0 (0 as success, 1 as error)
 */
.globl bcm32_route_gpuinterrupt
bcm32_route_gpuinterrupt:
	/* Auto (Local) Variables, but just Aliases */
	core_irq       .req r0
	core_fiq       .req r1
	memorymap_base .req r2

	and core_irq, core_irq, #0b11
	and core_fiq, core_fiq, #0b11
	orr core_irq, core_irq, core_fiq, lsl #2

	mov memorymap_base, #bcm32_cores_base
	add memorymap_base, memorymap_base, #bcm32_cores_gpuinterrupt_routing

	str core_irq, [memorymap_base]

	bcm32_route_gpuinterrupt_common:
		macro32_dsb ip
		mov pc, lr

.unreq core_irq
.unreq core_fiq
.unreq memorymap_base

.endif


.equ bcm32_mailbox_base,          0x0000B800
.equ bcm32_mailbox_channel0,      0x00
.equ bcm32_mailbox_channel1,      0x01
.equ bcm32_mailbox_channel2,      0x02
.equ bcm32_mailbox_channel3,      0x03
.equ bcm32_mailbox_channel4,      0x04
.equ bcm32_mailbox_channel5,      0x05
.equ bcm32_mailbox_channel6,      0x06
.equ bcm32_mailbox_channel7,      0x07
.equ bcm32_mailbox_channel8,      0x08
.equ bcm32_mailbox0_read,         0x80 @ On Old System of Mailbox (from Single Core), Mailbox is only 0-1 accessible.
.equ bcm32_mailbox0_poll,         0x90 @ Because, 0-1 are alternatively connected, e.g., read/write Mapping.
.equ bcm32_mailbox0_sender,       0x94
.equ bcm32_mailbox0_status,       0x98 @ MSB has 0 for sender. Next Bit from MSB has 0 for receiver
.equ bcm32_mailbox0_config,       0x9C
.equ bcm32_mailbox0_write,        0xA0 @ Mailbox 1 Read/ Mailbox 0 Write is the same address
.equ bcm32_mailbox1_read,         0xA0
.equ bcm32_mailbox1_poll,         0xB0
.equ bcm32_mailbox1_sender,       0xB4
.equ bcm32_mailbox1_status,       0xB8 @ MSB has 0 for sender. Next Bit from MSB has 0 for receiver
.equ bcm32_mailbox1_config,       0xBC
.equ bcm32_mailbox1_write,        0x80 @ Mailbox 0 Read/ Mailbox 1 Write is the same address
.equ bcm32_mailbox_gpuconfirm,    0x04
.equ bcm32_mailbox_gpuoffset,     0x40000000 @ If L2 Cache Disabled by `disable_l2cache=1` in config.txt, 0xC0000000
.equ bcm32_mailbox_armmask,       0x3FFFFFFF

/* Definition Only in ARMv7/AArch32 */
.ifndef __ARMV6

.equ bcm32_cores_base,                  0x40000000
.equ bcm32_cores_gpuinterrupt_routing,  0x0C @ Bit[3:2] GPU FIQ Routing, Bit[1:0] GPU IRQ Rouring, Set Core Number
.equ bcm32_core0_irq_source,            0x60 @ Bit[4] Mailbox0, Bit[5] Mailbox1, Bit[6] Mailbox2, Bit[7] Mailbox3
.equ bcm32_core1_irq_source,            0x64
.equ bcm32_core2_irq_source,            0x68
.equ bcm32_core3_irq_source,            0x6C
.equ bcm32_core0_fiq_source,            0x70 @ Bit[4] Mailbox0, Bit[5] Mailbox1, Bit[6] Mailbox2, Bit[7] Mailbox3
.equ bcm32_core1_fiq_source,            0x74
.equ bcm32_core2_fiq_source,            0x78
.equ bcm32_core3_fiq_source,            0x7C

.equ bcm32_cores_mailbox_offset,        0x10 @ Core0 * 0, Core1 * 1, Core2 * 2, Core3 * 3
.equ bcm32_cores_mailbox0_writeset,     0x80
.equ bcm32_cores_mailbox1_writeset,     0x84
.equ bcm32_cores_mailbox2_writeset,     0x88
.equ bcm32_cores_mailbox3_writeset,     0x8C @ Use for Inter-core Communication in RasPi's start.elf
.equ bcm32_cores_mailbox0_readclear,    0xC0 @ Write High to Clear
.equ bcm32_cores_mailbox1_readclear,    0xC4
.equ bcm32_cores_mailbox2_readclear,    0xC8
.equ bcm32_cores_mailbox3_readclear,    0xCC
.equ bcm32_core0_mailboxes_interrupt,   0x50 @ Bit[0]+ Mailbox0+ IRQ Control, Bit[4]+ Mailbox0+ FIQ Control, IRQ Bit (0-3)
.equ bcm32_core1_mailboxes_interrupt,   0x54
.equ bcm32_core2_mailboxes_interrupt,   0x58
.equ bcm32_core3_mailboxes_interrupt,   0x5C

.endif

