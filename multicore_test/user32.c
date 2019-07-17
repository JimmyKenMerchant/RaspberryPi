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

	/* Make Container 1 */
	ObjArray container1 = (ObjArray)heap32_malloc( 0x05 );
	container1[0] = (obj)test1;
	container1[1] = fd_stack;
	container1[2] = 2;
	container1[3] = 8;
	container1[4] = 8;
	arm32_dsb();

	ARM32_CORE_HANDLE_1 = container1;
	arm32_isb();

	_set_mail( 1, BCM32_CORES_MAILBOX_CALL, 0xFFFFFFFF );

	while (ARM32_CORE_HANDLE_1) {
		arm32_dsb();
	}
	
	uint32 answer1 = container1[0];

	heap32_mfree( (obj)container1 );

print32_debug( answer1, 0, 60 );

	/* Make Container 2 */
	ObjArray container2 = (ObjArray)heap32_malloc( 0x06 );
	container2[0] = (obj)test2;
	container2[1] = fd_stack;
	container2[2] = 3;
	container2[3] = 8;
	container2[4] = 8;
	container2[5] = 4;
	arm32_dsb();

	ARM32_CORE_HANDLE_1 = container2;
	arm32_isb();

	_set_mail( 1, BCM32_CORES_MAILBOX_CALL, 0xFFFFFFFF );

	while (ARM32_CORE_HANDLE_1) {
		arm32_dsb();
	}
	
	uint32 answer2 = container2[0];

	heap32_mfree( (obj)container2 );

print32_debug( answer2, 0, 72 );

	while(True) {
	}

	heap32_mfree( fd_stack );

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
