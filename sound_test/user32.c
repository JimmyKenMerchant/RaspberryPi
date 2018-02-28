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

#define timer_count_default 10000
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
	  3,  5,  7,  8, 10, 12, 14, 15, 10, 10, 10, 10,
	161,161, 10,  7,  3, 10,  7,  3,  8, 10, 12, 14,
	 15, 15, 15, 15, 10, 10, 10, 10,  7,  7,  7,  7,
	  3,  3,  3,  3,  3,  3,  3,  3,161,161,161,161,
	161,161,161,161,161,161,161,161,161,161,161,161,
	0xFFFF
};

music_code music2[] =
{
	9,8,7,6,5,4,3,4,5,6,7,8,
	9,9,9,9,9,9,8,8,8,8,8,8,
	7,7,7,7,7,7,6,6,6,6,6,6,
	5,5,4,4,3,3,3,3,4,4,5,5,
	0xFFFF
};

music_code music3[] =
{
	160,
	0xFFFF
};

music_code interrupt1[] =
{
	7,8,9,7,8,9,7,8,9,7,8,9,
	0xFFFF
};

int32 _user_start()
{
	String str_ready = "Get Ready?\0";
	String str_music1 = "Music No.1\0";
	String str_music2 = "Music No.2\0";
	String str_music3 = "Music No.3\0";
	int32 timer_count_divisor = 1;
	uint32 clock_divisor_fraction = 0;

	_armtimer_reload( arm32_udiv( timer_count_default, timer_count_divisor ) - 1 );

	_sounddecode( sound );

	print32_string( str_ready, 300, 300, str32_strlen( str_ready ) );

	while(true) {
		while( true ) {
			if ( _gpio_detect( 20 ) ) {
				_soundclear();
				print32_string( str_ready, 300, 300, str32_strlen( str_ready ) );
				break;
			}
			if ( _gpio_detect( 21 ) ) {
				_soundset( music1, snd32_musiclen( music1 ) , 0, -1 );
				print32_string( str_music1, 300, 300, str32_strlen( str_music1 ) );
				break;
			}
			if ( _gpio_detect( 22 ) ) {
				_soundset( music2, snd32_musiclen( music2 ) , 0, -1 );
				print32_string( str_music2, 300, 300, str32_strlen( str_music2 ) );
				break;
			}
			if ( _gpio_detect( 23 ) ) {
				_soundset( music3, snd32_musiclen( music3 ) , 0, -1 );
				print32_string( str_music3, 300, 300, str32_strlen( str_music3 ) );
				break;
			}
			if ( _gpio_detect( 24 ) ) {
				/* Tuner Using Fractional Divisor, but Noise Exist */
				clock_divisor_fraction += 1;
				if ( clock_divisor_fraction > 1023 ) clock_divisor_fraction = 1023;
				_clockmanager( _cm_pwm, _cm_ctl_mash_1|_cm_ctl_src_osc, clock_divisor_int_defualt<<_cm_div_integer|clock_divisor_fraction<<_cm_div_fraction );
				break;
			}
			if ( _gpio_detect( 25 ) ) {
				timer_count_divisor++;
				if ( timer_count_divisor > timer_count_default / 2 ) timer_count_divisor = timer_count_default / 2;
				_armtimer_reload( arm32_udiv( timer_count_default, timer_count_divisor ) - 1 );
				break;
			}
			if ( _gpio_detect( 26 ) ) {
				timer_count_divisor--;
				if ( timer_count_divisor < 1 ) timer_count_divisor = 1;
				_armtimer_reload( arm32_udiv( timer_count_default, timer_count_divisor ) - 1 );
				break;
			}
			if ( _gpio_detect( 27 ) ) {
				_soundinterrupt( interrupt1, snd32_musiclen( interrupt1 ) , 0, 1 );
				break;
			}
			_sleep( 500000 );
		}
	}

	return EXIT_SUCCESS;
}
