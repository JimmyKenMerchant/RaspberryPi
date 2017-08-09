/**
 * framebuffer32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * Aliases
 */
.equ mail_confirm,             0x04
.equ mailbox_gpuoffset,        0x40000000
.equ mailbox_armmask,          0x3FFFFFFF
.equ mailbox_channel8,         0x08
.equ mailbox0_read,            0x00
.equ mailbox0_poll,            0x10
.equ mailbox0_sender,          0x14
.equ mailbox0_status,          0x18         @ MSB has 0 for sender. Next Bit from MSB has 0 for receiver
.equ mailbox0_config,          0x1C
.equ mailbox0_write,           0x20


/**
 * function get_framebuffer
 * Get Framebuffer
 *
 * Usage: r0-r1
 * Return: r0 (0 as sucess, 1 as error)
 * Error(1): When Framebuffer is not Defined
 * Global Enviromental Variable(s): FB_ADDRESS
 * External Variable(s): peripherals_base, mailbox_base, mail_framebuffer_addr
 */
.globl get_framebuffer
get_framebuffer:
	memorymap_base    .req r0
	temp              .req r1

	ldr memorymap_base, peripherals_base
	ldr temp, mailbox_base
	add memorymap_base, memorymap_base, temp

	get_framebuffer_waitforwrite:
		ldr temp, [memorymap_base, #mailbox0_status]
		cmp temp, #0x80000000
		beq get_framebuffer_waitforwrite

	ldr temp, mail_framebuffer_addr
	add temp, temp, #mailbox_gpuoffset|mailbox_channel8
	str temp, [memorymap_base, #mailbox0_write]

	get_framebuffer_waitforread:
		ldr temp, [memorymap_base, #mailbox0_status]
		cmp temp, #0x40000000
		beq get_framebuffer_waitforread

	ldr memorymap_base, mail_framebuffer_addr
	ldr temp, [memorymap_base, #mail_confirm]
	cmp temp, #0x80000000
	bne get_framebuffer_error

	ldr memorymap_base, FB_ADDRESS
	cmp memorymap_base, #0
	beq get_framebuffer_error

	and memorymap_base, memorymap_base, #mailbox_armmask             @ Change FB_ADDRESS VideoCore's to ARM's
	str memorymap_base, FB_ADDRESS                                   @ Store ARM7s FB_ADDRESS

	dmb                                      @ `DMB` Data Memory Barrier, completes all memory access before
                                                 @ `DSB` Data Synchronization Barrier, completes all instructions before
                                                 @ `ISB` Instruction Synchronization Barrier, flushes the pipeline before,
                                                 @ to ensure to fetch data from cache/ memory
                                                 @ These are useful in multi-core/ threads usage, etc.

	mov r0, #0                               @ Return with Success

	b get_framebuffer_common

	get_framebuffer_error:
		mov r0, #1                       @ Return with Error

	get_framebuffer_common:
		mov pc, lr

.unreq memorymap_base
.unreq temp


/**
 * function clear_color
 * Fill Out Framebuffer by Color
 *
 * Parameters
 * r0: Color (16-bit or 32-bit)
 *
 * Usage: r0-r4
 * Return: r0 (0 as sucess, 1 as error)
 * Error(1): When Framebuffer is not Defined
 * Global Enviromental Variable(s): FB_ADDRESS, FB_SIZE, FB_DEPTH
 */
.globl clear_color
clear_color:
	color             .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	fb_buffer         .req r1
	size              .req r2
	depth             .req r3
	length            .req r4

	push {r4}

	ldr fb_buffer, FB_ADDRESS
	cmp fb_buffer, #0
	beq clear_color_error

	ldr size, FB_SIZE
	cmp size, #0
	beq clear_color_error

	ldr depth, FB_DEPTH
	cmp depth, #0
	beq clear_color_error

	cmp depth, #16
	moveq length, #2
	cmp depth, #32
	moveq length, #4

	clear_color_loop:
		cmp depth, #16
		streqh color, [fb_buffer]         @ Store half word
		cmp depth, #32
		streq color, [fb_buffer]          @ Store word
		add fb_buffer, fb_buffer, length
		sub size, size, length
		cmp size, #0
		bgt clear_color_loop

		mov r0, #0                        @ Return with Success
		b clear_color_common

	clear_color_error:
		mov r0, #1                        @ Return with Error

	clear_color_common:
		pop {r4}
		mov pc, lr

.unreq color
.unreq fb_buffer
.unreq size
.unreq depth
.unreq length

/* Indicates Caret Position to Use in Printing Characters */
.balign 4
.globl FB_X_CARET
.globl FB_Y_CARET
FB_X_CARET: .word 0x00000000
FB_Y_CARET: .word 0x00000000

/* Frame Buffer Physical */

.balign 16                      @ Need of 16 bytes align
.globl FB_DISPLAY_WIDTH
.globl FB_DISPLAY_HEIGHT
.globl FB_WIDTH
.globl FB_HEIGHT
.globl FB_DEPTH
.globl FB_ADDRESS
.globl FB_ADDRESS
.globl FB_SIZE
mail_framebuffer:
	.word mail_framebuffer_end - mail_framebuffer @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
mail_contents:
	.word 0x00048003        @ Tag Identifier, Set Physical Width/Height (Size in Physical Display)
	.word 0x00000008        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
FB_DISPLAY_WIDTH:
	.word 800               @ Value Buffer, Width in Pixels
FB_DISPLAY_HEIGHT:
	.word 640               @ Value Buffer, Height in Pixels
.balign 4
	.word 0x00048004        @ Tag Identifier, Set Virtual Width/Height (Actual Buffer Size just like Viewport in OpenGL)
	.word 0x00000008        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
FB_WIDTH:
	.word 800               @ Value Buffer, Width in Pixels
FB_HEIGHT:
	.word 640               @ Value Buffer, Height in Pixels
.balign 4
	.word 0x00048005        @ Tag Identifier, Set Depth
	.word 0x00000004        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
FB_DEPTH:
	.word 16                @ Value Buffer, Bits per Pixel, 32 would be 32 RGBA
.balign 4
	.word 0x00040001        @ Tag Identifier, Allocate Buffer
	.word 0x00000008        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
FB_ADDRESS:
	.word 0x00000000        @ Value Buffer, Alignment in Bytes (in Response, Frame Buffer Base Address in Bytes)
FB_SIZE:
	.word 0x00000000        @ Value Buffer, Reserved for Response (in Response, Frame Buffer Size in Bytes)
.balign 4
	.word 0x00000000        @ End Tag
mail_framebuffer_end:
.balign 16

mail_blankon:
	.word mail_blankon_end - mail_blankon @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00040002        @ Tag Identifier, Blank Screen
	.word 0x00000004        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
	.word 0x00000001        @ Value Buffer, State (0 means off, 1 means on)
.balign 4
	.word 0x00000000        @ End Tag
mail_blankon_end:
.balign 16

mail_blankoff:
	.word mail_blankoff_end - mail_blankoff @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00040002        @ Tag Identifier, Blank Screen
	.word 0x00000004        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
	.word 0x00000000        @ Value Buffer, State (0 means off, 1 means on)
.balign 4
	.word 0x00000000        @ End Tag
mail_blankoff_end:
.balign 16

mail_framebuffer_addr:
	.word mail_framebuffer  @ Address of mail_framebuffer
mail_blankon_addr:
	.word mail_blankon      @ Address of mail_blankon
mail_blankoff_addr:
	.word mail_blankoff     @ Address of mail_blankoff
.balign 4
