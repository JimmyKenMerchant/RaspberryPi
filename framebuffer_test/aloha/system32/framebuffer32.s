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
 * function fb32_copy
 * Copy Framebuffer to Renderbuffer
 *
 * Parameters
 * r0: Pointer of Renderbuffer
 *
 * Usage: r0-r5
 * Return: r0 (0 as sucess, 1 as error)
 * Error(1): When Framebuffer is not Defined
 * Global Enviromental Variable(s): FB_ADDRESS, FB_SIZE, FB_DEPTH
 */
.globl fb32_copy
fb32_copy:
	render_buffer     .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	fb_buffer         .req r1
	size              .req r2
	depth             .req r3
	length            .req r4
	color             .req r5

	push {r4-r5}

	ldr fb_buffer, FB_ADDRESS
	cmp fb_buffer, #0
	beq fb32_copy_error

	ldr size, FB_SIZE
	cmp size, #0
	beq fb32_copy_error

	ldr depth, FB_DEPTH
	cmp depth, #0
	beq fb32_copy_error

	cmp depth, #16
	moveq length, #2
	cmp depth, #32
	moveq length, #4

	fb32_copy_loop:
		cmp depth, #16
		ldreqh color, [fb_buffer]                @ Store half word
		streqh color, [render_buffer]            @ Store half word
		cmp depth, #32
		ldreq color, [fb_buffer]                 @ Store word
		streq color, [render_buffer]             @ Store word
		add fb_buffer, fb_buffer, length
		add render_buffer, render_buffer, length
		sub size, size, length
		cmp size, #0
		bgt fb32_copy_loop

		mov r0, #0                               @ Return with Success
		b fb32_copy_common

	fb32_copy_error:
		mov r0, #1                               @ Return with Error

	fb32_copy_common:
		pop {r4-r5}
		mov pc, lr

.unreq render_buffer
.unreq fb_buffer
.unreq size
.unreq depth
.unreq length
.unreq color


/**
 * function fb32_draw_image
 * Draw Image
 *
 * Parameters
 * r0: Pointer of Image
 * r1: X Coordinate
 * r2: Y Coordinate
 * r3: Character Width in Pixels
 * r4: Character Height in Pixels
 * (Callee ip, Caller r5): X Offset
 * (Callee ip, Caller r6): Y Offset
 *
 * Usage: r0-r11
 * Return: r0 (0 as sucess, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 * Global Enviromental Variable(s): FB_ADDRESS, FB_WIDTH, FB_SIZE, FB_DEPTH
 */
.globl fb32_draw_image
fb32_draw_image:
	/* Auto (Local) Variables, but just aliases */
	image_point      .req r0  @ Parameter, Register for Argument and Result, Scratch Register
	x_coord          .req r1  @ Parameter, Register for Argument and Result, Scratch Register
	y_coord          .req r2  @ Parameter, Register for Argument, Scratch Register
	char_width       .req r3  @ Parameter, have to PUSH/POP in ARM C lang Regulation, Use for Vertical Counter
	char_height      .req r4  @ Parameter, have to PUSH/POP in ARM C lang Regulation, Horizontal Counter Reserved Number
	f_buffer         .req r5  @ Pointer of Framebuffer
	width            .req r6
	depth            .req r7
	size             .req r8
	color            .req r9
	char_width_bytes .req r10
	bitmask          .req r11

	push {r4-r11}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                    @ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #32                                  @ r4-r11 offset 32 bytes
	pop {char_height}                                @ Get Fifth and Sixth Arguments
	sub sp, sp, #36                                  @ Retrieve SP

	ldr f_buffer, FB_ADDRESS
	cmp f_buffer, #0
	beq fb32_draw_image_error2

	ldr width, FB_WIDTH
	cmp width, #0
	beq fb32_draw_image_error2

	ldr depth, FB_DEPTH
	cmp depth, #0
	beq fb32_draw_image_error2
	cmp depth, #32
	cmpne depth, #16
	bne fb32_draw_image_error2

	ldr size, FB_SIZE
	cmp size, #0
	beq fb32_draw_image_error2
	add size, f_buffer, size

	cmp depth, #16
	subeq size, size, #2                             @ Maximum of Framebuffer Address (Offset - 2 Bytes)
	lsleq width, width, #1                           @ Vertical Offset Bytes, substitution of Multiplication by 2
	lsleq char_width_bytes, char_width, #1           @ Character Vertical Offset Bytes, substitution of Multiplication by 2
	cmp depth, #32
	subeq size, size, #4                             @ Maximum of Framebuffer Address (Offset - 4 bytes)
	lsleq width, width, #2                           @ Vertical Offset Bytes, substitution of Multiplication by 4
	lsleq char_width_bytes, char_width, #2           @ Character Vertical Offset Bytes, substitution of Multiplication by 2

	/* Set Location to Render the Character */

	cmp y_coord, #0                                  @ If Value of y_coord is Signed Minus
	addlt char_height, char_height, y_coord          @ Subtract y_coord Value from char_height
	mullt y_coord, char_width_bytes, y_coord         @ Multiply Number of Bytes in a Row
	sublt image_point, image_point, y_coord          @ Add y_coord Value to char_point
	mulge y_coord, width, y_coord                    @ Vertical Offset Bytes, Rd should not be Rm in `MUL` from Warning
	addge f_buffer, f_buffer, y_coord

	ldr ip, [sp, #40]                                @ Y Offset
	cmp ip, #0
	subgt char_height, char_height, ip               @ Subtract Y Offset (ip) value from char_height
	mulgt ip, char_width_bytes, ip
	addgt image_point, image_point, ip
	
	.unreq char_width_bytes
	j .req r10                                       @ Use for Horizontal Counter
	.unreq y_coord
	width_check .req r2                              @ Store the Limitation of Width on this Y Coordinate

	mov width_check, f_buffer
	add width_check, width

	cmp x_coord, #0                                  @ If Value of x_coord is Signed Minus
	blt fb32_draw_image_xminus

	cmp depth, #16
	lsleq x_coord, x_coord, #1                       @ Horizontal Offset Bytes, substitution of Multiplication by 2
	cmp depth, #32
	lsleq x_coord, x_coord, #2                       @ Horizontal Offset Bytes, substitution of Multiplication by 4
	add f_buffer, f_buffer, x_coord                  @ Horizontal Offset Bytes

	x_offset_char .req r1

	mov x_offset_char, #0                            @ X Minus Offset Bytes
	b fb32_draw_image_xoffset

	fb32_draw_image_xminus:
		add char_width, char_width, x_coord      @ Subtract x_coord Value from char_width

		.unreq x_coord

		mvn x_offset_char, x_offset_char         @ Logical Not to Convert Minus to Plus
		add x_offset_char, x_offset_char, #1     @ Add 1 to Convert Minus to Plus

		cmp depth, #16
		lsleq x_offset_char, x_offset_char, #1   @ X Minus Coord Bytes, substitution of Multiplication by 2 (No Minus)
		cmp depth, #32
		lsleq x_offset_char, x_offset_char, #2   @ X Minus Coord Bytes, substitution of Multiplication by 2 (No Minus)

	fb32_draw_image_xoffset:
		ldr ip, [sp, #36]                        @ X Offset
		cmp ip, #0
		ble fb32_draw_image_loop

		sub char_width, char_width, ip           @ Subtract X Offset (ip) value from char_width

		cmp depth, #16
		lsleq ip, ip, #1                         @ X Offset Bytes, substitution of Multiplication by 2 (No Minus)
		cmp depth, #32
		lsleq ip, ip, #2                         @ X Offset Bytes, substitution of Multiplication by 4 (No Minus)

		add x_offset_char, x_offset_char, ip

	fb32_draw_image_loop:
		cmp f_buffer, size                           @ Check Overflow of Framebuffer Memory
		bgt fb32_draw_image_error1

		cmp char_height, #0                          @ Vertical Counter `(; char_height > 0; char_height--)`
		movle r0, #0                                 @ Return with Success
		ble fb32_draw_image_common

		add image_point, image_point, x_offset_char  @ Add X Offset Bytes

		mov j, char_width                            @ Horizontal Counter `(int j = char_width; j >= 0; --j)`

		fb32_draw_image_loop_horizontal:
			sub j, j, #1                             @ For Bit Allocation (Horizontal Character Bit)
			cmp j, #0                                @ Horizontal Counter, Check
			blt fb32_draw_image_loop_common

			cmp depth, #16
			ldreqh color, [image_point]              @ Load half word
			cmp depth, #32
			ldreq color, [image_point]               @ Load word

			/* The Picture Process */
			cmp depth, #16
			streqh color, [f_buffer]                 @ Store half word
			cmp depth, #32
			streq color, [f_buffer]                  @ Store word

			fb32_draw_image_loop_horizontal_common:
				cmp depth, #16
				addeq f_buffer, f_buffer, #2         @ Framebuffer Address Shift
				addeq image_point, image_point, #2   @ Image Pointer Shift
				cmp depth, #32
				addeq f_buffer, f_buffer, #4         @ Framebuffer Address Shift
				addeq image_point, image_point, #4   @ Image Pointer Shift

				cmp f_buffer, width_check            @ Check Overflow of Width
				blt fb32_draw_image_loop_horizontal

				cmp depth, #16
				lsleq j, j, #1                       @ substitution of Multiplication by 2
				cmp depth, #32
				lsleq j, j, #2                       @ substitution of Multiplication by 4
				add f_buffer, f_buffer, j            @ Framebuffer Offset

		fb32_draw_image_loop_common:
			sub char_height, char_height, #1

			cmp depth, #16
			lsleq j, char_width, #1                  @ substitution of Multiplication by 2
			cmp depth, #32
			lsleq j, char_width, #2                  @ substitution of Multiplication by 4
			sub f_buffer, f_buffer, j                @ Offset Clear of Framebuffer

			add f_buffer, f_buffer, width            @ Horizontal Sync (Framebuffer)

			add width_check, width_check, width      @ Store the Limitation of Width on the Next Y Coordinate

			b fb32_draw_image_loop

	fb32_draw_image_error1:
		mov r0, #1                                   @ Return with Error 1
		b fb32_draw_image_common

	fb32_draw_image_error2:
		mov r0, #2                                   @ Return with Error 2

	fb32_draw_image_common:
		mov r1, f_buffer
		pop {r4-r11}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			            @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number
		mov pc, lr

.unreq image_point
.unreq x_offset_char
.unreq width_check
.unreq char_width
.unreq char_height
.unreq f_buffer
.unreq width
.unreq depth
.unreq size
.unreq color
.unreq j
.unreq bitmask


/**
 * function fb32_clear_color_block
 * Clear Block by Color
 *
 * Parameters
 * r0: Color (16-bit or 32-bit)
 * r1: X Coordinate
 * r2: Y Coordinate
 * r3: Character Width in Pixels
 * r4: Character Height in Pixels
 *
 * Usage: r0-r10
 * Return: r0 (0 as sucess, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 * Global Enviromental Variable(s): FB_ADDRESS, FB_WIDTH, FB_SIZE, FB_DEPTH
 */
.globl fb32_clear_color_block
fb32_clear_color_block:
	/* Auto (Local) Variables, but just aliases */
	color       .req r0  @ Parameter, Register for Argument, Scratch Register
	x_coord     .req r1  @ Parameter, Register for Argument and Result, Scratch Register
	y_coord     .req r2  @ Parameter, Register for Argument, Scratch Register
	char_width  .req r3  @ Parameter, Register for Argument, Scratch Register
	char_height .req r4  @ Parameter, have to PUSH/POP in ARM C lang Regulation, Horizontal Counter Reserved Number
	f_buffer    .req r5  @ Pointer of Framebuffer
	width       .req r6
	depth       .req r7
	size        .req r8
	j           .req r9  @ Use for Horizontal Counter
	bitmask     .req r10

	push {r4-r10}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                    @ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #28                                  @ r4-r10 offset 28 bytes
	pop {char_height}                                @ Get Fifth and Sixth Arguments
	sub sp, sp, #32                                  @ Retrieve SP

	ldr f_buffer, FB_ADDRESS
	cmp f_buffer, #0
	beq fb32_clear_color_block_error2

	ldr width, FB_WIDTH
	cmp width, #0
	beq fb32_clear_color_block_error2

	ldr depth, FB_DEPTH
	cmp depth, #0
	beq fb32_clear_color_block_error2
	cmp depth, #32
	cmpne depth, #16
	bne fb32_clear_color_block_error2

	ldr size, FB_SIZE
	cmp size, #0
	beq fb32_clear_color_block_error2
	add size, f_buffer, size

	cmp depth, #16
	subeq size, size, #2                             @ Maximum of Framebuffer Address (Offset - 2 Bytes)
	lsleq width, width, #1                           @ Vertical Offset Bytes, substitution of Multiplication by 2
	cmp depth, #32
	subeq size, size, #4                             @ Maximum of Framebuffer Address (Offset - 4 bytes)
	lsleq width, width, #2                           @ Vertical Offset Bytes, substitution of Multiplication by 4

	/* Set Location to Render the Character */

	cmp y_coord, #0                                  @ If Value of y_coord is Signed Minus
	addlt char_height, char_height, y_coord          @ Subtract y_coord Value from char_height
	mulge y_coord, width, y_coord                    @ Vertical Offset Bytes, Rd should not be Rm in `MUL` from Warning
	addge f_buffer, f_buffer, y_coord

	.unreq y_coord
	width_check .req r2                              @ Store the Limitation of Width on this Y Coordinate

	mov width_check, f_buffer
	add width_check, width

	cmp x_coord, #0                                  @ If Value of x_coord is Signed Minus
	addlt char_width, char_width, x_coord            @ Subtract x_coord Value from char_width
	blt fb32_clear_color_block_loop

	cmp depth, #16
	lsleq x_coord, x_coord, #1                       @ Horizontal Offset Bytes, substitution of Multiplication by 2
	cmp depth, #32
	lsleq x_coord, x_coord, #2                       @ Horizontal Offset Bytes, substitution of Multiplication by 4
	add f_buffer, f_buffer, x_coord                  @ Horizontal Offset Bytes

	fb32_clear_color_block_loop:
		cmp f_buffer, size                           @ Check Overflow of Framebuffer Memory
		bgt fb32_clear_color_block_error1

		cmp char_height, #0                          @ Vertical Counter `(; char_height > 0; char_height--)`
		movle r0, #0                                 @ Return with Success
		ble fb32_clear_color_block_common

		mov j, char_width                            @ Horizontal Counter `(int j = char_width; j >= 0; --j)`

		fb32_clear_color_block_loop_horizontal:
			sub j, j, #1                             @ For Bit Allocation (Horizontal Character Bit)
			cmp j, #0                                @ Horizontal Counter, Check
			blt fb32_clear_color_block_loop_common

			/* The Picture Process */
			cmp depth, #16
			streqh color, [f_buffer]                 @ Store half word
			cmp depth, #32
			streq color, [f_buffer]                  @ Store word

			fb32_clear_color_block_loop_horizontal_common:
				cmp depth, #16
				addeq f_buffer, f_buffer, #2          @ Framebuffer Address Shift
				cmp depth, #32
				addeq f_buffer, f_buffer, #4          @ Framebuffer Address Shift

				cmp f_buffer, width_check             @ Check Overflow of Width
				blt fb32_clear_color_block_loop_horizontal

				cmp depth, #16
				lsleq j, j, #1                        @ substitution of Multiplication by 2
				cmp depth, #32
				lsleq j, j, #2                        @ substitution of Multiplication by 4
				add f_buffer, f_buffer, j             @ Framebuffer Offset

		fb32_clear_color_block_loop_common:
			sub char_height, char_height, #1

			cmp depth, #16
			lsleq j, char_width, #1                  @ substitution of Multiplication by 2
			cmp depth, #32
			lsleq j, char_width, #2                  @ substitution of Multiplication by 4
			sub f_buffer, f_buffer, j                @ Offset Clear of Framebuffer

			add f_buffer, f_buffer, width            @ Horizontal Sync (Framebuffer)

			add width_check, width_check, width      @ Store the Limitation of Width on the Next Y Coordinate

			b fb32_clear_color_block_loop

	fb32_clear_color_block_error1:
		mov r0, #1                                   @ Return with Error 1
		b fb32_clear_color_block_common

	fb32_clear_color_block_error2:
		mov r0, #2                                   @ Return with Error 2

	fb32_clear_color_block_common:
		mov r1, f_buffer
		pop {r4-r10}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			            @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number
		mov pc, lr

.unreq color
.unreq x_coord
.unreq width_check
.unreq char_width
.unreq char_height
.unreq f_buffer
.unreq width
.unreq depth
.unreq size
.unreq j
.unreq bitmask


/**
 * function fb32_clear_color
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
.globl fb32_clear_color
fb32_clear_color:
	color             .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	fb_buffer         .req r1
	size              .req r2
	depth             .req r3
	length            .req r4

	push {r4}

	ldr fb_buffer, FB_ADDRESS
	cmp fb_buffer, #0
	beq fb32_clear_color_error

	ldr size, FB_SIZE
	cmp size, #0
	beq fb32_clear_color_error

	ldr depth, FB_DEPTH
	cmp depth, #0
	beq fb32_clear_color_error

	cmp depth, #16
	moveq length, #2
	cmp depth, #32
	moveq length, #4

	fb32_clear_color_loop:
		cmp depth, #16
		streqh color, [fb_buffer]         @ Store half word
		cmp depth, #32
		streq color, [fb_buffer]          @ Store word
		add fb_buffer, fb_buffer, length
		sub size, size, length
		cmp size, #0
		bgt fb32_clear_color_loop

		mov r0, #0                        @ Return with Success
		b fb32_clear_color_common

	fb32_clear_color_error:
		mov r0, #1                        @ Return with Error

	fb32_clear_color_common:
		pop {r4}
		mov pc, lr

.unreq color
.unreq fb_buffer
.unreq size
.unreq depth
.unreq length


/**
 * function fb32_get
 * Get Framebuffer
 *
 * Usage: r0-r1
 * Return: r0 (0 as sucess, 1 as error)
 * Error(1): When Framebuffer is not Defined
 * Global Enviromental Variable(s): FB_ADDRESS
 * External Variable(s): peripherals_base, mailbox_base, mail_framebuffer_addr
 */
.globl fb32_get
fb32_get:
	memorymap_base    .req r0
	temp              .req r1

	ldr memorymap_base, peripherals_base
	ldr temp, mailbox_base
	add memorymap_base, memorymap_base, temp

	fb32_get_waitforwrite:
		ldr temp, [memorymap_base, #mailbox0_status]
		cmp temp, #0x80000000
		beq fb32_get_waitforwrite

	ldr temp, mail_framebuffer_addr
	add temp, temp, #mailbox_gpuoffset|mailbox_channel8
	str temp, [memorymap_base, #mailbox0_write]

	fb32_get_waitforread:
		ldr temp, [memorymap_base, #mailbox0_status]
		cmp temp, #0x40000000
		beq fb32_get_waitforread

	ldr memorymap_base, mail_framebuffer_addr
	ldr temp, [memorymap_base, #mail_confirm]
	cmp temp, #0x80000000
	bne fb32_get_error

	ldr memorymap_base, FB_ADDRESS
	cmp memorymap_base, #0
	beq fb32_get_error

	and memorymap_base, memorymap_base, #mailbox_armmask             @ Change FB_ADDRESS VideoCore's to ARM's
	str memorymap_base, FB_ADDRESS                                   @ Store ARM7s FB_ADDRESS

	dmb                                      @ `DMB` Data Memory Barrier, completes all memory access before
                                                 @ `DSB` Data Synchronization Barrier, completes all instructions before
                                                 @ `ISB` Instruction Synchronization Barrier, flushes the pipeline before,
                                                 @ to ensure to fetch data from cache/ memory
                                                 @ These are useful in multi-core/ threads usage, etc.

	mov r0, #0                               @ Return with Success

	b fb32_get_common

	fb32_get_error:
		mov r0, #1                       @ Return with Error

	fb32_get_common:
		mov pc, lr

.unreq memorymap_base
.unreq temp


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
