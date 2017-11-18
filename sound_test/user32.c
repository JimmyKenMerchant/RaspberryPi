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


sound_index sound[] =
{
	1<<14|3<<12|36,  // 0 Silence 
	3<<14|1<<12|2,   // 1 Long Noise
	36,              // 2 Triangle
	72,              // 3
	144,             // 4
	288,             // 5
	576,             // 6
	1<<14|1<<12|36,  // 7 Square
	1<<14|1<<12|72,  // 8
	1<<14|1<<12|144, // 9
	1<<14|1<<12|288, // 10
	1<<14|1<<12|576, // 11
	3<<14|1<<12|36,  // 12 Noise
	3<<14|1<<12|72,  // 13
	3<<14|1<<12|144, // 14
	3<<14|1<<12|288, // 15
	3<<14|1<<12|576, // 16
	0                // End of Index
};

music_code music[] =
{
	4,3,2,4,3,2,4,3,2,4,3,2,
	6,5,4,6,5,4,6,5,4,6,5,4,
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
		_soundset( music, snd32_musiclen( music ) , 0, -1 );
		while( ! _gpio_detect( 27 ) ) {
			if ( _gpio_detect( 26 ) ) _soundinterrupt( interrupt, snd32_musiclen( interrupt ) , 0, 1 );
		}
		_soundclear();
		_sleep( 1000 );
	}
}