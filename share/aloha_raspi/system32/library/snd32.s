/**
 * snd32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

SND32_CODE:                .word 0x00 @ Pointer of Music Code, If End, Automatically Cleared
SND32_LENGTH:              .word 0x00 @ Length of Music Code, If End, Automatically Cleared
SND32_COUNT:               .word 0x00 @ Incremental Count, Once Music Code Reaches Last, This Value will Be Reset
SND32_REPEAT:              .word 0x00 @ -1 is Infinite Loop

SND32_SUSPEND_CODE:        .word 0x00 @ Pointer of Music Code, If End, Automatically Cleared
SND32_SUSPEND_LENGTH:      .word 0x00 @ Length of Music Code, If End, Automatically Cleared
SND32_SUSPEND_COUNT:       .word 0x00 @ Incremental Count, Once Music Code Reaches Last, This Value will Be Reset
SND32_SUSPEND_REPEAT:      .word 0x00 @ -1 is Infinite Loop
SND32_INTERRUPT_COUNT:     .word 0x00

/**
 * Bit[0] Not Started(0)/ Started (1)
 * Bit[1] Regular State(0)/ Interrupt State(1)
 * Bit[2] Reserved
 * Bit[3] Reserved
 * Bit[31] Not Initialized(0)/ Initialized(1)
 */
SND32_STATUS:              .word 0x00

/**
 * Usage
 * 1. Place `snd32_soundplay` on FIQ/IRQ Handler which will be triggered with any timer.
 * 2. Place `_sounddecode` with Sound Index as an argument in `user32.c` before `snd32_soundset`.
 * 3. Place `_soundset` with needed arguments in `user32.c`.
 * 4. Music code automatically plays the sound with the assigned values.
 * 5. If you want to interrupt the playing sound to play another, use '_soundinterrupt'.
 * 6. If you want to stop the playing sound, use '_soundclear'.
 */

/**
 * Sound Index is made of an array of 16-bit Blocks.
 * Bit[11:0]: Length of Wave, 0 to 4095.
 *             If Bit[11:0] is 0, Long (0x1F40, Decimal 8000).
 *             If Bit[11:0] is 1, Super Long (0x3E80, Decimal 16000).
 * Bit[13:12]: Volume of Wave, 0 is Max., 1 is Bigger, 2 is Smaller, 3 is Zero (In Noise, Least).
 * Bit[15:14]: Type of Wave, 0 is Sin, 1 is Triangle, 2 is Square, 3 is Noise, ordered by less edges which cause harmonics.
 *
 * Maximum number of blocks is 65280.
 * 0 means End of Sound Index
 */

/**
 * Music Code is 16-bit Blocks. Select up to 65280 sounds indexed by Sound Index.
 * Index is 0-65279.
 * 0xFFFF(65535) means End of Music Code.
 */


/**
 * function snd32_sounddecode
 * Decode Sound Index
 *
 * Parameters
 * r0: Sound Index
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): Already Initialized
 * Error(2): Index Overflow
 */
.globl snd32_sounddecode
snd32_sounddecode:
	/* Auto (Local) Variables, but just Aliases */
	snd_index   .req r0 @ Register for Argument and Result, Scratch Register
	snd         .req r1 @ Scratch Register
	status      .req r2 @ Scratch Register
	i           .req r3 @ Scratch Register
	wave_length .req r4
	wave_volume .req r5
	wave_type   .req r6
	mem_alloc   .req r7
	cb          .req r8
	size_cb     .req r9

	push {r4-r9,lr}                           @ Style of Enter/Return (2017 Winter)

	ldr status, SND32_STATUS
	tst status, #0x80000000
	bne snd32_sounddecode_error1              @ If Already Initialized

	mov i, #0
	mov cb, #equ32_dma32_cb_snd32_start
	mov size_cb, #equ32_dma32_cb_snd32_size
	add size_cb, cb, size_cb

	snd32_sounddecode_main:

		ldrh snd, [snd_index, i]

		cmp snd, #0                               @ 0 is End of Sound Index
		beq snd32_sounddecode_success 

		snd32_sounddecode_main_wave:

			bic wave_length, snd, #0xF000
			and wave_volume, snd, #0x3000
			lsr wave_volume, wave_volume, #12
			and wave_type, snd, #0xC000
			lsr wave_type, wave_type, #14

			cmp wave_length, #0
			moveq wave_length, #0x1F40
			cmp wave_length, #1
			moveq wave_length, #0x3E80

			push {r0-r3}
			mov r0, wave_length                        @ Words
			bl heap32_malloc_noncache
			mov mem_alloc, r0
			pop {r0-r3}

			cmp wave_type, #3
			bhs snd32_sounddecode_main_wave_noise      @ If Noise

			/* Triangle or Square Wave */

			push {r0-r3}
			mov r0, mem_alloc
			mov r1, wave_length
			cmp wave_volume, #3
			moveq r2, #0
			cmp wave_volume, #2
			moveq r2, #31
			cmp wave_volume, #1
			moveq r2, #63
			movlo r2, #127                             @ Height in Bytes
			mov r3, #128                               @ Medium in Bytes
			cmp wave_type, #2
			bleq heap32_wave_square
			cmp wave_type, #1
			bleq heap32_wave_triangle
			cmp wave_type, #0
			bleq heap32_wave_sin
			pop {r0-r3}

			b snd32_sounddecode_main_wave_setcb

			snd32_sounddecode_main_wave_noise:

				push {r0-r3}
				mov r0, mem_alloc
				mov r1, wave_length
				cmp wave_volume, #3
				moveq r2, #31
				moveq r3, #31
				cmp wave_volume, #2
				moveq r2, #63
				moveq r3, #63
				cmp wave_volume, #1
				moveq r2, #127
				moveq r3, #127
				movlo r2, #255
				movlo r3, #255
				bl heap32_wave_random
				pop {r0-r3}

			snd32_sounddecode_main_wave_setcb:

				push {r0-r3}
				mov r0, mem_alloc
				mov r1, #1                                @ Clean
				bl arm32_cache_operation_heap
				pop {r0-r3}

				push {r0-r6}
				mov r0, cb
				mov r1, #5<<equ32_dma_ti_permap
				bic r1, r1, #equ32_dma_ti_no_wide_bursts
				orr r1, r1, #0<<equ32_dma_ti_waits
				orr r1, r1, #0<<equ32_dma_ti_burst_length
				orr r1, r1, #equ32_dma_ti_src_inc|equ32_dma_ti_dst_dreq @ Transfer Information
				orr r1, r1, #equ32_dma_ti_wait_resp
				mov r2, mem_alloc                                       @ Source Address
				mov r3, #equ32_bus_peripherals_base
				add r3, r3, #equ32_pwm_base_lower
				add r3, r3, #equ32_pwm_base_upper
				add r3, r3, #equ32_pwm_fif1                             @ Destination Address
				lsl r4, wave_length, #2	                                @ Transfer Length
				mov r5, #0                                              @ 2D Stride
				mov r6, cb                                              @ Next CB Number
				push {r4-r6}
				bl dma32_set_cb
				add sp, sp, #12
				pop {r0-r6}

		snd32_sounddecode_main_common:

			macro32_dsb ip
			add i, i, #2
			add cb, cb, #1
			cmp cb, size_cb
			bhs snd32_sounddecode_error2

			b snd32_sounddecode_main

	snd32_sounddecode_error1:
		mov r0, #1                                 @ Return with Error 1
		b snd32_sounddecode_common

	snd32_sounddecode_error2:
		mov r0, #2                                 @ Return with Error 2
		b snd32_sounddecode_common

	snd32_sounddecode_success:
		orr status, status, #0x80000000
		str status, SND32_STATUS

		macro32_dsb ip
		mov r0, #0                                 @ Return with Success

	snd32_sounddecode_common:
		pop {r4-r9,pc}                             @ Style of Enter/Return (2017 Winter)

.unreq snd_index
.unreq snd
.unreq status
.unreq i
.unreq wave_length
.unreq wave_volume
.unreq wave_type
.unreq mem_alloc
.unreq cb
.unreq size_cb


/**
 * function snd32_soundclear
 * Clear Music Code
 *
 * Return: r0 (0 as success)
 */
.globl snd32_soundclear
snd32_soundclear:
	/* Auto (Local) Variables, but just Aliases */
	temp   .req r0 @ Register for Result, Scratch Register

	mov temp, #0

	str temp, SND32_CODE

	macro32_dsb ip

	str temp, SND32_LENGTH
	str temp, SND32_COUNT
	str temp, SND32_REPEAT

	ldr temp, SND32_STATUS	
	bic temp, temp, #0x3                          @ Clear Bit[1] and Bit[0]
	str temp, SND32_STATUS

	macro32_dsb ip

	push {r0-r3,lr}
	mov r0, #equ32_snd32_dma_channel
	bl dma32_clear_channel
	pop {r0-r3,lr}

	snd32_soundclear_success:
		macro32_dsb ip
		mov r0, #0                            @ Return with Success

	snd32_soundclear_common:
		mov pc, lr

.unreq temp


/**
 * function snd32_soundplay
 * Play Sound
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): Music Code is Not Assgined
 * Error(2): Not Initialized 
 */
.globl snd32_soundplay
snd32_soundplay:
	/* Auto (Local) Variables, but just Aliases */
	addr_code   .req r0 @ Register for Result, Scratch Register
	length      .req r1 @ Scratch Register
	count       .req r2 @ Scratch Register
	repeat      .req r3 @ Scratch Register
	status      .req r4
	code        .req r5
	temp        .req r6
	temp2       .req r7

	push {r4-r7,lr}

	ldr addr_code, SND32_CODE
	cmp addr_code, #0
	beq snd32_soundplay_error1

	ldr length, SND32_LENGTH
	ldr count, SND32_COUNT
	ldr repeat, SND32_REPEAT
	ldr status, SND32_STATUS

	tst status, #0x80000000                   @ If Not Initialized
	beq snd32_soundplay_error2

	cmp count, length
	blo snd32_soundplay_jump

	mov count, #0

	cmp repeat, #-1
	beq snd32_soundplay_jump

	sub repeat, repeat, #1

	cmp repeat, #0
	beq snd32_soundplay_free

	snd32_soundplay_jump:

		lsl temp, count, #1                        @ Substitute of Multiplication by 2
		ldrh code, [addr_code, temp]

		tst status, #0x1
		bne snd32_soundplay_contine                @ If Continue of Music Code

	snd32_soundplay_first:

		push {r0-r3}
		mov r0, #equ32_snd32_dma_channel
		bl dma32_clear_channel
		pop {r0-r3}

		push {r0-r3}
		mov r0, #equ32_snd32_dma_channel
		mov r1, code
		bl dma32_set_channel
		pop {r0-r3}

		orr status, status, #0x1

		b snd32_soundplay_countup

	snd32_soundplay_contine:

		push {r0-r3}
		mov r0, #equ32_snd32_dma_channel
		mov r1, code
		bl dma32_change_nextcb
		pop {r0-r3}

	snd32_soundplay_countup:
		add count, count, #1
		str count, SND32_COUNT
		str repeat, SND32_REPEAT
		str status, SND32_STATUS

		tst status, #0x2                           @ Check Regular/Interrupt State
		beq snd32_soundplay_success

		ldr temp, SND32_INTERRUPT_COUNT
		add temp, temp, #1
		str temp, SND32_INTERRUPT_COUNT

		b snd32_soundplay_success

	snd32_soundplay_free:
		tst status, #0x2
		bne snd32_soundplay_free_interrupt         @ Check Regular/Interrupt State

		mov addr_code, #0
		mov length, #0
		bic status, status, #0x1                   @ Clear Bit[0]

		str addr_code, SND32_CODE
		str length, SND32_LENGTH
		str count, SND32_COUNT                     @ count is Already Zero
		str repeat, SND32_REPEAT                   @ repeat is Already Zero
		str status, SND32_STATUS

		push {r0-r3}
		mov r0, #equ32_snd32_dma_channel
		bl dma32_clear_channel
		pop {r0-r3}

		b snd32_soundplay_success

		snd32_soundplay_free_interrupt:
			.unreq code
			temp3 .req r5

			ldr temp, SND32_SUSPEND_LENGTH
			str temp, SND32_LENGTH

			ldr temp2, SND32_SUSPEND_COUNT
			ldr temp3, SND32_INTERRUPT_COUNT           @ Count of Interrupt Throughout
			add temp2, temp2, temp3

			cmp temp2, temp
			bls snd32_soundplay_free_interrupt_jump

			snd32_soundplay_free_interrupt_loop:
				subs temp2, temp2, temp
				bhi snd32_soundplay_free_interrupt_loop

			snd32_soundplay_free_interrupt_jump:

				str temp2, SND32_COUNT

				ldr temp, SND32_SUSPEND_REPEAT
				str temp, SND32_REPEAT
				bic status, status, #0x2                   @ Clear Interrupt State Bit[1]
				str status, SND32_STATUS
				ldr temp, SND32_SUSPEND_CODE
				str temp, SND32_CODE

				macro32_dsb ip

				push {r0-r3}
				bl snd32_soundplay                         @ Execute Itself
				pop {r0-r3}

				b snd32_soundplay_success

	snd32_soundplay_error1:
		mov r0, #1                            @ Return with Error 1
		b snd32_soundplay_common

	snd32_soundplay_error2:
		mov r0, #2                            @ Return with Error 1
		b snd32_soundplay_common

	snd32_soundplay_success:
		macro32_dsb ip
		mov r0, #0                            @ Return with Success

	snd32_soundplay_common:
		pop {r4-r7,pc}

.unreq addr_code
.unreq length
.unreq count
.unreq repeat
.unreq status
.unreq temp3
.unreq temp
.unreq temp2


/**
 * function snd32_soundset
 * Set Sound
 *
 * Parameters
 * r0: Music Code
 * r1: Length
 * r2: Count (Offset)
 * r3: Number of Repeat, If -1, Infinite Loop
 *
 * Return: r0 (0 as success)
 */
.globl snd32_soundset
snd32_soundset:
	/* Auto (Local) Variables, but just Aliases */
	addr_code   .req r0 @ Register for Result, Scratch Register
	length      .req r1 @ Scratch Register
	count       .req r2 @ Scratch Register
	repeat      .req r3 @ Scratch Register
	temp        .req r4

	push {r4}

	mov temp, #0

	str temp, SND32_CODE      @ Reset to Prevent Odd Playing Sound

	macro32_dsb ip

	ldr temp, SND32_STATUS
	bic temp, temp, #0x3      @ Clear Bit[1] and Bit[0]
	str temp, SND32_STATUS

	str length, SND32_LENGTH
	str count, SND32_COUNT
	str repeat, SND32_REPEAT

	macro32_dsb ip

	str addr_code, SND32_CODE @ Should Set Music Code at End for Polling Functions, `snd32_soundplay`

	snd32_soundset_success:
		macro32_dsb ip
		mov r0, #0                                 @ Return with Success

	snd32_soundset_common:
		pop {r4}
		mov pc, lr

.unreq addr_code
.unreq length
.unreq count
.unreq repeat
.unreq temp


/**
 * function snd32_soundinterrupt
 * Interrupt Sound to Main Sound
 *
 * Parameters
 * r0: Music Code
 * r1: Length
 * r2: Count (Offset)
 * r3: Number of Repeat, If -1, Infinite Loop
 *
 * Return: r0 (0 as success, 1 as error)
 * Error: Main Sound Has Not Been Set
 */
.globl snd32_soundinterrupt
snd32_soundinterrupt:
	/* Auto (Local) Variables, but just Aliases */
	addr_code   .req r0 @ Register for Result, Scratch Register
	length      .req r1 @ Scratch Register
	count       .req r2 @ Scratch Register
	repeat      .req r3 @ Scratch Register
	temp        .req r4
	temp2       .req r5

	push {r4-r5}

	ldr temp, SND32_STATUS
	tst temp, #0x2
	bne snd32_soundinterrupt_already

	mov temp, #0

	ldr temp2, SND32_CODE
	cmp temp2, #0
	beq snd32_soundinterrupt_error
	str temp2, SND32_SUSPEND_CODE
	str temp, SND32_CODE                 @ Reset to Prevent Odd Playing Sound

	macro32_dsb ip

	ldr temp2, SND32_LENGTH
	str temp2, SND32_SUSPEND_LENGTH

	ldr temp2, SND32_COUNT
	str temp2, SND32_SUSPEND_COUNT

	ldr temp2, SND32_REPEAT
	str temp2, SND32_SUSPEND_REPEAT

	str temp, SND32_INTERRUPT_COUNT      @ Reset Interrupt Counter

	ldr temp, SND32_STATUS
	orr temp, temp, #0x2                 @ Set Interrupt State Bit[1]
	str temp, SND32_STATUS

	snd32_soundinterrupt_already:

		str length, SND32_LENGTH
		str count, SND32_COUNT
		str repeat, SND32_REPEAT

		macro32_dsb ip

		str addr_code, SND32_CODE            @ Should Set Music Code at End for Polling Functions, `snd32_soundplay`

		b snd32_soundinterrupt_success

	snd32_soundinterrupt_error:
		mov r1, #1
		b snd32_soundinterrupt_common        @ Return with Error

	snd32_soundinterrupt_success:
		macro32_dsb ip
		mov r0, #0                           @ Return with Success

	snd32_soundinterrupt_common:
		pop {r4-r5}
		mov pc, lr

.unreq addr_code
.unreq length
.unreq count
.unreq repeat
.unreq temp
.unreq temp2


/**
 * function snd32_musiclen
 * Count 2-Bytes Beats of Music Code
 *
 * Parameters
 * r0: Pointer of Array of Music Code
 *
 * Return: r0 (Number of Beats in Music Code) Maximum of 4,294,967,295 Beats
 */
.globl snd32_musiclen
snd32_musiclen:
	/* Auto (Local) Variables, but just Aliases */
	music_point       .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	music_hword       .req r1
	length            .req r2
	end               .req r3

	mov length, #0
	mov end, #0xFF00                             @ 0xFFFF is End of Music Code
	orr end, end, #0x00FF

	snd32_musiclen_loop:
		ldrh music_hword, [music_point]           @ Load Half Word (16-bit)
		cmp music_hword, end
		beq snd32_musiclen_common                 @ Break Loop if Null Character

		add music_point, music_point, #2
		add length, length, #1
		b snd32_musiclen_loop

	snd32_musiclen_common:
		mov r0, length
		mov pc, lr

.unreq music_point
.unreq music_hword
.unreq length
.unreq end


/**
 * function snd32_soundtest
 *
 * Parameters
 * r0:
 * r1:
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1):
 * Error(2):
 */
.globl snd32_soundtest
snd32_soundtest:
	/* Auto (Local) Variables, but just Aliases */
	temp .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	push {r4-r11}

	push {r0-r3,lr}
	mov r0, #144                            @ 144 Words Equals 576 Bytes
	bl heap32_malloc
	mov r4, r0
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, r4
	mov r1, #144                           @ Length in Words, Intended that 3.2KHz/144 Equals 222.2Hz
	mov r2, #63                            @ Height in Bytes
	mov r3, #128                           @ Medium in Bytes
	bl heap32_wave_triangle
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, r4
	mov r1, #1                                @ Clean
	bl arm32_cache_operation_heap
	pop {r0-r3,lr}

	/* Channel Block Setting */

	push {r0-r6,lr}
	mov r0, #0                                              @ CB Number
	mov r1, #5<<equ32_dma_ti_permap
	orr r1, r1, #equ32_dma_ti_src_dreq|equ32_dma_ti_src_inc @ Transfer Information
	mov r2, r4                                              @ Source Address
	mov r3, #equ32_bus_peripherals_base
	add r3, r3, #equ32_pwm_base_lower
	add r3, r3, #equ32_pwm_base_upper
	add r3, r3, #equ32_pwm_fif1                             @ Destination Address
	mov r4, #576	                                        @ Transfer Length
	mov r5, #0                                              @ 2D Stride
	mov r6, #0                                              @ Next CB Number
	push {r4-r6}
	bl dma32_set_cb
	add sp, sp, #12
	pop {r0-r6,lr}

	push {r0-r3,lr}
	mov r0, #1
	mov r1, #0
	bl dma32_set_channel
	pop {r0-r3,lr}

	b snd32_soundtest_success

	snd32_soundtest_error1:
		mov r0, #1                                 @ Return with Error 1
		b snd32_soundtest_common

	snd32_soundtest_error2:
		mov r0, #2                                 @ Return with Error 2
		b snd32_soundtest_common

	snd32_soundtest_success:
		mov r0, #0                                 @ Return with Success

	snd32_soundtest_common:
		pop {r4-r11}
		mov pc, lr

.unreq temp
