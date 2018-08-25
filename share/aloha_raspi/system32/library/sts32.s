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
 * These functions are aiming building a sound generator with frequency modulation synthesis by a software programmed for a central processing unit (CPU) and an output unit. As an output unit, this project uses a pulse width modulator (PWM) or a pulse code modulator (PCM).
 * On using PWM, the CPU calculates a form of a synthesized wave as binary data, and transmits it to PWM. PWM treats the form as an output of voltage. Differences of voltage of the form make sound wave through any speaker. This PWM amplifies differences of voltage at 6 dB gain.
 * On using PCM, the CPU calculates a form of a synthesized wave as binary data, and transmits it to PCM. PCM sends the form to a digital to analogue converter (DAC). DAC treats the form as an output of voltage. Differences of voltage of the form make sound wave through any speaker. PCM outputs L and R with each 16-bit depth.
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
STS32_SYNTHEWAVE_RL:      .word 0x00 @ 0 as R, 1 as L, Only on PWM

/**
 * Synthesizer Code is 64-bit Block (Two 32-bit Words) consists two frequencies and magnitudes to Synthesize.
 * Lower Bit[2-0] Decimal Part of Frequency-A (Main): 1 as 0.125 (0.125 * 1), 7 as 0.875 (0.875 * 8)
 * Lower Bit[16-3] Frequency-A (Main): 0 to 16383 Hz
 * Lower Bit[31-17] Magnitude-A = Volume: -16384 to 16383, Minus for Inverted Wave, Absolute 16383 is Appx. 0dB
 * Higher Bit[2-0] Decimal Part of Frequency-B (Sub): 1 as 0.125 (0.125 * 1), 7 as 0.875 (0.875 * 8)
 * Higher Bit[16-3] Frequency-B (Sub): 0 to 16383 Hz
 * Higher Bit[31-17] Magnitude-B: 0 to 32767, 1 is 2Pi/32767, 32767 is 2Pi
 * The wave is synthesized the formula:
 * Amplitude on T = Magnitude-A * sin((T * (2Pi * Frequency-A)) + Magnitude-B * sin(T * (2Pi * Frequency-B))).
 * Where T is time (seconds); one is 1/sampling-rate seconds.
 * This type of synthesis is named as "Frequency Modulation Synthesis" developed by John Chowning in 1973.
 * 0x00,0x00 (zeros on lower and higher) means End of Synthesizer Code.
 *
 * Synthesizer Code will be fetched by L/R alternatively.
 * If you line up four blocks, the first and the third block will be fetched by L, and the second and the fourth block will be fetched by R.
 */

/**
 * Synthesizer Pre-code is a series of blocks. Each block has a structure of 4 long integers (32-bit).
 * uint32 synthe_code_lower;
 * uint32 synthe_code_upper;
 * uint32 beat_length (Bit[31:0]), Reserved (Bit[63:32]) Must Be Zero;
 * uint32 rising_pitch (Bit[15:0]) and falling_pitch (Bit[31:16]); 0 - 100 Percents
 * 0x00,0x00 (zeros on lower and higher) means End of Synthesizer Code.
 *
 * Beat Length as 100 percents = Rising Pitch + Flat (Same as Volume) + Falling Pitch
 */

/**
 * function sts32_synthewave_pwm
 * Make Synthesized Wave
 * PWM outputs direct current (DC) bias on all the time.
 * If there isn't direct current bias, capacitors will lose its charged voltage.
 * Charging and losing voltage of capacitors cause popping noise with high volume.
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
	flag_rl        .req r3

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

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_pwm_base_lower
	add memorymap_base, memorymap_base, #equ32_pwm_base_upper

	ldr temp, [memorymap_base, #equ32_pwm_sta]
	tst temp, #equ32_pwm_sta_full1
	bne sts32_synthewave_pwm_error2

	/* Get RL Flag */
	ldr flag_rl, STS32_SYNTHEWAVE_RL

	ldr temp, STS32_STATUS
	tst temp, #1
	beq sts32_synthewave_pwm_error1

	ldr time, STS32_SYNTHEWAVE_TIME
	vmov vfp_time, time
	vcvt.f32.u32 vfp_time, vfp_time

	mov temp, #equ32_sts32_samplerate
	vmov vfp_samplerate, temp
	vcvt.f32.u32 vfp_samplerate, vfp_samplerate
	ldr temp, sts32_synthewave_MATH32_PI_DOUBLE
	vldr vfp_pi_double, [temp]

	vldr vfp_divisor, sts32_synthewave_pwm_divisor

	/* Get Time (Seconds) */
	vdiv.f32 vfp_time, vfp_time, vfp_samplerate

	tst flag_rl, #1
	bne sts32_synthewave_pwm_loop_l

	/**
	 * Amplitude on T = Magnitude-A * sin((T * (2Pi * Frequency-A)) + Magnitude-B * sin(T * (2Pi * Frequency-B))).
	 * Where T is time (seconds); one is 1/sampling-rate seconds.
	 */
	sts32_synthewave_pwm_loop:
		ldr temp, [memorymap_base, #equ32_pwm_sta]
		tst temp, #equ32_pwm_sta_full1
		bne sts32_synthewave_pwm_success

		/* R Wave */

		vldr vfp_freq_a, STS32_SYNTHEWAVE_FREQA_R
		ldr temp, STS32_SYNTHEWAVE_FREQB_R
		vmov vfp_freq_b, temp
		vldr vfp_mag_a, STS32_SYNTHEWAVE_MAGA_R
		vldr vfp_mag_b, STS32_SYNTHEWAVE_MAGB_R

		vmul.f32 vfp_freq_a, vfp_freq_a, vfp_pi_double
		vmul.f32 vfp_freq_a, vfp_freq_a, vfp_time

		/* Check Noise */
		cmp temp, #0
		beq sts32_synthewave_pwm_loop_rnoise

		vmul.f32 vfp_freq_b, vfp_freq_b, vfp_pi_double
		vmul.f32 vfp_freq_b, vfp_freq_b, vfp_time

		b sts32_synthewave_pwm_loop_rcommon

		sts32_synthewave_pwm_loop_rnoise:

			push {r0-r3}
			mov r0, #255
			bl arm32_random
			vmov vfp_freq_b, r0
			pop {r0-r3}

			vcvt.f32.u32 vfp_freq_b, vfp_freq_b

		sts32_synthewave_pwm_loop_rcommon:

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
			add temp, temp, #equ32_sts32_synthewave_pwm_bias

			str temp, [memorymap_base, #equ32_pwm_fif1]

			macro32_dsb ip

			mov flag_rl, #1

		/* L Wave */

		sts32_synthewave_pwm_loop_l:
			ldr temp, [memorymap_base, #equ32_pwm_sta]
			tst temp, #equ32_pwm_sta_full1
			bne sts32_synthewave_pwm_success

			vldr vfp_freq_a, STS32_SYNTHEWAVE_FREQA_L
			ldr temp, STS32_SYNTHEWAVE_FREQB_L
			vmov vfp_freq_b, temp
			vldr vfp_mag_a, STS32_SYNTHEWAVE_MAGA_L
			vldr vfp_mag_b, STS32_SYNTHEWAVE_MAGB_L

			vmul.f32 vfp_freq_a, vfp_freq_a, vfp_pi_double
			vmul.f32 vfp_freq_a, vfp_freq_a, vfp_time

			/* Check Noise */
			cmp temp, #0
			beq sts32_synthewave_pwm_loop_l_noise

			vmul.f32 vfp_freq_b, vfp_freq_b, vfp_pi_double
			vmul.f32 vfp_freq_b, vfp_freq_b, vfp_time

			b sts32_synthewave_pwm_loop_l_common

			sts32_synthewave_pwm_loop_l_noise:

				push {r0-r3}
				mov r0, #255
				bl arm32_random
				vmov vfp_freq_b, r0
				pop {r0-r3}

				vcvt.f32.u32 vfp_freq_b, vfp_freq_b

			sts32_synthewave_pwm_loop_l_common:

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
				add temp, temp, #equ32_sts32_synthewave_pwm_bias
				str temp, [memorymap_base, #equ32_pwm_fif1]

				macro32_dsb ip

				mov flag_rl, #0

				add time, time, #1
				cmp time, #equ32_sts32_samplerate<<3          @ To apply Up To 0.125Hz
				movge time, #0
				vmov vfp_time, time
				vcvt.f32.u32 vfp_time, vfp_time

				/* Get Time (Seconds) */
				vdiv.f32 vfp_time, vfp_time, vfp_samplerate

				b sts32_synthewave_pwm_loop

	sts32_synthewave_pwm_error1:
		ldr temp, [memorymap_base, #equ32_pwm_sta]
		tst temp, #equ32_pwm_sta_full1
		bne sts32_synthewave_pwm_error1_common

		mov temp, #equ32_sts32_synthewave_pwm_bias
		str temp, [memorymap_base, #equ32_pwm_fif1]

		macro32_dsb ip

		eor flag_rl, flag_rl, #1
		b sts32_synthewave_pwm_error1

		sts32_synthewave_pwm_error1_common:
			str flag_rl, STS32_SYNTHEWAVE_RL
			mov r0, #1
			b sts32_synthewave_pwm_common

	sts32_synthewave_pwm_error2:
		mov r0, #2
		b sts32_synthewave_pwm_common

	sts32_synthewave_pwm_success:
		str time, STS32_SYNTHEWAVE_TIME
		str flag_rl, STS32_SYNTHEWAVE_RL
		mov r0, #0

	sts32_synthewave_pwm_common:
		vpop {s0-s8}
		pop {pc}

.unreq memorymap_base
.unreq time
.unreq temp
.unreq flag_rl
.unreq vfp_temp
.unreq vfp_freq_a
.unreq vfp_freq_b
.unreq vfp_mag_a
.unreq vfp_mag_b
.unreq vfp_pi_double
.unreq vfp_samplerate
.unreq vfp_time
.unreq vfp_divisor

sts32_synthewave_pwm_divisor: .float 8.0 @ 6 dB Gain (Twice)


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

	mov temp, #equ32_sts32_samplerate
	vmov vfp_samplerate, temp
	vcvt.f32.u32 vfp_samplerate, vfp_samplerate
	ldr temp, sts32_synthewave_MATH32_PI_DOUBLE
	vldr vfp_pi_double, [temp]

	/* Get Time (Seconds) */
	vdiv.f32 vfp_time, vfp_time, vfp_samplerate

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
		ldr temp, STS32_SYNTHEWAVE_FREQB_L
		vmov vfp_freq_b, temp
		vldr vfp_mag_a, STS32_SYNTHEWAVE_MAGA_L
		vldr vfp_mag_b, STS32_SYNTHEWAVE_MAGB_L

		vmul.f32 vfp_freq_a, vfp_freq_a, vfp_pi_double
		vmul.f32 vfp_freq_a, vfp_freq_a, vfp_time

		/* Check Noise */
		cmp temp, #0
		beq sts32_synthewave_i2s_loop_lnoise

		vmul.f32 vfp_freq_b, vfp_freq_b, vfp_pi_double
		vmul.f32 vfp_freq_b, vfp_freq_b, vfp_time

		b sts32_synthewave_i2s_loop_lcommon

		sts32_synthewave_i2s_loop_lnoise:

			push {r0-r3}
			mov r0, #255
			bl arm32_random
			vmov vfp_freq_b, r0
			pop {r0-r3}

			vcvt.f32.u32 vfp_freq_b, vfp_freq_b

		sts32_synthewave_i2s_loop_lcommon:

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
			ldr temp2, STS32_SYNTHEWAVE_FREQB_R
			vmov vfp_freq_b, temp2
			vldr vfp_mag_a, STS32_SYNTHEWAVE_MAGA_R
			vldr vfp_mag_b, STS32_SYNTHEWAVE_MAGB_R

			vmul.f32 vfp_freq_a, vfp_freq_a, vfp_pi_double
			vmul.f32 vfp_freq_a, vfp_freq_a, vfp_time

			/* Check Noise */
			cmp temp2, #0
			beq sts32_synthewave_i2s_loop_rnoise

			vmul.f32 vfp_freq_b, vfp_freq_b, vfp_pi_double
			vmul.f32 vfp_freq_b, vfp_freq_b, vfp_time

			b sts32_synthewave_i2s_loop_rcommon

		sts32_synthewave_i2s_loop_rnoise:

			push {r0-r3}
			mov r0, #255
			bl arm32_random
			vmov vfp_freq_b, r0
			pop {r0-r3}

			vcvt.f32.u32 vfp_freq_b, vfp_freq_b

		sts32_synthewave_i2s_loop_rcommon:

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

			bic temp2, temp2, #0xFF000000
			bic temp2, temp2, #0x00FF0000               @ Bit[15:0] for R
			lsl temp, temp, #16                         @ Bit[31:16] for L
			orr temp, temp, temp2

			str temp, [memorymap_base, #equ32_pcm_fifo]

			macro32_dsb ip

			add time, time, #1
			cmp time, #equ32_sts32_samplerate<<3          @ To apply Up To 0.125Hz
			movge time, #0
			vmov vfp_time, time
			vcvt.f32.u32 vfp_time, vfp_time

			/* Get Time (Seconds) */
			vdiv.f32 vfp_time, vfp_time, vfp_samplerate

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
 * r0: Pointer of Synthesizer Code
 * r1: Length
 * r2: Count (Offset)
 * r3: Number of Repeat, If -1, Infinite Loop
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Failure of Setting (Pointer of Synthesizer Code is Addressed to Zero or Length is Zero)
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

	cmp addr_code, #0
	beq sts32_syntheset_error
	cmp length, #0
	beq sts32_syntheset_error

	mov temp, #0

	str temp, STS32_CODE       @ Reset to Prevent Odd Playing Sound

	macro32_dsb ip

	ldr temp, STS32_STATUS
	bic temp, temp, #1         @ Clear Bit[0]
	str temp, STS32_STATUS

	str length, STS32_LENGTH
	str count, STS32_COUNT
	str repeat, STS32_REPEAT

	macro32_dsb ip

	str addr_code, STS32_CODE  @ Should Set Music Code at End for Polling Functions, `sts32_syntheplay`

	b sts32_syntheset_success

	sts32_syntheset_error:
		mov r0, #1
		b sts32_syntheset_common

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
	addr_code     .req r0
	length        .req r1
	count         .req r2
	repeat        .req r3
	status        .req r4
	code          .req r5
	temp          .req r6
	fraction      .req r7

	/* VFP Registers */
	vfp_temp      .req s0
	vfp_pi_double .req s1
	vfp_max       .req s2
	vfp_eighth    .req s3
	vfp_fraction  .req s4

	push {r4-r7,lr}
	vpush {s0-s4}

	ldr addr_code, STS32_CODE
	cmp addr_code, #0
	beq sts32_syntheplay_error1

	ldr length, STS32_LENGTH
	cmp length, #0
	beq sts32_syntheplay_error1

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
		/* Hard Code of Single Precision Float 0.125 */
		mov temp, #0x3E000000
		vmov vfp_eighth, temp

		ldr temp, sts32_syntheplay_MATH32_PI_DOUBLE
		vldr vfp_pi_double, [temp]
		mov temp, #0x7F00                          @ Decimal 32767
		orr temp, temp, #0x00FF                    @ Decimal 32767
		vmov vfp_max, temp
		vcvt.f32.u32 vfp_max, vfp_max

		lsl temp, count, #4                        @ Substitute of Multiplication by 16
		ldr code, [addr_code, temp]
		lsl temp, code, #15                        @ Extract [16:0]
		lsr temp, temp, #15                        @ Extract [16:0]
		and fraction, temp, #0b111                 @ Bit [2:0]
		lsr temp, temp, #3                         @ Bit [16:3]
		vmov vfp_temp, temp
		vcvt.f32.u32 vfp_temp, vfp_temp
		vmov vfp_fraction, fraction
		vcvt.f32.u32 vfp_fraction, vfp_fraction
		vmul.f32 vfp_fraction, vfp_fraction, vfp_eighth
		vadd.f32 vfp_temp, vfp_temp, vfp_fraction   @ Add fraction
		vmov temp, vfp_temp
		str temp, STS32_SYNTHEWAVE_FREQA_L
		asr temp, code, #17                        @ Arighmetic Logical Shift Right to Hold Signess, Bit[31:17]
		lsl temp, temp, #1                         @ Multiply by 2
		vmov vfp_temp, temp
		vcvt.f32.s32 vfp_temp, vfp_temp
		vmov temp, vfp_temp
		str temp, STS32_SYNTHEWAVE_MAGA_L

		lsl temp, count, #4                        @ Substitute of Multiplication by 16
		add temp, temp, #4
		ldr code, [addr_code, temp]
		lsl temp, code, #15                        @ Extract [16:0]
		lsr temp, temp, #15                        @ Extract [16:0]
		and fraction, temp, #0b111                 @ Bit [2:0]
		lsr temp, temp, #3                         @ Bit [16:3]
		vmov vfp_temp, temp
		vcvt.f32.u32 vfp_temp, vfp_temp
		vmov vfp_fraction, fraction
		vcvt.f32.u32 vfp_fraction, vfp_fraction
		vmul.f32 vfp_fraction, vfp_fraction, vfp_eighth
		vadd.f32 vfp_temp, vfp_temp, vfp_fraction   @ Add fraction
		vmov temp, vfp_temp
		str temp, STS32_SYNTHEWAVE_FREQB_L
		lsr temp, code, #17                        @ Bit[31:17]
		vmov vfp_temp, temp
		vcvt.f32.u32 vfp_temp, vfp_temp
		vdiv.f32 vfp_temp, vfp_temp, vfp_max
		vmul.f32 vfp_temp, vfp_temp, vfp_pi_double
		vmov temp, vfp_temp
		str temp, STS32_SYNTHEWAVE_MAGB_L

		lsl temp, count, #4                        @ Substitute of Multiplication by 16
		add temp, temp, #8
		ldr code, [addr_code, temp]
		lsl temp, code, #15                        @ Extract [16:0]
		lsr temp, temp, #15                        @ Extract [16:0]
		and fraction, temp, #0b111                 @ Bit [2:0]
		lsr temp, temp, #3                         @ Bit [16:3]
		vmov vfp_temp, temp
		vcvt.f32.u32 vfp_temp, vfp_temp
		vmov vfp_fraction, fraction
		vcvt.f32.u32 vfp_fraction, vfp_fraction
		vmul.f32 vfp_fraction, vfp_fraction, vfp_eighth
		vadd.f32 vfp_temp, vfp_temp, vfp_fraction   @ Add fraction
		vmov temp, vfp_temp
		str temp, STS32_SYNTHEWAVE_FREQA_R
		asr temp, code, #17                        @ Arighmetic Logical Shift Right to Hold Signess, Bit[31:17]
		lsl temp, temp, #1                         @ Multiply by 2
		vmov vfp_temp, temp
		vcvt.f32.s32 vfp_temp, vfp_temp
		vmov temp, vfp_temp
		str temp, STS32_SYNTHEWAVE_MAGA_R

		lsl temp, count, #4                        @ Substitute of Multiplication by 16
		add temp, temp, #12
		ldr code, [addr_code, temp]
		lsl temp, code, #15                        @ Extract [16:0]
		lsr temp, temp, #15                        @ Extract [16:0]
		and fraction, temp, #0b111                 @ Bit [2:0]
		lsr temp, temp, #3                         @ Bit [16:3]
		vmov vfp_temp, temp
		vcvt.f32.u32 vfp_temp, vfp_temp
		vmov vfp_fraction, fraction
		vcvt.f32.u32 vfp_fraction, vfp_fraction
		vmul.f32 vfp_fraction, vfp_fraction, vfp_eighth
		vadd.f32 vfp_temp, vfp_temp, vfp_fraction   @ Add fraction
		vmov temp, vfp_temp
		str temp, STS32_SYNTHEWAVE_FREQB_R
		lsr temp, code, #17                        @ Bit[31:17]
		vmov vfp_temp, temp
		vcvt.f32.u32 vfp_temp, vfp_temp
		vdiv.f32 vfp_temp, vfp_temp, vfp_max
		vmul.f32 vfp_temp, vfp_temp, vfp_pi_double
		vmov temp, vfp_temp
		str temp, STS32_SYNTHEWAVE_MAGB_R

		tst status, #1
		orreq status, status, #1

		add count, count, #1
		str count, STS32_COUNT
		str repeat, STS32_REPEAT
		str status, STS32_STATUS

		b sts32_syntheplay_success

	sts32_syntheplay_free:
		mov addr_code, #0
		mov length, #0
		bic status, status, #1                     @ Clear Bit[0]

		str addr_code, STS32_CODE

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
		vpop {s0-s4}
		pop {r4-r7,pc}

.unreq addr_code
.unreq length
.unreq count
.unreq repeat
.unreq status
.unreq code
.unreq temp
.unreq fraction
.unreq vfp_temp
.unreq vfp_pi_double
.unreq vfp_max
.unreq vfp_eighth
.unreq vfp_fraction

sts32_syntheplay_MATH32_PI_DOUBLE: .word MATH32_PI_DOUBLE


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

	str temp, STS32_LENGTH
	str temp, STS32_COUNT
	str temp, STS32_REPEAT

	ldr temp, STS32_STATUS
	bic temp, temp, #1                         @ Clear Bit[1]
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
 * Count Beats (64-bit) of Synthesizer Code
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
 * function sts32_synthebeatlen
 * Count Beats in Synthesizer Pre-code
 *
 * Parameters
 * r0: Pointer of Array of Synthesizer Pre-code
 *
 * Return: r0 (Number of Beats in Synthesizer Pre-code)
 */
.globl sts32_synthebeatlen
sts32_synthebeatlen:
	/* Auto (Local) Variables, but just Aliases */
	synt_pre_point .req r0
	length         .req r1
	temp           .req r2
	beat           .req r3
	i              .req r4

	push {r4,lr}

	push {r0}
	bl sts32_synthelen
	mov length, r0
	pop {r0}

	lsr length, length, #1

	mov beat, #0
	mov i, #0

	sts32_synthebeatlen_loop:
		cmp i, length
		bge sts32_synthebeatlen_common
		ldr temp, [synt_pre_point, #8]
		add beat, beat, temp
		add synt_pre_point, synt_pre_point, #16
		add i, i, #1
		b sts32_synthebeatlen_loop

	sts32_synthebeatlen_common:
		mov r0, beat
		pop {r4,pc}

.unreq synt_pre_point
.unreq length
.unreq temp
.unreq beat
.unreq i


/**
 * function sts32_synthedecodelr
 * Make LR Synthesizer Code from Pre-code
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r0: Pointer of Array of Synthesizer Pre-code for L
 * r0: Pointer of Array of Synthesizer Pre-code for R
 *
 * Return: r0 (Pointer of Array of Synthesizer Code, If 0, 1, and 2 Error)
 * Error(0): Memory Space for Synthesizer Code is Not Allocated (On heap32_malloc)
 * Error(1): Memory Space for Synthesizer Code is Not Allocated (On sts32_synthedecode)
 * Error(2): Overflow of Memory Space (On sts32_synthedecode)
 */
.globl sts32_synthedecodelr
sts32_synthedecodelr:
	/* Auto (Local) Variables, but just Aliases */
	synt_pre_point_l .req r0
	synt_pre_point_r .req r1
	beat_l           .req r2
	beat_r           .req r3
	heap             .req r4
	result           .req r5

	push {r4-r5,lr}

	push {r0-r1}
	bl sts32_synthebeatlen
	mov beat_l, r0
	pop {r0-r1}

	push {r0-r2}
	mov r0, synt_pre_point_r
	bl sts32_synthebeatlen
	mov beat_r, r0
	pop {r0-r2}

	cmp beat_l, beat_r
	movlt beat_l, beat_r

	lsl beat_l, beat_l, #2               @ Substitute of Multiplication by 4, Make 128-bit Block (LR Synthe Code)
	add beat_l, beat_l, #2               @ End of Synthe Code (64-bit)

	push {r0-r3}
	mov r0, beat_l
	bl heap32_malloc
	mov heap, r0
	pop {r0-r3}

	cmp heap, #0
	beq sts32_synthedecodelr_common

	push {r0-r3}
	mov r1, synt_pre_point_l
	mov r0, heap
	mov r2, #0
	bl sts32_synthedecode
	mov result, r0
	pop {r0-r3}

	cmp result, #0
	movne heap, result
	bne sts32_synthedecodelr_common

	push {r0-r3}
	mov r0, heap
	mov r2, #1
	bl sts32_synthedecode
	mov result, r0
	pop {r0-r3}

	cmp result, #0
	movne heap, result

	sts32_synthedecodelr_common:
		mov r0, heap
		pop {r4-r5,pc}

.unreq synt_pre_point_l
.unreq synt_pre_point_r
.unreq beat_l
.unreq beat_r
.unreq heap
.unreq result


/**
 * function sts32_synthedecode
 * Make Synthesizer Code from Pre-code
 *
 * Parameters
 * r0: Pointer of Array of Synthesizer Code
 * r1: Pointer of Array of Synthesizer Pre-code
 * r2: L (0) or R (1)
 *
 * Return: r0 (0 as Success, 1 and 2 as Error)
 * Error(1): Memory Space for Synthesizer Code is Not Allocated
 * Error(2): Overflow of Memory Space
 */
.globl sts32_synthedecode
sts32_synthedecode:
	/* Auto (Local) Variables, but just Aliases */
	synt_point        .req r0
	synt_pre_point    .req r1
	flag_lr           .req r2
	synt_max_length   .req r3
	synt_pre_length   .req r4
	code_lower        .req r5
	code_upper        .req r6
	temp              .req r7
	rising_length     .req r8
	flat_length       .req r9
	beat_length       .req r10

	/* VFP Registers */
	vfp_volume        .req s0
	vfp_rising        .req s1
	vfp_falling       .req s2
	vfp_beat_length   .req s3
	vfp_temp          .req s4
	vfp_rising_delta  .req s5
	vfp_falling_delta .req s6
	vfp_one           .req s7

	push {r4-r10,lr}
	vpush {s0-s7}

	push {r0-r2}
	bl heap32_mcount
	mov synt_max_length, r0
	pop {r0-r2}

	cmp synt_max_length, #-1
	beq sts32_synthedecode_error1

	sub synt_max_length, synt_max_length, #8   @ Subtract for End of Synthe code
	lsr synt_max_length, synt_max_length, #4   @ Substitute of Division by 16, Counts as 128-bit (4 Words) Blocks for LR Synthe Code
	cmp flag_lr, #0
	addne synt_point, synt_point, #8           @ Set Offset for R

	push {r0-r3}
	mov r0, synt_pre_point
	bl sts32_synthelen
	mov synt_pre_length, r0
	pop {r0-r3}

	lsr synt_pre_length, synt_pre_length, #1

	mov temp, #1
	vmov vfp_one, temp
	vcvt.f32.u32 vfp_one, vfp_one

	sts32_synthedecode_main:
		subs synt_pre_length, synt_pre_length, #1
		blt sts32_synthedecode_success
		ldr code_lower, [synt_pre_point]
		ldr code_upper, [synt_pre_point, #4]
		ldr beat_length, [synt_pre_point, #8]
		vmov vfp_beat_length, beat_length
		vcvt.f32.u32 vfp_beat_length, vfp_beat_length
		asr temp, code_lower, #17                      @ Arighmetic Logical Shift Right to Hold Signess, Bit[31:17]
		vmov vfp_volume, temp
		vcvt.f32.s32 vfp_volume, vfp_volume
		ldrh flat_length, [synt_pre_point, #12]
		vmov vfp_rising, flat_length
		vcvt.f32.u32 vfp_rising, vfp_rising
		ldrh flat_length, [synt_pre_point, #14]
		vmov vfp_falling, flat_length
		vcvt.f32.u32 vfp_falling, vfp_falling
		add synt_pre_point, synt_pre_point, #16         @ Offset for Next Pre-block

		/* Convert Percents to Decimal */

		mov temp, #100
		vmov vfp_temp, temp
		vcvt.f32.u32 vfp_temp, vfp_temp
		vdiv.f32 vfp_rising, vfp_rising, vfp_temp
		vdiv.f32 vfp_falling, vfp_falling, vfp_temp

		/* Rising Length and Rising Delta */

		vmul.f32 vfp_temp, vfp_beat_length, vfp_rising
		vdiv.f32 vfp_rising_delta, vfp_volume, vfp_temp
		vcvt.u32.f32 vfp_temp, vfp_temp
		vmov rising_length, vfp_temp
		cmp rising_length, beat_length
		movgt rising_length, beat_length                @ If Rising Is Overing 100 Percents

		/* Falling Delta  */

		vmul.f32 vfp_temp, vfp_beat_length, vfp_falling
		vdiv.f32 vfp_falling_delta, vfp_volume, vfp_temp

		/* Flat Length */

		/* Check Sum of Rising and Falling is Under 100 Percents */
		vadd.f32 vfp_temp, vfp_rising, vfp_falling
		vcmp.f32 vfp_temp, vfp_one
		vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
		vsublt.f32 vfp_temp, vfp_one, vfp_temp
		vmullt.f32 vfp_temp, vfp_beat_length, vfp_temp
		vcvtlt.u32.f32 vfp_temp, vfp_temp
		vmovlt flat_length, vfp_temp
		movge flat_length, #0                           @ If Overing 100 Percents

		/* Volume 0.0 for Further Prcocesses */

		.unreq vfp_one
		vfp_zero .req s7

		mov temp, #0
		vmov vfp_volume, temp
		vmov vfp_zero, temp

		/* Clear Volume Bit[31:17] */

		bic code_lower, code_lower, #0xFF000000
		bic code_lower, code_lower, #0x00FE0000

		/* Make Falling Length */

		sub beat_length, beat_length, rising_length
		sub beat_length, beat_length, flat_length

		.unreq beat_length
		falling_length .req r10

/*
macro32_debug synt_max_length, 200, 0
macro32_debug rising_length, 200, 12 
macro32_debug flat_length, 200, 24
macro32_debug falling_length, 200, 36
macro32_debug synt_point, 200, 48
*/

		sts32_synthedecode_main_rising:
			subs rising_length, rising_length, #1
			ldrlt code_lower, [synt_pre_point, #-16]            @ Retrieve Original Volume for Flat Part
			asrlt temp, code_lower, #17                         @ Arighmetic Logical Shift Right to Hold Signess, Bit[31:17]
			vmovlt vfp_volume, temp
			vcvtlt.f32.s32 vfp_volume, vfp_volume
			blt sts32_synthedecode_main_flat
			subs synt_max_length, synt_max_length, #1
			blt sts32_synthedecode_error2

			str code_lower, [synt_point]
			str code_upper, [synt_point, #4]
			add synt_point, synt_point, #16

			vadd.f32 vfp_volume, vfp_volume, vfp_rising_delta
			vcvtr.s32.f32 vfp_temp, vfp_volume
			vmov temp, vfp_temp
			lsl temp, temp, #17                                 @ Bit[31:17]
			bic code_lower, code_lower, #0xFF000000
			bic code_lower, code_lower, #0x00FE0000
			orr code_lower, code_lower, temp

			b sts32_synthedecode_main_rising

		sts32_synthedecode_main_flat:
			subs flat_length, flat_length, #1
			blt sts32_synthedecode_main_falling
			subs synt_max_length, synt_max_length, #1
			blt sts32_synthedecode_error2

			str code_lower, [synt_point]
			str code_upper, [synt_point, #4]
			add synt_point, synt_point, #16

			b sts32_synthedecode_main_flat

		sts32_synthedecode_main_falling:
			subs falling_length, falling_length, #1
			blt sts32_synthedecode_main
			subs synt_max_length, synt_max_length, #1
			blt sts32_synthedecode_error2

			str code_lower, [synt_point]
			str code_upper, [synt_point, #4]
			add synt_point, synt_point, #16

			vsub.f32 vfp_volume, vfp_volume, vfp_falling_delta
			vcvtr.s32.f32 vfp_temp, vfp_volume
			vmov temp, vfp_temp
			lsl temp, temp, #17                                 @ Bit[31:17]
			bic code_lower, code_lower, #0xFF000000
			bic code_lower, code_lower, #0x00FE0000
			orr code_lower, code_lower, temp

			b sts32_synthedecode_main_falling

	sts32_synthedecode_error1:
		mov r0, #1
		b sts32_synthedecode_common

	sts32_synthedecode_error2:
		mov r0, #2
		b sts32_synthedecode_common

	sts32_synthedecode_success:
/*
macro32_debug synt_point, 200, 60
*/
		mov r0, #0

	sts32_synthedecode_common:
		vpop {s0-s7}
		pop {r4-r10,pc}

.unreq synt_point
.unreq synt_pre_point
.unreq flag_lr
.unreq synt_max_length
.unreq synt_pre_length
.unreq code_lower
.unreq code_upper
.unreq temp
.unreq rising_length
.unreq flat_length
.unreq falling_length
.unreq vfp_volume
.unreq vfp_rising
.unreq vfp_falling
.unreq vfp_beat_length
.unreq vfp_temp
.unreq vfp_rising_delta
.unreq vfp_falling_delta
.unreq vfp_zero


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
	 * Makes 160Mhz (From PLLD). 500Mhz Div by 3.125 Equals 200Mhz.
	 */
	push {r0-r3}
	mov r0, #equ32_cm_pwm
	mov r1, #equ32_cm_ctl_mash_1
	add r1, r1, #equ32_cm_ctl_enab|equ32_cm_ctl_src_plld           @ 500Mhz
	mov r2, #3<<equ32_cm_div_integer
	orr r2, r2, #512<<equ32_cm_div_fraction                        @ 0.125 * 4096
	bl arm32_clockmanager
	pop {r0-r3}

	/**
	 * PWM Enable
	 */
	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_pwm_base_lower
	add memorymap_base, memorymap_base, #equ32_pwm_base_upper

	/**
	 * 160Mhz Div By 5000 Equals 32000hz.
	 * Sampling Rate 32000hz, Bit Depth 12bit (Range is 5000, but Is Actually 4096).
	 */
	mov value, #0x1300
	orr value, value, #0x0088
	str value, [memorymap_base, #equ32_pwm_rng1]
	str value, [memorymap_base, #equ32_pwm_rng2]

	mov value, #equ32_pwm_ctl_msen1|equ32_pwm_ctl_clrf1|equ32_pwm_ctl_usef1|equ32_pwm_ctl_pwen1
	orr value, value, #equ32_pwm_ctl_msen2|equ32_pwm_ctl_usef2|equ32_pwm_ctl_pwen2
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
	orr value, value, #0b11 << equ32_pcm_cs_txthr @ Flag Down If Full
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

