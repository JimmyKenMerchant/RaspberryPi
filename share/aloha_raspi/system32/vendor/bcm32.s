/**
 * bcm32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

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
bcm32_mail_blankon:
	.word bcm32_mail_blankon_end - bcm32_mail_blankon @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00040002        @ Tag Identifier, Blank Screen
	.word 0x00000004        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
	.word 0x00000001        @ Value Buffer, State (0 means off, 1 means on)
.balign 4
	.word 0x00000000        @ End Tag
bcm32_mail_blankon_end:

.balign 16
bcm32_mail_blankoff:
	.word bcm32_mail_blankoff_end - bcm32_mail_blankoff @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00040002        @ Tag Identifier, Blank Screen
	.word 0x00000004        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
	.word 0x00000000        @ Value Buffer, State (0 means off, 1 means on)
.balign 4
	.word 0x00000000        @ End Tag
bcm32_mail_blankoff_end:

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
	.word 0x00000000        @ DeviceID, 0x0:SDCard,0x1:UART0,0x2:UART1,0x3:USBHCD,0x4:I2C0,0x5:I2C1,0x6:I2C2,0x7:SPI,0x8:CCP2TX
	.word 0x00000000        @ State, Bit[0]: 0 off, 1 on; Bit[1]: (Req 0 No Wait, 1 Wait), (Res 0 Device Exists, 1 Device No Exists)
.balign 4
	.word 0x00000000        @ End Tag
bcm32_mail_setpowerstate_end:

/* Pointers */
.balign 4
bcm32_mail_framebuffer_addr:
	.word bcm32_mail_framebuffer   @ Address of bcm32_mail_framebuffer
bcm32_mail_blankon_addr:
	.word bcm32_mail_blankon       @ Address of bcm32_mail_blankon
bcm32_mail_blankoff_addr:
	.word bcm32_mail_blankoff      @ Address of bcm32_mail_blankoff
bcm32_mail_getedid_addr:
	.word bcm32_mail_getedid       @ Address of bcm32_mail_getedid
bcm32_mail_setpowerstate_addr:
	.word bcm32_mail_setpowerstate @ Address of bcm32_mail_setpowerstate

.balign 4
bcm32_FB32_FRAMEBUFFER_addr:
	.word FB32_FRAMEBUFFER

/**
 * function bcm32_get_framebuffer
 * Get Framebuffer from VideoCore IV
 * This function is using a vendor-implemented process.
 *
 * Usage: r0-r1
 * Return: r0 (0 as success, 1 as error)
 * Error(1): When Framebuffer is not Defined
 */
.globl bcm32_get_framebuffer
bcm32_get_framebuffer:
	/* Auto (Local) Variables, but just Aliases */
	memorymap_base    .req r0
	temp              .req r1

	ldr temp, bcm32_mail_framebuffer_addr
	add temp, temp, #bcm32_mailbox_gpuoffset|bcm32_mailbox_channel8

	push {r0-r3,lr}
	mov r0, temp
	bl bcm32_mailbox_send
	bl bcm32_mailbox_read
	pop {r0-r3,lr}

	macro32_dsb ip

	ldr memorymap_base, bcm32_mail_framebuffer_addr
	ldr temp, bcm32_mail_framebuffer                                @ Get Size
	add temp, temp, memorymap_base

	macro32_dsb ip

	bcm32_get_framebuffer_loop:
		macro32_invalidate_cache memorymap_base, ip
		add memorymap_base, memorymap_base, #4
		cmp memorymap_base, temp
		blo bcm32_get_framebuffer_loop

	macro32_dsb ip

 	ldr memorymap_base, bcm32_mail_framebuffer_addr
	ldr temp, [memorymap_base, #bcm32_mailbox_gpuconfirm]
	cmp temp, #0x80000000
	bne bcm32_get_framebuffer_error

	ldr memorymap_base, BCM32_ADDRESS
	cmp memorymap_base, #0
	beq bcm32_get_framebuffer_error

	ldr temp, bcm32_FB32_FRAMEBUFFER_addr
	ldr temp, [temp]

	and memorymap_base, memorymap_base, #bcm32_mailbox_armmask      @ Change BCM32_ADDRESS VideoCore's to ARM's
	str memorymap_base, [temp]

	ldr memorymap_base, BCM32_WIDTH
	str memorymap_base, [temp, #4]

	ldr memorymap_base, BCM32_HEIGHT
	str memorymap_base, [temp, #8]

	ldr memorymap_base, BCM32_SIZE
	str memorymap_base, [temp, #12]

	ldr memorymap_base, BCM32_DEPTH
	str memorymap_base, [temp, #16]

	macro32_dsb ip

	push {r0-r3,lr}
	mov r0, temp
	bl fb32_attach_buffer
	cmp r0, #0
	pop {r0-r3,lr}
	bne bcm32_get_framebuffer_error

	mov r0, #0                               @ Return with Success

	b bcm32_get_framebuffer_common

	bcm32_get_framebuffer_error:
		mov r0, #1                           @ Return with Error

	bcm32_get_framebuffer_common:
		macro32_dsb ip                                     @ Ensure Completion of Instructions Before
		mov pc, lr

.unreq memorymap_base
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
 * Usage: r0-r1
 * Return: r0 (Bit[0]: 0 off, 1 on; Bit[1] 0 Device Exists, 1 Device No Exists)
 * Error(0xFFFFFFFF): Invalid of Mailing
 */
.globl bcm32_set_powerstate
bcm32_set_powerstate:
	/* Auto (Local) Variables, but just Aliases */
	deviceid          .req r0
	state             .req r1
	memorymap_base    .req r2
	temp              .req r3

	ldr memorymap_base, bcm32_mail_setpowerstate_addr
	ldr temp, bcm32_mail_setpowerstate                          @ Get Size
	add temp, temp, memorymap_base

	str deviceid, [memorymap_base, #20]	
	str state, [memorymap_base, #24]

	macro32_dsb ip

	bcm32_set_powerstate_loop1:
		macro32_clean_cache memorymap_base, ip
		add memorymap_base, memorymap_base, #4
		cmp memorymap_base, temp
		blo bcm32_set_powerstate_loop1

	macro32_dsb ip
	
	ldr temp, bcm32_mail_setpowerstate_addr
	add temp, temp, #bcm32_mailbox_gpuoffset|bcm32_mailbox_channel8

	push {r0-r3,lr}
	mov r0, temp
	bl bcm32_mailbox_send
	bl bcm32_mailbox_read
	pop {r0-r3,lr}

	macro32_dsb ip

	ldr memorymap_base, bcm32_mail_setpowerstate_addr
	ldr temp, bcm32_mail_setpowerstate                          @ Get Size
	add temp, temp, memorymap_base

	macro32_dsb ip

	bcm32_set_powerstate_loop2:
		macro32_invalidate_cache memorymap_base, ip
		add memorymap_base, memorymap_base, #4
		cmp memorymap_base, temp
		blo bcm32_set_powerstate_loop2

	macro32_dsb ip

 	ldr memorymap_base, bcm32_mail_setpowerstate_addr
	ldr temp, [memorymap_base, #bcm32_mailbox_gpuconfirm]
	cmp temp, #0x80000000
	bne bcm32_set_powerstate_error

	ldr r0, [memorymap_base, #24]

	b bcm32_set_powerstate_common

	bcm32_set_powerstate_error:
		mvn r0, #0                           @ Return with Error

	bcm32_set_powerstate_common:
		macro32_dsb ip                           @ Ensure Completion of Instructions Before
		mov pc, lr

.unreq deviceid
.unreq state
.unreq memorymap_base
.unreq temp


/**
 * function bcm32_poweron_usb
 * Power on USB
 * This function is using a vendor-implemented process.
 *
 * Usage: r0-r1
 * Return: r0 (0 as Success, 1 as Error)
 * Error(1): Powering on USB is not in Success
 */
.globl bcm32_poweron_usb
bcm32_poweron_usb:
	/* Auto (Local) Variables, but just Aliases */
	temp              .req r0
	temp2             .req r4

	push {r4}
	
	mov temp, #0x80

	push {r0-r3,lr}
	mov r0, temp
	bl bcm32_mailbox_send
	bl bcm32_mailbox_read
	mov temp2, r0
	pop {r0-r3,lr}

	cmp temp2, #0x80
	bne bcm32_poweron_usb_error

	mov r0, #0                                       @ Return with Success
	b bcm32_poweron_usb_common

	bcm32_poweron_usb_error:
		mov r0, #1                               @ Return with Error

	bcm32_poweron_usb_common:
		macro32_dsb ip                           @ Ensure Completion of Instructions Before
		pop {r4}
		mov pc, lr

.unreq temp
.unreq temp2


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

.equ bcm32_mailbox_base,         0x0000B800
.equ bcm32_mailbox_channel0,     0x00
.equ bcm32_mailbox_channel1,     0x01
.equ bcm32_mailbox_channel2,     0x02
.equ bcm32_mailbox_channel3,     0x03
.equ bcm32_mailbox_channel4,     0x04
.equ bcm32_mailbox_channel5,     0x05
.equ bcm32_mailbox_channel6,     0x06
.equ bcm32_mailbox_channel7,     0x07
.equ bcm32_mailbox_channel8,     0x08
.equ bcm32_mailbox0_read,        0x80 @ On Old System of Mailbox (from Single Core), Mailbox is only 0-1 accessible.
.equ bcm32_mailbox0_poll,        0x90 @ Because, 0-1 are alternatively connected, e.g., read/write Mapping.
.equ bcm32_mailbox0_sender,      0x94
.equ bcm32_mailbox0_status,      0x98 @ MSB has 0 for sender. Next Bit from MSB has 0 for receiver
.equ bcm32_mailbox0_config,      0x9C
.equ bcm32_mailbox0_write,       0xA0 @ Mailbox 1 Read/ Mailbox 0 Write is the same address
.equ bcm32_mailbox1_read,        0xA0
.equ bcm32_mailbox1_poll,        0xB0
.equ bcm32_mailbox1_sender,      0xB4
.equ bcm32_mailbox1_status,      0xB8 @ MSB has 0 for sender. Next Bit from MSB has 0 for receiver
.equ bcm32_mailbox1_config,      0xBC
.equ bcm32_mailbox1_write,       0x80 @ Mailbox 0 Read/ Mailbox 1 Write is the same address
.equ bcm32_mailbox_gpuconfirm,   0x04
.equ bcm32_mailbox_gpuoffset,    0x40000000 @ If L2 Cache Disabled by `disable_l2cache=1` in config.txt, 0xC0000000
.equ bcm32_mailbox_armmask,      0x3FFFFFFF

.equ bcm32_cores_base,                  0x40000000
.equ bcm32_cores_mailbox_offset,        0x10 @ Core0 * 0, Core1 * 1, Core2 * 2, Core3 * 3
.equ bcm32_cores_mailbox0_writeset,     0x80
.equ bcm32_cores_mailbox1_writeset,     0x84
.equ bcm32_cores_mailbox2_writeset,     0x88
.equ bcm32_cores_mailbox3_writeset,     0x8C @ Use for Inter-core Communication in RasPi's start.elf
.equ bcm32_cores_mailbox0_readclear,    0xC0 @ Write Hight to Clear
.equ bcm32_cores_mailbox1_readclear,    0xC4
.equ bcm32_cores_mailbox2_readclear,    0xC8
.equ bcm32_cores_mailbox3_readclear,    0xCC
.equ bcm32_core0_mailboxes_interrupt,   0x50 @ Bit[0]+ Mailbox0+ IRQ Control, Bit[4]+ Mailbox0+ FIQ Control, IRQ Bit (0-3)
.equ bcm32_core1_mailboxes_interrupt,   0x54
.equ bcm32_core2_mailboxes_interrupt,   0x58
.equ bcm32_core3_mailboxes_interrupt,   0x5C

.equ bcm32_core0_irq_source,   0x60 @ Bit[4] Mailbox0, Bit[5] Mailbox1, Bit[6] Mailbox2, Bit[7] Mailbox3
.equ bcm32_core1_irq_source,   0x64
.equ bcm32_core2_irq_source,   0x68
.equ bcm32_core3_irq_source,   0x6C
.equ bcm32_core0_fiq_source,   0x70 @ Bit[4] Mailbox0, Bit[5] Mailbox1, Bit[6] Mailbox2, Bit[7] Mailbox3
.equ bcm32_core1_fiq_source,   0x74
.equ bcm32_core2_fiq_source,   0x78
.equ bcm32_core3_fiq_source,   0x7C
