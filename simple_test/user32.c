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
	_gpiomode( 20, _GPIOMODE_IN );
	//_gpiomode( 21, _GPIOMODE_OUT ); // Already Set in vector32.s

	while( True ) {
		// If GPIO 20 Detects Voltage, GPIO 21 Keeps Lighting
		if ( _gpio_in( 20 ) ) _gpiotoggle( 21, _GPIOTOGGLE_HIGH );

		_sleep( 1000 ); // Wait for 1000 Microseconds
	}

	return EXIT_SUCCESS;
}
