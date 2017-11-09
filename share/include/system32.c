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

__attribute__((noinline)) uint32 _set_doublebuffer( int32* buffer_front, int32* buffer_back )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x2");
	return result;
}

__attribute__((noinline)) uint32 _attach_buffer( int32* buffer )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x3");
	return result;
}

__attribute__((noinline)) void _sleep( uint32 u_seconds )
{
	asm volatile ("svc #0x4");
}

__attribute__((noinline)) uchar8 _random( uchar8 range_start, uchar8 range_end )
{
	register uchar8 result asm("r0");
	asm volatile ("svc #0x5");
	return result;
}

__attribute__((noinline)) void _store_32( int32* address, int32 data )
{
	asm volatile ("svc #0x6");
}

__attribute__((noinline)) int32 _load_32( int32* address )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x7");
	return result;
}

__attribute__((noinline)) void _soundtest()
{
	asm volatile ("svc #0x8");
}

__attribute__((noinline)) int32 _soundset( int16* music_code, uint32 length, uint32 count, int32 repeat )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x9");
	return result;
}
