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

void _user_start()
{
	fb32_clear_color( COLOR32_BLUE );
	while (true) {
		_sleep( 100000 );
	}
}