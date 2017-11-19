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
	36,              // 2 Sin
	72,              // 3
	144,             // 4
	288,             // 5
	576,             // 6
	1<<14|1<<12|36,  // 7 Triangle
	1<<14|1<<12|72,  // 8
	1<<14|1<<12|144, // 9
	1<<14|1<<12|288, // 10
	1<<14|1<<12|576, // 11
	2<<14|1<<12|36,  // 12 Square
	2<<14|1<<12|72,  // 13
	2<<14|1<<12|144, // 14
	2<<14|1<<12|288, // 15
	2<<14|1<<12|576, // 16
	3<<14|1<<12|36,  // 17 Noise
	3<<14|1<<12|72,  // 18
	3<<14|1<<12|144, // 19
	3<<14|1<<12|288, // 20
	3<<14|1<<12|576, // 21
	0                // End of Index
};

music_code music[] =
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

music_code interrupt[] =
{
	7,8,9,7,8,9,7,8,9,7,8,9,
	0xFF
};

void _user_start()
{

	_sounddecode( sound );

	while(true) {
		while( true ) {
			if ( _gpio_detect( 27 ) ) {
				_soundset( music, snd32_musiclen( music ) , 0, -1 );
				continue;
			}
			if ( _gpio_detect( 26 ) ) {
				_soundinterrupt( interrupt, snd32_musiclen( interrupt ) , 0, 1 );
				continue;
			}
			if ( _gpio_detect( 25 ) ) {
				_soundclear();
				continue;
			}

		}
	}
}