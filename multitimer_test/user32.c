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

extern uint32 OS_IRQ_COUNT;
extern uint32 OS_FIQ_COUNT;

int32 _user_start() {

	while(True) {
		print32_debug( OS_IRQ_COUNT, 100, 200 );
		print32_debug( OS_FIQ_COUNT, 100, 212 );

		_sleep( 1000000 );
	}

	return EXIT_SUCCESS;
}
