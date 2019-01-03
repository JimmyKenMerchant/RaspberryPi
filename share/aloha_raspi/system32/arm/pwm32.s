/**
 * pwm32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

PWM32_PWM_CHANNEL:           .word 0
PWM32_PWM_MAXCHANNEL:        .word 1
PWM32_SEQUENCE_ADDR:         .word PWM32_SEQUENCE_1
PWM32_SEQUENCE_1:            .word 0x00 @ Pointer of PWM Sequence, If End, Automatically Cleared
PWM32_LENGTH_1:              .word 0x00 @ Length of PWM Sequence, If End, Automatically Cleared
PWM32_COUNT_1:               .word 0x00 @ Incremental Count, Once PWM Sequence Reaches Last, This Value will Be Reset
PWM32_REPEAT_1:              .word 0x00 @ -1 is Infinite Loop
PWM32_SEQUENCE_2:            .word 0x00 @ Pointer of PWM Sequence, If End, Automatically Cleared
PWM32_LENGTH_2:              .word 0x00 @ Length of PWM Sequence, If End, Automatically Cleared
PWM32_COUNT_2:               .word 0x00 @ Incremental Count, Once MPWM Sequence Reaches Last, This Value will Be Reset
PWM32_REPEAT_2:              .word 0x00 @ -1 is Infinite Loop

/**
 * Usage
 * 1. Place `pwm32_pwmplay` on FIQ/IRQ Handler which will be triggered with any timer.
 * 2. Select Channel by `_pwmselect`.
 * 3. Place `_pwmset` with needed arguments in `user32.c`.
 * 4. PWM sequence automatically runs with the assigned values.
 * 5. If you want to stop the PWM sequence, use `_pwmclear`. Constant 1 of its argument will stay current status of PWM.
 */

/**
 * PWM sequence is made of 32-bit Blocks. One Block means one beat.
 * Bit[30:0]: Data 0 to 2,147,483,647
 * Bit[31]: Always One
 * Note that if a beat is all zero, this beat means the end of sequence.
 */


/**
 * function pwm32_pwmplay
 * Play GPIO Sequence
 *
 * Return: r0 (0 as success, 1 as error)
 * Error: GPIO Sequence is not assigned
 */
.globl pwm32_pwmplay
pwm32_pwmplay:
	/* Auto (Local) Variables, but just Aliases */
	memorymap_base .req r0
	length         .req r1
	count          .req r2
	repeat         .req r3
	addr_seq       .req r4
	sequence       .req r5
	number_pwm     .req r6
	pwm_base       .req r7
	temp           .req r8

	push {r4-r8}

	ldr number_pwm, PWM32_PWM_CHANNEL

	ldr memorymap_base, PWM32_SEQUENCE_ADDR
	cmp number_pwm, #0
	addne memorymap_base, memorymap_base, #16

	ldr addr_seq, [memorymap_base]
	cmp addr_seq, #0
	beq pwm32_pwmplay_error

	ldr length, [memorymap_base, #4]
	cmp length, #0
	beq pwm32_pwmplay_error

	ldr count, [memorymap_base, #8]
	ldr repeat, [memorymap_base, #12]

	cmp count, length
	blo pwm32_pwmplay_main

	mov count, #0

	cmp repeat, #-1
	beq pwm32_pwmplay_main

	sub repeat, repeat, #1

	cmp repeat, #0
	beq pwm32_pwmplay_free

	pwm32_pwmplay_main:

		mov pwm_base, #equ32_peripherals_base
		add pwm_base, pwm_base, #equ32_pwm_base_lower
		add pwm_base, pwm_base, #equ32_pwm_base_upper

		lsl temp, count, #2                        @ Substitution of Multiplication by 4

		ldr sequence, [addr_seq, temp]

		bic sequence, sequence, #0x80000000

		cmp number_pwm, #0
		streq sequence, [pwm_base, #equ32_pwm_dat1]
		strne sequence, [pwm_base, #equ32_pwm_dat2]

		macro32_dsb ip

		add count, count, #1
		str count, [memorymap_base, #8]
		str repeat, [memorymap_base, #12]

		b pwm32_pwmplay_success

	pwm32_pwmplay_free:

		mov addr_seq, #0
		mov length, #0

		str addr_seq, [memorymap_base]
		str length, [memorymap_base, #4]
		str count, [memorymap_base, #8]            @ count is Already Zero
		str repeat, [memorymap_base, #12]          @ repeat is Already Zero

		b pwm32_pwmplay_success

	pwm32_pwmplay_error:
		mov r0, #1
		b pwm32_pwmplay_common

	pwm32_pwmplay_success:
		mov r0, #0                            @ Return with Success

	pwm32_pwmplay_common:
		pop {r4-r8}
		mov pc, lr

.unreq memorymap_base
.unreq length
.unreq count
.unreq repeat
.unreq addr_seq
.unreq sequence
.unreq number_pwm
.unreq pwm_base
.unreq temp


/**
 * function pwm32_pwmset
 * Set PWM Sequence
 *
 * Parameters
 * r0: PWM Sequence
 * r1: Length
 * r2: Count (Offset)
 * r3: Number of Repeat, If -1, Infinite Loop
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Failure of Setting (Pointer of PWM Sequence is Addressed to Zero or Length is Zero)
 */
.globl pwm32_pwmset
pwm32_pwmset:
	/* Auto (Local) Variables, but just Aliases */
	addr_seq       .req r0
	length         .req r1
	count          .req r2
	repeat         .req r3
	temp           .req r4
	memorymap_base .req r5
	number_pwm     .req r6

	push {r4-r6}

	cmp addr_seq, #0
	beq pwm32_pwmset_error
	cmp length, #0
	beq pwm32_pwmset_error

	ldr number_pwm, PWM32_PWM_CHANNEL

	ldr memorymap_base, PWM32_SEQUENCE_ADDR
	cmp number_pwm, #0
	addne memorymap_base, memorymap_base, #16

	mov temp, #0

	str temp, [memorymap_base]        @ Pointer of Sequence

	macro32_dsb ip

	str length, [memorymap_base, #4]  @ Length of PWM Sequence
	str count, [memorymap_base, #8]   @ Incremental Count
	str repeat, [memorymap_base, #12] @ -1 is Infinite Loop

	macro32_dsb ip

	str addr_seq, [memorymap_base]    @ Pointer of PWM Sequence

	b pwm32_pwmset_success

	pwm32_pwmset_error:
		mov r0, #1
		b pwm32_pwmset_common

	pwm32_pwmset_success:
		macro32_dsb ip
		mov r0, #0                                 @ Return with Success

	pwm32_pwmset_common:
		pop {r4-r6}
		mov pc, lr

.unreq addr_seq
.unreq length
.unreq count
.unreq repeat
.unreq temp
.unreq memorymap_base
.unreq number_pwm


/**
 * function pwm32_pwmclear
 * Clear GPIO Sequence
 *
 * Parameters
 * r0: Clear All (0) / Stay PWM Current Status (1)
 *
 * Return: r0 (0 as success)
 */
.globl pwm32_pwmclear
pwm32_pwmclear:
	/* Auto (Local) Variables, but just Aliases */
	stay           .req r0
	number_pwm     .req r1
	temp           .req r2
	memorymap_base .req r3

	ldr number_pwm, PWM32_PWM_CHANNEL

	ldr memorymap_base, PWM32_SEQUENCE_ADDR
	cmp number_pwm, #0
	addne memorymap_base, memorymap_base, #16

	mov temp, #0

	str temp, [memorymap_base]      @ Pointer of Sequence

	macro32_dsb ip

	str temp, [memorymap_base, #4]  @ Length of PWM Sequence
	str temp, [memorymap_base, #8]  @ Incremental Count
	str temp, [memorymap_base, #12] @ -1 is Infinite Loop

	macro32_dsb ip

	cmp stay, #0
	bhi pwm32_pwmclear_success

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_pwm_base_lower
	add memorymap_base, memorymap_base, #equ32_pwm_base_upper

	cmp number_pwm, #0
	streq temp, [memorymap_base, #equ32_pwm_dat1]
	strne temp, [memorymap_base, #equ32_pwm_dat2]

	pwm32_pwmclear_success:
		mov r0, #0                                 @ Return with Success

	pwm32_pwmclear_common:
		mov pc, lr

.unreq stay
.unreq number_pwm
.unreq temp
.unreq memorymap_base


/**
 * function pwm32_pwmselect
 * Count 4-Bytes Beats of PWM Sequence
 *
 * Parameters
 * r0: Number of PWM Channel (Starting from 0)
 *
 * Return: r0 (0 as Success, 1 as Error)
 * Error: Number of PWM Channel Exceeds Limitage
 */
.globl pwm32_pwmselect
pwm32_pwmselect:
	/* Auto (Local) Variables, but just Aliases */
	number .req r0
	max    .req r1

	ldr max, PWM32_PWM_MAXCHANNEL

	cmp number, max
	strle number, PWM32_PWM_CHANNEL
	movle number, #0

	movgt number, #1

	pwm32_pwmselect_common:
		mov pc, lr

.unreq number
.unreq max


/**
 * function pwm32_pwmlen
 * Count 4-Bytes Beats of PWM Sequence
 *
 * Parameters
 * r0: Pointer of Array of PWM Sequence
 *
 * Return: r0 (Number of Beats in PWM Sequence) Maximum of 4,294,967,295 Beats
 */
.globl pwm32_pwmlen
pwm32_pwmlen:
	/* Auto (Local) Variables, but just Aliases */
	sequence_point .req r0
	sequence_word  .req r1
	length         .req r2

	mov length, #0

	pwm32_pwmlen_loop:
		ldr sequence_word, [sequence_point]         @ Load Half Word (16-bit)
		cmp sequence_word, #0                       @ NULL Character (End of String) Checker
		beq pwm32_pwmlen_common                     @ Break Loop if Null Character

		add sequence_point, sequence_point, #4
		add length, length, #1
		b pwm32_pwmlen_loop

	pwm32_pwmlen_common:
		mov r0, length
		mov pc, lr

.unreq sequence_point
.unreq sequence_word
.unreq length


/**
 * function pwm32_pwminit
 * PWM Initializer
 *
 * Parameters
 * r0: 0 as Variable Frequencies to Balance Pulses (Multiple Highs and Lows), 1 as Fixed Frequency (One High and Low) in A Duty Cycle
 * r1: Range of PWM0
 * r2: Range of PWM1
 *
 * Return: r0 (0 as Success)
 */
.globl pwm32_pwminit
pwm32_pwminit:
	/* Auto (Local) Variables, but just Aliases */
	pwm_mode       .req r0
	range_0        .req r1
	range_1        .req r2
	memorymap_base .req r3
	value          .req r4

	push {r4,lr}

	/**
	 * GPIO for PWM
	 */
	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_gpio_base

	ldr value, [memorymap_base, #equ32_gpio_gpfsel10]
	bic value, value, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_2  @ Clear GPIO 12
	orr value, value, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_2   @ Set GPIO 12 PWM0
	bic value, value, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_3  @ Clear GPIO 13
	orr value, value, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_3   @ Set GPIO 13 PWM1
	str value, [memorymap_base, #equ32_gpio_gpfsel10]

	macro32_dsb ip

	/**
	 * PWM Enable
	 */
	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_pwm_base_lower
	add memorymap_base, memorymap_base, #equ32_pwm_base_upper

	str range_0, [memorymap_base, #equ32_pwm_rng1]
	str range_1, [memorymap_base, #equ32_pwm_rng2]

	mov value, #equ32_pwm_ctl_clrf1|equ32_pwm_ctl_pwen1
	orr value, value, #equ32_pwm_ctl_pwen2
	cmp pwm_mode, #0
	orrne value, value, #equ32_pwm_ctl_msen1
	orrne value, value, #equ32_pwm_ctl_msen2
	str value, [memorymap_base, #equ32_pwm_ctl]

	macro32_dsb ip

	pwm32_pwminit_common:
		mov r0, #0
		pop {r4,pc}

.unreq pwm_mode
.unreq range_0
.unreq range_1
.unreq memorymap_base
.unreq value

