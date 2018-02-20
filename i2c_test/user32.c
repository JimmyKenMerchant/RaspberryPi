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
	uint32 memory_space = heap32_malloc( 4 );
	_store_8( memory_space, 0xAB );
	_store_8( memory_space + 1, 0xCD );
	_store_8( memory_space + 2, 0xEF );
	_store_8( memory_space + 3, 0x12 );
	uint32 chip_select = 0b000;
	uint32 address_memory = 0x00;
	uint32 length = 4;

print32_debug_hexa( memory_space, 200, 200, length );

	_romwrite_i2c( memory_space, chip_select, address_memory, length );
	_romread_i2c( memory_space, chip_select, address_memory + 1, length );

print32_debug_hexa( memory_space, 200, 212, length );
	
	while(True) {
	}

	return EXIT_SUCCESS;
}
