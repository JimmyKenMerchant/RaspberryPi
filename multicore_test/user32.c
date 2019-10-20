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

	/**
	 * Simple Test
	 */

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

	heap32_mfree( fd_stack );

	/**
	 * Test of heap32_malloc (Dynamic Partition per Core)
	 */

	ObjArray container_core1 = (ObjArray)heap32_malloc( 0x04 );
	ObjArray container_core2 = (ObjArray)heap32_malloc( 0x04 );
	ObjArray container_core3 = (ObjArray)heap32_malloc( 0x04 );

	obj fd_stack_core1 = heap32_malloc( 0xFF );
	fd_stack_core1 = fd_stack_core1 + 0xFF * 4;
	obj fd_stack_core2 = heap32_malloc( 0xFF );
	fd_stack_core2 = fd_stack_core2 + 0xFF * 4;
	obj fd_stack_core3 = heap32_malloc( 0xFF );
	fd_stack_core3 = fd_stack_core3 + 0xFF * 4;

	uint32 answer_core1;
	uint32 answer_core2;
	uint32 answer_core3;

	while(True) {
		//container_core1[0] = (obj)heap32_malloc;
		container_core1[0] = (obj)heap32_malloc_noncache;
		container_core1[1] = fd_stack_core1;
		container_core1[2] = 1;
		container_core1[3] = 256;
		//container_core2[0] = (obj)heap32_malloc;
		container_core2[0] = (obj)heap32_malloc_noncache;
		container_core2[1] = fd_stack_core2;
		container_core2[2] = 1;
		container_core2[3] = 1024;
		//container_core3[0] = (obj)heap32_malloc;
		container_core3[0] = (obj)heap32_malloc_noncache;
		container_core3[1] = fd_stack_core3;
		container_core3[2] = 1;
		container_core3[3] = 512;
		arm32_dsb();

		ARM32_CORE_HANDLE_1 = container_core1;
		ARM32_CORE_HANDLE_2 = container_core2;
		ARM32_CORE_HANDLE_3 = container_core3;
		arm32_isb();

		_set_mail( 1, BCM32_CORES_MAILBOX_CALL, 0xFFFFFFFF );
		_set_mail( 2, BCM32_CORES_MAILBOX_CALL, 0xFFFFFFFF );
		_set_mail( 3, BCM32_CORES_MAILBOX_CALL, 0xFFFFFFFF );

		while (ARM32_CORE_HANDLE_1||ARM32_CORE_HANDLE_2||ARM32_CORE_HANDLE_3) {
			arm32_dsb();
		}
		arm32_dsb();

		answer_core1 = container_core1[0];
		answer_core2 = container_core2[0];
		answer_core3 = container_core3[0];
print32_debug( answer_core1, 300, 0 );
print32_debug( answer_core2, 300, 12 );
print32_debug( answer_core3, 300, 24 );

		container_core1[0] = (obj)heap32_mfree;
		container_core1[1] = fd_stack_core1;
		container_core1[2] = 1;
		container_core1[3] = answer_core1;
		container_core2[0] = (obj)heap32_mfree;
		container_core2[1] = fd_stack_core2;
		container_core2[2] = 1;
		container_core2[3] = answer_core2;
		container_core3[0] = (obj)heap32_mfree;
		container_core3[1] = fd_stack_core3;
		container_core3[2] = 1;
		container_core3[3] = answer_core3;
		arm32_dsb();

		ARM32_CORE_HANDLE_1 = container_core1;
		ARM32_CORE_HANDLE_2 = container_core2;
		ARM32_CORE_HANDLE_3 = container_core3;
		arm32_isb();

		_set_mail( 1, BCM32_CORES_MAILBOX_CALL, 0xFFFFFFFF );
		_set_mail( 2, BCM32_CORES_MAILBOX_CALL, 0xFFFFFFFF );
		_set_mail( 3, BCM32_CORES_MAILBOX_CALL, 0xFFFFFFFF );

		while (ARM32_CORE_HANDLE_1||ARM32_CORE_HANDLE_2||ARM32_CORE_HANDLE_3) {
			arm32_dsb();
		}
		arm32_dsb();

		answer_core1 = container_core1[0];
		answer_core2 = container_core2[0];
		answer_core3 = container_core3[0];
print32_debug( answer_core1, 300, 48 );
print32_debug( answer_core2, 300, 60 );
print32_debug( answer_core3, 300, 72 );

		_sleep( 500000 );

	}

	heap32_mfree( (obj)container_core1 );
	heap32_mfree( (obj)container_core2 );
	heap32_mfree( (obj)container_core3 );
	heap32_mfree( fd_stack_core1 );
	heap32_mfree( fd_stack_core2 );
	heap32_mfree( fd_stack_core3 );

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
