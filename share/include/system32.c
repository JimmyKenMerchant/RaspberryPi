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
	asm volatile ("svc #0x01");
	return result;
}

__attribute__((noinline)) uint32 _set_doublebuffer( uint32 address_buffer_front, uint32 address_buffer_back )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x02");
	return result;
}

__attribute__((noinline)) uint32 _attach_buffer( uint32 address_buffer )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x03");
	return result;
}

__attribute__((noinline)) void _stopwatch_start()
{
	asm volatile ("svc #0x04");
}

__attribute__((noinline)) uint32 _stopwatch_end()
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x05");
	return result;
}

__attribute__((noinline)) void _sleep( uint32 u_seconds )
{
	asm volatile ("svc #0x06");
}

__attribute__((noinline)) uchar8 _random( uchar8 range_end )
{
	register uchar8 result asm("r0");
	asm volatile ("svc #0x07");
	return result;
}

__attribute__((noinline)) void _store_8( uint32 address, char8 data )
{
	asm volatile ("svc #0x08");
}

__attribute__((noinline)) char8 _load_8( uint32 address )
{
	register char8 result asm("r0");
	asm volatile ("svc #0x09");
	return result;
}

__attribute__((noinline)) void _store_16( uint32 address, int16 data )
{
	asm volatile ("svc #0x0A");
}

__attribute__((noinline)) int16 _load_16( uint32 address )
{
	register int16 result asm("r0");
	asm volatile ("svc #0x0B");
	return result;
}

__attribute__((noinline)) void _store_32( uint32 address, int32 data )
{
	asm volatile ("svc #0x0C");
}

__attribute__((noinline)) int32 _load_32( uint32 address )
{
	register int32 result asm("r0");
	asm volatile ("svc #0x0D");
	return result;
}

__attribute__((noinline)) uint32 _sounddecode( sound_index* sound )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x0E");
	return result;
}

__attribute__((noinline)) uint32 _soundset( music_code* music, uint32 length, uint32 count, int32 repeat )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x0F");
	return result;
}

__attribute__((noinline)) uint32 _soundinterrupt( music_code* music, uint32 length, uint32 count, int32 repeat )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x10");
	return result;
}

__attribute__((noinline)) uint32 _soundclear()
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x11");
	return result;
}

__attribute__((noinline)) uint32 _gpioset( gpio_sequence* gpio, uint32 length, uint32 count, int32 repeat )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x12");
	return result;
}

__attribute__((noinline)) uint32 _gpioclear( bool stay )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x13");
	return result;
}

__attribute__((noinline)) uint32 _uartinit( uint32 div_int, uint32 div_frac, uint32 line_ctl, uint32 ctl )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x14");
	return result;
}

__attribute__((noinline)) uint32 _uartsetint( uint32 int_fifo, uint32 int_mask )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x15");
	return result;
}

__attribute__((noinline)) uint32 _uartclrint()
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x16");
	return result;
}

__attribute__((noinline)) uint32 _uarttx( String address_heap, uint32 size )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x17");
	return result;
}

__attribute__((noinline)) uint32 _uartrx( String address_heap, uint32 size )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x18");
	return result;
}

__attribute__((noinline)) uint32 _uartclrrx()
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x19");
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
