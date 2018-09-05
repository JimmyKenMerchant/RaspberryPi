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
#include "snd32.h"

#define timer_count_multiplicand        5
#define timer_count_multiplier_default  500
#define timer_count_multiplier_minlimit 125
#define timer_count_multiplier_maxlimit 1000

void makesilence();

/**
 * In default, there is a 48Hz synchronization clock (it's a half of 96Hz on Arm Timer beacause of toggling).
 * Arm Timer sets 240000Hz as clock.
 * 2500 is divisor (timer_count_multiplicand * timer_count_multiplier_defualt), i.e., 240000Hz / 2500 / 2 equals 48Hz (60BPM).
 * The Maximum beat (240000 / (timer_count_multiplicand * timer_count_multiplier_minlimit) / 2) is 192Hz (240BPM).
 * The minimum beat (240000 / (timer_count_multiplicand * timer_count_multiplier_maxlimit) / 2) is 24Hz (30BPM).
 *
 * If you want particular BPM for a track, use _armtimer_reload and/or _armtimer prior to _soundset.
 */

music_code music1[] =
{
	_48(_3_NOIS) _48(_3_NOIS)
	_48(_7_NOIS) _48(_7_NOIS)
	_48(_15_NOIS) _48(_15_NOIS)
	_48(_31_NOIS) _48(_31_NOIS)
	_48(_63_NOIS) _48(_63_NOIS)
	_48(_127_NOIS) _48(_127_NOIS)
	_48(_255_NOIS) _48(_255_NOIS)
	_48(_511_NOIS) _48(_511_NOIS)

	_48(_3_NOIM) _48(_3_NOIM)
	_48(_7_NOIM) _48(_7_NOIM)
	_48(_15_NOIM) _48(_15_NOIM)
	_48(_31_NOIM) _48(_31_NOIM)
	_48(_63_NOIM) _48(_63_NOIM)
	_48(_127_NOIM) _48(_127_NOIM)
	_48(_255_NOIM) _48(_255_NOIM)
	_48(_511_NOIM) _48(_511_NOIM)

	_48(_3_NOIL) _48(_3_NOIL)
	_48(_7_NOIL) _48(_7_NOIL)
	_48(_15_NOIL) _48(_15_NOIL)
	_48(_31_NOIL) _48(_31_NOIL)
	_48(_63_NOIL) _48(_63_NOIL)
	_48(_127_NOIL) _48(_127_NOIL)
	_48(_255_NOIL) _48(_255_NOIL)
	_48(_511_NOIL) _48(_511_NOIL)

	_END
};

music_code music2[] =
{
	_12(_E4_TRIL)
	_END
};

music_code music3[] =
{
	_12(_C4_SINL)
	_4(_E4_SINL) _4(_G4_SINL) _4(_C5_SINL)
	_12(_E4_SINL)
	_4(_G4_SINL) _4(_C5_SINL) _4(_E5_SINL)
	_12(_G4_SINL)
	_4(_E5_SINL) _4(_G5_SINL) _4(_C6_SINL)
	_END
};

music_code music4[] =
{
	_12_MAJ(_C4_SINL) _12_MAJ(_E4_SINL) _12_MAJ(_G4_SINL) _12_MAJ(_B4_SINL)
	_12_MAJ(_E4_SINL) _12_MAJ(_G4_SINL) _12_MAJ(_B4_SINL) _12_MAJ(_D5_SINL)
	_12_MAJ(_G4_SINL) _12_MAJ(_B4_SINL) _12_MAJ(_D5_SINL) _12_MAJ(_F5_SINL)
	_END
};

music_code music5[] =
{
	_24_DEC(_A4_TRIL) _24_DEC(_B4_TRIL)
	_24_DEC(_C5_TRIL) _24_DEC(_B4_TRIL)
	_24_DEC(_A4_TRIL) _24(_A4_TRIS)
	_48(_SILENCE)
	_END
};

music_code music6[] =
{
	_24_M(_C3_SINL) _24_M(_B2_SINL)
	_24_M(_A2_SINL) _24_M(_B2_SINL)
	_END
};

music_code music7[] =
{
	_48_9TH(_F4_TRIL)
	_END
};

music_code music8[] =
{
	_48_DOM(_D4_TRIL)
	_24_DOM_ARP(_G4_TRIL) _24_DOM_ARP(_G4_TRIL)
	_48_DOM(_D5_TRIL)
	_48_DOM(_D4_TRIL)
	_END
};

music_code interrupt16[] =
{
	_4_BIG(_RAP(
		_48_RYU_ARP(_D4_TRIL)
		_24_RYU_ARP(_G4_TRIL) _24_RYU_ARP(_G4_TRIL)
		_48_RYU_ARP(_D5_TRIL)
		_48_RYU_ARP(_D4_TRIL)
	))
	_1_BIG(_RAP(
		_48(_SILENCE)
	))
	_END
};

music_code silence31[] =
{
	_48(_SILENCE)
	_END
};

// Use in Function, makesilence
uint32 musiclen31;

void makesilence()
{

#ifdef __SOUND_I2S
	_soundclear();
#elif defined(__SOUND_I2S_BALANCED)
	_soundclear();
#elif defined(__SOUND_PWM)
	/* Prevent Popping Noise on Start to Have DC Bias on PWM Mode */
	_soundset( silence31, musiclen31, 0, -1 );
#elif defined(__SOUND_PWM_BALANCED)
	/* Prevent Popping Noise on Start to Have DC Bias on PWM Mode */
	_soundset( silence31, musiclen31, 0, -1 );
#elif defined(__SOUND_JACK)
	/* Prevent Popping Noise on Start to Have DC Bias on PWM Mode */
	_soundset( silence31, musiclen31, 0, -1 );
#elif defined(__SOUND_JACK_BALANCED)
	/* Prevent Popping Noise on Start to Have DC Bias on PWM Mode */
	_soundset( silence31, musiclen31, 0, -1 );
#endif

}

int32 _user_start()
{

	uint32 timer_count_multiplier = timer_count_multiplier_default;
	uint32 detect_parallel;
	uchar8 result;
	uchar8 playing_signal;

#ifdef __SOUND_I2S
	_sounddecode( _SOUND_INDEX, SND32_I2S );
#elif defined(__SOUND_I2S_BALANCED)
	_sounddecode( _SOUND_INDEX, SND32_I2S_BALANCED );
#elif defined(__SOUND_PWM)
	_sounddecode( _SOUND_INDEX, SND32_PWM );
#elif defined(__SOUND_PWM_BALANCED)
	_sounddecode( _SOUND_INDEX, SND32_PWM_BALANCED );
#elif defined(__SOUND_JACK)
	_sounddecode( _SOUND_INDEX, SND32_PWM );
#elif defined(__SOUND_JACK_BALANCED)
	_sounddecode( _SOUND_INDEX, SND32_PWM_BALANCED );
#endif

	// To Get Proper Latency, Get Lengths in Advance
	uint32 musiclen1 = snd32_musiclen( music1 );
	uint32 musiclen2 = snd32_musiclen( music2 );
	uint32 musiclen3 = snd32_musiclen( music3 );
	uint32 musiclen4 = snd32_musiclen( music4 );
	uint32 musiclen5 = snd32_musiclen( music5 );
	uint32 musiclen6 = snd32_musiclen( music6 );
	uint32 musiclen7 = snd32_musiclen( music7 );
	uint32 musiclen8 = snd32_musiclen( music8 );
	uint32 musiclen16 = snd32_musiclen( interrupt16 );
	musiclen31 = snd32_musiclen( silence31 );

	makesilence();

	while ( true ) {
		if ( _gpio_detect( 27 ) ) {

			detect_parallel = _load_32( _gpio_base|_gpio_gpeds0 );
			_store_32( _gpio_base|_gpio_gpeds0, detect_parallel );

//print32_debug( detect_parallel, 100, 100 );

			/* GPIO22-26 as Bit[26:22] */
			// 0b00001 (1)
			if ( detect_parallel == 0b00001<<22 ) {
				_soundset( music1, musiclen1, 0, -1 );
				//makesilence();

			// 0b00010 (2)
			} else if ( detect_parallel == 0b00010<<22 ) {
				_soundset( music2, musiclen2, 0, -1 );
				/* Beat Up */
				//timer_count_multiplier -= 5;
				//if ( timer_count_multiplier < timer_count_multiplier_minlimit ) timer_count_multiplier = timer_count_multiplier_minlimit;
				//_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );


			// 0b00011 (3)
			} else if ( detect_parallel == 0b00011<<22 ) {
				_soundset( music3, musiclen3, 0, -1 );

			// 0b00100 (4)
			} else if ( detect_parallel == 0b00100<<22 ) {
				_soundset( music4, musiclen4, 0, -1 );
				/* Beat Down */
				//timer_count_multiplier += 5;
				//if ( timer_count_multiplier > timer_count_multiplier_maxlimit ) timer_count_multiplier = timer_count_multiplier_maxlimit;
				//_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );

			// 0b00101 (5)
			} else if ( detect_parallel == 0b00101<<22 ) {
				_soundset( music5, musiclen5, 0, -1 );

			// 0b00110 (6)
			} else if ( detect_parallel == 0b00110<<22 ) {
				_soundset( music6, musiclen6, 0, -1 );

			// 0b00111 (7)
			} else if ( detect_parallel == 0b00111<<22 ) {
				_soundset( music7, musiclen7, 0, -1 );

			// 0b01000 (8)
			} else if ( detect_parallel == 0b01000<<22 ) {
				_soundset( music8, musiclen8, 0, -1 );

			// 0b01001 (9)
			} else if ( detect_parallel == 0b01001<<22 ) {
				makesilence();

			// 0b01010 (10)
			} else if ( detect_parallel == 0b01010<<22 ) {
				makesilence();

			// 0b01011 (11)
			} else if ( detect_parallel == 0b01011<<22 ) {
				makesilence();

			// 0b01100 (12)
			} else if ( detect_parallel == 0b01100<<22 ) {
				makesilence();

			// 0b01101 (13)
			} else if ( detect_parallel == 0b01101<<22 ) {
				makesilence();

			// 0b01110 (14)
			} else if ( detect_parallel == 0b01110<<22 ) {
				makesilence();

			// 0b01111 (15)
			} else if ( detect_parallel == 0b01111<<22 ) {
				makesilence();

			// 0b10000 (16)
			} else if ( detect_parallel == 0b10000<<22 ) {
				_soundinterrupt( interrupt16, musiclen16, 0, 1 );

			// 0b10001 (17)
			} else if ( detect_parallel == 0b10001<<22 ) {
				makesilence();

			// 0b10010 (18)
			} else if ( detect_parallel == 0b10010<<22 ) {
				makesilence();

			// 0b10011 (19)
			} else if ( detect_parallel == 0b10011<<22 ) {
				makesilence();

			// 0b10100 (20)
			} else if ( detect_parallel == 0b10100<<22 ) {
				makesilence();

			// 0b10101 (21)
			} else if ( detect_parallel == 0b10101<<22 ) {
				makesilence();

			// 0b10110 (22)
			} else if ( detect_parallel == 0b10110<<22 ) {
				makesilence();

			// 0b10111 (23)
			} else if ( detect_parallel == 0b10111<<22 ) {
				makesilence();

			// 0b11000 (24)
			} else if ( detect_parallel == 0b11000<<22 ) {
				makesilence();

			// 0b11001 (25)
			} else if ( detect_parallel == 0b11001<<22 ) {
				makesilence();

			// 0b11010 (26)
			} else if ( detect_parallel == 0b11010<<22 ) {
				makesilence();

			// 0b11011 (27)
			} else if ( detect_parallel == 0b11011<<22 ) {
				makesilence();

			// 0b11100 (28)
			} else if ( detect_parallel == 0b11100<<22 ) {
				makesilence();

			// 0b11101 (29)
			} else if ( detect_parallel == 0b11101<<22 ) {
				/* Beat Up */
				timer_count_multiplier -= 5;
				if ( timer_count_multiplier < timer_count_multiplier_minlimit ) timer_count_multiplier = timer_count_multiplier_minlimit;
				_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );

			// 0b11110 (30)
			} else if ( detect_parallel == 0b11110<<22 ) {
				/* Beat Down */
				timer_count_multiplier += 5;
				if ( timer_count_multiplier > timer_count_multiplier_maxlimit ) timer_count_multiplier = timer_count_multiplier_maxlimit;
				_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );

			// 0b11111 (31)
			} else if ( detect_parallel == 0b11111<<22 ) {
				makesilence();
			}

			result = _soundplay();
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
