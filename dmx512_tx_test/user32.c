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

/**
 * Global Variables and Constants
 * to Prevent Incorrect Compilation in optimization,
 * Variables (except these which have only one value) used over the iteration of the loop are defined as global variables.
 */

#define PARALLEL_MASK                   0b11111 // 5-bit
#define PARALLEL_OUTSTANDING_FLAG       0x80000000 // MSB
#define GPIO_PARALLEL_LSB               22
#define GPIO_CLOCKIN_PARALLEL           27
#define GPIO_BUSY_TOGGLE                15
#define GPIO_EOP_TOGGLE                 16 // End of Packet
#define DMX512_LENGTH                   513

extern uint32 OS_FIQ_COUNT;
extern uint32 OS_FIQ_TRANSMIT;
extern uint32 OS_FIQ_SWAP;
extern uint32 OS_FIQ_START;
extern uint32 OS_FIQ_REPEAT;

uint32 count_receive;
uint32 count_error;
uint32 increment;
uchar8 turn;
uchar8 data_mode;
uint16 index_slot;
uint16 buffer_data;
uchar8 index_slot_position; // 0 = Bit[3:0], 1 = Bit[7:0], 2 = Bit[8]
bool buffer_data_upper_flag;

int32 _user_start() {
	/* Local Variables */
	uint32 detect_parallel = 0;
	obj front_buffer_swap;
	obj back_buffer_swap;

	/* Initialization of Global Variables */
	count_receive = 0;
	count_error = 0;
	//uint32 error;
	increment = 0;
	turn = 0;
	data_mode = 1; // Slot Index Mode
	index_slot = 0;
	buffer_data = 0;
	index_slot_position = 0;
	buffer_data_upper_flag = false;

	//print32_debug( DMX32_BUFFER_FRONT, 100, 100 );
	//print32_debug( DMX32_BUFFER_BACK, 100, 112 );
	heap32_mfill( (obj)DMX32_BUFFER_FRONT, 0x23242526 );
	heap32_mfill( (obj)DMX32_BUFFER_BACK, 0x89ABCDEF );
	//print32_debug_hexa( DMX32_BUFFER_FRONT, 100, 124, 8 );
	//print32_debug_hexa( DMX32_BUFFER_BACK, 100, 136, 8 );

	while( True ) {
		/* DMX512 */
		/*
		print32_debug( OS_FIQ_COUNT, 100, 52 );
		if ( OS_FIQ_TRANSMIT ) {
			_store_8( (obj)DMX32_BUFFER_BACK + increment, turn );
			increment++;
			if ( increment > 512 ) {
				increment = 0;
				turn++;
			}
			_store_32( (uint32)&OS_FIQ_TRANSMIT, 0x00 );
		}
		*/

		if ( OS_FIQ_TRANSMIT ) {
			_gpiotoggle( GPIO_EOP_TOGGLE, _GPIOTOGGLE_SWAP );
			_store_32( (uint32)&OS_FIQ_TRANSMIT, 0x00 );
		}

		/* Detect Falling Edge of GPIO */
		if ( _gpio_detect( GPIO_CLOCKIN_PARALLEL ) ) {
			// Load Pin Level and Set Outstanding Flag
			detect_parallel = ((_load_32( _gpio_base|_gpio_gplev0 ) >> GPIO_PARALLEL_LSB ) & PARALLEL_MASK) | PARALLEL_OUTSTANDING_FLAG;
		}

		/* Command Execution */
		if ( detect_parallel ) { // If Any Non Zero Including Outstanding Flag
			_gpiotoggle( GPIO_BUSY_TOGGLE, _GPIOTOGGLE_SWAP ); // Busy Toggle
			detect_parallel &= 0x1F; // 0-31
			if ( detect_parallel & 0b10000 ) { // Command
				if ( detect_parallel == 26 ) { // Start Tx
					_store_32( (uint32)&OS_FIQ_START, 0x01 );
				} else if ( detect_parallel == 27 ) { // Set Repeat Tx
					_store_32( (uint32)&OS_FIQ_REPEAT, 0x01 );
				} else if ( detect_parallel == 28 ) { // Clear Repeat Tx, Pause after End of Packet (Default)
					_store_32( (uint32)&OS_FIQ_REPEAT, 0x00 );
				} else if ( detect_parallel == 29 ) { // Swap FRONT/BACK Buffer
					front_buffer_swap = (obj)DMX32_BUFFER_FRONT;
					back_buffer_swap = (obj)DMX32_BUFFER_BACK;
					arm32_dsb();
					_store_32( (uint32)&DMX32_BUFFER_FRONT, back_buffer_swap );
					_store_32( (uint32)&DMX32_BUFFER_BACK, front_buffer_swap );
				} else if ( detect_parallel == 30 ) { // Tx Send FRONT Buffer (Default)
					_store_32( (uint32)&OS_FIQ_SWAP, 0x00 );
				} else if ( detect_parallel == 31 ) { // Tx Send FRONT and Swap FRONT/BACK Buffer on End of Packet
					_store_32( (uint32)&OS_FIQ_SWAP, 0x01 );
				} else if ( detect_parallel != 16 ) { // 17-19 Select Data Mode (17: Slot Index [Default], 18: Slot Value, 19: Slot Value Sequentially)
					data_mode = detect_parallel & 0b1111;
				} // 16: Reset Data Position to LSB (All Commands Reset Data Position)
				index_slot_position = 0;
				buffer_data_upper_flag = false;
			} else { // Data
				if ( data_mode == 1 ) { // Slot Index
					if ( index_slot_position == 0 ) {
						index_slot = (index_slot & 0x1F0) | (detect_parallel & 0b1111);
						index_slot_position = 1;
					} else if ( index_slot_position == 1 ) {
						index_slot = (index_slot & 0x10F) | ((detect_parallel & 0b1111) << 4 );
						index_slot_position = 2;
					} else if ( index_slot_position == 2 ) {
						index_slot = (index_slot & 0x0FF) | ((detect_parallel & 0b1) << 8 );
						index_slot_position = 0;
					}
				} else if ( data_mode > 1 ) { // Slot Value
					if ( ! buffer_data_upper_flag ) {
						buffer_data = (buffer_data & 0xF0) | (detect_parallel & 0b1111);
						buffer_data_upper_flag = true;
					} else {
						buffer_data = (buffer_data & 0x0F) | ((detect_parallel & 0b1111) << 4 );
						buffer_data_upper_flag = false;
						DMX32_BUFFER_BACK[index_slot] = buffer_data;
						if ( data_mode == 3 ) { // Sequentially
							index_slot++;
							if ( index_slot >= DMX512_LENGTH ) index_slot = 0;
						}
					}
				}
			}
			detect_parallel = 0;
			arm32_dsb();
		}
	}
	return EXIT_SUCCESS;
}
