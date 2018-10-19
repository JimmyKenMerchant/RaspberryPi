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

extern uint32 OS_FIQ_RXFIFO;
extern uint32 OS_FIQ_TXFIFO;

uint32 memory_space_rx;
uint32 memory_space_tx;
uchar8 increment;

int32 _user_start() {
	memory_space_rx = heap32_malloc( 1 );
	memory_space_tx = heap32_malloc( 1 );
	increment = 0x20;

	_sleep( 100000 );

	while( True ) {
print32_debug_hexa( OS_FIQ_RXFIFO, 200, 88, 4 );

		_softuartrx( memory_space_rx, 1, OS_FIQ_RXFIFO );

print32_debug_hexa( memory_space_rx, 200, 100, 4 );
print32_debug_hexa( memory_space_tx, 200, 112, 4 );

		_store_8( memory_space_tx, increment );
		_softuarttx( memory_space_tx, 1, OS_FIQ_TXFIFO );
		increment++;

		_sleep( 500000 );
	}

	return EXIT_SUCCESS;
}
