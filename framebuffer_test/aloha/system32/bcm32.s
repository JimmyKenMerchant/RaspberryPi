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
bcm32_mail_contents:
	.word 0x00048003        @ Tag Identifier, Set Physical Width/Height (Size in Physical Display)
	.word 0x00000008        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
BCM32_DISPLAY_WIDTH:
	.word 800               @ Value Buffer, Width in Pixels
BCM32_DISPLAY_HEIGHT:
	.word 640               @ Value Buffer, Height in Pixels
.balign 4
	.word 0x00048004        @ Tag Identifier, Set Virtual Width/Height (Actual Buffer Size just like Viewport in OpenGL)
	.word 0x00000008        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
BCM32_WIDTH:
	.word 800               @ Value Buffer, Width in Pixels
BCM32_HEIGHT:
	.word 640               @ Value Buffer, Height in Pixels
.balign 4
	.word 0x00048005        @ Tag Identifier, Set Depth
	.word 0x00000004        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
BCM32_DEPTH:
	.word 16                @ Value Buffer, Bits per Pixel, 32 would be 32 ARGB
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

bcm32_mail_getedid:          @ get EDID (Extended Display Identification Data) from Disply to Get Display Resolution ,etc.
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

bcm32_mail_framebuffer_addr:
	.word bcm32_mail_framebuffer  @ Address of bcm32_mail_framebuffer
bcm32_mail_blankon_addr:
	.word bcm32_mail_blankon      @ Address of bcm32_mail_blankon
bcm32_mail_blankoff_addr:
	.word bcm32_mail_blankoff     @ Address of bcm32_mail_blankoff
bcm32_mail_getedid_addr:
	.word bcm32_mail_getedid      @ Address of bcm32_mail_getedid
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
	memorymap_base    .req r0
	temp              .req r1

	ldr temp, bcm32_mail_framebuffer_addr
	add temp, temp, #equ32_mailbox_gpuoffset|equ32_mailbox_channel8

	push {r0-r3,lr}
	mov r0, temp
	bl bcm32_mailbox_send
	bl bcm32_mailbox_read
	pop {r0-r3,lr}

	dsb

	ldr memorymap_base, bcm32_mail_framebuffer_addr
	ldr temp, bcm32_mail_framebuffer                                @ Get Size
	add temp, temp, memorymap_base

	bcm32_get_framebuffer_loop:
		push {r0-r3,lr}
		mov r0, memorymap_base
		mov r1, #1
		mov r2, #0                                              @ Invalidate
		bl system32_cache_operation
		pop {r0-r3,lr}
		add memorymap_base, memorymap_base, #4
		cmp memorymap_base, temp
		blt bcm32_get_framebuffer_loop

	dsb
	isb

 	ldr memorymap_base, bcm32_mail_framebuffer_addr
	ldr temp, [memorymap_base, #equ32_mailbox_gpuconfirm]
	cmp temp, #0x80000000
	bne bcm32_get_framebuffer_error

	ldr memorymap_base, BCM32_ADDRESS
	cmp memorymap_base, #0
	beq bcm32_get_framebuffer_error

	ldr temp, bcm32_FB32_FRAMEBUFFER_addr
	ldr temp, [temp]

	and memorymap_base, memorymap_base, #equ32_fb_armmask            @ Change FB32_ADDRESS VideoCore's to ARM's
	str memorymap_base, [temp]

	ldr memorymap_base, BCM32_WIDTH
	str memorymap_base, [temp, #4]

	ldr memorymap_base, BCM32_HEIGHT
	str memorymap_base, [temp, #8]

	ldr memorymap_base, BCM32_SIZE
	str memorymap_base, [temp, #12]

	ldr memorymap_base, BCM32_DEPTH
	str memorymap_base, [temp, #16]

	dsb

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
		dsb                                  @ Ensure Completion of Instructions Before
		isb                                  @ Flush Instructions in Pipeline
		mov pc, lr

.unreq memorymap_base
.unreq temp


/**
 * function bcm32_mailbox_read
 * Wait and Read Mail from VideoCore IV (Mailbox0 on Old System Only)
 * This function is using a vendor-implemented process.
 *
 * Usage: r0-r3
 * Return: r0 Reply Content, r1 (0 as success, 1 as error), 
 * Error: Number of Mailbox does not exist
 */
.globl bcm32_mailbox_read
bcm32_mailbox_read:
	/* Auto (Local) Variables, but just aliases */
	memorymap_base  .req r0
	temp            .req r1
	status          .req r2
	read            .req r3

	mov status, #equ32_mailbox0_status
	mov read, #equ32_mailbox0_read

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_mailbox_base

	dsb
	isb

	bcm32_mailbox_read_waitforread:
		ldr temp, [memorymap_base, status]
		cmp temp, #0x40000000                  @ Wait for Empty Flag is Cleared
		beq bcm32_mailbox_read_waitforread

	dsb                                      @ `DMB` Data Memory Barrier, completes all memory access before
        isb                                      @ `DSB` Data Synchronization Barrier, completes all instructions before
                                                 @ `ISB` Instruction Synchronization Barrier, flushes the pipeline before,
                                                 @ to ensure to fetch data from cache/ memory
                                                 @ These are useful in multi-core/ threads usage, etc.

	ldr r0, [memorymap_base, read]

	dsb
	isb

	b bcm32_mailbox_read_success

	bcm32_mailbox_read_error:
		mov r0, #0
		mov r1, #1
		b bcm32_mailbox_read_common

	bcm32_mailbox_read_success:
		mov r1, #0

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
	/* Auto (Local) Variables, but just aliases */
	mail_content    .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	memorymap_base  .req r1
	temp            .req r2
	status          .req r3
	write           .req r4

	push {r4}

	mov status, #equ32_mailbox0_status
	mov write, #equ32_mailbox0_write

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_mailbox_base

	dsb
	isb

	bcm32_mailbox_send_waitforwrite:
		ldr temp, [memorymap_base, status]
		cmp temp, #0x80000000                  @ Wait for Full Flag is Cleared
		beq bcm32_mailbox_send_waitforwrite

	dsb
	isb

	str mail_content, [memorymap_base, write]

	dsb
	isb

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
