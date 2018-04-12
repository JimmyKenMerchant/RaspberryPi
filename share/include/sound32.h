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
 * Bit[15:14]: Type of Wave, 0 is Sin, 1 is Saw Tooth, 2 is Square, 3 is Noise, ordered by less edges which cause harmonics.
 *
 * Maximum number of blocks is 4096.
 * 0 means End of Sound Index
 */

/**
 * Music Code is 16-bit Blocks. Select up to 4096 sounds indexed by Sound Index.
 * Index is 0-4096.
 * 0xFFFF(65535) means End of Music Code.
 */

/**
 * These comments about frequencies assume 3.2Khz as the sampling rate, using on PWM direct output (including from 3.5mm minijack).
 * On PCM, the sampling rate is appx. 3.168Khz to be adjusted to fit A4 on 440hz, e.g., G4 becomes 391.1Hz.
 */
sound_index sound[] =
{
	/* Volume Big */

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

	1<<14|0<<12|581, // 0x40  55.08hz Appx. A1  Saw Tooth
	1<<14|0<<12|548, // 0x41  58.39hz Appx. A#1 Saw Tooth
	1<<14|0<<12|518, // 0x42  61.78hz Appx. B1  Saw Tooth
	1<<14|0<<12|489, // 0x43  65.44hz Appx. C2  Saw Tooth
	1<<14|0<<12|461, // 0x44  69.41hz Appx. C#2 Saw Tooth
	1<<14|0<<12|435, // 0x45  73.56hz Appx. D2  Saw Tooth
	1<<14|0<<12|411, // 0x46  77.86hz Appx. D#2 Saw Tooth
	1<<14|0<<12|388, // 0x47  82.47hz Appx. E2  Saw Tooth
	1<<14|0<<12|366, // 0x48  87.43hz Appx. F2  Saw Tooth
	1<<14|0<<12|345, // 0x49  92.75hz Appx. F#2 Saw Tooth
	1<<14|0<<12|326, // 0x4A  98.16hz Appx. G2  Saw Tooth
	1<<14|0<<12|308, // 0x4B  103.9hz Appx. G#2 Saw Tooth
	1<<14|0<<12|288, // 0x4C  111.1hz Appx. A2  Saw Tooth
	1<<14|0<<12|272, // 0x4D  117.6hz Appx. A#2 Saw Tooth
	1<<14|0<<12|257, // 0x4E  124.5hz Appx. B2  Saw Tooth
	1<<14|0<<12|242, // 0x4F  132.2hz Appx. C3  Saw Tooth
	1<<14|0<<12|229, // 0x50  139.7hz Appx. C#3 Saw Tooth
	1<<14|0<<12|216, // 0x51  148.1hz Appx. D3  Saw Tooth
	1<<14|0<<12|204, // 0x52  156.9hz Appx. D#3 Saw Tooth
	1<<14|0<<12|192, // 0x53  166.7hz Appx. E3  Saw Tooth
	1<<14|0<<12|181, // 0x54  176.8hz Appx. F3  Saw Tooth
	1<<14|0<<12|171, // 0x55  187.1hz Appx. F#3 Saw Tooth
	1<<14|0<<12|162, // 0x56  197.5hz Appx. G3  Saw Tooth
	1<<14|0<<12|153, // 0x57  209.2hz Appx. G#3 Saw Tooth
	1<<14|0<<12|144, // 0x58  222.2hz Appx. A3  Saw Tooth
	1<<14|0<<12|136, // 0x59  235.3hz Appx. A#3 Saw Tooth
	1<<14|0<<12|129, // 0x5A  248.1hz Appx. B3  Saw Tooth
	1<<14|0<<12|121, // 0x5B  264.5hz Appx. C4  Saw Tooth
	1<<14|0<<12|114, // 0x5C  280.7hz Appx. C#4 Saw Tooth
	1<<14|0<<12|108, // 0x5D  296.3hz Appx. D4  Saw Tooth
	1<<14|0<<12|102, // 0x5E  313.7hz Appx. D#4 Saw Tooth
	1<<14|0<<12|96,  // 0x5F  333.3hz Appx. E4  Saw Tooth
	1<<14|0<<12|91,  // 0x60  351.6hz Appx. F4  Saw Tooth
	1<<14|0<<12|86,  // 0x61  372.1hz Appx. F#4 Saw Tooth
	1<<14|0<<12|81,  // 0x62  395.1hz Appx. G4  Saw Tooth
	1<<14|0<<12|76,  // 0x63  421.1hz Appx. G#4 Saw Tooth
	1<<14|0<<12|72,  // 0x64  444.4hz Appx. A4  Saw Tooth
	1<<14|0<<12|68,  // 0x65  470.6hz Appx. A#4 Saw Tooth
	1<<14|0<<12|64,  // 0x66  500.0hz Appx. B4  Saw Tooth
	1<<14|0<<12|61,  // 0x67  524.6hz Appx. C5  Saw Tooth
	1<<14|0<<12|57,  // 0x68  561.4hz Appx. C#5 Saw Tooth
	1<<14|0<<12|54,  // 0x69  592.6hz Appx. D5  Saw Tooth
	1<<14|0<<12|51,  // 0x6A  627.5hz Appx. D#5 Saw Tooth
	1<<14|0<<12|48,  // 0x6B  666.7hz Appx. E5  Saw Tooth
	1<<14|0<<12|46,  // 0x6C  695.7hz Appx. F5  Saw Tooth
	1<<14|0<<12|43,  // 0x6D  744.2hz Appx. F#5 Saw Tooth
	1<<14|0<<12|41,  // 0x6E  780.5hz Appx. G5  Saw Tooth
	1<<14|0<<12|38,  // 0x6F  842.1hz Appx. G#5 Saw Tooth
	1<<14|0<<12|36,  // 0x70  888.9hz Appx. A5  Saw Tooth
	1<<14|0<<12|34,  // 0x71  941.2hz Appx. A#5 Saw Tooth
	1<<14|0<<12|32,  // 0x72 1000.0hz Appx. B5  Saw Tooth
	1<<14|0<<12|30,  // 0x73 1066.7hz Appx. C6  Saw Tooth
	1<<14|0<<12|29,  // 0x74 1103.4hz Appx. C#6 Saw Tooth
	1<<14|0<<12|27,  // 0x75 1185.2hz Appx. D6  Saw Tooth
	1<<14|0<<12|26,  // 0x76 1230.8hz Appx. D#6 Saw Tooth
	1<<14|0<<12|24,  // 0x77 1333.3hz Appx. E6  Saw Tooth
	1<<14|0<<12|23,  // 0x78 1391.3hz Appx. F6  Saw Tooth
	1<<14|0<<12|22,  // 0x79 1454.5hz Appx. F#6 Saw Tooth
	1<<14|0<<12|20,  // 0x7A 1600.0hz Appx. G6  Saw Tooth
	1<<14|0<<12|19,  // 0x7B 1684.2hz Appx. G#6 Saw Tooth
	1<<14|0<<12|18,  // 0x7C 1777.8hz Appx. A6  Saw Tooth
	1<<14|0<<12|17,  // 0x7D 1882.4hz Appx. A#6 Saw Tooth
	1<<14|0<<12|16,  // 0x7E 2000.0hz Appx. B6  Saw Tooth
	1<<14|0<<12|15,  // 0x7F 2133.3hz Appx. C7  Saw Tooth

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

	/* Volume Middle */

	0<<14|1<<12|581, // 0x100  55.08hz Appx. A1  Sin
	0<<14|1<<12|548, // 0x101  58.39hz Appx. A#1 Sin
	0<<14|1<<12|518, // 0x102  61.78hz Appx. B1  Sin
	0<<14|1<<12|489, // 0x103  65.44hz Appx. C2  Sin
	0<<14|1<<12|461, // 0x104  69.41hz Appx. C#2 Sin
	0<<14|1<<12|435, // 0x105  73.56hz Appx. D2  Sin
	0<<14|1<<12|411, // 0x106  77.86hz Appx. D#2 Sin
	0<<14|1<<12|388, // 0x107  82.47hz Appx. E2  Sin
	0<<14|1<<12|366, // 0x108  87.43hz Appx. F2  Sin
	0<<14|1<<12|345, // 0x109  92.75hz Appx. F#2 Sin
	0<<14|1<<12|326, // 0x10A  98.16hz Appx. G2  Sin
	0<<14|1<<12|308, // 0x10B  103.9hz Appx. G#2 Sin
	0<<14|1<<12|288, // 0x10C  111.1hz Appx. A2  Sin
	0<<14|1<<12|272, // 0x10D  117.6hz Appx. A#2 Sin
	0<<14|1<<12|257, // 0x10E  124.5hz Appx. B2  Sin
	0<<14|1<<12|242, // 0x10F  132.2hz Appx. C3  Sin
	0<<14|1<<12|229, // 0x110  139.7hz Appx. C#3 Sin
	0<<14|1<<12|216, // 0x111  148.1hz Appx. D3  Sin
	0<<14|1<<12|204, // 0x112  156.9hz Appx. D#3 Sin
	0<<14|1<<12|192, // 0x113  166.7hz Appx. E3  Sin
	0<<14|1<<12|181, // 0x114  176.8hz Appx. F3  Sin
	0<<14|1<<12|171, // 0x115  187.1hz Appx. F#3 Sin
	0<<14|1<<12|162, // 0x116  197.5hz Appx. G3  Sin
	0<<14|1<<12|153, // 0x117  209.2hz Appx. G#3 Sin
	0<<14|1<<12|144, // 0x118  222.2hz Appx. A3  Sin
	0<<14|1<<12|136, // 0x119  235.3hz Appx. A#3 Sin
	0<<14|1<<12|129, // 0x11A  248.1hz Appx. B3  Sin
	0<<14|1<<12|121, // 0x11B  264.5hz Appx. C4  Sin
	0<<14|1<<12|114, // 0x11C  280.7hz Appx. C#4 Sin
	0<<14|1<<12|108, // 0x11D  296.3hz Appx. D4  Sin
	0<<14|1<<12|102, // 0x11E  313.7hz Appx. D#4 Sin
	0<<14|1<<12|96,  // 0x11F  333.3hz Appx. E4  Sin
	0<<14|1<<12|91,  // 0x120  351.6hz Appx. F4  Sin
	0<<14|1<<12|86,  // 0x121  372.1hz Appx. F#4 Sin
	0<<14|1<<12|81,  // 0x122  395.1hz Appx. G4  Sin
	0<<14|1<<12|76,  // 0x123  421.1hz Appx. G#4 Sin
	0<<14|1<<12|72,  // 0x124  444.4hz Appx. A4  Sin
	0<<14|1<<12|68,  // 0x125  470.6hz Appx. A#4 Sin
	0<<14|1<<12|64,  // 0x126  500.0hz Appx. B4  Sin
	0<<14|1<<12|61,  // 0x127  524.6hz Appx. C5  Sin
	0<<14|1<<12|57,  // 0x128  561.4hz Appx. C#5 Sin
	0<<14|1<<12|54,  // 0x129  592.6hz Appx. D5  Sin
	0<<14|1<<12|51,  // 0x12A  627.5hz Appx. D#5 Sin
	0<<14|1<<12|48,  // 0x12B  666.7hz Appx. E5  Sin
	0<<14|1<<12|46,  // 0x12C  695.7hz Appx. F5  Sin
	0<<14|1<<12|43,  // 0x12D  744.2hz Appx. F#5 Sin
	0<<14|1<<12|41,  // 0x12E  780.5hz Appx. G5  Sin
	0<<14|1<<12|38,  // 0x12F  842.1hz Appx. G#5 Sin
	0<<14|1<<12|36,  // 0x130  888.9hz Appx. A5  Sin
	0<<14|1<<12|34,  // 0x131  941.2hz Appx. A#5 Sin
	0<<14|1<<12|32,  // 0x132 1000.0hz Appx. B5  Sin
	0<<14|1<<12|30,  // 0x133 1066.7hz Appx. C6  Sin
	0<<14|1<<12|29,  // 0x134 1103.4hz Appx. C#6 Sin
	0<<14|1<<12|27,  // 0x135 1185.2hz Appx. D6  Sin
	0<<14|1<<12|26,  // 0x136 1230.8hz Appx. D#6 Sin
	0<<14|1<<12|24,  // 0x137 1333.3hz Appx. E6  Sin
	0<<14|1<<12|23,  // 0x138 1391.3hz Appx. F6  Sin
	0<<14|1<<12|22,  // 0x139 1454.5hz Appx. F#6 Sin
	0<<14|1<<12|20,  // 0x13A 1600.0hz Appx. G6  Sin
	0<<14|1<<12|19,  // 0x13B 1684.2hz Appx. G#6 Sin
	0<<14|1<<12|18,  // 0x13C 1777.8hz Appx. A6  Sin
	0<<14|1<<12|17,  // 0x13D 1882.4hz Appx. A#6 Sin
	0<<14|1<<12|16,  // 0x13E 2000.0hz Appx. B6  Sin
	0<<14|1<<12|15,  // 0x13F 2133.3hz Appx. C7  Sin

	1<<14|1<<12|581, // 0x140  55.08hz Appx. A1  Saw Tooth
	1<<14|1<<12|548, // 0x141  58.39hz Appx. A#1 Saw Tooth
	1<<14|1<<12|518, // 0x142  61.78hz Appx. B1  Saw Tooth
	1<<14|1<<12|489, // 0x143  65.44hz Appx. C2  Saw Tooth
	1<<14|1<<12|461, // 0x144  69.41hz Appx. C#2 Saw Tooth
	1<<14|1<<12|435, // 0x145  73.56hz Appx. D2  Saw Tooth
	1<<14|1<<12|411, // 0x146  77.86hz Appx. D#2 Saw Tooth
	1<<14|1<<12|388, // 0x147  82.47hz Appx. E2  Saw Tooth
	1<<14|1<<12|366, // 0x148  87.43hz Appx. F2  Saw Tooth
	1<<14|1<<12|345, // 0x149  92.75hz Appx. F#2 Saw Tooth
	1<<14|1<<12|326, // 0x14A  98.16hz Appx. G2  Saw Tooth
	1<<14|1<<12|308, // 0x14B  103.9hz Appx. G#2 Saw Tooth
	1<<14|1<<12|288, // 0x14C  111.1hz Appx. A2  Saw Tooth
	1<<14|1<<12|272, // 0x14D  117.6hz Appx. A#2 Saw Tooth
	1<<14|1<<12|257, // 0x14E  124.5hz Appx. B2  Saw Tooth
	1<<14|1<<12|242, // 0x14F  132.2hz Appx. C3  Saw Tooth
	1<<14|1<<12|229, // 0x150  139.7hz Appx. C#3 Saw Tooth
	1<<14|1<<12|216, // 0x151  148.1hz Appx. D3  Saw Tooth
	1<<14|1<<12|204, // 0x152  156.9hz Appx. D#3 Saw Tooth
	1<<14|1<<12|192, // 0x153  166.7hz Appx. E3  Saw Tooth
	1<<14|1<<12|181, // 0x154  176.8hz Appx. F3  Saw Tooth
	1<<14|1<<12|171, // 0x155  187.1hz Appx. F#3 Saw Tooth
	1<<14|1<<12|162, // 0x156  197.5hz Appx. G3  Saw Tooth
	1<<14|1<<12|153, // 0x157  209.2hz Appx. G#3 Saw Tooth
	1<<14|1<<12|144, // 0x158  222.2hz Appx. A3  Saw Tooth
	1<<14|1<<12|136, // 0x159  235.3hz Appx. A#3 Saw Tooth
	1<<14|1<<12|129, // 0x15A  248.1hz Appx. B3  Saw Tooth
	1<<14|1<<12|121, // 0x15B  264.5hz Appx. C4  Saw Tooth
	1<<14|1<<12|114, // 0x15C  280.7hz Appx. C#4 Saw Tooth
	1<<14|1<<12|108, // 0x15D  296.3hz Appx. D4  Saw Tooth
	1<<14|1<<12|102, // 0x15E  313.7hz Appx. D#4 Saw Tooth
	1<<14|1<<12|96,  // 0x15F  333.3hz Appx. E4  Saw Tooth
	1<<14|1<<12|91,  // 0x160  351.6hz Appx. F4  Saw Tooth
	1<<14|1<<12|86,  // 0x161  372.1hz Appx. F#4 Saw Tooth
	1<<14|1<<12|81,  // 0x162  395.1hz Appx. G4  Saw Tooth
	1<<14|1<<12|76,  // 0x163  421.1hz Appx. G#4 Saw Tooth
	1<<14|1<<12|72,  // 0x164  444.4hz Appx. A4  Saw Tooth
	1<<14|1<<12|68,  // 0x165  470.6hz Appx. A#4 Saw Tooth
	1<<14|1<<12|64,  // 0x166  500.0hz Appx. B4  Saw Tooth
	1<<14|1<<12|61,  // 0x167  524.6hz Appx. C5  Saw Tooth
	1<<14|1<<12|57,  // 0x168  561.4hz Appx. C#5 Saw Tooth
	1<<14|1<<12|54,  // 0x169  592.6hz Appx. D5  Saw Tooth
	1<<14|1<<12|51,  // 0x16A  627.5hz Appx. D#5 Saw Tooth
	1<<14|1<<12|48,  // 0x16B  666.7hz Appx. E5  Saw Tooth
	1<<14|1<<12|46,  // 0x16C  695.7hz Appx. F5  Saw Tooth
	1<<14|1<<12|43,  // 0x16D  744.2hz Appx. F#5 Saw Tooth
	1<<14|1<<12|41,  // 0x16E  780.5hz Appx. G5  Saw Tooth
	1<<14|1<<12|38,  // 0x16F  842.1hz Appx. G#5 Saw Tooth
	1<<14|1<<12|36,  // 0x170  888.9hz Appx. A5  Saw Tooth
	1<<14|1<<12|34,  // 0x171  941.2hz Appx. A#5 Saw Tooth
	1<<14|1<<12|32,  // 0x172 1000.0hz Appx. B5  Saw Tooth
	1<<14|1<<12|30,  // 0x173 1066.7hz Appx. C6  Saw Tooth
	1<<14|1<<12|29,  // 0x174 1103.4hz Appx. C#6 Saw Tooth
	1<<14|1<<12|27,  // 0x175 1185.2hz Appx. D6  Saw Tooth
	1<<14|1<<12|26,  // 0x176 1230.8hz Appx. D#6 Saw Tooth
	1<<14|1<<12|24,  // 0x177 1333.3hz Appx. E6  Saw Tooth
	1<<14|1<<12|23,  // 0x178 1391.3hz Appx. F6  Saw Tooth
	1<<14|1<<12|22,  // 0x179 1454.5hz Appx. F#6 Saw Tooth
	1<<14|1<<12|20,  // 0x17A 1600.0hz Appx. G6  Saw Tooth
	1<<14|1<<12|19,  // 0x17B 1684.2hz Appx. G#6 Saw Tooth
	1<<14|1<<12|18,  // 0x17C 1777.8hz Appx. A6  Saw Tooth
	1<<14|1<<12|17,  // 0x17D 1882.4hz Appx. A#6 Saw Tooth
	1<<14|1<<12|16,  // 0x17E 2000.0hz Appx. B6  Saw Tooth
	1<<14|1<<12|15,  // 0x17F 2133.3hz Appx. C7  Saw Tooth

	2<<14|1<<12|581, // 0x180  55.08hz Appx. A1  Square
	2<<14|1<<12|548, // 0x181  58.39hz Appx. A#1 Square
	2<<14|1<<12|518, // 0x182  61.78hz Appx. B1  Square
	2<<14|1<<12|489, // 0x183  65.44hz Appx. C2  Square
	2<<14|1<<12|461, // 0x184  69.41hz Appx. C#2 Square
	2<<14|1<<12|435, // 0x185  73.56hz Appx. D2  Square
	2<<14|1<<12|411, // 0x186  77.86hz Appx. D#2 Square
	2<<14|1<<12|388, // 0x187  82.47hz Appx. E2  Square
	2<<14|1<<12|366, // 0x188  87.43hz Appx. F2  Square
	2<<14|1<<12|345, // 0x189  92.75hz Appx. F#2 Square
	2<<14|1<<12|326, // 0x18A  98.16hz Appx. G2  Square
	2<<14|1<<12|308, // 0x18B  103.9hz Appx. G#2 Square
	2<<14|1<<12|288, // 0x18C  111.1hz Appx. A2  Square
	2<<14|1<<12|272, // 0x18D  117.6hz Appx. A#2 Square
	2<<14|1<<12|257, // 0x18E  124.5hz Appx. B2  Square
	2<<14|1<<12|242, // 0x18F  132.2hz Appx. C3  Square
	2<<14|1<<12|229, // 0x190  139.7hz Appx. C#3 Square
	2<<14|1<<12|216, // 0x191  148.1hz Appx. D3  Square
	2<<14|1<<12|204, // 0x192  156.9hz Appx. D#3 Square
	2<<14|1<<12|192, // 0x193  166.7hz Appx. E3  Square
	2<<14|1<<12|181, // 0x194  176.8hz Appx. F3  Square
	2<<14|1<<12|171, // 0x195  187.1hz Appx. F#3 Square
	2<<14|1<<12|162, // 0x196  197.5hz Appx. G3  Square
	2<<14|1<<12|153, // 0x197  209.2hz Appx. G#3 Square
	2<<14|1<<12|144, // 0x198  222.2hz Appx. A3  Square
	2<<14|1<<12|136, // 0x199  235.3hz Appx. A#3 Square
	2<<14|1<<12|129, // 0x19A  248.1hz Appx. B3  Square
	2<<14|1<<12|121, // 0x19B  264.5hz Appx. C4  Square
	2<<14|1<<12|114, // 0x19C  280.7hz Appx. C#4 Square
	2<<14|1<<12|108, // 0x19D  296.3hz Appx. D4  Square
	2<<14|1<<12|102, // 0x19E  313.7hz Appx. D#4 Square
	2<<14|1<<12|96,  // 0x19F  333.3hz Appx. E4  Square
	2<<14|1<<12|91,  // 0x1A0  351.6hz Appx. F4  Square
	2<<14|1<<12|86,  // 0x1A1  372.1hz Appx. F#4 Square
	2<<14|1<<12|81,  // 0x1A2  395.1hz Appx. G4  Square
	2<<14|1<<12|76,  // 0x1A3  421.1hz Appx. G#4 Square
	2<<14|1<<12|72,  // 0x1A4  444.4hz Appx. A4  Square
	2<<14|1<<12|68,  // 0x1A5  470.6hz Appx. A#4 Square
	2<<14|1<<12|64,  // 0x1A6  500.0hz Appx. B4  Square
	2<<14|1<<12|61,  // 0x1A7  524.6hz Appx. C5  Square
	2<<14|1<<12|57,  // 0x1A8  561.4hz Appx. C#5 Square
	2<<14|1<<12|54,  // 0x1A9  592.6hz Appx. D5  Square
	2<<14|1<<12|51,  // 0x1AA  627.5hz Appx. D#5 Square
	2<<14|1<<12|48,  // 0x1AB  666.7hz Appx. E5  Square
	2<<14|1<<12|46,  // 0x1AC  695.7hz Appx. F5  Square
	2<<14|1<<12|43,  // 0x1AD  744.2hz Appx. F#5 Square
	2<<14|1<<12|41,  // 0x1AE  780.5hz Appx. G5  Square
	2<<14|1<<12|38,  // 0x1AF  842.1hz Appx. G#5 Square
	2<<14|1<<12|36,  // 0x1B0  888.9hz Appx. A5  Square
	2<<14|1<<12|34,  // 0x1B1  941.2hz Appx. A#5 Square
	2<<14|1<<12|32,  // 0x1B2 1000.0hz Appx. B5  Square
	2<<14|1<<12|30,  // 0x1B3 1066.7hz Appx. C6  Square
	2<<14|1<<12|29,  // 0x1B4 1103.4hz Appx. C#6 Square
	2<<14|1<<12|27,  // 0x1B5 1185.2hz Appx. D6  Square
	2<<14|1<<12|26,  // 0x1B6 1230.8hz Appx. D#6 Square
	2<<14|1<<12|24,  // 0x1B7 1333.3hz Appx. E6  Square
	2<<14|1<<12|23,  // 0x1B8 1391.3hz Appx. F6  Square
	2<<14|1<<12|22,  // 0x1B9 1454.5hz Appx. F#6 Square
	2<<14|1<<12|20,  // 0x1BA 1600.0hz Appx. G6  Square
	2<<14|1<<12|19,  // 0x1BB 1684.2hz Appx. G#6 Square
	2<<14|1<<12|18,  // 0x1BC 1777.8hz Appx. A6  Square
	2<<14|1<<12|17,  // 0x1BD 1882.4hz Appx. A#6 Square
	2<<14|1<<12|16,  // 0x1BE 2000.0hz Appx. B6  Square
	2<<14|1<<12|15,  // 0x1BF 2133.3hz Appx. C7  Square

	3<<14|1<<12|581, // 0x1C0  55.08hz Appx. A1  Noise
	3<<14|1<<12|548, // 0x1C1  58.39hz Appx. A#1 Noise
	3<<14|1<<12|518, // 0x1C2  61.78hz Appx. B1  Noise
	3<<14|1<<12|489, // 0x1C3  65.44hz Appx. C2  Noise
	3<<14|1<<12|461, // 0x1C4  69.41hz Appx. C#2 Noise
	3<<14|1<<12|435, // 0x1C5  73.56hz Appx. D2  Noise
	3<<14|1<<12|411, // 0x1C6  77.86hz Appx. D#2 Noise
	3<<14|1<<12|388, // 0x1C7  82.47hz Appx. E2  Noise
	3<<14|1<<12|366, // 0x1C8  87.43hz Appx. F2  Noise
	3<<14|1<<12|345, // 0x1C9  92.75hz Appx. F#2 Noise
	3<<14|1<<12|326, // 0x1CA  98.16hz Appx. G2  Noise
	3<<14|1<<12|308, // 0x1CB  103.9hz Appx. G#2 Noise
	3<<14|1<<12|288, // 0x1CC  111.1hz Appx. A2  Noise
	3<<14|1<<12|272, // 0x1CD  117.6hz Appx. A#2 Noise
	3<<14|1<<12|257, // 0x1CE  124.5hz Appx. B2  Noise
	3<<14|1<<12|242, // 0x1CF  132.2hz Appx. C3  Noise
	3<<14|1<<12|229, // 0x1D0  139.7hz Appx. C#3 Noise
	3<<14|1<<12|216, // 0x1D1  148.1hz Appx. D3  Noise
	3<<14|1<<12|204, // 0x1D2  156.9hz Appx. D#3 Noise
	3<<14|1<<12|192, // 0x1D3  166.7hz Appx. E3  Noise
	3<<14|1<<12|181, // 0x1D4  176.8hz Appx. F3  Noise
	3<<14|1<<12|171, // 0x1D5  187.1hz Appx. F#3 Noise
	3<<14|1<<12|162, // 0x1D6  197.5hz Appx. G3  Noise
	3<<14|1<<12|153, // 0x1D7  209.2hz Appx. G#3 Noise
	3<<14|1<<12|144, // 0x1D8  222.2hz Appx. A3  Noise
	3<<14|1<<12|136, // 0x1D9  235.3hz Appx. A#3 Noise
	3<<14|1<<12|129, // 0x1DA  248.1hz Appx. B3  Noise
	3<<14|1<<12|121, // 0x1DB  264.5hz Appx. C4  Noise
	3<<14|1<<12|114, // 0x1DC  280.7hz Appx. C#4 Noise
	3<<14|1<<12|108, // 0x1DD  296.3hz Appx. D4  Noise
	3<<14|1<<12|102, // 0x1DE  313.7hz Appx. D#4 Noise
	3<<14|1<<12|96,  // 0x1DF  333.3hz Appx. E4  Noise
	3<<14|1<<12|91,  // 0x1E0  351.6hz Appx. F4  Noise
	3<<14|1<<12|86,  // 0x1E1  372.1hz Appx. F#4 Noise
	3<<14|1<<12|81,  // 0x1E2  395.1hz Appx. G4  Noise
	3<<14|1<<12|76,  // 0x1E3  421.1hz Appx. G#4 Noise
	3<<14|1<<12|72,  // 0x1E4  444.4hz Appx. A4  Noise
	3<<14|1<<12|68,  // 0x1E5  470.6hz Appx. A#4 Noise
	3<<14|1<<12|64,  // 0x1E6  500.0hz Appx. B4  Noise
	3<<14|1<<12|61,  // 0x1E7  524.6hz Appx. C5  Noise
	3<<14|1<<12|57,  // 0x1E8  561.4hz Appx. C#5 Noise
	3<<14|1<<12|54,  // 0x1E9  592.6hz Appx. D5  Noise
	3<<14|1<<12|51,  // 0x1EA  627.5hz Appx. D#5 Noise
	3<<14|1<<12|48,  // 0x1EB  666.7hz Appx. E5  Noise
	3<<14|1<<12|46,  // 0x1EC  695.7hz Appx. F5  Noise
	3<<14|1<<12|43,  // 0x1ED  744.2hz Appx. F#5 Noise
	3<<14|1<<12|41,  // 0x1EE  780.5hz Appx. G5  Noise
	3<<14|1<<12|38,  // 0x1EF  842.1hz Appx. G#5 Noise
	3<<14|1<<12|36,  // 0x1F0  888.9hz Appx. A5  Noise
	3<<14|1<<12|34,  // 0x1F1  941.2hz Appx. A#5 Noise
	3<<14|1<<12|32,  // 0x1F2 1000.0hz Appx. B5  Noise
	3<<14|1<<12|30,  // 0x1F3 1066.7hz Appx. C6  Noise
	3<<14|1<<12|29,  // 0x1F4 1103.4hz Appx. C#6 Noise
	3<<14|1<<12|27,  // 0x1F5 1185.2hz Appx. D6  Noise
	3<<14|1<<12|26,  // 0x1F6 1230.8hz Appx. D#6 Noise
	3<<14|1<<12|24,  // 0x1F7 1333.3hz Appx. E6  Noise
	3<<14|1<<12|23,  // 0x1F8 1391.3hz Appx. F6  Noise
	3<<14|1<<12|22,  // 0x1F9 1454.5hz Appx. F#6 Noise
	3<<14|1<<12|20,  // 0x1FA 1600.0hz Appx. G6  Noise
	3<<14|1<<12|19,  // 0x1FB 1684.2hz Appx. G#6 Noise
	3<<14|1<<12|18,  // 0x1FC 1777.8hz Appx. A6  Noise
	3<<14|1<<12|17,  // 0x1FD 1882.4hz Appx. A#6 Noise
	3<<14|1<<12|16,  // 0x1FE 2000.0hz Appx. B6  Noise
	3<<14|1<<12|15,  // 0x1FF 2133.3hz Appx. C7  Noise

	/* Volume Small */

	0<<14|2<<12|581, // 0x200  55.08hz Appx. A1  Sin
	0<<14|2<<12|548, // 0x201  58.39hz Appx. A#1 Sin
	0<<14|2<<12|518, // 0x202  61.78hz Appx. B1  Sin
	0<<14|2<<12|489, // 0x203  65.44hz Appx. C2  Sin
	0<<14|2<<12|461, // 0x204  69.41hz Appx. C#2 Sin
	0<<14|2<<12|435, // 0x205  73.56hz Appx. D2  Sin
	0<<14|2<<12|411, // 0x206  77.86hz Appx. D#2 Sin
	0<<14|2<<12|388, // 0x207  82.47hz Appx. E2  Sin
	0<<14|2<<12|366, // 0x208  87.43hz Appx. F2  Sin
	0<<14|2<<12|345, // 0x209  92.75hz Appx. F#2 Sin
	0<<14|2<<12|326, // 0x20A  98.16hz Appx. G2  Sin
	0<<14|2<<12|308, // 0x20B  103.9hz Appx. G#2 Sin
	0<<14|2<<12|288, // 0x20C  111.1hz Appx. A2  Sin
	0<<14|2<<12|272, // 0x20D  117.6hz Appx. A#2 Sin
	0<<14|2<<12|257, // 0x20E  124.5hz Appx. B2  Sin
	0<<14|2<<12|242, // 0x20F  132.2hz Appx. C3  Sin
	0<<14|2<<12|229, // 0x210  139.7hz Appx. C#3 Sin
	0<<14|2<<12|216, // 0x211  148.1hz Appx. D3  Sin
	0<<14|2<<12|204, // 0x212  156.9hz Appx. D#3 Sin
	0<<14|2<<12|192, // 0x213  166.7hz Appx. E3  Sin
	0<<14|2<<12|181, // 0x214  176.8hz Appx. F3  Sin
	0<<14|2<<12|171, // 0x215  187.1hz Appx. F#3 Sin
	0<<14|2<<12|162, // 0x216  197.5hz Appx. G3  Sin
	0<<14|2<<12|153, // 0x217  209.2hz Appx. G#3 Sin
	0<<14|2<<12|144, // 0x218  222.2hz Appx. A3  Sin
	0<<14|2<<12|136, // 0x219  235.3hz Appx. A#3 Sin
	0<<14|2<<12|129, // 0x21A  248.1hz Appx. B3  Sin
	0<<14|2<<12|121, // 0x21B  264.5hz Appx. C4  Sin
	0<<14|2<<12|114, // 0x21C  280.7hz Appx. C#4 Sin
	0<<14|2<<12|108, // 0x21D  296.3hz Appx. D4  Sin
	0<<14|2<<12|102, // 0x21E  313.7hz Appx. D#4 Sin
	0<<14|2<<12|96,  // 0x21F  333.3hz Appx. E4  Sin
	0<<14|2<<12|91,  // 0x220  351.6hz Appx. F4  Sin
	0<<14|2<<12|86,  // 0x221  372.1hz Appx. F#4 Sin
	0<<14|2<<12|81,  // 0x222  395.1hz Appx. G4  Sin
	0<<14|2<<12|76,  // 0x223  421.1hz Appx. G#4 Sin
	0<<14|2<<12|72,  // 0x224  444.4hz Appx. A4  Sin
	0<<14|2<<12|68,  // 0x225  470.6hz Appx. A#4 Sin
	0<<14|2<<12|64,  // 0x226  500.0hz Appx. B4  Sin
	0<<14|2<<12|61,  // 0x227  524.6hz Appx. C5  Sin
	0<<14|2<<12|57,  // 0x228  561.4hz Appx. C#5 Sin
	0<<14|2<<12|54,  // 0x229  592.6hz Appx. D5  Sin
	0<<14|2<<12|51,  // 0x22A  627.5hz Appx. D#5 Sin
	0<<14|2<<12|48,  // 0x22B  666.7hz Appx. E5  Sin
	0<<14|2<<12|46,  // 0x22C  695.7hz Appx. F5  Sin
	0<<14|2<<12|43,  // 0x22D  744.2hz Appx. F#5 Sin
	0<<14|2<<12|41,  // 0x22E  780.5hz Appx. G5  Sin
	0<<14|2<<12|38,  // 0x22F  842.1hz Appx. G#5 Sin
	0<<14|2<<12|36,  // 0x230  888.9hz Appx. A5  Sin
	0<<14|2<<12|34,  // 0x231  941.2hz Appx. A#5 Sin
	0<<14|2<<12|32,  // 0x232 1000.0hz Appx. B5  Sin
	0<<14|2<<12|30,  // 0x233 1066.7hz Appx. C6  Sin
	0<<14|2<<12|29,  // 0x234 1103.4hz Appx. C#6 Sin
	0<<14|2<<12|27,  // 0x235 1185.2hz Appx. D6  Sin
	0<<14|2<<12|26,  // 0x236 1230.8hz Appx. D#6 Sin
	0<<14|2<<12|24,  // 0x237 1333.3hz Appx. E6  Sin
	0<<14|2<<12|23,  // 0x238 1391.3hz Appx. F6  Sin
	0<<14|2<<12|22,  // 0x239 1454.5hz Appx. F#6 Sin
	0<<14|2<<12|20,  // 0x23A 1600.0hz Appx. G6  Sin
	0<<14|2<<12|19,  // 0x23B 1684.2hz Appx. G#6 Sin
	0<<14|2<<12|18,  // 0x23C 1777.8hz Appx. A6  Sin
	0<<14|2<<12|17,  // 0x23D 1882.4hz Appx. A#6 Sin
	0<<14|2<<12|16,  // 0x23E 2000.0hz Appx. B6  Sin
	0<<14|2<<12|15,  // 0x23F 2133.3hz Appx. C7  Sin

	1<<14|2<<12|581, // 0x240  55.08hz Appx. A1  Saw Tooth
	1<<14|2<<12|548, // 0x241  58.39hz Appx. A#1 Saw Tooth
	1<<14|2<<12|518, // 0x242  61.78hz Appx. B1  Saw Tooth
	1<<14|2<<12|489, // 0x243  65.44hz Appx. C2  Saw Tooth
	1<<14|2<<12|461, // 0x244  69.41hz Appx. C#2 Saw Tooth
	1<<14|2<<12|435, // 0x245  73.56hz Appx. D2  Saw Tooth
	1<<14|2<<12|411, // 0x246  77.86hz Appx. D#2 Saw Tooth
	1<<14|2<<12|388, // 0x247  82.47hz Appx. E2  Saw Tooth
	1<<14|2<<12|366, // 0x248  87.43hz Appx. F2  Saw Tooth
	1<<14|2<<12|345, // 0x249  92.75hz Appx. F#2 Saw Tooth
	1<<14|2<<12|326, // 0x24A  98.16hz Appx. G2  Saw Tooth
	1<<14|2<<12|308, // 0x24B  103.9hz Appx. G#2 Saw Tooth
	1<<14|2<<12|288, // 0x24C  111.1hz Appx. A2  Saw Tooth
	1<<14|2<<12|272, // 0x24D  117.6hz Appx. A#2 Saw Tooth
	1<<14|2<<12|257, // 0x24E  124.5hz Appx. B2  Saw Tooth
	1<<14|2<<12|242, // 0x24F  132.2hz Appx. C3  Saw Tooth
	1<<14|2<<12|229, // 0x250  139.7hz Appx. C#3 Saw Tooth
	1<<14|2<<12|216, // 0x251  148.1hz Appx. D3  Saw Tooth
	1<<14|2<<12|204, // 0x252  156.9hz Appx. D#3 Saw Tooth
	1<<14|2<<12|192, // 0x253  166.7hz Appx. E3  Saw Tooth
	1<<14|2<<12|181, // 0x254  176.8hz Appx. F3  Saw Tooth
	1<<14|2<<12|171, // 0x255  187.1hz Appx. F#3 Saw Tooth
	1<<14|2<<12|162, // 0x256  197.5hz Appx. G3  Saw Tooth
	1<<14|2<<12|153, // 0x257  209.2hz Appx. G#3 Saw Tooth
	1<<14|2<<12|144, // 0x258  222.2hz Appx. A3  Saw Tooth
	1<<14|2<<12|136, // 0x259  235.3hz Appx. A#3 Saw Tooth
	1<<14|2<<12|129, // 0x25A  248.1hz Appx. B3  Saw Tooth
	1<<14|2<<12|121, // 0x25B  264.5hz Appx. C4  Saw Tooth
	1<<14|2<<12|114, // 0x25C  280.7hz Appx. C#4 Saw Tooth
	1<<14|2<<12|108, // 0x25D  296.3hz Appx. D4  Saw Tooth
	1<<14|2<<12|102, // 0x25E  313.7hz Appx. D#4 Saw Tooth
	1<<14|2<<12|96,  // 0x25F  333.3hz Appx. E4  Saw Tooth
	1<<14|2<<12|91,  // 0x260  351.6hz Appx. F4  Saw Tooth
	1<<14|2<<12|86,  // 0x261  372.1hz Appx. F#4 Saw Tooth
	1<<14|2<<12|81,  // 0x262  395.1hz Appx. G4  Saw Tooth
	1<<14|2<<12|76,  // 0x263  421.1hz Appx. G#4 Saw Tooth
	1<<14|2<<12|72,  // 0x264  444.4hz Appx. A4  Saw Tooth
	1<<14|2<<12|68,  // 0x265  470.6hz Appx. A#4 Saw Tooth
	1<<14|2<<12|64,  // 0x266  500.0hz Appx. B4  Saw Tooth
	1<<14|2<<12|61,  // 0x267  524.6hz Appx. C5  Saw Tooth
	1<<14|2<<12|57,  // 0x268  561.4hz Appx. C#5 Saw Tooth
	1<<14|2<<12|54,  // 0x269  592.6hz Appx. D5  Saw Tooth
	1<<14|2<<12|51,  // 0x26A  627.5hz Appx. D#5 Saw Tooth
	1<<14|2<<12|48,  // 0x26B  666.7hz Appx. E5  Saw Tooth
	1<<14|2<<12|46,  // 0x26C  695.7hz Appx. F5  Saw Tooth
	1<<14|2<<12|43,  // 0x26D  744.2hz Appx. F#5 Saw Tooth
	1<<14|2<<12|41,  // 0x26E  780.5hz Appx. G5  Saw Tooth
	1<<14|2<<12|38,  // 0x26F  842.1hz Appx. G#5 Saw Tooth
	1<<14|2<<12|36,  // 0x270  888.9hz Appx. A5  Saw Tooth
	1<<14|2<<12|34,  // 0x271  941.2hz Appx. A#5 Saw Tooth
	1<<14|2<<12|32,  // 0x272 1000.0hz Appx. B5  Saw Tooth
	1<<14|2<<12|30,  // 0x273 1066.7hz Appx. C6  Saw Tooth
	1<<14|2<<12|29,  // 0x274 1103.4hz Appx. C#6 Saw Tooth
	1<<14|2<<12|27,  // 0x275 1185.2hz Appx. D6  Saw Tooth
	1<<14|2<<12|26,  // 0x276 1230.8hz Appx. D#6 Saw Tooth
	1<<14|2<<12|24,  // 0x277 1333.3hz Appx. E6  Saw Tooth
	1<<14|2<<12|23,  // 0x278 1391.3hz Appx. F6  Saw Tooth
	1<<14|2<<12|22,  // 0x279 1454.5hz Appx. F#6 Saw Tooth
	1<<14|2<<12|20,  // 0x27A 1600.0hz Appx. G6  Saw Tooth
	1<<14|2<<12|19,  // 0x27B 1684.2hz Appx. G#6 Saw Tooth
	1<<14|2<<12|18,  // 0x27C 1777.8hz Appx. A6  Saw Tooth
	1<<14|2<<12|17,  // 0x27D 1882.4hz Appx. A#6 Saw Tooth
	1<<14|2<<12|16,  // 0x27E 2000.0hz Appx. B6  Saw Tooth
	1<<14|2<<12|15,  // 0x27F 2133.3hz Appx. C7  Saw Tooth

	2<<14|2<<12|581, // 0x280  55.08hz Appx. A1  Square
	2<<14|2<<12|548, // 0x281  58.39hz Appx. A#1 Square
	2<<14|2<<12|518, // 0x282  61.78hz Appx. B1  Square
	2<<14|2<<12|489, // 0x283  65.44hz Appx. C2  Square
	2<<14|2<<12|461, // 0x284  69.41hz Appx. C#2 Square
	2<<14|2<<12|435, // 0x285  73.56hz Appx. D2  Square
	2<<14|2<<12|411, // 0x286  77.86hz Appx. D#2 Square
	2<<14|2<<12|388, // 0x287  82.47hz Appx. E2  Square
	2<<14|2<<12|366, // 0x288  87.43hz Appx. F2  Square
	2<<14|2<<12|345, // 0x289  92.75hz Appx. F#2 Square
	2<<14|2<<12|326, // 0x28A  98.16hz Appx. G2  Square
	2<<14|2<<12|308, // 0x28B  103.9hz Appx. G#2 Square
	2<<14|2<<12|288, // 0x28C  111.1hz Appx. A2  Square
	2<<14|2<<12|272, // 0x28D  117.6hz Appx. A#2 Square
	2<<14|2<<12|257, // 0x28E  124.5hz Appx. B2  Square
	2<<14|2<<12|242, // 0x28F  132.2hz Appx. C3  Square
	2<<14|2<<12|229, // 0x290  139.7hz Appx. C#3 Square
	2<<14|2<<12|216, // 0x291  148.1hz Appx. D3  Square
	2<<14|2<<12|204, // 0x292  156.9hz Appx. D#3 Square
	2<<14|2<<12|192, // 0x293  166.7hz Appx. E3  Square
	2<<14|2<<12|181, // 0x294  176.8hz Appx. F3  Square
	2<<14|2<<12|171, // 0x295  187.1hz Appx. F#3 Square
	2<<14|2<<12|162, // 0x296  197.5hz Appx. G3  Square
	2<<14|2<<12|153, // 0x297  209.2hz Appx. G#3 Square
	2<<14|2<<12|144, // 0x298  222.2hz Appx. A3  Square
	2<<14|2<<12|136, // 0x299  235.3hz Appx. A#3 Square
	2<<14|2<<12|129, // 0x29A  248.1hz Appx. B3  Square
	2<<14|2<<12|121, // 0x29B  264.5hz Appx. C4  Square
	2<<14|2<<12|114, // 0x29C  280.7hz Appx. C#4 Square
	2<<14|2<<12|108, // 0x29D  296.3hz Appx. D4  Square
	2<<14|2<<12|102, // 0x29E  313.7hz Appx. D#4 Square
	2<<14|2<<12|96,  // 0x29F  333.3hz Appx. E4  Square
	2<<14|2<<12|91,  // 0x2A0  351.6hz Appx. F4  Square
	2<<14|2<<12|86,  // 0x2A1  372.1hz Appx. F#4 Square
	2<<14|2<<12|81,  // 0x2A2  395.1hz Appx. G4  Square
	2<<14|2<<12|76,  // 0x2A3  421.1hz Appx. G#4 Square
	2<<14|2<<12|72,  // 0x2A4  444.4hz Appx. A4  Square
	2<<14|2<<12|68,  // 0x2A5  470.6hz Appx. A#4 Square
	2<<14|2<<12|64,  // 0x2A6  500.0hz Appx. B4  Square
	2<<14|2<<12|61,  // 0x2A7  524.6hz Appx. C5  Square
	2<<14|2<<12|57,  // 0x2A8  561.4hz Appx. C#5 Square
	2<<14|2<<12|54,  // 0x2A9  592.6hz Appx. D5  Square
	2<<14|2<<12|51,  // 0x2AA  627.5hz Appx. D#5 Square
	2<<14|2<<12|48,  // 0x2AB  666.7hz Appx. E5  Square
	2<<14|2<<12|46,  // 0x2AC  695.7hz Appx. F5  Square
	2<<14|2<<12|43,  // 0x2AD  744.2hz Appx. F#5 Square
	2<<14|2<<12|41,  // 0x2AE  780.5hz Appx. G5  Square
	2<<14|2<<12|38,  // 0x2AF  842.1hz Appx. G#5 Square
	2<<14|2<<12|36,  // 0x2B0  888.9hz Appx. A5  Square
	2<<14|2<<12|34,  // 0x2B1  941.2hz Appx. A#5 Square
	2<<14|2<<12|32,  // 0x2B2 1000.0hz Appx. B5  Square
	2<<14|2<<12|30,  // 0x2B3 1066.7hz Appx. C6  Square
	2<<14|2<<12|29,  // 0x2B4 1103.4hz Appx. C#6 Square
	2<<14|2<<12|27,  // 0x2B5 1185.2hz Appx. D6  Square
	2<<14|2<<12|26,  // 0x2B6 1230.8hz Appx. D#6 Square
	2<<14|2<<12|24,  // 0x2B7 1333.3hz Appx. E6  Square
	2<<14|2<<12|23,  // 0x2B8 1391.3hz Appx. F6  Square
	2<<14|2<<12|22,  // 0x2B9 1454.5hz Appx. F#6 Square
	2<<14|2<<12|20,  // 0x2BA 1600.0hz Appx. G6  Square
	2<<14|2<<12|19,  // 0x2BB 1684.2hz Appx. G#6 Square
	2<<14|2<<12|18,  // 0x2BC 1777.8hz Appx. A6  Square
	2<<14|2<<12|17,  // 0x2BD 1882.4hz Appx. A#6 Square
	2<<14|2<<12|16,  // 0x2BE 2000.0hz Appx. B6  Square
	2<<14|2<<12|15,  // 0x2BF 2133.3hz Appx. C7  Square

	3<<14|2<<12|581, // 0x2C0  55.08hz Appx. A1  Noise
	3<<14|2<<12|548, // 0x2C1  58.39hz Appx. A#1 Noise
	3<<14|2<<12|518, // 0x2C2  61.78hz Appx. B1  Noise
	3<<14|2<<12|489, // 0x2C3  65.44hz Appx. C2  Noise
	3<<14|2<<12|461, // 0x2C4  69.41hz Appx. C#2 Noise
	3<<14|2<<12|435, // 0x2C5  73.56hz Appx. D2  Noise
	3<<14|2<<12|411, // 0x2C6  77.86hz Appx. D#2 Noise
	3<<14|2<<12|388, // 0x2C7  82.47hz Appx. E2  Noise
	3<<14|2<<12|366, // 0x2C8  87.43hz Appx. F2  Noise
	3<<14|2<<12|345, // 0x2C9  92.75hz Appx. F#2 Noise
	3<<14|2<<12|326, // 0x2CA  98.16hz Appx. G2  Noise
	3<<14|2<<12|308, // 0x2CB  103.9hz Appx. G#2 Noise
	3<<14|2<<12|288, // 0x2CC  111.1hz Appx. A2  Noise
	3<<14|2<<12|272, // 0x2CD  117.6hz Appx. A#2 Noise
	3<<14|2<<12|257, // 0x2CE  124.5hz Appx. B2  Noise
	3<<14|2<<12|242, // 0x2CF  132.2hz Appx. C3  Noise
	3<<14|2<<12|229, // 0x2D0  139.7hz Appx. C#3 Noise
	3<<14|2<<12|216, // 0x2D1  148.1hz Appx. D3  Noise
	3<<14|2<<12|204, // 0x2D2  156.9hz Appx. D#3 Noise
	3<<14|2<<12|192, // 0x2D3  166.7hz Appx. E3  Noise
	3<<14|2<<12|181, // 0x2D4  176.8hz Appx. F3  Noise
	3<<14|2<<12|171, // 0x2D5  187.1hz Appx. F#3 Noise
	3<<14|2<<12|162, // 0x2D6  197.5hz Appx. G3  Noise
	3<<14|2<<12|153, // 0x2D7  209.2hz Appx. G#3 Noise
	3<<14|2<<12|144, // 0x2D8  222.2hz Appx. A3  Noise
	3<<14|2<<12|136, // 0x2D9  235.3hz Appx. A#3 Noise
	3<<14|2<<12|129, // 0x2DA  248.1hz Appx. B3  Noise
	3<<14|2<<12|121, // 0x2DB  264.5hz Appx. C4  Noise
	3<<14|2<<12|114, // 0x2DC  280.7hz Appx. C#4 Noise
	3<<14|2<<12|108, // 0x2DD  296.3hz Appx. D4  Noise
	3<<14|2<<12|102, // 0x2DE  313.7hz Appx. D#4 Noise
	3<<14|2<<12|96,  // 0x2DF  333.3hz Appx. E4  Noise
	3<<14|2<<12|91,  // 0x2E0  351.6hz Appx. F4  Noise
	3<<14|2<<12|86,  // 0x2E1  372.1hz Appx. F#4 Noise
	3<<14|2<<12|81,  // 0x2E2  395.1hz Appx. G4  Noise
	3<<14|2<<12|76,  // 0x2E3  421.1hz Appx. G#4 Noise
	3<<14|2<<12|72,  // 0x2E4  444.4hz Appx. A4  Noise
	3<<14|2<<12|68,  // 0x2E5  470.6hz Appx. A#4 Noise
	3<<14|2<<12|64,  // 0x2E6  500.0hz Appx. B4  Noise
	3<<14|2<<12|61,  // 0x2E7  524.6hz Appx. C5  Noise
	3<<14|2<<12|57,  // 0x2E8  561.4hz Appx. C#5 Noise
	3<<14|2<<12|54,  // 0x2E9  592.6hz Appx. D5  Noise
	3<<14|2<<12|51,  // 0x2EA  627.5hz Appx. D#5 Noise
	3<<14|2<<12|48,  // 0x2EB  666.7hz Appx. E5  Noise
	3<<14|2<<12|46,  // 0x2EC  695.7hz Appx. F5  Noise
	3<<14|2<<12|43,  // 0x2ED  744.2hz Appx. F#5 Noise
	3<<14|2<<12|41,  // 0x2EE  780.5hz Appx. G5  Noise
	3<<14|2<<12|38,  // 0x2EF  842.1hz Appx. G#5 Noise
	3<<14|2<<12|36,  // 0x2F0  888.9hz Appx. A5  Noise
	3<<14|2<<12|34,  // 0x2F1  941.2hz Appx. A#5 Noise
	3<<14|2<<12|32,  // 0x2F2 1000.0hz Appx. B5  Noise
	3<<14|2<<12|30,  // 0x2F3 1066.7hz Appx. C6  Noise
	3<<14|2<<12|29,  // 0x2F4 1103.4hz Appx. C#6 Noise
	3<<14|2<<12|27,  // 0x2F5 1185.2hz Appx. D6  Noise
	3<<14|2<<12|26,  // 0x2F6 1230.8hz Appx. D#6 Noise
	3<<14|2<<12|24,  // 0x2F7 1333.3hz Appx. E6  Noise
	3<<14|2<<12|23,  // 0x2F8 1391.3hz Appx. F6  Noise
	3<<14|2<<12|22,  // 0x2F9 1454.5hz Appx. F#6 Noise
	3<<14|2<<12|20,  // 0x2FA 1600.0hz Appx. G6  Noise
	3<<14|2<<12|19,  // 0x2FB 1684.2hz Appx. G#6 Noise
	3<<14|2<<12|18,  // 0x2FC 1777.8hz Appx. A6  Noise
	3<<14|2<<12|17,  // 0x2FD 1882.4hz Appx. A#6 Noise
	3<<14|2<<12|16,  // 0x2FE 2000.0hz Appx. B6  Noise
	3<<14|2<<12|15,  // 0x2FF 2133.3hz Appx. C7  Noise

	/* High Tones Big */

	2<<14|0<<12|14,  // 0x300 2285.7hz Appx. C#7 Square
	2<<14|0<<12|13,  // 0x301 2461.5hz Appx. D#7 Square
	2<<14|0<<12|12,  // 0x302 2666.6hz Appx. E7  Square
	2<<14|0<<12|11,  // 0x303 2909.1hz Appx. F7  Square
	2<<14|0<<12|10,  // 0x304 3200,0hz Appx. G7  Square
	2<<14|0<<12|9,   // 0x305 3555.6hz Appx. A7  Square
	2<<14|0<<12|8,   // 0x306 4000.0hz Appx. B7  Square
	2<<14|0<<12|7,   // 0x307 4571.4hz Appx. C#8 Square
	2<<14|0<<12|6,   // 0x308 5333.3hz Appx. E8  Square
	2<<14|0<<12|5,   // 0x309 6400.0hz Appx. G8  Square
	2<<14|0<<12|4,   // 0x30A 8000.0hz Appx. B8  Square
	2<<14|0<<12|3,   // 0x30B 10666.7hz Square

	/* High Tones Middle */

	2<<14|1<<12|14,  // 0x30C 2285.7hz Appx. C#7 Square
	2<<14|1<<12|13,  // 0x30D 2461.5hz Appx. D#7 Square
	2<<14|1<<12|12,  // 0x30E 2666.6hz Appx. E7  Square
	2<<14|1<<12|11,  // 0x30F 2909.1hz Appx. F7  Square
	2<<14|1<<12|10,  // 0x310 3200,0hz Appx. G7  Square
	2<<14|1<<12|9,   // 0x311 3555.6hz Appx. A7  Square
	2<<14|1<<12|8,   // 0x312 4000.0hz Appx. B7  Square
	2<<14|1<<12|7,   // 0x313 4571.4hz Appx. C#8 Square
	2<<14|1<<12|6,   // 0x314 5333.3hz Appx. E8  Square
	2<<14|1<<12|5,   // 0x315 6400.0hz Appx. G8  Square
	2<<14|1<<12|4,   // 0x316 8000.0hz Appx. B8  Square
	2<<14|1<<12|3,   // 0x317 10666.7hz Square

	/* High Tones Small */

	2<<14|2<<12|14,  // 0x318 2285.7hz Appx. C#7 Square
	2<<14|2<<12|13,  // 0x319 2461.5hz Appx. D#7 Square
	2<<14|2<<12|12,  // 0x31A 2666.6hz Appx. E7  Square
	2<<14|2<<12|11,  // 0x31B 2909.1hz Appx. F7  Square
	2<<14|2<<12|10,  // 0x31C 3200,0hz Appx. G7  Square
	2<<14|2<<12|9,   // 0x31D 3555.6hz Appx. A7  Square
	2<<14|2<<12|8,   // 0x31E 4000.0hz Appx. B7  Square
	2<<14|2<<12|7,   // 0x31F 4571.4hz Appx. C#8 Square
	2<<14|2<<12|6,   // 0x320 5333.3hz Appx. E8  Square
	2<<14|2<<12|5,   // 0x321 6400.0hz Appx. G8  Square
	2<<14|2<<12|4,   // 0x322 8000.0hz Appx. B8  Square
	2<<14|2<<12|3,   // 0x323 10666.7hz Square

	/* Special Sounds */

	2<<14|3<<12|36,  // 0x324 Silence 
	3<<14|0<<12|0,   // 0x325 Long Noise Big

	0                // End of Index
};
 

#define A1_SINL  0x00
#define AS1_SINL 0x01
#define B1_SINL  0x02
#define C2_SINL  0x03
#define CS2_SINL 0x04
#define D2_SINL  0x05
#define DS2_SINL 0x06
#define E2_SINL  0x07
#define F2_SINL  0x08
#define FS2_SINL 0x09
#define G2_SINL  0x0A
#define GS2_SINL 0x0B
#define A2_SINL  0x0C
#define AS2_SINL 0x0D
#define B2_SINL  0x0E
#define C3_SINL  0x0F
#define CS3_SINL 0x10
#define D3_SINL  0x11
#define DS3_SINL 0x12
#define E3_SINL  0x13
#define F3_SINL  0x14
#define FS3_SINL 0x15
#define G3_SINL  0x16
#define GS3_SINL 0x17
#define A3_SINL  0x18
#define AS3_SINL 0x19
#define B3_SINL  0x1A
#define C4_SINL  0x1B
#define CS4_SINL 0x1C
#define D4_SINL  0x1D
#define DS4_SINL 0x1E
#define E4_SINL  0x1F
#define F4_SINL  0x20
#define FS4_SINL 0x21
#define G4_SINL  0x22
#define GS4_SINL 0x23
#define A4_SINL  0x24
#define AS4_SINL 0x25
#define B4_SINL  0x26
#define C5_SINL  0x27
#define CS5_SINL 0x28
#define D5_SINL  0x29
#define DS5_SINL 0x2A
#define E5_SINL  0x2B
#define F5_SINL  0x2C
#define FS5_SINL 0x2D
#define G5_SINL  0x2E
#define GS5_SINL 0x2F
#define A5_SINL  0x30
#define AS5_SINL 0x31
#define B5_SINL  0x32
#define C6_SINL  0x33
#define CS6_SINL 0x34
#define D6_SINL  0x35
#define DS6_SINL 0x36
#define E6_SINL  0x37
#define F6_SINL  0x38
#define FS6_SINL 0x39
#define G6_SINL  0x3A
#define GS6_SINL 0x3B
#define A6_SINL  0x3C
#define AS6_SINL 0x3D
#define B6_SINL  0x3E
#define C7_SINL  0x3F

#define A1_TRIL  0x40
#define AS1_TRIL 0x41
#define B1_TRIL  0x42
#define C2_TRIL  0x43
#define CS2_TRIL 0x44
#define D2_TRIL  0x45
#define DS2_TRIL 0x46
#define E2_TRIL  0x47
#define F2_TRIL  0x48
#define FS2_TRIL 0x49
#define G2_TRIL  0x4A
#define GS2_TRIL 0x4B
#define A2_TRIL  0x4C
#define AS2_TRIL 0x4D
#define B2_TRIL  0x4E
#define C3_TRIL  0x4F
#define CS3_TRIL 0x50
#define D3_TRIL  0x51
#define DS3_TRIL 0x52
#define E3_TRIL  0x53
#define F3_TRIL  0x54
#define FS3_TRIL 0x55
#define G3_TRIL  0x56
#define GS3_TRIL 0x57
#define A3_TRIL  0x58
#define AS3_TRIL 0x59
#define B3_TRIL  0x5A
#define C4_TRIL  0x5B
#define CS4_TRIL 0x5C
#define D4_TRIL  0x5D
#define DS4_TRIL 0x5E
#define E4_TRIL  0x5F
#define F4_TRIL  0x60
#define FS4_TRIL 0x61
#define G4_TRIL  0x62
#define GS4_TRIL 0x63
#define A4_TRIL  0x64
#define AS4_TRIL 0x65
#define B4_TRIL  0x66
#define C5_TRIL  0x67
#define CS5_TRIL 0x68
#define D5_TRIL  0x69
#define DS5_TRIL 0x6A
#define E5_TRIL  0x6B
#define F5_TRIL  0x6C
#define FS5_TRIL 0x6D
#define G5_TRIL  0x6E
#define GS5_TRIL 0x6F
#define A5_TRIL  0x70
#define AS5_TRIL 0x71
#define B5_TRIL  0x72
#define C6_TRIL  0x73
#define CS6_TRIL 0x74
#define D6_TRIL  0x75
#define DS6_TRIL 0x76
#define E6_TRIL  0x77
#define F6_TRIL  0x78
#define FS6_TRIL 0x79
#define G6_TRIL  0x7A
#define GS6_TRIL 0x7B
#define A6_TRIL  0x7C
#define AS6_TRIL 0x7D
#define B6_TRIL  0x7E
#define C7_TRIL  0x7F

#define A1_SQUL  0x80
#define AS1_SQUL 0x81
#define B1_SQUL  0x82
#define C2_SQUL  0x83
#define CS2_SQUL 0x84
#define D2_SQUL  0x85
#define DS2_SQUL 0x86
#define E2_SQUL  0x87
#define F2_SQUL  0x88
#define FS2_SQUL 0x89
#define G2_SQUL  0x8A
#define GS2_SQUL 0x8B
#define A2_SQUL  0x8C
#define AS2_SQUL 0x8D
#define B2_SQUL  0x8E
#define C3_SQUL  0x8F
#define CS3_SQUL 0x90
#define D3_SQUL  0x91
#define DS3_SQUL 0x92
#define E3_SQUL  0x93
#define F3_SQUL  0x94
#define FS3_SQUL 0x95
#define G3_SQUL  0x96
#define GS3_SQUL 0x97
#define A3_SQUL  0x98
#define AS3_SQUL 0x99
#define B3_SQUL  0x9A
#define C4_SQUL  0x9B
#define CS4_SQUL 0x9C
#define D4_SQUL  0x9D
#define DS4_SQUL 0x9E
#define E4_SQUL  0x9F
#define F4_SQUL  0xA0
#define FS4_SQUL 0xA1
#define G4_SQUL  0xA2
#define GS4_SQUL 0xA3
#define A4_SQUL  0xA4
#define AS4_SQUL 0xA5
#define B4_SQUL  0xA6
#define C5_SQUL  0xA7
#define CS5_SQUL 0xA8
#define D5_SQUL  0xA9
#define DS5_SQUL 0xAA
#define E5_SQUL  0xAB
#define F5_SQUL  0xAC
#define FS5_SQUL 0xAD
#define G5_SQUL  0xAE
#define GS5_SQUL 0xAF
#define A5_SQUL  0xB0
#define AS5_SQUL 0xB1
#define B5_SQUL  0xB2
#define C6_SQUL  0xB3
#define CS6_SQUL 0xB4
#define D6_SQUL  0xB5
#define DS6_SQUL 0xB6
#define E6_SQUL  0xB7
#define F6_SQUL  0xB8
#define FS6_SQUL 0xB9
#define G6_SQUL  0xBA
#define GS6_SQUL 0xBB
#define A6_SQUL  0xBC
#define AS6_SQUL 0xBD
#define B6_SQUL  0xBE
#define C7_SQUL  0xBF

#define A1_NOIL  0xC0
#define AS1_NOIL 0xC1
#define B1_NOIL  0xC2
#define C2_NOIL  0xC3
#define CS2_NOIL 0xC4
#define D2_NOIL  0xC5
#define DS2_NOIL 0xC6
#define E2_NOIL  0xC7
#define F2_NOIL  0xC8
#define FS2_NOIL 0xC9
#define G2_NOIL  0xCA
#define GS2_NOIL 0xCB
#define A2_NOIL  0xCC
#define AS2_NOIL 0xCD
#define B2_NOIL  0xCE
#define C3_NOIL  0xCF
#define CS3_NOIL 0xD0
#define D3_NOIL  0xD1
#define DS3_NOIL 0xD2
#define E3_NOIL  0xD3
#define F3_NOIL  0xD4
#define FS3_NOIL 0xD5
#define G3_NOIL  0xD6
#define GS3_NOIL 0xD7
#define A3_NOIL  0xD8
#define AS3_NOIL 0xD9
#define B3_NOIL  0xDA
#define C4_NOIL  0xDB
#define CS4_NOIL 0xDC
#define D4_NOIL  0xDD
#define DS4_NOIL 0xDE
#define E4_NOIL  0xDF
#define F4_NOIL  0xE0
#define FS4_NOIL 0xE1
#define G4_NOIL  0xE2
#define GS4_NOIL 0xE3
#define A4_NOIL  0xE4
#define AS4_NOIL 0xE5
#define B4_NOIL  0xE6
#define C5_NOIL  0xE7
#define CS5_NOIL 0xE8
#define D5_NOIL  0xE9
#define DS5_NOIL 0xEA
#define E5_NOIL  0xEB
#define F5_NOIL  0xEC
#define FS5_NOIL 0xED
#define G5_NOIL  0xEE
#define GS5_NOIL 0xEF
#define A5_NOIL  0xF0
#define AS5_NOIL 0xF1
#define B5_NOIL  0xF2
#define C6_NOIL  0xF3
#define CS6_NOIL 0xF4
#define D6_NOIL  0xF5
#define DS6_NOIL 0xF6
#define E6_NOIL  0xF7
#define F6_NOIL  0xF8
#define FS6_NOIL 0xF9
#define G6_NOIL  0xFA
#define GS6_NOIL 0xFB
#define A6_NOIL  0xFC
#define AS6_NOIL 0xFD
#define B6_NOIL  0xFE
#define C7_NOIL  0xFF

#define A1_SINM  0x100
#define AS1_SINM 0x101
#define B1_SINM  0x102
#define C2_SINM  0x103
#define CS2_SINM 0x104
#define D2_SINM  0x105
#define DS2_SINM 0x106
#define E2_SINM  0x107
#define F2_SINM  0x108
#define FS2_SINM 0x109
#define G2_SINM  0x10A
#define GS2_SINM 0x10B
#define A2_SINM  0x10C
#define AS2_SINM 0x10D
#define B2_SINM  0x10E
#define C3_SINM  0x10F
#define CS3_SINM 0x110
#define D3_SINM  0x111
#define DS3_SINM 0x112
#define E3_SINM  0x113
#define F3_SINM  0x114
#define FS3_SINM 0x115
#define G3_SINM  0x116
#define GS3_SINM 0x117
#define A3_SINM  0x118
#define AS3_SINM 0x119
#define B3_SINM  0x11A
#define C4_SINM  0x11B
#define CS4_SINM 0x11C
#define D4_SINM  0x11D
#define DS4_SINM 0x11E
#define E4_SINM  0x11F
#define F4_SINM  0x120
#define FS4_SINM 0x121
#define G4_SINM  0x122
#define GS4_SINM 0x123
#define A4_SINM  0x124
#define AS4_SINM 0x125
#define B4_SINM  0x126
#define C5_SINM  0x127
#define CS5_SINM 0x128
#define D5_SINM  0x129
#define DS5_SINM 0x12A
#define E5_SINM  0x12B
#define F5_SINM  0x12C
#define FS5_SINM 0x12D
#define G5_SINM  0x12E
#define GS5_SINM 0x12F
#define A5_SINM  0x130
#define AS5_SINM 0x131
#define B5_SINM  0x132
#define C6_SINM  0x133
#define CS6_SINM 0x134
#define D6_SINM  0x135
#define DS6_SINM 0x136
#define E6_SINM  0x137
#define F6_SINM  0x138
#define FS6_SINM 0x139
#define G6_SINM  0x13A
#define GS6_SINM 0x13B
#define A6_SINM  0x13C
#define AS6_SINM 0x13D
#define B6_SINM  0x13E
#define C7_SINM  0x13F

#define A1_TRIM  0x140
#define AS1_TRIM 0x141
#define B1_TRIM  0x142
#define C2_TRIM  0x143
#define CS2_TRIM 0x144
#define D2_TRIM  0x145
#define DS2_TRIM 0x146
#define E2_TRIM  0x147
#define F2_TRIM  0x148
#define FS2_TRIM 0x149
#define G2_TRIM  0x14A
#define GS2_TRIM 0x14B
#define A2_TRIM  0x14C
#define AS2_TRIM 0x14D
#define B2_TRIM  0x14E
#define C3_TRIM  0x14F
#define CS3_TRIM 0x150
#define D3_TRIM  0x151
#define DS3_TRIM 0x152
#define E3_TRIM  0x153
#define F3_TRIM  0x154
#define FS3_TRIM 0x155
#define G3_TRIM  0x156
#define GS3_TRIM 0x157
#define A3_TRIM  0x158
#define AS3_TRIM 0x159
#define B3_TRIM  0x15A
#define C4_TRIM  0x15B
#define CS4_TRIM 0x15C
#define D4_TRIM  0x15D
#define DS4_TRIM 0x15E
#define E4_TRIM  0x15F
#define F4_TRIM  0x160
#define FS4_TRIM 0x161
#define G4_TRIM  0x162
#define GS4_TRIM 0x163
#define A4_TRIM  0x164
#define AS4_TRIM 0x165
#define B4_TRIM  0x166
#define C5_TRIM  0x167
#define CS5_TRIM 0x168
#define D5_TRIM  0x169
#define DS5_TRIM 0x16A
#define E5_TRIM  0x16B
#define F5_TRIM  0x16C
#define FS5_TRIM 0x16D
#define G5_TRIM  0x16E
#define GS5_TRIM 0x16F
#define A5_TRIM  0x170
#define AS5_TRIM 0x171
#define B5_TRIM  0x172
#define C6_TRIM  0x173
#define CS6_TRIM 0x174
#define D6_TRIM  0x175
#define DS6_TRIM 0x176
#define E6_TRIM  0x177
#define F6_TRIM  0x178
#define FS6_TRIM 0x179
#define G6_TRIM  0x17A
#define GS6_TRIM 0x17B
#define A6_TRIM  0x17C
#define AS6_TRIM 0x17D
#define B6_TRIM  0x17E
#define C7_TRIM  0x17F

#define A1_SQUM  0x180
#define AS1_SQUM 0x181
#define B1_SQUM  0x182
#define C2_SQUM  0x183
#define CS2_SQUM 0x184
#define D2_SQUM  0x185
#define DS2_SQUM 0x186
#define E2_SQUM  0x187
#define F2_SQUM  0x188
#define FS2_SQUM 0x189
#define G2_SQUM  0x18A
#define GS2_SQUM 0x18B
#define A2_SQUM  0x18C
#define AS2_SQUM 0x18D
#define B2_SQUM  0x18E
#define C3_SQUM  0x18F
#define CS3_SQUM 0x190
#define D3_SQUM  0x191
#define DS3_SQUM 0x192
#define E3_SQUM  0x193
#define F3_SQUM  0x194
#define FS3_SQUM 0x195
#define G3_SQUM  0x196
#define GS3_SQUM 0x197
#define A3_SQUM  0x198
#define AS3_SQUM 0x199
#define B3_SQUM  0x19A
#define C4_SQUM  0x19B
#define CS4_SQUM 0x19C
#define D4_SQUM  0x19D
#define DS4_SQUM 0x19E
#define E4_SQUM  0x19F
#define F4_SQUM  0x1A0
#define FS4_SQUM 0x1A1
#define G4_SQUM  0x1A2
#define GS4_SQUM 0x1A3
#define A4_SQUM  0x1A4
#define AS4_SQUM 0x1A5
#define B4_SQUM  0x1A6
#define C5_SQUM  0x1A7
#define CS5_SQUM 0x1A8
#define D5_SQUM  0x1A9
#define DS5_SQUM 0x1AA
#define E5_SQUM  0x1AB
#define F5_SQUM  0x1AC
#define FS5_SQUM 0x1AD
#define G5_SQUM  0x1AE
#define GS5_SQUM 0x1AF
#define A5_SQUM  0x1B0
#define AS5_SQUM 0x1B1
#define B5_SQUM  0x1B2
#define C6_SQUM  0x1B3
#define CS6_SQUM 0x1B4
#define D6_SQUM  0x1B5
#define DS6_SQUM 0x1B6
#define E6_SQUM  0x1B7
#define F6_SQUM  0x1B8
#define FS6_SQUM 0x1B9
#define G6_SQUM  0x1BA
#define GS6_SQUM 0x1BB
#define A6_SQUM  0x1BC
#define AS6_SQUM 0x1BD
#define B6_SQUM  0x1BE
#define C7_SQUM  0x1BF

#define A1_NOIM  0x1C0
#define AS1_NOIM 0x1C1
#define B1_NOIM  0x1C2
#define C2_NOIM  0x1C3
#define CS2_NOIM 0x1C4
#define D2_NOIM  0x1C5
#define DS2_NOIM 0x1C6
#define E2_NOIM  0x1C7
#define F2_NOIM  0x1C8
#define FS2_NOIM 0x1C9
#define G2_NOIM  0x1CA
#define GS2_NOIM 0x1CB
#define A2_NOIM  0x1CC
#define AS2_NOIM 0x1CD
#define B2_NOIM  0x1CE
#define C3_NOIM  0x1CF
#define CS3_NOIM 0x1D0
#define D3_NOIM  0x1D1
#define DS3_NOIM 0x1D2
#define E3_NOIM  0x1D3
#define F3_NOIM  0x1D4
#define FS3_NOIM 0x1D5
#define G3_NOIM  0x1D6
#define GS3_NOIM 0x1D7
#define A3_NOIM  0x1D8
#define AS3_NOIM 0x1D9
#define B3_NOIM  0x1DA
#define C4_NOIM  0x1DB
#define CS4_NOIM 0x1DC
#define D4_NOIM  0x1DD
#define DS4_NOIM 0x1DE
#define E4_NOIM  0x1DF
#define F4_NOIM  0x1E0
#define FS4_NOIM 0x1E1
#define G4_NOIM  0x1E2
#define GS4_NOIM 0x1E3
#define A4_NOIM  0x1E4
#define AS4_NOIM 0x1E5
#define B4_NOIM  0x1E6
#define C5_NOIM  0x1E7
#define CS5_NOIM 0x1E8
#define D5_NOIM  0x1E9
#define DS5_NOIM 0x1EA
#define E5_NOIM  0x1EB
#define F5_NOIM  0x1EC
#define FS5_NOIM 0x1ED
#define G5_NOIM  0x1EE
#define GS5_NOIM 0x1EF
#define A5_NOIM  0x1F0
#define AS5_NOIM 0x1F1
#define B5_NOIM  0x1F2
#define C6_NOIM  0x1F3
#define CS6_NOIM 0x1F4
#define D6_NOIM  0x1F5
#define DS6_NOIM 0x1F6
#define E6_NOIM  0x1F7
#define F6_NOIM  0x1F8
#define FS6_NOIM 0x1F9
#define G6_NOIM  0x1FA
#define GS6_NOIM 0x1FB
#define A6_NOIM  0x1FC
#define AS6_NOIM 0x1FD
#define B6_NOIM  0x1FE
#define C7_NOIM  0x1FF

#define A1_SINS  0x200
#define AS1_SINS 0x201
#define B1_SINS  0x202
#define C2_SINS  0x203
#define CS2_SINS 0x204
#define D2_SINS  0x205
#define DS2_SINS 0x206
#define E2_SINS  0x207
#define F2_SINS  0x208
#define FS2_SINS 0x209
#define G2_SINS  0x20A
#define GS2_SINS 0x20B
#define A2_SINS  0x20C
#define AS2_SINS 0x20D
#define B2_SINS  0x20E
#define C3_SINS  0x20F
#define CS3_SINS 0x210
#define D3_SINS  0x211
#define DS3_SINS 0x212
#define E3_SINS  0x213
#define F3_SINS  0x214
#define FS3_SINS 0x215
#define G3_SINS  0x216
#define GS3_SINS 0x217
#define A3_SINS  0x218
#define AS3_SINS 0x219
#define B3_SINS  0x21A
#define C4_SINS  0x21B
#define CS4_SINS 0x21C
#define D4_SINS  0x21D
#define DS4_SINS 0x21E
#define E4_SINS  0x21F
#define F4_SINS  0x220
#define FS4_SINS 0x221
#define G4_SINS  0x222
#define GS4_SINS 0x223
#define A4_SINS  0x224
#define AS4_SINS 0x225
#define B4_SINS  0x226
#define C5_SINS  0x227
#define CS5_SINS 0x228
#define D5_SINS  0x229
#define DS5_SINS 0x22A
#define E5_SINS  0x22B
#define F5_SINS  0x22C
#define FS5_SINS 0x22D
#define G5_SINS  0x22E
#define GS5_SINS 0x22F
#define A5_SINS  0x230
#define AS5_SINS 0x231
#define B5_SINS  0x232
#define C6_SINS  0x233
#define CS6_SINS 0x234
#define D6_SINS  0x235
#define DS6_SINS 0x236
#define E6_SINS  0x237
#define F6_SINS  0x238
#define FS6_SINS 0x239
#define G6_SINS  0x23A
#define GS6_SINS 0x23B
#define A6_SINS  0x23C
#define AS6_SINS 0x23D
#define B6_SINS  0x23E
#define C7_SINS  0x23F

#define A1_TRIS  0x240
#define AS1_TRIS 0x241
#define B1_TRIS  0x242
#define C2_TRIS  0x243
#define CS2_TRIS 0x244
#define D2_TRIS  0x245
#define DS2_TRIS 0x246
#define E2_TRIS  0x247
#define F2_TRIS  0x248
#define FS2_TRIS 0x249
#define G2_TRIS  0x24A
#define GS2_TRIS 0x24B
#define A2_TRIS  0x24C
#define AS2_TRIS 0x24D
#define B2_TRIS  0x24E
#define C3_TRIS  0x24F
#define CS3_TRIS 0x250
#define D3_TRIS  0x251
#define DS3_TRIS 0x252
#define E3_TRIS  0x253
#define F3_TRIS  0x254
#define FS3_TRIS 0x255
#define G3_TRIS  0x256
#define GS3_TRIS 0x257
#define A3_TRIS  0x258
#define AS3_TRIS 0x259
#define B3_TRIS  0x25A
#define C4_TRIS  0x25B
#define CS4_TRIS 0x25C
#define D4_TRIS  0x25D
#define DS4_TRIS 0x25E
#define E4_TRIS  0x25F
#define F4_TRIS  0x260
#define FS4_TRIS 0x261
#define G4_TRIS  0x262
#define GS4_TRIS 0x263
#define A4_TRIS  0x264
#define AS4_TRIS 0x265
#define B4_TRIS  0x266
#define C5_TRIS  0x267
#define CS5_TRIS 0x268
#define D5_TRIS  0x269
#define DS5_TRIS 0x26A
#define E5_TRIS  0x26B
#define F5_TRIS  0x26C
#define FS5_TRIS 0x26D
#define G5_TRIS  0x26E
#define GS5_TRIS 0x26F
#define A5_TRIS  0x270
#define AS5_TRIS 0x271
#define B5_TRIS  0x272
#define C6_TRIS  0x273
#define CS6_TRIS 0x274
#define D6_TRIS  0x275
#define DS6_TRIS 0x276
#define E6_TRIS  0x277
#define F6_TRIS  0x278
#define FS6_TRIS 0x279
#define G6_TRIS  0x27A
#define GS6_TRIS 0x27B
#define A6_TRIS  0x27C
#define AS6_TRIS 0x27D
#define B6_TRIS  0x27E
#define C7_TRIS  0x27F

#define A1_SQUS  0x280
#define AS1_SQUS 0x281
#define B1_SQUS  0x282
#define C2_SQUS  0x283
#define CS2_SQUS 0x284
#define D2_SQUS  0x285
#define DS2_SQUS 0x286
#define E2_SQUS  0x287
#define F2_SQUS  0x288
#define FS2_SQUS 0x289
#define G2_SQUS  0x28A
#define GS2_SQUS 0x28B
#define A2_SQUS  0x28C
#define AS2_SQUS 0x28D
#define B2_SQUS  0x28E
#define C3_SQUS  0x28F
#define CS3_SQUS 0x290
#define D3_SQUS  0x291
#define DS3_SQUS 0x292
#define E3_SQUS  0x293
#define F3_SQUS  0x294
#define FS3_SQUS 0x295
#define G3_SQUS  0x296
#define GS3_SQUS 0x297
#define A3_SQUS  0x298
#define AS3_SQUS 0x299
#define B3_SQUS  0x29A
#define C4_SQUS  0x29B
#define CS4_SQUS 0x29C
#define D4_SQUS  0x29D
#define DS4_SQUS 0x29E
#define E4_SQUS  0x29F
#define F4_SQUS  0x2A0
#define FS4_SQUS 0x2A1
#define G4_SQUS  0x2A2
#define GS4_SQUS 0x2A3
#define A4_SQUS  0x2A4
#define AS4_SQUS 0x2A5
#define B4_SQUS  0x2A6
#define C5_SQUS  0x2A7
#define CS5_SQUS 0x2A8
#define D5_SQUS  0x2A9
#define DS5_SQUS 0x2AA
#define E5_SQUS  0x2AB
#define F5_SQUS  0x2AC
#define FS5_SQUS 0x2AD
#define G5_SQUS  0x2AE
#define GS5_SQUS 0x2AF
#define A5_SQUS  0x2B0
#define AS5_SQUS 0x2B1
#define B5_SQUS  0x2B2
#define C6_SQUS  0x2B3
#define CS6_SQUS 0x2B4
#define D6_SQUS  0x2B5
#define DS6_SQUS 0x2B6
#define E6_SQUS  0x2B7
#define F6_SQUS  0x2B8
#define FS6_SQUS 0x2B9
#define G6_SQUS  0x2BA
#define GS6_SQUS 0x2BB
#define A6_SQUS  0x2BC
#define AS6_SQUS 0x2BD
#define B6_SQUS  0x2BE
#define C7_SQUS  0x2BF

#define A1_NOIS  0x2C0
#define AS1_NOIS 0x2C1
#define B1_NOIS  0x2C2
#define C2_NOIS  0x2C3
#define CS2_NOIS 0x2C4
#define D2_NOIS  0x2C5
#define DS2_NOIS 0x2C6
#define E2_NOIS  0x2C7
#define F2_NOIS  0x2C8
#define FS2_NOIS 0x2C9
#define G2_NOIS  0x2CA
#define GS2_NOIS 0x2CB
#define A2_NOIS  0x2CC
#define AS2_NOIS 0x2CD
#define B2_NOIS  0x2CE
#define C3_NOIS  0x2CF
#define CS3_NOIS 0x2D0
#define D3_NOIS  0x2D1
#define DS3_NOIS 0x2D2
#define E3_NOIS  0x2D3
#define F3_NOIS  0x2D4
#define FS3_NOIS 0x2D5
#define G3_NOIS  0x2D6
#define GS3_NOIS 0x2D7
#define A3_NOIS  0x2D8
#define AS3_NOIS 0x2D9
#define B3_NOIS  0x2DA
#define C4_NOIS  0x2DB
#define CS4_NOIS 0x2DC
#define D4_NOIS  0x2DD
#define DS4_NOIS 0x2DE
#define E4_NOIS  0x2DF
#define F4_NOIS  0x2E0
#define FS4_NOIS 0x2E1
#define G4_NOIS  0x2E2
#define GS4_NOIS 0x2E3
#define A4_NOIS  0x2E4
#define AS4_NOIS 0x2E5
#define B4_NOIS  0x2E6
#define C5_NOIS  0x2E7
#define CS5_NOIS 0x2E8
#define D5_NOIS  0x2E9
#define DS5_NOIS 0x2EA
#define E5_NOIS  0x2EB
#define F5_NOIS  0x2EC
#define FS5_NOIS 0x2ED
#define G5_NOIS  0x2EE
#define GS5_NOIS 0x2EF
#define A5_NOIS  0x2F0
#define AS5_NOIS 0x2F1
#define B5_NOIS  0x2F2
#define C6_NOIS  0x2F3
#define CS6_NOIS 0x2F4
#define D6_NOIS  0x2F5
#define DS6_NOIS 0x2F6
#define E6_NOIS  0x2F7
#define F6_NOIS  0x2F8
#define FS6_NOIS 0x2F9
#define G6_NOIS  0x2FA
#define GS6_NOIS 0x2FB
#define A6_NOIS  0x2FC
#define AS6_NOIS 0x2FD
#define B6_NOIS  0x2FE
#define C7_NOIS  0x2FF

#define CS7_SQUL 0x300
#define DS7_SQUL 0x301
#define E7_SQUL  0x302
#define F7_SQUL  0x303
#define G7_SQUL  0x304
#define A7_SQUL  0x305
#define B7_SQUL  0x306
#define CS8_SQUL 0x307
#define E8_SQUL  0x308
#define G8_SQUL  0x309
#define B8_SQUL  0x30A
#define HI_SQUL  0x30B

#define CS7_SQUM 0x30C
#define DS7_SQUM 0x30D
#define E7_SQUM  0x30E
#define F7_SQUM  0x30F
#define G7_SQUM  0x310
#define A7_SQUM  0x311
#define B7_SQUM  0x312
#define CS8_SQUM 0x313
#define E8_SQUM  0x314
#define G8_SQUM  0x315
#define B8_SQUM  0x316
#define HI_SQUM  0x317

#define CS7_SQUS 0x318
#define DS7_SQUS 0x319
#define E7_SQUS  0x31A
#define F7_SQUS  0x31B
#define G7_SQUS  0x31C
#define A7_SQUS  0x31D
#define B7_SQUS  0x31E
#define CS8_SQUS 0x31F
#define E8_SQUS  0x320
#define G8_SQUS  0x321
#define B8_SQUS  0x322
#define HI_SQUS  0x323

#define SND32_SILENCE  0x324
#define SND32_NOISE    0x325 // Long Noise

#define SND32_END      0xFFFF

#define _1(x) x,
#define _2(x) x,x,
#define _3(x) x,x,x,
#define _4(x) x,x,x,x,
#define _5(x) x,x,x,x,x,
#define _6(x) x,x,x,x,x,x,
#define _7(x) x,x,x,x,x,x,x,
#define _8(x) x,x,x,x,x,x,x,x,
#define _9(x) x,x,x,x,x,x,x,x,x,
#define _10(x) x,x,x,x,x,x,x,x,x,x,
#define _11(x) _10(x) _1(x)
#define _12(x) _10(x) _2(x)
#define _13(x) _10(x) _3(x)
#define _14(x) _10(x) _4(x)
#define _15(x) _10(x) _5(x)
#define _16(x) _10(x) _6(x)
#define _17(x) _10(x) _7(x)
#define _18(x) _10(x) _8(x)
#define _19(x) _10(x) _9(x)
#define _20(x) _10(x) _10(x)
#define _21(x) _20(x) _1(x)
#define _22(x) _20(x) _2(x)
#define _23(x) _20(x) _3(x)
#define _24(x) _20(x) _4(x)
#define _25(x) _20(x) _5(x)
#define _26(x) _20(x) _6(x)
#define _27(x) _20(x) _7(x)
#define _28(x) _20(x) _8(x)
#define _29(x) _20(x) _9(x)
#define _30(x) _20(x) _10(x)
#define _31(x) _30(x) _1(x)
#define _32(x) _30(x) _2(x)
#define _33(x) _30(x) _3(x)
#define _34(x) _30(x) _4(x)
#define _35(x) _30(x) _5(x)
#define _36(x) _30(x) _6(x)
#define _37(x) _30(x) _7(x)
#define _38(x) _30(x) _8(x)
#define _39(x) _30(x) _9(x)
#define _40(x) _30(x) _10(x)
#define _41(x) _40(x) _1(x)
#define _42(x) _40(x) _2(x)
#define _43(x) _40(x) _3(x)
#define _44(x) _40(x) _4(x)
#define _45(x) _40(x) _5(x)
#define _46(x) _40(x) _6(x)
#define _47(x) _40(x) _7(x)
#define _48(x) _40(x) _8(x)
#define _49(x) _40(x) _9(x)
#define _50(x) _40(x) _10(x)
#define _51(x) _50(x) _1(x)
#define _52(x) _50(x) _2(x)
#define _53(x) _50(x) _3(x)
#define _54(x) _50(x) _4(x)
#define _55(x) _50(x) _5(x)
#define _56(x) _50(x) _6(x)
#define _57(x) _50(x) _7(x)
#define _58(x) _50(x) _8(x)
#define _59(x) _50(x) _9(x)
#define _60(x) _50(x) _10(x)

/* Chords */

/* Major */
#define _3_MAJ(x)       x,x+4,x+7,
#define _6_MAJ(x)       _3_MAJ(x) _3_MAJ(x)
#define _9_MAJ(x)       _6_MAJ(x) _3_MAJ(x)
#define _12_MAJ(x)      _9_MAJ(x) _3_MAJ(x)
#define _15_MAJ(x)      _12_MAJ(x) _3_MAJ(x)
#define _18_MAJ(x)      _15_MAJ(x) _3_MAJ(x)
#define _21_MAJ(x)      _18_MAJ(x) _3_MAJ(x)
#define _24_MAJ(x)      _21_MAJ(x) _3_MAJ(x)
#define _27_MAJ(x)      _24_MAJ(x) _3_MAJ(x)
#define _30_MAJ(x)      _27_MAJ(x) _3_MAJ(x)
#define _33_MAJ(x)      _30_MAJ(x) _3_MAJ(x)
#define _36_MAJ(x)      _33_MAJ(x) _3_MAJ(x)
#define _39_MAJ(x)      _36_MAJ(x) _3_MAJ(x)
#define _42_MAJ(x)      _39_MAJ(x) _3_MAJ(x)
#define _45_MAJ(x)      _42_MAJ(x) _3_MAJ(x)
#define _48_MAJ(x)      _45_MAJ(x) _3_MAJ(x)

/* Minor */
#define _3_M(x)         x,x+3,x+7,
#define _6_M(x)         _3_M(x) _3_M(x)
#define _9_M(x)         _6_M(x) _3_M(x)
#define _12_M(x)        _9_M(x) _3_M(x)
#define _15_M(x)        _12_M(x) _3_M(x)
#define _18_M(x)        _15_M(x) _3_M(x)
#define _21_M(x)        _18_M(x) _3_M(x)
#define _24_M(x)        _21_M(x) _3_M(x)
#define _27_M(x)        _24_M(x) _3_M(x)
#define _30_M(x)        _27_M(x) _3_M(x)
#define _33_M(x)        _30_M(x) _3_M(x)
#define _36_M(x)        _33_M(x) _3_M(x)
#define _39_M(x)        _36_M(x) _3_M(x)
#define _42_M(x)        _39_M(x) _3_M(x)
#define _45_M(x)        _42_M(x) _3_M(x)
#define _48_M(x)        _45_M(x) _3_M(x)

/* Major 7th */
#define _4_MAJ7TH(x)    x,x+4,x+7,x+11,
#define _8_MAJ7TH(x)    _4_MAJ7TH(x) _4_MAJ7TH(x)
#define _12_MAJ7TH(x)   _8_MAJ7TH(x) _4_MAJ7TH(x)
#define _16_MAJ7TH(x)   _12_MAJ7TH(x) _4_MAJ7TH(x)
#define _20_MAJ7TH(x)   _16_MAJ7TH(x) _4_MAJ7TH(x)
#define _24_MAJ7TH(x)   _20_MAJ7TH(x) _4_MAJ7TH(x)
#define _28_MAJ7TH(x)   _24_MAJ7TH(x) _4_MAJ7TH(x)
#define _32_MAJ7TH(x)   _28_MAJ7TH(x) _4_MAJ7TH(x)
#define _36_MAJ7TH(x)   _32_MAJ7TH(x) _4_MAJ7TH(x)
#define _40_MAJ7TH(x)   _36_MAJ7TH(x) _4_MAJ7TH(x)
#define _44_MAJ7TH(x)   _40_MAJ7TH(x) _4_MAJ7TH(x)
#define _48_MAJ7TH(x)   _44_MAJ7TH(x) _4_MAJ7TH(x)

/* Minor Major 7th */
#define _4_MMAJ7TH(x)   x,x+3,x+7,x+11,
#define _8_MMAJ7TH(x)   _4_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _12_MMAJ7TH(x)  _8_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _16_MMAJ7TH(x)  _12_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _20_MMAJ7TH(x)  _16_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _24_MMAJ7TH(x)  _20_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _28_MMAJ7TH(x)  _24_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _32_MMAJ7TH(x)  _28_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _36_MMAJ7TH(x)  _32_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _40_MMAJ7TH(x)  _36_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _44_MMAJ7TH(x)  _40_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _48_MMAJ7TH(x)  _44_MMAJ7TH(x) _4_MMAJ7TH(x)

/* 7th */
#define _4_7TH(x)       x,x+4,x+7,x+10,
#define _8_7TH(x)       _4_7TH(x) _4_7TH(x)
#define _12_7TH(x)      _8_7TH(x) _4_7TH(x)
#define _16_7TH(x)      _12_7TH(x) _4_7TH(x)
#define _20_7TH(x)      _16_7TH(x) _4_7TH(x)
#define _24_7TH(x)      _20_7TH(x) _4_7TH(x)
#define _28_7TH(x)      _24_7TH(x) _4_7TH(x)
#define _32_7TH(x)      _28_7TH(x) _4_7TH(x)
#define _36_7TH(x)      _32_7TH(x) _4_7TH(x)
#define _40_7TH(x)      _36_7TH(x) _4_7TH(x)
#define _44_7TH(x)      _40_7TH(x) _4_7TH(x)
#define _48_7TH(x)      _44_7TH(x) _4_7TH(x)

/* Minor 7th */
#define _4_M7TH(x)      x,x+3,x+7,x+10,
#define _8_M7TH(x)      _4_M7TH(x) _4_M7TH(x)
#define _12_M7TH(x)     _8_M7TH(x) _4_M7TH(x)
#define _16_M7TH(x)     _12_M7TH(x) _4_M7TH(x)
#define _20_M7TH(x)     _16_M7TH(x) _4_M7TH(x)
#define _24_M7TH(x)     _20_M7TH(x) _4_M7TH(x)
#define _28_M7TH(x)     _24_M7TH(x) _4_M7TH(x)
#define _32_M7TH(x)     _28_M7TH(x) _4_M7TH(x)
#define _36_M7TH(x)     _32_M7TH(x) _4_M7TH(x)
#define _40_M7TH(x)     _36_M7TH(x) _4_M7TH(x)
#define _44_M7TH(x)     _40_M7TH(x) _4_M7TH(x)
#define _48_M7TH(x)     _44_M7TH(x) _4_M7TH(x)

/* Add 9th */
#define _4_ADD9TH(x)    x,x+4,x+7,x+14,
#define _8_ADD9TH(x)    _4_ADD9TH(x) _4_ADD9TH(x)
#define _12_ADD9TH(x)   _8_ADD9TH(x) _4_ADD9TH(x)
#define _16_ADD9TH(x)   _12_ADD9TH(x) _4_ADD9TH(x)
#define _20_ADD9TH(x)   _16_ADD9TH(x) _4_ADD9TH(x)
#define _24_ADD9TH(x)   _20_ADD9TH(x) _4_ADD9TH(x)
#define _28_ADD9TH(x)   _24_ADD9TH(x) _4_ADD9TH(x)
#define _32_ADD9TH(x)   _28_ADD9TH(x) _4_ADD9TH(x)
#define _36_ADD9TH(x)   _32_ADD9TH(x) _4_ADD9TH(x)
#define _40_ADD9TH(x)   _36_ADD9TH(x) _4_ADD9TH(x)
#define _44_ADD9TH(x)   _40_ADD9TH(x) _4_ADD9TH(x)
#define _48_ADD9TH(x)   _44_ADD9TH(x) _4_ADD9TH(x)

/* 9th */
#define _8_9TH(x)       x,x+4,x+7,x+10,x+14,x+10,x+7,x+4,
#define _16_9TH(x)      _8_9TH(x) _8_9TH(x)
#define _24_9TH(x)      _16_9TH(x) _8_9TH(x)
#define _32_9TH(x)      _24_9TH(x) _8_9TH(x)
#define _40_9TH(x)      _32_9TH(x) _8_9TH(x)
#define _48_9TH(x)      _40_9TH(x) _8_9TH(x)

/* 5th */
#define _4_5TH(x)       x,x+7,x+14,x+21,
#define _8_5TH(x)       _4_5TH(x) _4_5TH(x)
#define _12_5TH(x)      _8_5TH(x) _4_5TH(x)
#define _16_5TH(x)      _12_5TH(x) _4_5TH(x)
#define _20_5TH(x)      _16_5TH(x) _4_5TH(x)
#define _24_5TH(x)      _20_5TH(x) _4_5TH(x)
#define _28_5TH(x)      _24_5TH(x) _4_5TH(x)
#define _32_5TH(x)      _28_5TH(x) _4_5TH(x)
#define _36_5TH(x)      _32_5TH(x) _4_5TH(x)
#define _40_5TH(x)      _36_5TH(x) _4_5TH(x)
#define _44_5TH(x)      _40_5TH(x) _4_5TH(x)
#define _48_5TH(x)      _44_5TH(x) _4_5TH(x)

/* Arpeggios */

#define _24_MAJ_ARPEGGIO(x)     _6(x) _6(x+4) _6(x+7) _6(x+4)
#define _24_M_ARPEGGIO(x)       _6(x) _6(x+3) _6(x+7) _6(x+3)
#define _24_MAJ7TH_ARPEGGIO(x)  _4(x) _4(x+4) _4(x+7) _4(x+11) _4(x+7) _4(x+4)
#define _24_MMAJ7TH_ARPEGGIO(x) _4(x) _4(x+3) _4(x+7) _4(x+11) _4(x+7) _4(x+3)
#define _24_7TH_ARPEGGIO(x)     _4(x) _4(x+4) _4(x+7) _4(x+10) _4(x+7) _4(x+4)
#define _24_M7TH_ARPEGGIO(x)    _4(x) _4(x+3) _4(x+7) _4(x+10) _4(x+7) _4(x+3)
#define _24_ADD9TH_ARPEGGIO(x)  _4(x) _4(x+4) _4(x+7) _4(x+14) _4(x+7) _4(x+4)
#define _24_9TH_ARPEGGIO(x)     _3(x) _3(x+4) _3(x+7) _3(x+10) _3(x+14) _3(x+10) _3(x+7) _3(x+4)
#define _24_5TH_ARPEGGIO(x)     _4(x) _4(x+7) _4(x+14) _4(x+21) _4(x+14) _4(x+7)

#define _48_MAJ_ARPEGGIO(x)     _12(x) _12(x+4) _12(x+7) _12(x+4)
#define _48_M_ARPEGGIO(x)       _12(x) _12(x+3) _12(x+7) _12(x+3)
#define _48_MAJ7TH_ARPEGGIO(x)  _8(x) _8(x+4) _8(x+7) _8(x+11) _8(x+7) _8(x+4)
#define _48_MMAJ7TH_ARPEGGIO(x) _8(x) _8(x+3) _8(x+7) _8(x+11) _8(x+7) _8(x+3)
#define _48_7TH_ARPEGGIO(x)     _8(x) _8(x+4) _8(x+7) _8(x+10) _8(x+7) _8(x+4)
#define _48_M7TH_ARPEGGIO(x)    _8(x) _8(x+3) _8(x+7) _8(x+10) _8(x+7) _8(x+3)
#define _48_ADD9TH_ARPEGGIO(x)  _8(x) _8(x+4) _8(x+7) _8(x+14) _8(x+7) _8(x+4)
#define _48_9TH_ARPEGGIO(x)     _6(x) _6(x+4) _6(x+7) _6(x+10) _6(x+14) _6(x+10) _6(x+7) _6(x+4)
#define _48_5TH_ARPEGGIO(x)     _8(x) _8(x+7) _8(x+14) _8(x+21) _8(x+14) _8(x+7)

