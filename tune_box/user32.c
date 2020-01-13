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
#include "snd32/soundindex.h"
#include "snd32/soundadjust.h"
#include "snd32/musiccode.h"
#include "pwm32/notes_le.h"

#define timer_count_multiplicand        5
#define timer_count_multiplier_default  100
#define timer_count_multiplier_minlimit 20
#define timer_count_multiplier_maxlimit 200

extern uint32 OS_RESET_MIDI_CHANNEL;

void makesilence();

#define loop_countdown_default          10 // one out of ten

/**
 * In default, there is a 480Hz synchronization clock (it's a half of 960Hz on Arm Timer beacause of toggling).
 * To set 48 beats as 60 BPM, decoding of sequence of music code (_soundplay) plays at only one clock out of ten clocks.
 * A set of 48 beats (= delta times) is 60BPM on 48HZ (one delta time is 1/48 seconds).
 * Arm Timer sets 480000Hz as clock.
 * 500 is divisor (timer_count_multiplicand * timer_count_multiplier_defualt), i.e., 480000Hz / 250 / 2 equals 480Hz (60BPM).
 * The Maximum beat (480000 / (timer_count_multiplicand * timer_count_multiplier_minlimit) / 2) is 2400Hz (300BPM).
 * The minimum beat (480000 / (timer_count_multiplicand * timer_count_multiplier_maxlimit) / 2) is 240Hz (30BPM).
 *
 * If you want particular BPM for a track, use _armtimer_reload and/or _armtimer prior to _soundset.
 */

pwm_sequence music1_pulse1[] =
{
	_12(_RAP(1<<31|(_C4_LE/2),1<<31|_C4_LE))
	_12(_RAP(1<<31|0,1<<31|1))
	_12(_RAP(1<<31|(_E4_LE/2),1<<31|_E4_LE))
	_12(_RAP(1<<31|0,1<<31|1))
	_12(_RAP(1<<31|(_G4_LE/2),1<<31|_G4_LE))
	_12(_RAP(1<<31|0,1<<31|1))
	PWM32_END
};

pwm_sequence music1_pulse2[] =
{
	_12(_RAP(1<<31|(_E4_LE/2),1<<31|_E4_LE))
	_12(_RAP(1<<31|0,1<<31|1))
	_12(_RAP(1<<31|(_G4_LE/2),1<<31|_G4_LE))
	_12(_RAP(1<<31|0,1<<31|1))
	_12(_RAP(1<<31|(_C5_LE/2),1<<31|_C5_LE))
	_12(_RAP(1<<31|0,1<<31|1))
	PWM32_END
};

music_code music1_flex[] =
{
	_12(_C4_SINL)
	_4(_E4_SINL) _4(_G4_SINL) _4(_C5_SINL)
	_12(_E4_SINL)
	_4(_G4_SINL) _4(_C5_SINL) _4(_E5_SINL)
	_12(_G4_SINL)
	_4(_E5_SINL) _4(_G5_SINL) _4(_C6_SINL)
	_END
};

music_code interrupt16_flex[] =
{
	_4_BIG(_RAP(
		_48_RYU_ARP(_D4_TRIL)
		_24_RYU_ARP(_G4_TRIL) _24_RYU_ARP(_G4_TRIL)
		_48_RYU_ARP(_D5_TRIL)
		_48_RYU_ARP(_D4_TRIL)
	))
	_END
};

void makesilence() {

	_soundclear(True);
	_pwmselect( 0 );
	_pwmclear( False );
	_pwmselect( 1 );
	_pwmclear( False );

}

int32 _user_start() {

	uint32 timer_count_multiplier = timer_count_multiplier_default;
	bool flag_midi_noteon = False;
	uint32 detect_parallel = 0;
	uchar8 result;
	uchar8 playing_signal;
	bool mode_soundplay;
	uint32 delta_multiplier;

	/* Use Signed Integer to Prevent Incorrect Compilation (Using Comparison in IF Statement) */
	int32 loop_countdown = loop_countdown_default;

#if defined(__SOUND_I2S_BALANCED)
	_sounddecode( _SOUND_INDEX, SND32_I2S_BALANCED, _SOUND_ADJUST );
	mode_soundplay = True;
	delta_multiplier = 6;
#else
	_sounddecode( _SOUND_INDEX, SND32_I2S, _SOUND_ADJUST );
	mode_soundplay = True;
	delta_multiplier = 6;
#endif

	// To Get Proper Latency, Get Lengths in Advance
	uint32 musiclen1_flex = snd32_musiclen( music1_flex );
	uint32 musiclen16_flex = snd32_musiclen( interrupt16_flex );
	uint32 musiclen1_pulse1 = pwm32_pwmlen( music1_pulse1 ) / 2;
	uint32 musiclen1_pulse2 = pwm32_pwmlen( music1_pulse2 ) / 2;

	makesilence();

	while ( true ) {
		_soundmidi( OS_RESET_MIDI_CHANNEL, SND32_MIDI_PCM );

		/* High on GPIO20 If MIDI Note On */
		if ( SND32_STATUS & 0x4 ) { // Bit[2] MIDI Note Off(0)/ Note On(1)
			if ( ! flag_midi_noteon ) {
				flag_midi_noteon = True;
				_gpiotoggle( 20, flag_midi_noteon ); // Gate On
			}
		} else {
			if ( flag_midi_noteon ) {
				flag_midi_noteon = False;
				_gpiotoggle( 20, flag_midi_noteon ); // Gate Off
			}
		}

		/* Detect Falling Edge of GPIO */
		if ( _gpio_detect( 27 ) ) {
			detect_parallel = _load_32( _gpio_base|_gpio_gpeds0 );
			_store_32( _gpio_base|_gpio_gpeds0, detect_parallel );
			detect_parallel = (detect_parallel>>22)|0x80000000; // Set Outstanding Flag
		}

		/* If Any Non Zero */
		if ( detect_parallel ) {
			detect_parallel &= 0b11111;

			/* GPIO22-26 as Bit[26:22] */
			// 0b00001 (1)
			if ( detect_parallel == 0b00001 ) {
				_soundset( music1_flex, musiclen1_flex, 0, -1 );
				_pwmselect( 0 );
				_pwmset( music1_pulse1, musiclen1_pulse1, 0, -1 );
				_pwmselect( 1 );
				_pwmset( music1_pulse2, musiclen1_pulse2, 0, -1 );

			// 0b00010 (2)
			} else if ( detect_parallel == 0b00010 ) {
				makesilence();

			// 0b00011 (3)
			} else if ( detect_parallel == 0b00011 ) {
				makesilence();

			// 0b00100 (4)
			} else if ( detect_parallel == 0b00100 ) {
				makesilence();

			// 0b00101 (5)
			} else if ( detect_parallel == 0b00101 ) {
				makesilence();

			// 0b00110 (6)
			} else if ( detect_parallel == 0b00110 ) {
				makesilence();

			// 0b00111 (7)
			} else if ( detect_parallel == 0b00111 ) {
				makesilence();

			// 0b01000 (8)
			} else if ( detect_parallel == 0b01000 ) {
				makesilence();

			// 0b01001 (9)
			} else if ( detect_parallel == 0b01001 ) {
				SND32_MODULATION_DELTA = 0x10 * delta_multiplier;
				SND32_MODULATION_RANGE = 0x1000 * delta_multiplier;

			// 0b01010 (10)
			} else if ( detect_parallel == 0b01010 ) {
				SND32_MODULATION_DELTA = 0x0 * delta_multiplier;
				SND32_MODULATION_RANGE = 0x0 * delta_multiplier;

			// 0b01011 (11)
			} else if ( detect_parallel == 0b01011 ) {
				makesilence();

			// 0b01100 (12)
			} else if ( detect_parallel == 0b01100 ) {
				makesilence();

			// 0b01101 (13)
			} else if ( detect_parallel == 0b01101 ) {
				makesilence();

			// 0b01110 (14)
			} else if ( detect_parallel == 0b01110 ) {
				makesilence();

			// 0b01111 (15)
			} else if ( detect_parallel == 0b01111 ) {
				makesilence();

			// 0b10000 (16)
			} else if ( detect_parallel == 0b10000 ) {
				_soundinterrupt( interrupt16_flex, musiclen16_flex, 0, 1 );

			// 0b10001 (17)
			} else if ( detect_parallel == 0b10001 ) {
				makesilence();

			// 0b10010 (18)
			} else if ( detect_parallel == 0b10010 ) {
				makesilence();

			// 0b10011 (19)
			} else if ( detect_parallel == 0b10011 ) {
				makesilence();

			// 0b10100 (20)
			} else if ( detect_parallel == 0b10100 ) {
				makesilence();

			// 0b10101 (21)
			} else if ( detect_parallel == 0b10101 ) {
				makesilence();

			// 0b10110 (22)
			} else if ( detect_parallel == 0b10110 ) {
				makesilence();

			// 0b10111 (23)
			} else if ( detect_parallel == 0b10111 ) {
				makesilence();

			// 0b11000 (24)
			} else if ( detect_parallel == 0b11000 ) {
				makesilence();

			// 0b11001 (25)
			} else if ( detect_parallel == 0b11001 ) {
				makesilence();

			// 0b11010 (26)
			} else if ( detect_parallel == 0b11010 ) {
				makesilence();

			// 0b11011 (27)
			} else if ( detect_parallel == 0b11011 ) {
				makesilence();

			// 0b11100 (28)
			} else if ( detect_parallel == 0b11100 ) {
				makesilence();

			// 0b11101 (29)
			} else if ( detect_parallel == 0b11101 ) {
				/* Beat Up */
				timer_count_multiplier -= 5;
				if ( timer_count_multiplier < timer_count_multiplier_minlimit ) timer_count_multiplier = timer_count_multiplier_minlimit;
				_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );

			// 0b11110 (30)
			} else if ( detect_parallel == 0b11110 ) {
				/* Beat Down */
				timer_count_multiplier += 5;
				if ( timer_count_multiplier > timer_count_multiplier_maxlimit ) timer_count_multiplier = timer_count_multiplier_maxlimit;
				_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );

			// 0b11111 (31)
			} else if ( detect_parallel == 0b11111 ) {
				makesilence();
			}
			detect_parallel = 0;
		}

		/* Detect Rising Edge of GPIO */
		if ( _gpio_detect( 17 ) ) {
			if ( SND32_VIRTUAL_PARALLEL ) {
				detect_parallel = SND32_VIRTUAL_PARALLEL;
				SND32_VIRTUAL_PARALLEL = 0;
			}

//print32_debug( detect_parallel, 100, 100 );

			// Subtract Pitch Bend Ratio to Divisor (Upside Down)
			_clockmanager_divisor( _cm_pcm, SND32_DIVISOR - SND32_SOUNDMIDI_PITCHBEND );

/*
print32_debug( SND32_DIVISOR, 100, 100 );
print32_debug( SND32_MODULATION_DELTA, 100, 112 );
print32_debug( SND32_MODULATION_MAX, 100, 124 );
print32_debug( SND32_MODULATION_MIN, 100, 136 );
*/

			/* Triangle LFO */
			SND32_DIVISOR += SND32_MODULATION_DELTA;
			if ( SND32_DIVISOR >= SND32_MODULATION_MAX ) {
				SND32_DIVISOR = SND32_MODULATION_MAX;
				SND32_MODULATION_DELTA = -( SND32_MODULATION_DELTA );
			} else if ( SND32_DIVISOR <= SND32_MODULATION_MIN ) {
				SND32_DIVISOR = SND32_MODULATION_MIN;
				SND32_MODULATION_DELTA = -( SND32_MODULATION_DELTA );
			}

			arm32_dsb();

			loop_countdown--; // Decrement Counter
			if ( loop_countdown <= 0 ) { // If Reaches Zero
				result = _soundplay( mode_soundplay );
				if ( result == 0 ) { // Playing
					playing_signal = _GPIOTOGGLE_HIGH;
				} else { // Not Playing
					playing_signal = _GPIOTOGGLE_LOW;
				}
				_gpiotoggle( 16, playing_signal );
				/**
				 * PWM Play
				 */
				_pwmselect( 0 );
				_pwmplay( False, True ); // Wide PWM Sequence
				_pwmselect( 1 );
				_pwmplay( False, True ); // Wide PWM Sequence
				loop_countdown = loop_countdown_default; // Reset Counter
			}
		}
	}

	return EXIT_SUCCESS;
}
