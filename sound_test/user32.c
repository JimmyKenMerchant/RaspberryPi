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
 * Maximum number of blocks is 4096.
 * 0 means End of Sound Index
 */

/**
 * Music Code is 16-bit Blocks. Select up to 4096 sounds indexed by Sound Index.
 * Index is 0-4096.
 * 0xFFFF(65535) means End of Music Code.
 */

#include "system32.h"
#include "system32.c"

sound_index sound[] =
{
	144,             // 0   222.2hz Appx. A3  Sin
	136,             // 1   235.3hz Appx. A#3 Sin
	129,             // 2   248.1hz Appx. B3  Sin
	121,             // 3   264.5hz Appx. C4  Sin
	114,             // 4   280.7hz Appx. C#4 Sin
	108,             // 5   296.3hz Appx. D4  Sin
	102,             // 6   313.7hz Appx. D#4 Sin
	96,              // 7   333.3hz Appx. E4  Sin
	91,              // 8   351.6hz Appx. F4  Sin
	86,              // 9   372.1hz Appx. F#4 Sin
	81,              // 10  395.1hz Appx. G4  Sin
	76,              // 11  421.1hz Appx. G#4 Sin
	72,              // 12  444.4hz Appx. A4  Sin
	68,              // 13  470.6hz Appx. A#4 Sin
	64,              // 14  500.0hz Appx. B4  Sin
	61,              // 15  524.6hz Appx. C5  Sin
	57,              // 16  561.4hz Appx. C#5 Sin
	54,              // 17  592.6hz Appx. D5  Sin
	51,              // 18  627.5hz Appx. D#5 Sin
	48,              // 19  666.7hz Appx. E5  Sin
	46,              // 20  695.7hz Appx. F5  Sin
	43,              // 21  744.2hz Appx. F#5 Sin
	41,              // 22  780.5hz Appx. G5  Sin
	38,              // 23  842.1hz Appx. G#5 Sin
	36,              // 24  888.9hz Appx. A5  Sin
	34,              // 25  941.2hz Appx. A#5 Sin
	32,              // 26 1000.0hz Appx. B5  Sin
	30,              // 27 1066.3hz Appx. C6  Sin
	1<<14|1<<12|576, // 28 Triangle
	1<<14|1<<12|288, // 29 Triangle
	1<<14|1<<12|144, // 30 Triangle
	1<<14|1<<12|72,  // 31 Triangle
	1<<14|1<<12|36,  // 32 Triangle
	2<<14|1<<12|576, // 33 Square
	2<<14|1<<12|288, // 34 Square
	2<<14|1<<12|144, // 35 Square
	2<<14|1<<12|72,  // 36 Square
	2<<14|1<<12|36,  // 37 Square
	3<<14|1<<12|576, // 38 Noise
	3<<14|1<<12|288, // 39 Noise
	3<<14|1<<12|144, // 40 Noise
	3<<14|1<<12|72,  // 41 Noise
	3<<14|1<<12|36,  // 42 Noise
	2<<14|3<<12|36,  // 43 Silence 
	3<<14|1<<12|0,   // 44 Long Noise
	0                // End of Index
};

music_code music1[] =
{
	 3, 5, 7, 8,10,12,14,15,10,10,10,10,
	43,43,10, 7, 3,10, 7, 3, 8,10,12,14,
	15,15,15,15,10,10,10,10, 7, 7, 7, 7,
	 3, 3, 3, 3, 3, 3, 3, 3,43,43,43,43,
	43,43,43,43,43,43,43,43,43,43,43,43,
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

	String str_music1 = "Music 1\0";
	String str_music2 = "Music 2\0";
	String str_music3 = "Music 3\0";

	_sounddecode( sound );

	while(true) {
		while( true ) {
			if ( _gpio_detect( 20 ) ) {
				_soundclear();
				break;
			}
			if ( _gpio_detect( 21 ) ) {
				_soundset( music1, snd32_musiclen( music1 ) , 0, -1 );
				print32_string( str_music1, 300, 300, COLOR32_BLUE, COLOR32_WHITE, print32_strlen( str_music1 ), 8, 12, FONT_MONO_12PX_ASCII );
				break;
			}
			if ( _gpio_detect( 22 ) ) {
				_soundset( music2, snd32_musiclen( music2 ) , 0, -1 );
				print32_string( str_music2, 300, 300, COLOR32_BLUE, COLOR32_WHITE, print32_strlen( str_music2 ), 8, 12, FONT_MONO_12PX_ASCII );
				break;
			}
			if ( _gpio_detect( 23 ) ) {
				_soundset( music3, snd32_musiclen( music3 ) , 0, -1 );
				print32_string( str_music3, 300, 300, COLOR32_BLUE, COLOR32_WHITE, print32_strlen( str_music3 ), 8, 12, FONT_MONO_12PX_ASCII );
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