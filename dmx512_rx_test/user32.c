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

#define DMX512_LENGTH 513

extern uint32 OS_FIQ_COUNT;
volatile extern uint32 OS_FIQ_RECEIVE;
extern uint32 OS_RESET_DMX512_CHANNEL;

uchar8 dmx512_startcode;
uchar8 dmx512_value1;
uchar8 dmx512_value2;

pwm_sequence pwm0[] =
{
	1<<31|0,
	PWM32_END
};

pwm_sequence pwm1[] =
{
	1<<31|0,
	PWM32_END
};

int32 _user_start() {
	/* Initialization of Global Variables */
	dmx512_value1 = 0;
	dmx512_value2 = 0;

	while( True ) {
		if ( OS_FIQ_RECEIVE ) {
			_store_32( (uint32)&OS_FIQ_RECEIVE, 0x00 );
			if ( dmx512_value1 != DMX32_BUFFER_BACK[OS_RESET_DMX512_CHANNEL] ) {
				dmx512_value1 = DMX32_BUFFER_BACK[OS_RESET_DMX512_CHANNEL];
				pwm0[0] = 1<<31|dmx512_value1;
				_pwmselect( 0 );
				_pwmset( pwm0, 1, 0, 1 );
				_pwmplay( False, False );
			}
			if ( dmx512_value2 != DMX32_BUFFER_BACK[OS_RESET_DMX512_CHANNEL + 1] ) {
				dmx512_value2 = DMX32_BUFFER_BACK[OS_RESET_DMX512_CHANNEL + 1];
				pwm1[0] = 1<<31|dmx512_value2;
				_pwmselect( 1 );
				_pwmset( pwm1, 1, 0, 1 );
				_pwmplay( False, False );
			}
#ifdef __DEBUG
			dmx512_startcode = DMX32_BUFFER_BACK[0];
			print32_debug( OS_RESET_DMX512_CHANNEL, 100, 188 );
			print32_debug( OS_FIQ_COUNT, 100, 200 );
			print32_debug( dmx512_startcode, 100, 212 );
			print32_debug( dmx512_value1, 100, 224 );
			print32_debug( dmx512_value2, 100, 236 );
			print32_debug_hexa( (obj)DMX32_BUFFER_BACK, 100, 248, 514 );
#endif
		}
	}
	return EXIT_SUCCESS;
}
