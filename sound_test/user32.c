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
	72,
	288,
	144,
	1<<14|0<<12|144,
	36,
	0
};

music_code music[] =
{
	1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,
	3,4,5,3,4,5,3,4,5,3,4,5,3,4,5,
	2,3,4,2,3,4,2,3,4,2,3,4,2,3,4,
	0
};

void _user_start()
{

	_sounddecode( sound );

	_soundset( music, snd32_musiclen( music ) , 0, -1 );

	while(true) {

		_sleep( 1000000 );
	}
}