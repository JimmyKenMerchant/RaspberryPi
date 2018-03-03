/**
 * sound32.h
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * Sound Index is made of an array of 16-bit Blocks.
 * Bit[11:0]: Length of Wave, 0 to 4095.
 *             If Bit[11:0] is 0, Long (0x1F40, Decimal 8000).
 *             If Bit[11:0] is 1, Super Long (0x3E80, Decimal 16000).
 * Bit[13:12]: Volume of Wave, 0 is Max., 1 is Bigger, 2 is Smaller, 3 is Zero (In Noise, Least).
 * Bit[15:14]: Type of Wave, 0 is Sin, 1 is Triangle, 2 is Square, 3 is Noise, ordered by less edges which cause harmonics.
 *
 * Maximum number of blocks is 4096.
 * 0 means End of Sound Index
 */

/**
 * Music Code is 16-bit Blocks. Select up to 4096 sounds indexed by Sound Index.
 * Index is 0-4096.
 * 0xFFFF(65535) means End of Music Code.
 */

sound_index sound[] =
{
	0<<14|0<<12|581, // 0x00  55.08hz Appx. A1  Sin
	0<<14|0<<12|548, // 0x01  58.39hz Appx. A#1 Sin
	0<<14|0<<12|518, // 0x02  61.78hz Appx. B1  Sin
	0<<14|0<<12|489, // 0x03  65.44hz Appx. C2  Sin
	0<<14|0<<12|461, // 0x04  69.41hz Appx. C#2 Sin
	0<<14|0<<12|435, // 0x05  73.56hz Appx. D2  Sin
	0<<14|0<<12|411, // 0x06  77.86hz Appx. D#2 Sin
	0<<14|0<<12|388, // 0x07  82.47hz Appx. E2  Sin
	0<<14|0<<12|366, // 0x08  87.43hz Appx. F2  Sin
	0<<14|0<<12|345, // 0x09  92.75hz Appx. F#2 Sin
	0<<14|0<<12|326, // 0x0A  98.16hz Appx. G2  Sin
	0<<14|0<<12|308, // 0x0B  103.9hz Appx. G#2 Sin
	0<<14|0<<12|288, // 0x0C  111.1hz Appx. A2  Sin
	0<<14|0<<12|272, // 0x0D  117.6hz Appx. A#2 Sin
	0<<14|0<<12|257, // 0x0E  124.5hz Appx. B2  Sin
	0<<14|0<<12|242, // 0x0F  132.2hz Appx. C3  Sin
	0<<14|0<<12|229, // 0x10  139.7hz Appx. C#3 Sin
	0<<14|0<<12|216, // 0x11  148.1hz Appx. D3  Sin
	0<<14|0<<12|204, // 0x12  156.9hz Appx. D#3 Sin
	0<<14|0<<12|192, // 0x13  166.7hz Appx. E3  Sin
	0<<14|0<<12|181, // 0x14  176.8hz Appx. F3  Sin
	0<<14|0<<12|171, // 0x15  187.1hz Appx. F#3 Sin
	0<<14|0<<12|162, // 0x16  197.5hz Appx. G3  Sin
	0<<14|0<<12|153, // 0x17  209.2hz Appx. G#3 Sin
	0<<14|0<<12|144, // 0x18  222.2hz Appx. A3  Sin
	0<<14|0<<12|136, // 0x19  235.3hz Appx. A#3 Sin
	0<<14|0<<12|129, // 0x1A  248.1hz Appx. B3  Sin
	0<<14|0<<12|121, // 0x1B  264.5hz Appx. C4  Sin
	0<<14|0<<12|114, // 0x1C  280.7hz Appx. C#4 Sin
	0<<14|0<<12|108, // 0x1D  296.3hz Appx. D4  Sin
	0<<14|0<<12|102, // 0x1E  313.7hz Appx. D#4 Sin
	0<<14|0<<12|96,  // 0x1F  333.3hz Appx. E4  Sin
	0<<14|0<<12|91,  // 0x20  351.6hz Appx. F4  Sin
	0<<14|0<<12|86,  // 0x21  372.1hz Appx. F#4 Sin
	0<<14|0<<12|81,  // 0x22  395.1hz Appx. G4  Sin
	0<<14|0<<12|76,  // 0x23  421.1hz Appx. G#4 Sin
	0<<14|0<<12|72,  // 0x24  444.4hz Appx. A4  Sin
	0<<14|0<<12|68,  // 0x25  470.6hz Appx. A#4 Sin
	0<<14|0<<12|64,  // 0x26  500.0hz Appx. B4  Sin
	0<<14|0<<12|61,  // 0x27  524.6hz Appx. C5  Sin
	0<<14|0<<12|57,  // 0x28  561.4hz Appx. C#5 Sin
	0<<14|0<<12|54,  // 0x29  592.6hz Appx. D5  Sin
	0<<14|0<<12|51,  // 0x2A  627.5hz Appx. D#5 Sin
	0<<14|0<<12|48,  // 0x2B  666.7hz Appx. E5  Sin
	0<<14|0<<12|46,  // 0x2C  695.7hz Appx. F5  Sin
	0<<14|0<<12|43,  // 0x2D  744.2hz Appx. F#5 Sin
	0<<14|0<<12|41,  // 0x2E  780.5hz Appx. G5  Sin
	0<<14|0<<12|38,  // 0x2F  842.1hz Appx. G#5 Sin
	0<<14|0<<12|36,  // 0x30  888.9hz Appx. A5  Sin
	0<<14|0<<12|34,  // 0x31  941.2hz Appx. A#5 Sin
	0<<14|0<<12|32,  // 0x32 1000.0hz Appx. B5  Sin
	0<<14|0<<12|30,  // 0x33 1066.7hz Appx. C6  Sin
	0<<14|0<<12|29,  // 0x34 1103.4hz Appx. C#6 Sin
	0<<14|0<<12|27,  // 0x35 1185.2hz Appx. D6  Sin
	0<<14|0<<12|26,  // 0x36 1230.8hz Appx. D#6 Sin
	0<<14|0<<12|24,  // 0x37 1333.3hz Appx. E6  Sin
	0<<14|0<<12|23,  // 0x38 1391.3hz Appx. F6  Sin
	0<<14|0<<12|22,  // 0x39 1454.5hz Appx. F#6 Sin
	0<<14|0<<12|20,  // 0x3A 1600.0hz Appx. G6  Sin
	0<<14|0<<12|19,  // 0x3B 1684.2hz Appx. G#6 Sin
	0<<14|0<<12|18,  // 0x3C 1777.8hz Appx. A6  Sin
	0<<14|0<<12|17,  // 0x3D 1882.4hz Appx. A#6 Sin
	0<<14|0<<12|16,  // 0x3E 2000.0hz Appx. B6  Sin
	0<<14|0<<12|15,  // 0x3F 2133.3hz Appx. C7  Sin

	1<<14|0<<12|581, // 0x40  55.08hz Appx. A1  Triangle
	1<<14|0<<12|548, // 0x41  58.39hz Appx. A#1 Triangle
	1<<14|0<<12|518, // 0x42  61.78hz Appx. B1  Triangle
	1<<14|0<<12|489, // 0x43  65.44hz Appx. C2  Triangle
	1<<14|0<<12|461, // 0x44  69.41hz Appx. C#2 Triangle
	1<<14|0<<12|435, // 0x45  73.56hz Appx. D2  Triangle
	1<<14|0<<12|411, // 0x46  77.86hz Appx. D#2 Triangle
	1<<14|0<<12|388, // 0x47  82.47hz Appx. E2  Triangle
	1<<14|0<<12|366, // 0x48  87.43hz Appx. F2  Triangle
	1<<14|0<<12|345, // 0x49  92.75hz Appx. F#2 Triangle
	1<<14|0<<12|326, // 0x4A  98.16hz Appx. G2  Triangle
	1<<14|0<<12|308, // 0x4B  103.9hz Appx. G#2 Triangle
	1<<14|0<<12|288, // 0x4C  111.1hz Appx. A2  Triangle
	1<<14|0<<12|272, // 0x4D  117.6hz Appx. A#2 Triangle
	1<<14|0<<12|257, // 0x4E  124.5hz Appx. B2  Triangle
	1<<14|0<<12|242, // 0x4F  132.2hz Appx. C3  Triangle
	1<<14|0<<12|229, // 0x50  139.7hz Appx. C#3 Triangle
	1<<14|0<<12|216, // 0x51  148.1hz Appx. D3  Triangle
	1<<14|0<<12|204, // 0x52  156.9hz Appx. D#3 Triangle
	1<<14|0<<12|192, // 0x53  166.7hz Appx. E3  Triangle
	1<<14|0<<12|181, // 0x54  176.8hz Appx. F3  Triangle
	1<<14|0<<12|171, // 0x55  187.1hz Appx. F#3 Triangle
	1<<14|0<<12|162, // 0x56  197.5hz Appx. G3  Triangle
	1<<14|0<<12|153, // 0x57  209.2hz Appx. G#3 Triangle
	1<<14|0<<12|144, // 0x58  222.2hz Appx. A3  Triangle
	1<<14|0<<12|136, // 0x59  235.3hz Appx. A#3 Triangle
	1<<14|0<<12|129, // 0x5A  248.1hz Appx. B3  Triangle
	1<<14|0<<12|121, // 0x5B  264.5hz Appx. C4  Triangle
	1<<14|0<<12|114, // 0x5C  280.7hz Appx. C#4 Triangle
	1<<14|0<<12|108, // 0x5D  296.3hz Appx. D4  Triangle
	1<<14|0<<12|102, // 0x5E  313.7hz Appx. D#4 Triangle
	1<<14|0<<12|96,  // 0x5F  333.3hz Appx. E4  Triangle
	1<<14|0<<12|91,  // 0x60  351.6hz Appx. F4  Triangle
	1<<14|0<<12|86,  // 0x61  372.1hz Appx. F#4 Triangle
	1<<14|0<<12|81,  // 0x62  395.1hz Appx. G4  Triangle
	1<<14|0<<12|76,  // 0x63  421.1hz Appx. G#4 Triangle
	1<<14|0<<12|72,  // 0x64  444.4hz Appx. A4  Triangle
	1<<14|0<<12|68,  // 0x65  470.6hz Appx. A#4 Triangle
	1<<14|0<<12|64,  // 0x66  500.0hz Appx. B4  Triangle
	1<<14|0<<12|61,  // 0x67  524.6hz Appx. C5  Triangle
	1<<14|0<<12|57,  // 0x68  561.4hz Appx. C#5 Triangle
	1<<14|0<<12|54,  // 0x69  592.6hz Appx. D5  Triangle
	1<<14|0<<12|51,  // 0x6A  627.5hz Appx. D#5 Triangle
	1<<14|0<<12|48,  // 0x6B  666.7hz Appx. E5  Triangle
	1<<14|0<<12|46,  // 0x6C  695.7hz Appx. F5  Triangle
	1<<14|0<<12|43,  // 0x6D  744.2hz Appx. F#5 Triangle
	1<<14|0<<12|41,  // 0x6E  780.5hz Appx. G5  Triangle
	1<<14|0<<12|38,  // 0x6F  842.1hz Appx. G#5 Triangle
	1<<14|0<<12|36,  // 0x70  888.9hz Appx. A5  Triangle
	1<<14|0<<12|34,  // 0x71  941.2hz Appx. A#5 Triangle
	1<<14|0<<12|32,  // 0x72 1000.0hz Appx. B5  Triangle
	1<<14|0<<12|30,  // 0x73 1066.7hz Appx. C6  Triangle
	1<<14|0<<12|29,  // 0x74 1103.4hz Appx. C#6 Triangle
	1<<14|0<<12|27,  // 0x75 1185.2hz Appx. D6  Triangle
	1<<14|0<<12|26,  // 0x76 1230.8hz Appx. D#6 Triangle
	1<<14|0<<12|24,  // 0x77 1333.3hz Appx. E6  Triangle
	1<<14|0<<12|23,  // 0x78 1391.3hz Appx. F6  Triangle
	1<<14|0<<12|22,  // 0x79 1454.5hz Appx. F#6 Triangle
	1<<14|0<<12|20,  // 0x7A 1600.0hz Appx. G6  Triangle
	1<<14|0<<12|19,  // 0x7B 1684.2hz Appx. G#6 Triangle
	1<<14|0<<12|18,  // 0x7C 1777.8hz Appx. A6  Triangle
	1<<14|0<<12|17,  // 0x7D 1882.4hz Appx. A#6 Triangle
	1<<14|0<<12|16,  // 0x7E 2000.0hz Appx. B6  Triangle
	1<<14|0<<12|15,  // 0x7F 2133.3hz Appx. C7  Triangle

	2<<14|0<<12|581, // 0x80  55.08hz Appx. A1  Square
	2<<14|0<<12|548, // 0x81  58.39hz Appx. A#1 Square
	2<<14|0<<12|518, // 0x82  61.78hz Appx. B1  Square
	2<<14|0<<12|489, // 0x83  65.44hz Appx. C2  Square
	2<<14|0<<12|461, // 0x84  69.41hz Appx. C#2 Square
	2<<14|0<<12|435, // 0x85  73.56hz Appx. D2  Square
	2<<14|0<<12|411, // 0x86  77.86hz Appx. D#2 Square
	2<<14|0<<12|388, // 0x87  82.47hz Appx. E2  Square
	2<<14|0<<12|366, // 0x88  87.43hz Appx. F2  Square
	2<<14|0<<12|345, // 0x89  92.75hz Appx. F#2 Square
	2<<14|0<<12|326, // 0x8A  98.16hz Appx. G2  Square
	2<<14|0<<12|308, // 0x8B  103.9hz Appx. G#2 Square
	2<<14|0<<12|288, // 0x8C  111.1hz Appx. A2  Square
	2<<14|0<<12|272, // 0x8D  117.6hz Appx. A#2 Square
	2<<14|0<<12|257, // 0x8E  124.5hz Appx. B2  Square
	2<<14|0<<12|242, // 0x8F  132.2hz Appx. C3  Square
	2<<14|0<<12|229, // 0x90  139.7hz Appx. C#3 Square
	2<<14|0<<12|216, // 0x91  148.1hz Appx. D3  Square
	2<<14|0<<12|204, // 0x92  156.9hz Appx. D#3 Square
	2<<14|0<<12|192, // 0x93  166.7hz Appx. E3  Square
	2<<14|0<<12|181, // 0x94  176.8hz Appx. F3  Square
	2<<14|0<<12|171, // 0x95  187.1hz Appx. F#3 Square
	2<<14|0<<12|162, // 0x96  197.5hz Appx. G3  Square
	2<<14|0<<12|153, // 0x97  209.2hz Appx. G#3 Square
	2<<14|0<<12|144, // 0x98  222.2hz Appx. A3  Square
	2<<14|0<<12|136, // 0x99  235.3hz Appx. A#3 Square
	2<<14|0<<12|129, // 0x9A  248.1hz Appx. B3  Square
	2<<14|0<<12|121, // 0x9B  264.5hz Appx. C4  Square
	2<<14|0<<12|114, // 0x9C  280.7hz Appx. C#4 Square
	2<<14|0<<12|108, // 0x9D  296.3hz Appx. D4  Square
	2<<14|0<<12|102, // 0x9E  313.7hz Appx. D#4 Square
	2<<14|0<<12|96,  // 0x9F  333.3hz Appx. E4  Square
	2<<14|0<<12|91,  // 0xA0  351.6hz Appx. F4  Square
	2<<14|0<<12|86,  // 0xA1  372.1hz Appx. F#4 Square
	2<<14|0<<12|81,  // 0xA2  395.1hz Appx. G4  Square
	2<<14|0<<12|76,  // 0xA3  421.1hz Appx. G#4 Square
	2<<14|0<<12|72,  // 0xA4  444.4hz Appx. A4  Square
	2<<14|0<<12|68,  // 0xA5  470.6hz Appx. A#4 Square
	2<<14|0<<12|64,  // 0xA6  500.0hz Appx. B4  Square
	2<<14|0<<12|61,  // 0xA7  524.6hz Appx. C5  Square
	2<<14|0<<12|57,  // 0xA8  561.4hz Appx. C#5 Square
	2<<14|0<<12|54,  // 0xA9  592.6hz Appx. D5  Square
	2<<14|0<<12|51,  // 0xAA  627.5hz Appx. D#5 Square
	2<<14|0<<12|48,  // 0xAB  666.7hz Appx. E5  Square
	2<<14|0<<12|46,  // 0xAC  695.7hz Appx. F5  Square
	2<<14|0<<12|43,  // 0xAD  744.2hz Appx. F#5 Square
	2<<14|0<<12|41,  // 0xAE  780.5hz Appx. G5  Square
	2<<14|0<<12|38,  // 0xAF  842.1hz Appx. G#5 Square
	2<<14|0<<12|36,  // 0xB0  888.9hz Appx. A5  Square
	2<<14|0<<12|34,  // 0xB1  941.2hz Appx. A#5 Square
	2<<14|0<<12|32,  // 0xB2 1000.0hz Appx. B5  Square
	2<<14|0<<12|30,  // 0xB3 1066.7hz Appx. C6  Square
	2<<14|0<<12|29,  // 0xB4 1103.4hz Appx. C#6 Square
	2<<14|0<<12|27,  // 0xB5 1185.2hz Appx. D6  Square
	2<<14|0<<12|26,  // 0xB6 1230.8hz Appx. D#6 Square
	2<<14|0<<12|24,  // 0xB7 1333.3hz Appx. E6  Square
	2<<14|0<<12|23,  // 0xB8 1391.3hz Appx. F6  Square
	2<<14|0<<12|22,  // 0xB9 1454.5hz Appx. F#6 Square
	2<<14|0<<12|20,  // 0xBA 1600.0hz Appx. G6  Square
	2<<14|0<<12|19,  // 0xBB 1684.2hz Appx. G#6 Square
	2<<14|0<<12|18,  // 0xBC 1777.8hz Appx. A6  Square
	2<<14|0<<12|17,  // 0xBD 1882.4hz Appx. A#6 Square
	2<<14|0<<12|16,  // 0xBE 2000.0hz Appx. B6  Square
	2<<14|0<<12|15,  // 0xBF 2133.3hz Appx. C7  Square

	3<<14|0<<12|581, // 0xC0  55.08hz Appx. A1  Noise
	3<<14|0<<12|548, // 0xC1  58.39hz Appx. A#1 Noise
	3<<14|0<<12|518, // 0xC2  61.78hz Appx. B1  Noise
	3<<14|0<<12|489, // 0xC3  65.44hz Appx. C2  Noise
	3<<14|0<<12|461, // 0xC4  69.41hz Appx. C#2 Noise
	3<<14|0<<12|435, // 0xC5  73.56hz Appx. D2  Noise
	3<<14|0<<12|411, // 0xC6  77.86hz Appx. D#2 Noise
	3<<14|0<<12|388, // 0xC7  82.47hz Appx. E2  Noise
	3<<14|0<<12|366, // 0xC8  87.43hz Appx. F2  Noise
	3<<14|0<<12|345, // 0xC9  92.75hz Appx. F#2 Noise
	3<<14|0<<12|326, // 0xCA  98.16hz Appx. G2  Noise
	3<<14|0<<12|308, // 0xCB  103.9hz Appx. G#2 Noise
	3<<14|0<<12|288, // 0xCC  111.1hz Appx. A2  Noise
	3<<14|0<<12|272, // 0xCD  117.6hz Appx. A#2 Noise
	3<<14|0<<12|257, // 0xCE  124.5hz Appx. B2  Noise
	3<<14|0<<12|242, // 0xCF  132.2hz Appx. C3  Noise
	3<<14|0<<12|229, // 0xD0  139.7hz Appx. C#3 Noise
	3<<14|0<<12|216, // 0xD1  148.1hz Appx. D3  Noise
	3<<14|0<<12|204, // 0xD2  156.9hz Appx. D#3 Noise
	3<<14|0<<12|192, // 0xD3  166.7hz Appx. E3  Noise
	3<<14|0<<12|181, // 0xD4  176.8hz Appx. F3  Noise
	3<<14|0<<12|171, // 0xD5  187.1hz Appx. F#3 Noise
	3<<14|0<<12|162, // 0xD6  197.5hz Appx. G3  Noise
	3<<14|0<<12|153, // 0xD7  209.2hz Appx. G#3 Noise
	3<<14|0<<12|144, // 0xD8  222.2hz Appx. A3  Noise
	3<<14|0<<12|136, // 0xD9  235.3hz Appx. A#3 Noise
	3<<14|0<<12|129, // 0xDA  248.1hz Appx. B3  Noise
	3<<14|0<<12|121, // 0xDB  264.5hz Appx. C4  Noise
	3<<14|0<<12|114, // 0xDC  280.7hz Appx. C#4 Noise
	3<<14|0<<12|108, // 0xDD  296.3hz Appx. D4  Noise
	3<<14|0<<12|102, // 0xDE  313.7hz Appx. D#4 Noise
	3<<14|0<<12|96,  // 0xDF  333.3hz Appx. E4  Noise
	3<<14|0<<12|91,  // 0xE0  351.6hz Appx. F4  Noise
	3<<14|0<<12|86,  // 0xE1  372.1hz Appx. F#4 Noise
	3<<14|0<<12|81,  // 0xE2  395.1hz Appx. G4  Noise
	3<<14|0<<12|76,  // 0xE3  421.1hz Appx. G#4 Noise
	3<<14|0<<12|72,  // 0xE4  444.4hz Appx. A4  Noise
	3<<14|0<<12|68,  // 0xE5  470.6hz Appx. A#4 Noise
	3<<14|0<<12|64,  // 0xE6  500.0hz Appx. B4  Noise
	3<<14|0<<12|61,  // 0xE7  524.6hz Appx. C5  Noise
	3<<14|0<<12|57,  // 0xE8  561.4hz Appx. C#5 Noise
	3<<14|0<<12|54,  // 0xE9  592.6hz Appx. D5  Noise
	3<<14|0<<12|51,  // 0xEA  627.5hz Appx. D#5 Noise
	3<<14|0<<12|48,  // 0xEB  666.7hz Appx. E5  Noise
	3<<14|0<<12|46,  // 0xEC  695.7hz Appx. F5  Noise
	3<<14|0<<12|43,  // 0xED  744.2hz Appx. F#5 Noise
	3<<14|0<<12|41,  // 0xEE  780.5hz Appx. G5  Noise
	3<<14|0<<12|38,  // 0xEF  842.1hz Appx. G#5 Noise
	3<<14|0<<12|36,  // 0xF0  888.9hz Appx. A5  Noise
	3<<14|0<<12|34,  // 0xF1  941.2hz Appx. A#5 Noise
	3<<14|0<<12|32,  // 0xF2 1000.0hz Appx. B5  Noise
	3<<14|0<<12|30,  // 0xF3 1066.7hz Appx. C6  Noise
	3<<14|0<<12|29,  // 0xF4 1103.4hz Appx. C#6 Noise
	3<<14|0<<12|27,  // 0xF5 1185.2hz Appx. D6  Noise
	3<<14|0<<12|26,  // 0xF6 1230.8hz Appx. D#6 Noise
	3<<14|0<<12|24,  // 0xF7 1333.3hz Appx. E6  Noise
	3<<14|0<<12|23,  // 0xF8 1391.3hz Appx. F6  Noise
	3<<14|0<<12|22,  // 0xF9 1454.5hz Appx. F#6 Noise
	3<<14|0<<12|20,  // 0xFA 1600.0hz Appx. G6  Noise
	3<<14|0<<12|19,  // 0xFB 1684.2hz Appx. G#6 Noise
	3<<14|0<<12|18,  // 0xFC 1777.8hz Appx. A6  Noise
	3<<14|0<<12|17,  // 0xFD 1882.4hz Appx. A#6 Noise
	3<<14|0<<12|16,  // 0xFE 2000.0hz Appx. B6  Noise
	3<<14|0<<12|15,  // 0xFF 2133.3hz Appx. C7  Noise

	2<<14|3<<12|36,  // 0x100 Silence 
	3<<14|2<<12|0,   // 0x101 Long Noise
	0                // End of Index
};
