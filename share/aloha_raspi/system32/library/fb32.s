/**
 * fb32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * Frame Buffer Physical
 * To get speed, these variables are accessed directly from functions in fb32.s and print32.s,
 * therefore, the functions are needed to be placed close to these variables
 * within plus/minus 0x1000 bytes of the memory address.
 */
.globl FB32_ADDR
.globl FB32_WIDTH
.globl FB32_HEIGHT
.globl FB32_SIZE
.globl FB32_DEPTH

FB32_ADDR:           .word 0x00
FB32_WIDTH:          .word 0x00
FB32_HEIGHT:         .word 0x00
FB32_SIZE:           .word 0x00
FB32_DEPTH:          .word 0x00 @ 16/32. In 16 (Bits), RGB Oredered. In 32 (Bits), ARGB Ordered. (MSB to LSB).


/**
 * function fb32_image
 * Draw Image
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
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
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): When Buffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Buffer is not Defined
 * Global Enviromental Variable(s): FB32_ADDR, FB32_WIDTH, FB32_SIZE, FB32_DEPTH
 */
.globl fb32_image
fb32_image:
	/* Auto (Local) Variables, but just Aliases */
	image_point      .req r0  @ Parameter, Register for Argument and Result, Scratch Register
	x_coord          .req r1  @ Parameter, Register for Argument and Result, Scratch Register
	y_coord          .req r2  @ Parameter, Register for Argument, Scratch Register
	char_width       .req r3  @ Parameter, have to PUSH/POP in ARM C lang Regulation, Use for Vertical Counter
	char_height      .req r4  @ Parameter, have to PUSH/POP in ARM C lang Regulation, Horizontal Counter Reserved Number
	f_buffer         .req r5  @ Pointer of Buffer
	width            .req r6
	depth            .req r7
	size             .req r8
	color            .req r9
	char_width_bytes .req r10
	x_crop_char      .req r11

	/* VFP Registers */
	vfp_src_lower   .req d0
	vfp_src_upper   .req d1
	vfp_src_blue    .req s0
	vfp_src_green   .req s1
	vfp_src_red     .req s2
	vfp_src_alpha   .req s3
	vfp_dst_lower   .req d2
	vfp_dst_upper   .req d3
	vfp_dst_blue    .req s4
	vfp_dst_green   .req s5
	vfp_dst_red     .req s6
	vfp_dst_alpha   .req s7
	vfp_cal_lower   .req d4
	vfp_cal_upper   .req d5
	vfp_cal_a       .req s8
	vfp_cal_b       .req s9
	vfp_cal_one     .req s10
	vfp_cal_d       .req s11
	vfp_out_lower   .req d6
	vfp_out_upper   .req d7
	vfp_out_blue    .req s12
	vfp_out_green   .req s13
	vfp_out_red     .req s14
	vfp_out_alpha   .req s15
	vfp_divisor     .req s16

	push {r4-r11}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                    @ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #32                                  @ r4-r11 offset 32 bytes
	pop {char_height}                                @ Get Fifth and Sixth Arguments
	sub sp, sp, #36                                  @ Retrieve SP

	vpush {s0-s16}                                   @ 4 Bytes x 17, 68 Bytes Slide of SP, Know for ip and Stack Usage

	ldr f_buffer, FB32_ADDR
	cmp f_buffer, #0
	beq fb32_image_error2

	ldr width, FB32_WIDTH
	cmp width, #0
	beq fb32_image_error2

	ldr depth, FB32_DEPTH
	cmp depth, #0
	beq fb32_image_error2
	cmp depth, #32
	cmpne depth, #16
	bne fb32_image_error2

	ldr size, FB32_SIZE
	cmp size, #0
	beq fb32_image_error2
	add size, f_buffer, size

	cmp depth, #16
	lsleq width, width, #1                           @ Vertical Offset Bytes, substitution of Multiplication by 2
	lsleq char_width_bytes, char_width, #1           @ Character Vertical Offset Bytes, substitution of Multiplication by 2
	cmp depth, #32
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

	mov j, #1
	vmov vfp_cal_one, j
	vcvt.f32.s32 vfp_cal_one, vfp_cal_one

	mov width_check, f_buffer
	add width_check, width

	cmp x_coord, #0                                  @ If Value of x_coord is Signed Minus
	blt fb32_image_xminus

	cmp depth, #16
	lsleq x_coord, x_coord, #1                       @ Horizontal Offset Bytes, substitution of Multiplication by 2
	cmp depth, #32
	lsleq x_coord, x_coord, #2                       @ Horizontal Offset Bytes, substitution of Multiplication by 4
	add f_buffer, f_buffer, x_coord                  @ Horizontal Offset Bytes

	x_offset_char .req r1

	mov x_offset_char, #0                            @ X Minus Offset Bytes
	b fb32_image_xoffset

	fb32_image_xminus:
		add char_width, char_width, x_coord      @ Subtract x_coord Value from char_width

		.unreq x_coord

		mvn x_offset_char, x_offset_char         @ Logical Not to Convert Minus to Plus
		add x_offset_char, x_offset_char, #1     @ Add 1 to Convert Minus to Plus

		cmp depth, #16
		lsleq x_offset_char, x_offset_char, #1   @ X Minus Coord Bytes, substitution of Multiplication by 2 (No Minus)
		cmp depth, #32
		lsleq x_offset_char, x_offset_char, #2   @ X Minus Coord Bytes, substitution of Multiplication by 2 (No Minus)

	fb32_image_xoffset:
		ldr ip, [sp, #104]                       @ Load X Offset, Arm 36 Bytes + VFP 68 Bytes Away From Current SP
		cmp ip, #0
		ble fb32_image_xcrop

		sub char_width, char_width, ip           @ Subtract X Offset (ip) value from char_width

		cmp depth, #16
		lsleq ip, ip, #1                         @ X Offset Bytes, substitution of Multiplication by 2 (No Minus)
		cmp depth, #32
		lsleq ip, ip, #2                         @ X Offset Bytes, substitution of Multiplication by 4 (No Minus)

		add x_offset_char, x_offset_char, ip

	fb32_image_xcrop:
		ldr ip, [sp, #112]                       @ Load X Crop, Arm 44 Bytes + VFP 68 Bytes Away From Current SP
		cmp ip, #0
		movle x_crop_char, #0
		ble fb32_image_loop

		sub char_width, char_width, ip           @ Subtract X Crop (ip) value from char_width

		cmp depth, #16
		lsleq x_crop_char, ip, #1                @ X Crop Bytes, substitution of Multiplication by 2 (No Minus)
		cmp depth, #32
		lsleq x_crop_char, ip, #2                @ X Crop Bytes, substitution of Multiplication by 4 (No Minus)

	fb32_image_loop:
		cmp char_height, #0                          @ Vertical Counter `(; char_height > 0; char_height--)`
		ble fb32_image_success

		cmp f_buffer, size                           @ Check Overflow of Buffer Memory
		bhs fb32_image_error1

		add image_point, image_point, x_offset_char  @ Add X Offset Bytes

		mov j, char_width                            @ Horizontal Counter `(int j = char_width; j >= 0; --j)`

		fb32_image_loop_horizontal:
			sub j, j, #1                                 @ For Bit Allocation (Horizontal Character Bit)
			cmp j, #0                                    @ Horizontal Counter, Check
			blt fb32_image_loop_common

			/* The Picture Process of Depth 16 Bits */
			cmp depth, #16
			bne fb32_image_loop_horizontal_depth32
			ldrh color, [image_point]                    @ Load half word
			strh color, [f_buffer]                       @ Store half word
			b fb32_image_loop_horizontal_common

			fb32_image_loop_horizontal_depth32:
				/* The Picture Process of Depth 32 Bits */
				ldr color, [image_point]                     @ Load word

				/** 
				 * Alpha Blending
				 * SRC Over DST, Using Porter-Duff (1984)
				 *
				 * OUT_Alpha = SRC_Alpha + (DST_Alpha x (1 - SRC_Alpha))
				 * OUT_RGB = ((SRC_RGB x SRC_Alpha) + (DST_RGB x (DST_Alpha x (1 - SRC_Alpha)))) Div by OUT_Alpha
				 * If DST_Alpha = 1, OUT_Alpha = 1
				 * If OUT_Alpha = 0, OUT_RGB = 0
				 */

				cmp color, #0xFF000000                             @ If SRC_Alpha is Fully Opaque
				bhs fb32_image_loop_horizontal_depth32_common      @ Unsigned Higher or Same

				cmp color, #0x01000000                             @ If SRC_Alpha is Fully Transparent
				blo fb32_image_loop_horizontal_common              @ Unsigned Less (Lower)

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
				vcvt.f32.u32 vfp_src_blue, vfp_src_blue            @ Convert Unsigned Integer to Single Precision Floating Point
				vcvt.f32.u32 vfp_src_green, vfp_src_green          @ Convert Unsigned Integer to Single Precision Floating Point
				vcvt.f32.u32 vfp_src_red, vfp_src_red              @ Convert Unsigned Integer to Single Precision Floating Point
				vcvt.f32.u32 vfp_src_alpha, vfp_src_alpha          @ Convert Unsigned Integer to Single Precision Floating Point

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
				vcvt.f32.u32 vfp_dst_blue, vfp_dst_blue            @ Convert Unsigned Integer to Single Precision Floating Point
				vcvt.f32.u32 vfp_dst_green, vfp_dst_green          @ Convert Unsigned Integer to Single Precision Floating Point
				vcvt.f32.u32 vfp_dst_red, vfp_dst_red              @ Convert Unsigned Integer to Single Precision Floating Point
				vcvt.f32.u32 vfp_dst_alpha, vfp_dst_alpha          @ Convert Unsigned Integer to Single Precision Floating Point

				/* Clean Color Register */
				mov color, #0

				/* Sanitize OUT_ARGB */
				mov depth, #0
				vmov vfp_out_lower, depth, color
				vmov vfp_out_upper, depth, color
				vcvt.f32.u32 vfp_out_blue, vfp_out_blue
				vcvt.f32.u32 vfp_out_green, vfp_out_green
				vcvt.f32.u32 vfp_out_red, vfp_out_red
				vcvt.f32.u32 vfp_out_alpha, vfp_out_alpha

				/* Alpha divisor to Range within 0.0-1.0 */
				mov depth, #255
				vmov vfp_divisor, depth
				vcvt.f32.u32 vfp_divisor, vfp_divisor
				vdiv.f32 vfp_src_alpha, vfp_src_alpha, vfp_divisor
				vdiv.f32 vfp_dst_alpha, vfp_dst_alpha, vfp_divisor

				/* DST_Alpha x (1 - SRC_Alpha) to vfp_cal_a */
				vcmp.f32 vfp_dst_alpha, vfp_cal_one
				vmrs apsr_nzcv, fpscr                                   @ Transfer FPSCR Flags to CPSR's NZCV
				vmoveq vfp_out_alpha, vfp_dst_alpha                     @ If DST_Alpha Is 1.0, OUT_Alpha Becomes 1.0
				vsub.f32 vfp_cal_b, vfp_cal_a, vfp_src_alpha
				vmul.f32 vfp_cal_a, vfp_dst_alpha, vfp_cal_b

				/* OUT_Alpha, SRC_Alpha + (DST_RGB x (DST_Alpha x (1 - SRC_Alpha))) to vfp_out_alpha */
				vaddne.f32 vfp_out_alpha, vfp_src_alpha, vfp_cal_a      @ If DST_Alpha is not 0.0

				/* Compare OUT_Alpha to Zero */
				vcmp.f32 vfp_out_alpha, #0
				vmrs apsr_nzcv, fpscr                                   @ Transfer FPSCR Flags to CPSR's NZCV Flags (APSR)
				beq fb32_image_loop_horizontal_depth32_alphablend  @ If OUT_Alpha is 0.0, OUT_ARGB Becomes all 0.0

				/* DST_RGB x (DST_Alpha x (1 - SRC_Alpha)) to vfp_dst */
				vmul.f32 vfp_dst_blue, vfp_dst_blue, vfp_cal_a
				vmul.f32 vfp_dst_green, vfp_dst_green, vfp_cal_a
				vmul.f32 vfp_dst_red, vfp_dst_red, vfp_cal_a

				/* SRC_RGB x SRC_Alpha to vfp_src */
				vmul.f32 vfp_src_blue, vfp_src_blue, vfp_src_alpha
				vmul.f32 vfp_src_green, vfp_src_green, vfp_src_alpha
				vmul.f32 vfp_src_red, vfp_src_red, vfp_src_alpha

				/* (SRC_RGB x SRC_Alpha) + (DST_RGB x (DST_Alpha x (1 - SRC_Alpha))) to vfp_dst */
				vadd.f32 vfp_dst_blue, vfp_src_blue, vfp_dst_blue
				vadd.f32 vfp_dst_green, vfp_src_green, vfp_dst_green
				vadd.f32 vfp_dst_red, vfp_src_red, vfp_dst_red

				/* OUT_RGB, ((SRC_RGB x SRC_Alpha) + (DST_RGB x (DST_Alpha x (1 - SRC_Alpha)))) Div by OUT_Alpha to vfp_out */
				vdiv.f32 vfp_cal_a, vfp_cal_one, vfp_out_alpha
				vmul.f32 vfp_out_blue, vfp_dst_blue, vfp_cal_a
				vmul.f32 vfp_out_green, vfp_dst_green, vfp_cal_a
				vmul.f32 vfp_out_red, vfp_dst_red, vfp_cal_a

				/* Retrieve OUT_Alpha to Range within 0 to 255 */
				vmul.f32 vfp_out_alpha, vfp_out_alpha, vfp_divisor

				fb32_image_loop_horizontal_depth32_alphablend:
					vcvtr.u32.f32 vfp_out_blue, vfp_out_blue            @ Convert Single Precision Floating Point to Unsinged Integer
					vcvtr.u32.f32 vfp_out_green, vfp_out_green          @ Convert Single Precision Floating Point to Unsinged Integer
					vcvtr.u32.f32 vfp_out_red, vfp_out_red              @ Convert Single Precision Floating Point to Unsinged Integer
					vcvtr.u32.f32 vfp_out_alpha, vfp_out_alpha          @ Convert Single Precision Floating Point to Unsinged Integer
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

				fb32_image_loop_horizontal_depth32_common:
					str color, [f_buffer]                    @ Store word

			fb32_image_loop_horizontal_common:
				cmp depth, #16
				addeq f_buffer, f_buffer, #2         @ Buffer Address Shift
				addeq image_point, image_point, #2   @ Image Pointer Shift
				cmp depth, #32
				addeq f_buffer, f_buffer, #4         @ Buffer Address Shift
				addeq image_point, image_point, #4   @ Image Pointer Shift

				cmp f_buffer, width_check            @ Check Overflow of Width
				blo fb32_image_loop_horizontal

				cmp depth, #16
				lsleq j, j, #1                       @ substitution of Multiplication by 2
				cmp depth, #32
				lsleq j, j, #2                       @ substitution of Multiplication by 4
				add f_buffer, f_buffer, j            @ Buffer Offset

		fb32_image_loop_common:
			sub char_height, char_height, #1

			cmp depth, #16
			lsleq j, char_width, #1                   @ substitution of Multiplication by 2
			cmp depth, #32
			lsleq j, char_width, #2                   @ substitution of Multiplication by 4
			sub f_buffer, f_buffer, j                 @ Offset Clear of Buffer

			add f_buffer, f_buffer, width             @ Horizontal Sync (Buffer)

			add width_check, width_check, width       @ Store the Limitation of Width on the Next Y Coordinate

			add image_point, image_point, x_crop_char @ Add X Crop Bytes

			b fb32_image_loop

	fb32_image_error1:
		mov r0, #1                                   @ Return with Error 1
		b fb32_image_common

	fb32_image_error2:
		mov r0, #2                                   @ Return with Error 2
		b fb32_image_common

	fb32_image_success:
		mov r0, #0                                   @ Return with Success

	fb32_image_common:
		vpop {s0-s16}
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
.unreq x_crop_char
.unreq vfp_src_lower
.unreq vfp_src_upper
.unreq vfp_src_blue
.unreq vfp_src_green
.unreq vfp_src_red
.unreq vfp_src_alpha
.unreq vfp_dst_lower
.unreq vfp_dst_upper
.unreq vfp_dst_blue
.unreq vfp_dst_green
.unreq vfp_dst_red
.unreq vfp_dst_alpha
.unreq vfp_cal_lower
.unreq vfp_cal_upper
.unreq vfp_cal_a
.unreq vfp_cal_b
.unreq vfp_cal_one
.unreq vfp_cal_d
.unreq vfp_out_lower
.unreq vfp_out_upper
.unreq vfp_out_blue
.unreq vfp_out_green
.unreq vfp_out_red
.unreq vfp_out_alpha
.unreq vfp_divisor


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
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): When Buffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Buffer is not Defined
 * Global Enviromental Variable(s): FB32_ADDR, FB32_WIDTH, FB32_SIZE, FB32_DEPTH
 */
.globl fb32_clear_color_block
fb32_clear_color_block:
	/* Auto (Local) Variables, but just Aliases */
	color       .req r0  @ Parameter, Register for Argument, Scratch Register
	x_coord     .req r1  @ Parameter, Register for Argument and Result, Scratch Register
	y_coord     .req r2  @ Parameter, Register for Argument, Scratch Register
	char_width  .req r3  @ Parameter, Register for Argument, Scratch Register
	char_height .req r4  @ Parameter, have to PUSH/POP in ARM C lang Regulation, Horizontal Counter Reserved Number
	f_buffer    .req r5  @ Pointer of Buffer
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

	ldr f_buffer, FB32_ADDR
	cmp f_buffer, #0
	beq fb32_clear_color_block_error2

	ldr width, FB32_WIDTH
	cmp width, #0
	beq fb32_clear_color_block_error2

	cmp x_coord, width                               @ If Value of x_coord is Over Width
	bge fb32_clear_color_block_success

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
	lsleq width, width, #1                           @ Vertical Offset Bytes, substitution of Multiplication by 2
	cmp depth, #32
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

		cmp char_height, #0                          @ Vertical Counter `(; char_height > 0; char_height--)`
		ble fb32_clear_color_block_success

		cmp f_buffer, size                           @ Check Overflow of Buffer Memory
		bhs fb32_clear_color_block_error1

		mov j, char_width                            @ Horizontal Counter `(int j = char_width; j >= 0; --j)`

		fb32_clear_color_block_loop_horizontal:
			sub j, j, #1                             @ For Bit Allocation (Horizontal Character Bit)
			cmp j, #0                                @ Horizontal Counter, Check
			blt fb32_clear_color_block_loop_common

			/* The Picture Process */
			cmp depth, #16
			streqh color, [f_buffer]                 @ Store half word
			addeq f_buffer, f_buffer, #2             @ Buffer Address Shift

			cmp depth, #32
			streq color, [f_buffer]                  @ Store word
			addeq f_buffer, f_buffer, #4             @ Buffer Address Shift

			fb32_clear_color_block_loop_horizontal_common:

				cmp f_buffer, width_check             @ Check Overflow of Width
				blo fb32_clear_color_block_loop_horizontal

				cmp depth, #16
				lsleq j, j, #1                        @ substitution of Multiplication by 2
				cmp depth, #32
				lsleq j, j, #2                        @ substitution of Multiplication by 4
				add f_buffer, f_buffer, j             @ Buffer Offset

		fb32_clear_color_block_loop_common:
			sub char_height, char_height, #1

			cmp depth, #16
			lsleq j, char_width, #1                  @ substitution of Multiplication by 2
			cmp depth, #32
			lsleq j, char_width, #2                  @ substitution of Multiplication by 4
			sub f_buffer, f_buffer, j                @ Offset Clear of Buffer

			add f_buffer, f_buffer, width            @ Horizontal Sync (Buffer)

			add width_check, width_check, width      @ Store the Limitation of Width on the Next Y Coordinate

			b fb32_clear_color_block_loop

	fb32_clear_color_block_error1:
		mov r0, #1                                   @ Return with Error 1
		b fb32_clear_color_block_common

	fb32_clear_color_block_error2:
		mov r0, #2                                   @ Return with Error 2
		b fb32_clear_color_block_common

	fb32_clear_color_block_success:
		mov r0, #0                                   @ Return with Success

	fb32_clear_color_block_common:
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
 * Fill Out Buffer by Color
 *
 * Parameters
 * r0: Color (16-bit or 32-bit)
 *
 * Usage: r0-r4
 * Return: r0 (0 as success, 1 as error)
 * Error(1): When Buffer is not Defined
 * Global Enviromental Variable(s): FB32_ADDR, FB32_SIZE, FB32_DEPTH
 */
.globl fb32_clear_color
fb32_clear_color:
	color             .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	fb_buffer         .req r1
	size              .req r2
	depth             .req r3
	length            .req r4

	push {r4}

	ldr fb_buffer, FB32_ADDR
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
 * function fb32_flush_doublebuffer
 * Flush Back Buffer to Framebuffer and Swap Front and Back
 *
 * Usage: r0-r7
 * Return: r0 (0 as success, 1 as error)
 * Error(1): When buffer is not Defined
 */
.globl fb32_flush_doublebuffer
fb32_flush_doublebuffer:
	buffer_front      .req r0
	buffer_back       .req r1
	doublebuffer_base .req r2
	f_buffer          .req r3
	size              .req r4
	depth             .req r5
	r_buffer          .req r6
	color             .req r7

	push {r4-r7}

	ldr buffer_front, FB32_DOUBLEBUFFER_FRONT 
	cmp buffer_front, #0
	beq fb32_flush_doublebuffer_error
	ldr buffer_back, FB32_DOUBLEBUFFER_BACK
	cmp buffer_back, #0
	beq fb32_flush_doublebuffer_error

	str buffer_front, FB32_DOUBLEBUFFER_BACK 
	str buffer_back, FB32_DOUBLEBUFFER_FRONT

	ldr f_buffer, FB32_FRAMEBUFFER_ADDR
	cmp f_buffer, #0
	beq fb32_flush_doublebuffer_error
	ldr size, FB32_FRAMEBUFFER_SIZE
	cmp size, #0
	beq fb32_flush_doublebuffer_error
	ldr depth, FB32_FRAMEBUFFER_DEPTH
	cmp depth, #0
	beq fb32_flush_doublebuffer_error

	add size, f_buffer, size

	ldr r_buffer, [buffer_back]

	fb32_flush_doublebuffer_loop:
		cmp depth, #16
		ldreqh color, [r_buffer]
		streqh color, [f_buffer]
		addeq r_buffer, r_buffer, #2
		addeq f_buffer, f_buffer, #2
		cmp depth, #32
		ldreq color, [r_buffer]
		streq color, [f_buffer]
		addeq r_buffer, r_buffer, #4
		addeq f_buffer, f_buffer, #4
		cmp f_buffer, size
		blo fb32_flush_doublebuffer_loop

	push {r0-r3,lr}
	mov r0, buffer_front
	bl fb32_attach_buffer
	pop {r0-r3,lr}

	b fb32_flush_doublebuffer_success

	fb32_flush_doublebuffer_error:
		mov r0, #1                           @ Return with Error
		b fb32_flush_doublebuffer_common

	fb32_flush_doublebuffer_success:
		mov r0, #0                           @ Return with Success

	fb32_flush_doublebuffer_common:
		macro32_dsb ip                       @ Ensure Completion of Instructions Before
		pop {r4-r7}
		mov pc, lr

.unreq buffer_front
.unreq buffer_back
.unreq doublebuffer_base
.unreq f_buffer
.unreq size
.unreq depth
.unreq r_buffer
.unreq color


/**
 * function fb32_set_doublebuffer
 * Set Buffer for Double Buffer Operation
 *
 * Parameters
 * r0: Pointer of Buffer to Front
 * r1: Pointer of Buffer to Back
 *
 * Usage: r0-r2
 * Return: r0 (0 as success, 1 as error)
 * Error(1): When buffer is not Defined
 */
.globl fb32_set_doublebuffer
fb32_set_doublebuffer:
	buffer_front      .req r0
	buffer_back       .req r1
	doublebuffer_base .req r2

	cmp buffer_front, #0
	beq fb32_set_doublebuffer_error
	cmp buffer_back, #0
	beq fb32_set_doublebuffer_error

	str buffer_back, FB32_DOUBLEBUFFER_BACK
	str buffer_front, FB32_DOUBLEBUFFER_FRONT

	push {r0-r3,lr}
	mov r0, buffer_back
	bl fb32_attach_buffer
	pop {r0-r3,lr}

	b fb32_set_doublebuffer_success

	fb32_set_doublebuffer_error:
		mov r0, #1                           @ Return with Error
		b fb32_set_doublebuffer_common

	fb32_set_doublebuffer_success:
		mov r0, #0                           @ Return with Success

	fb32_set_doublebuffer_common:
		macro32_dsb ip                       @ Ensure Completion of Instructions Before
		mov pc, lr

.unreq buffer_front
.unreq buffer_back 
.unreq doublebuffer_base


/**
 * function fb32_attach_buffer
 * Attach Buffer to Draw on It
 *
 * Parameters
 * r0: Pointer of Buffer to Attach
 *
 * Usage: r0-r5
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Buffer In is not Defined
 */
.globl fb32_attach_buffer
fb32_attach_buffer:
	buffer            .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	buffer_addr       .req r1
	width             .req r2
	height            .req r3
	size              .req r4
	depth             .req r5

	push {r4,r5}

	macro32_dsb ip                           @ Ensure Coherence of Cache and Memory

	ldr buffer_addr, [buffer]
	cmp buffer_addr, #0
	beq fb32_attach_buffer_error

	ldr width, [buffer, #4]
	cmp width, #0
	beq fb32_attach_buffer_error

	ldr height, [buffer, #8]
	cmp height, #0
	beq fb32_attach_buffer_error

	ldr size, [buffer, #12]
	cmp size, #0
	beq fb32_attach_buffer_error

	ldr depth, [buffer, #16]
	cmp depth, #0
	beq fb32_attach_buffer_error

	str buffer_addr, FB32_ADDR
	str width, FB32_WIDTH
	str height, FB32_HEIGHT
	str size, FB32_SIZE
	str depth, FB32_DEPTH

	mov r0, #0                               @ Return with Success
	b fb32_attach_buffer_common

	fb32_attach_buffer_error:
		mov r0, #1                       @ Return with Error

	fb32_attach_buffer_common:
		macro32_dsb ip                       @ Ensure Completion of Instructions Before
		pop {r4, r5}
		mov pc, lr

.unreq buffer
.unreq buffer_addr
.unreq width
.unreq height
.unreq size
.unreq depth


/**
 * Buffers
 * Render Buffer Will Be Set with Heap.
 * Contents of Render Buffer is Same as Framebuffer.
 * First is Address of Buffer, Second is Width, Third is Height, Fourth is Size, Fifth is Depth.
 * So, Block Size is 5 (20 Bytes).
 */

.globl FB32_FRAMEBUFFER
.globl FB32_FRAMEBUFFER_ADDR
.globl FB32_FRAMEBUFFER_WIDTH
.globl FB32_FRAMEBUFFER_HEIGHT
.globl FB32_FRAMEBUFFER_SIZE
.globl FB32_FRAMEBUFFER_DEPTH
FB32_FRAMEBUFFER:          .word FB32_FRAMEBUFFER_ADDR
FB32_FRAMEBUFFER_ADDR:     .word 0x00
FB32_FRAMEBUFFER_WIDTH:    .word 0x00
FB32_FRAMEBUFFER_HEIGHT:   .word 0x00
FB32_FRAMEBUFFER_SIZE:     .word 0x00
FB32_FRAMEBUFFER_DEPTH:    .word 0x00

.globl FB32_DOUBLEBUFFER_BACK
.globl FB32_DOUBLEBUFFER_FRONT
FB32_DOUBLEBUFFER_BACK:    .word 0x00
FB32_DOUBLEBUFFER_FRONT:   .word 0x00

.balign 4

.section	.data

/* Indicates Caret Position to Use in Printing Characters */
.globl FB32_X_CARET
.globl FB32_Y_CARET
FB32_X_CARET: .word 0x00000000
FB32_Y_CARET: .word 0x00000000

.section	.library_system32
