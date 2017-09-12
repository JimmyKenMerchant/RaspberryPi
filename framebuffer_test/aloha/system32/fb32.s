/**
 * fb32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/* Frame Buffer Physical */
.globl FB32_ADDR
.globl FB32_WIDTH
.globl FB32_HEIGHT
.globl FB32_SIZE
.globl FB32_DEPTH

FB32_ADDR:           .word 0x00
FB32_WIDTH:          .word 0x00
FB32_HEIGHT:         .word 0x00
FB32_SIZE:           .word 0x00
FB32_DEPTH:          .word 0x00


/* Indicates Caret Position to Use in Printing Characters */
.balign 4
.globl FB32_X_CARET
.globl FB32_Y_CARET
FB32_X_CARET: .word 0x00000000
FB32_Y_CARET: .word 0x00000000


/**
 * Buffers
 * Render Buffer Will Be Set with Heap.
 * Content of Render Buffer is Same as Framebuffer.
 * First is Address of Buffer, Second is Width, Third is Height, Fourth is Size, Fifth is Depth.
 * So, Block Size is 5 (20 Bytes).
 */

.globl FB32_FRAMEBUFFER
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


/**
 * function fb32_draw_arc
 * Draw Arc
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Parameters
 * r0: Color (16-bit or 32-bit)
 * r1: X Coordinate of Center
 * r2: Y Coordinate of Center
 * r3: Radius
 * r4: Degree of Start
 * r5: Degree of End
 * r6: Width of Arc Line
 * r7: Height of Arc Line
 *
 * Usage: r0-r9
 * Return: r0 (0 as success, 1 as error), r1 (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Part of Circle from Last Coordinate was Not Drawn, Caused by Buffer Overflow
 */
.globl fb32_draw_arc
fb32_draw_arc:
	/* Auto (Local) Variables, but just aliases */
	color            .req r0   @ Parameter, Register for Argument, Scratch Register
	x_coord          .req r1   @ Parameter, Register for Argument and Result, Scratch Register
	y_coord          .req r2   @ Parameter, Register for Argument, Scratch Register
	radius           .req r3   @ Parameter, Register for Argument and Result, Scratch Register
	deg_start        .req r4   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	deg_end          .req r5   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_width       .req r6   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_height      .req r7   @ Parameter, have to PUSH/POP in ARM C lang Regulation
	x_current        .req r8
	y_current        .req r9

	/* VFP/NEON Registers */
	vfp_radian       .req d0 @ q0[0]
	vfp_radian_start .req s0 @ Lower 32 Bits of d0
	vfp_radian_end   .req s1 @ Upper 32 Bits of d0
	vfp_position     .req d1
	vfp_position_x   .req s2 @ Lower 32 Bits of d1
	vfp_position_y   .req s3 @ Upper 32 Bits of d1
	vfp_radius       .req d2
	vfp_radius_x     .req s4
	vfp_radius_y     .req s5
	vfp_adder        .req s6

	push {r4-r9}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                   @ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #24                                   @ r4-r9 offset 24 bytes
	pop {deg_start, deg_end, char_width, char_height} @ Get Fifth to Seventh Arguments
	sub sp, sp, #40                                   @ Retrieve SP

	vpush {s0-s6}

	push {r0-r3,lr}
	mov r0, deg_start
	bl math32_degree_to_radian32
	mov deg_start, r0                                 @ Float Type Value
	pop {r0-r3,lr}

	.unreq deg_start
	radian_start .req r3

	push {r0-r3,lr}
	mov r0, deg_end
	bl math32_degree_to_radian32
	mov deg_end, r0                                   @ Float Type Value
	pop {r0-r3,lr}

	.unreq deg_end
	radian_end .req r4

	vmov vfp_radian, radian_start, radian_end
	vcmp.f32 vfp_radian_start, vfp_radian_end
	vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
	vmovgt vfp_radian_start, vfp_radius_x
	vmovgt vfp_radian_start, vfp_radian_end
	vmovgt vfp_radian_end, vfp_radius_x

	vdup.32 vfp_radius, radius
	vcvt.f32.s32 vfp_radius, vfp_radius

	vmov vfp_adder, #0.125
	vmul.f32 vfp_adder, vfp_adder, vfp_adder
	vmul.f32 vfp_adder, vfp_adder, vfp_adder

	fb32_draw_arc_loop:
		vcmp.f32 vfp_radian_start, vfp_radian_end
		vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
		bgt fb32_draw_arc_success
		vmov radian_start, vfp_radian_start

		push {r0-r3,lr}
		mov r0, radian_start
		bl math32_cos32
		mov x_current, r0
		pop {r0-r3,lr}

		push {r0-r3,lr}
		mov r0, radian_start
		bl math32_sin32
		mov y_current, r0
		pop {r0-r3,lr}

		vmov vfp_position, x_current, y_current
		vmul.f32 vfp_position, vfp_position, vfp_radius
		vcvtr.s32.f32 vfp_position, vfp_position
		vmov x_current, vfp_position_x
		vmov y_current, vfp_position_y

		add x_current, x_current, x_coord
		add y_current, y_current, y_coord

		push {r0-r3,lr}                                     @ Equals to stmfd (stack pointer full, decrement order)
		mov r1, x_current
		mov r2, y_current
		mov r3, char_width
		push {char_height} 
		bl fb32_clear_color_block
		add sp, sp, #4
		push {r1}
		add sp, sp, #4
		cmp r0, #0                                          @ Compare Return 0 or 1
		pop {r0-r3,lr}                                      @ Retrieve Registers Before Error Check, POP does not flags-update
		bne fb32_draw_arc_error

		vadd.f32 vfp_radian_start, vfp_radian_start, vfp_adder
		b fb32_draw_arc_loop

	fb32_draw_arc_error:
		mov r0, #1
		b fb32_draw_arc_common

	fb32_draw_arc_success:
		mov r0, #0

	fb32_draw_arc_common:
		vpop {s0-s6}
		lsl x_current, x_current, #16
		add r1, x_current, y_current
		pop {r4-r9}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			            @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number
		mov pc, lr

.unreq color
.unreq x_coord
.unreq y_coord
.unreq radius
.unreq radian_start
.unreq radian_end
.unreq char_width
.unreq char_height
.unreq x_current
.unreq y_current
.unreq vfp_radian
.unreq vfp_radian_start
.unreq vfp_radian_end
.unreq vfp_position
.unreq vfp_position_x
.unreq vfp_position_y
.unreq vfp_radius
.unreq vfp_radius_x
.unreq vfp_radius_y
.unreq vfp_adder


/**
 * function fb32_draw_circle
 * Draw Circle Filled with Color
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
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
 * Error: Part of Circle from Last Coordinate was Not Drawn, Caused by Buffer Overflow
 */
.globl fb32_draw_circle
fb32_draw_circle:
	/* Auto (Local) Variables, but just aliases */
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

	/* VFP/NEON Registers */
	vfp_xy_coord     .req d0 @ q0[0]
	vfp_y_coord      .req s0 @ Lower 32 Bits of d0
	vfp_x_coord      .req s1 @ Upper 32 Bits of d0
	vfp_xy_radius    .req d1 @ q0[1]
	vfp_y_radius     .req s2
	vfp_x_radius     .req s3
	vfp_cal_ab       .req d2
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
	vcvt.f32.s32 vfp_xy_coord, vfp_xy_coord           @ *NEON*Convert Signed Integer to Single Precision Floating Point
	vcvt.f32.u32  vfp_xy_radius, vfp_xy_radius        @ *NEON*Convert Unsigned Integer to Single Precision Floating Point

	.unreq y_coord
	x_diff .req r2

	vmov vfp_x_start, vfp_x_coord

	vmov vfp_radius, vfp_y_radius
	vmov vfp_tri_height, vfp_y_radius

	vmov vfp_one, #1.0                                @ Floating Point Constant (Immediate)

	cmp x_radius, y_radius
	beq fb32_draw_circle_loop

	vsub.f32 vfp_diff_radius, vfp_y_radius, vfp_x_radius

	/**
	 * The difference of Ellipse's radius seems Like a parabola, so It can make an approximation formula by X = Y^2. It show as a line on X axis.
	 * Besides, the difference of position in Free Fall of Physics show as a line on Y axis, and its proportion show as Y = X^2
	 */

	fb32_draw_circle_loop:
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
		bl fb32_clear_color_block
		add sp, sp, #4
		push {r1}
		add sp, sp, #4
		cmp r0, #0                                          @ Compare Return 0 or 1
		pop {r0-r3,lr}                                      @ Retrieve Registers Before Error Check, POP does not flags-update
		bne fb32_draw_circle_error

		cmp y_current,  y_max                               @ Already, y_max Has Been Minus One Before Loop
		bge fb32_draw_circle_success

		add y_current, y_current, #1

		vsub.f32 vfp_tri_height, vfp_tri_height, vfp_one

		cmp x_radius, y_radius
		beq fb32_draw_circle_loop_jump

		/* Add Difference to vfp_x_radius in Case of Ellipse */

		vmov vfp_cal_a, vfp_tri_height
		vabs.f32 vfp_cal_a, vfp_cal_a
		vdiv.f32 vfp_cal_a, vfp_cal_a, vfp_y_radius                @ Compress Range Within 0.0-1.0
		vmul.f32 vfp_cal_a, vfp_cal_a, vfp_cal_a                   @ The Second Power of vfp_cal_a
		vmul.f32 vfp_cal_a, vfp_diff_radius, vfp_cal_a
		vadd.f32 vfp_radius, vfp_x_radius, vfp_cal_a

		fb32_draw_circle_loop_jump:

			b fb32_draw_circle_loop

	fb32_draw_circle_error:
		mov r0, #1
		b fb32_draw_circle_common

	fb32_draw_circle_success:
		mov r0, #0

	fb32_draw_circle_common:
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
.unreq vfp_cal_ab
.unreq vfp_cal_a
.unreq vfp_cal_b
.unreq vfp_cal_c
.unreq vfp_x_start
.unreq vfp_diff_radius
.unreq vfp_radius
.unreq vfp_tri_height
.unreq vfp_one


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
 * Return: r0 (0 as success, 1 as error), r1 (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Part of Line from Last Coordinate was Not Drawn, Caused by Buffer Overflow
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
	y_diff           .req r9   @ Counter
	dup_char_width   .req r10
	y_direction      .req r11  @ 1 is to Lower Right (Y Increment), -1 is to Upper Right (Y Decrement)

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
	bge fb32_draw_line_coordge
	blt fb32_draw_line_coordlt

	fb32_draw_line_coordge:                     @ `If ( y_coord_1 >= y_coord_2 )`
		sub y_diff, y_coord_1, y_coord_2
		cmp x_coord_1, x_coord_2

		movge x_current, x_coord_2               @ `If ( x_coord_1 >= x_coord_2 )`, Get X Start Point
		movge y_current, y_coord_2               @ Get Y Start Point
		movge y_direction, #1                    @ Draw to Lower Right

		movlt x_current, x_coord_1               @ `If ( x_coord_1 < x_coord_2 )`, Get X Start Point
		movlt y_current, y_coord_1               @ Get Y Start Point
		movlt y_direction, #-1                   @ Draw to Upper Right
		b fb32_draw_line_coord

	fb32_draw_line_coordlt:                      @ `If ( y_coord_1 < y_coord_2 )`
		sub y_diff, y_coord_2, y_coord_1
		cmp x_coord_1, x_coord_2

		movge x_current, x_coord_2               @ `If ( x_coord_1 >= x_coord_2 )`, Get X Start Point
		movge y_current, y_coord_2               @ Get Y Start Point
		movge y_direction, #-1                   @ Draw to Upper Right

		movlt x_current, x_coord_1               @ `If ( x_coord_1 < x_coord_2 )`, Get X Start Point
		movlt y_current, y_coord_1               @ Get Y Start Point
		movlt y_direction, #1                    @ Draw to Lower Right

	fb32_draw_line_coord:
		vmov vfp_xy_coord_1, y_coord_1, x_coord_1     @ Lower Bits from y_coord_n, Upper Bits x_coord_n, q0[0]
		vmov vfp_xy_coord_2, y_coord_2, x_coord_2     @ Lower Bits from y_coord_n, Upper Bits x_coord_n, q0[1]
		vcvt.f32.s32 q0, q0                           @ *NEON*Convert Signed Integer to Single Precision Floating Point

		/* *NEON*Subtract Each 32-Bit Lane as Single Precision */
		vsub.f32 vfp_xy_coord_3, vfp_xy_coord_1, vfp_xy_coord_2

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
		vmov vfp_one, #1.0                             @ Floating Point Constant (Immediate)

	fb32_draw_line_loop:

		push {r0-r3,lr}                                @ Equals to stmfd (stack pointer full, decrement order)
		mov r1, x_current
		mov r2, y_current
		mov r3, char_width
		push {char_height} 
		bl fb32_clear_color_block
		add sp, sp, #4
		push {r1}
		add sp, sp, #4
		cmp r0, #0                                     @ Compare Return 0 or 1
		pop {r0-r3,lr}                                 @ Retrieve Registers Before Error Check, POP does not flags-update
		bne fb32_draw_line_error

		fb32_draw_line_loop_common:
			add i, i, #1
			cmp i, y_diff
			bgt fb32_draw_line_success
			moveq char_width, dup_char_width           @ To hide Width Overflow on End Point (Except Original char_width)

			add y_current, y_current, y_direction

			vadd.f32 vfp_i, vfp_i, vfp_one
			vmov vfp_x_current, vfp_x_start
			vmla.f32 vfp_x_current, vfp_x_per_y, vfp_i    @ Multiply and Accumulate Fd = Fd + (Fn * Fm)
			vcvtr.s32.f32 vfp_x_current, vfp_x_current    @ In VFP Instructions, You Can Convert with Rounding Mode

			vmov x_current, vfp_x_current

			b fb32_draw_line_loop

	fb32_draw_line_error:
		mov r0, #1
		b fb32_draw_line_common

	fb32_draw_line_success:
		mov r0, #0

	fb32_draw_line_common:
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
.unreq vfp_xy_coord_3
.unreq vfp_y_coord_3
.unreq vfp_x_coord_3
.unreq vfp_char_width
.unreq vfp_x_per_y
.unreq vfp_x_start
.unreq vfp_x_current
.unreq vfp_i
.unreq vfp_one


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
 * Return: r0 (0 as success, 1 and 2 as error), r1 (Last Pointer of Buffer)
 * Error(1): When Buffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Buffer is not Defined
 * Global Enviromental Variable(s): FB32_ADDR, FB32_WIDTH, FB32_SIZE, FB32_DEPTH
 */
.globl fb32_draw_image
fb32_draw_image:
	/* Auto (Local) Variables, but just aliases */
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
	vfp_divisor     .req s16

	push {r4-r11}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                    @ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #32                                  @ r4-r11 offset 32 bytes
	pop {char_height}                                @ Get Fifth and Sixth Arguments
	sub sp, sp, #36                                  @ Retrieve SP

	vpush {s0-s16}                                   @ 4 Bytes x 17, 68 Bytes Slide of SP, Know for ip and Stack Usage

	ldr f_buffer, FB32_ADDR
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

		cmp char_height, #0                          @ Vertical Counter `(; char_height > 0; char_height--)`
		ble fb32_draw_image_success

		cmp f_buffer, size                           @ Check Overflow of Buffer Memory
		bge fb32_draw_image_error1

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
				bhs fb32_draw_image_loop_horizontal_depth32_common @ Unsigned Higher or Same

				cmp color, #0x01000000                             @ If SRC_Alpha is Fully Transparent
				blo fb32_draw_image_loop_horizontal_common         @ Unsigned Less (Lower)

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

				/* Alpha divisor to Range within 0.0-1.0 */
				mov depth, #255
				vmov vfp_divisor, depth
				vcvt.f32.u32 vfp_divisor, vfp_divisor
				vdiv.f32 vfp_src_alpha, vfp_src_alpha, vfp_divisor
				vdiv.f32 vfp_dst_alpha, vfp_dst_alpha, vfp_divisor

				/* DST_Alpha x (1 - SRC_Alpha) to vfp_cal_a */
				vmov vfp_cal_a, #1.0
				vcmp.f32 vfp_dst_alpha, vfp_cal_a
				vmrs apsr_nzcv, fpscr                                   @ Transfer FPSCR Flags to CPSR's NZCV
				vmoveq vfp_out_alpha, vfp_dst_alpha                     @ If DST_Alpha Is 1.0, OUT_Alpha Becomes 1.0
				vsub.f32 vfp_cal_b, vfp_cal_a, vfp_src_alpha
				vmul.f32 vfp_cal_a, vfp_dst_alpha, vfp_cal_b

				/* OUT_Alpha, SRC_Alpha + (DST_RGB x (DST_Alpha x (1 - SRC_Alpha))) to vfp_out_alpha */
				vaddne.f32 vfp_out_alpha, vfp_src_alpha, vfp_cal_a      @ If DST_Alpha is not 0.0

				/* Compare OUT_Alpha to Zero */
				vcmp.f32 vfp_out_alpha, #0
				vmrs apsr_nzcv, fpscr                                   @ Transfer FPSCR Flags to CPSR's NZCV Flags (APSR)
				beq fb32_draw_image_loop_horizontal_depth32_alphablend  @ If OUT_Alpha is 0.0, OUT_ARGB Becomes all 0.0

				/* DST_RGB x (DST_Alpha x (1 - SRC_Alpha)) to vfp_dst */
				vdup.f32 vfp_cal, vfp_cal_lower[0]                      @ NEON Side Name of vfp_cal_a
				vmul.f32 vfp_dst, vfp_dst, vfp_cal                      @ *NEON*

				/* SRC_RGB x SRC_Alpha to vfp_src */
				vdup.f32 vfp_cal, vfp_src_upper[1]                      @ NEON Side Name of vfp_src_alpha
				vmul.f32 vfp_src, vfp_src, vfp_cal                      @ *NEON*

				/* (SRC_RGB x SRC_Alpha) + (DST_RGB x (DST_Alpha x (1 - SRC_Alpha))) to vfp_dst */
				vadd.f32 vfp_dst, vfp_dst, vfp_src                      @ *NEON*

				/* OUT_RGB, ((SRC_RGB x SRC_Alpha) + (DST_RGB x (DST_Alpha x (1 - SRC_Alpha)))) Div by OUT_Alpha to vfp_out */
				vmov vfp_src_alpha, vfp_out_alpha                       @ Store to Retrieve
				vmov vfp_cal_a, #1.0
				vmov vfp_cal_b, vfp_out_alpha
				vdiv.f32 vfp_cal_a, vfp_cal_a, vfp_cal_b
				vdup.f32 vfp_cal, vfp_cal_lower[0]                      @ NEON Side Name of vfp_cal_a
				vmul.f32 vfp_out, vfp_dst, vfp_cal                      @ *NEON*

				/* Retrieve OUT_Alpha to Range within 0 to 255 */
				vmov vfp_out_alpha, vfp_src_alpha
				vmul.f32 vfp_out_alpha, vfp_out_alpha, vfp_divisor

				fb32_draw_image_loop_horizontal_depth32_alphablend:
					vcvtr.u32.f32 vfp_out, vfp_out                      @ *NEON* Convert Single Precision Floating Point to Unsinged Integer
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
				addeq f_buffer, f_buffer, #2         @ Buffer Address Shift
				addeq image_point, image_point, #2   @ Image Pointer Shift
				cmp depth, #32
				addeq f_buffer, f_buffer, #4         @ Buffer Address Shift
				addeq image_point, image_point, #4   @ Image Pointer Shift

				cmp f_buffer, width_check            @ Check Overflow of Width
				blt fb32_draw_image_loop_horizontal

				cmp depth, #16
				lsleq j, j, #1                       @ substitution of Multiplication by 2
				cmp depth, #32
				lsleq j, j, #2                       @ substitution of Multiplication by 4
				add f_buffer, f_buffer, j            @ Buffer Offset

		fb32_draw_image_loop_common:
			sub char_height, char_height, #1

			cmp depth, #16
			lsleq j, char_width, #1                   @ substitution of Multiplication by 2
			cmp depth, #32
			lsleq j, char_width, #2                   @ substitution of Multiplication by 4
			sub f_buffer, f_buffer, j                 @ Offset Clear of Buffer

			add f_buffer, f_buffer, width             @ Horizontal Sync (Buffer)

			add width_check, width_check, width       @ Store the Limitation of Width on the Next Y Coordinate

			add image_point, image_point, x_crop_char @ Add X Crop Bytes

			b fb32_draw_image_loop

	fb32_draw_image_error1:
		mov r0, #1                                   @ Return with Error 1
		b fb32_draw_image_common

	fb32_draw_image_error2:
		mov r0, #2                                   @ Return with Error 2
		b fb32_draw_image_common

	fb32_draw_image_success:
		mov r0, #0                                   @ Return with Success

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
 * Usage: r0-r11
 * Return: r0 (0 as success, 1 and 2 as error), r1 (Last Pointer of Buffer)
 * Error(1): When Buffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * **fb32_clear_color is specially implemented to check if y_coord is over height to hide stopping to draw on higher functions.
 * This height-check virtually prevents Error(1)**
 * Error(2): When Buffer is not Defined
 * Global Enviromental Variable(s): FB32_ADDR, FB32_WIDTH, FB_HEIGHT, FB32_SIZE, FB32_DEPTH
 */
.globl fb32_clear_color_block
fb32_clear_color_block:
	/* Auto (Local) Variables, but just aliases */
	color       .req r0  @ Parameter, Register for Argument, Scratch Register
	x_coord     .req r1  @ Parameter, Register for Argument and Result, Scratch Register
	y_coord     .req r2  @ Parameter, Register for Argument, Scratch Register
	char_width  .req r3  @ Parameter, Register for Argument, Scratch Register
	char_height .req r4  @ Parameter, have to PUSH/POP in ARM C lang Regulation, Horizontal Counter Reserved Number
	f_buffer    .req r5  @ Pointer of Buffer
	width       .req r6
	height      .req r7
	depth       .req r8
	size        .req r9
	j           .req r10  @ Use for Horizontal Counter
	bitmask     .req r11

	push {r4-r11}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                    @ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #32                                  @ r4-r11 offset 32 bytes
	pop {char_height}                                @ Get Fifth and Sixth Arguments
	sub sp, sp, #36                                  @ Retrieve SP

	ldr f_buffer, FB32_ADDR
	cmp f_buffer, #0
	beq fb32_clear_color_block_error2

	ldr width, FB32_WIDTH
	cmp width, #0
	beq fb32_clear_color_block_error2

	ldr height, FB32_HEIGHT
	cmp height, #0
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
	lsleq width, width, #1                           @ Vertical Offset Bytes, substitution of Multiplication by 2
	cmp depth, #32
	lsleq width, width, #2                           @ Vertical Offset Bytes, substitution of Multiplication by 4

	/* Set Location to Render the Character */

	cmp y_coord, height                              @ If Value of y_coord is over Height of Buffer
	subge height, y_coord, height
	addge height, height, #1
	subge char_height, height

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
		bge fb32_clear_color_block_error1

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
				blt fb32_clear_color_block_loop_horizontal

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
		mov r1, f_buffer
		pop {r4-r11}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			            @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number
		mov pc, lr

.unreq color
.unreq x_coord
.unreq width_check
.unreq char_width
.unreq char_height
.unreq f_buffer
.unreq width
.unreq height
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
 * function fb32_doublebuffer_flush
 * Flush Back Buffer to Framebuffer and Swap Front and Back
 *
 * Usage: r0-r7
 * Return: r0 (0 as success, 1 as error)
 * Error(1): When buffer is not Defined
 */
.globl fb32_doublebuffer_flush
fb32_doublebuffer_flush:
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
	beq fb32_doublebuffer_flush_error
	ldr buffer_back, FB32_DOUBLEBUFFER_BACK
	cmp buffer_back, #0
	beq fb32_doublebuffer_flush_error

	dsb
	isb

	str buffer_front, FB32_DOUBLEBUFFER_BACK 
	str buffer_back, FB32_DOUBLEBUFFER_FRONT

	ldr f_buffer, FB32_FRAMEBUFFER_ADDR
	cmp f_buffer, #0
	beq fb32_doublebuffer_flush_error
	ldr size, FB32_FRAMEBUFFER_SIZE
	cmp size, #0
	beq fb32_doublebuffer_flush_error
	ldr depth, FB32_FRAMEBUFFER_DEPTH
	cmp depth, #0
	beq fb32_doublebuffer_flush_error

	add size, f_buffer, size

	ldr r_buffer, [buffer_back]

	fb32_doublebuffer_flush_loop:
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
		blt fb32_doublebuffer_flush_loop

	push {r0-r3,lr}
	mov r0, buffer_front
	bl fb32_attach_buffer
	pop {r0-r3,lr}

	b fb32_doublebuffer_flush_success

	fb32_doublebuffer_flush_error:
		mov r0, #1                           @ Return with Error
		b fb32_doublebuffer_flush_common

	fb32_doublebuffer_flush_success:
		mov r0, #0                           @ Return with Success

	fb32_doublebuffer_flush_common:
		dsb                              @ Ensure Completion of Instructions Before
		isb
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
 * function fb32_doublebuffer_set
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
.globl fb32_doublebuffer_set
fb32_doublebuffer_set:
	buffer_front      .req r0
	buffer_back       .req r1
	doublebuffer_base .req r2

	cmp buffer_front, #0
	beq fb32_doublebuffer_set_error
	cmp buffer_back, #0
	beq fb32_doublebuffer_set_error

	str buffer_back, FB32_DOUBLEBUFFER_BACK
	str buffer_front, FB32_DOUBLEBUFFER_FRONT

	push {r0-r3,lr}
	mov r0, buffer_back
	bl fb32_attach_buffer
	pop {r0-r3,lr}

	b fb32_doublebuffer_set_success

	fb32_doublebuffer_set_error:
		mov r0, #1                           @ Return with Error
		b fb32_doublebuffer_set_common

	fb32_doublebuffer_set_success:
		mov r0, #0                           @ Return with Success

	fb32_doublebuffer_set_common:
		dsb                              @ Ensure Completion of Instructions Before
		isb
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

	dsb                                         @ Ensure Coherence of Cache and Memory
	isb

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
		mov r0, #1                           @ Return with Error

	fb32_attach_buffer_common:
		dsb                                  @ Ensure Completion of Instructions Before
		isb                                  @ Flush Instructions in Pipelines
		pop {r4, r5}
		mov pc, lr

.unreq buffer
.unreq buffer_addr
.unreq width
.unreq height
.unreq size
.unreq depth


/**
 * function fb32_set_cache
 * Set Cache Status for Memory Using as Framebuffer (By Section)
 *
 * Parameters
 * r0: Secure state (0) or Non-secure state (1)
 * r1: Flag of Descriptor
 *
 * Usage: r0-r4
 * Return: r0 (0 as success, 1 as error)
 * Error(1): When Framebuffer is not Defined
 */
.globl fb32_set_cache
fb32_set_cache:
	non_secure     .req r0
	desc_flag      .req r1
	memorymap_base .req r2
	size           .req r3
	temp           .req r4

	push {r4}

	dsb
	isb

	ldr memorymap_base, FB32_FRAMEBUFFER_ADDR
	cmp memorymap_base, #0
	beq fb32_set_cache_error

	ldr size, FB32_FRAMEBUFFER_SIZE
	cmp size, #0
	beq fb32_set_cache_error
	add size, size, memorymap_base

	mov temp, #0xFF00000
	add temp, #0xF0000000

	and memorymap_base, memorymap_base, temp
	and size, size, temp

	fb32_set_cache_loop:
		cmp memorymap_base, size
		bgt fb32_set_cache_success               @ Inclusive Loop Because of Cut Off by 0xFFF00000
		mov temp, desc_flag
		add temp, temp, memorymap_base
		push {r0-r3,lr}
		mov r1, memorymap_base
		mov r2, temp
		bl system32_change_descriptor
		pop {r0-r3,lr}
		add memorymap_base, memorymap_base, #0x00100000
		b fb32_set_cache_loop

	fb32_set_cache_error:
		mov r0, #1                           @ Return with Error
		b fb32_set_cache_common

	fb32_set_cache_success:
		mov r0, #0                           @ Return with Success

	fb32_set_cache_common:
		dsb                                  @ Ensure Completion of Instructions Before
		isb                                  @ Flush Instructions in Pipelines
		pop {r4}
		mov pc, lr

.unreq non_secure
.unreq desc_flag
.unreq memorymap_base
.unreq size
.unreq temp
