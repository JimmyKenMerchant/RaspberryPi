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

uint32 test1( uint32 var_a, uint32 var_b );

uint32 test2( uint32 var_a, uint32 var_b, uint32 var_c );

int32 _user_start() {

	/* Full Descending Stack */
	obj fd_stack = heap32_malloc( 0xFF );
	fd_stack = fd_stack + 0xFF * 4;

	/* Make Container */
	ObjArray container = (ObjArray)heap32_malloc( 0x05 );
	container[0] = (obj)test1;
	container[1] = fd_stack;
	container[2] = 2;
	container[3] = 8;
	container[4] = 8;
	arm32_dsb();

	ARM32_CORE_HANDLE_1 = container;
	arm32_isb();

	while (ARM32_CORE_HANDLE_1) {
		arm32_dsb();
	}
	
	uint32 answer1 = container[0];

print32_debug( answer1, 0, 60 );

	while(True) {
	}

	return EXIT_SUCCESS;
}

uint32 test1( uint32 var_a, uint32 var_b ) {
	uint32 var_z = var_a * var_b;
	return var_z;
}

uint32 test2( uint32 var_a, uint32 var_b, uint32 var_c ) {
	uint32 var_z = var_a * var_b * var_c;
	return var_z;
}
