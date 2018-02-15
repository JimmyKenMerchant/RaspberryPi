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

uint32 usb_channel; // 0-15
uint32 error;
uint32 response;
uint32 ticket_hid;

void _user_start()
{
	usb_channel = 0;
	_otg_host_reset_bcm();

	uint32 ticket_hub = _hub_activate( usb_channel, 0 );
	arm32_dsb();

print32_debug( ticket_hub, 500, 230 );

	if ( ticket_hub == -2 ) {
		ticket_hid = 0; // Direct Connection
	} else if ( ticket_hub > 0 ) {
		ticket_hid = _hub_search_device( usb_channel, ticket_hub );
#ifdef __B
		arm32_dsb();
		ticket_hid = _hub_search_device( usb_channel, ticket_hub );
#endif
	} else {
		return;
	}
	arm32_dsb();

	if ( ticket_hid <= 0 ) return;
print32_debug( ticket_hid, 500, 242 );
	_sleep( 800000 ); // Hub Port is Powerd On, So Wait for Activation of Device

	ticket_hid = _hid_activate( usb_channel, 1, ticket_hid );

	if ( ticket_hid > 0 ) {
		while(True) {
			response = _keyboard_get( usb_channel, 1, ticket_hid );
print32_debug( response, 500, 254 );
			_sleep( 100000 );
		}
	} else {
		return;
	}
}

