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

/**
 * Synthesizer Code is 64-bit Block (Two 32-bit Words) consists two frequencies and magnitudes to Synthesize.
 * Lower Bit[2-0] Decimal Part of Frequency-A (Main): 1 as 0.125 (0.125 * 1), 7 as 0.875 (0.875 * 8)
 * Lower Bit[16-3] Frequency-A (Main): 0 to 16383 Hz
 * Lower Bit[31-17] Amplitude-A = Volume: -16384 to 16383, Minus for Inverted Wave, Absolute 16383 is Appx. 0dB, Should Be -8192 to 8191 in PWM Output
 * Higher Bit[2-0] Decimal Part of Frequency-B (Sub): 1 as 0.125 (0.125 * 1), 7 as 0.875 (0.875 * 8)
 * Higher Bit[16-3] Frequency-B (Sub): 0 to 16383 Hz
 * Higher Bit[31-17] Amplitude-B: 0 to 32767, 1 is 2Pi/32767, 32767 is 2Pi
 * The wave is synthesized the formula:
 * Amplitude on T = Amplitude-A * sin((T * (2Pi * Frequency-A)) + Amplitude-B * sin(T * (2Pi * Frequency-B))).
 * Where T is time (seconds); one is 1/sampling-rate seconds.
 * This type of synthesis is named as "Frequency Modulation Synthesis" developed by John Chowning in 1973, so to speak, a brief formula of Fourier series.
 * 0x00,0x00 (zeros on lower and higher) means End of Synthesizer Code.
 *
 * Synthesizer Code will be fetched by L/R alternatively.
 * If you line up four blocks, the first and the third block will be fetched by L, and the second and the fourth block will be fetched by R.
 *
 * Reference: Chowning,J. 1973 The Synthesis of Complex Audio Spectra by Means of Frequency Modulation. Journal of the Audio Engineering Society, 21, 526-534.
 */

/**
 * Synthesizer Pre-code is a series of blocks. Each block has a structure of 4 long integers (32-bit).
 * uint32 synthe_code_lower;
 * uint32 synthe_code_upper;
 * uint32 beat_length (Bit[31:0]);
 * uint32 release_time (Bit[31:24]), sustain_level (Bit[23:16]), decay_time (Bit(15:8)), attack_time (Bit[7:0]); Envelope ADSR Model, 0 - 100 Percents
 * 0x00,0x00 (zeros on lower and higher) means End of Synthesizer Code.
 *
 * Beat Length as 100 percents = attack_time + decay_time + sustain_time (not parameterized) + release_time
 */

/**
 * function sts32_synthewave_pwm
 * Make Synthesized Wave
 * PWM outputs direct current (DC) bias on all the time.
 * If there isn't direct current bias, capacitors will lose its charged voltage.
 * Charging and losing voltage of capacitors cause popping noise with high volume.
 *
 * Parameters
 * r0: Pitch Bend Rate, Must Be Single Precision Float
 * r1: Tone (Low-pass Filter) Rate, Must Be Single Precision Float
 * r2: Number of Voices, A Multiple of 2
 *
 * Return: r0 (0 as Success, 1 as Error)
 * Error(1): PWM FIFO is Already Full
 */
.globl sts32_synthewave_pwm
sts32_synthewave_pwm:
	/* Auto (Local) Variables, but just Aliases */
	memorymap_base .req r0
	temp           .req r1
	num_voices     .req r2
	flag_rl        .req r3
	time           .req r4
	status_voices  .req r5
	voices         .req r6
	addr_param     .req r7
	offset_param   .req r8

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
	vfp_bend       .req s9
	vfp_sum        .req s10
	vfp_tone       .req s11

	push {r4-r8,lr}
	vpush {s0-s11}

	vmov vfp_bend, memorymap_base
	vmov vfp_tone, temp
	cmp num_voices, #equ32_sts32_voice_max
	movhi num_voices, #equ32_sts32_voice_max
	lsr num_voices, num_voices, #1                             @ Divide by 2

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_pwm_base_lower
	add memorymap_base, memorymap_base, #equ32_pwm_base_upper

	/* Check Whether Already Full on FIFO Stack */
	ldr temp, [memorymap_base, #equ32_pwm_sta]
	tst temp, #equ32_pwm_sta_full1
	bne sts32_synthewave_pwm_error1

	/* Get Pointer of Parameters */
	ldr addr_param, STS32_SYNTHEWAVE_PARAM

	/* Get Voices Status */
	ldr status_voices, STS32_VOICES

	/* Get Time (Seconds) */
	ldr time, STS32_SYNTHEWAVE_TIME
	vmov vfp_time, time
	vcvt.f32.u32 vfp_time, vfp_time

	mov temp, #equ32_sts32_samplerate
	vmov vfp_samplerate, temp
	vcvt.f32.u32 vfp_samplerate, vfp_samplerate
	vmul.f32 vfp_samplerate, vfp_samplerate, vfp_bend          @ Multiply Pitch Bend Rate to Sample Rate

	vdiv.f32 vfp_time, vfp_time, vfp_samplerate

	/* Get Double PI */
	ldr temp, sts32_synthewave_MATH32_PI_DOUBLE
	vldr vfp_pi_double, [temp]

	/* Divisor of Amplitude Only for PWM Output */
	vldr vfp_divisor, sts32_synthewave_pwm_divisor

	/* Get RL Flag Only for PWM Output */
	ldr flag_rl, STS32_SYNTHEWAVE_RL
	tst flag_rl, #1
	bne sts32_synthewave_pwm_loop_lfifo

	/**
	 * Amplitude on T = Amplitude-A * sin((T * (2Pi * Frequency-A)) + Amplitude-B * sin(T * (2Pi * Frequency-B))).
	 * Where T is time (seconds); one is 1/sampling-rate seconds.
	 */
	sts32_synthewave_pwm_loop:
		/* Check FIFO Stack for R */
		ldr temp, [memorymap_base, #equ32_pwm_sta]
		tst temp, #equ32_pwm_sta_full1
		bne sts32_synthewave_pwm_success

		mov voices, #0

		/* Clear Summation to Zero */
		vmov vfp_sum, voices

	/* R Wave */
	sts32_synthewave_pwm_loop_r:
		cmp voices, num_voices
		bhs sts32_synthewave_pwm_loop_r_common

		/* If Status of The Voice Is Inactive, Pass Through */
		lsl offset_param, voices, #3                @ Multiply by 8
		add offset_param, offset_param, #4
		mov temp, #0xF
		lsl temp, temp, offset_param
		tst status_voices, temp
		addeq voices, voices, #1
		beq sts32_synthewave_pwm_loop_r

		lsl offset_param, voices, #5                @ Multiply by 32, 32 Bytes (Eight Words) Offset for Each Parameter on Both L and R
		add offset_param, offset_param, #16         @ Add 16, 16 Bytes (Four Words) Offset for R
		add offset_param, addr_param, offset_param

		vldr vfp_freq_a, [offset_param]             @ Main Frequency
		add offset_param, offset_param, #4
		vldr vfp_mag_a, [offset_param]              @ Main Amplitude
		add offset_param, offset_param, #4
		ldr temp, [offset_param]                    @ Sub Frequency
		add offset_param, offset_param, #4
		vmov vfp_freq_b, temp
		vldr vfp_mag_b, [offset_param]              @ Sub Amplitude

		vmul.f32 vfp_freq_a, vfp_freq_a, vfp_pi_double
		vmul.f32 vfp_freq_a, vfp_freq_a, vfp_time

		/* Check Noise */
		cmp temp, #0
		beq sts32_synthewave_pwm_loop_r_noise

		vmul.f32 vfp_freq_b, vfp_freq_b, vfp_pi_double
		vmul.f32 vfp_freq_b, vfp_freq_b, vfp_time

		b sts32_synthewave_pwm_loop_r_calc

		sts32_synthewave_pwm_loop_r_noise:

			push {r0-r3}
			mov r0, #255
			bl arm32_random
			vmov vfp_freq_b, r0
			pop {r0-r3}

			vcvt.f32.u32 vfp_freq_b, vfp_freq_b

		sts32_synthewave_pwm_loop_r_calc:

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
			vadd.f32 vfp_sum, vfp_sum, vfp_freq_a

			add voices, voices, #1
			b sts32_synthewave_pwm_loop_r

		sts32_synthewave_pwm_loop_r_common:

			/* Tone */
			ldr temp, STS32_SYNTHEWAVE_TONE_R
			vmov vfp_freq_a, temp
			mov temp, #0x3F800000                       @ Hard Code of 1.0 Float
			vmov vfp_temp, temp
			vsub.f32 vfp_temp, vfp_temp, vfp_tone
			vmul.f32 vfp_sum, vfp_sum, vfp_temp
			vmul.f32 vfp_freq_a, vfp_freq_a, vfp_tone
			vadd.f32 vfp_sum, vfp_sum, vfp_freq_a
			vmov temp, vfp_sum
			str temp, STS32_SYNTHEWAVE_TONE_R

			vdiv.f32 vfp_sum, vfp_sum, vfp_divisor
			vcvtr.s32.f32 vfp_sum, vfp_sum
			vmov temp, vfp_sum
			add temp, temp, #equ32_sts32_synthewave_pwm_bias
			str temp, [memorymap_base, #equ32_pwm_fif1]

			macro32_dsb ip

			mov flag_rl, #1

		sts32_synthewave_pwm_loop_lfifo:
			/* Check FIFO Stack for L */
			ldr temp, [memorymap_base, #equ32_pwm_sta]
			tst temp, #equ32_pwm_sta_full1
			bne sts32_synthewave_pwm_success

			mov voices, #0

			/* Clear Summation to Zero */
			vmov vfp_sum, voices

		/* L Wave */
		sts32_synthewave_pwm_loop_l:
			cmp voices, num_voices
			bhs sts32_synthewave_pwm_loop_l_common

			/* If Status of The Voice Is Inactive, Pass Through */
			lsl offset_param, voices, #3                @ Multiply by 8
			mov temp, #0xF
			lsl temp, temp, offset_param
			tst status_voices, temp
			addeq voices, voices, #1
			beq sts32_synthewave_pwm_loop_l

			lsl offset_param, voices, #5                @ Multiply by 32, 32 Bytes (Eight Words) Offset for Each Parameter on Both L and R
			add offset_param, addr_param, offset_param

			vldr vfp_freq_a, [offset_param]             @ Main Frequency
			add offset_param, offset_param, #4
			vldr vfp_mag_a, [offset_param]              @ Main Amplitude
			add offset_param, offset_param, #4
			ldr temp, [offset_param]                    @ Sub Frequency
			add offset_param, offset_param, #4
			vmov vfp_freq_b, temp
			vldr vfp_mag_b, [offset_param]              @ Sub Amplitude

			vmul.f32 vfp_freq_a, vfp_freq_a, vfp_pi_double
			vmul.f32 vfp_freq_a, vfp_freq_a, vfp_time

			/* Check Noise */
			cmp temp, #0
			beq sts32_synthewave_pwm_loop_l_noise

			vmul.f32 vfp_freq_b, vfp_freq_b, vfp_pi_double
			vmul.f32 vfp_freq_b, vfp_freq_b, vfp_time

			b sts32_synthewave_pwm_loop_l_calc

			sts32_synthewave_pwm_loop_l_noise:

				push {r0-r3}
				mov r0, #255
				bl arm32_random
				vmov vfp_freq_b, r0
				pop {r0-r3}

				vcvt.f32.u32 vfp_freq_b, vfp_freq_b

			sts32_synthewave_pwm_loop_l_calc:

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
				vadd.f32 vfp_sum, vfp_sum, vfp_freq_a

				add voices, voices, #1
				b sts32_synthewave_pwm_loop_l

			sts32_synthewave_pwm_loop_l_common:

				/* Tone */
				ldr temp, STS32_SYNTHEWAVE_TONE_L
				vmov vfp_freq_a, temp
				mov temp, #0x3F800000                       @ Hard Code of 1.0 Float
				vmov vfp_temp, temp
				vsub.f32 vfp_temp, vfp_temp, vfp_tone
				vmul.f32 vfp_sum, vfp_sum, vfp_temp
				vmul.f32 vfp_freq_a, vfp_freq_a, vfp_tone
				vadd.f32 vfp_sum, vfp_sum, vfp_freq_a
				vmov temp, vfp_sum
				str temp, STS32_SYNTHEWAVE_TONE_L

				vdiv.f32 vfp_sum, vfp_sum, vfp_divisor
				vcvtr.s32.f32 vfp_sum, vfp_sum
				vmov temp, vfp_sum
				add temp, temp, #equ32_sts32_synthewave_pwm_bias
				str temp, [memorymap_base, #equ32_pwm_fif1]

				macro32_dsb ip

				mov flag_rl, #0

				add time, time, #1
				cmp time, #equ32_sts32_samplerate<<3          @ To apply Up To 0.125Hz, Multiply Sample Rate by 8
				movhs time, #0
				vmov vfp_time, time
				vcvt.f32.u32 vfp_time, vfp_time

				/* Get Time (Seconds) */
				vdiv.f32 vfp_time, vfp_time, vfp_samplerate

				b sts32_synthewave_pwm_loop

	sts32_synthewave_pwm_error1:
		mov r0, #1
		b sts32_synthewave_pwm_common

	sts32_synthewave_pwm_success:
		str time, STS32_SYNTHEWAVE_TIME
		str flag_rl, STS32_SYNTHEWAVE_RL
		mov r0, #0

	sts32_synthewave_pwm_common:
		vpop {s0-s11}
		pop {r4-r8,pc}

.unreq memorymap_base
.unreq temp
.unreq num_voices
.unreq flag_rl
.unreq time
.unreq status_voices
.unreq voices
.unreq addr_param
.unreq offset_param
.unreq vfp_temp
.unreq vfp_freq_a
.unreq vfp_freq_b
.unreq vfp_mag_a
.unreq vfp_mag_b
.unreq vfp_pi_double
.unreq vfp_samplerate
.unreq vfp_time
.unreq vfp_divisor
.unreq vfp_bend
.unreq vfp_sum
.unreq vfp_tone

sts32_synthewave_pwm_divisor: .float 8.0 @ 6 dB Gain (Twice)


/**
 * function sts32_synthewave_i2s
 * Make Synthesized Wave
 *
 * Parameters
 * r0: Pitch Bend Rate, Must Be Single Precision Float
 * r1: Tone (Low-pass Filter) Rate, Must Be Single Precision Float
 * r2: Number of Voices, A Multiple of 2
 *
 * Return: r0 (0 as Success, 1 as Error)
 * Error(1): PCM FIFO is Full
 */
.globl sts32_synthewave_i2s
sts32_synthewave_i2s:
	/* Auto (Local) Variables, but just Aliases */
	memorymap_base .req r0
	temp           .req r1
	num_voices     .req r2
	value          .req r3
	time           .req r4
	status_voices  .req r5
	voices         .req r6
	addr_param     .req r7
	offset_param   .req r8

	/* VFP Registers */
	vfp_temp       .req s0
	vfp_freq_a     .req s1
	vfp_freq_b     .req s2
	vfp_mag_a      .req s3
	vfp_mag_b      .req s4
	vfp_pi_double  .req s5
	vfp_samplerate .req s6
	vfp_time       .req s7
	vfp_bend       .req s8
	vfp_sum        .req s9
	vfp_tone       .req s10

	push {r4-r8,lr}
	vpush {s0-s10}

	vmov vfp_bend, memorymap_base
	vmov vfp_tone, temp
	cmp num_voices, #equ32_sts32_voice_max
	movhi num_voices, #equ32_sts32_voice_max
	lsr num_voices, num_voices, #1                             @ Divide by 2

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_pcm_base_lower
	add memorymap_base, memorymap_base, #equ32_pcm_base_upper

	/* Check Whether Already Full on FIFO Stack */
	ldr temp, [memorymap_base, #equ32_pcm_cs]
	tst temp, #equ32_pcm_cs_txw
	beq sts32_synthewave_i2s_error1

	/* Get Pointer of Parameters */
	ldr addr_param, STS32_SYNTHEWAVE_PARAM

	/* Get Voices Status */
	ldr status_voices, STS32_VOICES

	/* Get Time (Seconds) */
	ldr time, STS32_SYNTHEWAVE_TIME
	vmov vfp_time, time
	vcvt.f32.u32 vfp_time, vfp_time

	mov temp, #equ32_sts32_samplerate
	vmov vfp_samplerate, temp
	vcvt.f32.u32 vfp_samplerate, vfp_samplerate
	vmul.f32 vfp_samplerate, vfp_samplerate, vfp_bend          @ Multiply Pitch Bend Rate to Sample Rate

	vdiv.f32 vfp_time, vfp_time, vfp_samplerate

	/* Get Double PI */
	ldr temp, sts32_synthewave_MATH32_PI_DOUBLE
	vldr vfp_pi_double, [temp]

	/**
	 * Amplitude on T = Amplitude-A * sin((T * (2Pi * Frequency-A)) + Amplitude-B * sin(T * (2Pi * Frequency-B))).
	 * Where T is time (seconds); one is 1/sampling-rate seconds.
	 */
	sts32_synthewave_i2s_loop:
		/* Check FIFO Stack for R */
		ldr temp, [memorymap_base, #equ32_pcm_cs]
		tst temp, #equ32_pcm_cs_txw
		beq sts32_synthewave_i2s_success

		mov voices, #0

		/* Clear Summation to Zero */
		vmov vfp_sum, voices

	/* R Wave */
	sts32_synthewave_i2s_loop_r:
		cmp voices, num_voices
		bhs sts32_synthewave_i2s_loop_r_common

		/* If Status of The Voice Is Inactive, Pass Through */
		lsl offset_param, voices, #3                @ Multiply by 8
		add offset_param, offset_param, #4
		mov temp, #0xF
		lsl temp, temp, offset_param
		tst status_voices, temp
		addeq voices, voices, #1
		beq sts32_synthewave_i2s_loop_r

		lsl offset_param, voices, #5                @ Multiply by 32, 32 Bytes (Eight Words) Offset for Each Parameter on Both L and R
		add offset_param, offset_param, #16         @ Add 16, 16 Bytes (Four Words) Offset for R
		add offset_param, addr_param, offset_param

		vldr vfp_freq_a, [offset_param]             @ Main Frequency
		add offset_param, offset_param, #4
		vldr vfp_mag_a, [offset_param]              @ Main Amplitude
		add offset_param, offset_param, #4
		ldr temp, [offset_param]                    @ Sub Frequency
		add offset_param, offset_param, #4
		vmov vfp_freq_b, temp
		vldr vfp_mag_b, [offset_param]              @ Sub Amplitude

		vmul.f32 vfp_freq_a, vfp_freq_a, vfp_pi_double
		vmul.f32 vfp_freq_a, vfp_freq_a, vfp_time

		/* Check Noise */
		cmp temp, #0
		beq sts32_synthewave_i2s_loop_r_noise

		vmul.f32 vfp_freq_b, vfp_freq_b, vfp_pi_double
		vmul.f32 vfp_freq_b, vfp_freq_b, vfp_time

		b sts32_synthewave_i2s_loop_r_calc

		sts32_synthewave_i2s_loop_r_noise:

			push {r0-r3}
			mov r0, #255
			bl arm32_random
			vmov vfp_freq_b, r0
			pop {r0-r3}

			vcvt.f32.u32 vfp_freq_b, vfp_freq_b

		sts32_synthewave_i2s_loop_r_calc:

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
			vadd.f32 vfp_sum, vfp_sum, vfp_freq_a

			add voices, voices, #1
			b sts32_synthewave_i2s_loop_r

		sts32_synthewave_i2s_loop_r_common:

			/* Tone */
			ldr temp, STS32_SYNTHEWAVE_TONE_R
			vmov vfp_freq_a, temp
			mov temp, #0x3F800000                       @ Hard Code of 1.0 Float
			vmov vfp_temp, temp
			vsub.f32 vfp_temp, vfp_temp, vfp_tone
			vmul.f32 vfp_sum, vfp_sum, vfp_temp
			vmul.f32 vfp_freq_a, vfp_freq_a, vfp_tone
			vadd.f32 vfp_sum, vfp_sum, vfp_freq_a
			vmov temp, vfp_sum
			str temp, STS32_SYNTHEWAVE_TONE_R

			vcvtr.s32.f32 vfp_sum, vfp_sum
			vmov value, vfp_sum

			/**
			 * For L Wave
			 */

			mov voices, #0

			/* Clear Summation to Zero */
			vmov vfp_sum, voices

		/* L Wave */
		sts32_synthewave_i2s_loop_l:
			cmp voices, num_voices
			bhs sts32_synthewave_i2s_loop_l_common

			/* If Status of The Voice Is Inactive, Pass Through */
			lsl offset_param, voices, #3                @ Multiply by 8
			mov temp, #0xF
			lsl temp, temp, offset_param
			tst status_voices, temp
			addeq voices, voices, #1
			beq sts32_synthewave_i2s_loop_l

			lsl offset_param, voices, #5                @ Multiply by 32, 32 Bytes (Eight Words) Offset for Each Parameter on Both L and R
			add offset_param, addr_param, offset_param

			vldr vfp_freq_a, [offset_param]             @ Main Frequency
			add offset_param, offset_param, #4
			vldr vfp_mag_a, [offset_param]              @ Main Amplitude
			add offset_param, offset_param, #4
			ldr temp, [offset_param]                    @ Sub Frequency
			add offset_param, offset_param, #4
			vmov vfp_freq_b, temp
			vldr vfp_mag_b, [offset_param]              @ Sub Amplitude

			vmul.f32 vfp_freq_a, vfp_freq_a, vfp_pi_double
			vmul.f32 vfp_freq_a, vfp_freq_a, vfp_time

			/* Check Noise */
			cmp temp, #0
			beq sts32_synthewave_i2s_loop_l_noise

			vmul.f32 vfp_freq_b, vfp_freq_b, vfp_pi_double
			vmul.f32 vfp_freq_b, vfp_freq_b, vfp_time

			b sts32_synthewave_i2s_loop_l_calc

			sts32_synthewave_i2s_loop_l_noise:

				push {r0-r3}
				mov r0, #255
				bl arm32_random
				vmov vfp_freq_b, r0
				pop {r0-r3}

				vcvt.f32.u32 vfp_freq_b, vfp_freq_b

			sts32_synthewave_i2s_loop_l_calc:

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
				vadd.f32 vfp_sum, vfp_sum, vfp_freq_a

				add voices, voices, #1
				b sts32_synthewave_i2s_loop_l

			sts32_synthewave_i2s_loop_l_common:

				/* Tone */
				ldr temp, STS32_SYNTHEWAVE_TONE_L
				vmov vfp_freq_a, temp
				mov temp, #0x3F800000                       @ Hard Code of 1.0 Float
				vmov vfp_temp, temp
				vsub.f32 vfp_temp, vfp_temp, vfp_tone
				vmul.f32 vfp_sum, vfp_sum, vfp_temp
				vmul.f32 vfp_freq_a, vfp_freq_a, vfp_tone
				vadd.f32 vfp_sum, vfp_sum, vfp_freq_a
				vmov temp, vfp_sum
				str temp, STS32_SYNTHEWAVE_TONE_L

				vcvtr.s32.f32 vfp_sum, vfp_sum
				vmov temp, vfp_sum

				bic value, value, #0xFF000000
				bic value, value, #0x00FF0000               @ Bit[15:0] for R

				lsl temp, temp, #16                         @ Bit[31:16] for L
				orr value, value, temp

				str value, [memorymap_base, #equ32_pcm_fifo]

				macro32_dsb ip

				add time, time, #1
				cmp time, #equ32_sts32_samplerate<<3          @ To apply Up To 0.125Hz, Multiply Sample Rate by 8
				movhs time, #0
				vmov vfp_time, time
				vcvt.f32.u32 vfp_time, vfp_time

				/* Get Time (Seconds) */
				vdiv.f32 vfp_time, vfp_time, vfp_samplerate

				b sts32_synthewave_i2s_loop

	sts32_synthewave_i2s_error1:
		mov r0, #1
		b sts32_synthewave_i2s_common

	sts32_synthewave_i2s_success:
		str time, STS32_SYNTHEWAVE_TIME
		mov r0, #0

	sts32_synthewave_i2s_common:
		vpop {s0-s10}
		pop {r4-r8,pc}

.unreq memorymap_base
.unreq temp
.unreq num_voices
.unreq value
.unreq time
.unreq status_voices
.unreq voices
.unreq addr_param
.unreq offset_param
.unreq vfp_temp
.unreq vfp_freq_a
.unreq vfp_freq_b
.unreq vfp_mag_a
.unreq vfp_mag_b
.unreq vfp_pi_double
.unreq vfp_samplerate
.unreq vfp_time
.unreq vfp_bend
.unreq vfp_sum
.unreq vfp_tone

sts32_synthewave_MATH32_PI_DOUBLE: .word MATH32_PI_DOUBLE

STS32_SYNTHEWAVE_TIME:   .word 0x00 @ One Equals 1/sampling-rate Seconds
STS32_SYNTHEWAVE_RL:     .word 0x00 @ 0 as R, 1 as L, Only on PWM
STS32_SYNTHEWAVE_PARAM:  .word STS32_SYNTHEWAVE_FREQA_L
STS32_SYNTHEWAVE_TONE_R: .float 0.0
STS32_SYNTHEWAVE_TONE_L: .float 0.0


/* If End or Step Up, Automatically Cleared */
STS32_CODE:            .word 0x00 @ Pointer of Synthesizer Code
STS32_LENGTH:          .word 0x00 @ Length of Synthesizer Code
STS32_REPEAT:          .word 0x00 @ Repeat status of Synthesizer Code
STS32_COUNT:           .word 0x00 @ Incremental Count of Synthesizer Code, Once Music Code Reaches Last, This Value will Be Reset
STS32_CODE_NEXT:       .word 0x00 @ Pointer of Next Synthesizer Code
STS32_LENGTH_NEXT:     .word 0x00 @ Length of Next Synthesizer Code
STS32_REPEAT_NEXT:     .word 0x00 @ Repeat status of Next Synthesizer Code
STS32_COUNT_NEXT:      .word 0x00 @ Incremental Count of Next Synthesizer Code, Once Music Code Reaches Last, This Value will Be Reset

/**
 * Bit[0] Synthesizer Code Stop(0)/ Playing (1)
 * Bit[1] Reserved
 * Bit[2] Reserved
 * Bit[3] Reserved
 * Bit[31] Not Initialized(0)/ Initialized(1)
 */
STS32_STATUS:             .word 0x00


/**
 * Status of Voices, 0 as Inactive, 1 as Attack, 2 as Decay, 3 as Sustain, 4 as Release, 8 as Synthesizer Code
 * Bit[3:0] Voice L1
 * Bit[7:4] Voice R1
 * Bit[11:8] Voice L2
 * Bit[15:12] Voice R2
 * Bit[19:16] Voice L3
 * Bit[23:20] Voice R3
 * Bit[27:24] Voice L4
 * Bit[31:28] Voice R4
 */
STS32_VOICES:             .word 0x00


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
	status      .req r4

	push {r4}

	cmp addr_code, #0
	beq sts32_syntheset_error
	cmp length, #0
	beq sts32_syntheset_error

	ldr status, STS32_STATUS
	tst status, #1
	bne sts32_syntheset_next

	/* First Set */
	str addr_code, STS32_CODE
	str length, STS32_LENGTH
	str count, STS32_COUNT
	str repeat, STS32_REPEAT

	orr status, status, #1         @ Set Synthesizer Code Playing Bit[0]
	str status, STS32_STATUS

	b sts32_syntheset_success

	sts32_syntheset_next:
		str addr_code, STS32_CODE_NEXT
		str length, STS32_LENGTH_NEXT
		str count, STS32_COUNT_NEXT
		str repeat, STS32_REPEAT_NEXT

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
.unreq status


/**
 * function sts32_syntheplay
 * Play Synthesizer
 *
 * Parameters
 * r0: Number of Voices
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
	status_voices .req r7
	voices        .req r8
	addr_param    .req r9
	num_voices    .req r10
	offset_code   .req r11

	/* VFP Registers */
	vfp_temp      .req s0
	vfp_pi_double .req s1
	vfp_max       .req s2
	vfp_eighth    .req s3
	vfp_fraction  .req s4

	push {r4-r11,lr}
	vpush {s0-s4}

	mov num_voices, addr_code
	cmp num_voices, #equ32_sts32_voice_max
	movhi num_voices, #equ32_sts32_voice_max

	ldr addr_code, STS32_CODE
	cmp addr_code, #0
	beq sts32_syntheplay_error1

	ldr length, STS32_LENGTH
	cmp length, #0
	beq sts32_syntheplay_error1

	ldr count, STS32_COUNT
	ldr repeat, STS32_REPEAT
	ldr status, STS32_STATUS
	ldr status_voices, STS32_VOICES

	macro32_dsb ip

	tst status, #0x80000000                   @ If Not Initialized
	beq sts32_syntheplay_error2

	cmp count, length
	blo sts32_syntheplay_encode

	/* If Next Synthesizer Code Exists Alter Current Code on Point of Repeating */
	ldr temp, STS32_CODE_NEXT
	cmp temp, #0
	bne sts32_syntheplay_next

	mov count, #0

	cmp repeat, #-1
	beq sts32_syntheplay_encode

	sub repeat, repeat, #1

	cmp repeat, #0
	ble sts32_syntheplay_free

	sts32_syntheplay_next:
		mov addr_code, temp
		ldr length, STS32_LENGTH_NEXT
		ldr count, STS32_COUNT_NEXT
		ldr repeat, STS32_REPEAT_NEXT

		str addr_code, STS32_CODE
		str length, STS32_LENGTH

		mov temp, #0
		str temp, STS32_CODE_NEXT
		str temp, STS32_LENGTH_NEXT
		str temp, STS32_COUNT_NEXT
		str temp, STS32_REPEAT_NEXT

		.unreq length
		offset_param .req r1

	sts32_syntheplay_encode:
		/* Hard Code of Single Precision Float 0.125 */
		mov temp, #0x3E000000
		vmov vfp_eighth, temp

		ldr temp, sts32_syntheplay_MATH32_PI_DOUBLE
		vldr vfp_pi_double, [temp]
		mov temp, #0x7F00                          @ Decimal 32767
		orr temp, temp, #0x00FF                    @ Decimal 32767
		vmov vfp_max, temp
		vcvt.f32.u32 vfp_max, vfp_max

		mov voices, #0
		ldr addr_param, STS32_SYNTHEWAVE_PARAM

		/* Make Offset for Code */
		mov temp, #8
		mul temp, num_voices, temp                     @ Multiply by 8 to Make Stride, One Set for Each Voice is 8 Bytes (Two Words)
		mul offset_code, count, temp                   @ Multiply by Stride

		sts32_syntheplay_encode_loop:
			cmp voices, num_voices
			bge sts32_syntheplay_encode_common

			lsl offset_param, voices, #4               @ Multiply by 16, 16 Bytes (Four Words) Offset for Each Parameter

			/**
			 * Main
			 */

			ldr code, [addr_code, offset_code]
			add offset_code, offset_code, #4           @ Slide Offset for Synthesizer Code

			/* Fraction */
			and temp, code, #0b111                     @ Bit [2:0]
			vmov vfp_fraction, temp
			vcvt.f32.u32 vfp_fraction, vfp_fraction
			vmul.f32 vfp_fraction, vfp_fraction, vfp_eighth

			/* Integer */
			lsl temp, code, #15                        @ Extract [16:0]
			lsr temp, temp, #18                        @ Bit [16:3]
			vmov vfp_temp, temp
			vcvt.f32.u32 vfp_temp, vfp_temp

			/* Main Frequency */
			vadd.f32 vfp_temp, vfp_temp, vfp_fraction  @ Add fraction and Integer
			vmov temp, vfp_temp
			str temp, [addr_param, offset_param]       @ Main Frequency
			add offset_param, offset_param, #4

			/* Main Amplitude  */
			asr temp, code, #17                        @ Arighmetic Logical Shift Right to Hold Signess, Bit[31:17]
			lsl temp, temp, #1                         @ Multiply by 2
			vmov vfp_temp, temp
			vcvt.f32.s32 vfp_temp, vfp_temp
			vmov temp, vfp_temp
			str temp, [addr_param, offset_param]       @ Main Amplitude
			add offset_param, offset_param, #4

			/**
			 * Sub
			 */

			ldr code, [addr_code, offset_code]
			add offset_code, offset_code, #4           @ Slide Offset for Synthesizer Code

			/* Fraction */
			and temp, code, #0b111                     @ Bit [2:0]
			vmov vfp_fraction, temp
			vcvt.f32.u32 vfp_fraction, vfp_fraction
			vmul.f32 vfp_fraction, vfp_fraction, vfp_eighth

			/* Integer */
			lsl temp, code, #15                        @ Extract [16:0]
			lsr temp, temp, #18                        @ Bit [16:3]
			vmov vfp_temp, temp
			vcvt.f32.u32 vfp_temp, vfp_temp

			/* Sub Frequency */
			vadd.f32 vfp_temp, vfp_temp, vfp_fraction  @ Add fraction and Integer
			vmov temp, vfp_temp
			str temp, [addr_param, offset_param]       @ Sub Frequency
			add offset_param, offset_param, #4

			/* Sub Amplitude */
			lsr temp, code, #17                        @ Bit[31:17]
			vmov vfp_temp, temp
			vcvt.f32.u32 vfp_temp, vfp_temp
			vdiv.f32 vfp_temp, vfp_temp, vfp_max
			vmul.f32 vfp_temp, vfp_temp, vfp_pi_double
			vmov temp, vfp_temp
			str temp, [addr_param, offset_param]       @ Sub Amplitude

			/* Set Voices Status */
			lsl code, voices, #2                       @ Multiply by 4
			mov temp, #0b1000
			lsl temp, temp, code
			orr status_voices, status_voices, temp

			add voices, voices, #1
			b sts32_syntheplay_encode_loop

		sts32_syntheplay_encode_common:

			add count, count, #1
			str count, STS32_COUNT
			str repeat, STS32_REPEAT
			str status, STS32_STATUS
			str status_voices, STS32_VOICES

			b sts32_syntheplay_success

	sts32_syntheplay_free:
		bic status, status, #1                     @ Clear Bit[0]
		str status, STS32_STATUS

		mov addr_code, #0

		str addr_code, STS32_CODE
		str addr_code, STS32_LENGTH
		str count, STS32_COUNT                     @ count is Already Zero
		str repeat, STS32_REPEAT                   @ repeat is Already Zero

		/* Clear Voices Status */
		sts32_syntheplay_free_voices:
			sub num_voices, num_voices, #1
			lsl voices, num_voices, #2             @ Multiply by 4
			mov temp, #0b1000
			lsl temp, temp, voices
			bic status_voices, status_voices, temp
			cmp num_voices, #0
			bhi sts32_syntheplay_free_voices

		str status_voices, STS32_VOICES

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
		pop {r4-r11,pc}

.unreq addr_code
.unreq offset_param
.unreq count
.unreq repeat
.unreq status
.unreq code
.unreq temp
.unreq status_voices
.unreq voices
.unreq addr_param
.unreq num_voices
.unreq offset_code
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
 * Parameters
 * r0: Number of Voices
 *
 * Return: r0 (0 as success)
 */
.globl sts32_syntheclear
sts32_syntheclear:
	/* Auto (Local) Variables, but just Aliases */
	num_voices .req r0
	temp       .req r1
	temp2      .req r2
	temp3      .req r3

	cmp num_voices, #equ32_sts32_voice_max
	movhi num_voices, #equ32_sts32_voice_max

	ldr temp, STS32_STATUS
	bic temp, temp, #1                         @ Clear Bit[1]
	str temp, STS32_STATUS

	ldr temp, STS32_VOICES

	/* Clear Voices Status */
	sts32_syntheclear_voices:
		sub num_voices, num_voices, #1
		lsl temp2, num_voices, #2              @ Multiply by 4
		mov temp3, #0b1000
		lsl temp3, temp3, temp2
		bic temp, temp, temp3
		cmp num_voices, #0
		bhi sts32_syntheclear_voices

	str temp, STS32_VOICES

	mov temp, #0

	str temp, STS32_CODE
	str temp, STS32_LENGTH
	str temp, STS32_COUNT
	str temp, STS32_REPEAT

	str temp, STS32_CODE_NEXT
	str temp, STS32_LENGTH_NEXT
	str temp, STS32_COUNT_NEXT
	str temp, STS32_REPEAT_NEXT

	sts32_syntheclear_success:
		macro32_dsb ip
		mov r0, #0                            @ Return with Success

	sts32_syntheclear_common:
		mov pc, lr

.unreq num_voices
.unreq temp
.unreq temp2
.unreq temp3


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
	temp              .req r3

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

	.unreq gpio_set
	temp2 .req r2

	/**
	 * Clock Manager for PWM.
	 * Makes 160Mhz (From PLLD). 500Mhz Div by 3.125 Equals 200Mhz.
	 */
	push {r0-r3}
	mov r0, #equ32_cm_pwm
	mov r1, #equ32_cm_ctl_mash_1
	add r1, r1, #equ32_cm_ctl_enab|equ32_cm_ctl_src_plld           @ 500Mhz
	mov r2, #3<<equ32_cm_div_integer
	orr r2, r2, #0x200<<equ32_cm_div_fraction                      @ 0.125 * 4096, Decimal 512
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

	mov value, #equ32_sts32_neutraldiv_pwm
	ldr memorymap_base, STS32_DIVISOR_ADDR
	str value, [memorymap_base]

	mov temp, #equ32_sts32_range
	mov temp2, #equ32_sts32_mul_pwm
	mul temp, temp, temp2

	ldr memorymap_base, STS32_MODULATION_RANGE_ADDR
	str temp, [memorymap_base]

	add temp2, value, temp
	ldr memorymap_base, STS32_MODULATION_MAX_ADDR
	str temp2, [memorymap_base]

	sub temp2, value, temp
	ldr memorymap_base, STS32_MODULATION_MIN_ADDR
	str temp2, [memorymap_base]

	ldr value, STS32_STATUS
	orr value, value, #0x80000000
	str value, STS32_STATUS

	macro32_dsb ip

	sts32_syntheinit_pwm_common:
		mov r0, #0
		pop {pc}

.unreq memorymap_base
.unreq value
.unreq temp2
.unreq temp


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
	temp2             .req r2
	temp              .req r3

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
	orr r2, r2, #0xC00<<equ32_cm_div_fraction                      @ 0.75 * 4096, Decimal 3072
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

	mov value, #equ32_sts32_neutraldiv_pcm
	ldr memorymap_base, STS32_DIVISOR_ADDR
	str value, [memorymap_base]

	mov temp, #equ32_sts32_range
	mov temp2, #equ32_sts32_mul_pcm
	mul temp, temp, temp2

	ldr memorymap_base, STS32_MODULATION_RANGE_ADDR
	str temp, [memorymap_base]

	add temp2, value, temp
	ldr memorymap_base, STS32_MODULATION_MAX_ADDR
	str temp2, [memorymap_base]

	sub temp2, value, temp
	ldr memorymap_base, STS32_MODULATION_MIN_ADDR
	str temp2, [memorymap_base]

	ldr value, STS32_STATUS
	orr value, value, #0x80000000
	str value, STS32_STATUS

	macro32_dsb ip

	sts32_syntheinit_i2s_common:
		mov r0, #0
		pop {pc}

.unreq memorymap_base
.unreq value
.unreq temp2
.unreq temp


/**
 * function sts32_synthemidi
 * MIDI Handler
 * Use this function in UART interrupt.
 *
 * Parameters
 * r0: Channel, 0-15 (MIDI Channel No. 1 to 16)
 * r1: 0 as PWM Mode, 1 as PCM Mode
 * r2: Number of Voices
 *
 * Return: r0 (0 as success, 1, 2, and 3 as error)
 * Error(1): Not Initialized on sts32_syntheinit_*, No Buffer to Receive on UART, or UART Overrun
 * Error(2): Character Is Not Received
 * Error(3): MIDI Channel is Not Matched, or Only Data Bytes Received
 */
.globl sts32_synthemidi
sts32_synthemidi:
	/* Auto (Local) Variables, but just Aliases */
	channel        .req r0
	mode           .req r1
	buffer         .req r2
	count          .req r3
	max_size       .req r4
	bytebuffer     .req r5
	byte           .req r6
	temp           .req r7
	data1          .req r8
	data2          .req r9
	status         .req r10
	num_voices     .req r11

	/* VFP Registers */
	vfp_volume     .req s0
	vfp_sustain    .req s1
	vfp_temp       .req s2
	vfp_temp2      .req s3

	push {r4-r11,lr}
	vpush {s0-s3}

	mov num_voices, buffer
	cmp num_voices, #equ32_sts32_voice_max
	movhi num_voices, #equ32_sts32_voice_max

	ldr status, STS32_STATUS
	ldr count, STS32_SYNTHEMIDI_COUNT
	ldr max_size, STS32_SYNTHEMIDI_LENGTH
	ldr buffer, STS32_SYNTHEMIDI_BUFFER

	tst status, #0x80000000           @ If Not Initialized
	beq sts32_synthemidi_error1

	.unreq status
	status_voices .req r10

	cmp buffer, #0
	beq sts32_synthemidi_error1       @ If No Buffer

	ldr bytebuffer, STS32_SYNTHEMIDI_BYTEBUFFER

	push {r0-r3}
	mov r0, bytebuffer
	mov r1, #1                        @ 1 Bytes
	bl uart32_uartrx
	mov temp, r0                      @ Whether Overrun or Not
	pop {r0-r3}

	tst temp, #0x8                    @ Whether Overrun or Not
	bne sts32_synthemidi_error1       @ If Overrun

	tst temp, #0x10                   @ Whether Not Received or So
	bne sts32_synthemidi_error2       @ If Not Received

	/* Check Whether Status or Data Bytes */
	ldrb byte, [bytebuffer]

	tst byte, #0x80
	bne sts32_synthemidi_status

	/* Check Whether Only Data Bytes (Status Is For Other Channels, etc.) */
	cmp count, #0
	beq sts32_synthemidi_error3

	/* Data Bytes */
	strb byte, [buffer,count]

	/* Slide Offset Count */
	add count, count, #1
	cmp count, max_size
	subge count, max_size, #1         @ If Exceeds Maximum Size of Heap, Stay Count

	.unreq max_size
	temp2 .req r4
	.unreq bytebuffer
	voices .req r5

	/* Check Message Type and Procedures for Each Message */
	ldrb temp, [buffer]
	ldrb data1, [buffer, #1]
	ldrb data2, [buffer, #2]
	cmp temp, #0x8
	beq sts32_synthemidi_noteoff           @ Velocity is Ignored
	cmp temp, #0x9
	beq sts32_synthemidi_noteon
	cmp temp, #0xA
	beq sts32_synthemidi_polyaftertouch    @ Polyphonic Key Pressure
	cmp temp, #0xB
	beq sts32_synthemidi_control
	cmp temp, #0xC
	beq sts32_synthemidi_programchange
	cmp temp, #0xD
	beq sts32_synthemidi_monoaftertouch    @ Monophonic Key Pressure
	cmp temp, #0xE
	beq sts32_synthemidi_pitchbend
	cmp temp, #0xF
	beq sts32_synthemidi_systemcommon

	b sts32_synthemidi_success

	sts32_synthemidi_noteoff:
		cmp count, #3
		blo sts32_synthemidi_success

		ldr status_voices, STS32_VOICES

		mov voices, #0
		sts32_synthemidi_noteoff_voicesearch:
			cmp voices, num_voices
			bhs sts32_synthemidi_noteoff_common

			/* Test Whether The Voice Is under Usage as Attack, Decay, and Sustain with MIDI or Not */
			lsl temp, voices, #2              @ Multiply by 4
			mov temp2, #0b11
			lsl temp, temp2, temp
			tst status_voices, temp
			beq sts32_synthemidi_noteoff_voicesearch_common

			/* Load Each Concurrent Note, If Not Matched Do Nothing */
			ldr temp, STS32_SYNTHEMIDI_CURRENTNOTE
			ldrb temp, [temp, voices]
			cmp temp, data1
			bne sts32_synthemidi_noteoff_voicesearch_common

			/* If Note is Matched, Change Status to Release */
			lsl temp, voices, #2              @ Multiply by 4
			mov temp2, #0b11
			lsl temp2, temp2, temp
			bic status_voices, status_voices, temp2
			mov temp2, #0b100
			lsl temp2, temp2, temp
			orr status_voices, status_voices, temp2

			/**
			 * Store Delta for Release to Envelope Pointer
			 */

			lsl temp, voices, #4               @ Multiply by 16
			ldr temp2, STS32_SYNTHEWAVE_PARAM
			add data2, temp2, temp             @ vldr/vstr Has Offset Only with Immediate Value
			add data2, data2, #4               @ Offset Voice No. + 4 Bytes
			vldr vfp_volume, [data2]           @ Get Current Main Amplitude

			ldr data2, STS32_SYNTHEMIDI_RELEASE
			vmov vfp_temp, data2
			vcvt.f32.u32 vfp_temp, vfp_temp
			vdiv.f32 vfp_volume, vfp_volume, vfp_temp

			/* Reset Count to Zero and Store Delta for Release */
			ldr temp2, STS32_SYNTHEMIDI_ENVELOPE
			add data2, temp2, temp             @ vldr/vstr Has Offset Only with Immediate Value
			mov temp, #0
			str temp, [data2]                  @ Store Count Zero
			add data2, data2, #12              @ Offset Voice No. + 12 Bytes
			vstr vfp_volume, [data2]           @ Store Delta for Release

			/* Break Loop */
			/* Deprecated Because of Endless Sounding after Pushing Same Note on Pedaling Sustain
			b sts32_synthemidi_noteoff_common
			*/

			sts32_synthemidi_noteoff_voicesearch_common:
				add voices, voices, #1
				b sts32_synthemidi_noteoff_voicesearch

		sts32_synthemidi_noteoff_common:
			str status_voices, STS32_VOICES
			mov count, #0
			b sts32_synthemidi_success

	sts32_synthemidi_noteon:
		cmp count, #3
		blo sts32_synthemidi_success

		/* If Velocity Is Zero, Go to Note Off Event */
		cmp data2, #0
		beq sts32_synthemidi_noteoff

		ldr status_voices, STS32_VOICES

		mov voices, #0
		sts32_synthemidi_noteon_voicesearch:
			cmp voices, num_voices
			bhs sts32_synthemidi_noteon_common

			/* Test Whether The Voice Is under Any Usage with MIDI or Synthesizer Code, or Not */
			lsl temp, voices, #2               @ Multiply by 4
			mov temp2, #0b1111
			lsl temp2, temp2, temp
			tst status_voices, temp2
			bne sts32_synthemidi_noteon_voicesearch_common

			/* Set Attack */
			mov temp2, #0b1
			lsl temp2, temp2, temp
			orr status_voices, status_voices, temp2

			/* Store Concurrent Notes */
			ldr temp, STS32_SYNTHEMIDI_CURRENTNOTE
			strb data1, [temp, voices]

			/* Set Main Frequency from Table of Notes */
			ldr temp, STS32_SYNTHEMIDI_TABLENOTES
			lsl data1, data1, #2               @ Multiply by 4, Array of Single Precision Float
			ldr data1, [temp, data1]
			lsl temp2, voices, #4              @ Multiply by 16
			ldr temp, STS32_SYNTHEWAVE_PARAM
			str data1, [temp, temp2]           @ Main Frequency
			add temp2, temp2, #4

			/* Set Main Amplitude as Zero */
			mov byte, #0
			str byte, [temp, temp2]            @ Main Amplitude
			add temp2, temp2, #4

			/* Set Sub Frequency from Parameter, Round to Nearest 0.125 */
			vmov vfp_temp, data1
			ldr data1, STS32_SYNTHEMIDI_SUBPITCH
			vmov vfp_temp2, data1
			vmul.f32 vfp_temp, vfp_temp, vfp_temp2
			mov data1, #0x3E000000             @ Hard Code 0.125 in Float
			vmov vfp_temp2, data1
			vdiv.f32 vfp_temp, vfp_temp, vfp_temp2
			vcvtr.u32.f32 vfp_temp, vfp_temp
			vcvt.f32.u32 vfp_temp, vfp_temp
			vmul.f32 vfp_temp, vfp_temp, vfp_temp2
			vmov data1, vfp_temp
			str data1, [temp, temp2]           @ Sub Frequency
			add temp2, temp2, #4

			/* Set Sub Amplitude from Parameter */
			ldr data1, STS32_SYNTHEMIDI_SUBAMP
			str data1, [temp, temp2]           @ Sub Amplitude

			/**
			 * Make Deltas
			 */

			/* Make Maximum Volume with Floating Point */
			ldr temp, STS32_SYNTHEMIDI_VOLUME
			mul data2, data2, temp
			vmov vfp_volume, data2
			vcvt.f32.u32 vfp_volume, vfp_volume

			/* Make Envelope Pointer for The Voice */
			lsl temp2, voices, #4              @ Multiply by 16
			ldr temp, STS32_SYNTHEMIDI_ENVELOPE
			add temp, temp, temp2

			/* Store Count to Envelope Pointer */
			mov data1, #0
			str data1, [temp]
			add temp, temp, #4

			/* Store Delta for Attack to Envelope Pointer */
			ldr data1, STS32_SYNTHEMIDI_ATTACK
			vmov vfp_temp, data1
			vcvt.f32.u32 vfp_temp, vfp_temp
			vdiv.f32 vfp_temp, vfp_volume, vfp_temp
			vstr vfp_temp, [temp]
			add temp, temp, #4

			/* Store Delta for Decay to Envelope Pointer */
			ldr data1, STS32_SYNTHEMIDI_SUSTAIN
			vmov vfp_temp, data1
			vmul.f32 vfp_sustain, vfp_volume, vfp_temp
			vsub.f32 vfp_temp2, vfp_volume, vfp_sustain
			ldr data1, STS32_SYNTHEMIDI_DECAY
			vmov vfp_temp, data1
			vcvt.f32.u32 vfp_temp, vfp_temp
			vdiv.f32 vfp_temp, vfp_temp2, vfp_temp
			vstr vfp_temp, [temp]

			/* Break Loop */
			b sts32_synthemidi_noteon_common

			sts32_synthemidi_noteon_voicesearch_common:
				add voices, voices, #1
				b sts32_synthemidi_noteon_voicesearch

		sts32_synthemidi_noteon_common:
			str status_voices, STS32_VOICES
			mov count, #0
			b sts32_synthemidi_success

	sts32_synthemidi_polyaftertouch:
		cmp count, #3
		blo sts32_synthemidi_success

		mov count, #0
		b sts32_synthemidi_success

	sts32_synthemidi_control:
		cmp count, #3
		blo sts32_synthemidi_success

		mov count, #0

		cmp data1, #72
		beq sts32_synthemidi_control_release               @ Sound Controller 3
		cmp data1, #73
		beq sts32_synthemidi_control_attack                @ Sound Controller 4
		cmp data1, #75
		beq sts32_synthemidi_control_decay                 @ Sound Controller 6
		cmp data1, #79
		beq sts32_synthemidi_control_sustain               @ Sound Controller 10 Undefined in Default
		cmp data1, #64
		bhs sts32_synthemidi_control_others
		cmp data1, #32
		bhs sts32_synthemidi_control_lsb

		/* Most Significant Bits */

		ldr temp, STS32_SYNTHEMIDI_CTL
		and data1, data1, #0x1F                            @ Only Use 0 to 31
		lsl data1, data1, #1                               @ Multiply by 2 to Fit Half Word Align
		ldrh temp2, [temp, data1]
		bic temp2, #0x3F80                                 @ Bit[13:7]
		bic temp2, #0xC000                                 @ Clear Bit[15:14], Not Necessary
		orr data2, temp2, data2, lsl #7
		strh data2, [temp, data1]

		/**
		 * Immediate Changes Here
		 * Sending CC#1 to CC#31 Trigger to Change Each Parameter
		 */
		lsr data1, data1, #1                               @ Divide by 2
		cmp data1, #1
		beq sts32_synthemidi_control_modulation
		cmp data1, #7
		beq sts32_synthemidi_control_volume
		cmp data1, #9
		beq sts32_synthemidi_control_tone                  @ Undefined in Default
		cmp data1, #12
		beq sts32_synthemidi_control_dmoddelta             @ Effect Control 1 in Default
		cmp data1, #13
		beq sts32_synthemidi_control_dmodrange             @ Effect Control 2 in Default
		cmp data1, #16
		beq sts32_synthemidi_control_gp1                   @ Frequency Range (Interval) of Modulation
		cmp data1, #17
		beq sts32_synthemidi_control_gp2                   @ Sub Frequency Pitch on Synthesis
		cmp data1, #18
		beq sts32_synthemidi_control_gp3                   @ Sub Amplitude on Synthesis
		cmp data1, #19
		beq sts32_synthemidi_control_gp4                   @ Virtual Parallel for Sequence of Music Code

		b sts32_synthemidi_success

		sts32_synthemidi_control_lsb:

			/* Least Significant Bits */

			ldr temp, STS32_SYNTHEMIDI_CTL
			and data1, data1, #0x1F                            @ Only Use 0 to 31
			lsl data1, data1, #1                               @ Multiply by 2 to Fit Half Word Align
			ldrh temp2, [temp, data1]
			bic temp2, #0x7F                                   @ Bit[6:0]
			bic temp2, #0xC000                                 @ Clear Bit[15:14], Not Necessary
			orr data2, temp2, data2
			strh data2, [temp, data1]

			/**
			 * Immediate Changes Here
			 * Sending CC#1 to CC#31 Trigger to Change Each Parameter
			 */
			lsr data1, data1, #1                               @ Divide by 2
			cmp data1, #1
			beq sts32_synthemidi_control_modulation
			cmp data1, #7
			beq sts32_synthemidi_control_volume
			cmp data1, #9
			beq sts32_synthemidi_control_tone                  @ Undefined in Default
			cmp data1, #12
			beq sts32_synthemidi_control_dmoddelta             @ Effect Control 1 in Default
			cmp data1, #13
			beq sts32_synthemidi_control_dmodrange             @ Effect Control 2 in Default
			cmp data1, #16
			beq sts32_synthemidi_control_gp1                   @ Frequency Range (Interval) of Modulation
			cmp data1, #17
			beq sts32_synthemidi_control_gp2                   @ Sub Frequency Pitch on Synthesis
			cmp data1, #18
			beq sts32_synthemidi_control_gp3                   @ Sub Amplitude on Synthesis
			cmp data1, #19
			beq sts32_synthemidi_control_gp4                   @ Virtual Parallel for Sequence of Music Code

			b sts32_synthemidi_success

		sts32_synthemidi_control_modulation:
			/* Incremental / Decremental Delta of Modulation */
			lsr data2, data2, #8                               @ Divide by 256, Resolution 16384 to 64
			cmp mode, #0
			moveq temp, #equ32_sts32_mul_pwm
			movne temp, #equ32_sts32_mul_pcm
			mul data2, data2, temp
			ldr temp, STS32_MODULATION_DELTA_ADDR
			str data2, [temp]
			b sts32_synthemidi_success

		sts32_synthemidi_control_volume:
			/* (data^1/2) / 2 */
			vmov vfp_volume, data2
			vcvt.f32.u32 vfp_volume, vfp_volume
			mov temp, #2
			vmov vfp_temp, temp
			vcvt.f32.u32 vfp_temp, vfp_temp
			vsqrt.f32 vfp_volume, vfp_volume
			vdiv.f32 vfp_volume, vfp_volume, vfp_temp
			vcvt.u32.f32 vfp_volume, vfp_volume
			vmov temp, vfp_volume
			str temp, STS32_SYNTHEMIDI_VOLUME

			b sts32_synthemidi_success

		sts32_synthemidi_control_tone:
			/* Maximum Value 16000, Divisor */
			mov temp, #0x3E00                                  @ Decimal 16000
			orr temp, temp, #0x0080                            @ Decimal 16000
			vmov vfp_temp, temp
			vcvt.f32.u32 vfp_temp, vfp_temp

			/* If 16001 - 16383, Saturate to 16000, (Range 0 - 16383, Bit[13:0]) */
			cmp data2, temp
			movhi data2, temp

			vmov vfp_volume, data2
			vcvt.f32.u32 vfp_volume, vfp_volume

			vdiv.f32 vfp_volume, vfp_volume, vfp_temp          @ Range 0 - 16000 to 0 - 1.0

			ldr temp, STS32_TONE_ADDR
			vstr vfp_volume, [temp]

			b sts32_synthemidi_success

		sts32_synthemidi_control_dmoddelta:
			cmp data2, #0
			beq sts32_synthemidi_control_dmoddelta_zero
			lsr data2, data2, #7                          @ Range 0 - 16383 to 0 - 127
			vmov vfp_volume, data2
			vcvt.f32.s32 vfp_volume, vfp_volume

			/* Divisor, 16256 */
			mov temp, #0x3F00
			orr temp, temp, #0x0080
			vmov vfp_temp, temp
			vcvt.f32.u32 vfp_temp, vfp_temp
			vdiv.f32 vfp_volume, vfp_volume, vfp_temp     @ Range 0 - 255 to 0.0 - 0.0078125

			ldr temp, STS32_DIGITALMOD_DELTA_ADDR
			vstr vfp_volume, [temp]

			b sts32_synthemidi_success

			sts32_synthemidi_control_dmoddelta_zero:
				/* Reset Medium Value to 1.0, Prevent Glitch on Sample Rate */
				mov temp, #0x3F800000                     @ Hard Code 1.0 in Float
				ldr temp2, STS32_DIGITALMOD_MEDIUM_ADDR
				str temp, [temp2]

				mov temp, #0
				ldr temp2, STS32_DIGITALMOD_DELTA_ADDR
				str temp, [temp2]

				b sts32_synthemidi_success

		sts32_synthemidi_control_dmodrange:
			lsr data2, data2, #2                          @ Range 0 - 16383 to 0 - 4095
			vmov vfp_volume, data2
			vcvt.f32.u32 vfp_volume, vfp_volume

			/* Divisor, 8190 */
			mov temp, #0x1F00
			orr temp, temp, #0x00FE
			vmov vfp_temp, temp
			vcvt.f32.u32 vfp_temp, vfp_temp
			vdiv.f32 vfp_volume, vfp_volume, vfp_temp     @ Range 0 - 4095 to 0 - 0.5

			mov temp, #0x3F800000                         @ Hard Code 1.0 in Float
			vmov vfp_temp, temp

			/* Reset Medium Value to 1.0 */
			ldr temp, STS32_DIGITALMOD_MEDIUM_ADDR
			vstr vfp_temp, [temp]

			/* Maximum Value of Interval */
			vadd.f32 vfp_temp2, vfp_temp, vfp_volume
			ldr temp, STS32_DIGITALMOD_MAX_ADDR
			vstr vfp_temp2, [temp]

			/* Minimum Value of Interval */
			vsub.f32 vfp_temp2, vfp_temp, vfp_volume
			ldr temp, STS32_DIGITALMOD_MIN_ADDR
			vstr vfp_temp2, [temp]

			b sts32_synthemidi_success

		sts32_synthemidi_control_gp1:
			/* Frequency Range (Interval) of Modulation */
			lsr data1, data2, #3                          @ Divide by 8, Resolution 16384 to 2048
			cmp mode, #0
			moveq data2, #equ32_sts32_mul_pwm
			movne data2, #equ32_sts32_mul_pcm
			mul data1, data1, data2

			ldr temp, STS32_MODULATION_RANGE_ADDR
			str data1, [temp]

			/* Get Base Divisor on Modulation */
			ldr temp2, STS32_DIVISOR_ADDR
			ldr temp, [temp2]

			/* Maximum Frequency on Modulation */
			add data2, temp, data1
			ldr temp2, STS32_MODULATION_MAX_ADDR
			str data2, [temp2]

			/* Minimum Frequency on Modulation */
			sub data2, temp, data1
			ldr temp2, STS32_MODULATION_MIN_ADDR
			str data2, [temp2]

			b sts32_synthemidi_success

		sts32_synthemidi_control_gp2:
			/* Maximum Value 16000, Divisor */
			mov temp, #0x3E00                                  @ Decimal 16000
			orr temp, temp, #0x0080                            @ Decimal 16000
			vmov vfp_temp, temp
			vcvt.f32.u32 vfp_temp, vfp_temp

			/* If 16001 - 16383, Saturate to 16000, (Range 0 - 16383, Bit[13:0]) */
			cmp data2, temp
			movhi data2, temp

			vmov vfp_volume, data2
			vcvt.f32.u32 vfp_volume, vfp_volume

			/* Value of Multiplier */
			mov temp, #4
			vmov vfp_temp2, temp
			vcvt.f32.u32 vfp_temp2, vfp_temp2

			vdiv.f32 vfp_volume, vfp_volume, vfp_temp          @ Range 0 - 16000 to 0 - 1.0
			vmul.f32 vfp_volume, vfp_volume, vfp_temp2         @ Range 0 - 4.0

			vmov temp, vfp_volume
			str temp, STS32_SYNTHEMIDI_SUBPITCH

			b sts32_synthemidi_success

		sts32_synthemidi_control_gp3:
			/* Maximum Value 16000, Divisor */
			mov temp, #0x3E00                                  @ Decimal 16000
			orr temp, temp, #0x0080                            @ Decimal 16000
			vmov vfp_temp, temp
			vcvt.f32.u32 vfp_temp, vfp_temp

			/* If 16001 - 16383, Saturate to 16000, (Range 0 - 16383, Bit[13:0]) */
			cmp data2, temp
			movhi data2, temp

			vmov vfp_volume, data2
			vcvt.f32.u32 vfp_volume, vfp_volume

			/* Value of Multiplier */
			ldr temp, sts32_syntheplay_MATH32_PI_DOUBLE
			vldr vfp_temp2, [temp]

			vdiv.f32 vfp_volume, vfp_volume, vfp_temp          @ Range 0 - 16000 to 0 - 1.0
			vmul.f32 vfp_volume, vfp_volume, vfp_temp2         @ Range 0 - 2PI

			vmov temp, vfp_volume
			str temp, STS32_SYNTHEMIDI_SUBAMP
			/* Warning on Assmbler
			vstr vfp_volume, STS32_SYNTHEMIDI_SUBAMP
			*/

			b sts32_synthemidi_success

		sts32_synthemidi_control_gp4:
			/* Virtual Parallel of Coconuts */
			lsr data2, data2, #7                               @ Use Only MSB[13:7]
			ldr temp, STS32_VIRTUAL_PARALLEL_ADDR
			str data2, [temp]

			b sts32_synthemidi_success

		sts32_synthemidi_control_release:
			/* (data^2) / 8 */
			mul data2, data2, data2
			lsr data2, data2, #3
			cmp data2, #0
			moveq data2, #1
			str data2, STS32_SYNTHEMIDI_RELEASE

			b sts32_synthemidi_success

		sts32_synthemidi_control_attack:
			/* (data^2) / 8 */
			mul data2, data2, data2
			lsr data2, data2, #3
			cmp data2, #0
			moveq data2, #1
			str data2, STS32_SYNTHEMIDI_ATTACK

			b sts32_synthemidi_success

		sts32_synthemidi_control_decay:
			/* (data^2) / 8 */
			mul data2, data2, data2
			lsr data2, data2, #3
			cmp data2, #0
			moveq data2, #1
			str data2, STS32_SYNTHEMIDI_DECAY

			b sts32_synthemidi_success

		sts32_synthemidi_control_sustain:
			/* data / 127 */
			vmov vfp_volume, data2
			vcvt.f32.u32 vfp_volume, vfp_volume
			mov temp, #127
			vmov vfp_temp, temp
			vcvt.f32.u32 vfp_temp, vfp_temp
			vdiv.f32 vfp_volume, vfp_volume, vfp_temp
			vmov temp, vfp_volume
			str temp, STS32_SYNTHEMIDI_SUSTAIN

			b sts32_synthemidi_success

		sts32_synthemidi_control_others:
			b sts32_synthemidi_success

	sts32_synthemidi_programchange:
		cmp count, #2
		blo sts32_synthemidi_success

		ldr temp, STS32_SYNTHEMIDI_CTL
		ldrh temp, [temp]                              @ Bank Select Bit[13:0]
		lsl temp, temp, #7                             @ Bit[20:7] (Bank Select)
		orr data1, data1, temp                         @ Bit[20:7] (Bank Select) or Bit[6:0] (data1)

		cmp data1, #equ32_sts32_synthemidi_presets
		movhi data1, #equ32_sts32_synthemidi_presets
		mov data2, #24                                 @ One Presets has 24 Bytes
		mul data1, data1, data2
		ldr temp, STS32_SYNTHEMIDI_TABLEPRESETS

		ldr temp2, [temp, data1]
		str temp2, STS32_SYNTHEMIDI_SUBPITCH
		add data1, data1, #4

		ldr temp2, [temp, data1]
		str temp2, STS32_SYNTHEMIDI_SUBAMP
		add data1, data1, #4

		ldr temp2, [temp, data1]
		str temp2, STS32_SYNTHEMIDI_ATTACK
		add data1, data1, #4

		ldr temp2, [temp, data1]
		str temp2, STS32_SYNTHEMIDI_DECAY
		add data1, data1, #4

		ldr temp2, [temp, data1]
		str temp2, STS32_SYNTHEMIDI_RELEASE
		add data1, data1, #4

		ldr temp2, [temp, data1]
		str temp2, STS32_SYNTHEMIDI_SUSTAIN

		mov count, #0
		b sts32_synthemidi_success

	sts32_synthemidi_monoaftertouch:
		cmp count, #2
		blo sts32_synthemidi_success

		mov count, #0
		b sts32_synthemidi_success

	sts32_synthemidi_pitchbend:
		cmp count, #3
		blo sts32_synthemidi_success

		/* Concatenate Data1 and Data2, 0 to 16383, 8192 (0x2000) is Neutral */
		lsl data2, data2, #7                          @ MSB Bit[13:7]
		orr data1, data1, data2
		lsr data1, data1, #2                          @ Divisor of Resolution (This Case Divided by 4)
		sub data1, data1, #0x800                      @ Neutral (8192 / 4) to 0, Make Signed Value

		cmp mode, #0
		moveq data2, #equ32_sts32_mul_pwm
		moveq temp, #equ32_sts32_neutraldiv_pwm
		movne data2, #equ32_sts32_mul_pcm
		movne temp, #equ32_sts32_neutraldiv_pcm
		mul data1, data1, data2                       @ Multiply with Multiplier

		sub data1, temp, data1                        @ Subtract Pitch Bend Ratio to Neutral Divisor (Upside Down)

		push {r0-r3}
		cmp mode, #0
		moveq r0, #equ32_cm_pwm
		movne r0, #equ32_cm_pcm
		mov r1, data1
		bl arm32_clockmanager_divisor
		pop {r0-r3}

		ldr temp, STS32_DIVISOR_ADDR
		str data1, [temp]

		ldr temp, STS32_MODULATION_RANGE_ADDR
		ldr data2, [temp]

		/* Maximum Value of Modulation */
		add temp2, data1, data2
		ldr temp, STS32_MODULATION_MAX_ADDR
		str temp2, [temp]

		/* Minimum Value of Modulation */
		sub temp2, data1, data2
		ldr temp, STS32_MODULATION_MIN_ADDR
		str temp2, [temp]

		mov count, #0
		b sts32_synthemidi_success

	sts32_synthemidi_systemcommon:
		b sts32_synthemidi_success

	sts32_synthemidi_status:
		/* If 0b11111000 and Above, Jump to Event on System Real Time Messages */
		cmp byte, #248
		bhs sts32_synthemidi_systemrealtime

		bic temp, byte, #0xF0
		cmp temp, channel
		movne count, #0
		bne sts32_synthemidi_error2   @ If Channel Is Not Matched

		/* Channel Is Matched */
		lsr byte, byte, #4            @ Omit Channel Number
		strb byte, [buffer]
		mov count, #1
		b sts32_synthemidi_success

	sts32_synthemidi_systemrealtime:

		/* If Reset, Hook to Note Off Event */
		/*
		cmp byte, #255
		moveq count #3
		beq sts32_synthemidi_noteoff
		*/

		mov count, #0
		b sts32_synthemidi_success

	sts32_synthemidi_error1:
		push {r0-r3}
		bl uart32_uartclrrx           @ Clear RxFIFO
		pop {r0-r3}
		mov r0, #1
		b sts32_synthemidi_common

	sts32_synthemidi_error2:
		mov r0, #2
		b sts32_synthemidi_common

	sts32_synthemidi_error3:
		mov r0, #3
		b sts32_synthemidi_common

	sts32_synthemidi_success:
		mov r0, #0

	sts32_synthemidi_common:
		str count, STS32_SYNTHEMIDI_COUNT
		macro32_dsb ip
/*
macro32_debug_hexa buffer, 100, 100, 8
*/
		vpop {s0-s3}
		pop {r4-r11,pc}

.unreq channel
.unreq mode
.unreq buffer
.unreq count
.unreq temp2
.unreq voices
.unreq byte
.unreq temp
.unreq data1
.unreq data2
.unreq status_voices
.unreq num_voices
.unreq vfp_volume
.unreq vfp_sustain
.unreq vfp_temp
.unreq vfp_temp2

STS32_SYNTHEMIDI_SUBPITCH:       .float 1.0
STS32_SYNTHEMIDI_SUBAMP:         .float 0.0

STS32_SYNTHEMIDI_COUNT:          .word 0x00
STS32_SYNTHEMIDI_LENGTH:         .word 0x00
STS32_SYNTHEMIDI_BUFFER:         .word 0x00 @ Second Buffer to Store Outstanding MIDI Message
STS32_SYNTHEMIDI_BYTEBUFFER:     .word _STS32_SYNTHEMIDI_BYTEBUFFER
STS32_SYNTHEMIDI_CURRENTNOTE:    .word _STS32_SYNTHEMIDI_CURRENTNOTE
STS32_SYNTHEMIDI_TABLENOTES:     .word 0x00
STS32_SYNTHEMIDI_TABLEPRESETS:   .word 0x00

STS32_SYNTHEMIDI_CTL:            .word 0x00 @ Value List of Control Message, 32 Multiplied by 2 (Two Bytes Half Word), No. 0 to No. 31 of Control Change Message
STS32_VIRTUAL_PARALLEL_ADDR:     .word STS32_VIRTUAL_PARALLEL

STS32_SYNTHEMIDI_ATTACK:         .word equ32_sts32_synthemidi_attack
STS32_SYNTHEMIDI_DECAY:          .word equ32_sts32_synthemidi_decay
STS32_SYNTHEMIDI_SUSTAIN:        .float 1.0
STS32_SYNTHEMIDI_RELEASE:        .word equ32_sts32_synthemidi_release
STS32_SYNTHEMIDI_VOLUME:         .word equ32_sts32_synthemidi_volume

STS32_SYNTHEMIDI_ENVELOPE:       .word STS32_SYNTHEMIDI_COUNT1

STS32_DIVISOR_ADDR:              .word STS32_DIVISOR
STS32_MODULATION_DELTA_ADDR:     .word STS32_MODULATION_DELTA
STS32_MODULATION_MAX_ADDR:       .word STS32_MODULATION_MAX
STS32_MODULATION_MIN_ADDR:       .word STS32_MODULATION_MIN
STS32_MODULATION_RANGE_ADDR:     .word STS32_MODULATION_RANGE

STS32_DIGITALMOD_DELTA_ADDR:     .word STS32_DIGITALMOD_DELTA
STS32_DIGITALMOD_MAX_ADDR:       .word STS32_DIGITALMOD_MAX
STS32_DIGITALMOD_MIN_ADDR:       .word STS32_DIGITALMOD_MIN
STS32_DIGITALMOD_MEDIUM_ADDR:    .word STS32_DIGITALMOD_MEDIUM

STS32_TONE_ADDR:                 .word STS32_TONE

/* To Store and Load Data in User Mode, Actual Data Is Placed in ".data" Section */
.section	.data
_STS32_SYNTHEMIDI_BYTEBUFFER:    .word 0x00 @ First Buffer to Receive A Byte from UART
_STS32_SYNTHEMIDI_CURRENTNOTE:   .space 8, 0x00
STS32_SYNTHEWAVE_FREQA_L:        .word 0x00
STS32_SYNTHEWAVE_AMPA_L:         .word 0x00
STS32_SYNTHEWAVE_FREQB_L:        .word 0x00
STS32_SYNTHEWAVE_AMPB_L:         .word 0x00
STS32_SYNTHEWAVE_FREQA_R:        .word 0x00
STS32_SYNTHEWAVE_AMPA_R:         .word 0x00
STS32_SYNTHEWAVE_FREQB_R:        .word 0x00
STS32_SYNTHEWAVE_AMPB_R:         .word 0x00
.space 96, 0x00                             @ Rest 6 Sets
STS32_SYNTHEMIDI_COUNT1:         .word 0x00
STS32_SYNTHEMIDI_DELTA_ATTACK1:  .float 0.0
STS32_SYNTHEMIDI_DELTA_DECAY1:   .float 0.0
STS32_SYNTHEMIDI_DELTA_RELEASE1: .float 0.0
STS32_SYNTHEMIDI_COUNT2:         .word 0x00
STS32_SYNTHEMIDI_DELTA_ATTACK2:  .float 0.0
STS32_SYNTHEMIDI_DELTA_DECAY2:   .float 0.0
STS32_SYNTHEMIDI_DELTA_RELEASE2: .float 0.0
.space 96, 0x00                             @ Rest 6 Sets
.globl STS32_VIRTUAL_PARALLEL
STS32_VIRTUAL_PARALLEL:          .word 0x00 @ Emulate Parallel Inputs Through MIDI IN
.globl STS32_DIVISOR
STS32_DIVISOR:                   .word 0x00
.globl STS32_MODULATION_DELTA
STS32_MODULATION_DELTA:          .word 0x00
.globl STS32_MODULATION_MAX
STS32_MODULATION_MAX:            .word 0x00
.globl STS32_MODULATION_MIN
STS32_MODULATION_MIN:            .word 0x00
.globl STS32_MODULATION_RANGE
STS32_MODULATION_RANGE:          .word 0x00
.globl STS32_DIGITALMOD_DELTA
STS32_DIGITALMOD_DELTA:          .float 0.0
.globl STS32_DIGITALMOD_MAX
STS32_DIGITALMOD_MAX:            .float 1.2
.globl STS32_DIGITALMOD_MIN
STS32_DIGITALMOD_MIN:            .float 0.8
.globl STS32_DIGITALMOD_MEDIUM
STS32_DIGITALMOD_MEDIUM:         .float 1.0
.globl STS32_TONE
STS32_TONE:                      .float 0.0
.section	.library_system32


/**
 * function sts32_synthemidi_malloc
 * Make Buffer for Function, sts32_synthemidi
 *
 * Parameters
 * r0: Size of Buffer (Words)
 * r1: Pointer of Table of Notes Frequency
 * r2: Pointer of Table of Presets
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Memory Allocation Is Not Succeeded
 */
.globl sts32_synthemidi_malloc
sts32_synthemidi_malloc:
	/* Auto (Local) Variables, but just Aliases */
	words_buffer .req r0
	addr_table   .req r1
	addr_presets .req r2
	buffer       .req r3

	push {lr}

	/* Buffer to Receive MIDI Message */
	push {r0-r2}
	bl heap32_malloc
	mov buffer, r0
	pop {r0-r2}

	cmp buffer, #0
	beq sts32_synthemidi_malloc_error

	lsl words_buffer, words_buffer, #2             @ Multiply by 4
	sub words_buffer, words_buffer, #1             @ Subtract One Byte for Null Character
	str words_buffer, STS32_SYNTHEMIDI_LENGTH
	str buffer, STS32_SYNTHEMIDI_BUFFER
	mov words_buffer, #0
	str words_buffer, STS32_SYNTHEMIDI_COUNT

	/* Buffer for Control Message No. 0 to No. 31 */
	push {r0-r2}
	mov r0, #16                                    @ 16 Words Multiplied by 4 Bytes Equals 64 Bytes (2 Bytes Half Word * 32)
	bl heap32_malloc
	mov buffer, r0
	pop {r0-r2}

	cmp buffer, #0
	beq sts32_synthemidi_malloc_error

	str buffer, STS32_SYNTHEMIDI_CTL

	str addr_table, STS32_SYNTHEMIDI_TABLENOTES
	str addr_presets, STS32_SYNTHEMIDI_TABLEPRESETS

	b sts32_synthemidi_malloc_success

	sts32_synthemidi_malloc_error:
		mov r0, #1
		b sts32_synthemidi_malloc_common

	sts32_synthemidi_malloc_success:
		mov r0, #0

	sts32_synthemidi_malloc_common:
		macro32_dsb ip
		pop {pc}

.unreq words_buffer
.unreq addr_table
.unreq addr_presets
.unreq buffer


/**
 * function sts32_synthemidi_envelope
 * Make Envelope for Notes from MIDI IN
 *
 * Parameters
 * r0: Number of Voices
 *
 * Return: r0 (0 as success)
 */
.globl sts32_synthemidi_envelope
sts32_synthemidi_envelope:
	/* Auto (Local) Variables, but just Aliases */
	num_voices     .req r0
	status_voices  .req r1
	addr_envelope  .req r2
	addr_param     .req r3
	voices         .req r4
	check          .req r5
	offset         .req r6
	count          .req r7
	max_count      .req r8
	addr           .req r9

	/* VFP Registers */
	vfp_volume     .req s0
	vfp_delta      .req s1

	push {r4-r9,lr}
	vpush {s0-s1}

	cmp num_voices, #equ32_sts32_voice_max
	movhi num_voices, #equ32_sts32_voice_max

	ldr status_voices, STS32_VOICES
	ldr addr_envelope, STS32_SYNTHEMIDI_ENVELOPE
	ldr addr_param, STS32_SYNTHEWAVE_PARAM

	mov voices, #0
	sts32_synthemidi_envelope_loop:
		cmp voices, num_voices
		bhs sts32_synthemidi_envelope_success

		/* Test Whether The Voice Is under Usage with MIDI or Not */
		lsl offset, voices, #2              @ Multiply by 4
		mov check, #0b111
		lsl check, check, offset
		tst status_voices, check
		beq sts32_synthemidi_envelope_loop_common

		lsr check, status_voices, offset
		and check, check, #0b111
		cmp check, #0b001
		beq sts32_synthemidi_envelope_loop_attack
		cmp check, #0b010
		beq sts32_synthemidi_envelope_loop_decay
		cmp check, #0b011
		beq sts32_synthemidi_envelope_loop_sustain
		cmp check, #0b100
		bhs sts32_synthemidi_envelope_loop_release

		sts32_synthemidi_envelope_loop_attack:
			lsl offset, voices, #4                   @ Multiply by 16, 16 Bytes (Four Words) Offset for Each Parameter

			/* Increase Volume (Main Amplitude) */
			add addr, addr_envelope, offset          @ Pointer for Envelope
			add addr, addr, #4                       @ Add Offset for Attack Delta
			vldr vfp_delta, [addr]

			add addr, addr_param, offset             @ Pointer for Parameter
			add addr, addr, #4                       @ Main Amplitude
			vldr vfp_volume, [addr]

			vadd.f32 vfp_volume, vfp_volume, vfp_delta
			vstr vfp_volume, [addr]

			/* Increase Count, Reset Count and Change The Voice Status to 2 If Reaches Maximum */
			add addr, addr_envelope, offset          @ Pointer for Envelope
			ldr count, [addr]
			ldr max_count, STS32_SYNTHEMIDI_ATTACK
			add count, count, #1
			cmp count, max_count
			movhs count, #0
			lslhs offset, voices, #2                 @ Multiply by 4
			movhs check, #0b1
			lslhs check, check, offset
			addhs status_voices, status_voices, check
			str count, [addr]

			b sts32_synthemidi_envelope_loop_common

		sts32_synthemidi_envelope_loop_decay:
			lsl offset, voices, #4                   @ Multiply by 16, 16 Bytes (Four Words) Offset for Each Parameter

			/* Decrease Volume (Main Amplitude) */
			add addr, addr_envelope, offset          @ Pointer for Envelope
			add addr, addr, #8                       @ Add Offset for Delay Delta
			vldr vfp_delta, [addr]

			add addr, addr_param, offset             @ Pointer for Parameter
			add addr, addr, #4                       @ Main Amplitude
			vldr vfp_volume, [addr]

			vsub.f32 vfp_volume, vfp_volume, vfp_delta
			vstr vfp_volume, [addr]

			/* Increase Count, Reset Count and Change The Voice Status to 3 If Reaches Maximum */
			add addr, addr_envelope, offset          @ Pointer for Envelope
			ldr count, [addr]
			ldr max_count, STS32_SYNTHEMIDI_DECAY
			add count, count, #1
			cmp count, max_count
			movhs count, #0
			lslhs offset, voices, #2                 @ Multiply by 4
			movhs check, #0b1
			lslhs check, check, offset
			addhs status_voices, status_voices, check
			str count, [addr]
			b sts32_synthemidi_envelope_loop_common

		sts32_synthemidi_envelope_loop_sustain:
			/* Do Nothing */
			b sts32_synthemidi_envelope_loop_common

		sts32_synthemidi_envelope_loop_release:
			lsl offset, voices, #4                   @ Multiply by 16, 16 Bytes (Four Words) Offset for Each Parameter

			/* Decrease Volume (Main Amplitude) */
			add addr, addr_envelope, offset          @ Pointer for Envelope
			add addr, addr, #12                      @ Add Offset for Release Delta
			vldr vfp_delta, [addr]

			add addr, addr_param, offset             @ Pointer for Parameter
			add addr, addr, #4                       @ Main Amplitude
			vldr vfp_volume, [addr]

			vsub.f32 vfp_volume, vfp_volume, vfp_delta
			vstr vfp_volume, [addr]

			/* Increase Count, Reset Count and Change The Voice Status to 0 If Reaches Maximum */
			add addr, addr_envelope, offset          @ Pointer for Envelope
			ldr count, [addr]
			ldr max_count, STS32_SYNTHEMIDI_RELEASE
			add count, count, #1
			cmp count, max_count
			movhs count, #0
			lslhs offset, voices, #2                 @ Multiply by 4
			movhs check, #0b111
			lslhs check, check, offset
			bichs status_voices, status_voices, check
			str count, [addr]

		sts32_synthemidi_envelope_loop_common:
			add voices, voices, #1
			b sts32_synthemidi_envelope_loop

	sts32_synthemidi_envelope_success:
		str status_voices, STS32_VOICES
		mov r0, #0

	sts32_synthemidi_envelope_common:
		macro32_dsb ip
		vpop {s0-s1}
		pop {r4-r9,pc}

.unreq num_voices
.unreq status_voices
.unreq addr_envelope
.unreq addr_param
.unreq voices
.unreq check
.unreq offset
.unreq count
.unreq max_count
.unreq addr
.unreq vfp_volume
.unreq vfp_delta


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
 * r0: Pointer of Array of Sequences of Synthesizer Pre-code (Two Dimentional, L and R Alternatively)
 * r1: Number of Voices
 *
 * Return: r0 (Pointer of Array of Synthesizer Code, If 0, 1, and 2 Error)
 * Error(0): Memory Space for Synthesizer Code is Not Allocated (On heap32_malloc)
 * Error(1): Memory Space for Synthesizer Code is Not Allocated (On sts32_synthedecode)
 * Error(2): Overflow of Memory Space (On sts32_synthedecode)
 */
.globl sts32_synthedecodelr
sts32_synthedecodelr:
	/* Auto (Local) Variables, but just Aliases */
	array_synt_pre_point .req r0
	num_voices           .req r1
	beat                 .req r2
	temp                 .req r3
	heap                 .req r4
	result               .req r5
	voices               .req r6

	push {r4-r6,lr}

	cmp num_voices, #equ32_sts32_voice_max
	movhi num_voices, #equ32_sts32_voice_max

	/**
	 * Get Maximum Beat Length
	 */
	mov beat, #0
	mov voices, #0
	sts32_synthedecodelr_beatlen:
		cmp voices, num_voices
		bhs sts32_synthedecodelr_malloc

		lsl temp, voices, #2                 @ Multiply by 4

		push {r0-r2}
		ldr r0, [array_synt_pre_point, temp]
		bl sts32_synthebeatlen
		mov temp, r0
		pop {r0-r2}

		cmp temp, beat
		movhi beat, temp

		add voices, voices, #1
		b sts32_synthedecodelr_beatlen

	sts32_synthedecodelr_malloc:
		lsl temp, num_voices, #1             @ Multiply by 2, One Synthesizer Code on Each Voice Has Two Words (64-bit, 8 Bytes)
		mul beat, beat, temp
		add beat, beat, #2                   @ End of Synthe Code (64-bit, 8 Bytes)

		push {r0-r3}
		mov r0, beat                         @ The Number of Words (32-bit, 4 Bytes)
		bl heap32_malloc
		mov heap, r0
		pop {r0-r3}

		cmp heap, #0
		beq sts32_synthedecodelr_common

	mov voices, #0
	sts32_synthedecodelr_decode:
		cmp voices, num_voices
		bhs sts32_synthedecodelr_common

		lsl temp, voices, #2                 @ Multiply by 4

		push {r0-r3}
		mov r2, num_voices                   @ num_voices is r1
		ldr r1, [array_synt_pre_point, temp] @ Using r0 and r3
		mov r0, heap
		mov r3, voices
		bl sts32_synthedecode
		mov result, r0
		pop {r0-r3}

		cmp result, #0
		movne heap, result
		bne sts32_synthedecodelr_common

		add voices, voices, #1
		b sts32_synthedecodelr_decode

	sts32_synthedecodelr_common:
		mov r0, heap
		pop {r4-r6,pc}

.unreq array_synt_pre_point
.unreq num_voices
.unreq beat
.unreq temp
.unreq heap
.unreq result
.unreq voices


/**
 * function sts32_synthedecode
 * Make Synthesizer Code from Pre-code
 *
 * Parameters
 * r0: Pointer of Array of Synthesizer Code
 * r1: Pointer of Array of Synthesizer Pre-code
 * r2: Number of Voices (Total)
 * r3: Offset, L1 = First Voice (0), R1 = Second Voice (1), L2 = Third Voice (2), R2 = Fourth Voice (3), etc.
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
	stride_voices     .req r2
	synt_max_length   .req r3
	synt_pre_length   .req r4
	code_lower        .req r5
	code_upper        .req r6
	temp              .req r7
	attack_length     .req r8
	decay_length      .req r9
	release_length    .req r10
	beat_length       .req r11

	/* VFP Registers */
	vfp_volume        .req s0
	vfp_attack        .req s1
	vfp_decay         .req s2
	vfp_sustain       .req s3
	vfp_release       .req s4
	vfp_beat_length   .req s5
	vfp_temp          .req s6
	vfp_attack_delta  .req s7
	vfp_decay_delta   .req s8
	vfp_release_delta .req s9
	vfp_sustain_level .req s10
	vfp_one           .req s11

	push {r4-r11,lr}
	vpush {s0-s11}

	/* Move Fourth Parameter */
	mov temp, synt_max_length

	/* Check Size (Bytes) of Heap (synt_point) for Synthesizer Code */
	push {r0-r2}
	bl heap32_mcount
	mov synt_max_length, r0
	pop {r0-r2}

	cmp synt_max_length, #-1
	beq sts32_synthedecode_error1

	sub synt_max_length, synt_max_length, #8   @ Subtract for End of Synthe code

	/* Make Offset For The Voice */
	lsl temp, temp, #3                         @ Multiply by 8 (8 Bytes, Two Words, One Synthesizer Code)
	add synt_point, synt_point, temp

	lsl stride_voices, stride_voices, #3       @ Multiply by 8 (8 Bytes, Two Words, One Synthesizer Code), Make Offset for Total Voices

	push {r0-r2}
	mov r0, synt_max_length
	mov r1, stride_voices
	bl arm32_udiv
	mov synt_max_length, r0
	pop {r0-r2}

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

		/* Lower Half and Volume */
		ldr code_lower, [synt_pre_point]
		asr temp, code_lower, #17                      @ Arighmetic Logical Shift Right to Hold Signess, Bit[31:17]
		vmov vfp_volume, temp
		vcvt.f32.s32 vfp_volume, vfp_volume

		/* Upper Half */
		ldr code_upper, [synt_pre_point, #4]

		/* Beat Length */
		ldr beat_length, [synt_pre_point, #8]
		vmov vfp_beat_length, beat_length
		vcvt.f32.u32 vfp_beat_length, vfp_beat_length

		/* Attack Time */
		ldrb temp, [synt_pre_point, #12]
		cmp temp, #100
		movhi temp, #100                               @ Prevent Overflow
		vmov vfp_attack, temp
		vcvt.f32.u32 vfp_attack, vfp_attack

		/* Decay Time */
		ldrb temp, [synt_pre_point, #13]
		cmp temp, #100
		movhi temp, #100                               @ Prevent Overflow
		vmov vfp_decay, temp
		vcvt.f32.u32 vfp_decay, vfp_decay

		/* Sustain Level */
		ldrb temp, [synt_pre_point, #14]
		cmp temp, #100
		movhi temp, #100                               @ Prevent Overflow
		vmov vfp_sustain, temp
		vcvt.f32.u32 vfp_sustain, vfp_sustain

		/* Release Time */
		ldrb temp, [synt_pre_point, #15]
		cmp temp, #100
		movhi temp, #100                               @ Prevent Overflow
		vmov vfp_release, temp
		vcvt.f32.u32 vfp_release, vfp_release

		add synt_pre_point, synt_pre_point, #16        @ Offset for Next Pre-block

		/* Convert Percents to Decimal */

		mov temp, #100
		vmov vfp_temp, temp
		vcvt.f32.u32 vfp_temp, vfp_temp
		vdiv.f32 vfp_attack, vfp_attack, vfp_temp
		vdiv.f32 vfp_decay, vfp_decay, vfp_temp
		vdiv.f32 vfp_sustain, vfp_sustain, vfp_temp
		vdiv.f32 vfp_release, vfp_release, vfp_temp

		/* Attack Time and Attack Delta */

		vmul.f32 vfp_temp, vfp_beat_length, vfp_attack
		vdiv.f32 vfp_attack_delta, vfp_volume, vfp_temp
		vcvt.u32.f32 vfp_temp, vfp_temp
		vmov attack_length, vfp_temp

		/* Sustain Level */

		vmul.f32 vfp_sustain_level, vfp_volume, vfp_sustain

		/* Decay Time and Decay Delta */

		vmul.f32 vfp_temp, vfp_beat_length, vfp_decay
		vsub.f32 vfp_decay, vfp_volume, vfp_sustain_level
		vdiv.f32 vfp_decay_delta, vfp_decay, vfp_temp
		vcvt.u32.f32 vfp_temp, vfp_temp
		vmov decay_length, vfp_temp

		/* Release Time and Release Delta */

		vmul.f32 vfp_temp, vfp_beat_length, vfp_release
		vdiv.f32 vfp_release_delta, vfp_sustain_level, vfp_temp
		vcvt.u32.f32 vfp_temp, vfp_temp
		vmov release_length, vfp_temp

		/* Sustain Time */

		sub beat_length, beat_length, attack_length
		sub beat_length, beat_length, decay_length
		sub beat_length, beat_length, release_length

		.unreq beat_length
		sustain_length .req r11

		/* Check Overflow */

		cmp sustain_length, #0
		sublt release_length, release_length, sustain_length
		movlt sustain_length, #0

		cmp release_length, #0
		sublt decay_length, decay_length, release_length
		movlt release_length, #0

		cmp decay_length, #0
		sublt attack_length, attack_length, decay_length
		movlt decay_length, #0

		cmp attack_length, #0
		movlt attack_length, #0

		/* Volume 0.0 for Further Prcocesses */

		.unreq vfp_one
		vfp_zero .req s11

		mov temp, #0
		vmov vfp_volume, temp
		vmov vfp_zero, temp

		/* Clear Volume Bit[31:17] */

		bic code_lower, code_lower, #0xFF000000
		bic code_lower, code_lower, #0x00FE0000

/*
macro32_debug synt_max_length, 200, 0
macro32_debug attack_length, 200, 12
macro32_debug sustain_length, 200, 24
macro32_debug release_length, 200, 36
macro32_debug synt_point, 200, 48
*/

		sts32_synthedecode_main_attack:
			subs attack_length, attack_length, #1
			ldrlt code_lower, [synt_pre_point, #-16]            @ Retrieve Original Volume for Flat Part
			asrlt temp, code_lower, #17                         @ Arighmetic Logical Shift Right to Hold Signess, Bit[31:17]
			vmovlt vfp_volume, temp
			vcvtlt.f32.s32 vfp_volume, vfp_volume
			blt sts32_synthedecode_main_decay
			subs synt_max_length, synt_max_length, #1
			blt sts32_synthedecode_error2

			str code_lower, [synt_point]
			str code_upper, [synt_point, #4]
			add synt_point, synt_point, stride_voices

			vadd.f32 vfp_volume, vfp_volume, vfp_attack_delta
			vcvtr.s32.f32 vfp_temp, vfp_volume
			vmov temp, vfp_temp
			lsl temp, temp, #17                                 @ Bit[31:17]
			bic code_lower, code_lower, #0xFF000000
			bic code_lower, code_lower, #0x00FE0000
			orr code_lower, code_lower, temp

			b sts32_synthedecode_main_attack

		sts32_synthedecode_main_decay:
			subs decay_length, decay_length, #1
			vmovlt vfp_volume, vfp_sustain_level
			blt sts32_synthedecode_main_sustain
			subs synt_max_length, synt_max_length, #1
			blt sts32_synthedecode_error2

			str code_lower, [synt_point]
			str code_upper, [synt_point, #4]
			add synt_point, synt_point, stride_voices

			vsub.f32 vfp_volume, vfp_volume, vfp_decay_delta
			vcvtr.s32.f32 vfp_temp, vfp_volume
			vmov temp, vfp_temp
			lsl temp, temp, #17                                 @ Bit[31:17]
			bic code_lower, code_lower, #0xFF000000
			bic code_lower, code_lower, #0x00FE0000
			orr code_lower, code_lower, temp

			b sts32_synthedecode_main_decay

		sts32_synthedecode_main_sustain:
			subs sustain_length, sustain_length, #1
			blt sts32_synthedecode_main_release
			subs synt_max_length, synt_max_length, #1
			blt sts32_synthedecode_error2

			str code_lower, [synt_point]
			str code_upper, [synt_point, #4]
			add synt_point, synt_point, stride_voices

			b sts32_synthedecode_main_sustain

		sts32_synthedecode_main_release:
			subs release_length, release_length, #1
			blt sts32_synthedecode_main
			subs synt_max_length, synt_max_length, #1
			blt sts32_synthedecode_error2

			str code_lower, [synt_point]
			str code_upper, [synt_point, #4]
			add synt_point, synt_point, stride_voices

			vsub.f32 vfp_volume, vfp_volume, vfp_release_delta
			vcvtr.s32.f32 vfp_temp, vfp_volume
			vmov temp, vfp_temp
			lsl temp, temp, #17                                 @ Bit[31:17]
			bic code_lower, code_lower, #0xFF000000
			bic code_lower, code_lower, #0x00FE0000
			orr code_lower, code_lower, temp

			b sts32_synthedecode_main_release

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
		vpop {s0-s11}
		pop {r4-r11,pc}

.unreq synt_point
.unreq synt_pre_point
.unreq stride_voices
.unreq synt_max_length
.unreq synt_pre_length
.unreq code_lower
.unreq code_upper
.unreq temp
.unreq attack_length
.unreq decay_length
.unreq release_length
.unreq sustain_length
.unreq vfp_volume
.unreq vfp_attack
.unreq vfp_decay
.unreq vfp_sustain
.unreq vfp_release
.unreq vfp_beat_length
.unreq vfp_temp
.unreq vfp_attack_delta
.unreq vfp_decay_delta
.unreq vfp_release_delta
.unreq vfp_sustain_level
.unreq vfp_zero

