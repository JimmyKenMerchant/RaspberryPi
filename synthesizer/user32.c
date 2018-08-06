/**
 * user32.c
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

#include "system32.h"
#include "system32.c"
#include "sts32.h"

#define timer_count_multiplicand        1
#define timer_count_multiplier_default  30
#define timer_count_multiplier_minlimit 10
#define timer_count_multiplier_maxlimit 50

/**
 * In default, there is a 2000hz synchronization clock (it's a half of 2400Hz on Arm Timer beacause of toggling).
 * Arm Timer sets 120000Hz as clock.
 * 30 is divisor (timer_count_multiplicand * timer_count_multiplier_defualt), i.e., 120000 / 30 / 2 equals 2000.
 * The Maximum beat (120000 / (timer_count_multiplicand * timer_count_multiplier_minlimit) / 2) is 6000Hz.
 * The minimum beat (120000 / (timer_count_multiplicand * timer_count_multiplier_maxlimit) / 2) is 1200Hz.
 */

/**
 * Synthesizer Code is 64-bit Block (Two 32-bit Words) consists two frequencies and magnitudes to Synthesize.
 * Lower Bit[13-0] Frequency-A (Main): 0 to 16383 Hz
 * Lower Bit[15-14] Decimal Part of Frequency-A (Main): 0b as 0.0, 1b as 0.25, 10b as 0.5, 11b as 0.75
 * Lower Bit[31-16] Magnitude-A = Volume: -32768 to 32767, Minus for Inverted Wave
 * Higher Bit[13-0] Frequency-B (Sub): 0 to 16383 Hz
 * Higher Bit[15-14] Decimal Part of Frequency-B (Sub): 0b as 0.0, 1b as 0.25, 10b as 0.5, 11b as 0.75
 * Higher Bit[31-16] Magnitude-B: 0 to 65535, 1 is 2Pi/65535, 65535 is 2Pi
 * The wave is synthesized the formula:
 * Amplitude on T = Magnitude-A * sin((T * (2Pi * Frequency-A)) + Magnitude-B * sin(T * (2Pi * Frequency-B))).
 * Where T is time (seconds); one is 1/sampling-rate seconds.
 * This type of synthesizers is named as "Frequency Modulation Synthesis" developed by John Chowning, and decorated the music world in the late 20th century.
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

synthe_precode pre_synthe1_l[] = {
	_3_BIG(_RAP(
	_2(_RAP(
	_D6<<_FREQ|3000<<_MAG,_D6<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_F6<<_FREQ|3000<<_MAG,_F6<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_A6<<_FREQ|3000<<_MAG,_A6<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_F6<<_FREQ|3000<<_MAG,_F6<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL
	))
	_2(_RAP(
	_G6<<_FREQ|3000<<_MAG,_G6<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_B6<<_FREQ|3000<<_MAG,_B6<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_D7<<_FREQ|3000<<_MAG,_D7<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_B6<<_FREQ|3000<<_MAG,_B6<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL
	))
	_2(_RAP(
	_C6<<_FREQ|3000<<_MAG,_C6<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_E6<<_FREQ|3000<<_MAG,_E6<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_G6<<_FREQ|3000<<_MAG,_G6<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_E6<<_FREQ|3000<<_MAG,_E6<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL
	))
	_2(_RAP(
	_D6<<_FREQ|3000<<_MAG,_D6<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_F6<<_FREQ|3000<<_MAG,_F6<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_A6<<_FREQ|3000<<_MAG,_A6<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_F6<<_FREQ|3000<<_MAG,_F6<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL
	))
	))
	_END
};

synthe_precode pre_synthe1_r[] = {
	_3_BIG(_RAP(
	_2(_RAP(
	_D7<<_FREQ|3000<<_MAG,_D7<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_F7<<_FREQ|3000<<_MAG,_F7<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_A7<<_FREQ|3000<<_MAG,_A7<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_F7<<_FREQ|3000<<_MAG,_F7<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL
	))
	_2(_RAP(
	_G7<<_FREQ|3000<<_MAG,_G7<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_B7<<_FREQ|3000<<_MAG,_B7<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_D8<<_FREQ|3000<<_MAG,_D8<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_B7<<_FREQ|3000<<_MAG,_B7<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL
	))
	_2(_RAP(
	_C7<<_FREQ|3000<<_MAG,_C7<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_E7<<_FREQ|3000<<_MAG,_E7<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_G7<<_FREQ|3000<<_MAG,_G7<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_E7<<_FREQ|3000<<_MAG,_E7<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL
	))
	_2(_RAP(
	_D7<<_FREQ|3000<<_MAG,_D7<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_F7<<_FREQ|3000<<_MAG,_F7<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_A7<<_FREQ|3000<<_MAG,_A7<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL,
	_F7<<_FREQ|3000<<_MAG,_F7<<_FREQ|00000<<_MAG,250<<_BEAT,30<<_RIS|70<<_FAL
	))
	))
	_END
};

/* Rhythm of Drum 'n' Bass: Cymbal Part */
synthe_precode pre_synthe2_l[] = {
	// One
	_3(_RAP(
	_D6<<_FREQ|1000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|1000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|4000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|1000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|1000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|1000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|1000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|4000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,

	_D6<<_FREQ|1000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|1000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|4000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|1000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|1000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|1000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|1000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|4000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL
	))

	// Four
	_D6<<_FREQ|1000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|1000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|4000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|1000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|1000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|1000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|1000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|4000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,

	_D6<<_FREQ|4000<<_MAG,_D7<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,500<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|4000<<_MAG,_D7<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,500<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|4000<<_MAG,_D7<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,

	_END
};

/* Rhythm of Drum 'n' Base: Bass and Snare Parts */
synthe_precode pre_synthe2_r[] = {
	// One
	_3(_RAP(
	_D2<<_FREQ|4000<<_MAG,_D2<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_A4<<_FREQ|4000<<_MAG,_B4<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_A4<<_FREQ|100<<_MAG,_B4<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_A4<<_FREQ|100<<_MAG,_B4<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D2<<_FREQ|4000<<_MAG,_D2<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_A4<<_FREQ|4000<<_MAG,_B4<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,

	_D2<<_FREQ|4000<<_MAG,_D2<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_A4<<_FREQ|4000<<_MAG,_B4<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_A4<<_FREQ|100<<_MAG,_B4<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_A4<<_FREQ|100<<_MAG,_B4<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D2<<_FREQ|4000<<_MAG,_D2<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_A4<<_FREQ|4000<<_MAG,_B4<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL
	))

	// Four
	_D2<<_FREQ|4000<<_MAG,_D2<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_A4<<_FREQ|4000<<_MAG,_B4<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_A4<<_FREQ|100<<_MAG,_B4<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_A4<<_FREQ|100<<_MAG,_B4<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D2<<_FREQ|4000<<_MAG,_D2<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_A4<<_FREQ|4000<<_MAG,_B4<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,

	_D2<<_FREQ|4000<<_MAG,_D2<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_A4<<_FREQ|4000<<_MAG,_B4<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_A4<<_FREQ|4000<<_MAG,_B4<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D2<<_FREQ|4000<<_MAG,_D2<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_A4<<_FREQ|4000<<_MAG,_B4<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_A4<<_FREQ|4000<<_MAG,_B4<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D2<<_FREQ|4000<<_MAG,_D2<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_A4<<_FREQ|4000<<_MAG,_B4<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,
	_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|30000<<_MAG,125<<_BEAT,1<<_RIS|99<<_FAL,

	_END
};

synthe_precode pre_synthe8_l[] = {
	_D4<<_FREQ|3000<<_MAG,_D4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_G5<<_FREQ|3000<<_MAG,_G5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D4<<_FREQ|0000<<_MAG,_D4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_G5<<_FREQ|3000<<_MAG,_G5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D4<<_FREQ|3000<<_MAG,_D4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_G5<<_FREQ|3000<<_MAG,_G5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D4<<_FREQ|0000<<_MAG,_D4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_G5<<_FREQ|3000<<_MAG,_G5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D4<<_FREQ|3000<<_MAG,_D4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_G5<<_FREQ|3000<<_MAG,_G5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D4<<_FREQ|0000<<_MAG,_D4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_G5<<_FREQ|3000<<_MAG,_G5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D4<<_FREQ|3000<<_MAG,_D4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_G5<<_FREQ|3000<<_MAG,_G5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D4<<_FREQ|0000<<_MAG,_D4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_G5<<_FREQ|3000<<_MAG,_G5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_C4<<_FREQ|3000<<_MAG,_C4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_F5<<_FREQ|3000<<_MAG,_F5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_C4<<_FREQ|0000<<_MAG,_C4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_F5<<_FREQ|3000<<_MAG,_F5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_C4<<_FREQ|3000<<_MAG,_C4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_F5<<_FREQ|3000<<_MAG,_F5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_C4<<_FREQ|0000<<_MAG,_C4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_F5<<_FREQ|3000<<_MAG,_F5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_C4<<_FREQ|3000<<_MAG,_C4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_F5<<_FREQ|3000<<_MAG,_F5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_C4<<_FREQ|0000<<_MAG,_C4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_F5<<_FREQ|3000<<_MAG,_F5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_C4<<_FREQ|3000<<_MAG,_C4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_F5<<_FREQ|3000<<_MAG,_F5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_C4<<_FREQ|0000<<_MAG,_C4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_F5<<_FREQ|3000<<_MAG,_F5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_END
};

synthe_precode pre_synthe8_r[] = {
	_D4<<_FREQ|-3000<<_MAG,_D4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_G5<<_FREQ|-3000<<_MAG,_G5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D4<<_FREQ|00000<<_MAG,_D4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_G5<<_FREQ|-3000<<_MAG,_G5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D4<<_FREQ|-3000<<_MAG,_D4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_G5<<_FREQ|-3000<<_MAG,_G5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D4<<_FREQ|00000<<_MAG,_D4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_G5<<_FREQ|-3000<<_MAG,_G5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D4<<_FREQ|-3000<<_MAG,_D4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_G5<<_FREQ|-3000<<_MAG,_G5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D4<<_FREQ|00000<<_MAG,_D4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_G5<<_FREQ|-3000<<_MAG,_G5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D4<<_FREQ|-3000<<_MAG,_D4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_G5<<_FREQ|-3000<<_MAG,_G5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_D4<<_FREQ|00000<<_MAG,_D4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_G5<<_FREQ|-3000<<_MAG,_G5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_C4<<_FREQ|-3000<<_MAG,_C4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_F5<<_FREQ|-3000<<_MAG,_F5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_C4<<_FREQ|00000<<_MAG,_C4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_F5<<_FREQ|-3000<<_MAG,_F5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_C4<<_FREQ|-3000<<_MAG,_C4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_F5<<_FREQ|-3000<<_MAG,_F5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_C4<<_FREQ|00000<<_MAG,_C4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_F5<<_FREQ|-3000<<_MAG,_F5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_C4<<_FREQ|-3000<<_MAG,_C4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_F5<<_FREQ|-3000<<_MAG,_F5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_C4<<_FREQ|00000<<_MAG,_C4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_F5<<_FREQ|-3000<<_MAG,_F5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_C4<<_FREQ|-3000<<_MAG,_C4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_F5<<_FREQ|-3000<<_MAG,_F5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_C4<<_FREQ|00000<<_MAG,_C4<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_F5<<_FREQ|-3000<<_MAG,_F5<<_FREQ|30000<<_MAG,250<<_BEAT,1<<_RIS|99<<_FAL,
	_END
};

// "Himawari"
synthe_precode pre_synthe16_l[] = {
	_D5<<_FREQ|3000<<_MAG,_D7<<_FREQ|10000<<_MAG,750<<_BEAT,20<<_RIS|80<<_FAL,
	_G5<<_FREQ|3000<<_MAG,_G7<<_FREQ|10000<<_MAG,1250<<_BEAT,20<<_RIS|80<<_FAL,
	_D5<<_FREQ|3000<<_MAG,_D7<<_FREQ|10000<<_MAG,750<<_BEAT,20<<_RIS|80<<_FAL,
	_G5<<_FREQ|3000<<_MAG,_G7<<_FREQ|10000<<_MAG,1250<<_BEAT,20<<_RIS|80<<_FAL,
	_F5<<_FREQ|3000<<_MAG,_F7<<_FREQ|10000<<_MAG,750<<_BEAT,20<<_RIS|80<<_FAL,
	_C6<<_FREQ|3000<<_MAG,_C8<<_FREQ|10000<<_MAG,1250<<_BEAT,20<<_RIS|80<<_FAL,
	_END
};

synthe_precode pre_synthe16_r[] = {
	_G1<<_FREQ|3000<<_MAG,_G1<<_FREQ|60000<<_MAG,500<<_BEAT,10<<_RIS|90<<_FAL,
	_D2<<_FREQ|3000<<_MAG,_D2<<_FREQ|60000<<_MAG,500<<_BEAT,10<<_RIS|90<<_FAL,
	_G1<<_FREQ|3000<<_MAG,_G1<<_FREQ|60000<<_MAG,500<<_BEAT,10<<_RIS|90<<_FAL,
	_D2<<_FREQ|3000<<_MAG,_D2<<_FREQ|60000<<_MAG,500<<_BEAT,10<<_RIS|90<<_FAL,
	_G1<<_FREQ|3000<<_MAG,_G1<<_FREQ|60000<<_MAG,500<<_BEAT,10<<_RIS|90<<_FAL,
	_D2<<_FREQ|3000<<_MAG,_D2<<_FREQ|60000<<_MAG,500<<_BEAT,10<<_RIS|90<<_FAL,
	_G1<<_FREQ|3000<<_MAG,_G1<<_FREQ|60000<<_MAG,500<<_BEAT,10<<_RIS|90<<_FAL,
	_D2<<_FREQ|3000<<_MAG,_D2<<_FREQ|60000<<_MAG,500<<_BEAT,10<<_RIS|90<<_FAL,
	_F1<<_FREQ|3000<<_MAG,_F1<<_FREQ|60000<<_MAG,500<<_BEAT,10<<_RIS|90<<_FAL,
	_C2<<_FREQ|3000<<_MAG,_C2<<_FREQ|60000<<_MAG,500<<_BEAT,10<<_RIS|90<<_FAL,
	_F1<<_FREQ|3000<<_MAG,_F1<<_FREQ|60000<<_MAG,500<<_BEAT,10<<_RIS|90<<_FAL,
	_C2<<_FREQ|3000<<_MAG,_C2<<_FREQ|60000<<_MAG,500<<_BEAT,10<<_RIS|90<<_FAL,
	_END
};

int32 _user_start()
{

	synthe_code* synthe1 = sts32_synthedecodelr( pre_synthe1_l, pre_synthe1_r );
	synthe_code* synthe2 = sts32_synthedecodelr( pre_synthe2_l, pre_synthe2_r );
	synthe_code* synthe3 = (synthe_code*)heap32_malloc( 2 );
	synthe_code* synthe4 = (synthe_code*)heap32_malloc( 2 );
	synthe_code* synthe5 = (synthe_code*)heap32_malloc( 2 );
	synthe_code* synthe6 = (synthe_code*)heap32_malloc( 2 );
	synthe_code* synthe7 = (synthe_code*)heap32_malloc( 2 );
	synthe_code* synthe8 = sts32_synthedecodelr( pre_synthe8_l, pre_synthe8_r );
	synthe_code* synthe16 = sts32_synthedecodelr( pre_synthe16_l, pre_synthe16_r );

	uint32 timer_count_multiplier = timer_count_multiplier_default;
	uint32 detect_parallel;
	uchar8 result;
	uchar8 playing_signal;

//print32_debug( (uint32)synthe8, 100, 200 );
//print32_debug_hexa( (uint32)synthe8, 100, 212, 256 );

	while ( true ) {
#ifdef __SOUND_I2S
		_synthewave_i2s();
#endif
#ifdef __SOUND_PWM
		_synthewave_pwm();
#endif
#ifdef __SOUND_JACK
		_synthewave_pwm();
#endif
		if ( _gpio_detect( 27 ) ) { // Time of This Loop Around 40us in My Experience

			detect_parallel = _load_32( _gpio_base|_gpio_gpeds0 );
			_store_32( _gpio_base|_gpio_gpeds0, detect_parallel );

//print32_debug( detect_parallel, 100, 100 );

			/* GPIO22-26 as Bit[26:22] */
			// 0b00001 (1)
			if ( detect_parallel == 0b00001<<22 ) {
				_syntheset( synthe1, sts32_synthelen( synthe1 )/2, 0, -1 );
				//_syntheclear();

			// 0b00010 (2)
			} else if ( detect_parallel == 0b00010<<22 ) {
				_syntheset( synthe2, sts32_synthelen( synthe2 )/2, 0, -1 );
				/* Beat Up */
				//timer_count_multiplier--;
				//if ( timer_count_multiplier < timer_count_multiplier_minlimit ) timer_count_multiplier = timer_count_multiplier_minlimit;
				//_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );


			// 0b00011 (3)
			} else if ( detect_parallel == 0b00011<<22 ) {
				_syntheset( synthe3, sts32_synthelen( synthe3 )/2, 0, -1 );

			// 0b00100 (4)
			} else if ( detect_parallel == 0b00100<<22 ) {
				_syntheset( synthe4, sts32_synthelen( synthe4 )/2, 0, -1 );
				/* Beat Down */
				//timer_count_multiplier++;
				//if ( timer_count_multiplier > timer_count_multiplier_maxlimit ) timer_count_multiplier = timer_count_multiplier_maxlimit;
				//_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );

			// 0b00101 (5)
			} else if ( detect_parallel == 0b00101<<22 ) {
				_syntheset( synthe5, sts32_synthelen( synthe5 )/2, 0, -1 );

			// 0b00110 (6)
			} else if ( detect_parallel == 0b00110<<22 ) {
				_syntheset( synthe6, sts32_synthelen( synthe6 )/2, 0, -1 );

			// 0b00111 (7)
			} else if ( detect_parallel == 0b00111<<22 ) {
				_syntheset( synthe7, sts32_synthelen( synthe7 )/2, 0, -1 );

			// 0b01000 (8)
			} else if ( detect_parallel == 0b01000<<22 ) {
				_syntheset( synthe8, sts32_synthelen( synthe8 )/2, 0, -1 );

			// 0b01001 (9)
			} else if ( detect_parallel == 0b01001<<22 ) {
				_syntheclear();

			// 0b01010 (10)
			} else if ( detect_parallel == 0b01010<<22 ) {
				_syntheclear();

			// 0b01011 (11)
			} else if ( detect_parallel == 0b01011<<22 ) {
				_syntheclear();

			// 0b01100 (12)
			} else if ( detect_parallel == 0b01100<<22 ) {
				_syntheclear();

			// 0b01101 (13)
			} else if ( detect_parallel == 0b01101<<22 ) {
				_syntheclear();

			// 0b01110 (14)
			} else if ( detect_parallel == 0b01110<<22 ) {
				_syntheclear();

			// 0b01111 (15)
			} else if ( detect_parallel == 0b01111<<22 ) {
				_syntheclear();

			// 0b10000 (16)
			} else if ( detect_parallel == 0b10000<<22 ) {
				_syntheset( synthe16, sts32_synthelen( synthe16 )/2, 0, -1 );

			// 0b10001 (17)
			} else if ( detect_parallel == 0b10001<<22 ) {
				_syntheclear();

			// 0b10010 (18)
			} else if ( detect_parallel == 0b10010<<22 ) {
				_syntheclear();

			// 0b10011 (19)
			} else if ( detect_parallel == 0b10011<<22 ) {
				_syntheclear();

			// 0b10100 (20)
			} else if ( detect_parallel == 0b10100<<22 ) {
				_syntheclear();

			// 0b10101 (21)
			} else if ( detect_parallel == 0b10101<<22 ) {
				_syntheclear();

			// 0b10110 (22)
			} else if ( detect_parallel == 0b10110<<22 ) {
				_syntheclear();

			// 0b10111 (23)
			} else if ( detect_parallel == 0b10111<<22 ) {
				_syntheclear();

			// 0b11000 (24)
			} else if ( detect_parallel == 0b11000<<22 ) {
				_syntheclear();

			// 0b11001 (25)
			} else if ( detect_parallel == 0b11001<<22 ) {
				_syntheclear();

			// 0b11010 (26)
			} else if ( detect_parallel == 0b11010<<22 ) {
				_syntheclear();

			// 0b11011 (27)
			} else if ( detect_parallel == 0b11011<<22 ) {
				_syntheclear();

			// 0b11100 (28)
			} else if ( detect_parallel == 0b11100<<22 ) {
				_syntheclear();

			// 0b11101 (29)
			} else if ( detect_parallel == 0b11101<<22 ) {
				/* Beat Up */
				timer_count_multiplier--;
				if ( timer_count_multiplier < timer_count_multiplier_minlimit ) timer_count_multiplier = timer_count_multiplier_minlimit;
				_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );

			// 0b11110 (30)
			} else if ( detect_parallel == 0b11110<<22 ) {
				/* Beat Down */
				timer_count_multiplier++;
				if ( timer_count_multiplier > timer_count_multiplier_maxlimit ) timer_count_multiplier = timer_count_multiplier_maxlimit;
				_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );

			// 0b11111 (31)
			} else if ( detect_parallel == 0b11111<<22 ) {
				_syntheclear();

			}

			result = _syntheplay();
			if ( result == 0 ) { // Playing
				playing_signal = _GPIOTOGGLE_HIGH;
			} else { // Not Playing
				playing_signal = _GPIOTOGGLE_LOW;
			}
			_gpiotoggle( 16, playing_signal );
		}
	}

	return EXIT_SUCCESS;
}
