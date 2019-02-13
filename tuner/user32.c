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

extern bool TUNER_FIQ_FLAG_BACK;
extern obj TUNER_FIQ_BUFFER;

int32 _user_start()
{
	bool flag_flip = true;
	
	while(True) {
		if ( TUNER_FIQ_FLAG_BACK == flag_flip ) {
			flag_flip = flag_flip ^ true;
//print32_debug(flag_flip, 100, 100);
print32_debug_hexa(TUNER_FIQ_BUFFER, 0, 0, 256);

print32_debug_hexa(TUNER_FIQ_BUFFER + 16320 * 4, 0, 300, 260);
		}
		arm32_dsb();
//print32_debug(TUNER_FIQ_FLAG_BACK, 100, 112);
//print32_debug(TUNER_FIQ_BUFFER, 100, 124);
	}

	return EXIT_SUCCESS;
}
