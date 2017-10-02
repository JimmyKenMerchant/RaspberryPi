/**
 * user32.c
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

#include "system32.h"

void _user_start()
{
	
	while(1) {
		system32_sleep( 2000000 );
	}
}