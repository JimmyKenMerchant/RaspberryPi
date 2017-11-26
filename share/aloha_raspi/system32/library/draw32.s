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
 * function draw32_renderbuffer_init
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
.globl draw32_renderbuffer_init
draw32_renderbuffer_init:
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
	beq draw32_renderbuffer_init_error

	str addr, [buffer]
	str width, [buffer, #4]
	str height, [buffer, #8]
	str size, [buffer, #12]
	str depth, [buffer, #16]
	
	b draw32_renderbuffer_init_success

	draw32_renderbuffer_init_error:
		mov r0, #1
		b draw32_renderbuffer_init_common

	draw32_renderbuffer_init_success:
		mov r0, #0

	draw32_renderbuffer_init_common:
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
 * function draw32_renderbuffer_free
 * Clear Renderbuffer with Freeing Memory
 *
 * Parameters
 * r0: Pointer of Renderbuffer to Clear
 *
 * Usage: r0-r1
 * Return: r0 (0 as success, 1 as error)
 * Error: Pointer of Buffer is Null (0)
 */
.globl draw32_renderbuffer_free
draw32_renderbuffer_free:
	/* Auto (Local) Variables, but just Aliases */
	buffer    .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	addr      .req r1 @ Scratch Register

	ldr addr, [buffer]
	
	push {r0-r3,lr}
	mov r0, addr
	bl heap32_mfree
	cmp r0, #0
	bne draw32_renderbuffer_free_error
	pop {r0-r3,lr}

	mov addr, #0
	str addr, [buffer]
	str addr, [buffer, #4]
	str addr, [buffer, #8]
	str addr, [buffer, #12]
	str addr, [buffer, #16]

	b draw32_renderbuffer_free_success

	draw32_renderbuffer_free_error:
		mov r0, #1
		b draw32_renderbuffer_free_common

	draw32_renderbuffer_free_success:
		mov r0, #0

	draw32_renderbuffer_free_common:
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


/**
 * function draw32_arc_fdegree
 * Draw Arc by Degree with Single Precision Float
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 * Range is -360 to 360 degrees inclusively, otherwise, value will be cut off by the limit.
 *
 * Parameters
 * r0: Color (16-bit or 32-bit)
 * r1: X Coordinate of Center
 * r2: Y Coordinate of Center
 * r3: X Radius
 * r4: Y Radius
 * r5: Float Degree on Start of Arc
 * r6: Float Degree on End of Arc
 * r7: Width of Arc Line
 * r8: Height of Arc Line
 *
 * Return: r0 (0 as success, 1 as error)
 * Error: Buffer is Not Defined
 */
.globl draw32_arc_fdegree
draw32_arc_fdegree:
	/* Auto (Local) Variables, but just Aliases */
	color             .req r0   @ Parameter, Register for Argument and Result, Scratch Register
	x_coord           .req r1   @ Parameter, Register for Argument and Result, Scratch Register
	y_coord           .req r2   @ Parameter, Register for Argument, Scratch Register
	x_radius          .req r3   @ Parameter, Register for Argument, Scratch Register
	y_radius          .req r4   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	start_fdegree     .req r5   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	end_fdegree       .req r6   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_width        .req r7   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_height       .req r8   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	temp              .req r9
	neg_flag          .req r10

	/* VFP Registers */
	vfp_d_fdegree     .req d0 @ q0[0]
	vfp_start_fdegree .req s0 @ Lower 32 Bits of d0
	vfp_end_fdegree   .req s1 @ Upper 32 Bits of d0
	vfp_zero          .req s2
	vfp_full          .req s3
	vfp_half          .req s4
	vfp_temp          .req s5

	push {r4-r10,lr}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                   @ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #32                                   @ r4-r10 and lr offset 32 bytes
	pop {y_radius, start_fdegree, end_fdegree, char_width, char_height} @ Get Fifth to Ninth Arguments
	sub sp, sp, #52                                   @ Retrieve SP

	vpush {s0-s5}

	vmov vfp_d_fdegree, start_fdegree, end_fdegree

	mov temp, #0
	vmov vfp_zero, temp
	vcvt.f32.s32 vfp_zero, vfp_zero

	mov temp, #360
	vmov vfp_full, temp
	vcvt.f32.s32 vfp_full, vfp_full

	mov temp, #180
	vmov vfp_half, temp
	vcvt.f32.s32 vfp_half, vfp_half

	/* Ensure Start Is Less than End */

	vcmp.f32 vfp_start_fdegree, vfp_end_fdegree
	vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV
	vmovgt vfp_temp, vfp_start_fdegree
	vmovgt vfp_start_fdegree, vfp_end_fdegree
	vmovgt vfp_end_fdegree, vfp_temp

	/* Arrange -360.0 to 360.0 Degrees by Cutting off Exceeded Values */

	vcmp.f32 vfp_start_fdegree, vfp_full
	vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV
	vmovgt vfp_start_fdegree, vfp_full

	vcmp.f32 vfp_end_fdegree, vfp_full
	vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV
	vmovgt vfp_end_fdegree, vfp_full

	vneg.f32 vfp_temp, vfp_full
	
	vcmp.f32 vfp_start_fdegree, vfp_temp
	vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV
	vmovlt vfp_start_fdegree, vfp_temp

	vcmp.f32 vfp_end_fdegree, vfp_temp
	vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV
	vmovlt vfp_end_fdegree, vfp_temp

	/* Mirror Regular Registers and VFP Registers */
	vmov start_fdegree, vfp_start_fdegree
	vmov end_fdegree, vfp_end_fdegree

	draw32_arc_fdegree_minus180:
		/* -360 to -180.0 Degrees */
		vneg.f32 vfp_temp, vfp_half
		vcmp.f32 vfp_start_fdegree, vfp_temp
		vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV
		bge draw32_arc_fdegree_0

		vcmp.f32 vfp_end_fdegree, vfp_temp
		vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV
		vmovgt end_fdegree, vfp_temp

		push {r0-r3}
		mov r0, start_fdegree
		bl math32_fdegree_to_cradian32
		mov r5, r0
		pop {r0-r3}

		push {r0-r3}
		mov r0, end_fdegree
		bl math32_fdegree_to_cradian32
		mov r6, r0
		pop {r0-r3}

		push {r0-r3}
		push {r4-r8}
		bl draw32_arc
		add sp, sp, #20
		cmp r0, #1
		pop {r0-r3}
		beq draw32_arc_fdegree_error                   @ If Error

		vcmp.f32 vfp_end_fdegree, vfp_temp
		vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV
		ble draw32_arc_fdegree_success

		/* Mirror Regular Registers and VFP Registers */
		vmov start_fdegree, vfp_start_fdegree
		vmov end_fdegree, vfp_end_fdegree

	draw32_arc_fdegree_0:
		/* Over -180 to 0.0 Degrees */
		vcmp.f32 vfp_start_fdegree, vfp_zero
		vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV
		bge draw32_arc_fdegree_plus180

		vneg.f32 vfp_temp, vfp_half
		vcmp.f32 vfp_start_fdegree, vfp_temp
		vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV
		vmovlt start_fdegree, vfp_temp
		movle neg_flag, #1

		vcmp.f32 vfp_end_fdegree, vfp_zero
		vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV
		vmovgt end_fdegree, vfp_zero

		push {r0-r3}
		mov r0, start_fdegree
		bl math32_fdegree_to_cradian32
		mov r5, r0
		pop {r0-r3}

		/* Make Sure Value of PI Negative */
		cmp neg_flag, #1
		vmoveq vfp_temp, r5
		vnegeq.f32 vfp_temp, vfp_temp
		vmoveq r5, vfp_temp

		push {r0-r3}
		mov r0, end_fdegree
		bl math32_fdegree_to_cradian32
		mov r6, r0
		pop {r0-r3}

		push {r0-r3}
		push {r4-r8}
		bl draw32_arc
		add sp, sp, #20
		cmp r0, #1
		pop {r0-r3}
		beq draw32_arc_fdegree_error                       @ If Error

		vcmp.f32 vfp_end_fdegree, vfp_zero
		vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV
		ble draw32_arc_fdegree_success

		/* Mirror Regular Registers and VFP Registers */
		vmov start_fdegree, vfp_start_fdegree
		vmov end_fdegree, vfp_end_fdegree
	
	draw32_arc_fdegree_plus180:
		/* Over 0.0 to 180.0 Degrees */
		vcmp.f32 vfp_start_fdegree, vfp_half
		vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV
		bge draw32_arc_fdegree_plus360

		vcmp.f32 vfp_start_fdegree, vfp_zero
		vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV
		vmovlt start_fdegree, vfp_zero

		vcmp.f32 vfp_end_fdegree, vfp_half
		vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV
		vmovgt end_fdegree, vfp_half

		push {r0-r3}
		mov r0, start_fdegree
		bl math32_fdegree_to_cradian32
		mov r5, r0
		pop {r0-r3}

		push {r0-r3}
		mov r0, end_fdegree
		bl math32_fdegree_to_cradian32
		mov r6, r0
		pop {r0-r3}

		push {r0-r3}
		push {r4-r8}
		bl draw32_arc
		add sp, sp, #20
		cmp r0, #1
		pop {r0-r3}
		beq draw32_arc_fdegree_error                       @ If Error

		vcmp.f32 vfp_end_fdegree, vfp_half
		vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV
		ble draw32_arc_fdegree_success

		/* Mirror Regular Registers and VFP Registers */
		vmov start_fdegree, vfp_start_fdegree
		vmov end_fdegree, vfp_end_fdegree

	draw32_arc_fdegree_plus360:
		/* Over 180.0 to 360.0 Degrees */
		vcmp.f32 vfp_start_fdegree, vfp_half
		vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV
		vmovlt start_fdegree, vfp_half
		movle neg_flag, #1

		push {r0-r3}
		mov r0, start_fdegree
		bl math32_fdegree_to_cradian32
		mov r5, r0
		pop {r0-r3}

		/* Make Sure Value of PI Negative */
		cmp neg_flag, #1
		vmoveq vfp_temp, r5
		vnegeq.f32 vfp_temp, vfp_temp
		vmoveq r5, vfp_temp

		push {r0-r3}
		mov r0, end_fdegree
		bl math32_fdegree_to_cradian32
		mov r6, r0
		pop {r0-r3}

		push {r0-r3}
		push {r4-r8}
		bl draw32_arc
		add sp, sp, #20
		cmp r0, #1
		pop {r0-r3}
		beq draw32_arc_fdegree_error                       @ If Error

		b draw32_arc_fdegree_success

	draw32_arc_fdegree_error:
		mov r0, #1
		b draw32_arc_fdegree_common

	draw32_arc_fdegree_success:
		mov r0, #0

	draw32_arc_fdegree_common:
		vpop {s0-s5}
		pop {r4-r10,pc}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			            @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number

.unreq color
.unreq x_coord
.unreq y_coord
.unreq x_radius
.unreq y_radius
.unreq start_fdegree
.unreq end_fdegree
.unreq char_width
.unreq char_height
.unreq temp
.unreq neg_flag
.unreq vfp_d_fdegree
.unreq vfp_start_fdegree
.unreq vfp_end_fdegree
.unreq vfp_zero
.unreq vfp_full
.unreq vfp_half
.unreq vfp_temp


/**
 * function draw32_arc
 * Draw Arc by Radian with Single Precision Float
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 * |Radius| <= PI is Preferred. If you want a circle, use -180 degrees to 180 degrees, i.e., -PI to PI.
 *
 * Parameters
 * r0: Color (16-bit or 32-bit)
 * r1: X Coordinate of Center
 * r2: Y Coordinate of Center
 * r3: X Radius
 * r4: Y Radius
 * r5: Radian on Start of Arc
 * r6: Radian on End of Arc
 * r7: Width of Arc Line
 * r8: Height of Arc Line
 *
 * Return: r0 (0 as success, 1 as error), r1 (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Buffer is Not Defined
 */
.globl draw32_arc
draw32_arc:
	/* Auto (Local) Variables, but just Aliases */
	color            .req r0   @ Parameter, Register for Argument and Result, Scratch Register
	x_coord          .req r1   @ Parameter, Register for Argument and Result, Scratch Register
	y_coord          .req r2   @ Parameter, Register for Argument, Scratch Register
	x_radius         .req r3   @ Parameter, Register for Argument, Scratch Register
	y_radius         .req r4   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	start_radian     .req r5   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	end_radian       .req r6   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_width       .req r7   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_height      .req r8   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	x_current        .req r9
	y_current        .req r10
	flag             .req r11

	/* VFP Registers */
	vfp_d_radian     .req d0 @ q0[0]
	vfp_start_radian .req s0 @ Lower 32 Bits of d0
	vfp_end_radian   .req s1 @ Upper 32 Bits of d0
	vfp_xy_position  .req d1
	vfp_x_position   .req s2 @ Lower 32 Bits of d1
	vfp_y_position   .req s3 @ Upper 32 Bits of d1
	vfp_d_radius     .req d2
	vfp_x_radius     .req s4
	vfp_y_radius     .req s5
	vfp_add          .req s6
	vfp_temp         .req s7

	push {r4-r11}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                   @ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #32                                   @ r4-r11 offset 32 bytes
	pop {y_radius, start_radian, end_radian, char_width, char_height} @ Get Fifth to Ninth Arguments
	sub sp, sp, #52                                   @ Retrieve SP

	vpush {s0-s7}

	vmov vfp_d_radian, start_radian, end_radian
	vcmp.f32 vfp_start_radian, vfp_end_radian
	vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV
	vmovgt vfp_temp, vfp_start_radian
	vmovgt vfp_start_radian, vfp_end_radian
	vmovgt vfp_end_radian, vfp_temp

	vmov vfp_d_radius, x_radius, y_radius
	.unreq x_radius
	temp .req r3
	vcvt.f32.s32 vfp_x_radius, vfp_x_radius
	vcvt.f32.s32 vfp_y_radius, vfp_y_radius

	mov temp, #1
	vmov vfp_add, temp
	vcvt.f32.s32 vfp_add, vfp_add

	vcmp.f32 vfp_x_radius, vfp_y_radius
	vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV
	vmovge vfp_temp, vfp_x_radius
	vmovlt vfp_temp, vfp_y_radius
	vdiv.f32 vfp_add, vfp_add, vfp_temp

	.unreq temp
	.unreq y_radius
	x_current_before .req r3
	y_current_before .req r4

	mov flag, #0                                      @ To Hide to Compare Before/After at First Time

	draw32_arc_loop:
		vcmp.f32 vfp_start_radian, vfp_end_radian
		vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
		bgt draw32_arc_success
		vmov start_radian, vfp_start_radian

		push {r0-r3,lr}
		mov r0, start_radian
		bl math32_cos32
		mov x_current, r0
		pop {r0-r3,lr}

		push {r0-r3,lr}
		mov r0, start_radian
		bl math32_sin32
		mov y_current, r0
		pop {r0-r3,lr}

		vmov vfp_xy_position, x_current, y_current
		vmul.f32 vfp_x_position, vfp_x_position, vfp_x_radius
		vmul.f32 vfp_y_position, vfp_y_position, vfp_y_radius
		vcvtr.s32.f32 vfp_x_position, vfp_x_position
		vcvtr.s32.f32 vfp_y_position, vfp_y_position
		vmov x_current, y_current, vfp_xy_position

		add x_current, x_coord, x_current
		sub y_current, y_coord, y_current                   @ Y Coord is Reversal to Real Y Axis

		cmp flag, #1
		cmpeq x_current, x_current_before
		cmpeq y_current, y_current_before
		beq draw32_arc_loop_common

		push {r0-r3,lr}                                     @ Equals to stmfd (stack pointer full, decrement order)
		mov r1, x_current
		mov r2, y_current
		mov r3, char_width
		push {char_height} 
		bl fb32_block_color
		add sp, sp, #4
		cmp r0, #2                                          @ Compare Return 2
		pop {r0-r3,lr}                                      @ Retrieve Registers Before Error Check, POP does not flags-update
		beq draw32_arc_error

		draw32_arc_loop_common:
			mov flag, #1
			mov x_current_before, x_current
			mov y_current_before, y_current
			vadd.f32 vfp_start_radian, vfp_start_radian, vfp_add

			b draw32_arc_loop

	draw32_arc_error:
		mov r0, #1
		b draw32_arc_common

	draw32_arc_success:
		mov r0, #0

	draw32_arc_common:
		vpop {s0-s7}
		lsl x_current, x_current, #16
		add r1, x_current, y_current
		pop {r4-r11}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			            @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number
		mov pc, lr

.unreq color
.unreq x_coord
.unreq y_coord
.unreq x_current_before
.unreq y_current_before
.unreq start_radian
.unreq end_radian
.unreq char_width
.unreq char_height
.unreq x_current
.unreq y_current
.unreq flag
.unreq vfp_d_radian
.unreq vfp_start_radian
.unreq vfp_end_radian
.unreq vfp_xy_position
.unreq vfp_x_position
.unreq vfp_y_position
.unreq vfp_d_radius
.unreq vfp_x_radius
.unreq vfp_y_radius
.unreq vfp_add
.unreq vfp_temp


/**
 * function draw32_circle
 * Draw Circle Filled with Color
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Color (16-bit or 32-bit)
 * r1: X Coordinate of Center
 * r2: Y Coordinate of Center
 * r3: X Radius
 * r4: Y Radius
 *
 * Usage: r0-r9
 * Return: r0 (0 as success, 1 as error), r1 (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Buffer is Not Defined
 */
.globl draw32_circle
draw32_circle:
	/* Auto (Local) Variables, but just Aliases */
	color            .req r0   @ Parameter, Register for Argument, Scratch Register
	x_coord          .req r1   @ Parameter, Register for Argument and Result, Scratch Register
	y_coord          .req r2   @ Parameter, Register for Argument, Scratch Register
	x_radius         .req r3   @ Parameter, Register for Argument and Result, Scratch Register
	y_radius         .req r4   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_width       .req r5
	char_height      .req r6
	x_current        .req r7
	y_current        .req r8
	y_max            .req r9

	/* VFP Registers */
	vfp_xy_coord     .req d0 @ q0[0]
	vfp_y_coord      .req s0 @ Lower 32 Bits of d0
	vfp_x_coord      .req s1 @ Upper 32 Bits of d0
	vfp_xy_radius    .req d1 @ q0[1]
	vfp_y_radius     .req s2
	vfp_x_radius     .req s3
	vfp_cal_a        .req s4
	vfp_cal_b        .req s5
	vfp_cal_c        .req s6
	vfp_x_start      .req s7
	vfp_diff_radius  .req s8
	vfp_radius       .req s9
	vfp_tri_height   .req s10
	vfp_one          .req s11

	push {r4-r9}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                   @ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #24                                   @ r4-r9 offset 24 bytes
	pop {y_radius}                                    @ Get Fifth
	sub sp, sp, #28                                   @ Retrieve SP

	vpush {s0-s11}

	sub y_current, y_coord, y_radius                  @ First Y Coordinate to Draw
	mov char_height, #1

	add y_max, y_coord, y_radius                      @ As Counter
	sub y_max, y_max, #1                              @ Have Minus One

	vmov vfp_xy_coord, y_coord, x_coord               @ Lower Bits from y_coord, Upper Bits x_coord, q0[0]
	vmov vfp_xy_radius, y_radius, x_radius            @ Lower Bits from y_radius, Upper Bits x_radius, q0[1]
	vcvt.f32.s32 vfp_y_coord, vfp_y_coord             @ Convert Signed Integer to Single Precision Floating Point
	vcvt.f32.s32 vfp_x_coord, vfp_x_coord             @ Convert Signed Integer to Single Precision Floating Point
	vcvt.f32.u32 vfp_y_radius, vfp_y_radius           @ Convert Unsigned Integer to Single Precision Floating Point
	vcvt.f32.u32 vfp_x_radius, vfp_x_radius           @ Convert Unsigned Integer to Single Precision Floating Point

	.unreq y_coord
	x_diff .req r2

	vmov vfp_x_start, vfp_x_coord

	vmov vfp_radius, vfp_y_radius
	vmov vfp_tri_height, vfp_y_radius
	
	mov x_diff, #1
	vmov vfp_one, x_diff
	vcvt.f32.s32 vfp_one, vfp_one

	cmp x_radius, y_radius
	beq draw32_circle_loop

	vsub.f32 vfp_diff_radius, vfp_y_radius, vfp_x_radius

	/**
	 * The difference of Ellipse's radius seems Like a parabola, so It can make an approximation formula by X = Y^2. It show as a line on X axis.
	 * Besides, the difference of position in Free Fall of Physics show as a line on Y axis, and its proportion show as Y = X^2
	 */

	draw32_circle_loop:
		/* Pythagorean theorem C^2 = A^2 + B^2  */
		vmul.f32 vfp_cal_c, vfp_radius, vfp_radius          @ C^2, Hypotenuse
		vmul.f32 vfp_cal_b, vfp_tri_height, vfp_tri_height  @ B^2, Leg, (Height)
		vsub.f32 vfp_cal_a, vfp_cal_c, vfp_cal_b            @ A^2, Leg, (Width)
		vsqrt.f32 vfp_cal_a, vfp_cal_a                      @ A
		
		vsub.f32 vfp_cal_b, vfp_x_start, vfp_cal_a          @ X Current Coordinate
		vcvtr.s32.f32 vfp_cal_b, vfp_cal_b

		vmov x_current, vfp_cal_b

		sub x_diff, x_coord, x_current
		lsl char_width, x_diff, #1                          @ Substitute of Multiplication by 2

		push {r0-r3,lr}                                     @ Equals to stmfd (stack pointer full, decrement order)
		mov r1, x_current
		mov r2, y_current
		mov r3, char_width
		push {char_height} 
		bl fb32_block_color
		add sp, sp, #4
		cmp r0, #2                                          @ Compare Return 2
		pop {r0-r3,lr}                                      @ Retrieve Registers Before Error Check, POP does not flags-update
		beq draw32_circle_error

		cmp y_current,  y_max                               @ Already, y_max Has Been Minus One Before Loop
		bge draw32_circle_success

		add y_current, y_current, #1

		vsub.f32 vfp_tri_height, vfp_tri_height, vfp_one

		cmp x_radius, y_radius
		beq draw32_circle_loop_jump

		/* Add Difference to vfp_x_radius in Case of Ellipse */

		vmov vfp_cal_a, vfp_tri_height
		vabs.f32 vfp_cal_a, vfp_cal_a
		vdiv.f32 vfp_cal_a, vfp_cal_a, vfp_y_radius                @ Compress Range Within 0.0-1.0
		vmul.f32 vfp_cal_a, vfp_cal_a, vfp_cal_a                   @ The Second Power of vfp_cal_a
		vmul.f32 vfp_cal_a, vfp_diff_radius, vfp_cal_a
		vadd.f32 vfp_radius, vfp_x_radius, vfp_cal_a

		draw32_circle_loop_jump:

			b draw32_circle_loop

	draw32_circle_error:
		mov r0, #1
		b draw32_circle_common

	draw32_circle_success:
		mov r0, #0

	draw32_circle_common:
		vpop {s0-s11}
		lsl x_current, x_current, #16
		add r1, x_current, y_current
		pop {r4-r9}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			            @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number
		mov pc, lr

.unreq color
.unreq x_coord
.unreq x_diff
.unreq x_radius
.unreq y_radius
.unreq char_width
.unreq char_height
.unreq x_current
.unreq y_current
.unreq y_max
.unreq vfp_xy_coord
.unreq vfp_y_coord
.unreq vfp_x_coord
.unreq vfp_xy_radius
.unreq vfp_y_radius
.unreq vfp_x_radius
.unreq vfp_cal_a
.unreq vfp_cal_b
.unreq vfp_cal_c
.unreq vfp_x_start
.unreq vfp_diff_radius
.unreq vfp_radius
.unreq vfp_tri_height
.unreq vfp_one


/**
 * function draw32_line
 * Draw Line
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Color (16-bit or 32-bit)
 * r1: X Coordinate1
 * r2: Y Coordinate1
 * r3: X Coordinate2
 * r4: Y Coordinate2
 * r5: Point Width in Pixels, Origin is Upper Left Corner
 * r6: Point Height in Pixels, Origin is Upper Left Corner
 *
 * Usage: r0-r11
 * Return: r0 (0 as success, 1 as error), r1 (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Buffer is Not Defined
 */
.globl draw32_line
draw32_line:
	/* Auto (Local) Variables, but just Aliases */
	color            .req r0   @ Parameter, Register for Argument, Scratch Register
	x_coord_1        .req r1   @ Parameter, Register for Argument and Result, Scratch Register
	y_coord_1        .req r2   @ Parameter, Register for Argument, Scratch Register
	x_coord_2        .req r3   @ Parameter, Register for Argument and Result, Scratch Register
	y_coord_2        .req r4   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_width       .req r5   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_height      .req r6   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	x_current        .req r7
	y_current        .req r8
	y_diff           .req r9   @ Counter
	dup_char_width   .req r10
	y_direction      .req r11  @ 1 is to Lower Right (Y Increment), -1 is to Upper Right (Y Decrement)

	/* VFP Registers */
	vfp_xy_coord_1   .req d0 @ q0[0]
	vfp_y_coord_1    .req s0 @ Lower 32 Bits of d0
	vfp_x_coord_1    .req s1 @ Upper 32 Bits of d0
	vfp_xy_coord_2   .req d1 @ q0[1]
	vfp_y_coord_2    .req s2
	vfp_x_coord_2    .req s3
	vfp_y_coord_3    .req s4
	vfp_x_coord_3    .req s5
	vfp_char_width   .req s6
	vfp_x_per_y      .req s7 @ Uses to Determine char_width
	vfp_x_start      .req s8
	vfp_x_current    .req s9
	vfp_i            .req s10
	vfp_one          .req s11

	push {r4-r11}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                    @ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #32                                  @ r4-r11 offset 32 bytes
	pop {y_coord_2,char_width,char_height}           @ Get Fifth to Seventh Arguments
	sub sp, sp, #44                                  @ Retrieve SP

	vpush {s0-s11}

	mov dup_char_width, char_width                 @ Use on the Last Point

	cmp y_coord_1, y_coord_2
	bge draw32_line_coordge
	blt draw32_line_coordlt

	draw32_line_coordge:                     @ `If ( y_coord_1 >= y_coord_2 )`
		sub y_diff, y_coord_1, y_coord_2
		cmp x_coord_1, x_coord_2

		movge x_current, x_coord_2               @ `If ( x_coord_1 >= x_coord_2 )`, Get X Start Point
		movge y_current, y_coord_2               @ Get Y Start Point
		movge y_direction, #1                    @ Draw to Lower Right

		movlt x_current, x_coord_1               @ `If ( x_coord_1 < x_coord_2 )`, Get X Start Point
		movlt y_current, y_coord_1               @ Get Y Start Point
		movlt y_direction, #-1                   @ Draw to Upper Right
		b draw32_line_coord

	draw32_line_coordlt:                      @ `If ( y_coord_1 < y_coord_2 )`
		sub y_diff, y_coord_2, y_coord_1
		cmp x_coord_1, x_coord_2

		movge x_current, x_coord_2               @ `If ( x_coord_1 >= x_coord_2 )`, Get X Start Point
		movge y_current, y_coord_2               @ Get Y Start Point
		movge y_direction, #-1                   @ Draw to Upper Right

		movlt x_current, x_coord_1               @ `If ( x_coord_1 < x_coord_2 )`, Get X Start Point
		movlt y_current, y_coord_1               @ Get Y Start Point
		movlt y_direction, #1                    @ Draw to Lower Right

	draw32_line_coord:
		vmov vfp_xy_coord_1, y_coord_1, x_coord_1     @ Lower Bits from y_coord_n, Upper Bits x_coord_n, q0[0]
		vmov vfp_xy_coord_2, y_coord_2, x_coord_2     @ Lower Bits from y_coord_n, Upper Bits x_coord_n, q0[1]
		vcvt.f32.s32 vfp_y_coord_1, vfp_y_coord_1     @ Convert Signed Integer to Single Precision Floating Point
		vcvt.f32.s32 vfp_x_coord_1, vfp_x_coord_1     @ Convert Signed Integer to Single Precision Floating Point
		vcvt.f32.s32 vfp_y_coord_2, vfp_y_coord_2     @ Convert Signed Integer to Single Precision Floating Point
		vcvt.f32.s32 vfp_x_coord_2, vfp_x_coord_2     @ Convert Signed Integer to Single Precision Floating Point

		/* Subtract Each 32-Bit Lane as Single Precision */
		vsub.f32 vfp_y_coord_3, vfp_y_coord_1, vfp_y_coord_2
		vsub.f32 vfp_x_coord_3, vfp_x_coord_1, vfp_x_coord_2

		vcmp.f32 vfp_y_coord_3, #0
		vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
		vmoveq vfp_x_per_y, vfp_x_coord_3             @ If difference of Y is Zero, Just X per Y is X Difference
		vdivne.f32 vfp_x_per_y, vfp_x_coord_3, vfp_y_coord_3
		vabs.f32 vfp_x_per_y, vfp_x_per_y             @ Calculate Absolute Value of X Width per One Y Pixel

		vcmp.f32 vfp_x_coord_1, vfp_x_coord_2
		vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
		vmovge vfp_x_start, vfp_x_coord_2             @ Get X Start Point to Calculate in VFP
		vmovlt vfp_x_start, vfp_x_coord_1             @ Get X Start Point to Calculate in VFP

		/* Add Character Width to Calculated Value to Draw */
		vmov vfp_char_width, char_width
		vcvt.f32.s32 vfp_char_width, vfp_char_width
		vadd.f32 vfp_char_width, vfp_char_width, vfp_x_per_y
		vcvtr.s32.f32 vfp_char_width, vfp_char_width
		vmov char_width, vfp_char_width

		/*cmp char_width, #0*/
		/*moveq char_width, #1*/

		.unreq x_coord_1
		i      .req r1

		mov i, #0
		vmov vfp_i, i
		vcvt.f32.s32 vfp_i, vfp_i

		mov i, #1
		vmov vfp_one, i
		vcvt.f32.s32 vfp_one, vfp_one

	draw32_line_loop:

		push {r0-r3,lr}                                @ Equals to stmfd (stack pointer full, decrement order)
		mov r1, x_current
		mov r2, y_current
		mov r3, char_width
		push {char_height} 
		bl fb32_block_color
		add sp, sp, #4
		cmp r0, #2                                     @ Compare Return 2
		pop {r0-r3,lr}                                 @ Retrieve Registers Before Error Check, POP does not flags-update

		beq draw32_line_error

		draw32_line_loop_common:
			add i, i, #1
			cmp i, y_diff
			bhi draw32_line_success
			moveq char_width, dup_char_width           @ To hide Width Overflow on End Point (Except Original char_width)

			add y_current, y_current, y_direction

			vadd.f32 vfp_i, vfp_i, vfp_one
			vmov vfp_x_current, vfp_x_start
			vmla.f32 vfp_x_current, vfp_x_per_y, vfp_i    @ Multiply and Accumulate Fd = Fd + (Fn * Fm)
			vcvtr.s32.f32 vfp_x_current, vfp_x_current    @ In VFP Instructions, You Can Convert with Rounding Mode

			vmov x_current, vfp_x_current

			b draw32_line_loop

	draw32_line_error:
		mov r0, #1
		b draw32_line_common

	draw32_line_success:
		mov r0, #0

	draw32_line_common:
		vpop {s0-s11}
		lsl x_current, x_current, #16
		add r1, x_current, y_current
		pop {r4-r11}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			            @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number
		mov pc, lr

.unreq color
.unreq i
.unreq y_coord_1
.unreq x_coord_2
.unreq y_coord_2
.unreq char_width
.unreq char_height
.unreq x_current
.unreq y_current
.unreq y_diff
.unreq dup_char_width
.unreq y_direction
.unreq vfp_xy_coord_1
.unreq vfp_y_coord_1
.unreq vfp_x_coord_1
.unreq vfp_xy_coord_2
.unreq vfp_y_coord_2
.unreq vfp_x_coord_2
.unreq vfp_y_coord_3
.unreq vfp_x_coord_3
.unreq vfp_char_width
.unreq vfp_x_per_y
.unreq vfp_x_start
.unreq vfp_x_current
.unreq vfp_i
.unreq vfp_one
