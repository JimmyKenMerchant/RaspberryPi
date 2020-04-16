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
#include "user32_sample.h"

/**
 * Global Variables and Constants
 * to Prevent Incorrect Compilation in optimization,
 * Variables (except these which have only one value) used over the iteration of the loop are defined as global variables.
 */

extern uint32 OS_RESET_MIDI_CHANNEL; // From vector32.s

#define TEMPO_COUNT_DEFAULT  2
#define TEMPO_DEFAULT 60
#define TEMPO_MAX 420
#define PARALLEL_MASK                   0b11111 // 5-bit
#define PARALLEL_OUTSTANDING_FLAG       0x80000000 // MSB
#define GPIO_PARALLEL_LSB               22
#define GPIO_CLOCKIN_PARALLEL           27
#define GPIO_BUSY_TOGGLE                14
#define GPIO_CLOCKIN_RYTHMSYNC          5
#define GPIO_PLAYING_SIGNAL             16

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

#define PRE_SYNTHE_NUMBER 30

/* Register for Precodes */
synthe_precode** pre_synthe_table[PRE_SYNTHE_NUMBER] = {
	pre_sample_1,
	pre_sample_2,
	pre_sample_3,
	pre_sample_4,
	pre_sample_5,
	pre_sample_drumnbass,
	pre_sample_lofi,
	pre_sample_8,
	pre_sample_house,
	pre_sample_16,
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
	 6,
	 7,
	 8,
	 9,
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
		if ( _gpio_detect( GPIO_CLOCKIN_PARALLEL ) ) {
			// Load Pin Level and Set Outstanding Flag
			detect_parallel = ((_load_32( _gpio_base|_gpio_gplev0 ) >> GPIO_PARALLEL_LSB ) & PARALLEL_MASK) | PARALLEL_OUTSTANDING_FLAG;
		}

		/* Command Execution */
		if ( detect_parallel ) { // If Any Non Zero Including Outstanding Flag
			_gpiotoggle( GPIO_BUSY_TOGGLE, _GPIOTOGGLE_SWAP ); // Busy Toggle
			detect_parallel &= 0x7F; // 0-127
			if ( detect_parallel > 111 ) { // 112(0x70)-127(0x7F)
				// Tempo Index Upper 8-bit
				tempo_index = (tempo_index & 0x0F) | ((detect_parallel & 0x0F) << 4);
				// Integer 30-240 BPM
				tempo = tempo_index << 1;
				if ( tempo > TEMPO_MAX ) tempo = TEMPO_MAX;
				_clockmanager_divisor( _cm_gp1, tempo_table[tempo << 1] );
				tempo_count_reload = tempo_table[(tempo << 1) + 1];
			} else if ( detect_parallel > 95 ) { // 96(0x60)-111(0x6F)
				// Tempo Index Lower 8-bit
				tempo_index = (tempo_index & 0xF0) | (detect_parallel & 0x0F);
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
			} // Do Nothing at 0 for Preventing Chattering If Any Mechanical Switch
			detect_parallel = 0;
		}

		/* Detect Rising Edge of GPIO */
		if ( _gpio_detect( GPIO_CLOCKIN_RYTHMSYNC ) ) {
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
				_gpiotoggle( GPIO_PLAYING_SIGNAL, playing_signal );

				_synthemidi_envelope( 8 );

				tempo_count = tempo_count_reload; // Reset Counter
			}
		}
	}
	return EXIT_SUCCESS;
}
