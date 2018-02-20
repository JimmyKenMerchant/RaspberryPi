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
	_store_8( memory_space, 0xDC );
	_store_8( memory_space + 1, 0xEB );
	_store_8( memory_space + 2, 0xFA );
	_store_8( memory_space + 3, 0xCD );
	uint32 chip_select = 0b000;
	uint32 address_memory = 0x00;
	uint32 length = 128;

print32_debug_hexa( memory_space, 200, 200, length );

	//_romwrite_i2c( memory_space, chip_select, address_memory, length );
	_romread_i2c( memory_space, chip_select, address_memory, length );

print32_debug_hexa( memory_space, 200, 212, length );
	
	while(True) {
	}

	return EXIT_SUCCESS;
}
