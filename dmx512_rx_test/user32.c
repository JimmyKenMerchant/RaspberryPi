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
volatile extern uint32 OS_FIQ_RECEIVE;
extern uint32 OS_RESET_DMX512_CHANNEL;

uchar8 dmx512_startcode;
uchar8 dmx512_value1;

int32 _user_start() {
	while( True ) {
		if ( OS_FIQ_RECEIVE ) {
			print32_debug( OS_FIQ_COUNT, 100, 212 );
			dmx512_startcode = DMX32_BUFFER_BACK[0];
			dmx512_value1 = DMX32_BUFFER_BACK[OS_RESET_DMX512_CHANNEL];
			print32_debug( dmx512_startcode, 100, 224 );
			print32_debug( dmx512_value1, 100, 236 );
			print32_debug_hexa( (obj)DMX32_BUFFER_BACK, 100, 248, 514 );
			_store_32( (uint32)&OS_FIQ_RECEIVE, 0x00 );
		}
	}
	return EXIT_SUCCESS;
}
