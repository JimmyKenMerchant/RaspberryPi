/**
 * snd32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

SND32_CODE:                .word 0x00 @ Pointer of Sequence of Music Code, If End, Automatically Cleared
SND32_LENGTH:              .word 0x00 @ Length of Sequence of Music Code, If End, Automatically Cleared
SND32_COUNT:               .word 0x00 @ Incremental Count, Once Sequence of Music Code Reaches Last, This Value will Be Reset
SND32_REPEAT:              .word 0x00 @ -1 is Infinite Loop
SND32_CURRENTCODE:         .word 0x00 @ Currently Playng Music Code

SND32_SUSPEND_CODE:        .word 0x00 @ Pointer of Music Code, If End, Automatically Cleared
SND32_SUSPEND_LENGTH:      .word 0x00 @ Length of Music Code, If End, Automatically Cleared
SND32_SUSPEND_COUNT:       .word 0x00 @ Incremental Count, Once Music Code Reaches Last, This Value will Be Reset
SND32_SUSPEND_REPEAT:      .word 0x00 @ -1 is Infinite Loop
SND32_INTERRUPT_COUNT:     .word 0x00

/**
 * Bit[0] Stopped (0)/ Started (1)
 * Bit[1] Regular State(0)/ Interrupt State(1)
 * Bit[2] MIDI Note Off(0)/ Note On(1)
 * Bit[3] Reserved
 * Bit[31] Not Initialized(0)/ Initialized(1)
 */
.globl SND32_STATUS
SND32_STATUS:              .word 0x00

SND32_SOUND_ADJUST:        .word 0x00 @ Pointer of Sound Adjust Table

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
 * Bit[10:0]: Length of Wave, 0 to 2048.
 *             If Bit[11:0] is 0, Long (0x1F40, Decimal 8000).
 *             If Bit[11:0] is 1, Super Long (0x3E80, Decimal 16000).
 * Bit[12:11]: Volume of Wave, 0 is Large, 1 is Medium, 2 is Small, 3 is Tiny
 * Bit[15:13]: Type of Wave, 0 is Sine, 1 is Saw Tooth, 2 is Square, 3 is Triangle, 4 is Distortion
 *              6 is Noise, 7 is Silence.
 *
 * Maximum number of blocks is 4096.
 * 0 means End of Sound Index
 */

/**
 * Music Code is 16-bit Blocks. Select up to 4096 sounds indexed by Sound Index.
 * Index is 0-4095.
 * 0xFFFF(65535) means End of Music Code.
 */


/**
 * function snd32_sounddecode
 * Decode Sound Index
 *
 * Parameters
 * r0: Sound Index
 * r1: 0 as PWM Mode Monoral, 1 as PWM Mode Balanced Monoral, 2 as PCM Mode, 3 as PCM Mode Balanced Monoral
 * r2: Sound Adjust Table
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): Already Initialized
 * Error(2): Index Overflow or Failure of Memory Allocation
 */
.globl snd32_sounddecode
snd32_sounddecode:
	/* Auto (Local) Variables, but just Aliases */
	snd_index   .req r0
	mode        .req r1
	snd         .req r2
	i           .req r3
	temp        .req r4
	wave_length .req r5
	wave_volume .req r6
	wave_type   .req r7
	mem_alloc   .req r8
	temp2       .req r9
	cb          .req r10
	size_cb     .req r11

	push {r4-r11,lr}                          @ Style of Enter/Return (2017 Winter)

	ldr temp, SND32_STATUS
	tst temp, #0x80000000
	bne snd32_sounddecode_error1              @ If Already Initialized

	str snd, SND32_SOUND_ADJUST

	mov i, #0
	mov cb, #equ32_dma32_cb_snd32_start
	mov size_cb, #equ32_dma32_cb_snd32_size
	add size_cb, cb, size_cb

	snd32_sounddecode_main:

		ldrh snd, [snd_index, i]

		cmp snd, #0                               @ 0 is End of Sound Index
		beq snd32_sounddecode_success 

		snd32_sounddecode_main_wave:

			bic wave_length, snd, #0xF800         @ Bit[10:0]
			and wave_volume, snd, #0x1800         @ Bit[12:11]
			lsr wave_volume, wave_volume, #11
			and wave_type, snd, #0xE000           @ Bit[15:13]
			lsr wave_type, wave_type, #13

			.unreq snd
			temp3 .req r2

			/* Check Wether Wave Type is Random or Not */
			cmp wave_type, #6
			beq snd32_sounddecode_main_wave_random

			cmp wave_length, #0
			moveq wave_length, #0x1F40
			cmp wave_length, #1
			moveq wave_length, #0x3E80

			push {r0-r3}
			mov r0, wave_length                        @ Words
			bl heap32_malloc_noncache
			mov mem_alloc, r0
			pop {r0-r3}

			cmp mem_alloc, #0
			beq snd32_sounddecode_error2

			/* Check Wether Wave Type is Silence or Not */
			cmp wave_type, #7
			beq snd32_sounddecode_main_wave_silence

			/* Square, Sawtooth, and Sin Wave */

			push {r0-r3}
			mov r0, mem_alloc
			cmp wave_volume, #3
			moveq r2, #31
			cmp wave_volume, #2
			moveq r2, #63
			cmp wave_volume, #1
			moveq r2, #127
			movlo r2, #255
			cmp mode, #2
			movlo r3, #equ32_snd32_sounddecode_pwm_bias @ DC Offset in Bytes (Unsigned) for PWM
			movhs r3, #0                               @ DC Offset in Bytes (Signed) for PCM
			addhs r2, r2, #1                           @ Applied for 16-bit Resolution for PCM
			lslhs r2, r2, #5                           @ Applied for 16-bit Resolution for PCM, Substitute of Multiplication by 32
			subhs r2, r2, #1                           @ Applied for 16-bit Resolution for PCM
			mov r1, wave_length                        @ Assign r1 at Last Bacause mode Requires r1
			cmp wave_type, #4
			bleq heap32_wave_random2
			cmp wave_type, #3
			bleq heap32_wave_triangle
			cmp wave_type, #2
			bleq heap32_wave_square
			cmp wave_type, #1
			bleq heap32_wave_sawtooth
			cmp wave_type, #0
			bleq heap32_wave_sin
			pop {r0-r3}

			b snd32_sounddecode_main_wave_balance

			snd32_sounddecode_main_wave_random:

				/* Length is Fixed by Constant in Random */

				push {r0-r3}
				mov r0, #equ32_snd32_sounddecode_noise_len_upper
				orr r0, r0, #equ32_snd32_sounddecode_noise_len_lower
				bl heap32_malloc_noncache
				mov mem_alloc, r0
				pop {r0-r3}

				cmp mem_alloc, #0
				beq snd32_sounddecode_error2

				/* Random */

				push {r0-r3}
				mov r0, mem_alloc
				cmp wave_volume, #3
				moveq r2, #31
				cmp wave_volume, #2
				moveq r2, #63
				cmp wave_volume, #1
				moveq r2, #127
				movlo r2, #255
				cmp mode, #2
				movlo r3, #equ32_snd32_sounddecode_pwm_bias @ DC Offset in Bytes (Unsigned) for PWM
				movhs r3, #0                               @ DC Offset in Bytes (Signed) for PCM
				addhs r2, r2, #1                           @ Applied for 16-bit Resolution for PCM
				lslhs r2, r2, #5                           @ Applied for 16-bit Resolution for PCM, Substitute of Multiplication by 32
				subhs r2, r2, #1                           @ Applied for 16-bit Resolution for PCM
				/* Assign r1 at Last Bacause mode Requires r1 */
				mov r1, #equ32_snd32_sounddecode_noise_len_upper
				orr r1, r1, #equ32_snd32_sounddecode_noise_len_lower
				mov temp, #equ32_snd32_sounddecode_noise_resolution
				push {temp,wave_length}                    @ In Random Wave, Length Parameter Is Used as Stride (Affecting Frequencies)
				bl heap32_wave_random
				add sp, sp, #8
				pop {r0-r3}

				/* For Further Processes in PWM */
				mov wave_length, #equ32_snd32_sounddecode_noise_len_upper
				orr wave_length, wave_length, #equ32_snd32_sounddecode_noise_len_lower

				b snd32_sounddecode_main_wave_balance

			snd32_sounddecode_main_wave_silence:
				/* If PCM, No Need of Filling */
				cmp mode, #2
				bhs snd32_sounddecode_main_wave_balance

				push {r0-r3}
				mov r0, mem_alloc
				mov r1, #equ32_snd32_sounddecode_pwm_bias  @ DC Offset in Bytes (Unsigned) for PWM
				bl heap32_mfill
				pop {r0-r3}

			snd32_sounddecode_main_wave_balance:

				cmp mode, #2
				bhs snd32_sounddecode_main_wave_pcm
				cmp mode, #1
				bne snd32_sounddecode_main_wave_pwm

				/* For PWM Balanced Monoral */

				push {r0-r3}
				mov r0, wave_length                        @ Words
				bl heap32_malloc_noncache
				cmp r0, #0
				mov temp, r0
				pop {r0-r3}

				beq snd32_sounddecode_error2

				push {r0-r3}
				mov r0, temp
				mov r1, mem_alloc
				mov r2, #equ32_snd32_sounddecode_pwm_bias  @ DC Offset in Bytes (Unsigned) for PWM
				bl heap32_wave_invert
				cmp r0, #0
				pop {r0-r3}

				bne snd32_sounddecode_error2

			snd32_sounddecode_main_wave_pwm:

				lsl wave_length, wave_length, #1

				push {r0-r3}
				mov r0, wave_length                        @ Words
				bl heap32_malloc_noncache
				cmp r0, #0
				mov temp2, r0
				pop {r0-r3}

				beq snd32_sounddecode_error2

				push {r0-r3}
				cmp mode, #1
				moveq r2, temp
				movne r2, mem_alloc
				mov r0, temp2
				mov r1, mem_alloc
				bl heap32_mweave
				cmp r0, #0
				pop {r0-r3}

				bne snd32_sounddecode_error2

				push {r0-r3}
				mov r0, mem_alloc
				bl heap32_mfree
				cmp r0, #0
				pop {r0-r3}

				bne snd32_sounddecode_error2

				mov mem_alloc, temp2

				cmp mode, #1
				bne snd32_sounddecode_main_wave_common

				/* For PWM Balanced Monoral */

				push {r0-r3}
				mov r0, temp
				bl heap32_mfree
				cmp r0, #0
				pop {r0-r3}

				bne snd32_sounddecode_error2

				b snd32_sounddecode_main_wave_common

			snd32_sounddecode_main_wave_pcm:

				push {r0-r3}
				mov r0, mem_alloc                         @ Words
				cmp mode, #2
				moveq r1, #0
				movne r1, #1
				bl heap32_mpack
				cmp r0, #0
				pop {r0-r3}

				bne snd32_sounddecode_error2

			snd32_sounddecode_main_wave_common:

				push {r0-r3}
				mov r0, mem_alloc
				mov r1, #1                                @ Clean
				bl arm32_cache_operation_heap
				pop {r0-r3}

				push {r0-r6}
				mov r0, cb
				mov r3, #equ32_bus_peripherals_base
				cmp mode, #2
				movlo r1, #5<<equ32_dma_ti_permap                       @ DREQ Map for PWM
				addlo r3, r3, #equ32_pwm_base_lower
				addlo r3, r3, #equ32_pwm_base_upper
				addlo r3, r3, #equ32_pwm_fif1                           @ Destination Address for PWM
				movhs r1, #2<<equ32_dma_ti_permap                       @ DREQ Map for PCM Transmit
				addhs r3, r3, #equ32_pcm_base_lower
				addhs r3, r3, #equ32_pcm_base_upper
				addhs r3, r3, #equ32_pcm_fifo                           @ Destination Address for PCM Transmit
				bic r1, r1, #equ32_dma_ti_no_wide_bursts
				orr r1, r1, #0<<equ32_dma_ti_waits
				orr r1, r1, #0<<equ32_dma_ti_burst_length
				orr r1, r1, #equ32_dma_ti_src_inc|equ32_dma_ti_dst_dreq @ Transfer Information
				orr r1, r1, #equ32_dma_ti_wait_resp
				add r2, mem_alloc, #equ32_bus_coherence_base            @ Source Address
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

			.unreq cb
			temp4 .req r10

			b snd32_sounddecode_main

	snd32_sounddecode_error1:
		mov r0, #1                                 @ Return with Error 1
		b snd32_sounddecode_common

	snd32_sounddecode_error2:
		mov r0, #2                                 @ Return with Error 2
		b snd32_sounddecode_common

	snd32_sounddecode_success:

		/* Store Null (End of Sequence of Music Code) in Current Music Code for Sound Play */
		mov temp, #0xFF00
		orr temp, temp, #0x00FF
		str temp, SND32_CURRENTCODE

		/* Set Base Divisor on Modulation */
		ldr temp2, SND32_DIVISOR_ADDR
		cmp mode, #2
		ldrlo temp, SND32_NEUTRALDIV_PWM
		ldrhs temp, SND32_NEUTRALDIV_PCM
		str temp, [temp2]

		/* Maximum Frequency on Modulation, Same as Divisor */
		ldr temp2, SND32_MODULATION_MAX_ADDR
		str temp, [temp2]

		/* Minimum Frequency on Modulation, Same as Divisor */
		ldr temp2, SND32_MODULATION_MIN_ADDR
		str temp, [temp2]

		/* Range of Frequencies on Modulation */
		mov temp, #equ32_snd32_range
		cmp mode, #2
		movlo temp2, #equ32_snd32_mul_pwm
		movhs temp2, #equ32_snd32_mul_pcm
		mul temp, temp, temp2
		ldr temp2, SND32_MODULATION_RANGE_ADDR
		str temp, [temp2]

		ldr temp, SND32_STATUS
		orr temp, temp, #0x80000000
		str temp, SND32_STATUS

		macro32_dsb ip
		mov r0, #0                                 @ Return with Success

	snd32_sounddecode_common:
		pop {r4-r11,pc}                            @ Style of Enter/Return (2017 Winter)

.unreq snd_index
.unreq mode
.unreq temp3
.unreq i
.unreq temp
.unreq wave_length
.unreq wave_volume
.unreq wave_type
.unreq mem_alloc
.unreq temp2
.unreq temp4
.unreq size_cb


/**
 * function snd32_soundclear
 * Clear Music Code
 * This function is also used for PWM mode to initially set voltage bias to speaker, line, etc.
 *
 * Parameters
 * r0: 0 as PWM Mode, 1 as PCM Mode
 *
 * Return: r0 (0 as success)
 */
.globl snd32_soundclear
snd32_soundclear:
	/* Auto (Local) Variables, but just Aliases */
	mode   .req r0
	status .req r1
	temp   .req r2
	temp2  .req r3

	push {lr}

	mov temp, #0

	str temp, SND32_CODE

	macro32_dsb ip

	str temp, SND32_LENGTH
	str temp, SND32_COUNT
	str temp, SND32_REPEAT

	ldr status, SND32_STATUS

	cmp mode, #0
	bne snd32_soundclear_pcm

	/* PWM Mode */

	/* Store Silence Code in Current Music Code for Sound Play */
	mov temp, #equ32_snd32_silence
	str temp, SND32_CURRENTCODE

	tst status, #0x1                 @ Check Started Bit[0]
	bne snd32_soundclear_pwmcontinue

	/* First on PWM Mode */

	push {r0-r3}
	mov r0, #equ32_dma32_channel_snd32
	bl dma32_clear_channel
	pop {r0-r3}

	push {r0-r3}
	mov r0, #equ32_dma32_channel_snd32
	mov r1, #equ32_snd32_silence      @ Silence for Bias Voltage
	bl dma32_set_channel
	pop {r0-r3}

	orr status, status, #0x1

	b snd32_soundclear_modulation

	snd32_soundclear_pwmcontinue:
		/* Continue on PWM Mode */
		push {r0-r3}
		mov r0, #equ32_dma32_channel_snd32
		mov r1, #equ32_snd32_silence      @ Silence for Bias Voltage
		bl dma32_change_nextcb
		pop {r0-r3}

		b snd32_soundclear_modulation

	snd32_soundclear_pcm:
		/* PCM Mode */
		push {r0-r3}
		mov r0, #equ32_dma32_channel_snd32
		bl dma32_clear_channel
		pop {r0-r3}

		/* Store Null (End of Sequence of Music Code) in Current Music Code for Sound Play */
		mov temp, #0xFF00
		orr temp, temp, #0x00FF
		str temp, SND32_CURRENTCODE

		bic status, status, #0x1                          @ Clear Started Bit[0]

	snd32_soundclear_modulation:
		/* Set Base Divisor on Modulation */
		ldr temp2, SND32_DIVISOR_ADDR
		cmp mode, #0
		ldreq temp, SND32_NEUTRALDIV_PWM
		ldrne temp, SND32_NEUTRALDIV_PCM
		str temp, [temp2]

		/* Maximum Frequency on Modulation, Same as Divisor */
		ldr temp2, SND32_MODULATION_MAX_ADDR
		str temp, [temp2]

		/* Minimum Frequency on Modulation, Same as Divisor */
		ldr temp2, SND32_MODULATION_MIN_ADDR
		str temp, [temp2]

		bic status, status, #0x2                          @ Clear Interrupt State Bit[1]
		str status, SND32_STATUS

	snd32_soundclear_success:
		macro32_dsb ip
		mov r0, #0                            @ Return with Success

	snd32_soundclear_common:
		pop {pc}

.unreq mode
.unreq status
.unreq temp
.unreq temp2


/**
 * function snd32_soundplay
 * Play Sound
 *
 * Parameters
 * r0: 0 as PWM Mode, 1 as PCM Mode
 *
 * Return: r0 (0 as success, 1, 2, and 3 as error)
 * Error(1): Music Code is Not Assgined
 * Error(2): Not Initialized
 * Error(3): MIDI Note On
 */
.globl snd32_soundplay
snd32_soundplay:
	/* Auto (Local) Variables, but just Aliases */
	mode        .req r0 @ Register for Result, Scratch Register
	addr_code   .req r1 @ Scratch Register
	length      .req r2 @ Scratch Register
	count       .req r3 @ Scratch Register
	repeat      .req r4
	status      .req r5
	code        .req r6
	temp        .req r7
	temp2       .req r8

	push {r4-r8,lr}

	ldr addr_code, SND32_CODE
	cmp addr_code, #0
	beq snd32_soundplay_error1

	ldr length, SND32_LENGTH
	cmp length, #0
	beq snd32_soundplay_error1

	ldr count, SND32_COUNT
	ldr repeat, SND32_REPEAT
	ldr status, SND32_STATUS

	macro32_dsb ip

	tst status, #0x80000000                   @ If Not Initialized
	beq snd32_soundplay_error2

	tst status, #0x00000004
	bne snd32_soundplay_error3                @ If MIDI Note On

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

		macro32_dsb ip

		tst status, #0x1
		bne snd32_soundplay_continue               @ If Continue of Music Code

		.unreq addr_code
		temp4 .req r1

	snd32_soundplay_first:

		push {r0-r3}
		mov r0, #equ32_dma32_channel_snd32
		bl dma32_clear_channel
		pop {r0-r3}

		push {r0-r3}
		mov r0, #equ32_dma32_channel_snd32
		mov r1, code
		bl dma32_set_channel
		pop {r0-r3}

		orr status, status, #0x1
		str code, SND32_CURRENTCODE

		b snd32_soundplay_tune

	snd32_soundplay_continue:
		ldr temp, SND32_CURRENTCODE
		cmp temp, code
		beq snd32_soundplay_countup

		push {r0-r3}
		mov r0, #equ32_dma32_channel_snd32
		mov r1, code
		bl dma32_change_nextcb
		pop {r0-r3}

		str code, SND32_CURRENTCODE

	snd32_soundplay_tune:

		/* Tune Tone */

		ldr temp, SND32_SOUND_ADJUST
		lsl temp2, code, #1                        @ Multiply by 2
		ldrh temp, [temp, temp2]                   @ Half Word
		cmp mode, #0
		moveq temp2, #equ32_snd32_mul_pwm
		movne temp2, #equ32_snd32_mul_pcm
		mul temp, temp, temp2

		/* Current Pitch Bend */
		ldr temp4, SND32_SOUNDMIDI_PITCHBEND
		sub temp, temp, temp4                      @ Subtract Pitch Bend Ratio to Neutral Divisor (Upside Down)

		push {r0-r3}
		cmp mode, #0
		moveq r0, #equ32_cm_pwm
		movne r0, #equ32_cm_pcm
		mov r1, temp
		bl arm32_clockmanager_divisor
		pop {r0-r3}

		cmp code, #equ32_snd32_silence

		.unreq code
		temp3 .req r6

		/* Set Base Divisor on Modulation */
		ldr temp2, SND32_DIVISOR_ADDR
		str temp, [temp2]

		beq snd32_soundplay_tune_silence           @ If Silence

		/* Frequency Range on Modulation */
		ldr temp3, SND32_MODULATION_RANGE_ADDR
		ldr temp3, [temp3]

		/* Maximum Frequency on Modulation */
		add temp4, temp, temp3
		ldr temp2, SND32_MODULATION_MAX_ADDR
		str temp4, [temp2]

		/* Minimum Frequency on Modulation */
		sub temp4, temp, temp3
		ldr temp2, SND32_MODULATION_MIN_ADDR
		str temp4, [temp2]

		b snd32_soundplay_countup

		snd32_soundplay_tune_silence:

			/* Maximum Frequency on Modulation, Same as Divisor */
			ldr temp2, SND32_MODULATION_MAX_ADDR
			str temp, [temp2]

			/* Minimum Frequency on Modulation, Same as Divisor */
			ldr temp2, SND32_MODULATION_MIN_ADDR
			str temp, [temp2]

	snd32_soundplay_countup:

		/* Count Up */

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

		mov temp4, #0

		str temp4, SND32_CODE
		str temp4, SND32_LENGTH
		str count, SND32_COUNT                     @ count is Already Zero
		str repeat, SND32_REPEAT                   @ repeat is Already Zero

		cmp mode, #0
		bne snd32_soundplay_free_pcm

		/* PWM Mode */
		push {r0-r3}
		mov r0, #equ32_dma32_channel_snd32
		mov r1, #equ32_snd32_silence               @ Silence for Bias Voltage
		bl dma32_change_nextcb
		pop {r0-r3}

		/* Store Silence Code in Current Music Code for Sound Play */
		mov temp, #equ32_snd32_silence
		str temp, SND32_CURRENTCODE

		b snd32_soundplay_free_modulation

		snd32_soundplay_free_pcm:
			bic status, status, #0x1                   @ Clear Continue Bit[0]
			str status, SND32_STATUS

			/* PCM Mode */
			push {r0-r3}
			mov r0, #equ32_dma32_channel_snd32
			bl dma32_clear_channel
			pop {r0-r3}

			/* Store Null (End of Sequence of Music Code) in Current Music Code for Sound Play */
			mov temp, #0xFF00
			orr temp, temp, #0x00FF
			str temp, SND32_CURRENTCODE

		snd32_soundplay_free_modulation:

			/* Set Base Divisor on Modulation */
			ldr temp2, SND32_DIVISOR_ADDR
			cmp mode, #0
			ldreq temp, SND32_NEUTRALDIV_PWM
			ldrne temp, SND32_NEUTRALDIV_PCM
			str temp, [temp2]

			/* Maximum Frequency on Modulation, Same as Divisor */
			ldr temp2, SND32_MODULATION_MAX_ADDR
			str temp, [temp2]

			/* Minimum Frequency on Modulation, Same as Divisor */
			ldr temp2, SND32_MODULATION_MIN_ADDR
			str temp, [temp2]

			b snd32_soundplay_error1

		snd32_soundplay_free_interrupt:
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

				push {r1-r3}
				bl snd32_soundplay                         @ Execute Itself
				pop {r1-r3}

				b snd32_soundplay_common

	snd32_soundplay_error1:
		mov r0, #1                            @ Return with Error 1
		b snd32_soundplay_common

	snd32_soundplay_error2:
		mov r0, #2                            @ Return with Error 2
		b snd32_soundplay_common

	snd32_soundplay_error3:
		mov r0, #3                            @ Return with Error 3
		b snd32_soundplay_common

	snd32_soundplay_success:
		macro32_dsb ip
		mov r0, #0                            @ Return with Success

	snd32_soundplay_common:
		pop {r4-r8,pc}

.unreq mode
.unreq temp4
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
 * r0: Pointer of Music Code
 * r1: Length
 * r2: Count (Offset)
 * r3: Number of Repeat, If -1, Infinite Loop
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Failure of Setting (Pointer of Music Code is Addressed to Zero or Length is Zero)
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

	cmp addr_code, #0
	beq snd32_soundset_error
	cmp length, #0
	beq snd32_soundset_error

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

	b snd32_soundset_success

	snd32_soundset_error:
		mov r0, #1
		b snd32_soundset_common

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
 * r0: Pointer of Music Code
 * r1: Length
 * r2: Count (Offset)
 * r3: Number of Repeat, If -1, Infinite Loop
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): Failure of Setting (Pointer of Music Code is Addressed to Zero or Length is Zero)
 * Error(2): Main Sound Has Not Been Set
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

	cmp addr_code, #0
	beq snd32_soundinterrupt_error1
	cmp length, #0
	beq snd32_soundinterrupt_error1

	ldr temp, SND32_STATUS
	tst temp, #0x2
	bne snd32_soundinterrupt_already

	mov temp, #0

	ldr temp2, SND32_CODE
	cmp temp2, #0
	beq snd32_soundinterrupt_error2
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

	snd32_soundinterrupt_error1:
		mov r1, #1
		b snd32_soundinterrupt_common        @ Return with Error 1

	snd32_soundinterrupt_error2:
		mov r1, #2
		b snd32_soundinterrupt_common        @ Return with Error 2

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
 * function snd32_soundinit_pwm
 * Sound Initializer for PWM Mode
 *
 * Parameters
 * r0: 0 as GPIO 12/13 PWM, 1 as GPIO 40/45(41) PWM, 2 as Both
 *
 * Return: r0 (0 as Success)
 */
.globl snd32_soundinit_pwm
snd32_soundinit_pwm:
	/* Auto (Local) Variables, but just Aliases */
	memorymap_base    .req r0
	value             .req r1
	gpio_set          .req r2

	push {lr}

	mov gpio_set, memorymap_base

	/**
	 * GPIO for PWM
	 */
	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_gpio_base

	cmp gpio_set, #0
	cmpne gpio_set, #2

	ldr value, [memorymap_base, #equ32_gpio_gpfsel10]
	bic value, value, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_2    @ Clear GPIO 12
	orreq value, value, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_2   @ Set GPIO 12 PWM0
	bic value, value, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_3    @ Clear GPIO 13
	orreq value, value, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_3   @ Set GPIO 13 PWM1
	str value, [memorymap_base, #equ32_gpio_gpfsel10]

	cmp gpio_set, #1
	cmpne gpio_set, #2

	ldr value, [memorymap_base, #equ32_gpio_gpfsel40]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_0          @ Clear GPIO 40
	orreq r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_0         @ Set GPIO 40 PWM0 (to Minijack)
.ifdef __RASPI3B
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_1          @ Clear GPIO 41
	orreq r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_1         @ Set GPIO 41 PWM1 (to Minijack)
.else
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_5          @ Clear GPIO 45
	orreq r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_5         @ Set GPIO 45 PWM1 (to Minijack)
.endif
	str value, [memorymap_base, #equ32_gpio_gpfsel40]

	macro32_dsb ip

	/**
	 * Clock Manager for PWM.
	 * Makes Appx. 39.6Mhz (From PLLD). 500Mhz Div by 12.6259765625 Equals Appx. 39.6Mhz.
	 */
	push {r0-r3}
	mov r0, #equ32_cm_pwm
	mov r1, #equ32_cm_ctl_mash_1
	add r1, r1, #equ32_cm_ctl_enab|equ32_cm_ctl_src_plld            @ 500Mhz
	mov r2, #0xC<<equ32_cm_div_integer
	orr r2, r2, #0xA00<<equ32_cm_div_fraction                       @ 0.6259765625 * 4096, Decimal 2564
	orr r2, r2, #0x004<<equ32_cm_div_fraction                       @ 0.6259765625 * 4096, Decimal 2564
	bl arm32_clockmanager
	pop {r0-r3}

	/**
	 * PWM Enable
	 */
	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_pwm_base_lower
	add memorymap_base, memorymap_base, #equ32_pwm_base_upper

	/**
	 * 39.6Mhz Div By 1250 Equals 31680hz.
	 * Sampling Rate 31680hz, Bit Depth 10bit (Range is 1250, but Is Actually 1024).
	 */
	mov value, #0x0400
	orr value, value, #0x00E2
	str value, [memorymap_base, #equ32_pwm_rng1]
	str value, [memorymap_base, #equ32_pwm_rng2]

	mov value, #equ32_pwm_dmac_enable
	orr value, value, #11<<equ32_pwm_dmac_panic
	orr value, value, #7<<equ32_pwm_dmac_dreq
	str value, [memorymap_base, #equ32_pwm_dmac]

	mov value, #equ32_pwm_ctl_msen1|equ32_pwm_ctl_clrf1|equ32_pwm_ctl_usef1|equ32_pwm_ctl_pwen1
	orr value, value, #equ32_pwm_ctl_msen2|equ32_pwm_ctl_usef2|equ32_pwm_ctl_pwen2
	str value, [memorymap_base, #equ32_pwm_ctl]

	macro32_dsb ip

	snd32_soundinit_pwm_common:
		mov r0, #0
		pop {pc}

.unreq memorymap_base
.unreq value
.unreq gpio_set


/**
 * function snd32_soundinit_i2s
 * Sound Initializer for I2S Mode (Outputs Both L and R Side by 32Khz)
 *
 * Return: r0 (0 as Success)
 */
.globl snd32_soundinit_i2s
snd32_soundinit_i2s:
	/* Auto (Local) Variables, but just Aliases */
	memorymap_base    .req r0
	value             .req r1

	push {lr}

	/**
	 * GPIO for PCM
	 */
	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_gpio_base

	ldr value, [memorymap_base, #equ32_gpio_gpfsel10]
	bic value, value, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_8    @ Clear GPIO 18
	orr value, value, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_8     @ Set GPIO 18 PCM_CLK
	bic value, value, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_9    @ Clear GPIO 19
	orr value, value, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_9     @ Set GPIO 19 PCM_FS
	str value, [memorymap_base, #equ32_gpio_gpfsel10]

	/* GPIO 20 can be set to PCM_DIN, but No Use */
	ldr value, [memorymap_base, #equ32_gpio_gpfsel20]
	bic value, value, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_1    @ Clear GPIO 21
	orr value, value, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_1     @ Set GPIO 21 PCM_DOUT
	str value, [memorymap_base, #equ32_gpio_gpfsel20]

	macro32_dsb ip

	/**
	 * Clock Manager for PCM Clock.
	 * Makes 19.2Mhz (From Oscillator). Div by 18.75 Equals 1.024Mhz (Same as PWM Output).
	 * Makes 19.2Mhz (From Oscillator). Div by 18.93896484375 Equals 1.01378296852Mhz (Adjusted).
	 */
	push {r0-r3}
	mov r0, #equ32_cm_pcm
	mov r1, #equ32_cm_ctl_mash_1
	add r1, r1, #equ32_cm_ctl_enab|equ32_cm_ctl_src_osc            @ 19.2Mhz
	mov r2, #18<<equ32_cm_div_integer
	/*orr r2, r2, #3072<<equ32_cm_div_fraction*/                       @ 0.75 * 4096
	orr r2, r2, #0xF00<<equ32_cm_div_fraction                      @ 0.93896484375 * 4096 Equals 3846 (0xF06)
	orr r2, r2, #0x006<<equ32_cm_div_fraction                      @ 0.93896484375 * 4096 Equals 3846 (0xF06)
	bl arm32_clockmanager
	pop {r0-r3}

	/**
	 * PCM Enable
	 */
	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_pcm_base_lower
	add memorymap_base, memorymap_base, #equ32_pcm_base_upper

	mov value, #equ32_pcm_cs_en
	str value, [memorymap_base, #equ32_pcm_cs]

	macro32_dsb ip

	/* Make I2S Compatible LRCLK/WCLK by 16-bit Depth on Both L and R */
	mov value, #31<<equ32_pcm_mode_flen
	orr value, value, #16<<equ32_pcm_mode_fslen
	orr value, value, #equ32_pcm_mode_clki|equ32_pcm_mode_fsi @ Invert Clock and Frame Sync
	str value, [memorymap_base, #equ32_pcm_mode]

	/* Channel 1 */
	mov value, #equ32_pcm_rtxc_ch1en|equ32_pcm_rtxc_ch1wex        @ 32 Bits for Outputs Both L and R
	orr value, value, #1<<equ32_pcm_rtxc_ch1pos                   @ Make Sure Offset 1 Bit from Frame Sync to Fit I2S Signal Regulation
	orr value, value, #8<<equ32_pcm_rtxc_ch1wid
	str value, [memorymap_base, #equ32_pcm_txc]

	/* DMA DREQ Settings */
	orr value, value, #23<<equ32_pcm_dreq_tx_panic
	orr value, value, #15<<equ32_pcm_dreq_tx_dreq
	str value, [memorymap_base, #equ32_pcm_dreq]

	/* Clear TxFIFO, Two PCM Clocks Are Needed */
	ldr value, [memorymap_base, #equ32_pcm_cs]
	orr value, value, #equ32_pcm_cs_txclr
	orr value, value, #equ32_pcm_cs_sync
	str value, [memorymap_base, #equ32_pcm_cs]

	macro32_dsb ip

	snd32_soundinit_i2s_clrtxf:
		ldr value, [memorymap_base, #equ32_pcm_cs]
		tst value, #equ32_pcm_cs_sync
		beq snd32_soundinit_i2s_clrtxf

	/* Clear RxFIFO, No need of Clear RxFIFO, but RAM Preperation Needs Four PCM Clocks */
	ldr value, [memorymap_base, #equ32_pcm_cs]
	orr value, value, #equ32_pcm_cs_rxclr
	orr value, value, #equ32_pcm_cs_sync
	str value, [memorymap_base, #equ32_pcm_cs]

	macro32_dsb ip

	snd32_soundinit_i2s_clrrxf:
		ldr value, [memorymap_base, #equ32_pcm_cs]
		tst value, #equ32_pcm_cs_sync
		beq snd32_soundinit_i2s_clrrxf

	/* DMA and PCM Transmit Enable */
	bic value, value, #equ32_pcm_cs_sync
	orr value, value, #equ32_pcm_cs_dmaen
	orr value, value, #equ32_pcm_cs_txon
	str value, [memorymap_base, #equ32_pcm_cs]

	macro32_dsb ip

	snd32_soundinit_i2s_common:
		mov r0, #0
		pop {pc}

.unreq memorymap_base
.unreq value


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
 * function snd32_soundmidi
 * MIDI Handler
 * Use this function in UART interrupt.
 * This sound generater is monophonic. MIDI channel number in messages is detectable.
 *
 * Parameters
 * r0: Channel, 0-15 (MIDI Channel No. 1 to 16)
 * r1: 0 as PWM Mode, 1 as PCM Mode
 *
 * Return: r0 (0 as success, 1, 2, and 3 as error)
 * Error(1): Not Initialized on snd32_sounddecode, No Buffer to Receive on UART, or UART Overrun
 * Error(2): Character Is Not Received
 * Error(3): MIDI Channel is Not Matched, or Only Data Bytes Received
 */
.globl snd32_soundmidi
snd32_soundmidi:
	/* Auto (Local) Variables, but just Aliases */
	channel       .req r0
	mode          .req r1
	buffer        .req r2
	count         .req r3
	max_size      .req r4
	bytebuffer    .req r5
	byte          .req r6
	temp          .req r7
	data1         .req r8
	data2         .req r9
	status        .req r10

	push {r4-r10,lr}

	ldr status, SND32_STATUS
	ldr count, SND32_SOUNDMIDI_COUNT
	ldr max_size, SND32_SOUNDMIDI_LENGTH
	ldr buffer, SND32_SOUNDMIDI_BUFFER

	tst status, #0x80000000           @ If Not Initialized
	beq snd32_soundmidi_error1

	cmp buffer, #0
	beq snd32_soundmidi_error1        @ If No Buffer

	ldr bytebuffer, SND32_SOUNDMIDI_BYTEBUFFER

	push {r0-r3}
	mov r0, bytebuffer
	mov r1, #1                        @ 1 Bytes
	bl uart32_uartrx
	mov temp, r0                      @ Whether Overrun or Not
	pop {r0-r3}

	tst temp, #0x8                    @ Whether Overrun or Not
	bne snd32_soundmidi_error1        @ If Overrun

	tst temp, #0x10                   @ Whether Not Received or So
	bne snd32_soundmidi_error2        @ If Not Received

	/* Check Whether Status or Data Bytes */
	ldrb byte, [bytebuffer]

	tst byte, #0x80
	bne snd32_soundmidi_status

	/* Check Whether Only Data Bytes (Status Is For Other Channels, etc.) */
	cmp count, #0
	beq snd32_soundmidi_error3

	/* Data Bytes */
	strb byte, [buffer,count]

	/* Slide Offset Count */
	add count, count, #1
	cmp count, max_size
	subge count, max_size, #1         @ If Exceeds Maximum Size of Heap, Stay Count

	.unreq max_size
	temp2 .req r4

	/* Check Message Type and Procedures for Each Message */
	ldrb temp, [buffer]
	ldrb data1, [buffer, #1]
	ldrb data2, [buffer, #2]
	cmp temp, #0x8
	beq snd32_soundmidi_noteoff           @ Velocity is Ignored
	cmp temp, #0x9
	beq snd32_soundmidi_noteon
	cmp temp, #0xA
	beq snd32_soundmidi_polyaftertouch    @ Polyphonic Key Pressure
	cmp temp, #0xB
	beq snd32_soundmidi_control
	cmp temp, #0xC
	beq snd32_soundmidi_programchange
	cmp temp, #0xD
	beq snd32_soundmidi_monoaftertouch    @ Monophonic Key Pressure
	cmp temp, #0xE
	beq snd32_soundmidi_pitchbend
	cmp temp, #0xF
	beq snd32_soundmidi_systemcommon

	b snd32_soundmidi_success

	snd32_soundmidi_noteoff:
		cmp count, #3
		blo snd32_soundmidi_success

		/* Load Concurrent Note, If Not Matched Do Nothing */
		ldr temp, SND32_SOUNDMIDI_CURRENTNOTE
		cmp data1, temp
		movne count, #0
		bne snd32_soundmidi_success

		/* If Note ADSR Model, Stay Note But Gate Off */
		mov temp, #0
		cmp temp, #equ32_snd32_soundmidi_adsr
		bne snd32_soundmidi_noteoff_common

		snd32_soundmidi_noteoff_pwm:
			cmp mode, #0
			bne snd32_soundmidi_noteoff_pcm

			/* PWM Mode */
			push {r0-r3}
			mov r0, #equ32_dma32_channel_snd32
			mov r1, #equ32_snd32_silence      @ Silence for Bias Voltage
			bl dma32_change_nextcb
			pop {r0-r3}

			/* Store Silence Code in Current Music Code for Sound Play */
			mov temp, #equ32_snd32_silence
			str temp, SND32_CURRENTCODE

			b snd32_soundmidi_noteoff_modulation

		snd32_soundmidi_noteoff_pcm:
			/* PCM Mode */
			push {r0-r3}
			mov r0, #equ32_dma32_channel_snd32
			bl dma32_clear_channel
			pop {r0-r3}

			/* Store Null (End of Sequence of Music Code) in Current Music Code for Sound Play */
			mov temp, #0xFF00
			orr temp, temp, #0x00FF
			str temp, SND32_CURRENTCODE

			bic status, status, #0x1

		snd32_soundmidi_noteoff_modulation:
			/* Set Base Divisor on Modulation */
			ldr temp2, SND32_DIVISOR_ADDR
			cmp mode, #0
			ldreq temp, SND32_NEUTRALDIV_PWM
			ldrne temp, SND32_NEUTRALDIV_PCM
			str temp, [temp2]

			/* Maximum Frequency on Modulation, Same as Divisor */
			ldr temp2, SND32_MODULATION_MAX_ADDR
			str temp, [temp2]

			/* Minimum Frequency on Modulation, Same as Divisor */
			ldr temp2, SND32_MODULATION_MIN_ADDR
			str temp, [temp2]

		snd32_soundmidi_noteoff_common:
			bic status, status, #0x00000004                   @ Clear MIDI Note On
			mov count, #0
			b snd32_soundmidi_success

	snd32_soundmidi_noteon:
		cmp count, #3
		blo snd32_soundmidi_success

		/* Store Concurrent Note */
		str data1, SND32_SOUNDMIDI_CURRENTNOTE

		/* If Velocity is Zero, Jump to Note Off Event */
		cmp data2, #0
		beq snd32_soundmidi_noteoff

		/* If Note Number Is Higher than Expected, Saturate with Highest Note */
		ldr temp, SND32_SOUNDMIDI_HIGHNOTE
		cmp data1, temp
		movhi data1, temp

		/* To Fit Sound Index, Subtract: If Note Number Is Lower than Expected, Complement It with Lowest Note */
		ldr temp, SND32_SOUNDMIDI_LOWNOTE
		cmp data1, temp
		movlo data1, temp
		sub data1, data1, temp

		/* Sound Type Offset */
		ldr temp, SND32_SOUNDMIDI_BASEOFFSET
		add data1, data1, temp

		/* Velocity to Volume Offset */
		mov temp, #equ32_snd32_soundmidi_volumethres
		mov temp2, data2
		mov data2, #equ32_snd32_soundmidi_volumesteps - 1 @ Key of Minimum Volume

		snd32_soundmidi_noteon_velocity:
			sub temp2, temp
			cmp temp2, #0
			subge data2, data2, #1
			bge snd32_soundmidi_noteon_velocity

		/* If Sined Minus, Stay Key of Maximum Volume */
		cmp data2, #0
		movlt data2, #0

		mov temp, #equ32_snd32_soundmidi_volumeoffset
		mul data2, data2, temp
		add data1, data1, data2                 @ Add Volume Offset to Note
/*
macro32_debug data1, 0, 88
*/
		tst status, #0x1
		bne snd32_soundmidi_noteon_continue     @ If Continue

		/* If First */

		push {r0-r3}
		mov r0, #equ32_dma32_channel_snd32
		bl dma32_clear_channel
		pop {r0-r3}

		push {r0-r3}
		mov r0, #equ32_dma32_channel_snd32
		mov r1, data1
		bl dma32_set_channel
		pop {r0-r3}

		orr status, status, #0x1

		b snd32_soundmidi_noteon_common

	snd32_soundmidi_noteon_continue:
		push {r0-r3}
		mov r0, #equ32_dma32_channel_snd32
		mov r1, data1
		bl dma32_change_nextcb
		pop {r0-r3}

	snd32_soundmidi_noteon_common:

		/* Store Current Music Code Translated from MIDI Note */
		str data1, SND32_CURRENTCODE

		/* Tune Tone */

		ldr temp, SND32_SOUND_ADJUST
		lsl temp2, data1, #1                              @ Multiply by 2
		ldrh temp, [temp, temp2]                          @ Half Word
		cmp mode, #0
		moveq temp2, #equ32_snd32_mul_pwm
		movne temp2, #equ32_snd32_mul_pcm
		mul temp, temp, temp2

		/* Current Pitch Bend */
		ldr data1, SND32_SOUNDMIDI_PITCHBEND

		sub temp, temp, data1                             @ Subtract Pitch Bend Ratio to Neutral Divisor (Upside Down)

		push {r0-r3}
		cmp mode, #0
		moveq r0, #equ32_cm_pwm
		movne r0, #equ32_cm_pcm
		mov r1, temp
		bl arm32_clockmanager_divisor
		pop {r0-r3}

		/* Set Base Divisor on Modulation */
		ldr temp2, SND32_DIVISOR_ADDR
		str temp, [temp2]

		/* Frequency Range on Modulation */
		ldr data1, SND32_MODULATION_RANGE_ADDR
		ldr data1, [data1]

		/* Maximum Frequency on Modulation */
		add data2, temp, data1
		ldr temp2, SND32_MODULATION_MAX_ADDR
		str data2, [temp2]

		/* Minimum Frequency on Modulation */
		sub data2, temp, data1
		ldr temp2, SND32_MODULATION_MIN_ADDR
		str data2, [temp2]

		orr status, status, #0x00000004                   @ Set MIDI Note On
/*
macro32_debug data1, 0, 112
*/
		mov count, #0
		b snd32_soundmidi_success

	snd32_soundmidi_polyaftertouch:
		cmp count, #3
		blo snd32_soundmidi_success

		mov count, #0
		b snd32_soundmidi_success

	snd32_soundmidi_control:
		cmp count, #3
		blo snd32_soundmidi_success

		cmp data1, #64
		bhs snd32_soundmidi_control_others
		cmp data1, #32
		bhs snd32_soundmidi_control_lsb

		/* Most Significant Bits */

		ldr temp, SND32_SOUNDMIDI_CTL
		and data1, data1, #0x1F                            @ Only Use 0 to 31
		lsl data1, data1, #1                               @ Multiply by 2 to Fit Half Word Align
		ldrh temp2, [temp, data1]
		bic temp2, #0x3F80                                 @ Bit[13:7]
		bic temp2, #0xC000                                 @ Clear Bit[15:14], Not Necessary
		orr data2, temp2, data2, lsl #7
		strh data2, [temp, data1]

		mov count, #0

		/**
		 * Immediate Changes Here
		 * Sending CC#1 to CC#31 Trigger to Change Each Parameter
		 */
		lsr data1, data1, #1                               @ Divide by 2
		cmp data1, #1
		beq snd32_soundmidi_control_modulation
		cmp data1, #16
		beq snd32_soundmidi_control_gp1                    @ Frequency Range (Interval) of Modulation
		cmp data1, #19
		beq snd32_soundmidi_control_gp4                    @ Virtual Parallel for Sequence of Music Code

		b snd32_soundmidi_success

		snd32_soundmidi_control_lsb:

			/* Least Significant Bits */

			ldr temp, SND32_SOUNDMIDI_CTL
			and data1, data1, #0x1F                            @ Only Use 0 to 31
			lsl data1, data1, #1                               @ Multiply by 2 to Fit Half Word Align
			ldrh temp2, [temp, data1]
			bic temp2, #0x7F                                   @ Bit[6:0]
			bic temp2, #0xC000                                 @ Clear Bit[15:14], Not Necessary
			orr data2, temp2, data2
			strh data2, [temp, data1]

			mov count, #0

			/**
			 * Immediate Changes Here
			 * Sending CC#1 to CC#31 Trigger to Change Each Parameter
			 */
			lsr data1, data1, #1                               @ Divide by 2
			cmp data1, #1
			beq snd32_soundmidi_control_modulation
			cmp data1, #16
			beq snd32_soundmidi_control_gp1                    @ Frequency Range (Interval) of Modulation
			cmp data1, #19
			beq snd32_soundmidi_control_gp4                    @ Virtual Parallel for Sequence of Music Code

			b snd32_soundmidi_success

		snd32_soundmidi_control_modulation:
			/* Incremental / Decremental Delta of Modulation */
			lsr data2, data2, #6                               @ Divide by 64, Resolution 16384 to 256
			cmp mode, #0
			moveq temp, #equ32_snd32_mul_pwm
			movne temp, #equ32_snd32_mul_pcm
			mul data2, data2, temp
			ldr temp, SND32_MODULATION_DELTA_ADDR
			str data2, [temp]
			b snd32_soundmidi_success

		snd32_soundmidi_control_gp1:
			/* Make Frequency Range (Interval) of Modulation */
			lsr data2, data2, #2                               @ Divide by 4, Resolution 16384 to 4096
			cmp mode, #0
			moveq temp, #equ32_snd32_mul_pwm
			movne temp, #equ32_snd32_mul_pcm
			mul data2, data2, temp
			ldr temp, SND32_MODULATION_RANGE_ADDR
			str data2, [temp]

			/* Check If Silence on Current Music Code*/
			ldr data1, SND32_CURRENTCODE                       @ Check Current Code
			cmp data1, #equ32_snd32_silence
			beq snd32_soundmidi_success                        @ If Silence

			/* Check If Null (End of Sequence) on Current Music Code */
			mov temp2, #0xFF00
			orr temp2, temp2, #0x00FF
			cmp data1, temp2
			beq snd32_soundmidi_success                        @ If Null

			/* Except Silence or Null (End of Sequence of Music Code), Immediately Change Frequency Range */

			/* Tune Tone */

			ldr temp, SND32_SOUND_ADJUST
			lsl temp2, data1, #1                               @ Multiply by 2
			ldrh temp, [temp, temp2]                           @ Half Word
			cmp mode, #0
			moveq temp2, #equ32_snd32_mul_pwm
			movne temp2, #equ32_snd32_mul_pcm
			mul temp, temp, temp2

			/* Current Pitch Bend */
			ldr data1, SND32_SOUNDMIDI_PITCHBEND

			sub temp, temp, data1                              @ Subtract Pitch Bend Ratio to Neutral Divisor (Upside Down)

			mov data1, data2

			/* Maximum Frequency on Modulation */
			add data2, temp, data1
			ldr temp2, SND32_MODULATION_MAX_ADDR
			str data2, [temp2]

			/* Minimum Frequency on Modulation */
			sub data2, temp, data1
			ldr temp2, SND32_MODULATION_MIN_ADDR
			str data2, [temp2]

			b snd32_soundmidi_success

		snd32_soundmidi_control_gp4:
			/* Virtual Parallel of Coconuts */
			lsr data2, data2, #7                               @ Use Only MSB[13:7]
			ldr temp, SND32_VIRTUAL_PARALLEL_ADDR
			str data2, [temp]
			b snd32_soundmidi_success

		snd32_soundmidi_control_others:

			mov count, #0
			b snd32_soundmidi_success

	snd32_soundmidi_programchange:
		cmp count, #2
		blo snd32_soundmidi_success

		ldr temp, SND32_SOUNDMIDI_CTL
		ldrh temp, [temp]                              @ Bank Select Bit[13:0]
		lsl temp, temp, #7                             @ Bit[20:7] (Bank Select)
		orr data1, data1, temp                         @ Bit[20:7] (Bank Select) or Bit[6:0] (data1)

		cmp data1, #0
		moveq data2, #equ32_snd32_soundmidi_sound0_baseoffset
		moveq temp, #equ32_snd32_soundmidi_sound0_lownote
		moveq temp2, #equ32_snd32_soundmidi_sound0_highnote

		cmp data1, #1
		moveq data2, #equ32_snd32_soundmidi_sound1_baseoffset
		moveq temp, #equ32_snd32_soundmidi_sound1_lownote
		moveq temp2, #equ32_snd32_soundmidi_sound1_highnote

		cmp data1, #2
		moveq data2, #equ32_snd32_soundmidi_sound2_baseoffset
		moveq temp, #equ32_snd32_soundmidi_sound2_lownote
		moveq temp2, #equ32_snd32_soundmidi_sound2_highnote

		cmp data1, #3
		moveq data2, #equ32_snd32_soundmidi_sound3_baseoffset
		moveq temp, #equ32_snd32_soundmidi_sound3_lownote
		moveq temp2, #equ32_snd32_soundmidi_sound3_highnote

		cmp data1, #4
		moveq data2, #equ32_snd32_soundmidi_sound4_baseoffset
		moveq temp, #equ32_snd32_soundmidi_sound4_lownote
		moveq temp2, #equ32_snd32_soundmidi_sound4_highnote

		cmp data1, #5
		movhs data2, #equ32_snd32_soundmidi_sound5_baseoffset
		movhs temp, #equ32_snd32_soundmidi_sound5_lownote
		movhs temp2, #equ32_snd32_soundmidi_sound5_highnote

		str data2, SND32_SOUNDMIDI_BASEOFFSET
		str temp, SND32_SOUNDMIDI_LOWNOTE
		str temp2, SND32_SOUNDMIDI_HIGHNOTE

		mov count, #0
		b snd32_soundmidi_success

	snd32_soundmidi_monoaftertouch:
		cmp count, #2
		blo snd32_soundmidi_success

		mov count, #0
		b snd32_soundmidi_success

	snd32_soundmidi_pitchbend:
		cmp count, #3
		blo snd32_soundmidi_success

		/* Concatenate Data1 and Data2, 0 to 16383, 8192 (0x2000) is Neutral */
		lsl data2, data2, #7                          @ MSB Bit[13:7]
		orr data1, data1, data2
		lsr data1, data1, #1                          @ Divisor of Resolution (This Case Divided by 2)
		sub data1, data1, #0x1000                     @ Neutral (8192 / 2) to 0, Make Signed Value

		cmp mode, #0
		moveq data2, #equ32_snd32_mul_pwm
		movne data2, #equ32_snd32_mul_pcm
		mul data1, data1, data2                       @ Multiply with Multiplier
		str data1, SND32_SOUNDMIDI_PITCHBEND

		/* Tune Tone */

		ldr temp, SND32_SOUND_ADJUST
		ldr temp2, SND32_CURRENTCODE
		lsl temp2, temp2, #1                          @ Multiply by 2
		ldrh temp, [temp, temp2]                      @ Half Word
		mul temp, temp, data2                         @ Multiply with Multiplier

		sub temp, temp, data1                         @ Subtract Pitch Bend Ratio to Neutral Divisor (Upside Down)

		push {r0-r3}
		cmp mode, #0
		moveq r0, #equ32_cm_pwm
		movne r0, #equ32_cm_pcm
		mov r1, temp
		bl arm32_clockmanager_divisor
		pop {r0-r3}

		/* Set Base Divisor on Modulation */
		ldr temp2, SND32_DIVISOR_ADDR
		str temp, [temp2]

		/* Make Frequency Range on Modulation */
		ldr data1, SND32_MODULATION_RANGE_ADDR
		ldr data1, [data1]

		/* Maximum Frequency on Modulation */
		add data2, temp, data1
		ldr temp2, SND32_MODULATION_MAX_ADDR
		str data2, [temp2]

		/* Minimum Frequency on Modulation */
		sub data2, temp, data1
		ldr temp2, SND32_MODULATION_MIN_ADDR
		str data2, [temp2]

		mov count, #0
		b snd32_soundmidi_success

	snd32_soundmidi_systemcommon:
		b snd32_soundmidi_success

	snd32_soundmidi_status:
		/* If 0b11111000 and Above, Jump to Event on System Real Time Messages */
		cmp byte, #248
		bhs snd32_soundmidi_systemrealtime

		bic temp, byte, #0xF0
		cmp temp, channel
		movne count, #0
		bne snd32_soundmidi_error2    @ If Channel Is Not Matched

		/* Channel Is Matched */
		lsr byte, byte, #4            @ Omit Channel Number
		strb byte, [buffer]
		mov count, #1
		b snd32_soundmidi_success

	snd32_soundmidi_systemrealtime:

		/* If Reset, Hook to Note Off Event */
		cmp byte, #255
		beq snd32_soundmidi_noteoff_pwm

		mov count, #0
		b snd32_soundmidi_success

	snd32_soundmidi_error1:
		push {r0-r3}
		bl uart32_uartclrrx           @ Clear RxFIFO
		pop {r0-r3}
		mov r0, #1
		b snd32_soundmidi_common

	snd32_soundmidi_error2:
		mov r0, #2
		b snd32_soundmidi_common

	snd32_soundmidi_error3:
		mov r0, #3
		b snd32_soundmidi_common

	snd32_soundmidi_success:
		mov r0, #0

	snd32_soundmidi_common:
		str status, SND32_STATUS
		str count, SND32_SOUNDMIDI_COUNT
		macro32_dsb ip
/*
macro32_debug_hexa buffer, 100, 100, 8
*/
		pop {r4-r10,pc}

.unreq channel
.unreq mode
.unreq buffer
.unreq count
.unreq temp2
.unreq bytebuffer
.unreq byte
.unreq temp
.unreq data1
.unreq data2
.unreq status

SND32_NEUTRALDIV_PWM:           .word equ32_snd32_neutraldiv_pwm
SND32_NEUTRALDIV_PCM:           .word equ32_snd32_neutraldiv_pcm
SND32_SOUNDMIDI_COUNT:          .word 0x00
SND32_SOUNDMIDI_LENGTH:         .word 0x00
SND32_SOUNDMIDI_BUFFER:         .word 0x00  @ Second Buffer to Store Outstanding MIDI Message
SND32_SOUNDMIDI_BYTEBUFFER:     .word _SND32_SOUNDMIDI_BYTEBUFFER
SND32_SOUNDMIDI_BASEOFFSET:     .word equ32_snd32_soundmidi_sound0_baseoffset
SND32_SOUNDMIDI_LOWNOTE:        .word equ32_snd32_soundmidi_sound0_lownote
SND32_SOUNDMIDI_HIGHNOTE:       .word equ32_snd32_soundmidi_sound0_highnote
SND32_SOUNDMIDI_CURRENTNOTE:    .word 0x00
SND32_SOUNDMIDI_PITCHBEND:      .word 0x00

SND32_SOUNDMIDI_CTL:            .word 0x00  @ Value List of Control Message, 32 Multiplied by 2 (Two Bytes Half Word), No. 0 to No. 31 of Control Change Message
SND32_VIRTUAL_PARALLEL_ADDR:    .word SND32_VIRTUAL_PARALLEL
SND32_DIVISOR_ADDR:             .word SND32_DIVISOR
SND32_MODULATION_DELTA_ADDR:    .word SND32_MODULATION_DELTA
SND32_MODULATION_MAX_ADDR:      .word SND32_MODULATION_MAX
SND32_MODULATION_MIN_ADDR:      .word SND32_MODULATION_MIN
SND32_MODULATION_RANGE_ADDR:    .word SND32_MODULATION_RANGE

.section	.data
_SND32_SOUNDMIDI_BYTEBUFFER:    .word 0x00  @ First Buffer to Receive A Byte from UART
.globl SND32_VIRTUAL_PARALLEL
SND32_VIRTUAL_PARALLEL:         .word 0x00  @ Emulate Parallel Inputs Through MIDI IN
.globl SND32_DIVISOR
SND32_DIVISOR:                  .word 0x00
.globl SND32_MODULATION_DELTA
SND32_MODULATION_DELTA:         .word 0x00
.globl SND32_MODULATION_MAX
SND32_MODULATION_MAX:           .word 0x00
.globl SND32_MODULATION_MIN
SND32_MODULATION_MIN:           .word 0x00
.globl SND32_MODULATION_RANGE
SND32_MODULATION_RANGE:         .word 0x00
.section	.library_system32


/**
 * function snd32_soundmidi_malloc
 * Make Buffer for Function, snd32_soundmidi
 *
 * Parameters
 * r0: Size of Buffer (Words)
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Memory Allocation Is Not Succeeded
 */
.globl snd32_soundmidi_malloc
snd32_soundmidi_malloc:
	/* Auto (Local) Variables, but just Aliases */
	words_buffer .req r0
	buffer       .req r1

	push {lr}

	/* Buffer to Receive MIDI Message */
	push {r0}
	bl heap32_malloc
	mov buffer, r0
	pop {r0}

	cmp buffer, #0
	beq snd32_soundmidi_malloc_error

	lsl words_buffer, words_buffer, #2             @ Multiply by 4
	sub words_buffer, words_buffer, #1             @ Subtract One Byte for Null Character
	str words_buffer, SND32_SOUNDMIDI_LENGTH
	str buffer, SND32_SOUNDMIDI_BUFFER
	mov words_buffer, #0
	str words_buffer, SND32_SOUNDMIDI_COUNT

	/* Buffer for Control Message No. 0 to No. 31 */
	push {r0}
	mov r0, #16                                    @ 16 Words Multiplied by 4 Bytes Equals 64 Bytes (2 Bytes Half Word * 32)
	bl heap32_malloc
	mov buffer, r0
	pop {r0}

	cmp buffer, #0
	beq snd32_soundmidi_malloc_error

	str buffer, SND32_SOUNDMIDI_CTL

	b snd32_soundmidi_malloc_success

	snd32_soundmidi_malloc_error:
		mov r0, #1
		b snd32_soundmidi_malloc_common

	snd32_soundmidi_malloc_success:
		mov r0, #0

	snd32_soundmidi_malloc_common:
		macro32_dsb ip
		pop {pc}

.unreq words_buffer
.unreq buffer


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

