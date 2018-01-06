/**
 * deci32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function deci32_count_zero32
 * Count Leading Zero from Most Siginificant Bit in 32 Bit Register
 *
 * Parameters
 * r0: Register to Count
 *
 * Usage: r0-r3
 * Return: r0 (Count)
 */
.globl deci32_count_zero32
deci32_count_zero32:
	/* Auto (Local) Variables, but just Aliases */
	register      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	mask          .req r1
	base          .req r2
	count         .req r3

	mov mask, #0x80000000              @ Most Siginificant Bit
	mov count, #0

	deci32_count_zero32_loop:
		cmp count, #32
		beq deci32_count_zero32_common @ If All Zero

		and base, register, mask
		teq base, mask                 @ Similar to EORS (Exclusive OR)
		addne count, count, #1         @ No Zero flag (This Means The Bit is Zero)
		lsrne mask, mask, #1
		bne deci32_count_zero32_loop   @ If the Bit is Zero

	deci32_count_zero32_common:
		mov r0, count
		mov pc, lr

.unreq register
.unreq mask
.unreq base
.unreq count


/**
 * function deci32_float32_to_string
 * Make String of Single Precision Float Value
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 * If Float Value Exceeds 1,000,000,000.0, String Will Be Shown With Exponent and May Have Loss of Signification.
 * If Float Value is less than 1.0, String Will Be Shown With Exponent.
 *
 * Parameters
 * r0: Float Value, Must Be Type of Single Precision Float
 * r1: Minimam Length of Digits in Integer Places, 16 Digits Max
 * r2: Maximam Length of Digits in Decimal Places, Default 8 Digits
 * r3: Minimam Length of Digits in Exponent Places, 16 Digits Max
 *
 * Usage: r0-r11
 * Return: r0 (Pointer of String)
 */
.globl deci32_float32_to_string
deci32_float32_to_string:
	/* Auto (Local) Variables, but just Aliases */
	float          .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	min_integer    .req r1
	max_decimal    .req r2
	min_exponent   .req r3
	temp           .req r4
	integer        .req r5
	decimal        .req r6
	string_integer .req r7
	string_decimal .req r8
	string_cmp     .req r9
	exponent       .req r10
	minus          .req r11

	/* VFP Registers */
	vfp_float      .req s0
	vfp_integer    .req s1
	vfp_decimal    .req s2
	vfp_temp       .req s3
	vfp_ten        .req s4

	push {r4-r11,lr}
	vpush {s0-s4}

	/* Sanitize Pointers */
	mov string_integer, #0
	mov string_decimal, #0
	mov string_cmp, #0

	mov exponent, #0

	mov temp, #10
	vmov vfp_ten, temp
	vcvt.f32.s32 vfp_ten, vfp_ten

	/* Know Need of Exponent */

	vmov vfp_float, float
	vcmp.f32 vfp_float, #0
	vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
	movlt minus, #1
	movge minus, #0
	beq deci32_float32_to_string_integer

	vabs.f32 vfp_float, vfp_float

	mov temp, #1
	vmov vfp_temp, temp
	vcvt.f32.s32 vfp_temp, vfp_temp
	vcmp.f32 vfp_float, vfp_temp
	vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
	blt deci32_float32_to_string_exponentminus

	mov temp, #0x3B
	lsl temp, #8
	add temp, #0x9A
	lsl temp, #8
	add temp, #0xCA
	lsl temp, #8                                  @ Making Decimal 1,000,000,000
	vmov vfp_temp, temp
	vcvt.f32.u32 vfp_temp, vfp_temp
	vcmp.f32 vfp_float, vfp_temp
	vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
	bge deci32_float32_to_string_exponentplus

	b deci32_float32_to_string_integer

	deci32_float32_to_string_exponentminus:
		sub exponent, exponent, #1
		vmul.f32 vfp_float, vfp_float, vfp_ten
		vcmp.f32 vfp_float, vfp_temp
		vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
		blt deci32_float32_to_string_exponentminus

		b deci32_float32_to_string_convertfloat

	deci32_float32_to_string_exponentplus:
		add exponent, exponent, #1
		vdiv.f32 vfp_float, vfp_float, vfp_ten
		vcmp.f32 vfp_float, vfp_temp
		vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
		bge deci32_float32_to_string_exponentplus

	deci32_float32_to_string_convertfloat:
		cmp minus, #1
		vnegeq.f32 vfp_float, vfp_float
		vmov float, vfp_float

	/* Integer Part */

	deci32_float32_to_string_integer:

		vmov vfp_integer, float                       @ Signed
		vcvt.s32.f32 vfp_integer, vfp_integer         @ Round Down
		vmov integer, vfp_integer

		push {r0-r3}
		mov r0, integer
		mov r2, #1
		bl deci32_int32_to_string_deci
		mov string_integer, r0
		pop {r0-r3}

		.unreq min_integer
		temp2 .req r1

		cmp string_integer, #0
		beq deci32_float32_to_string_error

		push {r0-r3}
		mov r0, #1
		bl heap32_malloc
		mov string_decimal, r0
		pop {r0-r3}

		cmp string_decimal, #0
		beq deci32_float32_to_string_error

		mov temp, #0x2E
		strb temp, [string_decimal]                   @ Store Period Sign
		mov temp, #0x00
		strb temp, [string_decimal, #1]               @ Store Null Character

		push {r0-r3}
		mov r0, string_integer
		mov r1, string_decimal
		bl print32_strcat
		mov string_cmp, r0
		pop {r0-r3}

		cmp string_cmp, #0
		beq deci32_float32_to_string_error

		push {r0-r3}
		mov r0, string_integer 
		bl heap32_mfree
		pop {r0-r3}

		push {r0-r3}
		mov r0, string_decimal
		bl heap32_mfree
		pop {r0-r3}

		mov string_integer, string_cmp

		vcvt.f32.s32 vfp_integer, vfp_integer
		vmov vfp_decimal, float
		vabs.f32 vfp_integer, vfp_integer               @ Make Absolute Value
		vabs.f32 vfp_decimal, vfp_decimal               @ Make Absolute Value
		vsub.f32 vfp_decimal, vfp_decimal, vfp_integer  @ Cut Integer Part

	/* Decimal Part */

	deci32_float32_to_string_decimal:
		/* Repeat of vfp_decimal X 10^8 and Cut it till catch Zero */
		cmp max_decimal, #0
		ble deci32_float32_to_string_exponent
		mov temp, #8

		deci32_float32_to_string_decimal_loop:
			cmp temp, #0
			ble deci32_float32_to_string_decimal_common
			cmp max_decimal, #0
			ble deci32_float32_to_string_decimal_common
			vmul.f32 vfp_decimal, vfp_decimal, vfp_ten
			sub temp, temp, #1
			sub max_decimal, max_decimal, #1
			b deci32_float32_to_string_decimal_loop

		deci32_float32_to_string_decimal_common:
			mov temp2, #8
			sub temp, temp2, temp

			vmov vfp_temp, vfp_decimal
			cmp max_decimal, #0
			vcvtreq.s32.f32 vfp_temp, vfp_temp       @ Round If Maximam Length Reaches Zero
			vcvtne.s32.f32 vfp_temp, vfp_temp
			vmov decimal, vfp_temp

			push {r0-r3}
			mov r0, decimal
			mov r1, temp
			mov r2, #0
			bl deci32_int32_to_string_deci
			mov string_decimal, r0
			pop {r0-r3}
			
			push {r0-r3}
			mov r0, string_integer
			mov r1, string_decimal
			bl print32_strcat
			mov string_cmp, r0
			pop {r0-r3}

			cmp string_cmp, #0
			beq deci32_float32_to_string_error

			push {r0-r3}
			mov r0, string_integer 
			bl heap32_mfree
			pop {r0-r3}

			push {r0-r3}
			mov r0, string_decimal
			bl heap32_mfree
			pop {r0-r3}

			mov string_integer, string_cmp

			vcvt.f32.s32 vfp_temp, vfp_temp
			vsub.f32 vfp_decimal, vfp_decimal, vfp_temp

			vcmp.f32 vfp_decimal, #0
			vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
			ble deci32_float32_to_string_exponent

			b deci32_float32_to_string_decimal

	/* Exponential Part */

	deci32_float32_to_string_exponent:
		cmp exponent, #0
		beq deci32_float32_to_string_success

		push {r0-r3}
		mov r0, #1
		bl heap32_malloc
		mov string_decimal, r0
		pop {r0-r3}

		mov temp, #0x45
		strb temp, [string_decimal]                      @ Store `E`
		cmp exponent, #0
		movgt temp, #0x2B
		movlt temp, #0x2D
		strb temp, [string_decimal, #1]                  @ Store `+` or `-`
		mov temp, #0x00
		strb temp, [string_decimal, #2]                  @ Store Null Character

		push {r0-r3}
		mov r0, string_integer
		mov r1, string_decimal
		bl print32_strcat
		mov string_cmp, r0
		pop {r0-r3}

		cmp string_cmp, #0
		beq deci32_float32_to_string_error

		push {r0-r3}
		mov r0, string_integer 
		bl heap32_mfree
		pop {r0-r3}

		push {r0-r3}
		mov r0, string_decimal
		bl heap32_mfree
		pop {r0-r3}

		mov string_integer, string_cmp

		cmp exponent, #0
		mvnlt exponent, exponent              @ If Minus, Make Absolute Value
		addlt exponent, #1

		push {r0-r3}
		mov r0, exponent
		mov r1, min_exponent
		mov r2, #0
		bl deci32_int32_to_string_deci
		mov string_decimal, r0
		pop {r0-r3}

		push {r0-r3}
		mov r0, string_integer
		mov r1, string_decimal
		bl print32_strcat
		mov string_cmp, r0
		pop {r0-r3}

		cmp string_cmp, #0
		beq deci32_float32_to_string_error

		push {r0-r3}
		mov r0, string_integer 
		bl heap32_mfree
		pop {r0-r3}

		push {r0-r3}
		mov r0, string_decimal
		bl heap32_mfree
		pop {r0-r3}

		mov string_integer, string_cmp
		b deci32_float32_to_string_success

	deci32_float32_to_string_error:
		push {r0-r3}
		mov r0, string_integer 
		bl heap32_mfree
		pop {r0-r3}

		push {r0-r3}
		mov r0, string_decimal
		bl heap32_mfree
		pop {r0-r3}

		push {r0-r3}
		mov r0, string_cmp
		bl heap32_mfree
		pop {r0-r3}

		mov r0, #0
		b deci32_float32_to_string_common

	deci32_float32_to_string_success:
		mov r0, string_integer

	deci32_float32_to_string_common:
		vpop {s0-s4}
		pop {r4-r11,pc}

.unreq float
.unreq temp2
.unreq max_decimal
.unreq min_exponent
.unreq temp
.unreq integer
.unreq decimal
.unreq string_integer
.unreq string_decimal
.unreq string_cmp
.unreq exponent
.unreq minus
.unreq vfp_float
.unreq vfp_integer
.unreq vfp_decimal
.unreq vfp_temp
.unreq vfp_ten


/**
 * function deci32_int32_to_string_deci
 * Make String of Integer Value by Decimal System (Base 10)
 *
 * Parameters
 * r0: Integer Number
 * r1: Minimum Length of Digits from Left Side, Up to 16 Digits
 * r2: 0 unsigned, 1 signed
 *
 * Usage: r0-r11
 * Return: r0 (Pointer of String, If Zero, Memory Space for String Can't Be Allocated)
 */
.globl deci32_int32_to_string_deci
deci32_int32_to_string_deci:
	/* Auto (Local) Variables, but just Aliases */
	integer       .req r0
	min_length    .req r1
	signed        .req r2
	temp          .req r3
	string_lower  .req r4
	string_upper  .req r5
	string_minus  .req r6
	string_cmp    .req r7
	count_lower   .req r8
	count_upper   .req r9
	integer_lower .req r10
	integer_upper .req r11

	push {r4-r11,lr}

	cmp min_length, #16
	movgt min_length, #16

	/* Sanitize Pointers */
	mov string_lower, #0
	mov string_upper, #0
	mov string_minus, #0
	mov string_cmp, #0

	push {r0-r3}
	bl deci32_count_zero32
	mov count_lower, r0
	pop {r0-r3}

	cmp signed, #1
	cmpeq count_lower, #0                   @ Whether Top Bit is One or Zero
	movne signed, #0                        @ If Count Is Not Zero, Signed Will Perform The Same as Unsigned
	bne deci32_int32_to_string_deci_jumpunsigned

	/* Process for Minus Signed */
	mvn integer, integer                    @ All Inverter
	add integer, #1                         @ Convert Value from Minus Signed Number to Plus Signed Number

	deci32_int32_to_string_deci_jumpunsigned:
		push {r0-r3}
		bl deci32_hexa_to_deci32
		mov integer_lower, r0
		mov integer_upper, r1
		pop {r0-r3}

		push {r0-r3}
		mov r0, integer_lower
		bl deci32_count_zero32
		mov count_lower, r0
		pop {r0-r3}

		push {r0-r3}
		mov r0, integer_upper
		bl deci32_count_zero32
		mov count_upper, r0
		pop {r0-r3}

		mov temp, count_lower
		mov count_lower, #0

	deci32_int32_to_string_deci_countlower:
		subs temp, temp, #4
		addge count_lower, #1
		bge deci32_int32_to_string_deci_countlower

		mov temp, #8
		sub count_lower, temp, count_lower

		mov temp, count_upper
		mov count_upper, #0

	deci32_int32_to_string_deci_countupper:
		subs temp, temp, #4
		addge count_upper, #1
		bge deci32_int32_to_string_deci_countupper

		mov temp, #8
		sub count_upper, temp, count_upper

		cmp count_lower, min_length
		movlt count_lower, min_length                    @ Cutting off min_length Exists in deci32_int32_to_string_hexa

		cmp count_upper, #0
		beq deci32_int32_to_string_deci_lower            @ If Upper String Doesn't Exist

		sub temp, min_length, #8
		cmp count_upper, temp
		movlt count_upper, temp

	deci32_int32_to_string_deci_upper:
		push {r0-r3}
		mov r0, integer_upper
		mov r1, count_upper
		mov r2, #0
		mov r3, #0
		bl deci32_int32_to_string_hexa
		mov string_upper, r0
		pop {r0-r3}

		cmp string_upper, #0
		beq deci32_int32_to_string_deci_error

		mov count_lower, #8

	deci32_int32_to_string_deci_lower:
		push {r0-r3}
		mov r0, integer_lower
		mov r1, count_lower
		mov r2, #0
		mov r3, #0
		bl deci32_int32_to_string_hexa
		mov string_lower, r0
		pop {r0-r3}

		cmp string_lower, #0
		beq deci32_int32_to_string_deci_error

		cmp signed, #1
		bne deci32_int32_to_string_deci_cat         @ If Unsigned, Jump to Next

		push {r0-r3}
		mov r0, #1
		bl heap32_malloc
		mov string_minus, r0
		pop {r0-r3}

		cmp string_minus, #0
		beq deci32_int32_to_string_deci_error

		mov temp, #0x2D
		strb temp, [string_minus]                   @ Store Minus Sign

		mov temp, #0x00
		strb temp, [string_minus, #1]               @ Store Null Character

	deci32_int32_to_string_deci_cat:
		cmp count_upper, #0
		beq deci32_int32_to_string_deci_cat_lower

		cmp signed, #1
		bne deci32_int32_to_string_deci_cat_jump   @ If Unsigned, Jump to Next

		push {r0-r3}
		mov r0, string_minus 
		mov r1, string_upper
		bl print32_strcat
		mov string_cmp, r0
		pop {r0-r3}

		cmp string_cmp, #0
		beq deci32_int32_to_string_deci_error

		push {r0-r3}
		mov r0, string_minus 
		bl heap32_mfree
		pop {r0-r3}

		push {r0-r3}
		mov r0, string_upper
		bl heap32_mfree
		pop {r0-r3}

		mov string_upper, string_cmp

		deci32_int32_to_string_deci_cat_jump:
			push {r0-r3}
			mov r0, string_upper
			mov r1, string_lower
			bl print32_strcat
			mov string_cmp, r0
			pop {r0-r3}

			cmp string_cmp, #0
			beq deci32_int32_to_string_deci_error

			push {r0-r3}
			mov r0, string_upper 
			bl heap32_mfree
			pop {r0-r3}

			push {r0-r3}
			mov r0, string_lower
			bl heap32_mfree
			pop {r0-r3}

			b deci32_int32_to_string_deci_success 

		deci32_int32_to_string_deci_cat_lower:
			cmp signed, #1
			movne string_cmp, string_lower
			bne deci32_int32_to_string_deci_success         @ If Unsigned, Jump to Next

			push {r0-r3}
			mov r0, string_minus 
			mov r1, string_lower
			bl print32_strcat
			mov string_cmp, r0
			pop {r0-r3}

			cmp string_cmp, #0
			beq deci32_int32_to_string_deci_error

			push {r0-r3}
			mov r0, string_minus 
			bl heap32_mfree
			pop {r0-r3}

			push {r0-r3}
			mov r0, string_lower
			bl heap32_mfree
			pop {r0-r3}

			b deci32_int32_to_string_deci_success 

	deci32_int32_to_string_deci_error:
		push {r0-r3}
		mov r0, string_lower
		bl heap32_mfree
		pop {r0-r3}
		push {r0-r3}
		mov r0, string_upper
		bl heap32_mfree
		pop {r0-r3}
		push {r0-r3}
		mov r0, string_minus 
		bl heap32_mfree
		pop {r0-r3}
		push {r0-r3}
		mov r0, string_cmp 
		bl heap32_mfree
		pop {r0-r3}

		mov r0, #0
		b deci32_int32_to_string_deci_common

	deci32_int32_to_string_deci_success:
		mov r0, string_cmp

	deci32_int32_to_string_deci_common:
		pop {r4-r11,pc}
		mov pc, lr

.unreq integer
.unreq min_length
.unreq signed
.unreq temp
.unreq string_lower
.unreq string_upper
.unreq string_minus
.unreq string_cmp
.unreq count_lower
.unreq count_upper
.unreq integer_lower
.unreq integer_upper


/**
 * function deci32_int32_to_string_hexa
 * Make String of Integer Value by Hexadecimal System (Base 16)
 *
 * Parameters
 * r0: Integer Number
 * r1: Minimum Length of Digits from Left Side, Up to 8 Digits
 * r2: 0 unsigned, 1 signed
 * r3: 0 Doesn't Show Bases Mark, 1 Shows Bases Mark(`0x`)
 *
 * Usage: r0-r9
 * Return: r0 (Pointer of String, If Zero, Memory Space for String Can't Be Allocated)
 */
.globl deci32_int32_to_string_hexa
deci32_int32_to_string_hexa:
	/* Auto (Local) Variables, but just Aliases */
	integer     .req r0
	min_length  .req r1
	signed      .req r2
	base_mark   .req r3
	temp        .req r4
	mask        .req r5
	heap        .req r6
	heap_origin .req r7
	heap_size   .req r8
	count       .req r9

	push {r4-r9,lr}

	cmp min_length, #8
	movgt min_length, #8

	push {r0-r3}
	bl deci32_count_zero32
	mov count, r0
	pop {r0-r3}

	cmp signed, #1
	cmpeq count, #0                         @ Whether Top Bit is One or Zero
	movne signed, #0                        @ If Count Is Not Zero, Signed Will Perform The Same as Unsigned
	bne deci32_int32_to_string_hexa_jumpunsigned

	/* Process for Minus Signed */
	mvn integer, integer                    @ All Inverter
	add integer, #1                         @ Convert Value from Minus Signed Number to Plus Signed Number
	push {r0-r3}
	bl deci32_count_zero32
	mov count, r0
	pop {r0-r3}

	deci32_int32_to_string_hexa_jumpunsigned:
		mov temp, count
		mov count, #0

	deci32_int32_to_string_hexa_arrangecount:
		subs temp, temp, #4
		addge count, #1
		bge deci32_int32_to_string_hexa_arrangecount

		mov temp, #8
		sub count, temp, count
		cmp count, min_length
		movlt count, min_length

		mov heap_size, #1                               @ 1 Size is 4 bytes in Heap
		mov temp, count
		add temp, temp, #1                              @ Add One for Null Character
		cmp signed, #1
		addeq temp, temp, #1                            @ Add One for Minus Character
		cmp base_mark, #1
		addeq temp, temp, #2                            @ Add Two for Bases Mark, `0x`

	deci32_int32_to_string_hexa_countsize:
		subs temp, temp, #4
		addgt heap_size, #1
		bgt deci32_int32_to_string_hexa_countsize

		push {r0-r3}
		mov r0, heap_size
		bl heap32_malloc
		mov heap_origin, r0
		pop {r0-r3}

		cmp heap_origin, #0
		beq deci32_int32_to_string_hexa_error
		mov heap, heap_origin

		cmp signed, #1
		bne deci32_int32_to_string_hexa_basemark        @ If Unsigned, Jump to Next
		mov mask, #0x2D
		strb mask, [heap]                               @ Store Minus Sign
		add heap, heap, #1

	deci32_int32_to_string_hexa_basemark:
		cmp base_mark, #1
		bne deci32_int32_to_string_hexa_loop
		mov mask, #0x30
		strb mask, [heap]                       @ Store `0`
		add heap, heap, #1
		mov mask, #0x78
		strb mask, [heap]                       @ Store `x`
		add heap, heap, #1
	
	deci32_int32_to_string_hexa_loop:
		sub count, count, #1
		cmp count, #0
		blt deci32_int32_to_string_hexa_loop_common
		lsl count, #2                               @ Substitution of Multiplication by 4
		mov mask, #0xF
		lsl mask, count
		and mask, integer, mask
		lsr mask, count
		cmp mask, #9
		addls mask, mask, #0x30                     @ Ascii Table Number Offset
		addhi mask, mask, #0x37                     @ Ascii Table Alphabet Offset - 9
		strb mask, [heap]
		add heap, heap, #1
		lsr count, #2                               @ Substitution of Division by 4

		b deci32_int32_to_string_hexa_loop

		deci32_int32_to_string_hexa_loop_common:
			mov mask, #0
			strb mask, [heap]
			b deci32_int32_to_string_hexa_success

	deci32_int32_to_string_hexa_error:
		mov r0, #0
		b deci32_int32_to_string_hexa_common

	deci32_int32_to_string_hexa_success:
		mov r0, heap_origin

	deci32_int32_to_string_hexa_common:
		pop {r4-r9,pc}
		mov pc, lr

.unreq integer
.unreq min_length
.unreq signed
.unreq base_mark
.unreq temp
.unreq mask
.unreq heap
.unreq heap_origin
.unreq heap_size
.unreq count


/**
 * function deci32_string_to_int32
 * Make 32-bit Unsigned/Signed Integer From String (Decimal System)
 * Caution! The Range of Decimal Number is 0 through 4,294,967,295 on Unsigned, -2,147,483,648 thorugh 2,147,483,647 on Signed.
 * Otherwise, You'll Get Zero to Return.
 *
 * Parameters
 * r0: Heap of String
 * r1: Length of String (Max. 10 if Unsigned, 11 if Signed)
 *
 * Return: r0 (32-bit Unsigned/Signed Integer)
 */
.globl deci32_string_to_int32
deci32_string_to_int32:
	/* Auto (Local) Variables, but just Aliases */
	heap        .req r0
	length      .req r1
	signed      .req r2
	byte        .req r3
	i           .req r4
	deci_lower  .req r5
	deci_upper  .req r6
	shift       .req r7

	push {r4-r7}

	sub length, length, #1

	mov i, #0
	mov deci_lower, #0
	mov deci_upper, #0

	ldrb byte, [heap]
	cmp byte, #0x2D                   @ Minus
	moveq signed, #1
	movne signed, #0
	cmpne byte, #0x2B                 @ Plus
	bne deci32_string_to_int32_length @ If Neither Minus nor Plus

	/* If Signed */
	add i, i, #1
	sub length, length, #1

	deci32_string_to_int32_length:

		cmp length, #9
		bgt deci32_string_to_int32_success

	deci32_string_to_int32_loop:

		ldrb byte, [heap, i]
		sub byte, byte, #0x30                     @ Ascii Table Number Offset

		lsl shift, length, #2                     @ Substitute of Multiplication by 4

		cmp length, #8
		bhs deci32_string_to_int32_loop_upper

		/* Lower Number */
		lsl byte, byte, shift

		add deci_lower, deci_lower, byte

		b deci32_string_to_int32_loop_common

		/* Upper Number */
		deci32_string_to_int32_loop_upper:

			sub shift, shift, #32

			lsl byte, byte, shift

			add deci_upper, deci_upper, byte

		deci32_string_to_int32_loop_common:

			add i, i, #1
			sub length, length, #1

			cmp length, #0
			bge deci32_string_to_int32_loop

			push {r0-r3,lr}
			mov r0, deci_lower
			mov r1, deci_upper
			bl deci32_deci_to_hexa32
			mov deci_lower, r0
			pop {r0-r3,lr}

			cmp signed, #1
			mvneq deci_lower, deci_lower          @ Logical Not to Convert Plus to Minus
			addeq deci_lower, deci_lower, #1      @ Add 1 to Convert Plus to Minus

	deci32_string_to_int32_success:
		mov r0, deci_lower

	deci32_string_to_int32_common:
		pop {r4-r7}
		mov pc, lr

.unreq heap
.unreq length
.unreq signed
.unreq byte
.unreq i
.unreq deci_lower
.unreq deci_upper
.unreq shift


/**
 * function deci32_string_to_float32
 * Make 32-bit Float From String (Decimal System)
 * Caution! The Range of Integer Part is -2,147,483,648 thorugh 2,147,483,647 on Signed.
 * Otherwise, You'll Get Zero on Integer Part to Return.
 *
 * Parameters
 * r0: Heap of String
 *
 * Return: r0 (32-bit Float, -0 Negative Zero as error)
 * Error(-0): String Could Not Be Converted
 */
.globl deci32_string_to_float32
deci32_string_to_float32:
	/* Auto (Local) Variables, but just Aliases */
	heap               .req r0
	temp               .req r1
	minus              .req r2
	temp2              .req r3
	length_integer     .req r4
	integer            .req r5
	frac_offset        .req r6
	length_exponent    .req r7
	exponent           .req r8

	vfp_float          .req s0
	vfp_float_frac     .req s1
	vfp_float_cal      .req s2
	vfp_ten            .req s3

	push {r4-r8,lr}
	vpush {s0-s3}

	/* Check Existing of Exponential Part */

	push {r0-r3}
	mov r1, #0x45                     @ Ascii Code of E
	bl print32_charindex
	mov exponent, r0
	pop {r0-r3}

	cmp exponent, #-1
	bne deci32_string_to_float32_preexpo

	push {r0-r3}
	mov r1, #0x65                     @ Ascii Code of e
	bl print32_charindex
	mov exponent, r0
	pop {r0-r3}

	cmp exponent, #-1
	moveq length_exponent, #0
	beq deci32_string_to_float32_int

	deci32_string_to_float32_preexpo:

		push {r0-r3}
		bl print32_strlen
		mov length_exponent, r0
		pop {r0-r3}

		sub length_exponent, length_exponent, exponent

	deci32_string_to_float32_int:

		/* Integer Part */

		push {r0-r3}
		mov r1, #0x2E                     @ Ascii Code for Period
		bl print32_charindex
		mov length_integer, r0
		pop {r0-r3}

		cmp length_integer, #-1
		beq deci32_string_to_float32_error

		push {r0-r3}
		mov r1, length_integer
		bl deci32_string_to_int32
		mov integer, r0
		pop {r0-r3}

		cmp integer, #0
		movlt minus, #1
		movge minus, #0

		vmov vfp_float, integer
		vcvt.f32.s32 vfp_float, vfp_float

		/* Fractional Part */

		add heap, heap, length_integer    @ To Period
		add heap, heap, #1                @ To Next of Period

		.unreq length_integer
		.unreq integer

		length_frac .req r4
		frac        .req r5

		push {r0-r3}
		bl print32_strlen
		mov length_frac, r0
		pop {r0-r3}

		sub length_frac, length_frac, length_exponent

		mov frac_offset, #0

		mov temp2, #0
		vmov vfp_float_frac, temp2
		vcvt.f32.s32 vfp_float_frac, vfp_float_frac

		mov temp2, #10
		vmov vfp_ten, temp2
		vcvt.f32.s32 vfp_ten, vfp_ten

		.unreq temp2
		length_dup .req r3

	deci32_string_to_float32_frac:
		cmp length_frac, #8
		movge length_dup, #8
		movlt length_dup, length_frac

		push {r0-r3}
		mov r1, length_dup
		bl deci32_string_to_int32
		mov frac, r0
		pop {r0-r3}

		vmov vfp_float_cal, frac
		vcvt.f32.s32 vfp_float_cal, vfp_float_cal

		add heap, heap, length_dup               @ Offset of Heap, Next Fractional Places or "E"/"e" Sign

		add length_dup, length_dup, frac_offset

		deci32_string_to_float32_frac_loop:

			vdiv.f32 vfp_float_cal, vfp_float_cal, vfp_ten

			sub length_dup, length_dup, #1
			cmp length_dup, #0
			bgt deci32_string_to_float32_frac_loop

		vadd.f32 vfp_float_frac, vfp_float_frac, vfp_float_cal

		subge length_frac, length_frac, #8
		cmp length_frac, #0
		addgt frac_offset, frac_offset, #8
		bgt deci32_string_to_float32_frac

		cmp minus, #1
		vnegeq.f32 vfp_float_frac, vfp_float_frac
		vadd.f32 vfp_float, vfp_float, vfp_float_frac

	deci32_string_to_float32_expo:
		cmp exponent, #-1
		beq deci32_string_to_float32_success

		/* Exponential Part */

		add heap, heap, #1                       @ To Next of "E"/"e" Sign
		sub length_exponent, length_exponent, #1 @ Subtract "E"/"e" Sign

		push {r0-r3}
		mov r1, length_exponent
		bl deci32_string_to_int32
		mov exponent, r0
		pop {r0-r3}

		cmp exponent, #0
		movge minus, #0
		movlt minus, #1
		mvnlt exponent, exponent                 @ Logical Not to Convert Plus to Minus
		addlt exponent, exponent, #1             @ Add 1 to Convert Plus to Minus

	deci32_string_to_float32_expo_loop:
		cmp exponent, #0
		ble deci32_string_to_float32_success

		cmp minus, #1
		vdiveq.f32 vfp_float, vfp_float, vfp_ten
		vmulne.f32 vfp_float, vfp_float, vfp_ten

		sub exponent, exponent, #1

		b deci32_string_to_float32_expo_loop

	deci32_string_to_float32_error:
		mov r0, #0x80000000                      @ Error With Negative Zero (IEEE754)
		b deci32_string_to_float32_common

	deci32_string_to_float32_success:
		vmov r0, vfp_float

	deci32_string_to_float32_common:
		vpop {s0-s3}
		pop {r4-r8,pc}

.unreq heap
.unreq temp
.unreq minus
.unreq length_dup
.unreq length_frac
.unreq frac
.unreq frac_offset
.unreq length_exponent
.unreq exponent
.unreq vfp_float
.unreq vfp_float_frac
.unreq vfp_float_cal
.unreq vfp_ten


/**
 * function deci32_hexa_to_deci32
 * Convert Hexadecimal Bases (0-F) to Decimal Bases (0-9)
 *
 * Parameters
 * r0: Hexadecimal Number to Be Converted
 *
 * Return: r0 (Lower Bits of Decimal Number), r1 (Upper Bits of Decimal Number)
 */
.globl deci32_hexa_to_deci32
deci32_hexa_to_deci32:
	/* Auto (Local) Variables, but just Aliases */
	hexa        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	deci_upper  .req r1
	power_lower .req r2
	power_upper .req r3
	dup_hexa    .req r4
	i           .req r5
	shift       .req r6
	bitmask     .req r7

	push {r4-r7}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                    @ Similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	mov dup_hexa, hexa
	
	.unreq hexa
	deci_lower .req r0

	mov deci_lower, #0
	mov deci_upper, #0
	mov power_upper, #0

	mov i, #0

	deci32_hexa_to_deci32_loop:
		mov bitmask, #0xF                         @ 0b1111
		lsl shift, i, #2                          @ Substitute of Multiplication by 4
		lsl bitmask, bitmask, shift               @ Make bitmask
		and bitmask, dup_hexa, bitmask
		lsr bitmask, bitmask, shift               @ Make One Digit Number

		cmp i, #0
		ldreq power_lower, deci32_hexa_to_deci32_0                @ 16^0
		beq deci32_hexa_to_deci32_loop_loop

		cmp i, #1
		ldreq power_lower, deci32_hexa_to_deci32_1                @ 16^1
		beq deci32_hexa_to_deci32_loop_loop

		cmp i, #2
		ldreq power_lower, deci32_hexa_to_deci32_2                @ 16^2
		beq deci32_hexa_to_deci32_loop_loop

		cmp i, #3
		ldreq power_lower, deci32_hexa_to_deci32_3                @ 16^3
		beq deci32_hexa_to_deci32_loop_loop

		cmp i, #4
		ldreq power_lower, deci32_hexa_to_deci32_4                @ 16^4
		beq deci32_hexa_to_deci32_loop_loop

		cmp i, #5
		ldreq power_lower, deci32_hexa_to_deci32_5                @ 16^5
		beq deci32_hexa_to_deci32_loop_loop

		cmp i, #6
		ldreq power_lower, deci32_hexa_to_deci32_6                @ 16^6
		beq deci32_hexa_to_deci32_loop_loop

		cmp i, #7
		ldreq power_lower, deci32_hexa_to_deci32_7_lower          @ 16^7 Lower Bits
		ldreq power_upper, deci32_hexa_to_deci32_7_upper          @ 16^7 Upper Bits

		deci32_hexa_to_deci32_loop_loop:

			cmp bitmask, #0
			ble deci32_hexa_to_deci32_loop_common

			push {lr}
			bl deci32_deci_add64
			pop {lr}

			sub bitmask, bitmask, #1

			b deci32_hexa_to_deci32_loop_loop

		deci32_hexa_to_deci32_loop_common:

			add i, i, #1
			cmp i, #8
			blo deci32_hexa_to_deci32_loop

	deci32_hexa_to_deci32_common:
		pop {r4-r7}     @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			        @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number

		mov pc, lr

/* Variables */
.balign 4
deci32_hexa_to_deci32_0:       .word 0x00000001 @ 16^0
deci32_hexa_to_deci32_1:       .word 0x00000016 @ 16^1
deci32_hexa_to_deci32_2:       .word 0x00000256 @ 16^2
deci32_hexa_to_deci32_3:       .word 0x00004096 @ 16^3
deci32_hexa_to_deci32_4:       .word 0x00065536 @ 16^4
deci32_hexa_to_deci32_5:       .word 0x01048576 @ 16^5
deci32_hexa_to_deci32_6:       .word 0x16777216 @ 16^6
deci32_hexa_to_deci32_7_lower: .word 0x68435456 @ 16^7 Lower Bits
deci32_hexa_to_deci32_7_upper: .word 0x00000002 @ 16^7 Upper Bits
.balign 4

.unreq deci_lower
.unreq deci_upper
.unreq power_lower
.unreq power_upper
.unreq dup_hexa
.unreq i
.unreq shift
.unreq bitmask


/**
 * function deci32_deci_add64
 * Addition with Decimal Bases (0-9)
 *
 * Parameters
 * r0: Lower Bits of First Number, needed between 0-9 in all digits
 * r1: Upper Bits of First Number, needed between 0-9 in all digits
 * r2: Lower Bits of Second Number, needed between 0-9 in all digits
 * r3: Upper Bits of Second Number, needed between 0-9 in all digits
 *
 * Return: r0 (Lower Bits of Decimal Number), r1 (Upper Bits of Decimal Number), -1 (ALL Ones on r0 and r1) as error
 * Error: This function could not calculate because of digit-overflow.
 */
.globl deci32_deci_add64
deci32_deci_add64:
	/* Auto (Local) Variables, but just Aliases */
	lower_1        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	upper_1        .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	lower_2        .req r2 @ Parameter, Register for Argument, Scratch Register
	upper_2        .req r3 @ Parameter, Register for Argument, Scratch Register
	dup_lower_1    .req r4 @ Duplication of lower_1
	dup_upper_1    .req r5 @ Duplication of upper_1
	i              .req r6
	shift          .req r7
	bitmask_1      .req r8
	bitmask_2      .req r9
	carry_flag     .req r10

	push {r4-r10}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			@ Similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	mov dup_lower_1, lower_1
	mov dup_upper_1, upper_1
	mov lower_1, #0
	mov upper_1, #0
	mov carry_flag, #0

	mov i, #0

	deci32_deci_add64_loop:
		mov bitmask_1, #0xF                            @ 0b1111
		mov bitmask_2, #0xF

		lsl shift, i, #2                               @ Substitute of Multiplication by 4

		cmp i, #8
		bhs deci32_deci_add64_loop_uppernumber

		/* Lower Number */
		lsl bitmask_1, bitmask_1, shift
		lsl bitmask_2, bitmask_2, shift

		and bitmask_1, dup_lower_1, bitmask_1
		and bitmask_2, lower_2, bitmask_2

		b deci32_deci_add64_loop_cal

		/* Upper Number */
		deci32_deci_add64_loop_uppernumber:

			sub shift, shift, #32

			lsl bitmask_1, bitmask_1, shift
			lsl bitmask_2, bitmask_2, shift

			and bitmask_1, dup_upper_1, bitmask_1
			and bitmask_2, upper_2, bitmask_2

		deci32_deci_add64_loop_cal:
		
			lsr bitmask_1, bitmask_1, shift
			lsr bitmask_2, bitmask_2, shift

			add bitmask_1, bitmask_1, bitmask_2
			add bitmask_1, bitmask_1, carry_flag

			cmp bitmask_1, #0x10
			bhs deci32_deci_add64_loop_cal_hexacarry

			cmp bitmask_1, #0x0A
			bhs deci32_deci_add64_loop_cal_decicarry

			mov carry_flag, #0                      @ Clear Carry

			b deci32_deci_add64_loop_common	

			deci32_deci_add64_loop_cal_hexacarry:

				sub bitmask_1, #0x10
				add bitmask_1, #0x06 
				mov carry_flag, #1              @ Set Carry

				b deci32_deci_add64_loop_common

			deci32_deci_add64_loop_cal_decicarry:

				sub bitmask_1, #0x0A
				mov carry_flag, #1              @ Set Carry

		deci32_deci_add64_loop_common:
			lsl bitmask_1, bitmask_1, shift

			cmp i, #8
			bhs deci32_deci_add64_loop_common_uppernumber

			/* Lower Number */
			add lower_1, lower_1, bitmask_1

			b deci32_deci_add64_loop_common_common

			/* Upper Number */
			deci32_deci_add64_loop_common_uppernumber:

				add upper_1, upper_1, bitmask_1

			deci32_deci_add64_loop_common_common:

				add i, i, #1
				cmp i, #16
				blo deci32_deci_add64_loop

				cmp carry_flag, #1
				beq deci32_deci_add64_error

	deci32_deci_add64_success:
		b deci32_deci_add64_common

	deci32_deci_add64_error:
		mvn r0, #0                                      @ Return with Error
		mvn r1, #0

	deci32_deci_add64_common:
		pop {r4-r10}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			        @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number

		mov pc, lr

.unreq lower_1
.unreq upper_1
.unreq lower_2
.unreq upper_2
.unreq dup_lower_1
.unreq dup_upper_1
.unreq i
.unreq shift
.unreq bitmask_1
.unreq bitmask_2
.unreq carry_flag


/**
 * function deci32_deci_to_hexa32
 * Convert Decimal Bases (0-9) to Hexadecimal Bases (0-F)
 * Caution! The Range of Decimal Number is 0 through 4,294,967,295.
 *
 * Parameters
 * r0: Lower Bits of Decimal Number to Be Converted, needed between 0-9 in all digits
 * r1: Upper Bits of Decimal Number to Be Converted, needed between 0-9 in all digits
 *
 * Return: r0 (Hexadecimal Number)
 */
.globl deci32_deci_to_hexa32
deci32_deci_to_hexa32:
	/* Auto (Local) Variables, but just Aliases */
	deci_lower     .req r0
	deci_upper     .req r1
	power_lower    .req r2
	power_upper    .req r3
	hexa           .req r4
	i              .req r5
	shift          .req r6
	deci_lower_dup .req r7
	deci_upper_dup .req r8

	push {r4-r8} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                 @ Similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	mov hexa, #0

	mov i, #7

	deci32_deci_to_hexa32_loop:

		cmp i, #0
		ldreq power_lower, deci32_deci_to_hexa32_0                @ 16^1
		moveq power_upper, #0
		ldreq shift, deci32_deci_to_hexa32_shift_0
		beq deci32_deci_to_hexa32_loop_loop

		cmp i, #1
		ldreq power_lower, deci32_deci_to_hexa32_1                @ 16^1
		moveq power_upper, #0
		ldreq shift, deci32_deci_to_hexa32_shift_1
		beq deci32_deci_to_hexa32_loop_loop

		cmp i, #2
		ldreq power_lower, deci32_deci_to_hexa32_2                @ 16^2
		moveq power_upper, #0
		ldreq shift, deci32_deci_to_hexa32_shift_2
		beq deci32_deci_to_hexa32_loop_loop

		cmp i, #3
		ldreq power_lower, deci32_deci_to_hexa32_3                @ 16^3
		moveq power_upper, #0
		ldreq shift, deci32_deci_to_hexa32_shift_3
		beq deci32_deci_to_hexa32_loop_loop

		cmp i, #4
		ldreq power_lower, deci32_deci_to_hexa32_4                @ 16^4
		moveq power_upper, #0
		ldreq shift, deci32_deci_to_hexa32_shift_4
		beq deci32_deci_to_hexa32_loop_loop

		cmp i, #5
		ldreq power_lower, deci32_deci_to_hexa32_5                @ 16^5
		moveq power_upper, #0
		ldreq shift, deci32_deci_to_hexa32_shift_5
		beq deci32_deci_to_hexa32_loop_loop

		cmp i, #6
		ldreq power_lower, deci32_deci_to_hexa32_6                @ 16^6
		moveq power_upper, #0
		ldreq shift, deci32_deci_to_hexa32_shift_6
		beq deci32_deci_to_hexa32_loop_loop

		cmp i, #7
		ldreq power_lower, deci32_deci_to_hexa32_7_lower          @ 16^7 Lower Bits
		ldreq power_upper, deci32_deci_to_hexa32_7_upper          @ 16^7 Upper Bits
		ldreq shift, deci32_deci_to_hexa32_shift_7

		deci32_deci_to_hexa32_loop_loop:

			push {r0-r3,lr}
			bl deci32_deci_sub64
			mov deci_lower_dup, r0
			mov deci_upper_dup, r1
			cmp r0, #-1
			cmpeq r1, #-1
			pop {r0-r3,lr}
			beq deci32_deci_to_hexa32_loop_common

			mov deci_lower, deci_lower_dup
			mov deci_upper, deci_upper_dup
			add hexa, hexa, shift

			b deci32_deci_to_hexa32_loop_loop

		deci32_deci_to_hexa32_loop_common:

			sub i, i, #1
			cmp i, #0
			bge deci32_deci_to_hexa32_loop

	deci32_deci_to_hexa32_common:
		mov r0, hexa
		pop {r4-r8} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                    @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number

		mov pc, lr

/* Variables */
.balign 4
deci32_deci_to_hexa32_0:       .word 0x00000001 @ 16^0
deci32_deci_to_hexa32_1:       .word 0x00000016 @ 16^1
deci32_deci_to_hexa32_2:       .word 0x00000256 @ 16^2
deci32_deci_to_hexa32_3:       .word 0x00004096 @ 16^3
deci32_deci_to_hexa32_4:       .word 0x00065536 @ 16^4
deci32_deci_to_hexa32_5:       .word 0x01048576 @ 16^5
deci32_deci_to_hexa32_6:       .word 0x16777216 @ 16^6
deci32_deci_to_hexa32_7_lower: .word 0x68435456 @ 16^7 Lower Bits
deci32_deci_to_hexa32_7_upper: .word 0x00000002 @ 16^7 Upper Bits
deci32_deci_to_hexa32_shift_0: .word 0x00000001 @ 16^0
deci32_deci_to_hexa32_shift_1: .word 0x00000010 @ 16^1
deci32_deci_to_hexa32_shift_2: .word 0x00000100 @ 16^2
deci32_deci_to_hexa32_shift_3: .word 0x00001000 @ 16^3
deci32_deci_to_hexa32_shift_4: .word 0x00010000 @ 16^4
deci32_deci_to_hexa32_shift_5: .word 0x00100000 @ 16^5
deci32_deci_to_hexa32_shift_6: .word 0x01000000 @ 16^6
deci32_deci_to_hexa32_shift_7: .word 0x10000000 @ 16^7
.balign 4

.unreq deci_lower
.unreq deci_upper
.unreq power_lower
.unreq power_upper
.unreq hexa
.unreq i
.unreq shift
.unreq deci_lower_dup
.unreq deci_upper_dup


/**
 * function deci32_deci_sub64
 * Subtraction with Decimal Bases (0-9)
 *
 * Parameters
 * r0: Lower Bits of First Number, needed between 0-9 in all digits
 * r1: Upper Bits of First Number, needed between 0-9 in all digits
 * r2: Lower Bits of Second Number, needed between 0-9 in all digits
 * r3: Upper Bits of Second Number, needed between 0-9 in all digits
 *
 * Return: r0 (Lower Bits of Decimal Number), r1 (Upper Bits of Decimal Number), -1 (ALL Ones on r0 and r1) as error
 * Error: This function could not calculate because the result is signed minus.
 */
.globl deci32_deci_sub64
deci32_deci_sub64:
	/* Auto (Local) Variables, but just Aliases */
	lower_1        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	upper_1        .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	lower_2        .req r2 @ Parameter, Register for Argument, Scratch Register
	upper_2        .req r3 @ Parameter, Register for Argument, Scratch Register
	dup_lower_1    .req r4 @ Duplication of lower_1
	dup_upper_1    .req r5 @ Duplication of upper_1
	i              .req r6
	shift          .req r7
	bitmask_1      .req r8
	bitmask_2      .req r9
	carry_flag     .req r10

	push {r4-r10}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			@ Similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	mov dup_lower_1, lower_1
	mov dup_upper_1, upper_1
	mov lower_1, #0
	mov upper_1, #0
	mov carry_flag, #0

	mov i, #0

	deci32_deci_sub64_loop:
		mov bitmask_1, #0xF                            @ 0b1111
		mov bitmask_2, #0xF

		lsl shift, i, #2                               @ Substitute of Multiplication by 4

		cmp i, #8
		bhs deci32_deci_sub64_loop_uppernumber

		/* Lower Number */
		lsl bitmask_1, bitmask_1, shift
		lsl bitmask_2, bitmask_2, shift

		and bitmask_1, dup_lower_1, bitmask_1
		and bitmask_2, lower_2, bitmask_2

		b deci32_deci_sub64_loop_cal

		/* Upper Number */
		deci32_deci_sub64_loop_uppernumber:

			sub shift, shift, #32

			lsl bitmask_1, bitmask_1, shift
			lsl bitmask_2, bitmask_2, shift

			and bitmask_1, dup_upper_1, bitmask_1
			and bitmask_2, upper_2, bitmask_2

		deci32_deci_sub64_loop_cal:
	
			lsr bitmask_1, bitmask_1, shift
			lsr bitmask_2, bitmask_2, shift

			sub bitmask_1, bitmask_1, bitmask_2
			sub bitmask_1, bitmask_1, carry_flag

			cmp bitmask_1, #0x0
			blt deci32_deci_sub64_loop_cal_carry

			mov carry_flag, #0                      @ Clear Carry

			b deci32_deci_sub64_loop_common	

			deci32_deci_sub64_loop_cal_carry:

				add bitmask_1, bitmask_1, #10        @ Value of bitmask_1 is minus
				mov carry_flag, #1                   @ Set Carry

		deci32_deci_sub64_loop_common:
			lsl bitmask_1, bitmask_1, shift

			cmp i, #8
			bhs deci32_deci_sub64_loop_common_uppernumber

			/* Lower Number */
			add lower_1, lower_1, bitmask_1

			b deci32_deci_sub64_loop_common_common

			/* Upper Number */
			deci32_deci_sub64_loop_common_uppernumber:

				add upper_1, upper_1, bitmask_1

			deci32_deci_sub64_loop_common_common:

				add i, i, #1
				cmp i, #16
				blo deci32_deci_sub64_loop

				cmp carry_flag, #1
				beq deci32_deci_sub64_error

	deci32_deci_sub64_success:
		b deci32_deci_sub64_common

	deci32_deci_sub64_error:
		mvn r0, #0                                      @ Return with Error
		mvn r1, #0

	deci32_deci_sub64_common:
		pop {r4-r10}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			        @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number

		mov pc, lr

.unreq lower_1
.unreq upper_1
.unreq lower_2
.unreq upper_2
.unreq dup_lower_1
.unreq dup_upper_1
.unreq i
.unreq shift
.unreq bitmask_1
.unreq bitmask_2
.unreq carry_flag
