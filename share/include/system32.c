/**
 * system32.c
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * In SVC mode, Regular Registers Stay, but SP, LR, and SPSR are Banked.
 * So, as SVCm, you need to have only r0-r3 registers to execute functions.
 */
__attribute__((noinline)) uint32 _example_svc_0( int32 a, int32 b, int32 c, int32 d )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0");
	return result;
}

__attribute__((noinline)) uint32 _flush_doublebuffer()
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x1");
	return result;
}

__attribute__((noinline)) uint32 _set_doublebuffer( uint32 address_buffer_front, uint32 address_buffer_back )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x2");
	return result;
}

__attribute__((noinline)) uint32 _attach_buffer( uint32 address_buffer )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x3");
	return result;
}

__attribute__((noinline)) void _sleep( uint32 u_seconds )
{
	asm volatile ("svc #0x4");
}

__attribute__((noinline)) uchar8 _random( uchar8 range_end )
{
	register uchar8 result asm("r0");
	asm volatile ("svc #0x5");
	return result;
}

__attribute__((noinline)) void _store_32( uint32 address, int32 data )
{
	asm volatile ("svc #0x6");
}

__attribute__((noinline)) int32 _load_32( uint32 address )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x7");
	return result;
}

__attribute__((noinline)) uint32 _sounddecode( sound_index* sound )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x8");
	return result;
}

__attribute__((noinline)) uint32 _soundset( music_code* music, uint32 length, uint32 count, int32 repeat )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x9");
	return result;
}

__attribute__((noinline)) uint32 _soundclear()
{
	register uint32 result asm("r0");
	asm volatile ("svc #0xA");
	return result;
}

__attribute__((noinline)) uint32 _gpioset( gpio_sequence* gpio, uint32 length, uint32 count, int32 repeat )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0xB");
	return result;
}

__attribute__((noinline)) uint32 _gpioclear( bool stay )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0xC");
	return result;
}

bool _gpio_detect( uchar8 gpio_number )
{
	int32 value = _load_32( _gpio_base|_gpio_gpeds0 );
	if (value & 1 << gpio_number ) {
		value = 1 << gpio_number;
		_store_32( _gpio_base|_gpio_gpeds0, value );
		return true;
	} else {
		return false;
	}
}
