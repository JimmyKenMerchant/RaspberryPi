/**
 * user32.c
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * Usage
 * 1. Place `snd32_soundplay` on FIQ/IRQ Handler which will be triggered with any timer.
 * 2. Place `_sounddecode` with Sound Index as an argument in `user32.c` before `snd32_soundset`.
 * 3. Place `_soundset` with needed arguments in `user32.c`.
 * 4. Music code automatically plays the sound with the assigned values.
 * 5. If you want to interrupt the playing sound to play another, use '_soundinterrupt'.
 * 6. If you want to stop the playing sound, use '_soundclear'.
 */

#include "system32.h"
#include "system32.c"
#include "sound32.h"

#define timer_count_default 5000
#define clock_divisor_int_defualt 2

/**
 * Sound Index is made of an array of 16-bit Blocks.
 * Bit[11:0]: Length of Wave, 0 to 4095.
 *             If Bit[11:0] is 0, Long (0x1F40, Decimal 8000).
 *             If Bit[11:0] is 1, Super Long (0x3E80, Decimal 16000).
 * Bit[13:12]: Volume of Wave, 0 is Max., 1 is Bigger, 2 is Smaller, 3 is Zero (In Noise, Least).
 * Bit[15:14]: Type of Wave, 0 is Sin, 1 is Triangle, 2 is Square, 3 is Noise, ordered by less edges which cause harmonics.
 *
 * Maximum number of blocks is 4096.
 * 0 means End of Sound Index
 */

/**
 * Music Code is 16-bit Blocks. Select up to 4096 sounds indexed by Sound Index.
 * Index is 0-4096.
 * 0xFFFF(65535) means End of Music Code.
 */

music_code music1[] =
{
	BEAT12(C4_SINL)
	SND_END
};

music_code music2[] =
{
	0x2B, 0x2E, 0x32, 0x2B, 0x2E, 0x32, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33,
	0xFFFF
};

music_code music3[] =
{
	0x27, 0x2B, 0x2E, 0x27, 0x2B, 0x2E, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30,
	0xFFFF
};

music_code interrupt1[] =
{
	0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,
	0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,
	0x32,0x32,0x32,0x32,0x32,0x32,0x32,0x32,0x32,0x32,0x32,0x32,
	0x32,0x32,0x32,0x32,0x32,0x32,0x32,0x32,0x32,0x32,0x32,0x32,
	0x64,0x64,0x64,0x64,0x64,0x64,0x64,0x64,0x64,0x64,0x64,0x64,
	0x64,0x64,0x64,0x64,0x64,0x64,0x64,0x64,0x64,0x64,0x64,0x64,
	0x72,0x72,0x72,0x72,0x72,0x72,0x72,0x72,0x72,0x72,0x72,0x72,
	0x72,0x72,0x72,0x72,0x72,0x72,0x72,0x72,0x72,0x72,0x72,0x72,
	0xA4,0xA4,0xA4,0xA4,0xA4,0xA4,0xA4,0xA4,0xA4,0xA4,0xA4,0xA4,
	0xA4,0xA4,0xA4,0xA4,0xA4,0xA4,0xA4,0xA4,0xA4,0xA4,0xA4,0xA4,
	0xB2,0xB2,0xB2,0xB2,0xB2,0xB2,0xB2,0xB2,0xB2,0xB2,0xB2,0xB2,
	0xB2,0xB2,0xB2,0xB2,0xB2,0xB2,0xB2,0xB2,0xB2,0xB2,0xB2,0xB2,
	0xE4,0xE4,0xE4,0xE4,0xE4,0xE4,0xE4,0xE4,0xE4,0xE4,0xE4,0xE4,
	0xE4,0xE4,0xE4,0xE4,0xE4,0xE4,0xE4,0xE4,0xE4,0xE4,0xE4,0xE4,
	0xF2,0xF2,0xF2,0xF2,0xF2,0xF2,0xF2,0xF2,0xF2,0xF2,0xF2,0xF2,
	0xF2,0xF2,0xF2,0xF2,0xF2,0xF2,0xF2,0xF2,0xF2,0xF2,0xF2,0xF2,
	0xFFFF
};

int32 _user_start()
{
	String str_ready = "Get Ready?\0";
	String str_music1 = "Music No.1\0";
	String str_music2 = "Music No.2\0";
	String str_music3 = "Music No.3\0";
	int32 timer_count_divisor = 1;
	uint32 detect_parallel = 0;
	//uint32 clock_divisor_fraction = 0;

	_armtimer_reload( arm32_udiv( timer_count_default, timer_count_divisor ) - 1 );

#ifdef __SOUND_I2S
	_sounddecode( sound, true );
#else
	_sounddecode( sound, false );
#endif

	print32_string( str_ready, 300, 300, str32_strlen( str_ready ) );

	while ( true ) {
		if ( _gpio_detect( 27 ) ) {
			_soundplay();
			detect_parallel = _load_32( _gpio_base|_gpio_gpeds0 );
			_store_32( _gpio_base|_gpio_gpeds0, detect_parallel );

//print32_debug( detect_parallel, 100, 100 );

			if ( detect_parallel == 1<<22 ) {
				_soundclear();
				print32_string( str_ready, 300, 300, str32_strlen( str_ready ) );
			} else if ( detect_parallel == 1<<23 ) {
				_armtimer_load( arm32_udiv( timer_count_default, timer_count_divisor ) - 1 );
				_soundset( music1, snd32_musiclen( music1 ) , 0, -1 );
				print32_string( str_music1, 300, 300, str32_strlen( str_music1 ) );
			} else if ( detect_parallel == 1<<24 ) {
				_armtimer_load( arm32_udiv( timer_count_default, timer_count_divisor ) - 1 );
				_soundset( music2, snd32_musiclen( music2 ) , 0, -1 );
				print32_string( str_music2, 300, 300, str32_strlen( str_music2 ) );
			} else if ( detect_parallel == 1<<25 ) {
				_armtimer_load( arm32_udiv( timer_count_default, timer_count_divisor ) - 1 );
				_soundset( music3, snd32_musiclen( music3 ) , 0, -1 );
				print32_string( str_music3, 300, 300, str32_strlen( str_music3 ) );
			} else if ( detect_parallel == 1<<26 ) {
				_soundinterrupt( interrupt1, snd32_musiclen( interrupt1 ) , 0, 1 );
			}
			/*
			if ( _gpio_in( 26 ) ) {
				timer_count_divisor++;
				if ( timer_count_divisor > timer_count_default / 2 ) timer_count_divisor = timer_count_default / 2;
				_armtimer_reload( arm32_udiv( timer_count_default, timer_count_divisor ) - 1 );
				break;
			}

			if ( _gpio_in( 26 ) ) {
				// Tuner Using Fractional Divisor, but Noise Exist
				clock_divisor_fraction += 1;
				if ( clock_divisor_fraction > 1023 ) clock_divisor_fraction = 1023;
				_clockmanager( _cm_pwm, _cm_ctl_mash_1|_cm_ctl_src_osc, clock_divisor_int_defualt<<_cm_div_integer|clock_divisor_fraction<<_cm_div_fraction );
				break;
			}
			if ( _gpio_in( 26 ) ) {
				timer_count_divisor--;
				if ( timer_count_divisor < 1 ) timer_count_divisor = 1;
				_armtimer_reload( arm32_udiv( timer_count_default, timer_count_divisor ) - 1 );
				break;
			}
			if ( _gpio_detect( 276 ) ) {
				timer_count_divisor--;
				if ( timer_count_divisor < 1 ) timer_count_divisor = 1;
				_armtimer_reload( arm32_udiv( timer_count_default, timer_count_divisor ) - 1 );
				break;
			}
			*/
		}
	}

	return EXIT_SUCCESS;
}
