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
	_gpiopull( 20, _GPIOPULL_UP );
	_gpioevent( 20, _GPIOEVENT_RISING, TRUE );

	while(True) {
		//if ( _gpio_detect( 20 ) ) _gpiotoggle( 21, _GPIOTOGGLE_SWAP );
		if ( _gpio_in( 20 ) ) _gpiotoggle( 21, _GPIOTOGGLE_SWAP );

		_sleep(1000);
	}

	return EXIT_SUCCESS;
}
