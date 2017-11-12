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

int16 music_code[] =
{
	72, 72, 72, 72, 72, 72,
	288, 288, 288, 288, 288, 288,
	144, 144, 144, 144, 144, 144,
	1<<14|0<<12|144, 1<<14|0<<12|144, 1<<14|0<<12|144, 1<<14|0<<12|144, 1<<14|0<<12|144, 1<<14|0<<12|144,
	2<<14|288, 2<<14|288, 2<<14|288, 2<<14|288, 72, 72,
	36, 36, 36, 36, 36, 36
};

void _user_start()
{

	_sleep( 1000000 );

	_soundset( music_code, 36 , 0, 3 );

	while(1) {

		_sleep( 1000000 );
	}
}