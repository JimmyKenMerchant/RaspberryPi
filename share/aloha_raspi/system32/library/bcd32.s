/**
 * bcd32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/* Calculation with Binary-coded Decimal (BCD) */

/**
 * function bcd32_bcdstring
 * Make String for BCD Process
 * Caution! This function makes string allocated from Heap.
 *
 * Parameters
 * r0: Lower Half of Decimal Value
 * r1: Upper Half Of Decimal Value
 * r2: Plus Sign (0) or Minus Sign (1)
 *
 * Return: r0 (Pointer of String of Decimal Number, If Zero Memory Allocation Fails)
 */
.globl bcd32_bcdstring
bcd32_bcdstring:
	/* Auto (Local) Variables, but just Aliases */
	deci_lower    .req r0
	deci_upper    .req r1
	sign          .req r2
	temp          .req r3
	ret_lower     .req r4
	ret_upper     .req r5
	ret_all       .req r6
	ret_minus     .req r7
	count         .req r8

	push {r4-r8,lr}

	/* Make String of Upper Part */

	clz temp, deci_upper
	mov count, #0
	bcd32_bcdstring_countupper:
		subs temp, temp, #4
		addge count, #1
		bge bcd32_bcdstring_countupper

	mov temp, #8
	sub count, temp, count

	push {r0-r3}
	mov r0, deci_upper
	mov r1, count
	mov r2, #0
	mov r3, #0
	bl deci32_int32_to_string_hexa
	mov ret_upper, r0
	pop {r0-r3}

	cmp ret_upper, #0
	beq bcd32_bcdstring_error

	/* Make String of Lower Part */

	cmp count, #0
	movgt count, #8          @ If Any Digit at Upper Part Exists
	bgt bcd32_bcdstring_jump @ If Any Digit at Upper Part Exists

	clz temp, deci_lower
	mov count, #0
	bcd32_bcdstring_countlower:
		subs temp, temp, #4
		addge count, #1
		bge bcd32_bcdstring_countlower

	mov temp, #8
	subs count, temp, count
	moveq count, #1         @ If count is Zero

	bcd32_bcdstring_jump:

		push {r0-r3}
		mov r1, count
		mov r2, #0
		mov r3, #0
		bl deci32_int32_to_string_hexa
		mov ret_lower, r0
		pop {r0-r3}

		cmp ret_lower, #0
		beq bcd32_bcdstring_error

		push {r0-r3}
		mov r0, ret_upper
		mov r1, ret_lower
		bl print32_strcat
		mov ret_all, r0
		pop {r0-r3}

		cmp ret_all, #0
		beq bcd32_bcdstring_error

		push {r0-r3}
		mov r0, ret_upper
		bl heap32_mfree
		pop {r0-r3}

		push {r0-r3}
		mov r0, ret_lower
		bl heap32_mfree
		pop {r0-r3}

		cmp sign, #1
		bne bcd32_bcdstring_success

		push {r0-r3}
		mov r0, #1
		bl heap32_malloc
		mov ret_upper, r0
		pop {r0-r3}

		cmp ret_upper, #0
		beq bcd32_bcdstring_error

		mov temp, #0x2D
		strb temp, [ret_upper]                   @ Store Minus Sign
		mov temp, #0x00
		strb temp, [ret_upper, #1]               @ Store Null Character

		mov ret_lower, ret_all

		push {r0-r3}
		mov r0, ret_upper
		mov r1, ret_lower
		bl print32_strcat
		mov ret_all, r0
		pop {r0-r3}

		cmp ret_all, #0
		beq bcd32_bcdstring_error

		push {r0-r3}
		mov r0, ret_upper
		bl heap32_mfree
		pop {r0-r3}

		push {r0-r3}
		mov r0, ret_lower
		bl heap32_mfree
		pop {r0-r3}

		b bcd32_bcdstring_success

	bcd32_bcdstring_error:
		mov r0, #0
		b bcd32_bcdstring_common

	bcd32_bcdstring_success:
		mov r0, ret_all

	bcd32_bcdstring_common:
		pop {r4-r8,pc}

.unreq deci_lower 
.unreq deci_upper
.unreq sign
.unreq temp
.unreq ret_lower
.unreq ret_upper
.unreq ret_all
.unreq ret_minus
.unreq count


/**
 * function bcd32_badd
 * Signed Addition with Decimal Bases (0-9), -9,999,999,999,999,999 to 9,999,999,999,999,999
 * If Saturated, Returns All F in 16 Digits
 * Caution! This function makes string allocated from Heap.
 *
 * Parameters
 * r0: Pointer of String of First Number, needed between 0-9 in all digits
 * r1: Length of String of First Number
 * r2: Pointer of String of Second Number, needed between 0-9 in all digits
 * r3: Length of String of Second Number
 *
 * Return: r0 (Pointer of String of Decimal Number, If Zero Memory Allocation Fails)
 */
.globl bcd32_badd
bcd32_badd:
	/* Auto (Local) Variables, but just Aliases */
	string1        .req r0
	length1        .req r1
	string2        .req r2
	length2        .req r3
	deci1_lower    .req r4
	deci1_upper    .req r5
	deci2_lower    .req r6
	deci2_upper    .req r7
	sign1          .req r8
	sign2          .req r9

	push {r4-r9,lr}

	/* Check Existing of minus */

	push {r0-r3}
	mov r2, #0x2D                     @ Ascii Code of Minus
	bl print32_charsearch
	mov sign1, r0
	pop {r0-r3}
	cmp sign1, #-1
	addne string1, string1, sign1
	subne length1, length1, sign1
	movne sign1, #1
	moveq sign1, #0

	push {r0-r3}
	bl deci32_string_to_deci
	mov deci1_lower, r0
	mov deci1_upper, r1
	pop {r0-r3}

	push {r0-r3}
	mov r0, string2
	mov r1, length2
	mov r2, #0x2D                     @ Ascii Code of Minus
	bl print32_charsearch
	mov sign2, r0
	pop {r0-r3}
	cmp sign2, #-1
	addne string2, string2, sign2
	subne length2, length2, sign2
	movne sign2, #1
	moveq sign2, #0

	push {r0-r3}
	mov r0, string2
	mov r1, length2
	bl deci32_string_to_deci
	mov deci2_lower, r0
	mov deci2_upper, r1
	pop {r0-r3}

	/* If Sign of Value is Diffrent from Another */
	cmp sign1, #1
	cmpeq sign2, #0
	beq bcd32_badd_subtraction
	cmp sign1, #0
	cmpeq sign2, #1
	beq bcd32_badd_subtraction

	/* Same Signs Mean Addition */
	push {r0-r3}
	mov r0, deci1_lower
	mov r1, deci1_upper
	mov r2, deci2_lower
	mov r3, deci2_upper
	bl bcd32_deci_add64
	mov deci1_lower, r0
	mov deci1_upper, r1
	pop {r0-r3}

	/* If Carry Set, Error Value */
	movcs deci1_lower, #0xFFFFFFFF
	movcs deci1_upper, #0xFFFFFFFF

	b bcd32_badd_string

	bcd32_badd_subtraction:
		/* Diffrent Signs Mean Subtraction */

		/* Check Which Is Higher than Another */
		cmp deci1_upper, deci2_upper
		/* First Is Higher on Uppers */
		bhi bcd32_badd_subtraction_calc
		/* First Is Lower on Uppers */
		blo bcd32_badd_subtraction_swap
		/* Uppers Are Same Value, So Check Lowers */
		cmpeq deci1_lower, deci2_lower
		/* Uppers Are Same Value, But First is Higher or Same on Lowers */
		bhs bcd32_badd_subtraction_calc

		bcd32_badd_subtraction_swap:
			mov string1, deci1_upper
			mov deci1_upper, deci2_upper
			mov deci2_upper, string1
			mov string1, deci1_lower
			mov deci1_lower, deci2_lower
			mov deci2_lower, string1
			/* Sign of Return Value Becomes Sign of Second Value */
			mov sign1, sign2

		bcd32_badd_subtraction_calc:
			push {r0-r3}
			mov r0, deci1_lower
			mov r1, deci1_upper
			mov r2, deci2_lower
			mov r3, deci2_upper
			bl bcd32_deci_sub64
			mov deci1_lower, r0
			mov deci1_upper, r1
			pop {r0-r3}

	bcd32_badd_string:
		push {r0-r3}
		mov r0, deci1_lower
		mov r1, deci1_upper
		mov r2, sign1
		bl bcd32_bcdstring
		mov deci1_upper, r0
		pop {r0-r3}

		cmp deci1_upper, #0
		bne bcd32_badd_success

	bcd32_badd_error:
		mov r0, #0
		b bcd32_badd_common

	bcd32_badd_success:
		mov r0, deci1_upper

	bcd32_badd_common:
		pop {r4-r9,pc}

.unreq string1
.unreq length1
.unreq string2
.unreq length2
.unreq deci1_lower
.unreq deci1_upper
.unreq deci2_lower
.unreq deci2_upper
.unreq sign1
.unreq sign2


/**
 * function bcd32_bsub
 * Signed Subtraction with Decimal Bases (0-9), -9,999,999,999,999,999 to 9,999,999,999,999,999
 * If Saturated, Returns All F in 16 Digits
 * Caution! This function makes string allocated from Heap.
 *
 * Parameters
 * r0: Pointer of String of First Number, needed between 0-9 in all digits
 * r1: Length of String of First Number
 * r2: Pointer of String of Second Number, needed between 0-9 in all digits
 * r3: Length of String of Second Number
 *
 * Return: r0 (Pointer of String of Decimal Number, If Zero Memory Allocation Fails)
 */
.globl bcd32_bsub
bcd32_bsub:
	/* Auto (Local) Variables, but just Aliases */
	string1        .req r0
	length1        .req r1
	string2        .req r2
	length2        .req r3
	deci1_lower    .req r4
	deci1_upper    .req r5
	deci2_lower    .req r6
	deci2_upper    .req r7
	sign1          .req r8
	sign2          .req r9

	push {r4-r9,lr}

	/* Check Existing of minus */

	push {r0-r3}
	mov r2, #0x2D                     @ Ascii Code of Minus
	bl print32_charsearch
	mov sign1, r0
	pop {r0-r3}
	cmp sign1, #-1
	addne string1, string1, sign1
	subne length1, length1, sign1
	movne sign1, #1
	moveq sign1, #0

	push {r0-r3}
	bl deci32_string_to_deci
	mov deci1_lower, r0
	mov deci1_upper, r1
	pop {r0-r3}

	push {r0-r3}
	mov r0, string2
	mov r1, length2
	mov r2, #0x2D                     @ Ascii Code of Minus
	bl print32_charsearch
	mov sign2, r0
	pop {r0-r3}
	cmp sign2, #-1
	addne string2, string2, sign2
	subne length2, length2, sign2
	movne sign2, #1
	moveq sign2, #0

	push {r0-r3}
	mov r0, string2
	mov r1, length2
	bl deci32_string_to_deci
	mov deci2_lower, r0
	mov deci2_upper, r1
	pop {r0-r3}

	/* If Sign of Value is Diffrent from Another */
	cmp sign1, #1
	cmpeq sign2, #1
	beq bcd32_bsub_subtraction
	cmp sign1, #0
	cmpeq sign2, #0
	beq bcd32_bsub_subtraction

	/* Different Signs Mean Addition */
	push {r0-r3}
	mov r0, deci1_lower
	mov r1, deci1_upper
	mov r2, deci2_lower
	mov r3, deci2_upper
	bl bcd32_deci_add64
	mov deci1_lower, r0
	mov deci1_upper, r1
	pop {r0-r3}

	/* If Carry Set, Error Value */
	movcs deci1_lower, #0xFFFFFFFF
	movcs deci1_upper, #0xFFFFFFFF

	b bcd32_bsub_string

	bcd32_bsub_subtraction:
		/* Same Signs Mean Subtraction */

		/* Check Which Is Higher than Another */
		cmp deci1_upper, deci2_upper
		/* First Is Higher on Uppers */
		bhi bcd32_bsub_subtraction_calc
		/* First Is Lower on Uppers */
		blo bcd32_bsub_subtraction_swap
		/* Uppers Are Same Value, So Check Lowers */
		cmpeq deci1_lower, deci2_lower
		/* Uppers Are Same Value, But First is Higher or Same on Lowers */
		bhs bcd32_bsub_subtraction_calc

		bcd32_bsub_subtraction_swap:
			mov string1, deci1_upper
			mov deci1_upper, deci2_upper
			mov deci2_upper, string1
			mov string1, deci1_lower
			mov deci1_lower, deci2_lower
			mov deci2_lower, string1
			/* Sign of Return Value Becomes Inverted Sign of Second Value */
			cmp sign2, #1
			moveq sign1, #0
			movne sign1, #1

		bcd32_bsub_subtraction_calc:
			push {r0-r3}
			mov r0, deci1_lower
			mov r1, deci1_upper
			mov r2, deci2_lower
			mov r3, deci2_upper
			bl bcd32_deci_sub64
			mov deci1_lower, r0
			mov deci1_upper, r1
			pop {r0-r3}

	bcd32_bsub_string:
		push {r0-r3}
		mov r0, deci1_lower
		mov r1, deci1_upper
		mov r2, sign1
		bl bcd32_bcdstring
		mov deci1_upper, r0
		pop {r0-r3}

		cmp deci1_upper, #0
		bne bcd32_bsub_success

	bcd32_bsub_error:
		mov r0, #0
		b bcd32_bsub_common

	bcd32_bsub_success:
		mov r0, deci1_upper

	bcd32_bsub_common:
		pop {r4-r9,pc}

.unreq string1
.unreq length1
.unreq string2
.unreq length2
.unreq deci1_lower
.unreq deci1_upper
.unreq deci2_lower
.unreq deci2_upper
.unreq sign1
.unreq sign2


/**
 * function bcd32_bmul
 * Signed Multiplication with Decimal Bases (0-9), -9,999,999,999,999,999 to 9,999,999,999,999,999
 * If Saturated, Returns All F in 16 Digits
 * Caution! This function makes string allocated from Heap.
 *
 * Parameters
 * r0: Pointer of String of First Number, needed between 0-9 in all digits
 * r1: Length of String of First Number
 * r2: Pointer of String of Second Number, needed between 0-9 in all digits
 * r3: Length of String of Second Number
 *
 * Return: r0 (Pointer of String of Decimal Number, If Zero Memory Allocation Fails)
 */
.globl bcd32_bmul
bcd32_bmul:
	/* Auto (Local) Variables, but just Aliases */
	string1        .req r0
	length1        .req r1
	string2        .req r2
	length2        .req r3
	deci1_lower    .req r4
	deci1_upper    .req r5
	deci2_lower    .req r6
	deci2_upper    .req r7
	sign1          .req r8
	sign2          .req r9

	push {r4-r9,lr}

	/* Check Existing of minus */

	push {r0-r3}
	mov r2, #0x2D                     @ Ascii Code of Minus
	bl print32_charsearch
	mov sign1, r0
	pop {r0-r3}
	cmp sign1, #-1
	addne string1, string1, sign1
	subne length1, length1, sign1
	movne sign1, #1
	moveq sign1, #0

	push {r0-r3}
	bl deci32_string_to_deci
	mov deci1_lower, r0
	mov deci1_upper, r1
	pop {r0-r3}

	push {r0-r3}
	mov r0, string2
	mov r1, length2
	mov r2, #0x2D                     @ Ascii Code of Minus
	bl print32_charsearch
	mov sign2, r0
	pop {r0-r3}
	cmp sign2, #-1
	addne string2, string2, sign2
	subne length2, length2, sign2
	movne sign2, #1
	moveq sign2, #0

	push {r0-r3}
	mov r0, string2
	mov r1, length2
	bl deci32_string_to_deci
	mov deci2_lower, r0
	mov deci2_upper, r1
	pop {r0-r3}

	/* Multiplication with Absolute Values */
	push {r0-r3}
	mov r0, deci1_lower
	mov r1, deci1_upper
	mov r2, deci2_lower
	mov r3, deci2_upper
	bl bcd32_deci_mul64
	mov deci1_lower, r0
	mov deci1_upper, r1
	pop {r0-r3}

	/* If Carry Set, Error Value */
	movcs deci1_lower, #0xFFFFFFFF
	movcs deci1_upper, #0xFFFFFFFF

	/* If Sign of Value is Diffrent from Another */
	cmp sign1, #1
	cmpeq sign2, #0
	beq bcd32_bmul_negative
	cmp sign1, #0
	cmpeq sign2, #1
	beq bcd32_bmul_negative

	mov sign1, #0

	b bcd32_bmul_string

	bcd32_bmul_negative:

		/* Different Signs Mean Signed Minus */
		mov sign1, #1

	bcd32_bmul_string:

		push {r0-r3}
		mov r0, deci1_lower
		mov r1, deci1_upper
		mov r2, sign1
		bl bcd32_bcdstring
		mov deci1_upper, r0
		pop {r0-r3}

		cmp deci1_upper, #0
		bne bcd32_bmul_success

	bcd32_bmul_error:
		mov r0, #0
		b bcd32_bmul_common

	bcd32_bmul_success:
		mov r0, deci1_upper

	bcd32_bmul_common:
		pop {r4-r9,pc}

.unreq string1
.unreq length1
.unreq string2
.unreq length2
.unreq deci1_lower
.unreq deci1_upper
.unreq deci2_lower
.unreq deci2_upper
.unreq sign1
.unreq sign2


/**
 * function bcd32_bdiv
 * Signed Division with Decimal Bases (0-9), -9,999,999,999,999,999 to 9,999,999,999,999,999
 * If Saturated, Returns All F in 16 Digits
 * Caution! This function makes string allocated from Heap.
 *
 * Parameters
 * r0: Pointer of String of First Number, needed between 0-9 in all digits
 * r1: Length of String of First Number
 * r2: Pointer of String of Second Number, needed between 0-9 in all digits
 * r3: Length of String of Second Number
 *
 * Return: r0 (Pointer of String of Decimal Number, If Zero Memory Allocation Fails)
 */
.globl bcd32_bdiv
bcd32_bdiv:
	/* Auto (Local) Variables, but just Aliases */
	string1        .req r0
	length1        .req r1
	string2        .req r2
	length2        .req r3
	deci1_lower    .req r4
	deci1_upper    .req r5
	deci2_lower    .req r6
	deci2_upper    .req r7
	sign1          .req r8
	sign2          .req r9

	push {r4-r9,lr}

	/* Check Existing of minus */

	push {r0-r3}
	mov r2, #0x2D                     @ Ascii Code of Minus
	bl print32_charsearch
	mov sign1, r0
	pop {r0-r3}
	cmp sign1, #-1
	addne string1, string1, sign1
	subne length1, length1, sign1
	movne sign1, #1
	moveq sign1, #0

	push {r0-r3}
	bl deci32_string_to_deci
	mov deci1_lower, r0
	mov deci1_upper, r1
	pop {r0-r3}

	push {r0-r3}
	mov r0, string2
	mov r1, length2
	mov r2, #0x2D                     @ Ascii Code of Minus
	bl print32_charsearch
	mov sign2, r0
	pop {r0-r3}
	cmp sign2, #-1
	addne string2, string2, sign2
	subne length2, length2, sign2
	movne sign2, #1
	moveq sign2, #0

	push {r0-r3}
	mov r0, string2
	mov r1, length2
	bl deci32_string_to_deci
	mov deci2_lower, r0
	mov deci2_upper, r1
	pop {r0-r3}

	/* Division with Absolute Values */
	push {r0-r3}
	mov r0, deci1_lower
	mov r1, deci1_upper
	mov r2, deci2_lower
	mov r3, deci2_upper
	bl bcd32_deci_div64
	mov deci1_lower, r0
	mov deci1_upper, r1
	pop {r0-r3}

	/* If Sign of Value is Diffrent from Another */
	cmp sign1, #1
	cmpeq sign2, #0
	beq bcd32_bdiv_negative
	cmp sign1, #0
	cmpeq sign2, #1
	beq bcd32_bdiv_negative

	mov sign1, #0

	b bcd32_bdiv_string

	bcd32_bdiv_negative:

		/* Different Signs Mean Signed Minus */
		mov sign1, #1

	bcd32_bdiv_string:

		push {r0-r3}
		mov r0, deci1_lower
		mov r1, deci1_upper
		mov r2, sign1
		bl bcd32_bcdstring
		mov deci1_upper, r0
		pop {r0-r3}

		cmp deci1_upper, #0
		bne bcd32_bdiv_success

	bcd32_bdiv_error:
		mov r0, #0
		b bcd32_bdiv_common

	bcd32_bdiv_success:
		mov r0, deci1_upper

	bcd32_bdiv_common:
		pop {r4-r9,pc}

.unreq string1
.unreq length1
.unreq string2
.unreq length2
.unreq deci1_lower
.unreq deci1_upper
.unreq deci2_lower
.unreq deci2_upper
.unreq sign1
.unreq sign2


/**
 * function bcd32_brem
 * Remainder of Signed Division with Decimal Bases (0-9), -9,999,999,999,999,999 to 9,999,999,999,999,999
 * If Saturated, Returns All F in 16 Digits
 * Caution! This function makes string allocated from Heap.
 *
 * Parameters
 * r0: Pointer of String of First Number, needed between 0-9 in all digits
 * r1: Length of String of First Number
 * r2: Pointer of String of Second Number, needed between 0-9 in all digits
 * r3: Length of String of Second Number
 *
 * Return: r0 (Pointer of String of Decimal Number, If Zero Memory Allocation Fails)
 */
.globl bcd32_brem
bcd32_brem:
	/* Auto (Local) Variables, but just Aliases */
	string1        .req r0
	length1        .req r1
	string2        .req r2
	length2        .req r3
	deci1_lower    .req r4
	deci1_upper    .req r5
	deci2_lower    .req r6
	deci2_upper    .req r7
	sign1          .req r8
	sign2          .req r9

	push {r4-r9,lr}

	/* Check Existing of minus */

	push {r0-r3}
	mov r2, #0x2D                     @ Ascii Code of Minus
	bl print32_charsearch
	mov sign1, r0
	pop {r0-r3}
	cmp sign1, #-1
	addne string1, string1, sign1
	subne length1, length1, sign1
	movne sign1, #1
	moveq sign1, #0

	push {r0-r3}
	bl deci32_string_to_deci
	mov deci1_lower, r0
	mov deci1_upper, r1
	pop {r0-r3}

	push {r0-r3}
	mov r0, string2
	mov r1, length2
	mov r2, #0x2D                     @ Ascii Code of Minus
	bl print32_charsearch
	mov sign2, r0
	pop {r0-r3}
	cmp sign2, #-1
	addne string2, string2, sign2
	subne length2, length2, sign2
	movne sign2, #1
	moveq sign2, #0

	push {r0-r3}
	mov r0, string2
	mov r1, length2
	bl deci32_string_to_deci
	mov deci2_lower, r0
	mov deci2_upper, r1
	pop {r0-r3}

	/* Remainder with Absolute Values */
	push {r0-r3}
	mov r0, deci1_lower
	mov r1, deci1_upper
	mov r2, deci2_lower
	mov r3, deci2_upper
	bl bcd32_deci_rem64
	mov deci1_lower, r0
	mov deci1_upper, r1
	pop {r0-r3}

	bcd32_brem_string:

		push {r0-r3}
		mov r0, deci1_lower
		mov r1, deci1_upper
		mov r2, sign1         @ Minus Sign of Dividend Mean Signed Minus
		bl bcd32_bcdstring
		mov deci1_upper, r0
		pop {r0-r3}

		cmp deci1_upper, #0
		bne bcd32_brem_success

	bcd32_brem_error:
		mov r0, #0
		b bcd32_brem_common

	bcd32_brem_success:
		mov r0, deci1_upper

	bcd32_brem_common:
		pop {r4-r9,pc}

.unreq string1
.unreq length1
.unreq string2
.unreq length2
.unreq deci1_lower
.unreq deci1_upper
.unreq deci2_lower
.unreq deci2_upper
.unreq sign1
.unreq sign2


/**
 * function bcd32_bcmp
 * Compare Values with Decimal Bases (0-9), -9,999,999,999,999,999 to 9,999,999,999,999,999
 *
 * Parameters
 * r0: Pointer of String of First Number, needed between 0-9 in all digits
 * r1: Length of String of First Number
 * r2: Pointer of String of Second Number, needed between 0-9 in all digits
 * r3: Length of String of Second Number
 *
 * Return: r0 (NZCV ALU Flags (Bit[31:28]))
 */
.globl bcd32_bcmp
bcd32_bcmp:
	/* Auto (Local) Variables, but just Aliases */
	string1        .req r0
	length1        .req r1
	string2        .req r2
	length2        .req r3
	deci1_lower    .req r4
	deci1_upper    .req r5
	deci2_lower    .req r6
	deci2_upper    .req r7
	sign1          .req r8
	sign2          .req r9

	push {r4-r9,lr}

	/* Check Existing of minus */

	push {r0-r3}
	mov r2, #0x2D                     @ Ascii Code of Minus
	bl print32_charsearch
	mov sign1, r0
	pop {r0-r3}
	cmp sign1, #-1
	addne string1, string1, sign1
	subne length1, length1, sign1
	movne sign1, #1
	moveq sign1, #0

	push {r0-r3}
	bl deci32_string_to_deci
	mov deci1_lower, r0
	mov deci1_upper, r1
	pop {r0-r3}

	push {r0-r3}
	mov r0, string2
	mov r1, length2
	mov r2, #0x2D                     @ Ascii Code of Minus
	bl print32_charsearch
	mov sign2, r0
	pop {r0-r3}
	cmp sign2, #-1
	addne string2, string2, sign2
	subne length2, length2, sign2
	movne sign2, #1
	moveq sign2, #0

	push {r0-r3}
	mov r0, string2
	mov r1, length2
	bl deci32_string_to_deci
	mov deci2_lower, r0
	mov deci2_upper, r1
	pop {r0-r3}

	.unreq string1
	flag_nzcv .req r0
	mov flag_nzcv, #0

	/* If Sign of Value is Diffrent from Another */
	cmp sign1, #1
	cmpeq sign2, #1
	beq bcd32_bcmp_subtraction
	cmp sign1, #0
	cmpeq sign2, #0
	beq bcd32_bcmp_subtraction

	/* Different Signs Mean Addition */
	push {r0-r3}
	mov r0, deci1_lower
	mov r1, deci1_upper
	mov r2, deci2_lower
	mov r3, deci2_upper
	bl bcd32_deci_add64
	mov deci1_lower, r0
	mov deci1_upper, r1
	pop {r0-r3}

	/* If Carry Set, Error Value */
	movcs deci1_lower, #0xFFFFFFFF
	movcs deci1_upper, #0xFFFFFFFF

	b bcd32_bcmp_nz

	bcd32_bcmp_subtraction:
		/* Same Signs Mean Subtraction */

		/* Check Which Is Higher than Another */
		cmp deci1_upper, deci2_upper
		/* First Is Higher on Uppers */
		bhi bcd32_bcmp_subtraction_calc
		/* First Is Lower on Uppers */
		blo bcd32_bcmp_subtraction_swap
		/* Uppers Are Same Value, So Check Lowers */
		cmpeq deci1_lower, deci2_lower
		/* Uppers Are Same Value, But First is Higher or Same on Lowers */
		bhs bcd32_bcmp_subtraction_calc

		bcd32_bcmp_subtraction_swap:
			mov string2, deci1_upper
			mov deci1_upper, deci2_upper
			mov deci2_upper, string2
			mov string2, deci1_lower
			mov deci1_lower, deci2_lower
			mov deci2_lower, string2
			/* Sign of Return Value Becomes Inverted Sign of Second Value */
			cmp sign2, #1
			moveq sign1, #0
			movne sign1, #1

		bcd32_bcmp_subtraction_calc:
			push {r0-r3}
			mov r0, deci1_lower
			mov r1, deci1_upper
			mov r2, deci2_lower
			mov r3, deci2_upper
			bl bcd32_deci_sub64
			mov deci1_lower, r0
			mov deci1_upper, r1
			pop {r0-r3}

	bcd32_bcmp_nz:
		/* If Minus Signed (Negative), N Bit[31] */
		cmp sign1, #1
		orreq flag_nzcv, flag_nzcv, #0x80000000

		/* If Zero, Z Bit[30] */
		cmp deci1_upper, #0
		cmpeq deci1_lower, #0
		orreq flag_nzcv, flag_nzcv, #0x40000000

		/* Two's Complement Overflow (V Bit[28]) Never Occurs Because It's Not a True Binary Arithmetic */
		/* Carry (C Bit[29]) Never Occurs Because It's Not a True Binary Arithmetic */

	bcd32_bcmp_common:
		pop {r4-r9,pc}

.unreq flag_nzcv
.unreq length1
.unreq string2
.unreq length2
.unreq deci1_lower
.unreq deci1_upper
.unreq deci2_lower
.unreq deci2_upper
.unreq sign1
.unreq sign2


/**
 * function bcd32_deci_add64
 * Unsigned Addition with Decimal Bases (0-9)
 *
 * Parameters
 * r0: Lower Bits of First Number, needed between 0-9 in all digits
 * r1: Upper Bits of First Number, needed between 0-9 in all digits
 * r2: Lower Bits of Second Number, needed between 0-9 in all digits
 * r3: Upper Bits of Second Number, needed between 0-9 in all digits
 *
 * Return: r0 (Lower Bits of Decimal Number), r1 (Upper Bits of Decimal Number), error if carry bit is set
 * Error: This function could not calculate because of digit-overflow.
 */
.globl bcd32_deci_add64
bcd32_deci_add64:
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

	bcd32_deci_add64_loop:
		mov bitmask_1, #0xF                            @ 0b1111
		mov bitmask_2, #0xF

		lsl shift, i, #2                               @ Substitute of Multiplication by 4

		cmp i, #8
		bhs bcd32_deci_add64_loop_uppernumber

		/* Lower Number */
		lsl bitmask_1, bitmask_1, shift
		lsl bitmask_2, bitmask_2, shift

		and bitmask_1, dup_lower_1, bitmask_1
		and bitmask_2, lower_2, bitmask_2

		b bcd32_deci_add64_loop_cal

		/* Upper Number */
		bcd32_deci_add64_loop_uppernumber:

			sub shift, shift, #32

			lsl bitmask_1, bitmask_1, shift
			lsl bitmask_2, bitmask_2, shift

			and bitmask_1, dup_upper_1, bitmask_1
			and bitmask_2, upper_2, bitmask_2

		bcd32_deci_add64_loop_cal:
		
			lsr bitmask_1, bitmask_1, shift
			lsr bitmask_2, bitmask_2, shift

			add bitmask_1, bitmask_1, bitmask_2
			add bitmask_1, bitmask_1, carry_flag

			cmp bitmask_1, #0x10
			bhs bcd32_deci_add64_loop_cal_hexacarry

			cmp bitmask_1, #0x0A
			bhs bcd32_deci_add64_loop_cal_decicarry

			mov carry_flag, #0                      @ Clear Carry

			b bcd32_deci_add64_loop_common	

			bcd32_deci_add64_loop_cal_hexacarry:

				sub bitmask_1, #0x10
				add bitmask_1, #0x06 
				mov carry_flag, #1              @ Set Carry

				b bcd32_deci_add64_loop_common

			bcd32_deci_add64_loop_cal_decicarry:

				sub bitmask_1, #0x0A
				mov carry_flag, #1              @ Set Carry

		bcd32_deci_add64_loop_common:
			lsl bitmask_1, bitmask_1, shift

			cmp i, #8
			bhs bcd32_deci_add64_loop_common_uppernumber

			/* Lower Number */
			add lower_1, lower_1, bitmask_1

			b bcd32_deci_add64_loop_common_common

			/* Upper Number */
			bcd32_deci_add64_loop_common_uppernumber:

				add upper_1, upper_1, bitmask_1

			bcd32_deci_add64_loop_common_common:

				add i, i, #1
				cmp i, #16
				blo bcd32_deci_add64_loop

				cmp carry_flag, #1
				beq bcd32_deci_add64_error

	bcd32_deci_add64_success:            
		b bcd32_deci_add64_common

	bcd32_deci_add64_error:
		/**
		 * Load Only Status Flags From CPSR
		 * NZCVQ (Negative; Zero; Unsigned Carry; Overflow = Signed Carry; Saturation = Stickey Overflow on QADD, etc.)
		 * But codes below is not valid in User mode because writing to cpsr is not valid in User mode
		 */
		/*
		mrs carry_flag, apsr                    @ NZCVQ Bit[31:27]
		bic carry_flag, carry_flag, #0xF8000000 @ Clear NZCVQ
		orr carry_flag, carry_flag, #0x20000000 @ Only Set Carry Bit[29], Check by Conditional cs/hs and cc/lo
		msr apsr_nzcvq, carry_flag
		*/

	bcd32_deci_add64_common:
		cmp carry_flag, #1
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
 * function bcd32_deci_sub64
 * Unsigned Subtraction with Decimal Bases (0-9)
 *
 * Parameters
 * r0: Lower Bits of First Number, needed between 0-9 in all digits
 * r1: Upper Bits of First Number, needed between 0-9 in all digits
 * r2: Lower Bits of Second Number, needed between 0-9 in all digits
 * r3: Upper Bits of Second Number, needed between 0-9 in all digits
 *
 * Return: r0 (Lower Bits of Decimal Number), r1 (Upper Bits of Decimal Number), error if carry bit is set
 * Error: This function could not calculate because the result is reached minus.
 */
.globl bcd32_deci_sub64
bcd32_deci_sub64:
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

	bcd32_deci_sub64_loop:
		mov bitmask_1, #0xF                            @ 0b1111
		mov bitmask_2, #0xF

		lsl shift, i, #2                               @ Substitute of Multiplication by 4

		cmp i, #8
		bhs bcd32_deci_sub64_loop_uppernumber

		/* Lower Number */
		lsl bitmask_1, bitmask_1, shift
		lsl bitmask_2, bitmask_2, shift

		and bitmask_1, dup_lower_1, bitmask_1
		and bitmask_2, lower_2, bitmask_2

		b bcd32_deci_sub64_loop_cal

		/* Upper Number */
		bcd32_deci_sub64_loop_uppernumber:

			sub shift, shift, #32

			lsl bitmask_1, bitmask_1, shift
			lsl bitmask_2, bitmask_2, shift

			and bitmask_1, dup_upper_1, bitmask_1
			and bitmask_2, upper_2, bitmask_2

		bcd32_deci_sub64_loop_cal:
	
			lsr bitmask_1, bitmask_1, shift
			lsr bitmask_2, bitmask_2, shift

			sub bitmask_1, bitmask_1, bitmask_2
			sub bitmask_1, bitmask_1, carry_flag

			cmp bitmask_1, #0x0
			blt bcd32_deci_sub64_loop_cal_carry

			mov carry_flag, #0                      @ Clear Carry

			b bcd32_deci_sub64_loop_common	

			bcd32_deci_sub64_loop_cal_carry:

				add bitmask_1, bitmask_1, #10        @ Value of bitmask_1 is minus
				mov carry_flag, #1                   @ Set Carry

		bcd32_deci_sub64_loop_common:
			lsl bitmask_1, bitmask_1, shift

			cmp i, #8
			bhs bcd32_deci_sub64_loop_common_uppernumber

			/* Lower Number */
			add lower_1, lower_1, bitmask_1

			b bcd32_deci_sub64_loop_common_common

			/* Upper Number */
			bcd32_deci_sub64_loop_common_uppernumber:

				add upper_1, upper_1, bitmask_1

			bcd32_deci_sub64_loop_common_common:

				add i, i, #1
				cmp i, #16
				blo bcd32_deci_sub64_loop

				cmp carry_flag, #1
				beq bcd32_deci_sub64_error

	bcd32_deci_sub64_success:
		b bcd32_deci_sub64_common

	bcd32_deci_sub64_error:
		/**
		 * Load Only Status Flags From CPSR
		 * NZCVQ (Negative; Zero; Unsigned Carry; Overflow = Signed Carry; Saturation = Stickey Overflow on QADD, etc.)
		 * But codes below is not valid in User mode because writing to cpsr is not valid in User mode
		 */
		/*
		mrs carry_flag, apsr                    @ NZCVQ Bit[31:27]
		bic carry_flag, carry_flag, #0xF8000000 @ Clear NZCVQ
		orr carry_flag, carry_flag, #0x20000000 @ Only Set Carry Bit[29], Check by Conditional cs/hs and cc/lo
		msr apsr_nzcvq, carry_flag
		*/

	bcd32_deci_sub64_common:
		cmp carry_flag, #1
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
 * function bcd32_deci_shift64
 * Shift Place with Decimal Bases (0-9)
 *
 * Parameters
 * r0: Lower Bits of Number, needed between 0-9 in all digits
 * r1: Upper Bits of Number, needed between 0-9 in all digits
 * r2: Number of Place to Shift, Plus Signed Means Shift Left, Minus Singed Means Shift Right
 *
 * Return: r0 (Lower Bits of Decimal Number), r1 (Upper Bits of Decimal Number), error if carry bit is set
 */
.globl bcd32_deci_shift64
bcd32_deci_shift64:
	/* Auto (Local) Variables, but just Aliases */
	lower_1        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	upper_1        .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	shift          .req r2 @ Parameter, Register for Argument, Scratch Register
	minus          .req r3 @ Scratch Register
	carry_flag     .req r4

	push {r4,lr}

	cmp shift, #0
	movlt minus, #1
	mvnlt shift, shift
	addlt shift, shift, #1
	movge minus, #0

	lsl shift, shift, #2                   @ Substitute of Multiplication by 4
	mov carry_flag, #0

	bcd32_deci_shift64_loop:

		cmp shift, #0
		ble bcd32_deci_shift64_common

		cmp minus, #1
		beq bcd32_deci_shift64_loop_minus

		lsls upper_1, upper_1, #1
		orrcs carry_flag, carry_flag, #1
		lsls lower_1, lower_1, #1
		addcs upper_1, upper_1, #1

		sub shift, shift, #1
		b bcd32_deci_shift64_loop

		bcd32_deci_shift64_loop_minus:

			lsrs upper_1, upper_1, #1
			lsr lower_1, lower_1, #1
			addcs lower_1, lower_1, #0x80000000

			sub shift, shift, #1
			b bcd32_deci_shift64_loop

	bcd32_deci_shift64_common:
		cmp carry_flag, #1
		pop {r4,pc}

.unreq lower_1
.unreq upper_1
.unreq shift
.unreq minus
.unreq carry_flag


/**
 * function bcd32_deci_mul64_pre
 * Unsigned Multiplication with Decimal Bases (0-9)
 * Caution! This Function is a Module for Other Functions.
 *
 * Parameters
 * r0: Lower Bits of First Number, needed between 0-9 in all digits
 * r1: Upper Bits of First Number, needed between 0-9 in all digits
 * r2: Lower Bits of Second Number, needed between 0-9 in all digits
 * r3: Upper Bits of Second Number, needed between 0-9 in all digits
 *
 * Return: r0 (Lower Bits of Decimal Number), r1 (Upper Bits of Decimal Number), error if carry bit is set
 * Error: This function could not calculate because of digit-overflow.
 */
.globl bcd32_deci_mul64_pre
bcd32_deci_mul64_pre:
	/* Auto (Local) Variables, but just Aliases */
	lower_1        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	upper_1        .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	lower_2        .req r2 @ Parameter, Register for Argument, Scratch Register
	upper_2        .req r3 @ Parameter, Register for Argument, Scratch Register
	dup_lower_2    .req r4 @ Duplication of lower_2
	dup_upper_2    .req r5 @ Duplication of upper_2
	carry_flag     .req r6

	push {r4-r6,lr}

	mov dup_lower_2, lower_2
	mov dup_upper_2, upper_2
	mov lower_2, lower_1
	mov upper_2, upper_1
	mov lower_1, #0
	mov upper_1, #0
	mov carry_flag, #0

	bcd32_deci_mul64_pre_loop:

		push {r0-r3}
		mov r0, dup_lower_2
		mov r1, dup_upper_2
		mov r2, #1
		mov r3, #0
		bl bcd32_deci_sub64
		mov dup_lower_2, r0
		mov dup_upper_2, r1
		pop {r0-r3}
		bcs bcd32_deci_mul64_pre_common @ If Carry Set/ Unsigned Higher or Same (hs)

		push {r2-r3}
		bl bcd32_deci_add64
		pop {r2-r3}
		movcs carry_flag, #1
		bcs bcd32_deci_mul64_pre_common @ If Carry Set/ Unsigned Higher or Same (hs)

		b bcd32_deci_mul64_pre_loop

	bcd32_deci_mul64_pre_common:
		cmp carry_flag, #1
		pop {r4-r6,pc}

.unreq lower_1
.unreq upper_1
.unreq lower_2
.unreq upper_2
.unreq dup_lower_2
.unreq dup_upper_2
.unreq carry_flag


/**
 * function bcd32_deci_mul64
 * Unsigned Multiplication with Decimal Bases (0-9)
 *
 * Parameters
 * r0: Lower Bits of First Number, needed between 0-9 in all digits
 * r1: Upper Bits of First Number, needed between 0-9 in all digits
 * r2: Lower Bits of Second Number, needed between 0-9 in all digits
 * r3: Upper Bits of Second Number, needed between 0-9 in all digits
 *
 * Return: r0 (Lower Bits of Decimal Number), r1 (Upper Bits of Decimal Number), error if carry bit is set
 * Error: This function could not calculate because of digit-overflow.
 */
.globl bcd32_deci_mul64
bcd32_deci_mul64:
	/* Auto (Local) Variables, but just Aliases */
	lower_1        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	upper_1        .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	lower_2        .req r2 @ Parameter, Register for Argument, Scratch Register
	upper_2        .req r3 @ Parameter, Register for Argument, Scratch Register
	dup_lower_2    .req r4 @ Duplication of lower_2
	dup_upper_2    .req r5 @ Duplication of upper_2
	cal_lower      .req r6
	cal_upper      .req r7
	shift          .req r8
	temp_lower     .req r9
	temp_upper     .req r10
	carry_flag     .req r11

	/**
	 * To speed up, this function refers handwrinting method to calculate multiplication,
	 * i.e., two-dimensional method that is using exponent in base 10.
	 */

	push {r4-r11,lr}

	mov dup_lower_2, lower_2
	mov dup_upper_2, upper_2
	mov upper_2, #0
	mov cal_lower, #0
	mov cal_upper, #0
	mov shift, #15
	mov carry_flag, #0

	bcd32_deci_mul64_loop:

		cmp shift, #0
		blt bcd32_deci_mul64_common

		mov lower_2, #0xF
		lsl temp_lower, shift, #2                   @ Substitute of Multiplication by 4
		cmp shift, #8
		bge bcd32_deci_mul64_loop_upper

		lsl lower_2, lower_2, temp_lower
		and lower_2, lower_2, dup_lower_2
		lsr lower_2, lower_2, temp_lower

		b bcd32_deci_mul64_loop_common

		bcd32_deci_mul64_loop_upper:

			sub temp_lower, temp_lower, #32
			lsl lower_2, lower_2, temp_lower
			and lower_2, lower_2, dup_upper_2
			lsr lower_2, lower_2, temp_lower
	
		bcd32_deci_mul64_loop_common:

			push {r0-r3}
			bl bcd32_deci_mul64_pre
			mov temp_lower, r0
			mov temp_upper, r1
			pop {r0-r3}

			push {r0-r3}
			mov r0, temp_lower
			mov r1, temp_upper
			mov r2, shift
			bl bcd32_deci_shift64
			mov temp_lower, r0
			mov temp_upper, r1
			pop {r0-r3}
			movcs carry_flag, #1
			bcs bcd32_deci_mul64_common

			push {r0-r3}
			mov r0, cal_lower
			mov r1, cal_upper
			mov r2, temp_lower
			mov r3, temp_upper
			bl bcd32_deci_add64
			mov cal_lower, r0
			mov cal_upper, r1
			pop {r0-r3}
			movcs carry_flag, #1
			bcs bcd32_deci_mul64_common

			sub shift, shift, #1
			b bcd32_deci_mul64_loop

	bcd32_deci_mul64_common:
		cmp carry_flag, #1
		mov r0, cal_lower
		mov r1, cal_upper
		pop {r4-r11,pc}

.unreq lower_1
.unreq upper_1
.unreq lower_2
.unreq upper_2
.unreq dup_lower_2
.unreq dup_upper_2
.unreq cal_lower
.unreq cal_upper
.unreq shift
.unreq temp_lower
.unreq temp_upper
.unreq carry_flag


/**
 * function bcd32_deci_div64_pre
 * Unsigned Division with Decimal Bases (0-9)
 * Caution! This Function is a Module for Other Functions.
 *
 * Parameters
 * r0: Lower Bits of First Number, needed between 0-9 in all digits
 * r1: Upper Bits of First Number, needed between 0-9 in all digits
 * r2: Lower Bits of Second Number, needed between 0-9 in all digits
 * r3: Upper Bits of Second Number, needed between 0-9 in all digits
 *
 * Return: r0 (Lower Bits of Decimal Number), r1 (Upper Bits of Decimal Number), Remainder Exists If Carry Bit Is Set
 * Error: This function could not calculate because of digit-overflow.
 */
.globl bcd32_deci_div64_pre
bcd32_deci_div64_pre:
	/* Auto (Local) Variables, but just Aliases */
	lower_1        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	upper_1        .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	lower_2        .req r2 @ Parameter, Register for Argument, Scratch Register
	upper_2        .req r3 @ Parameter, Register for Argument, Scratch Register
	cal_lower      .req r4
	cal_upper      .req r5
	carry_flag     .req r6

	push {r4-r6,lr}

	mov cal_lower, #0
	mov cal_upper, #0
	mov carry_flag, #0

	bcd32_deci_div64_pre_loop:

		push {r2-r3}
		bl bcd32_deci_sub64
		pop {r2-r3}
		bcs bcd32_deci_div64_pre_common @ If Carry Set/ Unsigned Higher or Same (hs)

		push {r0-r3}
		mov r0, cal_lower
		mov r1, cal_upper
		mov r2, #1
		mov r3, #0
		bl bcd32_deci_add64
		mov cal_lower, r0
		mov cal_upper, r1
		pop {r0-r3}
		movcs carry_flag, #1
		bcs bcd32_deci_div64_pre_common @ If Carry Set/ Unsigned Higher or Same (hs)

		cmp lower_1, #0
		cmpeq upper_1, #0
		beq bcd32_deci_div64_pre_common @ If Divisible

		b bcd32_deci_div64_pre_loop

	bcd32_deci_div64_pre_common:
		cmp carry_flag, #1
		mov r0, cal_lower
		mov r1, cal_upper
		pop {r4-r6,pc}

.unreq lower_1
.unreq upper_1
.unreq lower_2
.unreq upper_2
.unreq cal_lower
.unreq cal_upper
.unreq carry_flag


/**
 * function bcd32_deci_div64
 * Unsigned Division with Decimal Bases (0-9)
 *
 * Parameters
 * r0: Lower Bits of First Number, needed between 0-9 in all digits
 * r1: Upper Bits of First Number, needed between 0-9 in all digits
 * r2: Lower Bits of Second Number, needed between 0-9 in all digits
 * r3: Upper Bits of Second Number, needed between 0-9 in all digits
 *
 * Return: r0 (Lower Bits of Decimal Number), r1 (Upper Bits of Decimal Number), Remainder Exists If Carry Bit Is Set
 * Error: This function could not calculate because of digit-overflow.
 */
.globl bcd32_deci_div64
bcd32_deci_div64:
	/* Auto (Local) Variables, but just Aliases */
	lower_1        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	upper_1        .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	lower_2        .req r2 @ Parameter, Register for Argument, Scratch Register
	upper_2        .req r3 @ Parameter, Register for Argument, Scratch Register
	cal_lower      .req r4
	cal_upper      .req r5
	shift          .req r6
	temp1_lower    .req r7
	temp1_upper    .req r8
	temp2_lower    .req r9
	temp2_upper    .req r10
	carry_flag     .req r11

	/**
	 * To speed up, this function refers handwrinting method to calculate division,
	 * i.e., two-dimensional method that is using exponent in base 10.
	 */

	push {r4-r11,lr}

	mov cal_lower, #0
	mov cal_upper, #0

	clz temp1_lower, upper_2
	cmp temp1_lower, #32
	clzge temp1_lower, lower_2
	addge temp1_lower, temp1_lower, #32

	mov shift, #0

	bcd32_deci_div64_count:
		subs temp1_lower, temp1_lower, #4
		addge shift, #1
		bge bcd32_deci_div64_count

	bcd32_deci_div64_loop:

		mov carry_flag, #1

		cmp shift, #0
		blt bcd32_deci_div64_common

		push {r0-r3}
		mov r0, lower_2
		mov r1, upper_2
		mov r2, shift
		bl bcd32_deci_shift64
		mov temp1_lower, r0
		mov temp1_upper, r1
		pop {r0-r3}

		push {r0-r3}
		mov r2, temp1_lower
		mov r3, temp1_upper
		bl bcd32_deci_div64_pre
		mov temp2_lower, r0
		mov temp2_upper, r1
		pop {r0-r3}

		push {r0-r3}
		mov r0, temp2_lower
		mov r1, temp2_upper
		mov r2, shift
		bl bcd32_deci_shift64
		mov temp2_lower, r0
		mov temp2_upper, r1
		pop {r0-r3}

		push {r0-r3}
		mov r0, cal_lower
		mov r1, cal_upper
		mov r2, temp2_lower
		mov r3, temp2_upper
		bl bcd32_deci_add64
		mov cal_lower, r0
		mov cal_upper, r1
		pop {r0-r3}

		push {r2-r3}
		mov r2, temp1_lower
		mov r3, temp1_upper
		bl bcd32_deci_rem64_pre
		pop {r2-r3}

		cmp lower_1, #0
		cmpeq upper_1, #0
		moveq carry_flag, #0
		beq bcd32_deci_div64_common

		sub shift, shift, #1

		b bcd32_deci_div64_loop

	bcd32_deci_div64_common:
		cmp carry_flag, #1
		mov r0, cal_lower
		mov r1, cal_upper
		pop {r4-r11,pc}

.unreq lower_1
.unreq upper_1
.unreq lower_2
.unreq upper_2
.unreq cal_lower
.unreq cal_upper
.unreq shift
.unreq temp1_lower
.unreq temp1_upper
.unreq temp2_lower
.unreq temp2_upper
.unreq carry_flag


/**
 * function bcd32_deci_rem64_pre
 * Remainder of Unsigned Division with Decimal Bases (0-9)
 * Caution! This Function is a Module for Other Functions.
 *
 * Parameters
 * r0: Lower Bits of First Number, needed between 0-9 in all digits
 * r1: Upper Bits of First Number, needed between 0-9 in all digits
 * r2: Lower Bits of Second Number, needed between 0-9 in all digits
 * r3: Upper Bits of Second Number, needed between 0-9 in all digits
 *
 * Return: r0 (Lower Bits of Decimal Number), r1 (Upper Bits of Decimal Number)
 * Error: This function could not calculate because of digit-overflow.
 */
.globl bcd32_deci_rem64_pre
bcd32_deci_rem64_pre:
	/* Auto (Local) Variables, but just Aliases */
	lower_1        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	upper_1        .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	lower_2        .req r2 @ Parameter, Register for Argument, Scratch Register
	upper_2        .req r3 @ Parameter, Register for Argument, Scratch Register
	dup_lower_1    .req r4
	dup_upper_1    .req r5

	push {r4-r5,lr}

	bcd32_deci_rem64_pre_loop:

		mov dup_lower_1, lower_1
		mov dup_upper_1, upper_1

		push {r2-r3}
		bl bcd32_deci_sub64
		pop {r2-r3}
		bcs bcd32_deci_rem64_pre_common @ If Carry Set/ Unsigned Higher or Same (hs)

		b bcd32_deci_rem64_pre_loop

	bcd32_deci_rem64_pre_common:
		mov r0, dup_lower_1
		mov r1, dup_upper_1
		pop {r4-r5,pc}

.unreq lower_1
.unreq upper_1
.unreq lower_2
.unreq upper_2
.unreq dup_lower_1
.unreq dup_upper_1


/**
 * function bcd32_deci_rem64
 * Remainder of Unsigned Division with Decimal Bases (0-9)
 *
 * Parameters
 * r0: Lower Bits of First Number, needed between 0-9 in all digits
 * r1: Upper Bits of First Number, needed between 0-9 in all digits
 * r2: Lower Bits of Second Number, needed between 0-9 in all digits
 * r3: Upper Bits of Second Number, needed between 0-9 in all digits
 *
 * Return: r0 (Lower Bits of Decimal Number), r1 (Upper Bits of Decimal Number)
 * Error: This function could not calculate because of digit-overflow.
 */
.globl bcd32_deci_rem64
bcd32_deci_rem64:
	/* Auto (Local) Variables, but just Aliases */
	lower_1        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	upper_1        .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	lower_2        .req r2 @ Parameter, Register for Argument, Scratch Register
	upper_2        .req r3 @ Parameter, Register for Argument, Scratch Register
	cal_lower      .req r4
	cal_upper      .req r5
	shift          .req r6
	temp1_lower    .req r7
	temp1_upper    .req r8
	temp2_lower    .req r9
	temp2_upper    .req r10

	/**
	 * To speed up, this function refers handwrinting method to calculate division,
	 * i.e., two-dimensional method that is using exponent in base 10.
	 */

	push {r4-r10,lr}

	mov cal_lower, #0
	mov cal_upper, #0

	clz temp1_lower, upper_2
	cmp temp1_lower, #32
	clzge temp1_lower, lower_2
	addge temp1_lower, temp1_lower, #32

	mov shift, #0

	bcd32_deci_rem64_count:
		subs temp1_lower, temp1_lower, #4
		addge shift, #1
		bge bcd32_deci_rem64_count

	bcd32_deci_rem64_loop:
		cmp shift, #0
		blt bcd32_deci_rem64_common

		push {r0-r3}
		mov r0, lower_2
		mov r1, upper_2
		mov r2, shift
		bl bcd32_deci_shift64
		mov temp1_lower, r0
		mov temp1_upper, r1
		pop {r0-r3}

		push {r0-r3}
		mov r2, temp1_lower
		mov r3, temp1_upper
		bl bcd32_deci_rem64_pre
		mov temp2_lower, r0
		mov temp2_upper, r1
		pop {r0-r3}

		push {r0-r3}
		mov r0, temp2_lower
		mov r1, temp2_upper
		mov r2, shift
		bl bcd32_deci_shift64
		mov temp2_lower, r0
		mov temp2_upper, r1
		pop {r0-r3}

		push {r0-r3}
		mov r0, cal_lower
		mov r1, cal_upper
		mov r2, temp2_lower
		mov r3, temp2_upper
		bl bcd32_deci_add64
		mov cal_lower, r0
		mov cal_upper, r1
		pop {r0-r3}

		push {r2-r3}
		mov r2, temp1_lower
		mov r3, temp1_upper
		bl bcd32_deci_rem64_pre
		pop {r2-r3}

		cmp lower_1, #0
		cmpeq upper_1, #0
		beq bcd32_deci_rem64_common

		sub shift, shift, #1

		b bcd32_deci_rem64_loop

	bcd32_deci_rem64_common:
		pop {r4-r10,pc}

.unreq lower_1
.unreq upper_1
.unreq lower_2
.unreq upper_2
.unreq cal_lower
.unreq cal_upper
.unreq shift
.unreq temp1_lower
.unreq temp1_upper
.unreq temp2_lower
.unreq temp2_upper

