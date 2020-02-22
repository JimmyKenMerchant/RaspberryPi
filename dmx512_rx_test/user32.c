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

extern uint32 OS_FIQ_COUNT;
extern uint32 OS_FIQ_RECEIVE;

int32 _user_start() {
	while( True ) {
		print32_debug( OS_FIQ_COUNT, 100, 212 );
		if ( OS_FIQ_RECEIVE ) {
			print32_debug_hexa( DMX32_BUFFER_BACK, 100, 224, 514 );
			_store_32( (uint32)&OS_FIQ_RECEIVE, 0x00 );
		}
	}
	return EXIT_SUCCESS;
}
