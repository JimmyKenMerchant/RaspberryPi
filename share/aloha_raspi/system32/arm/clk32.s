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
CLK32_UTC:          .word 0x00 @ Coordinated Universal Time, Minus Sign Exists
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
	timestamp_low  .req r4
	timestamp_high .req r5

	push {r4-r5,lr}

	push {r0-r3}
	bl arm32_timestamp
	mov timestamp_low, r0
	mov timestamp_high, r1
	pop {r0-r3}

	str timestamp_low, CLK32_SYSTEM_LOWER
	str timestamp_high, CLK32_SYSTEM_UPPER

	strb hour, CLK32_HOUR_INIT
	strb minute, CLK32_MINUTE_INIT
	strb second, CLK32_SECOND_INIT
	str usecond, CLK32_USECOND_INIT

	macro32_dsb ip

	clk32_clock_init_common:
		mov r0, #0
		pop {r4-r5,pc}

.unreq hour
.unreq minute
.unreq second
.unreq usecond
.unreq timestamp_low
.unreq timestamp_high


/**
 * function clk32_correct_utc
 * Time Correction From UTC
 *
 * Parameters
 * r0: Distance from UTC
 *
 * Return: r0 (0 as Success)
 */
.globl clk32_correct_utc
clk32_correct_utc:
	/* Auto (Local) Variables, but just Aliases */
	year              .req r0
	yearday           .req r1
	hour              .req r2
	distance_utc      .req r3
	swap              .req r4
	prev_distance_utc .req r5

	push {r4-r5,lr}

	mov distance_utc, year

	ldr year, CLK32_YEAR_INIT
	ldr yearday, CLK32_YEARDAY_INIT
	ldrb hour, CLK32_HOUR_INIT
	ldr prev_distance_utc, CLK32_UTC
	/* Store New Distance from UTC */
	str distance_utc, CLK32_UTC

	macro32_dsb ip
	
	/* If Previous Distance from UTC Is Not Zero, Back to UTC Then Correct Time for New Distance from UTC Again */
	cmp prev_distance_utc, #0
	beq clk32_correct_utc_main

	mov swap, distance_utc
	mov distance_utc, prev_distance_utc
	mov prev_distance_utc, swap

	.unreq swap
	leap_year .req r4

	/* Convert Plus and Minus Sign to Back to UTC */
	mvn distance_utc, distance_utc
	add distance_utc, distance_utc, #1

	clk32_correct_utc_main:

		/* Hours */
		add hour, hour, distance_utc
		cmp hour, #24
		subge hour, hour, #24
		addge yearday, yearday, #1
		cmp hour, #0
		addlt hour, hour, #24
		sublt yearday, yearday, #1

		/* If Past Year */
		cmp yearday, #0
		suble year, year, #1          @ If Past Year

		push {r0-r3}
		bl clk32_check_leapyear
		mov leap_year, r0
		pop {r0-r3}

		/* Amount of Days of Year */
		cmp leap_year, #1

		.unreq leap_year
		allday .req r4

		moveq allday, #0x160
		addeq allday, allday, #0xE    @ Decimal 366
		movne allday, #0x160
		addne allday, allday, #0xD    @ Decimal 365

		/* Past Year */
		cmp yearday, #0
		movle yearday, allday
		ble clk32_correct_utc_main_common

		/* Current Year */
		cmp yearday, allday
		subgt yearday, yearday, allday
		addgt year, year, #1

		clk32_correct_utc_main_common:

			/* If Previous UTC Distance is Backed, Correct Time for New UTC Distance Again Except New Distance is Zero */
			cmp prev_distance_utc, #0
			movne distance_utc, prev_distance_utc
			movne prev_distance_utc, #0 
			bne clk32_correct_utc_main

			strb hour, CLK32_HOUR_INIT
			str yearday, CLK32_YEARDAY_INIT
			str year, CLK32_YEAR_INIT

	clk32_correct_utc_common:
		mov r0, #0
		pop {r4-r5,pc}

.unreq year
.unreq yearday
.unreq hour
.unreq distance_utc
.unreq allday
.unreq prev_distance_utc


/**
 * function clk32_get_time
 * Get Current Time From Clock
 *
 * Return: r0 (0 as Success)
 */
.globl clk32_get_time
clk32_get_time:
	/* Auto (Local) Variables, but just Aliases */
	timestamp_low   .req r0
	timestamp_high  .req r1

	push {lr}

	bl arm32_timestamp
	bl clk32_set_time

	clk32_get_time_common:
		pop {pc}

.unreq timestamp_low
.unreq timestamp_high


/**
 * function clk32_set_time
 * Set Time From Time Stamp
 *
 * Parameters
 * r0: Lower 32 Bits of Time Stamp
 * r1: Upper 32 Bits of Time Stamp
 *
 * Return: r0 (0 as Success)
 */
.globl clk32_set_time
clk32_set_time:
	/* Auto (Local) Variables, but just Aliases */
	year                .req r0
	month               .req r1
	yearday             .req r2
	hour                .req r3
	minute              .req r4
	second              .req r5
	usecond             .req r6
	leap_year           .req r7
	timestamp_low_past  .req r8
	timestamp_high_past .req r9
	timestamp_low       .req r10
	timestamp_high      .req r11

	push {r4-r11,lr}

	mov timestamp_low, year
	mov timestamp_high, month

	ldr timestamp_low_past, CLK32_SYSTEM_LOWER
	ldr timestamp_high_past, CLK32_SYSTEM_UPPER
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

	subs timestamp_low, timestamp_low, timestamp_low_past
	sublo timestamp_high, timestamp_high, #1
	sub timestamp_high, timestamp_high, timestamp_high_past

	.unreq timestamp_low_past
	.unreq timestamp_high_past
	temp  .req r8
	temp2 .req r9

	clk32_set_time_correction:
		/* Micro Seconds */

		mov temp, #0xF4000
		add temp, temp, #0x240                            @ Decimal 1000000

		push {r0-r3}
		mov r0, timestamp_low
		mov r1, temp
		bl arm32_urem
		mov temp2, r0
		pop {r0-r3}

		sub timestamp_low, timestamp_low, temp2

		add usecond, usecond, temp2
		cmp usecond, temp
		subge usecond, usecond, temp
		addge second, second, #1

		/* Seconds */

		mov temp, #0xF4000
		add temp, temp, #0x240                            @ Decimal 1000000
		mov temp2, #60
		mul temp2, temp, temp2

		push {r0-r3}
		mov r0, timestamp_low
		mov r1, temp2
		bl arm32_urem
		mov temp2, r0
		pop {r0-r3}

		sub timestamp_low, timestamp_low, temp2

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
		mov r0, timestamp_low
		mov r1, temp2
		bl arm32_udiv
		cmp r0, #1
		pop {r0-r3}
		addge hour, hour, #1

		push {r0-r3}
		mov r0, timestamp_low
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

		/* Hours */

		cmp hour, #24
		subge hour, hour, #24
		addge yearday, yearday, #1

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

		sub timestamp_high, timestamp_high, #1
		cmp timestamp_high, #0
		mvnge timestamp_low, #0     @ 0xFFFFFFFF
		addge usecond, usecond, #1  @ Remainder of Higher Half
		bge clk32_set_time_correction

		str usecond, CLK32_USECOND 
		strb second, CLK32_SECOND 
		strb minute, CLK32_MINUTE
		strb hour, CLK32_HOUR
		str yearday, CLK32_YEARDAY
		str year, CLK32_YEAR

		.unreq yearday
		monthday .req r2

		ldr temp, CLK32_MONTHS
		mov month, #1

	clk32_set_time_monthday:
		ldrb temp2, [temp, month]
		subs monthday, monthday, temp2
		addgt month, month, #1
		bgt clk32_set_time_monthday

		add monthday, monthday, temp2

		strb month, CLK32_MONTH
		strb monthday, CLK32_MONTHDAY
	
		push {r0-r3}
		bl clk32_check_week
		mov temp, r0
		pop {r0-r3}

		strb temp, CLK32_WEEK

	clk32_set_time_common:
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
.unreq timestamp_low
.unreq timestamp_high


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

