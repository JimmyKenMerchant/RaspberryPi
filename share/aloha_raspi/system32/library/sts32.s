/**
 * sts32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * About Codes in This File:
 * These functions are aiming building a frequency modulation synthesizer by a software programmed for a central processing unit (CPU) and an output unit. As an output unit, this project uses a pulse width modulator (PWM) or a pulse code modulator (PCM).
 * On using PWM, the CPU calculates a form of a synthesized wave as binary data, and transmits it to PWM. PWM treats the form as an output of voltage. Differences of voltage of the form make sound wave through any speaker.
 * On using PCM, the CPU calculates a form of a synthesized wave as binary data, and transmits it to PCM. PCM sends the form to a digital to analogue converter (DAC). DAC treats the form as an output of voltage. Differences of voltage of the form make sound wave through any speaker.
 */

STS32_CODE:            .word 0x00 @ Pointer of Music Code, If End, Automatically Cleared
STS32_LENGTH:          .word 0x00 @ Length of Music Code, If End, Automatically Cleared
STS32_COUNT:           .word 0x00 @ Incremental Count, Once Music Code Reaches Last, This Value will Be Reset
STS32_REPEAT:          .word 0x00 @ -1 is Infinite Loop

/**
 * Bit[0] Not Started(0)/ Started (1)
 * Bit[1] Reserved
 * Bit[2] Reserved
 * Bit[3] Reserved
 * Bit[31] Not Initialized(0)/ Initialized(1)
 */
STS32_STATUS:          .word 0x00

STS32_SYNTHEWAVE_TIME:    .word 0x00 @ One Equals 1/sampling-rate Seconds
STS32_SYNTHEWAVE_FREQA_L: .word 0x00
STS32_SYNTHEWAVE_FREQB_L: .word 0x00
STS32_SYNTHEWAVE_MAGA_L:  .word 0x00
STS32_SYNTHEWAVE_MAGB_L:  .word 0x00
STS32_SYNTHEWAVE_FREQA_R: .word 0x00
STS32_SYNTHEWAVE_FREQB_R: .word 0x00
STS32_SYNTHEWAVE_MAGA_R:  .word 0x00
STS32_SYNTHEWAVE_MAGB_R:  .word 0x00
STS32_SYNTHEWAVE_LR:      .word 0x00 @ 0 as L, 1 as R

/**
 * Synthesizer Code is 64-bit Block consists two frequencies and magnitudes to Synthesize.
 * Bit[15-0] Frequency-A (Main): 0 to 65535 Hz
 * Bit[31-16] Magnitude-A: -32768 to 32767
 * Bit[47-32] Frequency-B (Sub): 0 to 65535 Hz
 * Bit[63-48] Magnitude-B: -32768 to 32767
 * The wave is synthesized the formula:
 * Amplitude on T = Magnitude-A * sin((T * (2Pi * Frequency-A)) + Magnitude-B * sin(T * (2Pi * Frequency-B))).
 * Where T is time (seconds); one is 1/sampling-rate seconds.
 * This type of synthesizers is named as "Frequency Modulation Synthesis" developed by John Chowning, and decorated the music world in the late 20th century.
 * 0x0 means End of Synthesizer Code.
 *
 * Synthesizer Code will be fetched by L/R alternatively.
 * If you line up four blocks, the first and the third block will be fetched by L, and the second and the fourth block will be fetched by R.
 */

/**
 * function sts32_synthewave_pwm
 * Make Synthesized Wave
 *
 * Return: r0 (0 as Success, 1 and 2 as Error)
 * Error(1): Not Started
 * Error(2): PCM FIFO is Full
 */
.globl sts32_synthewave_pwm
sts32_synthewave_pwm:
	/* Auto (Local) Variables, but just Aliases */
	memorymap_base .req r0
	time           .req r1
	temp           .req r2
	flag_lr        .req r3

	/* VFP Registers */
	vfp_temp       .req s0
	vfp_freq_a     .req s1
	vfp_freq_b     .req s2
	vfp_mag_a      .req s3
	vfp_mag_b      .req s4
	vfp_pi_double  .req s5
	vfp_samplerate .req s6
	vfp_time       .req s7
	vfp_divisor    .req s8

	push {lr}
	vpush {s0-s8}

	ldr temp, STS32_STATUS
	tst temp, #1
	beq sts32_synthewave_pwm_error1

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_pwm_base_lower
	add memorymap_base, memorymap_base, #equ32_pwm_base_upper

	ldr temp, [memorymap_base, #equ32_pwm_sta]
	tst temp, #equ32_pwm_sta_empt1
	beq sts32_synthewave_pwm_error2

	ldr time, STS32_SYNTHEWAVE_TIME
	vmov vfp_time, time
	vcvt.f32.u32 vfp_time, vfp_time

	mov temp, #32000
	vmov vfp_samplerate, temp
	vcvt.f32.u32 vfp_samplerate, vfp_samplerate
	ldr temp, sts32_synthewave_MATH32_PI_DOUBLE
	vldr vfp_pi_double, [temp]

	vldr vfp_divisor, sts32_synthewave_pwm_divisor

	ldr flag_lr, STS32_SYNTHEWAVE_LR
	tst flag_lr, #1
	bne sts32_synthewave_pwm_loop_r

	/**
	 * Amplitude on T = Magnitude-A * sin((T * (2Pi * Frequency-A)) + Magnitude-B * sin(T * (2Pi * Frequency-B))).
	 * Where T is time (seconds); one is 1/sampling-rate seconds.
	 */
	sts32_synthewave_pwm_loop:
		ldr temp, [memorymap_base, #equ32_pwm_sta]
		tst temp, #equ32_pwm_sta_empt1
		beq sts32_synthewave_pwm_success

		/* L Wave */

		vldr vfp_freq_a, STS32_SYNTHEWAVE_FREQA_L
		vcvt.f32.u32 vfp_freq_a, vfp_freq_a
		vldr vfp_freq_b, STS32_SYNTHEWAVE_FREQB_L
		vcvt.f32.u32 vfp_freq_b, vfp_freq_b
		vldr vfp_mag_a, STS32_SYNTHEWAVE_MAGA_L
		vcvt.f32.s32 vfp_mag_a, vfp_mag_a
		vldr vfp_mag_b, STS32_SYNTHEWAVE_MAGB_L
		vcvt.f32.s32 vfp_mag_b, vfp_mag_b

		vmul.f32 vfp_freq_a, vfp_freq_a, vfp_pi_double
		vmul.f32 vfp_freq_a, vfp_freq_a, vfp_time
		vdiv.f32 vfp_freq_a, vfp_freq_a, vfp_samplerate

		vmul.f32 vfp_freq_b, vfp_freq_b, vfp_pi_double
		vmul.f32 vfp_freq_b, vfp_freq_b, vfp_time
		vdiv.f32 vfp_freq_b, vfp_freq_b, vfp_samplerate

		/* Round Radian within 2Pi */
		vdiv.f32 vfp_temp, vfp_freq_b, vfp_pi_double
		vcvt.s32.f32 vfp_temp, vfp_temp
		vcvt.f32.s32 vfp_temp, vfp_temp
		vmul.f32 vfp_temp, vfp_temp, vfp_pi_double
		vsub.f32 vfp_freq_b, vfp_freq_b, vfp_temp

		push {r0-r3}
		vmov r0, vfp_freq_b
		bl math32_sin
		vmov vfp_freq_b, r0
		pop {r0-r3}

		vmul.f32 vfp_freq_b, vfp_freq_b, vfp_mag_b
		vadd.f32 vfp_freq_a, vfp_freq_a, vfp_freq_b

		/* Round Radian within 2Pi */
		vdiv.f32 vfp_temp, vfp_freq_a, vfp_pi_double
		vcvt.s32.f32 vfp_temp, vfp_temp
		vcvt.f32.s32 vfp_temp, vfp_temp
		vmul.f32 vfp_temp, vfp_temp, vfp_pi_double
		vsub.f32 vfp_freq_a, vfp_freq_a, vfp_temp

		push {r0-r3}
		vmov r0, vfp_freq_a
		bl math32_sin
		vmov vfp_freq_a, r0
		pop {r0-r3}

		vmul.f32 vfp_freq_a, vfp_freq_a, vfp_mag_a
		vdiv.f32 vfp_freq_a, vfp_freq_a, vfp_divisor
		vcvtr.s32.f32 vfp_freq_a, vfp_freq_a
		vmov temp, vfp_freq_a
		add temp, temp, #128
		str temp, [memorymap_base, #equ32_pwm_fif1]

		macro32_dsb ip

		mov flag_lr, #1

		/* R Wave */

		sts32_synthewave_pwm_loop_r:
			ldr temp, [memorymap_base, #equ32_pwm_sta]
			tst temp, #equ32_pwm_sta_empt1
			beq sts32_synthewave_pwm_success

			vldr vfp_freq_a, STS32_SYNTHEWAVE_FREQA_R
			vcvt.f32.u32 vfp_freq_a, vfp_freq_a
			vldr vfp_freq_b, STS32_SYNTHEWAVE_FREQB_R
			vcvt.f32.u32 vfp_freq_b, vfp_freq_b
			vldr vfp_mag_a, STS32_SYNTHEWAVE_MAGA_R
			vcvt.f32.s32 vfp_mag_a, vfp_mag_a
			vldr vfp_mag_b, STS32_SYNTHEWAVE_MAGB_R
			vcvt.f32.s32 vfp_mag_b, vfp_mag_b

			vmul.f32 vfp_freq_a, vfp_freq_a, vfp_pi_double
			vmul.f32 vfp_freq_a, vfp_freq_a, vfp_time
			vdiv.f32 vfp_freq_a, vfp_freq_a, vfp_samplerate

			vmul.f32 vfp_freq_b, vfp_freq_b, vfp_pi_double
			vmul.f32 vfp_freq_b, vfp_freq_b, vfp_time
			vdiv.f32 vfp_freq_b, vfp_freq_b, vfp_samplerate

			/* Round Radian within 2Pi */
			vdiv.f32 vfp_temp, vfp_freq_b, vfp_pi_double
			vcvt.s32.f32 vfp_temp, vfp_temp
			vcvt.f32.s32 vfp_temp, vfp_temp
			vmul.f32 vfp_temp, vfp_temp, vfp_pi_double
			vsub.f32 vfp_freq_b, vfp_freq_b, vfp_temp

			push {r0-r3}
			vmov r0, vfp_freq_b
			bl math32_sin
			vmov vfp_freq_b, r0
			pop {r0-r3}

			vmul.f32 vfp_freq_b, vfp_freq_b, vfp_mag_b
			vadd.f32 vfp_freq_a, vfp_freq_a, vfp_freq_b

			/* Round Radian within 2Pi */
			vdiv.f32 vfp_temp, vfp_freq_a, vfp_pi_double
			vcvt.s32.f32 vfp_temp, vfp_temp
			vcvt.f32.s32 vfp_temp, vfp_temp
			vmul.f32 vfp_temp, vfp_temp, vfp_pi_double
			vsub.f32 vfp_freq_a, vfp_freq_a, vfp_temp

			push {r0-r3}
			vmov r0, vfp_freq_a
			bl math32_sin
			vmov vfp_freq_a, r0
			pop {r0-r3}

			vmul.f32 vfp_freq_a, vfp_freq_a, vfp_mag_a
			vdiv.f32 vfp_freq_a, vfp_freq_a, vfp_divisor
			vcvtr.s32.f32 vfp_freq_a, vfp_freq_a
			vmov temp, vfp_freq_a
			add temp, temp, #128
			str temp, [memorymap_base, #equ32_pwm_fif1]

			macro32_dsb ip

			mov flag_lr, #0

			add time, time, #1
			vmov vfp_time, time
			vcvt.f32.u32 vfp_time, vfp_time
			b sts32_synthewave_pwm_loop

	sts32_synthewave_pwm_error1:
		mov r0, #1
		b sts32_synthewave_pwm_common

	sts32_synthewave_pwm_error2:
		mov r0, #2
		b sts32_synthewave_pwm_common

	sts32_synthewave_pwm_success:
		str time, STS32_SYNTHEWAVE_TIME
		str flag_lr, STS32_SYNTHEWAVE_LR
		mov r0, #0

	sts32_synthewave_pwm_common:
		vpop {s0-s8}
		pop {pc}

.unreq memorymap_base
.unreq time
.unreq temp
.unreq flag_lr
.unreq vfp_temp
.unreq vfp_freq_a
.unreq vfp_freq_b
.unreq vfp_mag_a
.unreq vfp_mag_b
.unreq vfp_pi_double
.unreq vfp_samplerate
.unreq vfp_time
.unreq vfp_divisor

sts32_synthewave_pwm_divisor: .float 256.0


/**
 * function sts32_synthewave_i2s
 * Make Synthesized Wave
 *
 * Return: r0 (0 as Success, 1 and 2 as Error)
 * Error(1): Not Started
 * Error(2): PCM FIFO is Full
 */
.globl sts32_synthewave_i2s
sts32_synthewave_i2s:
	/* Auto (Local) Variables, but just Aliases */
	memorymap_base .req r0
	time           .req r1
	temp           .req r2
	temp2          .req r3

	/* VFP Registers */
	vfp_temp       .req s0
	vfp_freq_a     .req s1
	vfp_freq_b     .req s2
	vfp_mag_a      .req s3
	vfp_mag_b      .req s4
	vfp_pi_double  .req s5
	vfp_samplerate .req s6
	vfp_time       .req s7

	push {lr}
	vpush {s0-s7}

	ldr temp, STS32_STATUS
	tst temp, #1
	beq sts32_synthewave_i2s_error1

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_pcm_base_lower
	add memorymap_base, memorymap_base, #equ32_pcm_base_upper

	ldr temp, [memorymap_base, #equ32_pcm_cs]
	tst temp, #equ32_pcm_cs_txw
	beq sts32_synthewave_i2s_error2

	ldr time, STS32_SYNTHEWAVE_TIME
	vmov vfp_time, time
	vcvt.f32.u32 vfp_time, vfp_time

	mov temp, #32000
	vmov vfp_samplerate, temp
	vcvt.f32.u32 vfp_samplerate, vfp_samplerate
	ldr temp, sts32_synthewave_MATH32_PI_DOUBLE
	vldr vfp_pi_double, [temp]


	/**
	 * Amplitude on T = Magnitude-A * sin((T * (2Pi * Frequency-A)) + Magnitude-B * sin(T * (2Pi * Frequency-B))).
	 * Where T is time (seconds); one is 1/sampling-rate seconds.
	 */
	sts32_synthewave_i2s_loop:
		ldr temp, [memorymap_base, #equ32_pcm_cs]
		tst temp, #equ32_pcm_cs_txw
		beq sts32_synthewave_i2s_success

		/* L Wave */

		vldr vfp_freq_a, STS32_SYNTHEWAVE_FREQA_L
		vcvt.f32.u32 vfp_freq_a, vfp_freq_a
		vldr vfp_freq_b, STS32_SYNTHEWAVE_FREQB_L
		vcvt.f32.u32 vfp_freq_b, vfp_freq_b
		vldr vfp_mag_a, STS32_SYNTHEWAVE_MAGA_L
		vcvt.f32.s32 vfp_mag_a, vfp_mag_a
		vldr vfp_mag_b, STS32_SYNTHEWAVE_MAGB_L
		vcvt.f32.s32 vfp_mag_b, vfp_mag_b

		vmul.f32 vfp_freq_a, vfp_freq_a, vfp_pi_double
		vmul.f32 vfp_freq_a, vfp_freq_a, vfp_time
		vdiv.f32 vfp_freq_a, vfp_freq_a, vfp_samplerate

		vmul.f32 vfp_freq_b, vfp_freq_b, vfp_pi_double
		vmul.f32 vfp_freq_b, vfp_freq_b, vfp_time
		vdiv.f32 vfp_freq_b, vfp_freq_b, vfp_samplerate

		/* Round Radian within 2Pi */
		vdiv.f32 vfp_temp, vfp_freq_b, vfp_pi_double
		vcvt.s32.f32 vfp_temp, vfp_temp
		vcvt.f32.s32 vfp_temp, vfp_temp
		vmul.f32 vfp_temp, vfp_temp, vfp_pi_double
		vsub.f32 vfp_freq_b, vfp_freq_b, vfp_temp

		push {r0-r3}
		vmov r0, vfp_freq_b
		bl math32_sin
		vmov vfp_freq_b, r0
		pop {r0-r3}

		vmul.f32 vfp_freq_b, vfp_freq_b, vfp_mag_b
		vadd.f32 vfp_freq_a, vfp_freq_a, vfp_freq_b

		/* Round Radian within 2Pi */
		vdiv.f32 vfp_temp, vfp_freq_a, vfp_pi_double
		vcvt.s32.f32 vfp_temp, vfp_temp
		vcvt.f32.s32 vfp_temp, vfp_temp
		vmul.f32 vfp_temp, vfp_temp, vfp_pi_double
		vsub.f32 vfp_freq_a, vfp_freq_a, vfp_temp

		push {r0-r3}
		vmov r0, vfp_freq_a
		bl math32_sin
		vmov vfp_freq_a, r0
		pop {r0-r3}

		vmul.f32 vfp_freq_a, vfp_freq_a, vfp_mag_a
		vcvtr.s32.f32 vfp_freq_a, vfp_freq_a
		vmov temp, vfp_freq_a

		/* R Wave */

		vldr vfp_freq_a, STS32_SYNTHEWAVE_FREQA_R
		vcvt.f32.u32 vfp_freq_a, vfp_freq_a
		vldr vfp_freq_b, STS32_SYNTHEWAVE_FREQB_R
		vcvt.f32.u32 vfp_freq_b, vfp_freq_b
		vldr vfp_mag_a, STS32_SYNTHEWAVE_MAGA_R
		vcvt.f32.s32 vfp_mag_a, vfp_mag_a
		vldr vfp_mag_b, STS32_SYNTHEWAVE_MAGB_R
		vcvt.f32.s32 vfp_mag_b, vfp_mag_b

		vmul.f32 vfp_freq_a, vfp_freq_a, vfp_pi_double
		vmul.f32 vfp_freq_a, vfp_freq_a, vfp_time
		vdiv.f32 vfp_freq_a, vfp_freq_a, vfp_samplerate

		vmul.f32 vfp_freq_b, vfp_freq_b, vfp_pi_double
		vmul.f32 vfp_freq_b, vfp_freq_b, vfp_time
		vdiv.f32 vfp_freq_b, vfp_freq_b, vfp_samplerate

		/* Round Radian within 2Pi */
		vdiv.f32 vfp_temp, vfp_freq_b, vfp_pi_double
		vcvt.s32.f32 vfp_temp, vfp_temp
		vcvt.f32.s32 vfp_temp, vfp_temp
		vmul.f32 vfp_temp, vfp_temp, vfp_pi_double
		vsub.f32 vfp_freq_b, vfp_freq_b, vfp_temp

		push {r0-r3}
		vmov r0, vfp_freq_b
		bl math32_sin
		vmov vfp_freq_b, r0
		pop {r0-r3}

		vmul.f32 vfp_freq_b, vfp_freq_b, vfp_mag_b
		vadd.f32 vfp_freq_a, vfp_freq_a, vfp_freq_b

		/* Round Radian within 2Pi */
		vdiv.f32 vfp_temp, vfp_freq_a, vfp_pi_double
		vcvt.s32.f32 vfp_temp, vfp_temp
		vcvt.f32.s32 vfp_temp, vfp_temp
		vmul.f32 vfp_temp, vfp_temp, vfp_pi_double
		vsub.f32 vfp_freq_a, vfp_freq_a, vfp_temp

		push {r0-r3}
		vmov r0, vfp_freq_a
		bl math32_sin
		vmov vfp_freq_a, r0
		pop {r0-r3}

		vmul.f32 vfp_freq_a, vfp_freq_a, vfp_mag_a
		vcvtr.s32.f32 vfp_freq_a, vfp_freq_a
		vmov temp2, vfp_freq_a

		bic temp, temp, #0xFF000000
		bic temp, temp, #0x00FF0000
		lsl temp2, temp2, #16
		orr temp, temp, temp2

		str temp, [memorymap_base, #equ32_pcm_fifo]

		macro32_dsb ip

		add time, time, #1
		vmov vfp_time, time
		vcvt.f32.u32 vfp_time, vfp_time
		b sts32_synthewave_i2s_loop

	sts32_synthewave_i2s_error1:
		mov r0, #1
		b sts32_synthewave_i2s_common

	sts32_synthewave_i2s_error2:
		mov r0, #2
		b sts32_synthewave_i2s_common

	sts32_synthewave_i2s_success:
		str time, STS32_SYNTHEWAVE_TIME
		mov r0, #0

	sts32_synthewave_i2s_common:
		vpop {s0-s7}
		pop {pc}

.unreq memorymap_base
.unreq time
.unreq temp
.unreq temp2
.unreq vfp_temp
.unreq vfp_freq_a
.unreq vfp_freq_b
.unreq vfp_mag_a
.unreq vfp_mag_b
.unreq vfp_pi_double
.unreq vfp_samplerate
.unreq vfp_time

sts32_synthewave_MATH32_PI_DOUBLE: .word MATH32_PI_DOUBLE


/**
 * function sts32_syntheset
 * Set Synthesizer
 *
 * Parameters
 * r0: Synthesizer Code
 * r1: Length
 * r2: Count (Offset)
 * r3: Number of Repeat, If -1, Infinite Loop
 *
 * Return: r0 (0 as success)
 */
.globl sts32_syntheset
sts32_syntheset:
	/* Auto (Local) Variables, but just Aliases */
	addr_code   .req r0 @ Register for Result, Scratch Register
	length      .req r1 @ Scratch Register
	count       .req r2 @ Scratch Register
	repeat      .req r3 @ Scratch Register
	temp        .req r4

	push {r4}

	mov temp, #0

	str temp, STS32_CODE       @ Reset to Prevent Odd Playing Sound

	macro32_dsb ip

	ldr temp, STS32_STATUS
	bic temp, temp, #0x1       @ Clear Bit[0]
	str temp, STS32_STATUS

	str length, STS32_LENGTH
	str count, STS32_COUNT
	str repeat, STS32_REPEAT

	macro32_dsb ip

	str addr_code, STS32_CODE  @ Should Set Music Code at End for Polling Functions, `sts32_syntheplay`

	sts32_syntheset_success:
		macro32_dsb ip
		mov r0, #0                                 @ Return with Success

	sts32_syntheset_common:
		pop {r4}
		mov pc, lr

.unreq addr_code
.unreq length
.unreq count
.unreq repeat
.unreq temp


/**
 * function sts32_syntheplay
 * Play Synthesizer
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): Music Code is Not Assgined
 * Error(2): Not Initialized
 */
.globl sts32_syntheplay
sts32_syntheplay:
	/* Auto (Local) Variables, but just Aliases */
	addr_code   .req r0
	length      .req r1
	count       .req r2
	repeat      .req r3
	status      .req r4
	code        .req r5
	temp        .req r6
	temp2       .req r7

	push {r4-r7,lr}

	ldr addr_code, STS32_CODE
	cmp addr_code, #0
	beq sts32_syntheplay_error1

	ldr length, STS32_LENGTH
	ldr count, STS32_COUNT
	ldr repeat, STS32_REPEAT
	ldr status, STS32_STATUS

	macro32_dsb ip

	tst status, #0x80000000                   @ If Not Initialized
	beq sts32_syntheplay_error2

	cmp count, length
	blo sts32_syntheplay_jump

	mov count, #0

	cmp repeat, #-1
	beq sts32_syntheplay_jump

	sub repeat, repeat, #1

	cmp repeat, #0
	beq sts32_syntheplay_free

	sts32_syntheplay_jump:
		lsl temp, count, #4                        @ Substitute of Multiplication by 16
		ldr code, [addr_code, temp]
		lsl temp, code, #16
		lsr temp, temp, #16
		str temp, STS32_SYNTHEWAVE_FREQA_L
		lsr temp, code, #16
		str temp, STS32_SYNTHEWAVE_MAGA_L

		lsl temp, count, #4                        @ Substitute of Multiplication by 16
		add temp, temp, #4
		ldr code, [addr_code, temp]
		lsl temp, code, #16
		lsr temp, temp, #16
		str temp, STS32_SYNTHEWAVE_FREQB_L
		lsr temp, code, #16
		str temp, STS32_SYNTHEWAVE_MAGB_L

		lsl temp, count, #4                        @ Substitute of Multiplication by 16
		add temp, temp, #8
		ldr code, [addr_code, temp]
		lsl temp, code, #16
		lsr temp, temp, #16
		str temp, STS32_SYNTHEWAVE_FREQA_R
		lsr temp, code, #16
		str temp, STS32_SYNTHEWAVE_MAGA_R

		lsl temp, count, #4                        @ Substitute of Multiplication by 8
		add temp, temp, #12
		ldr code, [addr_code, temp]
		lsl temp, code, #16
		lsr temp, temp, #16
		str temp, STS32_SYNTHEWAVE_FREQB_R
		lsr temp, code, #16
		str temp, STS32_SYNTHEWAVE_MAGB_R

		tst status, #0x1
		orreq status, status, #0x1

		add count, count, #1
		str count, STS32_COUNT
		str repeat, STS32_REPEAT
		str status, STS32_STATUS

		b sts32_syntheplay_success

	sts32_syntheplay_free:
		mov addr_code, #0
		mov length, #0
		bic status, status, #0x1                   @ Clear Bit[0]

		str addr_code, STS32_CODE
		str addr_code, STS32_SYNTHEWAVE_TIME        @ Reset Time
		str length, STS32_LENGTH
		str count, STS32_COUNT                     @ count is Already Zero
		str repeat, STS32_REPEAT                   @ repeat is Already Zero
		str status, STS32_STATUS

		b sts32_syntheplay_success

	sts32_syntheplay_error1:
		mov r0, #1                            @ Return with Error 1
		b sts32_syntheplay_common

	sts32_syntheplay_error2:
		mov r0, #2                            @ Return with Error 1
		b sts32_syntheplay_common

	sts32_syntheplay_success:
		macro32_dsb ip
		mov r0, #0                            @ Return with Success

	sts32_syntheplay_common:
		pop {r4-r7,pc}

.unreq addr_code
.unreq length
.unreq count
.unreq repeat
.unreq status
.unreq code
.unreq temp
.unreq temp2


/**
 * function sts32_syntheclear
 * Clear Synthesizer Code
 *
 * Return: r0 (0 as success)
 */
.globl sts32_syntheclear
sts32_syntheclear:
	/* Auto (Local) Variables, but just Aliases */
	temp   .req r0

	mov temp, #0

	str temp, STS32_CODE

	macro32_dsb ip

	str temp, STS32_SYNTHEWAVE_TIME            @ Reset Time

	str temp, STS32_LENGTH
	str temp, STS32_COUNT
	str temp, STS32_REPEAT

	ldr temp, STS32_STATUS
	bic temp, temp, #0x1                      @ Clear Bit[1]
	str temp, STS32_STATUS

	macro32_dsb ip

	sts32_syntheclear_success:
		macro32_dsb ip
		mov r0, #0                            @ Return with Success

	sts32_syntheclear_common:
		mov pc, lr

.unreq temp


/**
 * function sts32_synthelen
 * Count 4-Bytes Beats of Synthesizer Code
 *
 * Parameters
 * r0: Pointer of Array of Synthesizer Code
 *
 * Return: r0 (Number of Beats in Synthesizer Code)
 */
.globl sts32_synthelen
sts32_synthelen:
	/* Auto (Local) Variables, but just Aliases */
	synt_point .req r0
	synt_word  .req r1
	length     .req r2

	mov length, #0

	sts32_synthelen_loop:
		ldr synt_word, [synt_point]       @ Load Lower Half Word (32-bit)
		cmp synt_word, #0
		ldreq synt_word, [synt_point, #4] @ Load Upper Half Word (32-bit)
		cmpeq synt_word, #0
		beq sts32_synthelen_common        @ Break Loop if Null Character

		add synt_point, synt_point, #8
		add length, length, #1
		b sts32_synthelen_loop

	sts32_synthelen_common:
		mov r0, length
		mov pc, lr

.unreq synt_point
.unreq synt_word
.unreq length


/**
 * function sts32_syntheinit_pwm
 * Sound Initializer for PWM Mode
 *
 * Parameters
 * r0: 0 as GPIO 12/13 PWM, 1 as GPIO 40/45(41) PWM, 2 as Both
 *
 * Return: r0 (0 as Success)
 */
.globl sts32_syntheinit_pwm
sts32_syntheinit_pwm:
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
	 * Makes 19.2Mhz (From Oscillator). Div by 2 Equals 19.2Mhz.
	 */
	push {r0-r3}
	mov r0, #equ32_cm_pwm
	mov r1, #equ32_cm_ctl_mash_0
	add r1, r1, #equ32_cm_ctl_enab|equ32_cm_ctl_src_osc            @ 19.2Mhz
	mov r2, #2<<equ32_cm_div_integer
	bl arm32_clockmanager
	pop {r0-r3}

	/**
	 * PWM Enable
	 */
	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_pwm_base_lower
	add memorymap_base, memorymap_base, #equ32_pwm_base_upper

	/**
	 * 9.6Mhz Div By 300 Equals 32000hz.
	 * Sampling Rate 32000hz, Bit Depth 8bit (Range is 300, but Is Actually 256).
	 */
	mov value, #300
	str value, [memorymap_base, #equ32_pwm_rng1]
	mov value, #300
	str value, [memorymap_base, #equ32_pwm_rng2]

	mov value, #equ32_pwm_ctl_usef1|equ32_pwm_ctl_clrf1|equ32_pwm_ctl_pwen1
	orr value, value, #equ32_pwm_ctl_usef2|equ32_pwm_ctl_pwen2
	str value, [memorymap_base, #equ32_pwm_ctl]

	macro32_dsb ip

	ldr value, STS32_STATUS
	orr value, value, #0x80000000
	str value, STS32_STATUS

	macro32_dsb ip

	sts32_syntheinit_pwm_common:
		mov r0, #0
		pop {pc}

.unreq memorymap_base
.unreq value
.unreq gpio_set


/**
 * function sts32_syntheinit_i2s
 * Synthesizer Initializer for I2S Mode (Outputs Both L and R Side by 32Khz)
 *
 * Return: r0 (0 as Success)
 */
.globl sts32_syntheinit_i2s
sts32_syntheinit_i2s:
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
	 * Makes 19.2Mhz (From Oscillator). Div by 18.75 Equals 1.024Mhz
	 */
	push {r0-r3}
	mov r0, #equ32_cm_pcm
	mov r1, #equ32_cm_ctl_mash_1
	add r1, r1, #equ32_cm_ctl_enab|equ32_cm_ctl_src_osc            @ 19.2Mhz
	mov r2, #18<<equ32_cm_div_integer
	orr r2, r2, #3072<<equ32_cm_div_fraction                       @ 0.75 * 4096
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
	orr value, value, #equ32_pcm_mode_clki|equ32_pcm_mode_fsi     @ Invert Clock and Frame Sync
	str value, [memorymap_base, #equ32_pcm_mode]

	/* Channel 1 */
	mov value, #equ32_pcm_rtxc_ch1en|equ32_pcm_rtxc_ch1wex        @ 32 Bits for Outputs Both L and R
	orr value, value, #1<<equ32_pcm_rtxc_ch1pos                   @ Make Sure Offset 1 Bit from Frame Sync to Fit I2S Signal Regulation
	orr value, value, #8<<equ32_pcm_rtxc_ch1wid
	str value, [memorymap_base, #equ32_pcm_txc]

	/* Clear TxFIFO, Two PCM Clocks Are Needed */
	ldr value, [memorymap_base, #equ32_pcm_cs]
	orr value, value, #equ32_pcm_cs_txclr
	orr value, value, #equ32_pcm_cs_sync
	str value, [memorymap_base, #equ32_pcm_cs]

	macro32_dsb ip

	sts32_syntheinit_i2s_clrtxf:
		ldr value, [memorymap_base, #equ32_pcm_cs]
		tst value, #equ32_pcm_cs_sync
		beq sts32_syntheinit_i2s_clrtxf

	/* Clear RxFIFO, No need of Clear RxFIFO, but RAM Preperation Needs Four PCM Clocks */
	ldr value, [memorymap_base, #equ32_pcm_cs]
	orr value, value, #equ32_pcm_cs_rxclr
	orr value, value, #equ32_pcm_cs_sync
	str value, [memorymap_base, #equ32_pcm_cs]

	macro32_dsb ip

	sts32_syntheinit_i2s_clrrxf:
		ldr value, [memorymap_base, #equ32_pcm_cs]
		tst value, #equ32_pcm_cs_sync
		beq sts32_syntheinit_i2s_clrrxf

	/* PCM Transmit Enable */
	bic value, value, #equ32_pcm_cs_sync
	orr value, value, #0b00 << equ32_pcm_cs_txthr
	orr value, value, #equ32_pcm_cs_txon
	str value, [memorymap_base, #equ32_pcm_cs]

	macro32_dsb ip

	ldr value, STS32_STATUS
	orr value, value, #0x80000000
	str value, STS32_STATUS

	macro32_dsb ip

	sts32_syntheinit_i2s_common:
		mov r0, #0
		pop {pc}

.unreq memorymap_base
.unreq value

