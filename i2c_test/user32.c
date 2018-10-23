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
	uint32 memory_space = heap32_malloc( 32 );
	_store_8( memory_space, 0xC1 );
	_store_8( memory_space + 1, 0xC2 );
	_store_8( memory_space + 2, 0xC3 );
	_store_8( memory_space + 3, 0xC4 );
	_store_8( memory_space + 4, 0xC5 );
	_store_8( memory_space + 5, 0xC6 );
	_store_8( memory_space + 6, 0xC7 );
	uint32 chip_select = 0b000;
	uint32 address_memory = 0x00;
	uint32 length = 128;
	uint32 error = 0;

	//error = _romwrite_i2c( memory_space, chip_select, address_memory, length );
print32_debug( error, 200, 0 );
print32_debug_hexa( memory_space, 200, 12, length );

	error = _romread_i2c( memory_space, chip_select, address_memory, length );
print32_debug( error, 200, 200 );
print32_debug_hexa( memory_space, 200, 212, length );
	
	while(True) {
	}

	return EXIT_SUCCESS;
}
