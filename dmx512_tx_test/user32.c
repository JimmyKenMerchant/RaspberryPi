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
extern uint32 OS_IRQ_TRANSMIT_ADDR;
extern uint32 OS_FIQ_COUNT;
extern uint32 OS_FIQ_RXFIFO;
extern uint32 OS_FIQ_TXFIFO;
extern uint32 OS_FIQ_BREAK;

uint32 memory_space_rx;
uint32 memory_space_tx;
uint32 count_receive;
uint32 count_error;
uint32 increment;
uchar8 turn;

int32 _user_start() {

	memory_space_rx = heap32_malloc( 1 );
	memory_space_tx = heap32_malloc( 1 );
	count_receive = 0;
	count_error = 0;
	uint32 error;
	increment = 0;
	turn = 0;

	//print32_debug( DMX32_BUFFER_FRONT, 100, 100 );
	//print32_debug( DMX32_BUFFER_BACK, 100, 112 );

	heap32_mfill( DMX32_BUFFER_FRONT, 0x23242526 );
	heap32_mfill( DMX32_BUFFER_BACK, 0x89ABCDEF );

	//print32_debug_hexa( DMX32_BUFFER_FRONT, 100, 124, 8 );
	//print32_debug_hexa( DMX32_BUFFER_BACK, 100, 136, 8 );

	while(True) {

		/* DMX512 */

		print32_debug( OS_IRQ_COUNT, 100, 52 );
		print32_debug( OS_FIQ_COUNT, 100, 64 );

		if ( _load_32( OS_IRQ_TRANSMIT_ADDR ) ) {
			_store_8( DMX32_BUFFER_BACK + increment, turn );
			increment++;
			if ( increment > 511 ) {
				increment = 0;
				turn++;
			}
			_store_32( OS_IRQ_TRANSMIT_ADDR, 0x00 );
		}

		/* Software UART */

		/*
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

		print32_debug( OS_FIQ_BREAK, 200, 136 );

		_store_8( memory_space_tx, increment );
		increment++;
		_store_8( memory_space_tx + 1, increment );
		increment++;
		_store_8( memory_space_tx + 2, increment );
		increment++;
		_softuarttx( memory_space_tx, 3, OS_FIQ_TXFIFO );

		_sleep( 500000 );
		*/
	}

	return EXIT_SUCCESS;
}
