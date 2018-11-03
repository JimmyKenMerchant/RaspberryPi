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

	print32_debug( DMX32_BUFFER_FRONT, 100, 100 );
	print32_debug( DMX32_BUFFER_BACK, 100, 112 );

	heap32_mfill( DMX32_BUFFER_FRONT, 0x23242526 );
	heap32_mfill( DMX32_BUFFER_BACK, 0x89ABCDEF );

	print32_debug_hexa( DMX32_BUFFER_FRONT, 100, 124, 8 );
	print32_debug_hexa( DMX32_BUFFER_BACK, 100, 136, 8 );

	while(True) {
		print32_debug( OS_IRQ_COUNT, 100, 200 );
		print32_debug( OS_FIQ_COUNT, 100, 212 );

		//_store_8( DMX32_BUFFER_BACK, 0xAA );

		_sleep( 1000000 );
	}

	return EXIT_SUCCESS;
}
