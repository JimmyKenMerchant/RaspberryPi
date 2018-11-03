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
extern obj OS_IRQ_DMX512RX;

int32 _user_start() {
	//uint32 error;

	while(True) {
		print32_debug( OS_IRQ_COUNT, 100, 200 );
		print32_debug( OS_FIQ_COUNT, 100, 212 );
		print32_debug_hexa( OS_IRQ_DMX512RX, 100, 224, 513 );

		//error = _uartrx( OS_IRQ_DMX512RX, 1 );
		//print32_debug( error, 0, 200 );

		_sleep( 1000000 );
	}

	return EXIT_SUCCESS;
}
