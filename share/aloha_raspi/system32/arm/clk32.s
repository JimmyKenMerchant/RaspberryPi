/**
 * clk32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * On this system, the reference time of the calender and the clock will not be changed as long as you re-initialize the calender and the clock.
 * This function gradually lengthen execution time because of the distance between the reference time and the actual time.
 */

.globl CLK32_YEAR
.globl CLK32_YEARDAY
.globl CLK32_YEAR_INIT
.globl CLK32_YEARDAY_INIT
.globl CLK32_UTC
.globl CLK32_MONTH
.globl CLK32_WEEK
.globl CLK32_MONTHDAY
.globl CLK32_HOUR
.globl CLK32_MINUTE
.globl CLK32_SECOND
.globl CLK32_HOUR_INIT
.globl CLK32_MINUTE_INIT
.globl CLK32_SECOND_INIT
.globl CLK32_USECOND
.globl CLK32_USECOND_INIT
CLK32_YEAR:         .word 0x00
CLK32_YEARDAY:      .word 0x00 @ The day of the year
CLK32_YEAR_INIT:    .word 0x00
CLK32_YEARDAY_INIT: .word 0x00 @ The day of the year
CLK32_UTC:          .byte 0x00 @ Coordinated Universal Time
CLK32_MONTH:        .byte 0x00
CLK32_WEEK:         .byte 0x00 @ 0-6, Saturday to Friday
CLK32_MONTHDAY:     .byte 0x00 @ The day of the month
CLK32_HOUR:         .byte 0x00
CLK32_MINUTE:       .byte 0x00
CLK32_SECOND:       .byte 0x00
CLK32_HOUR_INIT:    .byte 0x00
CLK32_MINUTE_INIT:  .byte 0x00
CLK32_SECOND_INIT:  .byte 0x00
.balign 4
CLK32_USECOND:      .word 0x00 @ Microseconds Under Seconds
CLK32_USECOND_INIT: .word 0x00
.balign 4

CLK32_SYSTEM_UPPER: .word 0x00
CLK32_SYSTEM_LOWER: .word 0x00

CLK32_MONTHS:  .word _CLK32_MOHTHS
_CLK32_MOHTHS: .byte 0
CLK32_JAN:     .byte 31
CLK32_FEB:     .byte 28
CLK32_MAR:     .byte 31
CLK32_APR:     .byte 30
CLK32_MAY:     .byte 31
CLK32_JUN:     .byte 30
CLK32_JUL:     .byte 31
CLK32_AUG:     .byte 31
CLK32_SEP:     .byte 30
CLK32_OCT:     .byte 31
CLK32_NOV:     .byte 30
CLK32_DEC:     .byte 31
.balign 4


/**
 * function clk32_calender_init
 * Initialize Calender
 *
 * Parameters
 * r0: Year
 * r1: Month
 * r2: Day of Month
 *
 * Return: r0 (0 as Success)
 */
.globl clk32_calender_init
clk32_calender_init:
	/* Auto (Local) Variables, but just Aliases */
	year           .req r0
	month          .req r1
	monthday       .req r2
	yearday        .req r3
	memorymap_base .req r4
	temp           .req r5
	leap_year      .req r6

	push {r4-r6,lr}

	/* Limiter of Month */
	cmp month, #12
	movgt month, #12
	cmp month, #0
	movle month, #1

	/* Limiter of Day of Month */
	cmp monthday, #31
	movgt monthday, #31
	cmp monthday, #0
	movle monthday, #1

	str year, CLK32_YEAR_INIT

	push {r0-r3}
	bl clk32_check_leapyear
	mov leap_year, r0
	pop {r0-r3}

	ldr memorymap_base, CLK32_MONTHS
	mov yearday, #0
	sub month, month, #1

	clk32_calender_init_yearday:
		ldrb temp, [memorymap_base, month]
		cmp month, #2
		cmpeq leap_year, #1
		addeq temp, temp, #1
		add yearday, yearday, temp
		subs month, month, #1
		bgt clk32_calender_init_yearday
	
	add yearday, yearday, monthday
	str yearday, CLK32_YEARDAY_INIT

	macro32_dsb ip

	clk32_calender_init_common:
		mov r0, #0
		pop {r4-r6,pc}

.unreq year
.unreq month
.unreq monthday
.unreq yearday
.unreq memorymap_base
.unreq temp
.unreq leap_year


/**
 * function clk32_clock_init
 * Set Current Time
 *
 * Parameters
 * r0: Hour
 * r1: Minute
 * r2: Second
 * r3: Micro Second
 *
 * Return: r0 (0 as Success)
 */
.globl clk32_clock_init
clk32_clock_init:
	/* Auto (Local) Variables, but just Aliases */
	hour           .req r0
	minute         .req r1
	second         .req r2
	usecond        .req r3
	memorymap_base .req r4
	count_low      .req r5
	count_high     .req r6

	push {r4-r6,lr}

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_systemtimer_base
	ldr count_low, [memorymap_base, #equ32_systemtimer_counter_lower]   @ Get Lower 32 Bits
	ldr count_high, [memorymap_base, #equ32_systemtimer_counter_higher] @ Get Higher 32 Bits

	macro32_dsb ip

	str count_low, CLK32_SYSTEM_LOWER
	str count_high, CLK32_SYSTEM_UPPER

	strb hour, CLK32_HOUR_INIT
	strb minute, CLK32_MINUTE_INIT
	strb second, CLK32_SECOND_INIT
	str usecond, CLK32_USECOND_INIT

	macro32_dsb ip

	clk32_clock_init_common:
		mov r0, #0
		pop {r4-r6,pc}

.unreq hour
.unreq minute
.unreq second
.unreq usecond
.unreq memorymap_base
.unreq count_low
.unreq count_high


/**
 * function clk32_get_time
 * Get Current Time From Clock
 *
 * Return: r0 (0 as Success)
 */
.globl clk32_get_time
clk32_get_time:
	/* Auto (Local) Variables, but just Aliases */
	year            .req r0
	month           .req r1
	yearday         .req r2
	hour            .req r3
	minute          .req r4
	second          .req r5
	usecond         .req r6
	memorymap_base  .req r7
	count_low_past  .req r8
	count_high_past .req r9
	count_low_now   .req r10
	count_high_now  .req r11

	push {r4-r11,lr}

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_systemtimer_base
	ldr count_low_now, [memorymap_base, #equ32_systemtimer_counter_lower]   @ Get Lower 32 Bits
	ldr count_high_now, [memorymap_base, #equ32_systemtimer_counter_higher] @ Get Higher 32 Bits

	ldr count_low_past, CLK32_SYSTEM_LOWER
	ldr count_high_past, CLK32_SYSTEM_UPPER

	.unreq memorymap_base
	leap_year .req r7

	macro32_dsb ip

	ldr year, CLK32_YEAR_INIT
	ldr yearday, CLK32_YEARDAY_INIT
	ldrb hour, CLK32_HOUR_INIT
	ldrb minute, CLK32_MINUTE_INIT
	ldrb second, CLK32_SECOND_INIT
	ldr usecond, CLK32_USECOND_INIT

	macro32_dsb ip

	push {r0-r3}
	bl clk32_check_leapyear
	mov leap_year, r0
	pop {r0-r3}

	subs count_low_now, count_low_now, count_low_past
	sublo count_high_now, count_high_now, #1
	sub count_high_now, count_high_now, count_high_past
	cmp count_low_now, #0                               @ If Signed Minus
	mvnlt count_low_now, count_low_now
	addlt count_low_now, count_low_now, #1              @ Absolute Value
	cmp count_high_now, #0                              @ If Signed Minus
	mvnlt count_high_now, count_high_now
	addlt count_high_now, count_high_now, #1            @ Absolute Value

	.unreq count_low_past
	.unreq count_high_past
	temp  .req r8
	temp2 .req r9

	clk32_get_time_correction:
		/* Micro Seconds */

		mov temp, #0xF4000
		add temp, temp, #0x240                            @ Decimal 1000000

		push {r0-r3}
		mov r0, count_low_now
		mov r1, temp
		bl arm32_urem
		mov temp2, r0
		pop {r0-r3}

		sub count_low_now, count_low_now, temp2

		add usecond, usecond, temp2
		cmp usecond, temp
		subge usecond, usecond, temp
		addge second, second, #1
		str usecond, CLK32_USECOND 

		/* Seconds */

		mov temp, #0xF4000
		add temp, temp, #0x240                            @ Decimal 1000000
		mov temp2, #60
		mul temp2, temp, temp2

		push {r0-r3}
		mov r0, count_low_now
		mov r1, temp2
		bl arm32_urem
		mov temp2, r0
		pop {r0-r3}

		sub count_low_now, count_low_now, temp2

		push {r0-r3}
		mov r0, temp2
		mov r1, temp
		bl arm32_udiv
		mov temp2, r0
		pop {r0-r3}

		add second, second, temp2
		cmp second, #60
		subge second, second, #60
		addge minute, minute, #1
		strb second, CLK32_SECOND 

		/* Minutes */

		mov temp, #0xF4000
		add temp, temp, #0x240                            @ Decimal 1000000
		mov temp2, #60
		mul temp, temp, temp2
		mov temp2, #60
		mul temp2, temp, temp2

		/**
		 * Maximum Value of 32-bit is 4,294,967,295 (micro seconds in this case).
		 * Besides, 1 hour is 3,600,000,000 micro seconds.
		 * If the count can be divided by 3,600,000,000, it indicates that 1 hour is passed.
		 */
		push {r0-r3}
		mov r0, count_low_now
		mov r1, temp2
		bl arm32_udiv
		cmp r0, #1
		pop {r0-r3}
		addge hour, hour, #1

		push {r0-r3}
		mov r0, count_low_now
		mov r1, temp2
		bl arm32_urem
		mov temp2, r0
		pop {r0-r3}

		push {r0-r3}
		mov r0, temp2
		mov r1, temp
		bl arm32_udiv
		mov temp2, r0
		pop {r0-r3}

		add minute, minute, temp2
		cmp minute, #60
		subge minute, minute, #60
		addge hour, hour, #1
		strb minute, CLK32_MINUTE

		/* Hours */

		cmp hour, #24
		subge hour, hour, #24
		addge yearday, yearday, #1
		strb hour, CLK32_HOUR

		/* All Days */
		cmp leap_year, #1
		moveq temp2, #0x160
		addeq temp2, temp2, #0xE    @ Decimal 366
		movne temp2, #0x160
		addne temp2, temp2, #0xD    @ Decimal 365

		/* There is No Zero Day */
		cmp yearday, temp2 
		subgt yearday, yearday, temp2
		addgt year, year, #1
		str yearday, CLK32_YEARDAY

		str year, CLK32_YEAR

		sub count_high_now, count_high_now, #1
		cmp count_high_now, #0
		mvnge count_low_now, #0     @ 0xFFFFFFFF
		addge usecond, usecond, #1  @ Remainder of Higher Half
		bge clk32_get_time_correction

		.unreq yearday
		monthday .req r2

		ldr temp, CLK32_MONTHS
		mov month, #1

	clk32_get_time_monthday:
		ldrb temp2, [temp, month]
		subs monthday, monthday, temp2
		addgt month, month, #1
		bgt clk32_get_time_monthday

		add monthday, monthday, temp2

		strb month, CLK32_MONTH
		strb monthday, CLK32_MONTHDAY
	
		push {r0-r3}
		bl clk32_check_week
		mov temp, r0
		pop {r0-r3}

		strb temp, CLK32_WEEK

	clk32_get_time_common:
		mov r0, #0
		pop {r4-r11,pc}

.unreq year
.unreq month
.unreq monthday
.unreq hour
.unreq minute
.unreq second
.unreq usecond
.unreq leap_year
.unreq temp
.unreq temp2
.unreq count_low_now
.unreq count_high_now


/**
 * function clk32_check_leapyear
 * Check Leap Year or Not
 *
 * Parameters
 * r0: Year
 *
 * Return: r0 (1 as Leap Year, 0 as Not)
 */
.globl clk32_check_leapyear
clk32_check_leapyear:
	/* Auto (Local) Variables, but just Aliases */
	year           .req r0
	leap_year      .req r1

	push {lr}

	mov leap_year, #0

	/* Leap Year is Multiples by 4 */
	push {r0-r1}
	mov r1, #4
	bl arm32_urem
	cmp r0, #0
	pop {r0-r1}
	bne clk32_check_leapyear_common

	/* Except Divisible by 100, But Not by 400 */
	push {r0-r1}
	mov r1, #100
	bl arm32_urem
	cmp r0, #0
	pop {r0-r1}
	movne leap_year, #1
	bne clk32_check_leapyear_common

	push {r0-r1}
	mov r1, #400
	bl arm32_urem
	cmp r0, #0
	pop {r0-r1}
	bne clk32_check_leapyear_common

	mov leap_year, #1

	clk32_check_leapyear_common:
		macro32_dsb ip
		mov r0, leap_year
		pop {pc}

.unreq year
.unreq leap_year


/**
 * function clk32_check_week
 * Check Day on Week
 *
 * Parameters
 * r0: Year
 * r1: Month
 * r2: Day of Month
 *
 * Return: r0 (1 as Monday, 7 as Sunday)
 */
.globl clk32_check_week
clk32_check_week:
	/* Auto (Local) Variables, but just Aliases */
	year          .req r0
	month         .req r1
	monthday      .req r2
	century       .req r3 @ Zero Base, Not Ordinary
	temp          .req r4
	trans_century .req r5

	push {r4-r5,lr}

	/**
	 * Zeller's Congruence for Gregorian Calendar
	 * h = ( q + ( 13 * ( m + 1 ) Div by 5  ) + k + ( k Div by 4 ) + ( j Div by 4 ) - 2j ) mod 7
	 * Where h is the day of the week, q is the day of the month, m is the month (special rule), k is the year of the century, j is the century (Zero Based).
	 * On this function, 0 as Saturday and 6 as Friday. But ISO8601 uses 1 as Monday and 7 as Sunday.
	 */

	/* January and February Considered as 13th and 14th of Previous Year */
	cmp month, #2
	suble year, year, #1
	addle month, month, #12

	/* Get Century */
	push {r0-r2}
	mov r1, #100
	bl arm32_udiv
	mov century, r0
	pop {r0-r2}

	/* Get Year of Century  */
	push {r1-r3}
	mov r1, #100
	bl arm32_urem
	pop {r1-r3}

	/* Transformation of Month */
	add month, month, #1
	mov temp, #13
	mul month, month, temp
	push {r0-r3}
	mov r0, month
	mov r1, #5
	bl arm32_udiv
	mov temp, r0
	pop {r0-r3}

	.unreq month
	trans_month .req r1
	mov trans_month, temp

	.unreq temp
	trans_year .req r4

	lsr trans_year, year, #2       @ Substitute of Division by 4
	lsr trans_century, century, #2 @ Substitute of Division by 4

	/* Another Transformation of Century */
	lsl century, century, #1       @ Substitute of Multiplication by 2
	.unreq century
	century_double .req r3

	add monthday, monthday, trans_month
	add monthday, monthday, year
	add monthday, monthday, trans_year
	add monthday, monthday, trans_century
	sub monthday, monthday, century_double

	/* Prevent Minus */
	clk32_check_week_loop:
		cmp monthday, #0
		addlt monthday, monthday, #7
		blt clk32_check_week_loop

	/* Modular of 7 */
	push {r1-r3}
	mov r0, monthday
	mov r1, #7
	bl arm32_urem
	pop {r1-r3}

	.unreq year
	week .req r0

	cmp week, #0
	moveq week, #6
	beq clk32_check_week_common

	cmp week, #1
	moveq week, #7
	beq clk32_check_week_common

	cmp week, #2
	moveq week, #1
	beq clk32_check_week_common

	cmp week, #3
	moveq week, #2
	beq clk32_check_week_common

	cmp week, #4
	moveq week, #3
	beq clk32_check_week_common

	cmp week, #5
	moveq week, #4
	beq clk32_check_week_common

	cmp week, #6
	moveq week, #5

	clk32_check_week_common:
		macro32_dsb ip
		pop {r4-r5,pc}

.unreq week
.unreq trans_month
.unreq monthday
.unreq century_double
.unreq trans_year
.unreq trans_century

