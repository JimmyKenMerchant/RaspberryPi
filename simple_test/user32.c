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

int32 _user_start()
{
	_gpiopullud( 2, 20 );
	
	while(True) {
	}

	return EXIT_SUCCESS;
}
