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
#include "sts32/notes.h"
#include "sts32/presets.h"
#include "user32_tempo.h"
#include "user32_percussion.h"

/**
 * Global Variables and Constants
 * to Prevent Incorrect Compilation in optimization,
 * Variables (except these which have only one value) used over the iteration of the loop are defined as global variables.
 */

extern uint32 OS_RESET_MIDI_CHANNEL; // From vector32.s

#define TEMPO_COUNT_DEFAULT  2
#define TEMPO_DEFAULT 60
#define TEMPO_MAX 420

/**
 * In default, there is a 2400Hz synchronization clock (it's a half of 4800Hz on GPCLK1).
 * A set of 2400 beats (= delta times) is 60BPM on 2400HZ (one delta time is 1/2400 seconds).
 * BPM is controlled with a table in "user32_tempo.h"
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

synthe_precode pre_synthe1_l[] = {
	_3_BIG(_RAP(
		/*
		_2(_RAP(
			_A3<<_FREQ|2500<<_MAG,_NOISE<<_FREQ|8000<<_MAG,600<<_BEAT,1<<_ATK|20<<_DCY|30<<_STN|79<<_RLS,
			_SILENCE,_SILENCE,600<<_BEAT,0
		))
		_2(_RAP(
			_G6<<_FREQ|2500<<_MAG,_NOISE<<_FREQ|6000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_B6<<_FREQ|2500<<_MAG,_NOISE<<_FREQ|6000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_D7<<_FREQ|2500<<_MAG,_NOISE<<_FREQ|6000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_B6<<_FREQ|2500<<_MAG,_NOISE<<_FREQ|6000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL
		))
			_2(_RAP(
			_C6<<_FREQ|2500<<_MAG,_NOISE<<_FREQ|7000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_E6<<_FREQ|2500<<_MAG,_NOISE<<_FREQ|7000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_G6<<_FREQ|2500<<_MAG,_NOISE<<_FREQ|7000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_E6<<_FREQ|2500<<_MAG,_NOISE<<_FREQ|7000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL
		))
		*/
		_8(_RAP(
			_SILENCE,_SILENCE,300<<_BEAT,0,
			_SILENCE,_SILENCE,300<<_BEAT,0,
			_SILENCE,_SILENCE,300<<_BEAT,0,
			_SILENCE,_SILENCE,300<<_BEAT,0
		))
	))
	_END
};

synthe_precode pre_synthe1_r[] = {
	_3_BIG(_RAP(
		_1(_RAP(
			_D7<<_FREQ|2500<<_MAG,_NOISE<<_FREQ|0000<<_MAG,2400<<_BEAT,10<<_ATK|20<<_DCY|30<<_STN|10<<_RLS
		))
		_1(_RAP(
			_D7<<_FREQ|2500<<_MAG,_NOISE<<_FREQ|0000<<_MAG,2400<<_BEAT,10<<_ATK|40<<_DCY|30<<_STN|10<<_RLS
		))
		_1(_RAP(
			_D7<<_FREQ|2500<<_MAG,_NOISE<<_FREQ|0000<<_MAG,2400<<_BEAT,10<<_ATK|60<<_DCY|30<<_STN|10<<_RLS
		))
		_1(_RAP(
			_D7<<_FREQ|2500<<_MAG,_NOISE<<_FREQ|0000<<_MAG,2400<<_BEAT,10<<_ATK|80<<_DCY|30<<_STN|10<<_RLS
		))
	))
	_END
};

/*
synthe_precode pre_synthe1_l[] = {
	_3_BIG(_RAP(
		_2(_RAP(
			_D6<<_FREQ|2500<<_MAG,_D6<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_F6<<_FREQ|2500<<_MAG,_F6<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_A6<<_FREQ|2500<<_MAG,_A6<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_F6<<_FREQ|2500<<_MAG,_F6<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL
		))
		_2(_RAP(
			_G6<<_FREQ|2500<<_MAG,_G6<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_B6<<_FREQ|2500<<_MAG,_B6<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_D7<<_FREQ|2500<<_MAG,_D7<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_B6<<_FREQ|2500<<_MAG,_B6<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL
		))
			_2(_RAP(
			_C6<<_FREQ|2500<<_MAG,_C6<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_E6<<_FREQ|2500<<_MAG,_E6<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_G6<<_FREQ|2500<<_MAG,_G6<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_E6<<_FREQ|2500<<_MAG,_E6<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL
		))
		_2(_RAP(
			_D6<<_FREQ|2500<<_MAG,_D6<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_F6<<_FREQ|2500<<_MAG,_F6<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_A6<<_FREQ|2500<<_MAG,_A6<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_F6<<_FREQ|2500<<_MAG,_F6<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL
		))
	))
	_END
};

synthe_precode pre_synthe1_r[] = {
	_3_BIG(_RAP(
		_2(_RAP(
			_D7<<_FREQ|2500<<_MAG,_D7<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_F7<<_FREQ|2500<<_MAG,_F7<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_A7<<_FREQ|2500<<_MAG,_A7<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_F7<<_FREQ|2500<<_MAG,_F7<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL
		))
		_2(_RAP(
			_G7<<_FREQ|2500<<_MAG,_G7<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_B7<<_FREQ|2500<<_MAG,_B7<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_D8<<_FREQ|2500<<_MAG,_D8<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_B7<<_FREQ|2500<<_MAG,_B7<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL
		))
		_2(_RAP(
			_C7<<_FREQ|2500<<_MAG,_C7<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_E7<<_FREQ|2500<<_MAG,_E7<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_G7<<_FREQ|2500<<_MAG,_G7<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_E7<<_FREQ|2500<<_MAG,_E7<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL
		))
		_2(_RAP(
			_D7<<_FREQ|2500<<_MAG,_D7<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_F7<<_FREQ|2500<<_MAG,_F7<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_A7<<_FREQ|2500<<_MAG,_A7<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL,
			_F7<<_FREQ|2500<<_MAG,_F7<<_FREQ|00000<<_MAG,300<<_BEAT,30<<_RIS|100<<_STN|70<<_FAL
		))
	))
	_END
};
*/

/* Rhythm of Drum 'n' Bass: Cymbal Part */
synthe_precode pre_synthe2_l[] = {
	// One, Two, Three
	_3(_RAP(
		_D6<<_FREQ|600<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|600<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|2500<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|600<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|600<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|600<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|600<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|2500<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,

		_D6<<_FREQ|600<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|600<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|2500<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|600<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|600<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|600<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|600<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|2500<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL
	))

	// Four
	_1(_RAP(
		_D6<<_FREQ|600<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|600<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|2500<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|600<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|600<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|600<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|600<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|2500<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,

		_D6<<_FREQ|2500<<_MAG,_D7<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,600<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|2500<<_MAG,_D7<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,600<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|2500<<_MAG,_D7<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D6<<_FREQ|0000<<_MAG,_D7<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL
	))

	_END
};

/* Rhythm of Drum 'n' Base: Bass and Snare Parts */
synthe_precode pre_synthe2_r[] = {
	// One, Two, Three
	_3(_RAP(
		_B1<<_FREQ|5000<<_MAG,_B1<<_FREQ|00000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_A4<<_FREQ|2500<<_MAG,_B4<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_A4<<_FREQ|60<<_MAG,_B4<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_A4<<_FREQ|60<<_MAG,_B4<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_B1<<_FREQ|5000<<_MAG,_B1<<_FREQ|00000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_A4<<_FREQ|2500<<_MAG,_B4<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,

		_B1<<_FREQ|5000<<_MAG,_B1<<_FREQ|00000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_A4<<_FREQ|2500<<_MAG,_B4<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_A4<<_FREQ|60<<_MAG,_B4<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_A4<<_FREQ|60<<_MAG,_B4<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_B1<<_FREQ|5000<<_MAG,_B1<<_FREQ|00000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_A4<<_FREQ|2500<<_MAG,_B4<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL
	))

	// Four
	_1(_RAP(
		_B1<<_FREQ|5000<<_MAG,_B1<<_FREQ|00000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_A4<<_FREQ|2500<<_MAG,_B4<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_A4<<_FREQ|60<<_MAG,_B4<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_A4<<_FREQ|60<<_MAG,_B4<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_B1<<_FREQ|5000<<_MAG,_B1<<_FREQ|00000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_A4<<_FREQ|2500<<_MAG,_B4<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,

		_B1<<_FREQ|5000<<_MAG,_B1<<_FREQ|00000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_A4<<_FREQ|2500<<_MAG,_B4<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_A4<<_FREQ|2500<<_MAG,_B4<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_B1<<_FREQ|5000<<_MAG,_B1<<_FREQ|00000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_A4<<_FREQ|2500<<_MAG,_B4<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_A4<<_FREQ|2500<<_MAG,_B4<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_B1<<_FREQ|5000<<_MAG,_B1<<_FREQ|00000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_A4<<_FREQ|2500<<_MAG,_B4<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1<<_FREQ|0000<<_MAG,_D1<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL
	))

	_END
};

/* Test Sin Wave C1 C2 C3 C4 C5 C6 C7 C8*/
synthe_precode pre_synthe3_l[] = {
	_1(_RAP(
		_C1<<_FREQ|6000<<_MAG,_C1<<_FREQ|00000<<_MAG,9600<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_1(_RAP(
		_C2<<_FREQ|5000<<_MAG,_C2<<_FREQ|00000<<_MAG,9600<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_1(_RAP(
		_C3<<_FREQ|4000<<_MAG,_C3<<_FREQ|00000<<_MAG,9600<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_1(_RAP(
		_C4<<_FREQ|3500<<_MAG,_C4<<_FREQ|00000<<_MAG,9600<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_1(_RAP(
		_C5<<_FREQ|2500<<_MAG,_C5<<_FREQ|00000<<_MAG,9600<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_1(_RAP(
		_C6<<_FREQ|2500<<_MAG,_C6<<_FREQ|00000<<_MAG,9600<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_1(_RAP(
		_C7<<_FREQ|2500<<_MAG,_C7<<_FREQ|00000<<_MAG,9600<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_1(_RAP(
		_C8<<_FREQ|2500<<_MAG,_C8<<_FREQ|00000<<_MAG,9600<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_1(_RAP(
		_A4<<_FREQ|2500<<_MAG,_A4<<_FREQ|00000<<_MAG,19200<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_END
};

synthe_precode pre_synthe3_r[] = {
	_1(_RAP(
		_C1<<_FREQ|0000<<_MAG,_C1<<_FREQ|00000<<_MAG,9600<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_1(_RAP(
		_C2<<_FREQ|0000<<_MAG,_C2<<_FREQ|00000<<_MAG,9600<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_1(_RAP(
		_C3<<_FREQ|0000<<_MAG,_C3<<_FREQ|00000<<_MAG,9600<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_1(_RAP(
		_C4<<_FREQ|0000<<_MAG,_C4<<_FREQ|00000<<_MAG,9600<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_1(_RAP(
		_C5<<_FREQ|0000<<_MAG,_C5<<_FREQ|00000<<_MAG,9600<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_1(_RAP(
		_C6<<_FREQ|0000<<_MAG,_C6<<_FREQ|00000<<_MAG,9600<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_1(_RAP(
		_C7<<_FREQ|0000<<_MAG,_C7<<_FREQ|00000<<_MAG,9600<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_1(_RAP(
		_C8<<_FREQ|0000<<_MAG,_C8<<_FREQ|00000<<_MAG,9600<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_1(_RAP(
		_A4<<_FREQ|0000<<_MAG,_A4<<_FREQ|00000<<_MAG,19200<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_END
};

/* Major 7th Alpeggio, 1 and 8 */
synthe_precode pre_synthe4_l[] = {
	_4(_RAP(
		_C4<<_FREQ|2500<<_MAG,_G4<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_E4<<_FREQ|2500<<_MAG,_B4<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_G4<<_FREQ|2500<<_MAG,_D5<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_E4<<_FREQ|2500<<_MAG,_B4<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_4(_RAP(
		_F4<<_FREQ|2500<<_MAG,_C5<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_A4<<_FREQ|2500<<_MAG,_E5<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_C5<<_FREQ|2500<<_MAG,_G5<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_A4<<_FREQ|2500<<_MAG,_E5<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_4(_RAP(
		_G4<<_FREQ|2500<<_MAG,_D5<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_B4<<_FREQ|2500<<_MAG,_FS5<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_D5<<_FREQ|2500<<_MAG,_A5<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_B4<<_FREQ|2500<<_MAG,_FS5<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_4(_RAP(
		_C4<<_FREQ|2500<<_MAG,_G4<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_E4<<_FREQ|2500<<_MAG,_B4<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_G4<<_FREQ|2500<<_MAG,_D5<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_E4<<_FREQ|2500<<_MAG,_B4<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_END
};

/* Major 7th Alpeggio, 12 and 5 */
synthe_precode pre_synthe4_r[] = {
	_4(_RAP(
		_B4<<_FREQ|2500<<_MAG,_E4<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_DS5<<_FREQ|2500<<_MAG,_GS4<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_FS5<<_FREQ|2500<<_MAG,_B4<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_DS5<<_FREQ|2500<<_MAG,_GS4<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_4(_RAP(
		_E5<<_FREQ|2500<<_MAG,_A4<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_GS5<<_FREQ|2500<<_MAG,_CS5<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_B5<<_FREQ|2500<<_MAG,_E5<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_GS5<<_FREQ|2500<<_MAG,_CS5<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_4(_RAP(
		_FS5<<_FREQ|2500<<_MAG,_B4<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_AS5<<_FREQ|2500<<_MAG,_DS5<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_CS6<<_FREQ|2500<<_MAG,_FS5<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_AS5<<_FREQ|2500<<_MAG,_DS5<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_4(_RAP(
		_B4<<_FREQ|2500<<_MAG,_E4<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_DS5<<_FREQ|2500<<_MAG,_GS4<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_FS5<<_FREQ|2500<<_MAG,_B4<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL,
		_DS5<<_FREQ|2500<<_MAG,_GS4<<_FREQ|5000<<_MAG,300<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_END
};

/* Low */
synthe_precode pre_synthe5_l[] = {
	_1(_RAP(
		_B2_INT<<_FREQ|3500<<_MAG,(_B2_INT>>2)<<_FREQ|30000<<_MAG,2400<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_END
};

synthe_precode pre_synthe5_r[] = {
	_1(_RAP(
		_B2_INT<<_FREQ|3500<<_MAG,(_B2_INT>>2)<<_FREQ|30000<<_MAG,2400<<_BEAT,50<<_RIS|100<<_STN|50<<_FAL
	))
	_END
};

synthe_precode pre_synthe8_l[] = {
	_4(_RAP(
		_D4_INT<<_FREQ|2500<<_MAG,(_D4_INT>>2)<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_G5_INT<<_FREQ|2500<<_MAG,(_G5_INT>>2)<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D4_INT<<_FREQ|0000<<_MAG,(_D4_INT>>2)<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_G5_INT<<_FREQ|2500<<_MAG,(_G5_INT>>2)<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL
	))
	_4(_RAP(
		_C4_INT<<_FREQ|2500<<_MAG,(_C4_INT>>2)<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_F5_INT<<_FREQ|2500<<_MAG,(_F5_INT>>2)<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_C4_INT<<_FREQ|0000<<_MAG,(_C4_INT>>2)<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_F5_INT<<_FREQ|2500<<_MAG,(_F5_INT>>2)<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL
	))
	_END
};

synthe_precode pre_synthe8_r[] = {
	_4(_RAP(
		_D1_INT<<_FREQ|2500<<_MAG,(_D4_INT>>2)<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1_INT<<_FREQ|0000<<_MAG,(_G5_INT>>2)<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1_INT<<_FREQ|0000<<_MAG,(_D4_INT>>2)<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1_INT<<_FREQ|2500<<_MAG,(_G5_INT>>2)<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL
	))
	_4(_RAP(
		_D1_INT<<_FREQ|2500<<_MAG,(_D4_INT>>2)<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1_INT<<_FREQ|0000<<_MAG,(_G5_INT>>2)<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1_INT<<_FREQ|0000<<_MAG,(_D4_INT>>2)<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
		_D1_INT<<_FREQ|2500<<_MAG,(_G5_INT>>2)<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL
	))
	_END
};

// "Himawari"
synthe_precode pre_synthe16_l[] = {
	_D5<<_FREQ|2500<<_MAG,_D7<<_FREQ|5000<<_MAG,900<<_BEAT,20<<_RIS|100<<_STN|80<<_FAL,
	_G5<<_FREQ|2500<<_MAG,_G7<<_FREQ|5000<<_MAG,1500<<_BEAT,20<<_RIS|100<<_STN|80<<_FAL,
	_D5<<_FREQ|2500<<_MAG,_D7<<_FREQ|5000<<_MAG,900<<_BEAT,20<<_RIS|100<<_STN|80<<_FAL,
	_G5<<_FREQ|2500<<_MAG,_G7<<_FREQ|5000<<_MAG,1500<<_BEAT,20<<_RIS|100<<_STN|80<<_FAL,
	_F5<<_FREQ|2500<<_MAG,_F7<<_FREQ|5000<<_MAG,900<<_BEAT,20<<_RIS|100<<_STN|80<<_FAL,
	_C6<<_FREQ|2500<<_MAG,_C8<<_FREQ|5000<<_MAG,1500<<_BEAT,20<<_RIS|100<<_STN|80<<_FAL,
	_G5<<_FREQ|2500<<_MAG,_G7<<_FREQ|5000<<_MAG,900<<_BEAT,20<<_RIS|100<<_STN|80<<_FAL,
	_D6<<_FREQ|2500<<_MAG,_D8<<_FREQ|5000<<_MAG,1500<<_BEAT,20<<_RIS|100<<_STN|80<<_FAL,
	_END
};

synthe_precode pre_synthe16_r[] = {
	_G1<<_FREQ|2500<<_MAG,_G1<<_FREQ|30000<<_MAG,600<<_BEAT,10<<_RIS|100<<_STN|90<<_FAL,
	_D2<<_FREQ|2500<<_MAG,_D2<<_FREQ|30000<<_MAG,600<<_BEAT,10<<_RIS|100<<_STN|90<<_FAL,
	_G1<<_FREQ|2500<<_MAG,_G1<<_FREQ|30000<<_MAG,600<<_BEAT,10<<_RIS|100<<_STN|90<<_FAL,
	_D2<<_FREQ|2500<<_MAG,_D2<<_FREQ|30000<<_MAG,600<<_BEAT,10<<_RIS|100<<_STN|90<<_FAL,
	_G1<<_FREQ|2500<<_MAG,_G1<<_FREQ|30000<<_MAG,600<<_BEAT,10<<_RIS|100<<_STN|90<<_FAL,
	_D2<<_FREQ|2500<<_MAG,_D2<<_FREQ|30000<<_MAG,600<<_BEAT,10<<_RIS|100<<_STN|90<<_FAL,
	_G1<<_FREQ|2500<<_MAG,_G1<<_FREQ|30000<<_MAG,600<<_BEAT,10<<_RIS|100<<_STN|90<<_FAL,
	_D2<<_FREQ|2500<<_MAG,_D2<<_FREQ|30000<<_MAG,600<<_BEAT,10<<_RIS|100<<_STN|90<<_FAL,
	_F1<<_FREQ|2500<<_MAG,_F1<<_FREQ|30000<<_MAG,600<<_BEAT,10<<_RIS|100<<_STN|90<<_FAL,
	_C2<<_FREQ|2500<<_MAG,_C2<<_FREQ|30000<<_MAG,600<<_BEAT,10<<_RIS|100<<_STN|90<<_FAL,
	_F1<<_FREQ|2500<<_MAG,_F1<<_FREQ|30000<<_MAG,600<<_BEAT,10<<_RIS|100<<_STN|90<<_FAL,
	_C2<<_FREQ|2500<<_MAG,_C2<<_FREQ|30000<<_MAG,600<<_BEAT,10<<_RIS|100<<_STN|90<<_FAL,
	_G1<<_FREQ|2500<<_MAG,_G1<<_FREQ|30000<<_MAG,600<<_BEAT,10<<_RIS|100<<_STN|90<<_FAL,
	_D2<<_FREQ|2500<<_MAG,_D2<<_FREQ|30000<<_MAG,600<<_BEAT,10<<_RIS|100<<_STN|90<<_FAL,
	_G1<<_FREQ|2500<<_MAG,_G1<<_FREQ|30000<<_MAG,600<<_BEAT,10<<_RIS|100<<_STN|90<<_FAL,
	_D2<<_FREQ|2500<<_MAG,_D2<<_FREQ|30000<<_MAG,600<<_BEAT,10<<_RIS|100<<_STN|90<<_FAL,
	_END
};

/* Two Dimentional Array (Array of Pointers) */

synthe_precode* pre_synthe1[] = {
	pre_synthe1_l,
	pre_synthe1_r
};

synthe_precode* pre_synthe2[] = {
	pre_synthe2_l,
	pre_synthe2_r
};

synthe_precode* pre_synthe3[] = {
	pre_synthe3_l,
	pre_synthe3_r
};

synthe_precode* pre_synthe4[] = {
	pre_synthe4_l,
	pre_synthe4_r
};

synthe_precode* pre_synthe5[] = {
	pre_synthe5_l,
	pre_synthe5_r
};

synthe_precode* pre_synthe8[] = {
	pre_synthe8_l,
	pre_synthe8_r
};

synthe_precode* pre_synthe16[] = {
	pre_synthe16_l,
	pre_synthe16_r
};

#define PRE_SYNTHE_NUMBER 27

/* Register for Precodes */
synthe_precode** pre_synthe_table[PRE_SYNTHE_NUMBER] = {
	pre_synthe1,
	pre_synthe2,
	pre_synthe3,
	pre_synthe4,
	pre_synthe5,
	pre_synthe8,
	pre_synthe16,
	pre_percussion_bassdrum2,
	pre_percussion_bassdrum1,
	pre_percussion_sidestick,
	pre_percussion_handclap,
	pre_percussion_snare1,
	pre_percussion_snare2,
	pre_percussion_lowtom1,
	pre_percussion_lowtom2,
	pre_percussion_midtom1,
	pre_percussion_midtom2,
	pre_percussion_hightom1,
	pre_percussion_hightom2,
	pre_percussion_hihat1,
	pre_percussion_hihat2,
	pre_percussion_symbal1,
	pre_percussion_symbal2,
	pre_percussion_elsymbal1,
	pre_percussion_elsymbal2,
	pre_percussion_triangle2,
	pre_percussion_triangle1
};

/* Register for Number of Voices */
uint32 pre_synthe_voice_table[PRE_SYNTHE_NUMBER] = {
	2,
	2,
	2,
	2,
	2,
	2,
	2,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1
};

/* Register for Index of Tables */
uint32 pre_synthe_table_index[PRE_SYNTHE_NUMBER] = {
	 1,
	 2,
	 3,
	 4,
	 5,
	 8,
	16,
	35, // Acoustic Bass Drum (Bass Drum 2) at GM 1 Percussion Key Map
	36, // Bass Drum 1
	37, // Side Stick
	39, // Hand Clap
	38, // Acoustic Snare (Snare Drum 1)
	40, // Electric Snare (Snare Drum 2)
	41, // Low Floor Tom
	45, // Low Tom
	47, // Low-mid Tom
	48, // Hi-mid Tom
	43, // High Floor Tom
	50, // High Tom
	42, // Closed Hi-hat
	44, // Pedal Hi-hat
	51, // Ride Cymbal 1
	59, // Ride Cymbal 2
	49, // Crash Cymbal 1
	57, // Crash Cymbal 2
	80, // Mute Triangle
	81  // Open Triangle
};

synthe_code** synthe_code_table;
uint32* synthelen_table;
int32 tempo_count; // Use Signed Integer (Using Comparison in IF Statement)
int32 tempo_count_reload;
uint32 tempo;
uint32 tempo_index;

int32 _user_start() {
	/* Local Variables */
	synthe_code* temp_synthe_code;
	uint32 number_voices;
	uint32 table_index;
	uint32 detect_parallel = 0;
	uchar8 result;
	uchar8 playing_signal;

	/* Initialization of Global Variables */
	synthe_code_table = (synthe_code**)heap32_malloc( 128 );
	synthelen_table = (uint32*)heap32_malloc( 128 );

	for ( uint32 i = 0; i < PRE_SYNTHE_NUMBER; i++ ) {
		number_voices = pre_synthe_voice_table[i];
		if ( number_voices ) {
			temp_synthe_code = sts32_synthedecodelr( pre_synthe_table[i], number_voices );
		} else {
			temp_synthe_code = (synthe_code*)pre_synthe_table[i]; // Decoded Binaries
		}
		if ( (uint32)temp_synthe_code == -1 ) return EXIT_FAILURE;
		table_index = pre_synthe_table_index[i];
		synthe_code_table[table_index] = temp_synthe_code;
		// To Get Proper Latency, Get Lengths in Advance
		synthelen_table[table_index] = arm32_udiv( sts32_synthelen( temp_synthe_code ), number_voices );
	}

	tempo_count = TEMPO_COUNT_DEFAULT;
	tempo_count_reload = TEMPO_COUNT_DEFAULT;
	tempo = TEMPO_DEFAULT;
	tempo_index = TEMPO_DEFAULT >> 1;

//print32_debug( (uint32)synthe8, 100, 200 );
//print32_debug_hexa( (uint32)synthe8, 100, 212, 256 );

	while ( true ) {
		// Time of _synthewave_i2s and synthemidi Is Up to Appx. 55us with Zero W in My Experience
#ifdef __SOUND_I2S
		_synthewave_i2s( STS32_DIGITALMOD_MEDIUM, STS32_TONE, 8 );
		_synthemidi( OS_RESET_MIDI_CHANNEL, STS32_I2S, 8 );
#elif defined(__SOUND_PWM)
		_synthewave_pwm( STS32_DIGITALMOD_MEDIUM, STS32_TONE, 8 );
		_synthemidi( OS_RESET_MIDI_CHANNEL, STS32_PWM, 8 );
#elif defined(__SOUND_JACK)
		_synthewave_pwm( STS32_DIGITALMOD_MEDIUM, STS32_TONE, 8 );
		_synthemidi( OS_RESET_MIDI_CHANNEL, STS32_PWM, 8 );
#endif

		/* Detect Falling Edge of GPIO */
		if ( _gpio_detect( 27 ) ) {
			detect_parallel = _load_32( _gpio_base|_gpio_gpeds0 );
			_store_32( _gpio_base|_gpio_gpeds0, detect_parallel );
			detect_parallel = ((detect_parallel >> 22) & 0b11111) | 0x80000000; // Set Outstanding Flag
		}

		/**
		 * Detecting falling edge of gpio is sticky, and is cleared by falling edge of GPIO 27.
		 * So, physical all high is needed to act as doing nothing or its equivalent.
		 * 0x1F = 0b11111 (31) is physical all high in default. Command 31 is used as stopping sound.
		 * 0x7F = 0b1111111 (127) is virtual all high in default.
		 * If you extend physical parallel up to 0x7F, you need to use Command 127 as doing nothing or so.
		 * Command 127 is used as setting lower 8 bits of the tempo index.
		 */
		if ( detect_parallel ) { // If Any Non Zero Including Outstanding Flag
			detect_parallel &= 0x7F; // 0-127
			if ( detect_parallel > 111 ) { // 112(0x70)-127(0x7F)
				// Tempo Index Lower 8-bit
				tempo_index = (tempo_index & 0xF0) | (detect_parallel & 0x0F);
				// Integer 30-240 BPM
				tempo = tempo_index << 1;
				if ( tempo > TEMPO_MAX ) tempo = TEMPO_MAX;
				_clockmanager_divisor( _cm_gp1, tempo_table[tempo << 1] );
				tempo_count_reload = tempo_table[(tempo << 1) + 1];
			} else if ( detect_parallel > 95 ) { // 96(0x60)-111(0x6F)
				// Tempo Index Upper 8-bit
				tempo_index = (tempo_index & 0x0F) | ((detect_parallel & 0x0F) << 4);
				// Integer 30-240 BPM
				tempo = tempo_index << 1;
				if ( tempo > TEMPO_MAX ) tempo = TEMPO_MAX;
				_clockmanager_divisor( _cm_gp1, tempo_table[tempo << 1] );
				tempo_count_reload = tempo_table[(tempo << 1) + 1];
			} else if ( detect_parallel > 31 ) { // 32-95
				// One Time
				if ( detect_parallel < 37 ) { // Bass Drums
					STS32_LANE = 1;
				} else if ( detect_parallel < 41 ) { // Snare
					STS32_LANE = 2;
				} else { // Symbal, etc.
					STS32_LANE = 3;
				}
				_syntheset( synthe_code_table[detect_parallel], synthelen_table[detect_parallel], 0, 1 );
			} else if ( detect_parallel == 0b11111 ) { // 0b11111 (31)
				STS32_LANE = 0;
				_syntheclear( 0, 2 );
				STS32_LANE = 1;
				_syntheclear( 2, 1 );
				STS32_LANE = 2;
				_syntheclear( 3, 1 );
				STS32_LANE = 3;
				_syntheclear( 4, 1 );
			} else if ( detect_parallel == 0b11110 ) { // 0b11110 (30)
				/* Beat Down */
				tempo--;
				if ( tempo < 0 ) tempo = 0;
				_clockmanager_divisor( _cm_gp1, tempo_table[tempo << 1] );
				tempo_count_reload = tempo_table[(tempo << 1) + 1];
			} else if ( detect_parallel == 0b11101 ) { // 0b11101 (29)
				/* Beat Up */
				tempo++;
				if ( tempo > TEMPO_MAX ) tempo = TEMPO_MAX;
				_clockmanager_divisor( _cm_gp1, tempo_table[tempo << 1] );
				tempo_count_reload = tempo_table[(tempo << 1) + 1];
			} else if ( detect_parallel > 0 ) { // 1-28
				// Loop
				STS32_LANE = 0;
				_syntheset( synthe_code_table[detect_parallel], synthelen_table[detect_parallel], 0, -1 );
			} // Do Nothing at 0 for Preventing Chattering
			detect_parallel = 0;
		}

		/* Detect Rising Edge of GPIO */
		if ( _gpio_detect( 5 ) ) {
			tempo_count--; // Decrement Counter
			if ( tempo_count <= 0 ) { // If Reaches Zero
				// Time of This Procedure Is Up to Appx. 5us with Zero W in My Experience

				if ( STS32_VIRTUAL_PARALLEL ) {
					detect_parallel = STS32_VIRTUAL_PARALLEL;
					STS32_VIRTUAL_PARALLEL = 0;
				}

//print32_debug( detect_parallel, 100, 100 );

				// Subtract Pitch Bend Ratio to Divisor (Upside Down)
#ifdef __SOUND_I2S
				_clockmanager_divisor( _cm_pcm, STS32_DIVISOR - STS32_PITCHBEND );
#elif defined(__SOUND_PWM)
				_clockmanager_divisor( _cm_pwm, STS32_DIVISOR - STS32_PITCHBEND );
#elif defined(__SOUND_JACK)
				_clockmanager_divisor( _cm_pwm, STS32_DIVISOR - STS32_PITCHBEND );
#endif

				/* Triangle LFO for MODULATION (Vibration) */
				STS32_DIVISOR += STS32_MODULATION_DELTA;
				if ( STS32_DIVISOR >= STS32_MODULATION_MAX ) {
					STS32_DIVISOR = STS32_MODULATION_MAX;
					STS32_MODULATION_DELTA = -( STS32_MODULATION_DELTA );
				} else if ( STS32_DIVISOR <= STS32_MODULATION_MIN ) {
					STS32_DIVISOR = STS32_MODULATION_MIN;
					STS32_MODULATION_DELTA = -( STS32_MODULATION_DELTA );
				}

				/* Triangle LFO for DIGITALMOD */
				STS32_DIGITALMOD_MEDIUM = vfp32_fadd( STS32_DIGITALMOD_MEDIUM, STS32_DIGITALMOD_DELTA );
				if ( vfp32_fgt( STS32_DIGITALMOD_MEDIUM, STS32_DIGITALMOD_MAX ) |
					vfp32_flt( STS32_DIGITALMOD_MEDIUM, STS32_DIGITALMOD_MIN ) ) {
					STS32_DIGITALMOD_DELTA = vfp32_fmul( STS32_DIGITALMOD_DELTA, -1.0 );
				}
				result = 0;
				STS32_LANE = 0;
				result |= _syntheplay( 0, 2 ) ^ 0b11;
				STS32_LANE = 1;
				result |= _syntheplay( 2, 1 ) ^ 0b11;
				STS32_LANE = 2;
				result |= _syntheplay( 3, 1 ) ^ 0b11;
				STS32_LANE = 3;
				result |= _syntheplay( 4, 1 ) ^ 0b11;
				if ( result == 0b11 ) { // Playing
					playing_signal = _GPIOTOGGLE_HIGH;
				} else { // Not Playing
					playing_signal = _GPIOTOGGLE_LOW;
				}
				_gpiotoggle( 16, playing_signal );

				_synthemidi_envelope( 8 );

				tempo_count = tempo_count_reload; // Reset Counter
			}
		}
	}
	return EXIT_SUCCESS;
}
