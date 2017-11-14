/**
 * draw32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function draw32_antialias
 * Anti-aliasing
 * Caution! This Function is Used in 32-bit Depth Color
 * First and Last Pixel of Base is not anti-aliased, and there is no horizontal sync.
 *
 * Parameters
 * r0: Pointer of Buffer for Result
 * r1: Pointer of Buffer to Be Aliased, Base
 *
 * Usage: r0-r10
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): When Buffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Buffer is not Defined, or Depth is not 32-bit
 */
.globl draw32_antialias
draw32_antialias:
	/* Auto (Local) Variables, but just Aliases */
	buffer_result  .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	buffer_base    .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	size_result    .req r2 @ Scratch Register
	size_base      .req r3 @ Scratch Register
	color          .req r4
	color_before   .req r5
	color_after    .req r6
	bitmask        .req r7
	bitmask_before .req r8
	bitmask_after  .req r9
	color_result   .req r10
	shift          .req r11

	push {r4-r11}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                    @ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	ldr size_result, [buffer_result, #12]
	cmp size_result, #0
	beq draw32_antialias_error2

	ldr shift, [buffer_result, #16]
	cmp shift, #32                             @ Depth Check
	bne draw32_antialias_error2

	ldr buffer_result, [buffer_result]
	cmp buffer_result, #0
	beq draw32_antialias_error2

	.unreq buffer_result
	result_addr .req r0

	add size_result, result_addr, size_result

	ldr size_base, [buffer_base, #12]
	cmp size_base, #0
	beq draw32_antialias_error2

	ldr shift, [buffer_base, #16]
	cmp shift, #32                             @ Depth Check
	bne draw32_antialias_error2

	ldr buffer_base, [buffer_base]
	cmp buffer_base, #0
	beq draw32_antialias_error2

	.unreq buffer_base
	base_addr .req r1

	add size_base, base_addr, size_base
	sub size_base, size_base, #4               @ Not to Reach Last Pixel of Base

	ldr color, [base_addr]                     @ First Pixel of Base
	str color, [result_addr]

	draw32_antialias_loop:

		add base_addr, base_addr, #4
		add result_addr, result_addr, #4

		cmp base_addr, size_base
		bhi draw32_antialias_success

		cmp result_addr, size_result
		bhs draw32_antialias_error1

		cmp base_addr, size_base
		ldreq color, [base_addr]           @ Last Pixel of Base
		streq color, [result_addr]
		beq draw32_antialias_loop

		ldr color, [base_addr]
		ldr color_before, [base_addr, #-4]
		ldr color_after, [base_addr, #4]
		
		mov shift, #0
		mov color_result, #0

		draw32_antialias_loop_color:
			cmp shift, #32
			bhs draw32_antialias_loop_common
			mov bitmask, #0xFF
			mov bitmask_before, #0xFF
			mov bitmask_after, #0xFF
			lsl bitmask, bitmask, shift
			lsl bitmask_before, bitmask_before, shift
			lsl bitmask_after, bitmask_after, shift
			and bitmask, bitmask, color
			and bitmask_before, bitmask_before, color_before
			and bitmask_after, bitmask_after, color_after
			lsr bitmask, bitmask, shift
			lsr bitmask_before, bitmask_before, shift
			lsr bitmask_after, bitmask_after, shift
			lsl bitmask, bitmask, #2                             @ Substitution of Multiplication by 4
			lsl bitmask_before, bitmask_before, #1               @ Substitution of Multiplication by 2
			lsl bitmask_after, bitmask_after, #1                 @ Substitution of Multiplication by 2
			add bitmask, bitmask, bitmask_before
			add bitmask, bitmask, bitmask_after
			lsr bitmask, #3                                      @ Substitutuion of Division by 8
			lsl bitmask, bitmask, shift
			add color_result, color_result, bitmask
			add shift, shift, #8

			b draw32_antialias_loop_color

		draw32_antialias_loop_common:
			str color_result, [result_addr]

			b draw32_antialias_loop

	draw32_antialias_error1:
		mov r0, #1                                 @ Return with Error 1
		b draw32_antialias_common

	draw32_antialias_error2:
		mov r0, #2                                 @ Return with Error 2
		b draw32_antialias_common

	draw32_antialias_success:
		mov r0, #0                                 @ Return with Success

	draw32_antialias_common:
		pop {r4-r11}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			            @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number
		mov pc, lr

.unreq result_addr
.unreq base_addr
.unreq size_result
.unreq size_base
.unreq color
.unreq color_before
.unreq color_after
.unreq bitmask
.unreq bitmask_before
.unreq bitmask_after
.unreq color_result
.unreq shift


/**
 * function draw32_fill_color
 * Fill by Color
 *
 * Parameters
 * r0: Pointer of Buffer to Be Filled by Color
 *
 * Usage: r0-r10
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): When Buffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Buffer is not Defined
 */
.globl draw32_fill_color
draw32_fill_color:
	/* Auto (Local) Variables, but just Aliases */
	buffer_base .req r0 @ Parameter, Register for Argument, Scratch Register
	base_addr   .req r1 @ Parameter, Register for Result, Scratch Register
	color       .req r2 @ Scratch Register
	width       .req r3 @ Scratch Register
	height      .req r4
	depth       .req r5
	size        .req r6
	flag        .req r7
	j           .req r8 @ Use for Horizontal Counter
	color_pick  .req r9
	addr_pick   .req r10

	push {r4-r10}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                    @ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	ldr base_addr, [buffer_base]
	cmp base_addr, #0
	beq draw32_fill_color_error2

	ldr width, [buffer_base, #4]
	cmp width, #0
	beq draw32_fill_color_error2

	ldr height, [buffer_base, #8]
	cmp height, #0
	beq draw32_fill_color_error2

	ldr size, [buffer_base, #12]
	cmp size, #0
	beq draw32_fill_color_error2
	add size, base_addr, size

	ldr depth, [buffer_base, #16]
	cmp depth, #32
	cmpne depth, #16
	bne draw32_fill_color_error2

	mov flag, #0

	draw32_fill_color_loop:

		cmp height, #0                               @ Vertical Counter `(; mask_height > 0; mask_height--)`
		ble draw32_fill_color_success

		cmp base_addr, size                          @ Check Overflow of Buffer Memory
		bhs draw32_fill_color_error1

		mov j, width                                 @ Horizontal Counter `(int j = mask_width; j >= 0; --j)`

		draw32_fill_color_loop_horizontal:
			sub j, j, #1                             @ For Bit Allocation (Horizontal Character Bit)
			cmp j, #0                                @ Horizontal Counter, Check
			blt draw32_fill_color_loop_common

			/* Pick Process */
			cmp depth, #16
			ldreqh color_pick, [base_addr]
			cmp depth, #32
			ldreq color_pick, [base_addr]

			cmp flag, #0
			beq draw32_fill_color_loop_horizontal_flag0
			cmp flag, #1
			beq draw32_fill_color_loop_horizontal_flag1
			cmp flag, #2
			beq draw32_fill_color_loop_horizontal_flag2
			cmp flag, #3
			beq draw32_fill_color_loop_horizontal_flag3

			draw32_fill_color_loop_horizontal_flag0:             @ When No Color, phi
				cmp color_pick, #0
				beq draw32_fill_color_loop_horizontal_common
				mov color, color_pick
				mov flag, #1
				b draw32_fill_color_loop_horizontal_common

			draw32_fill_color_loop_horizontal_flag1:             @ When Left Side to Fill by Color
				cmp color, color_pick
				beq draw32_fill_color_loop_horizontal_common
				mov addr_pick, base_addr
				mov flag, #2
				b draw32_fill_color_loop_horizontal_common

			draw32_fill_color_loop_horizontal_flag2:             @ When Space to Fill by Color
				cmp color, color_pick
				bne draw32_fill_color_loop_horizontal_common

				draw32_fill_color_loop_horizontal_flag2_loop:

					cmp depth, #16
					streqh color, [addr_pick]
					addeq addr_pick, addr_pick, #2
					cmp depth, #32
					streq color, [addr_pick]
					addeq addr_pick, addr_pick, #4
					cmp addr_pick, base_addr
					blo draw32_fill_color_loop_horizontal_flag2_loop

					mov flag, #3
					b draw32_fill_color_loop_horizontal_common

			draw32_fill_color_loop_horizontal_flag3:             @ When Right Side to Fill by COlor
				cmp color, color_pick
				beq draw32_fill_color_loop_horizontal_common @ If Same Color to Fill
				cmp color_pick, #0
				moveq flag, #0                             @ If No Color
				movne color, color_pick
				movne flag, #1                             @ If Other Color

			draw32_fill_color_loop_horizontal_common:
				cmp depth, #16
				addeq base_addr, base_addr, #2          @ Buffer Address Shift
				cmp depth, #32
				addeq base_addr, base_addr, #4          @ Buffer Address Shift

				b draw32_fill_color_loop_horizontal

		draw32_fill_color_loop_common:
			sub height, height, #1

			mov flag, #0

			b draw32_fill_color_loop

	draw32_fill_color_error1:
		mov r0, #1                                 @ Return with Error 1
		b draw32_fill_color_common

	draw32_fill_color_error2:
		mov r0, #2                                 @ Return with Error 2
		b draw32_fill_color_common

	draw32_fill_color_success:
		mov r0, #0                                 @ Return with Success

	draw32_fill_color_common:
		pop {r4-r10}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			            @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number
		mov pc, lr

.unreq buffer_base
.unreq base_addr
.unreq color
.unreq width
.unreq height
.unreq depth
.unreq size
.unreq flag
.unreq j
.unreq color_pick
.unreq addr_pick


/**
 * function draw32_mask_image
 * Make Masked Image to Mask
 * Caution! This Function is Used in 32-bit Depth Color
 *
 * Parameters
 * r0: Pointer of Buffer of Mask
 * r1: Pointer of Buffer based of Mask
 * r2: X Coordinate of Mask
 * r3: Y Coordinate of Mask
 *
 * Usage: r0-r11
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): When Buffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Buffer is not Defined
 */
.globl draw32_mask_image
draw32_mask_image:
	/* Auto (Local) Variables, but just Aliases */
	buffer_mask .req r0  @ Parameter, Register for Argument and Result, Scratch Register
	buffer_base .req r1  @ Parameter, Register for Argument and Result, Scratch Register
	x_coord     .req r2  @ Parameter, Register for Argument, Scratch Register
	y_coord     .req r3  @ Parameter, Register for Argument, Scratch Register
	base_addr   .req r4  @ Pointer of Base
	width       .req r5
	depth       .req r6
	size        .req r7
	mask_addr   .req r8  @ Pointer of Mask
	mask_width  .req r9
	mask_height .req r10
	j           .req r11 @ Use for Horizontal Counter

	push {r4-r11}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                    @ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	ldr base_addr, [buffer_base]
	cmp base_addr, #0
	beq draw32_mask_image_error2

	ldr width, [buffer_base, #4]
	cmp width, #0
	beq draw32_mask_image_error2

	ldr depth, [buffer_base, #16]
	cmp depth, #32
	bne draw32_mask_image_error2
	ldr depth, [buffer_mask, #16]
	cmp depth, #32
	bne draw32_mask_image_error2

	ldr size, [buffer_base, #12]
	cmp size, #0
	beq draw32_mask_image_error2
	add size, base_addr, size

	lsl width, width, #2                             @ Vertical Offset Bytes, substitution of Multiplication by 4

	ldr mask_addr, [buffer_mask]
	cmp mask_addr, #0
	beq draw32_mask_image_error2

	ldr mask_width, [buffer_mask, #4]
	cmp mask_width, #0
	beq draw32_mask_image_error2

	ldr mask_height, [buffer_mask, #8]
	cmp mask_width, #0
	beq draw32_mask_image_error2

	/* Set Location of Mask */

	cmp y_coord, #0                                  @ If Value of y_coord is Signed Minus
	addlt mask_height, mask_height, y_coord          @ Subtract y_coord Value from char_height
	mulge y_coord, width, y_coord                    @ Vertical Offset Bytes, Rd should not be Rm in `MUL` from Warning
	addge base_addr, base_addr, y_coord

	.unreq y_coord
	width_check .req r3                              @ Store the Limitation of Width on this Y Coordinate

	mov width_check, base_addr
	add width_check, width

	cmp x_coord, #0                                  @ If Value of x_coord is Signed Minus
	addlt mask_width, mask_width, x_coord            @ Subtract x_coord Value from char_width
	blt draw32_mask_image_loop

	lsl x_coord, x_coord, #2                         @ Horizontal Offset Bytes, substitution of Multiplication by 4
	add base_addr, base_addr, x_coord                @ Horizontal Offset Bytes

	.unreq x_coord
	color .req r2

	draw32_mask_image_loop:

		cmp mask_height, #0                          @ Vertical Counter `(; mask_height > 0; mask_height--)`
		ble draw32_mask_image_success

		cmp base_addr, size                          @ Check Overflow of Buffer Memory
		bhs draw32_mask_image_error1

		mov j, mask_width                            @ Horizontal Counter `(int j = mask_width; j >= 0; --j)`

		draw32_mask_image_loop_horizontal:
			sub j, j, #1                             @ For Bit Allocation (Horizontal Character Bit)
			cmp j, #0                                @ Horizontal Counter, Check
			blt draw32_mask_image_loop_common

			/* Mask Process */
			ldr color, [mask_addr]
			cmp color, #0xFF000000

			moveq color, #0                             @ If Black
			streq color, [mask_addr]
			beq draw32_mask_image_loop_horizontal_common

			ldr color, [base_addr]                      @ Get Color of Base
			str color, [mask_addr]                      @ Store Color of Base to Mask

			draw32_mask_image_loop_horizontal_common:
				add base_addr, base_addr, #4            @ Buffer Address Shift
				add mask_addr, mask_addr, #4            @ Buffer Address Shift

				cmp base_addr, width_check              @ Check Overflow of Width
				blo draw32_mask_image_loop_horizontal

				lsl j, j, #2                            @ substitution of Multiplication by 4
				add base_addr, base_addr, j             @ Buffer Offset
				add mask_addr, mask_addr, j             @ Buffer Offset

		draw32_mask_image_loop_common:
			sub mask_height, mask_height, #1

			lsl j, mask_width, #2                      @ substitution of Multiplication by 4
			sub base_addr, base_addr, j                @ Offset Clear of Buffer of Base

			add base_addr, base_addr, width            @ Horizontal Sync (Buffer of Base)

			add width_check, width_check, width        @ Store the Limitation of Width on the Next Y Coordinate

			b draw32_mask_image_loop

	draw32_mask_image_error1:
		mov r0, #1                                   @ Return with Error 1
		b draw32_mask_image_common

	draw32_mask_image_error2:
		mov r0, #2                                   @ Return with Error 2
		b draw32_mask_image_common

	draw32_mask_image_success:
		mov r0, #0                                   @ Return with Success

	draw32_mask_image_common:
		pop {r4-r11}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			            @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number
		mov pc, lr

.unreq buffer_mask
.unreq buffer_base
.unreq color
.unreq width_check
.unreq base_addr
.unreq width
.unreq depth
.unreq size
.unreq mask_addr
.unreq mask_width
.unreq mask_height
.unreq j


/**
 * function draw32_init_renderbuffer
 * Set Renderbuffer
 *
 * Render Buffer Will Be Set with Heap.
 * Content of Render Buffer is Same as Framebuffer.
 * First is Address of Buffer, Second is Width, Third is Height, Fourth is Size, Fifth is Depth.
 * So, Block Size is 5 (20 Bytes).
 *
 * Parameters
 * r0: Pointer of Renderbuffer to Set
 * r1: Width of BUffer
 * r2: height of Buffer
 * r3: depth of Buffer
 *
 * Usage: r0-r5
 * Return: r0 (0 as success, 1 as error)
 * Error: Memory Space for Buffer Can't Be Allocated
 */
.globl draw32_init_renderbuffer
draw32_init_renderbuffer:
	/* Auto (Local) Variables, but just Aliases */
	buffer    .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	width     .req r1 @ Parameter, Register for Argument, Scratch Register
	height    .req r2 @ Parameter, Register for Argument, Scratch Register
	depth     .req r3 @ Parameter, Register for Argument, Scratch Register
	size      .req r4
	addr      .req r5

	push {r4-r5}

	macro32_dsb ip
	macro32_isb ip

	mul size, width, height

	cmp depth, #16
	lsreq addr, size, #1                 @ Division of Multiplication by 2, i.e., Half Block (2 Bytes) per Pixel For Heap
	addeq addr, addr, #1                 @ To Hide Overflow by Division
	lsleq size, size, #1                 @ Multiplication of Multiplication by 2 (2 Bytes per Pixel)

	cmp depth, #32
	moveq addr, size                     @ One Block (4 Bytes) per Pixel for Heap
	lsleq size, size, #2                 @ Multiplication of Multiplication by 4 (4 Bytes per Pixel)

	push {r0-r3,lr}
	mov r0, addr
	bl heap32_malloc
	mov addr, r0
	pop {r0-r3,lr}

	cmp addr, #0
	beq draw32_init_renderbuffer_error

	str addr, [buffer]
	str width, [buffer, #4]
	str height, [buffer, #8]
	str size, [buffer, #12]
	str depth, [buffer, #16]
	
	b draw32_init_renderbuffer_success

	draw32_init_renderbuffer_error:
		mov r0, #1
		b draw32_init_renderbuffer_common

	draw32_init_renderbuffer_success:
		mov r0, #0

	draw32_init_renderbuffer_common:
		macro32_dsb ip                   @ Ensure Completion of Instructions Before
		macro32_isb ip                   @ Flush Data in Pipeline to Cache
		pop {r4-r5}
		mov pc, lr

.unreq buffer
.unreq width
.unreq height
.unreq depth
.unreq size
.unreq addr


/**
 * function draw32_free_renderbuffer
 * Clear Renderbuffer with Freeing Memory
 *
 * Parameters
 * r0: Pointer of Renderbuffer to Clear
 *
 * Usage: r0-r1
 * Return: r0 (0 as success, 1 as error)
 * Error: Pointer of Buffer is Null (0)
 */
.globl draw32_free_renderbuffer
draw32_free_renderbuffer:
	/* Auto (Local) Variables, but just Aliases */
	buffer    .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	addr      .req r1 @ Scratch Register

	ldr addr, [buffer]
	
	push {r0-r3,lr}
	mov r0, addr
	bl heap32_mfree
	cmp r0, #0
	bne draw32_free_renderbuffer_error
	pop {r0-r3,lr}

	mov addr, #0
	str addr, [buffer]
	str addr, [buffer, #4]
	str addr, [buffer, #8]
	str addr, [buffer, #12]
	str addr, [buffer, #16]

	b draw32_free_renderbuffer_success

	draw32_free_renderbuffer_error:
		mov r0, #1
		b draw32_free_renderbuffer_common

	draw32_free_renderbuffer_success:
		mov r0, #0

	draw32_free_renderbuffer_common:
		macro32_dsb ip                   @ Ensure Completion of Instructions Before
		macro32_isb ip                   @ Flush Data in Pipeline to Cache
		mov pc, lr

.unreq buffer
.unreq addr


/**
 * function draw32_copy
 * Copy Buffer to Buffer
 *
 * Parameters
 * r0: Pointer of Buffer IN
 * r1: Pointer of Buffer OUT
 *
 * Usage: r0-r9
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Buffer In is not Defined
 */
.globl draw32_copy
draw32_copy:
	/* Auto (Local) Variables, but just Aliases */
	buffer_in         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	buffer_out        .req r1 @ Parameter, Register for Argument, Scratch Register
	buffer_in_addr    .req r2 @ Scratch Register
	buffer_out_addr   .req r3 @ Scratch Register
	width             .req r4
	height            .req r5
	size              .req r6
	depth             .req r7
	length            .req r8
	color             .req r9

	push {r4-r9}

	macro32_dsb ip
	macro32_isb ip

	ldr buffer_in_addr, [buffer_in]
	cmp buffer_in_addr, #0
	beq draw32_copy_error

	ldr width, [buffer_in, #4]
	cmp width, #0
	beq draw32_copy_error

	ldr height, [buffer_in, #8]
	cmp height, #0
	beq draw32_copy_error

	ldr size, [buffer_in, #12]
	cmp size, #0
	beq draw32_copy_error

	ldr depth, [buffer_in, #16]
	cmp depth, #0
	beq draw32_copy_error

	ldr buffer_out_addr, [buffer_out]
	cmp buffer_out_addr, #0
	beq draw32_copy_error

	str width, [buffer_out, #4]
	str height, [buffer_out, #8]
	str size, [buffer_out, #12]
	str depth, [buffer_out, #16]

	cmp depth, #16
	moveq length, #2
	cmp depth, #32
	moveq length, #4

	draw32_copy_loop:
		cmp depth, #16
		ldreqh color, [buffer_in_addr]        @ Store half word
		streqh color, [buffer_out_addr]       @ Store half word
		cmp depth, #32
		ldreq color, [buffer_in_addr]         @ Store word
		streq color, [buffer_out_addr]        @ Store word
		add buffer_in_addr, buffer_in_addr, length
		add buffer_out_addr, buffer_out_addr, length
		sub size, size, length
		cmp size, #0
		bgt draw32_copy_loop

		mov r0, #0                               @ Return with Success
		b draw32_copy_common

	draw32_copy_error:
		mov r0, #1                               @ Return with Error

	draw32_copy_common:
		macro32_dsb ip
		macro32_isb ip
		pop {r4-r9}
		mov pc, lr

.unreq buffer_in
.unreq buffer_out
.unreq buffer_in_addr
.unreq buffer_out_addr
.unreq width
.unreq height
.unreq size
.unreq depth
.unreq length
.unreq color


/**
 * function draw32_change_alpha_argb
 * Change Value of Alpha Channel in ARGB Data
 * Caution! This Function is Used in 32-bit Depth Color
 *
 * Parameters
 * r0: Pointer of Data to Change Value of Alpha
 * r1: Size of Data 
 * r2: Value of Alpha, 0-7 bits
 *
 * Usage: r0-r3
 * Return: r0 (0 as success)
 */
.globl draw32_change_alpha_argb
draw32_change_alpha_argb:
	/* Auto (Local) Variables, but just Aliases */
	data_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	size            .req r1 @ Parameter, Register for Argument, Scratch Register
	value_alpha     .req r2 @ Parameter, Register for Argument, Scratch Register
	swap            .req r3 @ Scratch Register

	add size, size, data_point
	lsl value_alpha, value_alpha, #24

	draw32_change_alpha_argb_loop:
		cmp data_point, size
		bhs draw32_change_alpha_argb_success

		ldr swap, [data_point]
		bic swap, swap, #0xFF000000
		add swap, swap, value_alpha
		str swap, [data_point]
		add data_point, data_point, #4

		b draw32_change_alpha_argb_loop

	draw32_change_alpha_argb_success:
		mov r0, #0

	draw32_change_alpha_argb_common:
		mov pc, lr

.unreq data_point
.unreq size
.unreq value_alpha
.unreq swap


/**
 * function draw32_rgba_to_argb
 * Convert 32-bit Depth Color RBGA to ARGB
 *
 * Parameters
 * r0: Pointer of Data to Convert Endianness
 * r1: Size of Data 
 *
 * Usage: r0-r2
 * Return: r0 (0 as success)
 */
.globl draw32_rgba_to_argb
draw32_rgba_to_argb:
	/* Auto (Local) Variables, but just Aliases */
	data_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	size            .req r1 @ Scratch Register
	swap            .req r2 @ Scratch Register

	add size, size, data_point

	draw32_rgba_to_argb_loop:
		cmp data_point, size
		bhs draw32_rgba_to_argb_success

		ldr swap, [data_point]
		ror swap, #8                    @ Rotate Right 8 Bits
		str swap, [data_point]
		add data_point, data_point, #4

		b draw32_rgba_to_argb_loop

	draw32_rgba_to_argb_success:
		mov r0, #0

	draw32_rgba_to_argb_common:
		mov pc, lr

.unreq data_point
.unreq size
.unreq swap
