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

/**
 * Sound Index is made of an array of 16-bit Blocks.
 * Bit[11:0]: Length of Wave, 0 to 4095.
 *             If Bit[11:0] is 0, Long (0x1F40, Decimal 8000).
 *             If Bit[11:0] is 1, Super Long (0x3E80, Decimal 16000).
 * Bit[13:12]: Volume of Wave, 0 is Max., 1 is Bigger, 2 is Smaller, 3 is Zero (In Noise, Least).
 * Bit[15:14]: Type of Wave, 0 is Sin, 1 is Triangle, 2 is Square, 3 is Noise, ordered by less edges which cause harmonics.
 *
 * Maximum number of blocks is 65535.
 * 0 means End of Sound Index
 */

/**
 * Music Code is 16-bit Blocks. Select up to 65535 sounds indexed by Sound Index.
 * Index is 0-65534.
 * 0xFFFF(65535) means End of Music Code.
 */

#include "system32.h"
#include "system32.c"

sound_index sound[] =
{
	2<<14|3<<12|36,  // 0 Silence 
	3<<14|1<<12|0,   // 1 Long Noise
	576,             // 2   55.6hz Sin
	288,             // 3   111.1hz Sin
	144,             // 4   222.2hz Sin
	72,              // 5   444.4hz Appx. A4  Sin
	68,              // 6   470.6hz Appx. A#4 Sin
	64,              // 7   500.0hz Appx. B4  Sin
	61,              // 8   524.6hz Appx. C5  Sin
	57,              // 9   561.4hz Appx. C#5 Sin
	54,              // 10  592.6hz Appx. D5  Sin
	51,              // 11  627.5hz Appx. D#5 Sin
	48,              // 12  666.7hz Appx. E5  Sin
	46,              // 13  695.7hz Appx. F5  Sin
	43,              // 14  744.2hz Appx. F#5 Sin
	41,              // 15  780.5hz Appx. G5  Sin
	38,              // 16  842.1hz Appx. G#5 Sin
	36,              // 17  888.9hz Appx. A5  Sin
	34,              // 18  941.2hz Appx. A#5 Sin
	32,              // 19 1000.0hz Appx. B5  Sin
	30,              // 20 1066.3hz Appx. C6  Sin
	1<<14|1<<12|576, // 21 Triangle
	1<<14|1<<12|288, // 22 Triangle
	1<<14|1<<12|144, // 23 Triangle
	1<<14|1<<12|72,  // 24 Triangle
	1<<14|1<<12|36,  // 25 Triangle
	2<<14|1<<12|576, // 26 Square
	2<<14|1<<12|288, // 27 Square
	2<<14|1<<12|144, // 28 Square
	2<<14|1<<12|72,  // 29 Square
	2<<14|1<<12|36,  // 30 Square
	3<<14|1<<12|576, // 31 Noise
	3<<14|1<<12|288, // 32 Noise
	3<<14|1<<12|144, // 33 Noise
	3<<14|1<<12|72,  // 34 Noise
	3<<14|1<<12|36,  // 35 Noise
	0                // End of Index
};

music_code music1[] =
{
	 4, 3, 2, 4, 3, 2, 4, 3, 2, 4, 3, 2,
	 8,10,12,13,15,17,19,20,20,15,12, 8,
	 8, 8, 8, 8,12,12,12,12,15,15,15,15,
	20,20,20,20,20,20,20,20, 0, 0, 0, 0,
	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
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
	9,8,7,6,5,4,3,4,5,6,7,8,
	9,9,9,9,9,9,8,8,8,8,8,8,
	7,7,7,7,7,7,6,6,6,6,6,6,
	5,5,4,4,3,3,3,3,4,4,5,5,
	0xFFFF
};

music_code interrupt1[] =
{
	7,8,9,7,8,9,7,8,9,7,8,9,
	0xFFFF
};

void _user_start()
{

	_sounddecode( sound );

	while(true) {
		while( true ) {
			if ( _gpio_detect( 20 ) ) {
				_soundclear();
				break;
			}
			if ( _gpio_detect( 21 ) ) {
				_soundset( music1, snd32_musiclen( music1 ) , 0, -1 );
				break;
			}
			if ( _gpio_detect( 22 ) ) {
				_soundset( music2, snd32_musiclen( music2 ) , 0, -1 );
				break;
			}
			if ( _gpio_detect( 23 ) ) {
				_soundset( music3, snd32_musiclen( music3 ) , 0, -1 );
				break;
			}
			if ( _gpio_detect( 24 ) ) {
				break;
			}
			if ( _gpio_detect( 25 ) ) {
				break;
			}
			if ( _gpio_detect( 26 ) ) {
				break;
			}
			if ( _gpio_detect( 27 ) ) {
				_soundinterrupt( interrupt1, snd32_musiclen( interrupt1 ) , 0, 1 );
				break;
			}
		}
	}
}