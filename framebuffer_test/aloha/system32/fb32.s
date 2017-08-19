/**
 * fb32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function fb32_rgba_to_argb
 * Convert 32-bit Depth Color RBGA to ARGB
 *
 * Parameters
 * r0: Pointer of Data to Convert Endianness
 * r1: Size of Data 
 *
 * Usage: r0-r2
 * Return: r0 (0 as sucess)
 */
.globl fb32_rgba_to_argb
fb32_rgba_to_argb:
	/* Auto (Local) Variables, but just aliases */
	data_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	size            .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	swap            .req r2

	add size, size, data_point

	fb32_rgba_to_argb_loop:
		cmp data_point, size
		bge fb32_rgba_to_argb_success

		ldr swap, [data_point]
		ror swap, #8                    @ Rotate Right 8 Bits
		str swap, [data_point]
		add data_point, data_point, #4

		b fb32_rgba_to_argb_loop

	fb32_rgba_to_argb_success:
		mov r0, #0

	fb32_rgba_to_argb_common:
		mov pc, lr

.unreq data_point
.unreq size
.unreq swap


/**
 * function fb32_draw_line
 * Draw Line
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
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
 * Return: r0 (0 as sucess, 1 and more as error), r1 (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Points Which Were Not Drawn
 * Global Enviromental Variable(s): FB32_WIDTH, FB32_HEIGHT
 */
.globl fb32_draw_line
fb32_draw_line:
	/* Auto (Local) Variables, but just aliases */
	color            .req r0   @ Parameter, Register for Argument, Scratch Register
	x_coord_1        .req r1   @ Parameter, Register for Argument and Result, Scratch Register
	y_coord_1        .req r2   @ Parameter, Register for Argument, Scratch Register
	x_coord_2        .req r3   @ Parameter, Register for Argument and Result, Scratch Register
	y_coord_2        .req r4   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_width       .req r5   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_height      .req r6   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	x_current        .req r7
	y_current        .req r8
	x_diff           .req r9   @ Counter
	dup_char_height  .req r10
	x_direction      .req r11  @ 1 is to Lower Right (X Increment), -1 is to Lower Left (X Decrement)

	/* VFP/NEON Registers */
	vfp_xy_coord_1   .req d0 @ q0[0]
	vfp_y_coord_1    .req s0 @ Lower 32 Bits of d0
	vfp_x_coord_1    .req s1 @ Upper 32 Bits of d0
	vfp_xy_coord_2   .req d1 @ q0[1]
	vfp_y_coord_2    .req s2
	vfp_x_coord_2    .req s3
	vfp_xy_coord_3   .req d2
	vfp_y_coord_3    .req s4
	vfp_x_coord_3    .req s5
	vfp_char_height  .req s6
	vfp_y_per_x      .req s7 @ Uses to Determine char_width
	vfp_y_start      .req s8
	vfp_y_current    .req s9
	vfp_i            .req s10
	vfp_one          .req s11

	push {r4-r11}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                    @ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #32                                  @ r4-r11 offset 32 bytes
	pop {y_coord_2,char_width,char_height}           @ Get Fifth to Seventh Arguments
	sub sp, sp, #44                                  @ Retrieve SP

	vpush {s0-s11}

	mov dup_char_height, char_height                 @ Use on the Last Point

	cmp x_coord_1, x_coord_2
	bge fb32_draw_line_coordge
	blt fb32_draw_line_coordlt

	fb32_draw_line_coordge:                          @ `If ( x_coord_1 >= x_coord_2 )`
		sub x_diff, x_coord_1, x_coord_2
		cmp y_coord_1, y_coord_2

		movge x_current, x_coord_2               @ `If ( y_coord_1 >= y_coord_2 )`
		movge y_current, y_coord_2               @ Get Y Start Point
		movge x_direction, #1                    @ Draw to Lower Right

		movlt x_current, x_coord_1               @ `If ( y_coord_1 < y_coord_2 )`
		movlt y_current, y_coord_1               @ Get Y Start Point
		movlt x_direction, #-1                   @ Draw to Lower Left
		b fb32_draw_line_coord

	fb32_draw_line_coordlt:                          @ `If ( x_coord_1 < x_coord_2 )`
		sub x_diff, x_coord_2, x_coord_1
		cmp y_coord_1, y_coord_2

		movge x_current, x_coord_2               @ `If ( y_coord_1 >= y_coord_2 )`
		movge y_current, y_coord_2               @ Get Y Start Point
		movge x_direction, #-1                   @ Draw to Lower Left

		movlt x_current, x_coord_1               @ `If ( y_coord_1 < y_coord_2 )`
		movlt y_current, y_coord_1               @ Get Y Start Point
		movlt x_direction, #1                    @ Draw to Lower Right

	fb32_draw_line_coord:
		vmov vfp_xy_coord_1, y_coord_1, x_coord_1     @ Lower Bits from y_coord_n, Upper Bits x_coord_n, q0[0]
		vmov vfp_xy_coord_2, y_coord_2, x_coord_2     @ Lower Bits from y_coord_n, Upper Bits x_coord_n, q0[1]
		vcvt.f32.s32 q0, q0                           @ *NEON*Convert Signed Integer to Single Precision Floating Point

		/* *NEON*Subtract Each 32-Bit Lane as Single Precision */
		vsub.f32 vfp_xy_coord_3, vfp_xy_coord_1, vfp_xy_coord_2

		vcmp.f32 vfp_x_coord_3, #0
		vmoveq vfp_x_coord_3, #1.0                    @ If difference of X is Zero, Add One to Hide
		vdiv.f32 vfp_y_per_x, vfp_y_coord_3, vfp_x_coord_3
		vabs.f32 vfp_y_per_x, vfp_y_per_x             @ Calculate Absolute Value of Y Length per One X Pixel

		vcmp.f32 vfp_y_coord_1, vfp_y_coord_2
		vmovge vfp_y_start, vfp_y_coord_2             @ Get Y Start Point to Calculate in VFP
		vmovlt vfp_y_start, vfp_y_coord_1             @ Get Y Start Point to Calculate in VFP

		/* Add Character Height to Calculated Value to Draw */
		vmov vfp_char_height, char_height
		vcvt.f32.s32 vfp_char_height, vfp_char_height
		vadd.f32 vfp_char_height, vfp_char_height, vfp_y_per_x
		vcvtr.s32.f32 vfp_char_height, vfp_char_height
		vmov char_height, vfp_char_height

		.unreq x_coord_1
		.unreq y_coord_1
		.unreq x_coord_2
		i      .req r1
		width  .req r2
		height .req r3

		mov i, #0
		vmov vfp_i, i
		vcvt.f32.s32 vfp_i, vfp_i
		vmov vfp_one, #1.0                             @ Floating Point Constant (Immediate)

		ldr width, FB32_WIDTH
		ldr height, FB32_HEIGHT

	fb32_draw_line_loop:
		cmp x_current, #0
		blt fb32_draw_line_loop_common
		cmp y_current, #0
		blt fb32_draw_line_loop_common
		cmp x_current, width
		bge fb32_draw_line_loop_common
		cmp y_current, height
		bge fb32_draw_line_loop_common

		push {r0-r3,lr}                          @ Equals to stmfd (stack pointer full, decrement order)
		mov r1, x_current
		mov r2, y_current
		mov r3, char_width
		push {char_height} 
		bl fb32_clear_color_block
		add sp, sp, #4
		push {r1}
		add sp, sp, #4
		cmp r0, #0                               @ Compare Return 0 or 1
		pop {r0-r3,lr}                           @ Retrieve Registers Before Error Check, POP does not flags-update
		bne fb32_draw_line_error

		fb32_draw_line_loop_common:

			add x_current, x_current, x_direction

			add i, i, #1
			vadd.f32 vfp_i, vfp_i, vfp_one

			cmp i, x_diff
			bgt fb32_draw_line_common
			moveq char_height, dup_char_height            @ To hide Height Overflow on End Point (Except Original char_height)

			vmov vfp_y_current, vfp_y_start
			vmla.f32 vfp_y_current, vfp_y_per_x, vfp_i    @ Multiply and Accumulate Fd = Fd + (Fn * Fm)
			vcvtr.s32.f32 vfp_y_current, vfp_y_current    @ In VFP Instructions, You Can Convert with Rounding Mode
			vmov y_current, vfp_y_current

			b fb32_draw_line_loop

	fb32_draw_line_error:
		sub i, i, #1                                  @ Adjust for Not Completed Point
		sub x_diff, x_diff, i
		mov r0, x_diff

	fb32_draw_line_common:
		vpop {s0-s11}
		lsl x_current, x_current, #16
		add r1, x_current, y_current
		pop {r4-r11}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			            @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number
		mov pc, lr

.unreq color
.unreq i
.unreq width
.unreq height
.unreq y_coord_2
.unreq char_width
.unreq char_height
.unreq x_current
.unreq y_current
.unreq x_diff
.unreq dup_char_height
.unreq x_direction
.unreq vfp_xy_coord_1
.unreq vfp_y_coord_1
.unreq vfp_x_coord_1
.unreq vfp_xy_coord_2
.unreq vfp_y_coord_2
.unreq vfp_x_coord_2
.unreq vfp_xy_coord_3
.unreq vfp_y_coord_3
.unreq vfp_x_coord_3
.unreq vfp_char_height
.unreq vfp_y_per_x
.unreq vfp_y_start
.unreq vfp_y_current
.unreq vfp_i
.unreq vfp_one


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
 * Global Enviromental Variable(s): FB32_ADDRESS, FB32_SIZE, FB32_DEPTH
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

	ldr fb_buffer, FB32_ADDRESS
	cmp fb_buffer, #0
	beq fb32_copy_error

	ldr size, FB32_SIZE
	cmp size, #0
	beq fb32_copy_error

	ldr depth, FB32_DEPTH
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
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Parameters
 * r0: Pointer of Image
 * r1: X Coordinate
 * r2: Y Coordinate
 * r3: Character Width in Pixels
 * r4: Character Height in Pixels
 * (Callee ip, Caller r5): X Offset (Upper Left Position X)
 * (Callee ip, Caller r6): Y Offset (Upper Left Position Y)
 * (Callee ip, Caller r7): X Crop (Lower Right Position X)
 * (Callee ip, Caller r8): Y Crop (Lower Right Position Y)
 *
 * Usage: r0-r12
 * Return: r0 (0 as sucess, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 * Global Enviromental Variable(s): FB32_ADDRESS, FB32_WIDTH, FB32_SIZE, FB32_DEPTH
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
	x_crop_char      .req r12 @ ip is Alias of r12, This Function Uses r12 as ip Too. x_crop_char Uses After Usage as ip

	/* VFP/NEON Registers */
	vfp_src         .req q0
	vfp_src_lower   .req d0
	vfp_src_upper   .req d1
	vfp_src_blue    .req s0
	vfp_src_green   .req s1
	vfp_src_red     .req s2
	vfp_src_alpha   .req s3
	vfp_dst         .req q1
	vfp_dst_lower   .req d2
	vfp_dst_upper   .req d3
	vfp_dst_blue    .req s4
	vfp_dst_green   .req s5
	vfp_dst_red     .req s6
	vfp_dst_alpha   .req s7
	vfp_cal         .req q2
	vfp_cal_lower   .req d4
	vfp_cal_upper   .req d5
	vfp_cal_a       .req s8
	vfp_cal_b       .req s9
	vfp_cal_c       .req s10
	vfp_cal_d       .req s11
	vfp_out         .req q3
	vfp_out_lower   .req d6
	vfp_out_upper   .req d7
	vfp_out_blue    .req s12
	vfp_out_green   .req s13
	vfp_out_red     .req s14
	vfp_out_alpha   .req s15
	vfp_divider     .req s16

	push {r4-r11}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                    @ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #32                                  @ r4-r11 offset 32 bytes
	pop {char_height}                                @ Get Fifth and Sixth Arguments
	sub sp, sp, #36                                  @ Retrieve SP

	vpush {s0-s16}                                   @ 4 Bytes x 17, 68 Bytes Slide of SP, Know for ip and Stack Usage

	ldr f_buffer, FB32_ADDRESS
	cmp f_buffer, #0
	beq fb32_draw_image_error2

	ldr width, FB32_WIDTH
	cmp width, #0
	beq fb32_draw_image_error2

	ldr depth, FB32_DEPTH
	cmp depth, #0
	beq fb32_draw_image_error2
	cmp depth, #32
	cmpne depth, #16
	bne fb32_draw_image_error2

	ldr size, FB32_SIZE
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

	ldr ip, [sp, #108]                               @ Load Y Offset Arm 40 Bytes + VFP 68 Bytes Away from Current SP
	cmp ip, #0
	subgt char_height, char_height, ip               @ Subtract Y Offset (ip) value from char_height
	mulgt ip, char_width_bytes, ip
	addgt image_point, image_point, ip

	ldr ip, [sp, #116]                               @ Load Y Crop, Arm 48 Bytes + VFP 68 Bytes Away from Current SP
	cmp ip, #0
	subgt char_height, char_height, ip               @ Subtract Y Crop (ip) value from char_height
	
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
		ldr ip, [sp, #104]                       @ Load X Offset, Arm 36 Bytes + VFP 68 Bytes Away From Current SP
		cmp ip, #0
		ble fb32_draw_image_xcrop

		sub char_width, char_width, ip           @ Subtract X Offset (ip) value from char_width

		cmp depth, #16
		lsleq ip, ip, #1                         @ X Offset Bytes, substitution of Multiplication by 2 (No Minus)
		cmp depth, #32
		lsleq ip, ip, #2                         @ X Offset Bytes, substitution of Multiplication by 4 (No Minus)

		add x_offset_char, x_offset_char, ip

	fb32_draw_image_xcrop:
		ldr ip, [sp, #112]                       @ Load X Crop, Arm 44 Bytes + VFP 68 Bytes Away From Current SP
		cmp ip, #0
		movle x_crop_char, #0
		ble fb32_draw_image_loop

		sub char_width, char_width, ip           @ Subtract X Crop (ip) value from char_width

		cmp depth, #16
		lsleq x_crop_char, ip, #1                @ X Crop Bytes, substitution of Multiplication by 2 (No Minus)
		cmp depth, #32
		lsleq x_crop_char, ip, #2                @ X Crop Bytes, substitution of Multiplication by 4 (No Minus)

	fb32_draw_image_loop:
		cmp f_buffer, size                           @ Check Overflow of Framebuffer Memory
		bgt fb32_draw_image_error1

		cmp char_height, #0                          @ Vertical Counter `(; char_height > 0; char_height--)`
		movle r0, #0                                 @ Return with Success
		ble fb32_draw_image_common

		add image_point, image_point, x_offset_char  @ Add X Offset Bytes

		mov j, char_width                            @ Horizontal Counter `(int j = char_width; j >= 0; --j)`

		fb32_draw_image_loop_horizontal:
			sub j, j, #1                                 @ For Bit Allocation (Horizontal Character Bit)
			cmp j, #0                                    @ Horizontal Counter, Check
			blt fb32_draw_image_loop_common

			/* The Picture Process of Depth 16 Bits */
			cmp depth, #16
			bne fb32_draw_image_loop_horizontal_depth32
			ldrh color, [image_point]                    @ Load half word
			strh color, [f_buffer]                       @ Store half word
			b fb32_draw_image_loop_horizontal_common

			fb32_draw_image_loop_horizontal_depth32:
				/* The Picture Process of Depth 32 Bits */
				ldr color, [image_point]                     @ Load word

				cmp color, #0xFF000000                             @ If Alpha is Fully Opaque
				bhs fb32_draw_image_loop_horizontal_depth32_common @ Unsigned Higher or Same

				cmp color, #0x01000000                             @ If Alpha is Fully Transparent
				blo fb32_draw_image_loop_horizontal_common         @ Unsigned Less (Lower)

				/** 
				 * Alpha Blending
				 * Porter-Duff Src-over
				 *
				 * OUT_Alpha = SRC_Alpha + (DST_Alpha x (1 - SRC_Alpha))
				 * OUT_RGB = ((SRC_RGB x SRC_Alpha) + (DST_RGB x (DST_Alpha x (1 - SRC_Alpha)))) Div by OUT_Alpha
				 * If OUT_Alpha = 0,  OUT_RGB = 0
				 */

				/* SRC */
				and depth, color, #0xFF
				vmov vfp_src_blue, depth                           @ Blue of SRC
				and depth, color, #0xFF00
				lsr depth, depth, #8
				vmov vfp_src_green, depth                          @ Green of SRC
				and depth, color, #0xFF0000
				lsr depth, depth, #16
				vmov vfp_src_red, depth                            @ Red of SRC
				and depth, color, #0xFF000000
				lsr depth, depth, #24
				vmov vfp_src_alpha, depth                          @ Alpha of SRC
				vcvt.f32.u32 vfp_src, vfp_src                      @ *NEON*Convert Unsigned Integer to Single Precision Floating Point

				/* DST */
				ldr color, [f_buffer]

				and depth, color, #0xFF
				vmov vfp_dst_blue, depth                           @ Blue of DST
				and depth, color, #0xFF00
				lsr depth, depth, #8
				vmov vfp_dst_green, depth                          @ Green of DST
				and depth, color, #0xFF0000
				lsr depth, depth, #16
				vmov vfp_dst_red, depth                            @ Red of DST
				and depth, color, #0xFF000000
				lsr depth, depth, #24
				vmov vfp_dst_alpha, depth                          @ Alpha of DST
				vcvt.f32.u32 vfp_dst, vfp_dst                      @ *NEON*Convert Unsigned Integer to Single Precision Floating Point

				/* Clean Color Register */
				mov color, #0

				/* Sanitize OUT_ARGB */
				mov depth, #0
				vdup.32 vfp_out, depth
				vcvt.f32.u32 vfp_out, vfp_out

				/* Alpha divider to Range within 0.0-1.0 */
				mov depth, #255
				vmov vfp_divider, depth
				vcvt.f32.u32 vfp_divider, vfp_divider
				vdiv.f32 vfp_src_alpha, vfp_src_alpha, vfp_divider
				vdiv.f32 vfp_dst_alpha, vfp_dst_alpha, vfp_divider

				/* DST_Alpha x (1 - SRC_Alpha) to vfp_cal_a */
				vmov vfp_cal_a, #1.0 
				vsub.f32 vfp_cal_b, vfp_cal_a, vfp_src_alpha
				vmul.f32 vfp_cal_a, vfp_dst_alpha, vfp_cal_b

				/* OUT_Alpha, SRC_Alpha + (DST_RGB x (DST_Alpha x (1 - SRC_Alpha))) to vfp_out_alpha */
				vadd.f32 vfp_out_alpha, vfp_src_alpha, vfp_cal_a

				/* Compare OUT_Alpha to Zero */
				vcmp.f32 vfp_out_alpha, #0
				vmrs apsr_nzcv, fpscr                             @ Transfer FPSCR Flags to CPSR's NZCV Flags (APSR)
				beq fb32_draw_image_loop_horizontal_depth32_alphablend

				/* DST_RGB x (DST_Alpha x (1 - SRC_Alpha)) to vfp_dst */
				vdup.f32 vfp_cal, vfp_cal_lower[0]                @ NEON Side Name of vfp_cal_a
				vmul.f32 vfp_dst, vfp_dst, vfp_cal                @ *NEON*

				/* SRC_RGB x SRC_Alpha to vfp_src */
				vdup.f32 vfp_cal, vfp_src_upper[1]                @ NEON Side Name of vfp_src_alpha
				vmul.f32 vfp_src, vfp_src, vfp_cal                @ *NEON*

				/* (SRC_RGB x SRC_Alpha) + (DST_RGB x (DST_Alpha x (1 - SRC_Alpha))) to vfp_dst */
				vadd.f32 vfp_dst, vfp_dst, vfp_src                @ *NEON*

				/* OUT_RGB, ((SRC_RGB x SRC_Alpha) + (DST_RGB x (DST_Alpha x (1 - SRC_Alpha)))) Div by OUT_Alpha to vfp_out */
				vmov vfp_src_alpha, vfp_out_alpha                 @ Store to Retrieve
				vmov vfp_cal_a, #1.0
				vmov vfp_cal_b, vfp_out_alpha
				vdiv.f32 vfp_cal_a, vfp_cal_a, vfp_cal_b
				vdup.f32 vfp_cal, vfp_cal_lower[0]                @ NEON Side Name of vfp_cal_a
				vmul.f32 vfp_out, vfp_dst, vfp_cal

				/* Retrieve OUT_Alpha to Range within 0 to 255 */
				vmov vfp_out_alpha, vfp_src_alpha
				vmul.f32 vfp_out_alpha, vfp_out_alpha, vfp_divider

				fb32_draw_image_loop_horizontal_depth32_alphablend:
					vcvtr.u32.f32 vfp_out, vfp_out            @ *NEON*Convert Single Precision Floating Point to Unsinged Integer
					vmov depth, vfp_out_blue
					add color, color, depth
					vmov depth, vfp_out_green
					lsl depth, depth, #8
					add color, color, depth
					vmov depth, vfp_out_red
					lsl depth, depth, #16
					add color, color, depth
					vmov depth, vfp_out_alpha
					lsl depth, depth, #24
					add color, color, depth

					mov depth, #32

				fb32_draw_image_loop_horizontal_depth32_common:
					str color, [f_buffer]                    @ Store word

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
			lsleq j, char_width, #1                   @ substitution of Multiplication by 2
			cmp depth, #32
			lsleq j, char_width, #2                   @ substitution of Multiplication by 4
			sub f_buffer, f_buffer, j                 @ Offset Clear of Framebuffer

			add f_buffer, f_buffer, width             @ Horizontal Sync (Framebuffer)

			add width_check, width_check, width       @ Store the Limitation of Width on the Next Y Coordinate

			add image_point, image_point, x_crop_char @ Add X Crop Bytes

			b fb32_draw_image_loop

	fb32_draw_image_error1:
		mov r0, #1                                   @ Return with Error 1
		b fb32_draw_image_common

	fb32_draw_image_error2:
		mov r0, #2                                   @ Return with Error 2

	fb32_draw_image_common:
		vpop {s0-s16}
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
.unreq x_crop_char
.unreq vfp_src
.unreq vfp_src_lower
.unreq vfp_src_upper
.unreq vfp_src_blue
.unreq vfp_src_green
.unreq vfp_src_red
.unreq vfp_src_alpha
.unreq vfp_dst
.unreq vfp_dst_lower
.unreq vfp_dst_upper
.unreq vfp_dst_blue
.unreq vfp_dst_green
.unreq vfp_dst_red
.unreq vfp_dst_alpha
.unreq vfp_cal
.unreq vfp_cal_lower
.unreq vfp_cal_upper
.unreq vfp_cal_a
.unreq vfp_cal_b
.unreq vfp_cal_c
.unreq vfp_cal_d
.unreq vfp_out
.unreq vfp_out_lower
.unreq vfp_out_upper
.unreq vfp_out_blue
.unreq vfp_out_green
.unreq vfp_out_red
.unreq vfp_out_alpha
.unreq vfp_divider


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
 * Global Enviromental Variable(s): FB32_ADDRESS, FB32_WIDTH, FB32_SIZE, FB32_DEPTH
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

	ldr f_buffer, FB32_ADDRESS
	cmp f_buffer, #0
	beq fb32_clear_color_block_error2

	ldr width, FB32_WIDTH
	cmp width, #0
	beq fb32_clear_color_block_error2

	ldr depth, FB32_DEPTH
	cmp depth, #0
	beq fb32_clear_color_block_error2
	cmp depth, #32
	cmpne depth, #16
	bne fb32_clear_color_block_error2

	ldr size, FB32_SIZE
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
 * Global Enviromental Variable(s): FB32_ADDRESS, FB32_SIZE, FB32_DEPTH
 */
.globl fb32_clear_color
fb32_clear_color:
	color             .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	fb_buffer         .req r1
	size              .req r2
	depth             .req r3
	length            .req r4

	push {r4}

	ldr fb_buffer, FB32_ADDRESS
	cmp fb_buffer, #0
	beq fb32_clear_color_error

	ldr size, FB32_SIZE
	cmp size, #0
	beq fb32_clear_color_error

	ldr depth, FB32_DEPTH
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
 * Global Enviromental Variable(s): FB32_ADDRESS
 * External Variable(s): fb32_mail_framebuffer_addr
 */
.globl fb32_get
fb32_get:
	memorymap_base    .req r0
	temp              .req r1

	ldr temp, fb32_mail_framebuffer_addr
	add temp, temp, #equ32_mailbox_gpuoffset|equ32_mailbox_channel8
	push {r0-r3,lr}
	mov r0, temp
	mov r1, #0
	bl system32_mailbox_send
	mov r0, #0
	bl system32_mailbox_read
	pop {r0-r3,lr}

	ldr memorymap_base, fb32_mail_framebuffer_addr
	ldr temp, [memorymap_base, #equ32_mailbox_gpuconfirm]
	cmp temp, #0x80000000
	bne fb32_get_error

	ldr memorymap_base, FB32_ADDRESS
	cmp memorymap_base, #0
	beq fb32_get_error

	and memorymap_base, memorymap_base, #equ32_fb_armmask            @ Change FB32_ADDRESS VideoCore's to ARM's
	str memorymap_base, FB32_ADDRESS                                 @ Store ARM7s FB32_ADDRESS

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
.globl FB32_X_CARET
.globl FB32_Y_CARET
FB32_X_CARET: .word 0x00000000
FB32_Y_CARET: .word 0x00000000

/* Frame Buffer Physical */

.balign 16                      @ Need of 16 bytes align
.globl FB32_DISPLAY_WIDTH
.globl FB32_DISPLAY_HEIGHT
.globl FB32_WIDTH
.globl FB32_HEIGHT
.globl FB32_DEPTH
.globl FB32_PIXELORDER
.globl FB32_ALPHAMODE
.globl FB32_ADDRESS
.globl FB32_SIZE
fb32_mail_framebuffer:
	.word fb32_mail_framebuffer_end - fb32_mail_framebuffer @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
fb32_mail_contents:
	.word 0x00048003        @ Tag Identifier, Set Physical Width/Height (Size in Physical Display)
	.word 0x00000008        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
FB32_DISPLAY_WIDTH:
	.word 800               @ Value Buffer, Width in Pixels
FB32_DISPLAY_HEIGHT:
	.word 640               @ Value Buffer, Height in Pixels
.balign 4
	.word 0x00048004        @ Tag Identifier, Set Virtual Width/Height (Actual Buffer Size just like Viewport in OpenGL)
	.word 0x00000008        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
FB32_WIDTH:
	.word 800               @ Value Buffer, Width in Pixels
FB32_HEIGHT:
	.word 640               @ Value Buffer, Height in Pixels
.balign 4
	.word 0x00048005        @ Tag Identifier, Set Depth
	.word 0x00000004        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
FB32_DEPTH:
	.word 16                @ Value Buffer, Bits per Pixel, 32 would be 32 ARGB
.balign 4
	.word 0x00048006        @ Tag Identifier, Set Pixel Order
	.word 0x00000004        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
FB32_PIXELORDER:
	.word 0x01              @ 0x00 is BGR, 0x01 is RGB
.balign 4
	.word 0x00048007        @ Tag Identifier, Set Alpha Mode (This Value is just for INNER of VideoCore, NOT CPU SIDE)
	.word 0x00000004        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
FB32_ALPHAMODE:
	.word 0x00              @ 0x00 is Enabled(0:Fully Opaque<exist>), 0x01 is Reversed(0:Fully Transparent), 0x02 is Ignored
.balign 4
	.word 0x00040001        @ Tag Identifier, Allocate Buffer
	.word 0x00000008        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
FB32_ADDRESS:
	.word 0x00000000        @ Value Buffer, Alignment in Bytes (in Response, Frame Buffer Base Address in Bytes)
FB32_SIZE:
	.word 0x00000000        @ Value Buffer, Reserved for Response (in Response, Frame Buffer Size in Bytes)
.balign 4
	.word 0x00000000        @ End Tag
fb32_mail_framebuffer_end:
.balign 16

fb32_mail_blankon:
	.word fb32_mail_blankon_end - fb32_mail_blankon @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00040002        @ Tag Identifier, Blank Screen
	.word 0x00000004        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
	.word 0x00000001        @ Value Buffer, State (0 means off, 1 means on)
.balign 4
	.word 0x00000000        @ End Tag
fb32_mail_blankon_end:
.balign 16

fb32_mail_blankoff:
	.word fb32_mail_blankoff_end - fb32_mail_blankoff @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00040002        @ Tag Identifier, Blank Screen
	.word 0x00000004        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
	.word 0x00000000        @ Value Buffer, State (0 means off, 1 means on)
.balign 4
	.word 0x00000000        @ End Tag
fb32_mail_blankoff_end:
.balign 16

fb32_mail_getedid:                   @ get EDID (Extended Display Identification Data) from Disply to Get Display Resolution ,etc.
	.word fb32_mail_getedid_end - fb32_mail_getedid @ Size of this Mail
	.word 0x00000000        @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00030020        @ Tag Identifier, get EDID
	.word 0x00000136        @ Value Buffer Size in Bytes
	.word 0x00000000        @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
	.word 0x00000000        @ EDID Block Number Requested/ Responded
	.word 0x00000000        @ Status
.fill 128, 1, 0x00              @ 128 * 1 byte EDID Block
.balign 4
	.word 0x00000000        @ End Tag
fb32_mail_getedid_end:
.balign 16

fb32_mail_framebuffer_addr:
	.word fb32_mail_framebuffer  @ Address of fb32_mail_framebuffer
fb32_mail_blankon_addr:
	.word fb32_mail_blankon      @ Address of fb32_mail_blankon
fb32_mail_blankoff_addr:
	.word fb32_mail_blankoff     @ Address of fb32_mail_blankoff
.balign 4
