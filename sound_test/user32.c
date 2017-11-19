/**
 * user32.c
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * Sound Index is made of an array of 16-bit Blocks.
 * Bit[11:0]: Length of Wave, 0 to 4095.
 *             If Bit[11:0] is 0, Long (0x1F40, Decimal 8000).
 *             If Bit[11:0] is 1, Super Long (0x3E80, Decimal 16000).
 * Bit[13:12]: Volume of Wave, 0 is Max., 1 is Bigger, 2 is Smaller, 3 is Zero (In Noise, Least).
 * Bit[15:14]: Type of Wave, 0 is Sin, 1 is Triangle, 2 is Square, 3 is Noise, ordered by less edges which cause harmonics.
 *
 * Maximum number of blocks is 255.
 * 0 means End of Sound Index
 */

/**
 * Music Code is 8-bit Blocks. Select 254 sounds indexed by Sound Index.
 * Index is 0-254.
 * 0xFF(255) means End of Music Code.
 */

#include "system32.h"
#include "system32.c"

sound_index sound[] =
{
	2<<14|3<<12|36,  // 0 Silence 
	3<<14|1<<12|0,   // 1 Long Noise
	36,              // 2  888.9hz Appx. A5 Sin
	51,              // 3  627.5hz Appx. D#5
	55,              // 4  581.8hz Appx. D5
	58,              // 5  551.7hz Appx. C#5
	61,              // 6  524.6hz Appx. C5
	65,              // 7  492.3hz Appx. B4
	68,              // 8  470.6hz Appx. A#4
	72,              // 9  444.4hz Appx. A4
	144,             // 10 222.2hz
	288,             // 11
	576,             // 12
	1<<14|1<<12|36,  // 13 Triangle
	1<<14|1<<12|72,  // 14
	1<<14|1<<12|144, // 15
	1<<14|1<<12|288, // 16
	1<<14|1<<12|576, // 17
	2<<14|1<<12|36,  // 18 Square
	2<<14|1<<12|72,  // 19
	2<<14|1<<12|144, // 20
	2<<14|1<<12|288, // 21
	2<<14|1<<12|576, // 22
	3<<14|1<<12|36,  // 23 Noise
	3<<14|1<<12|72,  // 24
	3<<14|1<<12|144, // 25
	3<<14|1<<12|288, // 26
	3<<14|1<<12|576, // 27
	0                // End of Index
};

music_code music1[] =
{
	4,3,2,4,3,2,4,3,2,4,3,2,
	6,5,4,6,5,4,6,5,4,6,5,4,
	9,9,9,9,9,9,4,4,4,4,4,4,
	10,10,10,10,10,10,5,5,5,5,5,5,
	1,1,1,1,1,1,1,1,1,1,1,1,
	0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,
	0xFF
};

music_code music2[] =
{
	9,8,7,6,5,4,3,4,5,6,7,8,
	9,9,9,9,9,9,8,8,8,8,8,8,
	7,7,7,7,7,7,6,6,6,6,6,6,
	5,5,4,4,3,3,3,3,4,4,5,5,
	0xFF
};

music_code music3[] =
{
	9,8,7,6,5,4,3,4,5,6,7,8,
	9,9,9,9,9,9,8,8,8,8,8,8,
	7,7,7,7,7,7,6,6,6,6,6,6,
	5,5,4,4,3,3,3,3,4,4,5,5,
	0xFF
};

music_code interrupt1[] =
{
	7,8,9,7,8,9,7,8,9,7,8,9,
	0xFF
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