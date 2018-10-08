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
#include "user32_tempo.h"

#define tempo_count_default  2
#define tempo_default 60
#define tempo_max 420

extern uint32 OS_RESET_MIDI_CHANNEL;

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

/* Use Signed Integer and Global Scope to Prevent Incorrect Compilation (Using Comparison in IF Statement) */
int32 tempo_count = tempo_count_default;
int32 tempo_count_reload = tempo_count_default;
int32 tempo = tempo_default;


int32 _user_start()
{

	// To Get Proper Latency, Get Lengths in Advance
	synthe_code* synthe1 = sts32_synthedecodelr( pre_synthe1, 2 );
	if ( (uint32)synthe1 == -1 ) return EXIT_FAILURE;
	uint32 synthelen1 = sts32_synthelen( synthe1 ) / 2;

	synthe_code* synthe2 = sts32_synthedecodelr( pre_synthe2, 2 );
	if ( (uint32)synthe2 == -1 ) return EXIT_FAILURE;
	uint32 synthelen2 = sts32_synthelen( synthe2 ) / 2;

	synthe_code* synthe3 = sts32_synthedecodelr( pre_synthe3, 2 );
	if ( (uint32)synthe3 == -1 ) return EXIT_FAILURE;
	uint32 synthelen3 = sts32_synthelen( synthe3 ) / 2;

	synthe_code* synthe4 = sts32_synthedecodelr( pre_synthe4, 2 );
	if ( (uint32)synthe4 == -1 ) return EXIT_FAILURE;
	uint32 synthelen4 = sts32_synthelen( synthe4 ) / 2;

	synthe_code* synthe5 = sts32_synthedecodelr( pre_synthe5, 2 );
	if ( (uint32)synthe5 == -1 ) return EXIT_FAILURE;
	uint32 synthelen5 = sts32_synthelen( synthe5 ) / 2;

	synthe_code* synthe6 = (synthe_code*)heap32_malloc( 2 );
	if ( (uint32)synthe6 == -1 ) return EXIT_FAILURE;
	uint32 synthelen6 = sts32_synthelen( synthe6 ) / 2;

	synthe_code* synthe7 = (synthe_code*)heap32_malloc( 2 );
	if ( (uint32)synthe7 == -1 ) return EXIT_FAILURE;
	uint32 synthelen7 = sts32_synthelen( synthe7 ) / 2;

	synthe_code* synthe8 = sts32_synthedecodelr( pre_synthe8, 2 );
	if ( (uint32)synthe8 == -1 ) return EXIT_FAILURE;
	uint32 synthelen8 = sts32_synthelen( synthe8 ) / 2;

	synthe_code* synthe16 = sts32_synthedecodelr( pre_synthe16, 2 );
	if ( (uint32)synthe16 == -1 ) return EXIT_FAILURE;
	uint32 synthelen16 = sts32_synthelen( synthe16 ) / 2;

	tempo_count = tempo_count_default;
	tempo_count_reload = tempo_count_default;
	tempo = tempo_default;

	uint32 detect_parallel;
	uchar8 result;
	uchar8 playing_signal;
	float32 bend_rate = 1.0;

//print32_debug( (uint32)synthe8, 100, 200 );
//print32_debug_hexa( (uint32)synthe8, 100, 212, 256 );

	while ( true ) {
#ifdef __SOUND_I2S
		_synthewave_i2s( bend_rate, 8 );
		_synthemidi( OS_RESET_MIDI_CHANNEL, STS32_I2S, 8 );
#endif
#ifdef __SOUND_PWM
		_synthewave_pwm( bend_rate, 8 );
		_synthemidi( OS_RESET_MIDI_CHANNEL, STS32_PWM, 8 );
#endif
#ifdef __SOUND_JACK
		_synthewave_pwm( bend_rate, 8 );
		_synthemidi( OS_RESET_MIDI_CHANNEL, STS32_PWM, 8 );
#endif
		if ( _gpio_detect( 6 ) ) { // Time of This Loop Around 40us in My Experience

			tempo_count--; // Decrement Counter
			if ( tempo_count <= 0 ) { // If Reaches Zero

				detect_parallel = _load_32( _gpio_base|_gpio_gpeds0 );
				_store_32( _gpio_base|_gpio_gpeds0, detect_parallel );
				if ( STS32_VIRTUAL_PARALLEL ) {
					detect_parallel |= STS32_VIRTUAL_PARALLEL<<22;
					STS32_VIRTUAL_PARALLEL = 0;
				}

//print32_debug( detect_parallel, 100, 100 );

				/* GPIO22-26 as Bit[26:22] */
				// 0b00001 (1)
				if ( detect_parallel == 0b00001<<22 ) {
					_syntheset( synthe1, synthelen1, 0, 1 );

				// 0b00010 (2)
				} else if ( detect_parallel == 0b00010<<22 ) {
					_syntheset( synthe2, synthelen2, 0, -1 );

				// 0b00011 (3)
				} else if ( detect_parallel == 0b00011<<22 ) {
					_syntheset( synthe3, synthelen3, 0, -1 );

				// 0b00100 (4)
				} else if ( detect_parallel == 0b00100<<22 ) {
					_syntheset( synthe4, synthelen4, 0, -1 );

				// 0b00101 (5)
				} else if ( detect_parallel == 0b00101<<22 ) {
					_syntheset( synthe5, synthelen5, 0, -1 );

				// 0b00110 (6)
				} else if ( detect_parallel == 0b00110<<22 ) {
					_syntheset( synthe6, synthelen6, 0, -1 );

				// 0b00111 (7)
				} else if ( detect_parallel == 0b00111<<22 ) {
					_syntheset( synthe7, synthelen7, 0, -1 );

				// 0b01000 (8)
				} else if ( detect_parallel == 0b01000<<22 ) {
					_syntheset( synthe8, synthelen8, 0, -1 );

				// 0b01001 (9)
				} else if ( detect_parallel == 0b01001<<22 ) {
					_syntheclear( 2 );

				// 0b01010 (10)
				} else if ( detect_parallel == 0b01010<<22 ) {
					_syntheclear( 2 );

				// 0b01011 (11)
				} else if ( detect_parallel == 0b01011<<22 ) {
					_syntheclear( 2 );

				// 0b01100 (12)
				} else if ( detect_parallel == 0b01100<<22 ) {
					_syntheclear( 2 );

				// 0b01101 (13)
				} else if ( detect_parallel == 0b01101<<22 ) {
					_syntheclear( 2 );

				// 0b01110 (14)
				} else if ( detect_parallel == 0b01110<<22 ) {
					_syntheclear( 2 );

				// 0b01111 (15)
				} else if ( detect_parallel == 0b01111<<22 ) {
					_syntheclear( 2 );

				// 0b10000 (16)
				} else if ( detect_parallel == 0b10000<<22 ) {
					_syntheset( synthe16, synthelen16, 0, -1 );

				// 0b10001 (17)
				} else if ( detect_parallel == 0b10001<<22 ) {
					_syntheclear( 2 );

				// 0b10010 (18)
				} else if ( detect_parallel == 0b10010<<22 ) {
					_syntheclear( 2 );

				// 0b10011 (19)
				} else if ( detect_parallel == 0b10011<<22 ) {
					_syntheclear( 2 );

				// 0b10100 (20)
				} else if ( detect_parallel == 0b10100<<22 ) {
					_syntheclear( 2 );

				// 0b10101 (21)
				} else if ( detect_parallel == 0b10101<<22 ) {
					_syntheclear( 2 );

				// 0b10110 (22)
				} else if ( detect_parallel == 0b10110<<22 ) {
					_syntheclear( 2 );

				// 0b10111 (23)
				} else if ( detect_parallel == 0b10111<<22 ) {
					_syntheclear( 2 );

				// 0b11000 (24)
				} else if ( detect_parallel == 0b11000<<22 ) {
					_syntheclear( 2 );

				// 0b11001 (25)
				} else if ( detect_parallel == 0b11001<<22 ) {
					_syntheclear( 2 );

				// 0b11010 (26)
				} else if ( detect_parallel == 0b11010<<22 ) {
					_syntheclear( 2 );

				// 0b11011 (27)
				} else if ( detect_parallel == 0b11011<<22 ) {
					_syntheclear( 2 );

				// 0b11100 (28)
				} else if ( detect_parallel == 0b11100<<22 ) {
					_syntheclear( 2 );

				// 0b11101 (29)
				} else if ( detect_parallel == 0b11101<<22 ) {
					/* Beat Up */
					tempo++;
					if ( tempo > tempo_max ) tempo = tempo_max;
					_clockmanager_divisor( _cm_gp1, tempo_table[tempo<<1] );
					tempo_count_reload = tempo_table[(tempo<<1) + 1];

				// 0b11110 (30)
				} else if ( detect_parallel == 0b11110<<22 ) {
					/* Beat Down */
					tempo--;
					if ( tempo < 0 ) tempo = 0;
					_clockmanager_divisor( _cm_gp1, tempo_table[tempo<<1] );
					tempo_count_reload = tempo_table[(tempo<<1) + 1];

				// 0b11111 (31)
				} else if ( detect_parallel == 0b11111<<22 ) {
					_syntheclear( 2 );

				}

				result = _syntheplay( 2 );
				if ( result == 0 ) { // Playing
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
