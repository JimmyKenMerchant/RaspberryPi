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
uint32 count_receive;
uint32 count_error;
uchar8 increment;

int32 _user_start() {
	memory_space_rx = heap32_malloc( 1 );
	memory_space_tx = heap32_malloc( 1 );
	count_receive = 0;
	count_error = 0;
	increment = 0x20;
	uint32 error;

	_sleep( 100000 );

	while( True ) {
		print32_debug_hexa( OS_FIQ_RXFIFO, 200, 52, 4 );

		error = _softuartrx( memory_space_rx, 3, OS_FIQ_RXFIFO );
		if ( error & 0b1 ) { // Check If Break Error
			count_error++;
			print32_debug( count_error, 200, 64 );
			print32_debug( error, 200, 76 );
		} else if ( ! error ) { // Check If Success
			count_receive++;
			print32_debug( count_receive, 200, 88 );
		}

		print32_debug_hexa( memory_space_rx, 200, 100, 4 );
		print32_debug_hexa( memory_space_tx, 200, 112, 4 );

		_store_8( memory_space_tx, increment );
		increment++;
		_store_8( memory_space_tx + 1, increment );
		increment++;
		_store_8( memory_space_tx + 2, increment );
		increment++;
		_softuarttx( memory_space_tx, 3, OS_FIQ_TXFIFO );

		_sleep( 500000 );
	}

	return EXIT_SUCCESS;
}
