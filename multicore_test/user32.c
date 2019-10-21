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

float32 array_float1[] = { 1.0f, 2.0f, 3.0f };
float32 array_float2[] = { 4.0f, 5.0f, 6.0f };
float32 array_float3[] = { 7.0f, 8.0f, 9.0f };

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

print32_debug( answer1, 0, 96 );

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

print32_debug( answer2, 0, 108 );

	heap32_mfree( fd_stack );

	/**
	 * Test of Functions
	 */

	ObjArray container_core1 = (ObjArray)heap32_malloc( 8 );
	ObjArray container_core2 = (ObjArray)heap32_malloc( 8 );
	ObjArray container_core3 = (ObjArray)heap32_malloc( 8 );

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
		/* Allocate Memory */

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

		answer_core1 = container_core1[0];
		answer_core2 = container_core2[0];
		answer_core3 = container_core3[0];
print32_debug( answer_core1, 0, 132 );
print32_debug( answer_core2, 0, 144 );
print32_debug( answer_core3, 0, 156 );

		/* Free Memory */

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

		answer_core1 = container_core1[0];
		answer_core2 = container_core2[0];
		answer_core3 = container_core3[0];
print32_debug( answer_core1, 0, 180 );
print32_debug( answer_core2, 0, 192 );
print32_debug( answer_core3, 0, 204 );

		/* Get Matrix */

		container_core1[0] = (obj)mtx32_translate3d;
		container_core1[1] = fd_stack_core1;
		container_core1[2] = 1;
		container_core1[3] = (obj)array_float1;
		container_core2[0] = (obj)mtx32_translate3d;
		container_core2[1] = fd_stack_core2;
		container_core2[2] = 1;
		container_core2[3] = (obj)array_float2;
		container_core3[0] = (obj)mtx32_translate3d;
		container_core3[1] = fd_stack_core3;
		container_core3[2] = 1;
		container_core3[3] = (obj)array_float3;
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

		answer_core1 = container_core1[0];
		answer_core2 = container_core2[0];
		answer_core3 = container_core3[0];
print32_debug_hexa( answer_core1, 0, 228, 64 );
print32_debug_hexa( answer_core2, 0, 240, 64 );
print32_debug_hexa( answer_core3, 0, 252, 64 );

		/* Free Matrix */

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

		answer_core1 = container_core1[0];
		answer_core2 = container_core2[0];
		answer_core3 = container_core3[0];
print32_debug( answer_core1, 0, 276 );
print32_debug( answer_core2, 0, 288 );
print32_debug( answer_core3, 0, 300 );

		/* Dot Product */

		container_core1[0] = (obj)mtx32_dotproduct;
		container_core1[1] = fd_stack_core1;
		container_core1[2] = 3;
		container_core1[3] = (obj)array_float1;
		container_core1[4] = (obj)array_float2;
		container_core1[5] = 3;

		container_core2[0] = (obj)mtx32_dotproduct;
		container_core2[1] = fd_stack_core2;
		container_core2[2] = 3;
		container_core2[3] = (obj)array_float2;
		container_core2[4] = (obj)array_float3;
		container_core2[5] = 3;

		container_core3[0] = (obj)mtx32_dotproduct;
		container_core3[1] = fd_stack_core3;
		container_core3[2] = 3;
		container_core3[3] = (obj)array_float1;
		container_core3[4] = (obj)array_float3;
		container_core3[5] = 3;

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

		answer_core1 = container_core1[0];
		answer_core2 = container_core2[0];
		answer_core3 = container_core3[0];
print32_debug( answer_core1, 0, 324 );
print32_debug( answer_core2, 0, 336 );
print32_debug( answer_core3, 0, 348 );

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
