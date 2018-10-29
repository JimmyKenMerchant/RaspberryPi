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

extern uint32 OS_IRQ_COUNT;
extern uint32 OS_FIQ_COUNT;

int32 _user_start() {

	while(True) {
		print32_debug( OS_IRQ_COUNT, 100, 200 );
		print32_debug( OS_FIQ_COUNT, 100, 212 );

		// Inner function, arm32_timestamp has an atomic procedure, preventing interrupts, IRQ and FIQ.
		// Particularly, the atomic procedure seems to prevent IRQ because FIQ has a priority rather than IRQ.
		// Memo (Not Examined): Entering modes with SVC, SMC, HVC, or Interrupts seems to keep other interrupts able,
		// even if you have marked diable bits on cpsr at previous entering. Needed to search any documents about this.
		//_sleep( 100000 );
	}

	return EXIT_SUCCESS;
}
