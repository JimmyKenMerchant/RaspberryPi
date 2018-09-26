/**
 * snd32/musiccode.h
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * This header file is for the convenience of using functions in ../(asterisk)/system32/library/snd32.s
 * Because of the purpose, names of constants are abbreviated and less considered of naming conventions.
 * Be careful of naming conventions with constants in other header files.
 */

/**
 * Music Code is 16-bit Blocks. Select up to 4096 sounds indexed by Sound Index.
 * Index is 0-4096.
 * 0xFFFF(65535) means End of Music Code.
 */

#define _A1_SINL  0x00
#define _AS1_SINL 0x01
#define _B1_SINL  0x02
#define _C2_SINL  0x03
#define _CS2_SINL 0x04
#define _D2_SINL  0x05
#define _DS2_SINL 0x06
#define _E2_SINL  0x07
#define _F2_SINL  0x08
#define _FS2_SINL 0x09
#define _G2_SINL  0x0A
#define _GS2_SINL 0x0B
#define _A2_SINL  0x0C
#define _AS2_SINL 0x0D
#define _B2_SINL  0x0E
#define _C3_SINL  0x0F
#define _CS3_SINL 0x10
#define _D3_SINL  0x11
#define _DS3_SINL 0x12
#define _E3_SINL  0x13
#define _F3_SINL  0x14
#define _FS3_SINL 0x15
#define _G3_SINL  0x16
#define _GS3_SINL 0x17
#define _A3_SINL  0x18
#define _AS3_SINL 0x19
#define _B3_SINL  0x1A
#define _C4_SINL  0x1B
#define _CS4_SINL 0x1C
#define _D4_SINL  0x1D
#define _DS4_SINL 0x1E
#define _E4_SINL  0x1F
#define _F4_SINL  0x20
#define _FS4_SINL 0x21
#define _G4_SINL  0x22
#define _GS4_SINL 0x23
#define _A4_SINL  0x24
#define _AS4_SINL 0x25
#define _B4_SINL  0x26
#define _C5_SINL  0x27
#define _CS5_SINL 0x28
#define _D5_SINL  0x29
#define _DS5_SINL 0x2A
#define _E5_SINL  0x2B
#define _F5_SINL  0x2C
#define _FS5_SINL 0x2D
#define _G5_SINL  0x2E
#define _GS5_SINL 0x2F
#define _A5_SINL  0x30
#define _AS5_SINL 0x31
#define _B5_SINL  0x32
#define _C6_SINL  0x33
#define _CS6_SINL 0x34
#define _D6_SINL  0x35
#define _DS6_SINL 0x36
#define _E6_SINL  0x37
#define _F6_SINL  0x38
#define _FS6_SINL 0x39
#define _G6_SINL  0x3A
#define _GS6_SINL 0x3B
#define _A6_SINL  0x3C
#define _AS6_SINL 0x3D
#define _B6_SINL  0x3E
#define _C7_SINL  0x3F

#define _A1_SAWL  0x40
#define _AS1_SAWL 0x41
#define _B1_SAWL  0x42
#define _C2_SAWL  0x43
#define _CS2_SAWL 0x44
#define _D2_SAWL  0x45
#define _DS2_SAWL 0x46
#define _E2_SAWL  0x47
#define _F2_SAWL  0x48
#define _FS2_SAWL 0x49
#define _G2_SAWL  0x4A
#define _GS2_SAWL 0x4B
#define _A2_SAWL  0x4C
#define _AS2_SAWL 0x4D
#define _B2_SAWL  0x4E
#define _C3_SAWL  0x4F
#define _CS3_SAWL 0x50
#define _D3_SAWL  0x51
#define _DS3_SAWL 0x52
#define _E3_SAWL  0x53
#define _F3_SAWL  0x54
#define _FS3_SAWL 0x55
#define _G3_SAWL  0x56
#define _GS3_SAWL 0x57
#define _A3_SAWL  0x58
#define _AS3_SAWL 0x59
#define _B3_SAWL  0x5A
#define _C4_SAWL  0x5B
#define _CS4_SAWL 0x5C
#define _D4_SAWL  0x5D
#define _DS4_SAWL 0x5E
#define _E4_SAWL  0x5F
#define _F4_SAWL  0x60
#define _FS4_SAWL 0x61
#define _G4_SAWL  0x62
#define _GS4_SAWL 0x63
#define _A4_SAWL  0x64
#define _AS4_SAWL 0x65
#define _B4_SAWL  0x66
#define _C5_SAWL  0x67
#define _CS5_SAWL 0x68
#define _D5_SAWL  0x69
#define _DS5_SAWL 0x6A
#define _E5_SAWL  0x6B
#define _F5_SAWL  0x6C
#define _FS5_SAWL 0x6D
#define _G5_SAWL  0x6E
#define _GS5_SAWL 0x6F
#define _A5_SAWL  0x70
#define _AS5_SAWL 0x71
#define _B5_SAWL  0x72
#define _C6_SAWL  0x73
#define _CS6_SAWL 0x74
#define _D6_SAWL  0x75
#define _DS6_SAWL 0x76
#define _E6_SAWL  0x77
#define _F6_SAWL  0x78
#define _FS6_SAWL 0x79
#define _G6_SAWL  0x7A
#define _GS6_SAWL 0x7B
#define _A6_SAWL  0x7C
#define _AS6_SAWL 0x7D
#define _B6_SAWL  0x7E
#define _C7_SAWL  0x7F

#define _A1_SQUL  0x80
#define _AS1_SQUL 0x81
#define _B1_SQUL  0x82
#define _C2_SQUL  0x83
#define _CS2_SQUL 0x84
#define _D2_SQUL  0x85
#define _DS2_SQUL 0x86
#define _E2_SQUL  0x87
#define _F2_SQUL  0x88
#define _FS2_SQUL 0x89
#define _G2_SQUL  0x8A
#define _GS2_SQUL 0x8B
#define _A2_SQUL  0x8C
#define _AS2_SQUL 0x8D
#define _B2_SQUL  0x8E
#define _C3_SQUL  0x8F
#define _CS3_SQUL 0x90
#define _D3_SQUL  0x91
#define _DS3_SQUL 0x92
#define _E3_SQUL  0x93
#define _F3_SQUL  0x94
#define _FS3_SQUL 0x95
#define _G3_SQUL  0x96
#define _GS3_SQUL 0x97
#define _A3_SQUL  0x98
#define _AS3_SQUL 0x99
#define _B3_SQUL  0x9A
#define _C4_SQUL  0x9B
#define _CS4_SQUL 0x9C
#define _D4_SQUL  0x9D
#define _DS4_SQUL 0x9E
#define _E4_SQUL  0x9F
#define _F4_SQUL  0xA0
#define _FS4_SQUL 0xA1
#define _G4_SQUL  0xA2
#define _GS4_SQUL 0xA3
#define _A4_SQUL  0xA4
#define _AS4_SQUL 0xA5
#define _B4_SQUL  0xA6
#define _C5_SQUL  0xA7
#define _CS5_SQUL 0xA8
#define _D5_SQUL  0xA9
#define _DS5_SQUL 0xAA
#define _E5_SQUL  0xAB
#define _F5_SQUL  0xAC
#define _FS5_SQUL 0xAD
#define _G5_SQUL  0xAE
#define _GS5_SQUL 0xAF
#define _A5_SQUL  0xB0
#define _AS5_SQUL 0xB1
#define _B5_SQUL  0xB2
#define _C6_SQUL  0xB3
#define _CS6_SQUL 0xB4
#define _D6_SQUL  0xB5
#define _DS6_SQUL 0xB6
#define _E6_SQUL  0xB7
#define _F6_SQUL  0xB8
#define _FS6_SQUL 0xB9
#define _G6_SQUL  0xBA
#define _GS6_SQUL 0xBB
#define _A6_SQUL  0xBC
#define _AS6_SQUL 0xBD
#define _B6_SQUL  0xBE
#define _C7_SQUL  0xBF

#define _CS7_SQUL 0xC0
#define _D7_SQUL  0xC1
#define _DS7_SQUL 0xC2
#define _E7_SQUL  0xC3
#define _F7_SQUL  0xC4
#define _FS7_SQUL 0xC5
#define _G7_SQUL  0xC6
#define _GS7_SQUL 0xC7
#define _A7_SQUL  0xC8
#define _AS7_SQUL 0xC9
#define _B7_SQUL  0xCA
#define _C8_SQUL  0xCB

#define _1_NOIL   0xCC
#define _2_NOIL   0xCD
#define _3_NOIL   0xCE
#define _4_NOIL   0xCF
#define _5_NOIL   0xD0
#define _6_NOIL   0xD1
#define _7_NOIL   0xD2
#define _8_NOIL   0xD3
#define _9_NOIL   0xD4
#define _10_NOIL  0xD5
#define _11_NOIL  0xD6
#define _12_NOIL  0xD7
#define _13_NOIL  0xD8
#define _14_NOIL  0xD9
#define _15_NOIL  0xDA
#define _16_NOIL  0xDB
#define _17_NOIL  0xDC
#define _18_NOIL  0xDD
#define _19_NOIL  0xDE
#define _20_NOIL  0xDF
#define _21_NOIL  0xE0
#define _22_NOIL  0xE1
#define _23_NOIL  0xE2
#define _24_NOIL  0xE3
#define _25_NOIL  0xE4
#define _26_NOIL  0xE5
#define _27_NOIL  0xE6
#define _28_NOIL  0xE7
#define _29_NOIL  0xE8
#define _30_NOIL  0xE9
#define _31_NOIL  0xEA
#define _32_NOIL  0xEB
#define _33_NOIL  0xEC
#define _34_NOIL  0xED
#define _35_NOIL  0xEE
#define _36_NOIL  0xEF
#define _37_NOIL  0xF0
#define _38_NOIL  0xF1
#define _39_NOIL  0xF2
#define _40_NOIL  0xF3
#define _41_NOIL  0xF4
#define _42_NOIL  0xF5
#define _43_NOIL  0xF6
#define _44_NOIL  0xF7
#define _45_NOIL  0xF8
#define _46_NOIL  0xF9
#define _47_NOIL  0xFA
#define _48_NOIL  0xFB
#define _49_NOIL  0xFC
#define _50_NOIL  0xFD
#define _51_NOIL  0xFE
#define _52_NOIL  0xFF

#define _A1_TRIL  0x100
#define _AS1_TRIL 0x101
#define _B1_TRIL  0x102
#define _C2_TRIL  0x103
#define _CS2_TRIL 0x104
#define _D2_TRIL  0x105
#define _DS2_TRIL 0x106
#define _E2_TRIL  0x107
#define _F2_TRIL  0x108
#define _FS2_TRIL 0x109
#define _G2_TRIL  0x10A
#define _GS2_TRIL 0x10B
#define _A2_TRIL  0x10C
#define _AS2_TRIL 0x10D
#define _B2_TRIL  0x10E
#define _C3_TRIL  0x10F
#define _CS3_TRIL 0x110
#define _D3_TRIL  0x111
#define _DS3_TRIL 0x112
#define _E3_TRIL  0x113
#define _F3_TRIL  0x114
#define _FS3_TRIL 0x115
#define _G3_TRIL  0x116
#define _GS3_TRIL 0x117
#define _A3_TRIL  0x118
#define _AS3_TRIL 0x119
#define _B3_TRIL  0x11A
#define _C4_TRIL  0x11B
#define _CS4_TRIL 0x11C
#define _D4_TRIL  0x11D
#define _DS4_TRIL 0x11E
#define _E4_TRIL  0x11F
#define _F4_TRIL  0x120
#define _FS4_TRIL 0x121
#define _G4_TRIL  0x122
#define _GS4_TRIL 0x123
#define _A4_TRIL  0x124
#define _AS4_TRIL 0x125
#define _B4_TRIL  0x126
#define _C5_TRIL  0x127
#define _CS5_TRIL 0x128
#define _D5_TRIL  0x129
#define _DS5_TRIL 0x12A
#define _E5_TRIL  0x12B
#define _F5_TRIL  0x12C
#define _FS5_TRIL 0x12D
#define _G5_TRIL  0x12E
#define _GS5_TRIL 0x12F
#define _A5_TRIL  0x130
#define _AS5_TRIL 0x131
#define _B5_TRIL  0x132
#define _C6_TRIL  0x133
#define _CS6_TRIL 0x134
#define _D6_TRIL  0x135
#define _DS6_TRIL 0x136
#define _E6_TRIL  0x137
#define _F6_TRIL  0x138
#define _FS6_TRIL 0x139
#define _G6_TRIL  0x13A
#define _GS6_TRIL 0x13B
#define _A6_TRIL  0x13C
#define _AS6_TRIL 0x13D
#define _B6_TRIL  0x13E
#define _C7_TRIL  0x13F

#define _A1_DISL  0x140
#define _AS1_DISL 0x141
#define _B1_DISL  0x142
#define _C2_DISL  0x143
#define _CS2_DISL 0x144
#define _D2_DISL  0x145
#define _DS2_DISL 0x146
#define _E2_DISL  0x147
#define _F2_DISL  0x148
#define _FS2_DISL 0x149
#define _G2_DISL  0x14A
#define _GS2_DISL 0x14B
#define _A2_DISL  0x14C
#define _AS2_DISL 0x14D
#define _B2_DISL  0x14E
#define _C3_DISL  0x14F
#define _CS3_DISL 0x150
#define _D3_DISL  0x151
#define _DS3_DISL 0x152
#define _E3_DISL  0x153
#define _F3_DISL  0x154
#define _FS3_DISL 0x155
#define _G3_DISL  0x156
#define _GS3_DISL 0x157
#define _A3_DISL  0x158
#define _AS3_DISL 0x159
#define _B3_DISL  0x15A
#define _C4_DISL  0x15B
#define _CS4_DISL 0x15C
#define _D4_DISL  0x15D
#define _DS4_DISL 0x15E
#define _E4_DISL  0x15F
#define _F4_DISL  0x160
#define _FS4_DISL 0x161
#define _G4_DISL  0x162
#define _GS4_DISL 0x163
#define _A4_DISL  0x164
#define _AS4_DISL 0x165
#define _B4_DISL  0x166
#define _C5_DISL  0x167
#define _CS5_DISL 0x168
#define _D5_DISL  0x169
#define _DS5_DISL 0x16A
#define _E5_DISL  0x16B
#define _F5_DISL  0x16C
#define _FS5_DISL 0x16D
#define _G5_DISL  0x16E
#define _GS5_DISL 0x16F
#define _A5_DISL  0x170
#define _AS5_DISL 0x171
#define _B5_DISL  0x172
#define _C6_DISL  0x173
#define _CS6_DISL 0x174
#define _D6_DISL  0x175
#define _DS6_DISL 0x176
#define _E6_DISL  0x177
#define _F6_DISL  0x178
#define _FS6_DISL 0x179
#define _G6_DISL  0x17A
#define _GS6_DISL 0x17B
#define _A6_DISL  0x17C
#define _AS6_DISL 0x17D
#define _B6_DISL  0x17E
#define _C7_DISL  0x17F

#define _A1_SINM  0x200
#define _AS1_SINM 0x201
#define _B1_SINM  0x202
#define _C2_SINM  0x203
#define _CS2_SINM 0x204
#define _D2_SINM  0x205
#define _DS2_SINM 0x206
#define _E2_SINM  0x207
#define _F2_SINM  0x208
#define _FS2_SINM 0x209
#define _G2_SINM  0x20A
#define _GS2_SINM 0x20B
#define _A2_SINM  0x20C
#define _AS2_SINM 0x20D
#define _B2_SINM  0x20E
#define _C3_SINM  0x20F
#define _CS3_SINM 0x210
#define _D3_SINM  0x211
#define _DS3_SINM 0x212
#define _E3_SINM  0x213
#define _F3_SINM  0x214
#define _FS3_SINM 0x215
#define _G3_SINM  0x216
#define _GS3_SINM 0x217
#define _A3_SINM  0x218
#define _AS3_SINM 0x219
#define _B3_SINM  0x21A
#define _C4_SINM  0x21B
#define _CS4_SINM 0x21C
#define _D4_SINM  0x21D
#define _DS4_SINM 0x21E
#define _E4_SINM  0x21F
#define _F4_SINM  0x220
#define _FS4_SINM 0x221
#define _G4_SINM  0x222
#define _GS4_SINM 0x223
#define _A4_SINM  0x224
#define _AS4_SINM 0x225
#define _B4_SINM  0x226
#define _C5_SINM  0x227
#define _CS5_SINM 0x228
#define _D5_SINM  0x229
#define _DS5_SINM 0x22A
#define _E5_SINM  0x22B
#define _F5_SINM  0x22C
#define _FS5_SINM 0x22D
#define _G5_SINM  0x22E
#define _GS5_SINM 0x22F
#define _A5_SINM  0x230
#define _AS5_SINM 0x231
#define _B5_SINM  0x232
#define _C6_SINM  0x233
#define _CS6_SINM 0x234
#define _D6_SINM  0x235
#define _DS6_SINM 0x236
#define _E6_SINM  0x237
#define _F6_SINM  0x238
#define _FS6_SINM 0x239
#define _G6_SINM  0x23A
#define _GS6_SINM 0x23B
#define _A6_SINM  0x23C
#define _AS6_SINM 0x23D
#define _B6_SINM  0x23E
#define _C7_SINM  0x23F

#define _A1_SAWM  0x240
#define _AS1_SAWM 0x241
#define _B1_SAWM  0x242
#define _C2_SAWM  0x243
#define _CS2_SAWM 0x244
#define _D2_SAWM  0x245
#define _DS2_SAWM 0x246
#define _E2_SAWM  0x247
#define _F2_SAWM  0x248
#define _FS2_SAWM 0x249
#define _G2_SAWM  0x24A
#define _GS2_SAWM 0x24B
#define _A2_SAWM  0x24C
#define _AS2_SAWM 0x24D
#define _B2_SAWM  0x24E
#define _C3_SAWM  0x24F
#define _CS3_SAWM 0x250
#define _D3_SAWM  0x251
#define _DS3_SAWM 0x252
#define _E3_SAWM  0x253
#define _F3_SAWM  0x254
#define _FS3_SAWM 0x255
#define _G3_SAWM  0x256
#define _GS3_SAWM 0x257
#define _A3_SAWM  0x258
#define _AS3_SAWM 0x259
#define _B3_SAWM  0x25A
#define _C4_SAWM  0x25B
#define _CS4_SAWM 0x25C
#define _D4_SAWM  0x25D
#define _DS4_SAWM 0x25E
#define _E4_SAWM  0x25F
#define _F4_SAWM  0x260
#define _FS4_SAWM 0x261
#define _G4_SAWM  0x262
#define _GS4_SAWM 0x263
#define _A4_SAWM  0x264
#define _AS4_SAWM 0x265
#define _B4_SAWM  0x266
#define _C5_SAWM  0x267
#define _CS5_SAWM 0x268
#define _D5_SAWM  0x269
#define _DS5_SAWM 0x26A
#define _E5_SAWM  0x26B
#define _F5_SAWM  0x26C
#define _FS5_SAWM 0x26D
#define _G5_SAWM  0x26E
#define _GS5_SAWM 0x26F
#define _A5_SAWM  0x270
#define _AS5_SAWM 0x271
#define _B5_SAWM  0x272
#define _C6_SAWM  0x273
#define _CS6_SAWM 0x274
#define _D6_SAWM  0x275
#define _DS6_SAWM 0x276
#define _E6_SAWM  0x277
#define _F6_SAWM  0x278
#define _FS6_SAWM 0x279
#define _G6_SAWM  0x27A
#define _GS6_SAWM 0x27B
#define _A6_SAWM  0x27C
#define _AS6_SAWM 0x27D
#define _B6_SAWM  0x27E
#define _C7_SAWM  0x27F

#define _A1_SQUM  0x280
#define _AS1_SQUM 0x281
#define _B1_SQUM  0x282
#define _C2_SQUM  0x283
#define _CS2_SQUM 0x284
#define _D2_SQUM  0x285
#define _DS2_SQUM 0x286
#define _E2_SQUM  0x287
#define _F2_SQUM  0x288
#define _FS2_SQUM 0x289
#define _G2_SQUM  0x28A
#define _GS2_SQUM 0x28B
#define _A2_SQUM  0x28C
#define _AS2_SQUM 0x28D
#define _B2_SQUM  0x28E
#define _C3_SQUM  0x28F
#define _CS3_SQUM 0x290
#define _D3_SQUM  0x291
#define _DS3_SQUM 0x292
#define _E3_SQUM  0x293
#define _F3_SQUM  0x294
#define _FS3_SQUM 0x295
#define _G3_SQUM  0x296
#define _GS3_SQUM 0x297
#define _A3_SQUM  0x298
#define _AS3_SQUM 0x299
#define _B3_SQUM  0x29A
#define _C4_SQUM  0x29B
#define _CS4_SQUM 0x29C
#define _D4_SQUM  0x29D
#define _DS4_SQUM 0x29E
#define _E4_SQUM  0x29F
#define _F4_SQUM  0x2A0
#define _FS4_SQUM 0x2A1
#define _G4_SQUM  0x2A2
#define _GS4_SQUM 0x2A3
#define _A4_SQUM  0x2A4
#define _AS4_SQUM 0x2A5
#define _B4_SQUM  0x2A6
#define _C5_SQUM  0x2A7
#define _CS5_SQUM 0x2A8
#define _D5_SQUM  0x2A9
#define _DS5_SQUM 0x2AA
#define _E5_SQUM  0x2AB
#define _F5_SQUM  0x2AC
#define _FS5_SQUM 0x2AD
#define _G5_SQUM  0x2AE
#define _GS5_SQUM 0x2AF
#define _A5_SQUM  0x2B0
#define _AS5_SQUM 0x2B1
#define _B5_SQUM  0x2B2
#define _C6_SQUM  0x2B3
#define _CS6_SQUM 0x2B4
#define _D6_SQUM  0x2B5
#define _DS6_SQUM 0x2B6
#define _E6_SQUM  0x2B7
#define _F6_SQUM  0x2B8
#define _FS6_SQUM 0x2B9
#define _G6_SQUM  0x2BA
#define _GS6_SQUM 0x2BB
#define _A6_SQUM  0x2BC
#define _AS6_SQUM 0x2BD
#define _B6_SQUM  0x2BE
#define _C7_SQUM  0x2BF

#define _CS7_SQUM 0x2C0
#define _D7_SQUM  0x2C1
#define _DS7_SQUM 0x2C2
#define _E7_SQUM  0x2C3
#define _F7_SQUM  0x2C4
#define _FS7_SQUM 0x2C5
#define _G7_SQUM  0x2C6
#define _GS7_SQUM 0x2C7
#define _A7_SQUM  0x2C8
#define _AS7_SQUM 0x2C9
#define _B7_SQUM  0x2CA
#define _C8_SQUM  0x2CB

#define _1_NOIM   0x2CC
#define _2_NOIM   0x2CD
#define _3_NOIM   0x2CE
#define _4_NOIM   0x2CF
#define _5_NOIM   0x2D0
#define _6_NOIM   0x2D1
#define _7_NOIM   0x2D2
#define _8_NOIM   0x2D3
#define _9_NOIM   0x2D4
#define _10_NOIM  0x2D5
#define _11_NOIM  0x2D6
#define _12_NOIM  0x2D7
#define _13_NOIM  0x2D8
#define _14_NOIM  0x2D9
#define _15_NOIM  0x2DA
#define _16_NOIM  0x2DB
#define _17_NOIM  0x2DC
#define _18_NOIM  0x2DD
#define _19_NOIM  0x2DE
#define _20_NOIM  0x2DF
#define _21_NOIM  0x2E0
#define _22_NOIM  0x2E1
#define _23_NOIM  0x2E2
#define _24_NOIM  0x2E3
#define _25_NOIM  0x2E4
#define _26_NOIM  0x2E5
#define _27_NOIM  0x2E6
#define _28_NOIM  0x2E7
#define _29_NOIM  0x2E8
#define _30_NOIM  0x2E9
#define _31_NOIM  0x2EA
#define _32_NOIM  0x2EB
#define _33_NOIM  0x2EC
#define _34_NOIM  0x2ED
#define _35_NOIM  0x2EE
#define _36_NOIM  0x2EF
#define _37_NOIM  0x2F0
#define _38_NOIM  0x2F1
#define _39_NOIM  0x2F2
#define _40_NOIM  0x2F3
#define _41_NOIM  0x2F4
#define _42_NOIM  0x2F5
#define _43_NOIM  0x2F6
#define _44_NOIM  0x2F7
#define _45_NOIM  0x2F8
#define _46_NOIM  0x2F9
#define _47_NOIM  0x2FA
#define _48_NOIM  0x2FB
#define _49_NOIM  0x2FC
#define _50_NOIM  0x2FD
#define _51_NOIM  0x2FE
#define _52_NOIM  0x2FF

#define _A1_TRIM  0x300
#define _AS1_TRIM 0x301
#define _B1_TRIM  0x302
#define _C2_TRIM  0x303
#define _CS2_TRIM 0x304
#define _D2_TRIM  0x305
#define _DS2_TRIM 0x306
#define _E2_TRIM  0x307
#define _F2_TRIM  0x308
#define _FS2_TRIM 0x309
#define _G2_TRIM  0x30A
#define _GS2_TRIM 0x30B
#define _A2_TRIM  0x30C
#define _AS2_TRIM 0x30D
#define _B2_TRIM  0x30E
#define _C3_TRIM  0x30F
#define _CS3_TRIM 0x310
#define _D3_TRIM  0x311
#define _DS3_TRIM 0x312
#define _E3_TRIM  0x313
#define _F3_TRIM  0x314
#define _FS3_TRIM 0x315
#define _G3_TRIM  0x316
#define _GS3_TRIM 0x317
#define _A3_TRIM  0x318
#define _AS3_TRIM 0x319
#define _B3_TRIM  0x31A
#define _C4_TRIM  0x31B
#define _CS4_TRIM 0x31C
#define _D4_TRIM  0x31D
#define _DS4_TRIM 0x31E
#define _E4_TRIM  0x31F
#define _F4_TRIM  0x320
#define _FS4_TRIM 0x321
#define _G4_TRIM  0x322
#define _GS4_TRIM 0x323
#define _A4_TRIM  0x324
#define _AS4_TRIM 0x325
#define _B4_TRIM  0x326
#define _C5_TRIM  0x327
#define _CS5_TRIM 0x328
#define _D5_TRIM  0x329
#define _DS5_TRIM 0x32A
#define _E5_TRIM  0x32B
#define _F5_TRIM  0x32C
#define _FS5_TRIM 0x32D
#define _G5_TRIM  0x32E
#define _GS5_TRIM 0x32F
#define _A5_TRIM  0x330
#define _AS5_TRIM 0x331
#define _B5_TRIM  0x332
#define _C6_TRIM  0x333
#define _CS6_TRIM 0x334
#define _D6_TRIM  0x335
#define _DS6_TRIM 0x336
#define _E6_TRIM  0x337
#define _F6_TRIM  0x338
#define _FS6_TRIM 0x339
#define _G6_TRIM  0x33A
#define _GS6_TRIM 0x33B
#define _A6_TRIM  0x33C
#define _AS6_TRIM 0x33D
#define _B6_TRIM  0x33E
#define _C7_TRIM  0x33F

#define _A1_DISM  0x340
#define _AS1_DISM 0x341
#define _B1_DISM  0x342
#define _C2_DISM  0x343
#define _CS2_DISM 0x344
#define _D2_DISM  0x345
#define _DS2_DISM 0x346
#define _E2_DISM  0x347
#define _F2_DISM  0x348
#define _FS2_DISM 0x349
#define _G2_DISM  0x34A
#define _GS2_DISM 0x34B
#define _A2_DISM  0x34C
#define _AS2_DISM 0x34D
#define _B2_DISM  0x34E
#define _C3_DISM  0x34F
#define _CS3_DISM 0x350
#define _D3_DISM  0x351
#define _DS3_DISM 0x352
#define _E3_DISM  0x353
#define _F3_DISM  0x354
#define _FS3_DISM 0x355
#define _G3_DISM  0x356
#define _GS3_DISM 0x357
#define _A3_DISM  0x358
#define _AS3_DISM 0x359
#define _B3_DISM  0x35A
#define _C4_DISM  0x35B
#define _CS4_DISM 0x35C
#define _D4_DISM  0x35D
#define _DS4_DISM 0x35E
#define _E4_DISM  0x35F
#define _F4_DISM  0x360
#define _FS4_DISM 0x361
#define _G4_DISM  0x362
#define _GS4_DISM 0x363
#define _A4_DISM  0x364
#define _AS4_DISM 0x365
#define _B4_DISM  0x366
#define _C5_DISM  0x367
#define _CS5_DISM 0x368
#define _D5_DISM  0x369
#define _DS5_DISM 0x36A
#define _E5_DISM  0x36B
#define _F5_DISM  0x36C
#define _FS5_DISM 0x36D
#define _G5_DISM  0x36E
#define _GS5_DISM 0x36F
#define _A5_DISM  0x370
#define _AS5_DISM 0x371
#define _B5_DISM  0x372
#define _C6_DISM  0x373
#define _CS6_DISM 0x374
#define _D6_DISM  0x375
#define _DS6_DISM 0x376
#define _E6_DISM  0x377
#define _F6_DISM  0x378
#define _FS6_DISM 0x379
#define _G6_DISM  0x37A
#define _GS6_DISM 0x37B
#define _A6_DISM  0x37C
#define _AS6_DISM 0x37D
#define _B6_DISM  0x37E
#define _C7_DISM  0x37F

#define _A1_SINS  0x400
#define _AS1_SINS 0x401
#define _B1_SINS  0x402
#define _C2_SINS  0x403
#define _CS2_SINS 0x404
#define _D2_SINS  0x405
#define _DS2_SINS 0x406
#define _E2_SINS  0x407
#define _F2_SINS  0x408
#define _FS2_SINS 0x409
#define _G2_SINS  0x40A
#define _GS2_SINS 0x40B
#define _A2_SINS  0x40C
#define _AS2_SINS 0x40D
#define _B2_SINS  0x40E
#define _C3_SINS  0x40F
#define _CS3_SINS 0x410
#define _D3_SINS  0x411
#define _DS3_SINS 0x412
#define _E3_SINS  0x413
#define _F3_SINS  0x414
#define _FS3_SINS 0x415
#define _G3_SINS  0x416
#define _GS3_SINS 0x417
#define _A3_SINS  0x418
#define _AS3_SINS 0x419
#define _B3_SINS  0x41A
#define _C4_SINS  0x41B
#define _CS4_SINS 0x41C
#define _D4_SINS  0x41D
#define _DS4_SINS 0x41E
#define _E4_SINS  0x41F
#define _F4_SINS  0x420
#define _FS4_SINS 0x421
#define _G4_SINS  0x422
#define _GS4_SINS 0x423
#define _A4_SINS  0x424
#define _AS4_SINS 0x425
#define _B4_SINS  0x426
#define _C5_SINS  0x427
#define _CS5_SINS 0x428
#define _D5_SINS  0x429
#define _DS5_SINS 0x42A
#define _E5_SINS  0x42B
#define _F5_SINS  0x42C
#define _FS5_SINS 0x42D
#define _G5_SINS  0x42E
#define _GS5_SINS 0x42F
#define _A5_SINS  0x430
#define _AS5_SINS 0x431
#define _B5_SINS  0x432
#define _C6_SINS  0x433
#define _CS6_SINS 0x434
#define _D6_SINS  0x435
#define _DS6_SINS 0x436
#define _E6_SINS  0x437
#define _F6_SINS  0x438
#define _FS6_SINS 0x439
#define _G6_SINS  0x43A
#define _GS6_SINS 0x43B
#define _A6_SINS  0x43C
#define _AS6_SINS 0x43D
#define _B6_SINS  0x43E
#define _C7_SINS  0x43F

#define _A1_SAWS  0x440
#define _AS1_SAWS 0x441
#define _B1_SAWS  0x442
#define _C2_SAWS  0x443
#define _CS2_SAWS 0x444
#define _D2_SAWS  0x445
#define _DS2_SAWS 0x446
#define _E2_SAWS  0x447
#define _F2_SAWS  0x448
#define _FS2_SAWS 0x449
#define _G2_SAWS  0x44A
#define _GS2_SAWS 0x44B
#define _A2_SAWS  0x44C
#define _AS2_SAWS 0x44D
#define _B2_SAWS  0x44E
#define _C3_SAWS  0x44F
#define _CS3_SAWS 0x450
#define _D3_SAWS  0x451
#define _DS3_SAWS 0x452
#define _E3_SAWS  0x453
#define _F3_SAWS  0x454
#define _FS3_SAWS 0x455
#define _G3_SAWS  0x456
#define _GS3_SAWS 0x457
#define _A3_SAWS  0x458
#define _AS3_SAWS 0x459
#define _B3_SAWS  0x45A
#define _C4_SAWS  0x45B
#define _CS4_SAWS 0x45C
#define _D4_SAWS  0x45D
#define _DS4_SAWS 0x45E
#define _E4_SAWS  0x45F
#define _F4_SAWS  0x460
#define _FS4_SAWS 0x461
#define _G4_SAWS  0x462
#define _GS4_SAWS 0x463
#define _A4_SAWS  0x464
#define _AS4_SAWS 0x465
#define _B4_SAWS  0x466
#define _C5_SAWS  0x467
#define _CS5_SAWS 0x468
#define _D5_SAWS  0x469
#define _DS5_SAWS 0x46A
#define _E5_SAWS  0x46B
#define _F5_SAWS  0x46C
#define _FS5_SAWS 0x46D
#define _G5_SAWS  0x46E
#define _GS5_SAWS 0x46F
#define _A5_SAWS  0x470
#define _AS5_SAWS 0x471
#define _B5_SAWS  0x472
#define _C6_SAWS  0x473
#define _CS6_SAWS 0x474
#define _D6_SAWS  0x475
#define _DS6_SAWS 0x476
#define _E6_SAWS  0x477
#define _F6_SAWS  0x478
#define _FS6_SAWS 0x479
#define _G6_SAWS  0x47A
#define _GS6_SAWS 0x47B
#define _A6_SAWS  0x47C
#define _AS6_SAWS 0x47D
#define _B6_SAWS  0x47E
#define _C7_SAWS  0x47F

#define _A1_SQUS  0x480
#define _AS1_SQUS 0x481
#define _B1_SQUS  0x482
#define _C2_SQUS  0x483
#define _CS2_SQUS 0x484
#define _D2_SQUS  0x485
#define _DS2_SQUS 0x486
#define _E2_SQUS  0x487
#define _F2_SQUS  0x488
#define _FS2_SQUS 0x489
#define _G2_SQUS  0x48A
#define _GS2_SQUS 0x48B
#define _A2_SQUS  0x48C
#define _AS2_SQUS 0x48D
#define _B2_SQUS  0x48E
#define _C3_SQUS  0x48F
#define _CS3_SQUS 0x490
#define _D3_SQUS  0x491
#define _DS3_SQUS 0x492
#define _E3_SQUS  0x493
#define _F3_SQUS  0x494
#define _FS3_SQUS 0x495
#define _G3_SQUS  0x496
#define _GS3_SQUS 0x497
#define _A3_SQUS  0x498
#define _AS3_SQUS 0x499
#define _B3_SQUS  0x49A
#define _C4_SQUS  0x49B
#define _CS4_SQUS 0x49C
#define _D4_SQUS  0x49D
#define _DS4_SQUS 0x49E
#define _E4_SQUS  0x49F
#define _F4_SQUS  0x4A0
#define _FS4_SQUS 0x4A1
#define _G4_SQUS  0x4A2
#define _GS4_SQUS 0x4A3
#define _A4_SQUS  0x4A4
#define _AS4_SQUS 0x4A5
#define _B4_SQUS  0x4A6
#define _C5_SQUS  0x4A7
#define _CS5_SQUS 0x4A8
#define _D5_SQUS  0x4A9
#define _DS5_SQUS 0x4AA
#define _E5_SQUS  0x4AB
#define _F5_SQUS  0x4AC
#define _FS5_SQUS 0x4AD
#define _G5_SQUS  0x4AE
#define _GS5_SQUS 0x4AF
#define _A5_SQUS  0x4B0
#define _AS5_SQUS 0x4B1
#define _B5_SQUS  0x4B2
#define _C6_SQUS  0x4B3
#define _CS6_SQUS 0x4B4
#define _D6_SQUS  0x4B5
#define _DS6_SQUS 0x4B6
#define _E6_SQUS  0x4B7
#define _F6_SQUS  0x4B8
#define _FS6_SQUS 0x4B9
#define _G6_SQUS  0x4BA
#define _GS6_SQUS 0x4BB
#define _A6_SQUS  0x4BC
#define _AS6_SQUS 0x4BD
#define _B6_SQUS  0x4BE
#define _C7_SQUS  0x4BF

#define _CS7_SQUS 0x4C0
#define _D7_SQUS  0x4C1
#define _DS7_SQUS 0x4C2
#define _E7_SQUS  0x4C3
#define _F7_SQUS  0x4C4
#define _FS7_SQUS 0x4C5
#define _G7_SQUS  0x4C6
#define _GS7_SQUS 0x4C7
#define _A7_SQUS  0x4C8
#define _AS7_SQUS 0x4C9
#define _B7_SQUS  0x4CA
#define _C8_SQUS  0x4CB

#define _1_NOIS   0x4CC
#define _2_NOIS   0x4CD
#define _3_NOIS   0x4CE
#define _4_NOIS   0x4CF
#define _5_NOIS   0x4D0
#define _6_NOIS   0x4D1
#define _7_NOIS   0x4D2
#define _8_NOIS   0x4D3
#define _9_NOIS   0x4D4
#define _10_NOIS  0x4D5
#define _11_NOIS  0x4D6
#define _12_NOIS  0x4D7
#define _13_NOIS  0x4D8
#define _14_NOIS  0x4D9
#define _15_NOIS  0x4DA
#define _16_NOIS  0x4DB
#define _17_NOIS  0x4DC
#define _18_NOIS  0x4DD
#define _19_NOIS  0x4DE
#define _20_NOIS  0x4DF
#define _21_NOIS  0x4E0
#define _22_NOIS  0x4E1
#define _23_NOIS  0x4E2
#define _24_NOIS  0x4E3
#define _25_NOIS  0x4E4
#define _26_NOIS  0x4E5
#define _27_NOIS  0x4E6
#define _28_NOIS  0x4E7
#define _29_NOIS  0x4E8
#define _30_NOIS  0x4E9
#define _31_NOIS  0x4EA
#define _32_NOIS  0x4EB
#define _33_NOIS  0x4EC
#define _34_NOIS  0x4ED
#define _35_NOIS  0x4EE
#define _36_NOIS  0x4EF
#define _37_NOIS  0x4F0
#define _38_NOIS  0x4F1
#define _39_NOIS  0x4F2
#define _40_NOIS  0x4F3
#define _41_NOIS  0x4F4
#define _42_NOIS  0x4F5
#define _43_NOIS  0x4F6
#define _44_NOIS  0x4F7
#define _45_NOIS  0x4F8
#define _46_NOIS  0x4F9
#define _47_NOIS  0x4FA
#define _48_NOIS  0x4FB
#define _49_NOIS  0x4FC
#define _50_NOIS  0x4FD
#define _51_NOIS  0x4FE
#define _52_NOIS  0x4FF

#define _A1_TRIS  0x500
#define _AS1_TRIS 0x501
#define _B1_TRIS  0x502
#define _C2_TRIS  0x503
#define _CS2_TRIS 0x504
#define _D2_TRIS  0x505
#define _DS2_TRIS 0x506
#define _E2_TRIS  0x507
#define _F2_TRIS  0x508
#define _FS2_TRIS 0x509
#define _G2_TRIS  0x50A
#define _GS2_TRIS 0x50B
#define _A2_TRIS  0x50C
#define _AS2_TRIS 0x50D
#define _B2_TRIS  0x50E
#define _C3_TRIS  0x50F
#define _CS3_TRIS 0x510
#define _D3_TRIS  0x511
#define _DS3_TRIS 0x512
#define _E3_TRIS  0x513
#define _F3_TRIS  0x514
#define _FS3_TRIS 0x515
#define _G3_TRIS  0x516
#define _GS3_TRIS 0x517
#define _A3_TRIS  0x518
#define _AS3_TRIS 0x519
#define _B3_TRIS  0x51A
#define _C4_TRIS  0x51B
#define _CS4_TRIS 0x51C
#define _D4_TRIS  0x51D
#define _DS4_TRIS 0x51E
#define _E4_TRIS  0x51F
#define _F4_TRIS  0x520
#define _FS4_TRIS 0x521
#define _G4_TRIS  0x522
#define _GS4_TRIS 0x523
#define _A4_TRIS  0x524
#define _AS4_TRIS 0x525
#define _B4_TRIS  0x526
#define _C5_TRIS  0x527
#define _CS5_TRIS 0x528
#define _D5_TRIS  0x529
#define _DS5_TRIS 0x52A
#define _E5_TRIS  0x52B
#define _F5_TRIS  0x52C
#define _FS5_TRIS 0x52D
#define _G5_TRIS  0x52E
#define _GS5_TRIS 0x52F
#define _A5_TRIS  0x530
#define _AS5_TRIS 0x531
#define _B5_TRIS  0x532
#define _C6_TRIS  0x533
#define _CS6_TRIS 0x534
#define _D6_TRIS  0x535
#define _DS6_TRIS 0x536
#define _E6_TRIS  0x537
#define _F6_TRIS  0x538
#define _FS6_TRIS 0x539
#define _G6_TRIS  0x53A
#define _GS6_TRIS 0x53B
#define _A6_TRIS  0x53C
#define _AS6_TRIS 0x53D
#define _B6_TRIS  0x53E
#define _C7_TRIS  0x53F

#define _A1_DISS  0x540
#define _AS1_DISS 0x541
#define _B1_DISS  0x542
#define _C2_DISS  0x543
#define _CS2_DISS 0x544
#define _D2_DISS  0x545
#define _DS2_DISS 0x546
#define _E2_DISS  0x547
#define _F2_DISS  0x548
#define _FS2_DISS 0x549
#define _G2_DISS  0x54A
#define _GS2_DISS 0x54B
#define _A2_DISS  0x54C
#define _AS2_DISS 0x54D
#define _B2_DISS  0x54E
#define _C3_DISS  0x54F
#define _CS3_DISS 0x550
#define _D3_DISS  0x551
#define _DS3_DISS 0x552
#define _E3_DISS  0x553
#define _F3_DISS  0x554
#define _FS3_DISS 0x555
#define _G3_DISS  0x556
#define _GS3_DISS 0x557
#define _A3_DISS  0x558
#define _AS3_DISS 0x559
#define _B3_DISS  0x55A
#define _C4_DISS  0x55B
#define _CS4_DISS 0x55C
#define _D4_DISS  0x55D
#define _DS4_DISS 0x55E
#define _E4_DISS  0x55F
#define _F4_DISS  0x560
#define _FS4_DISS 0x561
#define _G4_DISS  0x562
#define _GS4_DISS 0x563
#define _A4_DISS  0x564
#define _AS4_DISS 0x565
#define _B4_DISS  0x566
#define _C5_DISS  0x567
#define _CS5_DISS 0x568
#define _D5_DISS  0x569
#define _DS5_DISS 0x56A
#define _E5_DISS  0x56B
#define _F5_DISS  0x56C
#define _FS5_DISS 0x56D
#define _G5_DISS  0x56E
#define _GS5_DISS 0x56F
#define _A5_DISS  0x570
#define _AS5_DISS 0x571
#define _B5_DISS  0x572
#define _C6_DISS  0x573
#define _CS6_DISS 0x574
#define _D6_DISS  0x575
#define _DS6_DISS 0x576
#define _E6_DISS  0x577
#define _F6_DISS  0x578
#define _FS6_DISS 0x579
#define _G6_DISS  0x57A
#define _GS6_DISS 0x57B
#define _A6_DISS  0x57C
#define _AS6_DISS 0x57D
#define _B6_DISS  0x57E
#define _C7_DISS  0x57F

#define _A1_SINT  0x600
#define _AS1_SINT 0x601
#define _B1_SINT  0x602
#define _C2_SINT  0x603
#define _CS2_SINT 0x604
#define _D2_SINT  0x605
#define _DS2_SINT 0x606
#define _E2_SINT  0x607
#define _F2_SINT  0x608
#define _FS2_SINT 0x609
#define _G2_SINT  0x60A
#define _GS2_SINT 0x60B
#define _A2_SINT  0x60C
#define _AS2_SINT 0x60D
#define _B2_SINT  0x60E
#define _C3_SINT  0x60F
#define _CS3_SINT 0x610
#define _D3_SINT  0x611
#define _DS3_SINT 0x612
#define _E3_SINT  0x613
#define _F3_SINT  0x614
#define _FS3_SINT 0x615
#define _G3_SINT  0x616
#define _GS3_SINT 0x617
#define _A3_SINT  0x618
#define _AS3_SINT 0x619
#define _B3_SINT  0x61A
#define _C4_SINT  0x61B
#define _CS4_SINT 0x61C
#define _D4_SINT  0x61D
#define _DS4_SINT 0x61E
#define _E4_SINT  0x61F
#define _F4_SINT  0x620
#define _FS4_SINT 0x621
#define _G4_SINT  0x622
#define _GS4_SINT 0x623
#define _A4_SINT  0x624
#define _AS4_SINT 0x625
#define _B4_SINT  0x626
#define _C5_SINT  0x627
#define _CS5_SINT 0x628
#define _D5_SINT  0x629
#define _DS5_SINT 0x62A
#define _E5_SINT  0x62B
#define _F5_SINT  0x62C
#define _FS5_SINT 0x62D
#define _G5_SINT  0x62E
#define _GS5_SINT 0x62F
#define _A5_SINT  0x630
#define _AS5_SINT 0x631
#define _B5_SINT  0x632
#define _C6_SINT  0x633
#define _CS6_SINT 0x634
#define _D6_SINT  0x635
#define _DS6_SINT 0x636
#define _E6_SINT  0x637
#define _F6_SINT  0x638
#define _FS6_SINT 0x639
#define _G6_SINT  0x63A
#define _GS6_SINT 0x63B
#define _A6_SINT  0x63C
#define _AS6_SINT 0x63D
#define _B6_SINT  0x63E
#define _C7_SINT  0x63F

#define _A1_SAWT  0x640
#define _AS1_SAWT 0x641
#define _B1_SAWT  0x642
#define _C2_SAWT  0x643
#define _CS2_SAWT 0x644
#define _D2_SAWT  0x645
#define _DS2_SAWT 0x646
#define _E2_SAWT  0x647
#define _F2_SAWT  0x648
#define _FS2_SAWT 0x649
#define _G2_SAWT  0x64A
#define _GS2_SAWT 0x64B
#define _A2_SAWT  0x64C
#define _AS2_SAWT 0x64D
#define _B2_SAWT  0x64E
#define _C3_SAWT  0x64F
#define _CS3_SAWT 0x650
#define _D3_SAWT  0x651
#define _DS3_SAWT 0x652
#define _E3_SAWT  0x653
#define _F3_SAWT  0x654
#define _FS3_SAWT 0x655
#define _G3_SAWT  0x656
#define _GS3_SAWT 0x657
#define _A3_SAWT  0x658
#define _AS3_SAWT 0x659
#define _B3_SAWT  0x65A
#define _C4_SAWT  0x65B
#define _CS4_SAWT 0x65C
#define _D4_SAWT  0x65D
#define _DS4_SAWT 0x65E
#define _E4_SAWT  0x65F
#define _F4_SAWT  0x660
#define _FS4_SAWT 0x661
#define _G4_SAWT  0x662
#define _GS4_SAWT 0x663
#define _A4_SAWT  0x664
#define _AS4_SAWT 0x665
#define _B4_SAWT  0x666
#define _C5_SAWT  0x667
#define _CS5_SAWT 0x668
#define _D5_SAWT  0x669
#define _DS5_SAWT 0x66A
#define _E5_SAWT  0x66B
#define _F5_SAWT  0x66C
#define _FS5_SAWT 0x66D
#define _G5_SAWT  0x66E
#define _GS5_SAWT 0x66F
#define _A5_SAWT  0x670
#define _AS5_SAWT 0x671
#define _B5_SAWT  0x672
#define _C6_SAWT  0x673
#define _CS6_SAWT 0x674
#define _D6_SAWT  0x675
#define _DS6_SAWT 0x676
#define _E6_SAWT  0x677
#define _F6_SAWT  0x678
#define _FS6_SAWT 0x679
#define _G6_SAWT  0x67A
#define _GS6_SAWT 0x67B
#define _A6_SAWT  0x67C
#define _AS6_SAWT 0x67D
#define _B6_SAWT  0x67E
#define _C7_SAWT  0x67F

#define _A1_SQUT  0x680
#define _AS1_SQUT 0x681
#define _B1_SQUT  0x682
#define _C2_SQUT  0x683
#define _CS2_SQUT 0x684
#define _D2_SQUT  0x685
#define _DS2_SQUT 0x686
#define _E2_SQUT  0x687
#define _F2_SQUT  0x688
#define _FS2_SQUT 0x689
#define _G2_SQUT  0x68A
#define _GS2_SQUT 0x68B
#define _A2_SQUT  0x68C
#define _AS2_SQUT 0x68D
#define _B2_SQUT  0x68E
#define _C3_SQUT  0x68F
#define _CS3_SQUT 0x690
#define _D3_SQUT  0x691
#define _DS3_SQUT 0x692
#define _E3_SQUT  0x693
#define _F3_SQUT  0x694
#define _FS3_SQUT 0x695
#define _G3_SQUT  0x696
#define _GS3_SQUT 0x697
#define _A3_SQUT  0x698
#define _AS3_SQUT 0x699
#define _B3_SQUT  0x69A
#define _C4_SQUT  0x69B
#define _CS4_SQUT 0x69C
#define _D4_SQUT  0x69D
#define _DS4_SQUT 0x69E
#define _E4_SQUT  0x69F
#define _F4_SQUT  0x6A0
#define _FS4_SQUT 0x6A1
#define _G4_SQUT  0x6A2
#define _GS4_SQUT 0x6A3
#define _A4_SQUT  0x6A4
#define _AS4_SQUT 0x6A5
#define _B4_SQUT  0x6A6
#define _C5_SQUT  0x6A7
#define _CS5_SQUT 0x6A8
#define _D5_SQUT  0x6A9
#define _DS5_SQUT 0x6AA
#define _E5_SQUT  0x6AB
#define _F5_SQUT  0x6AC
#define _FS5_SQUT 0x6AD
#define _G5_SQUT  0x6AE
#define _GS5_SQUT 0x6AF
#define _A5_SQUT  0x6B0
#define _AS5_SQUT 0x6B1
#define _B5_SQUT  0x6B2
#define _C6_SQUT  0x6B3
#define _CS6_SQUT 0x6B4
#define _D6_SQUT  0x6B5
#define _DS6_SQUT 0x6B6
#define _E6_SQUT  0x6B7
#define _F6_SQUT  0x6B8
#define _FS6_SQUT 0x6B9
#define _G6_SQUT  0x6BA
#define _GS6_SQUT 0x6BB
#define _A6_SQUT  0x6BC
#define _AS6_SQUT 0x6BD
#define _B6_SQUT  0x6BE
#define _C7_SQUT  0x6BF

#define _CS7_SQUT 0x6C0
#define _D7_SQUT  0x6C1
#define _DS7_SQUT 0x6C2
#define _E7_SQUT  0x6C3
#define _F7_SQUT  0x6C4
#define _FS7_SQUT 0x6C5
#define _G7_SQUT  0x6C6
#define _GS7_SQUT 0x6C7
#define _A7_SQUT  0x6C8
#define _AS7_SQUT 0x6C9
#define _B7_SQUT  0x6CA
#define _C8_SQUT  0x6CB

#define _1_NOIT   0x6CC
#define _2_NOIT   0x6CD
#define _3_NOIT   0x6CE
#define _4_NOIT   0x6CF
#define _5_NOIT   0x6D0
#define _6_NOIT   0x6D1
#define _7_NOIT   0x6D2
#define _8_NOIT   0x6D3
#define _9_NOIT   0x6D4
#define _10_NOIT  0x6D5
#define _11_NOIT  0x6D6
#define _12_NOIT  0x6D7
#define _13_NOIT  0x6D8
#define _14_NOIT  0x6D9
#define _15_NOIT  0x6DA
#define _16_NOIT  0x6DB
#define _17_NOIT  0x6DC
#define _18_NOIT  0x6DD
#define _19_NOIT  0x6DE
#define _20_NOIT  0x6DF
#define _21_NOIT  0x6E0
#define _22_NOIT  0x6E1
#define _23_NOIT  0x6E2
#define _24_NOIT  0x6E3
#define _25_NOIT  0x6E4
#define _26_NOIT  0x6E5
#define _27_NOIT  0x6E6
#define _28_NOIT  0x6E7
#define _29_NOIT  0x6E8
#define _30_NOIT  0x6E9
#define _31_NOIT  0x6EA
#define _32_NOIT  0x6EB
#define _33_NOIT  0x6EC
#define _34_NOIT  0x6ED
#define _35_NOIT  0x6EE
#define _36_NOIT  0x6EF
#define _37_NOIT  0x6F0
#define _38_NOIT  0x6F1
#define _39_NOIT  0x6F2
#define _40_NOIT  0x6F3
#define _41_NOIT  0x6F4
#define _42_NOIT  0x6F5
#define _43_NOIT  0x6F6
#define _44_NOIT  0x6F7
#define _45_NOIT  0x6F8
#define _46_NOIT  0x6F9
#define _47_NOIT  0x6FA
#define _48_NOIT  0x6FB
#define _49_NOIT  0x6FC
#define _50_NOIT  0x6FD
#define _51_NOIT  0x6FE
#define _52_NOIT  0x6FF

#define _A1_TRIT  0x700
#define _AS1_TRIT 0x701
#define _B1_TRIT  0x702
#define _C2_TRIT  0x703
#define _CS2_TRIT 0x704
#define _D2_TRIT  0x705
#define _DS2_TRIT 0x706
#define _E2_TRIT  0x707
#define _F2_TRIT  0x708
#define _FS2_TRIT 0x709
#define _G2_TRIT  0x70A
#define _GS2_TRIT 0x70B
#define _A2_TRIT  0x70C
#define _AS2_TRIT 0x70D
#define _B2_TRIT  0x70E
#define _C3_TRIT  0x70F
#define _CS3_TRIT 0x710
#define _D3_TRIT  0x711
#define _DS3_TRIT 0x712
#define _E3_TRIT  0x713
#define _F3_TRIT  0x714
#define _FS3_TRIT 0x715
#define _G3_TRIT  0x716
#define _GS3_TRIT 0x717
#define _A3_TRIT  0x718
#define _AS3_TRIT 0x719
#define _B3_TRIT  0x71A
#define _C4_TRIT  0x71B
#define _CS4_TRIT 0x71C
#define _D4_TRIT  0x71D
#define _DS4_TRIT 0x71E
#define _E4_TRIT  0x71F
#define _F4_TRIT  0x720
#define _FS4_TRIT 0x721
#define _G4_TRIT  0x722
#define _GS4_TRIT 0x723
#define _A4_TRIT  0x724
#define _AS4_TRIT 0x725
#define _B4_TRIT  0x726
#define _C5_TRIT  0x727
#define _CS5_TRIT 0x728
#define _D5_TRIT  0x729
#define _DS5_TRIT 0x72A
#define _E5_TRIT  0x72B
#define _F5_TRIT  0x72C
#define _FS5_TRIT 0x72D
#define _G5_TRIT  0x72E
#define _GS5_TRIT 0x72F
#define _A5_TRIT  0x730
#define _AS5_TRIT 0x731
#define _B5_TRIT  0x732
#define _C6_TRIT  0x733
#define _CS6_TRIT 0x734
#define _D6_TRIT  0x735
#define _DS6_TRIT 0x736
#define _E6_TRIT  0x737
#define _F6_TRIT  0x738
#define _FS6_TRIT 0x739
#define _G6_TRIT  0x73A
#define _GS6_TRIT 0x73B
#define _A6_TRIT  0x73C
#define _AS6_TRIT 0x73D
#define _B6_TRIT  0x73E
#define _C7_TRIT  0x73F

#define _A1_DIST  0x740
#define _AS1_DIST 0x741
#define _B1_DIST  0x742
#define _C2_DIST  0x743
#define _CS2_DIST 0x744
#define _D2_DIST  0x745
#define _DS2_DIST 0x746
#define _E2_DIST  0x747
#define _F2_DIST  0x748
#define _FS2_DIST 0x749
#define _G2_DIST  0x74A
#define _GS2_DIST 0x74B
#define _A2_DIST  0x74C
#define _AS2_DIST 0x74D
#define _B2_DIST  0x74E
#define _C3_DIST  0x74F
#define _CS3_DIST 0x750
#define _D3_DIST  0x751
#define _DS3_DIST 0x752
#define _E3_DIST  0x753
#define _F3_DIST  0x754
#define _FS3_DIST 0x755
#define _G3_DIST  0x756
#define _GS3_DIST 0x757
#define _A3_DIST  0x758
#define _AS3_DIST 0x759
#define _B3_DIST  0x75A
#define _C4_DIST  0x75B
#define _CS4_DIST 0x75C
#define _D4_DIST  0x75D
#define _DS4_DIST 0x75E
#define _E4_DIST  0x75F
#define _F4_DIST  0x760
#define _FS4_DIST 0x761
#define _G4_DIST  0x762
#define _GS4_DIST 0x763
#define _A4_DIST  0x764
#define _AS4_DIST 0x765
#define _B4_DIST  0x766
#define _C5_DIST  0x767
#define _CS5_DIST 0x768
#define _D5_DIST  0x769
#define _DS5_DIST 0x76A
#define _E5_DIST  0x76B
#define _F5_DIST  0x76C
#define _FS5_DIST 0x76D
#define _G5_DIST  0x76E
#define _GS5_DIST 0x76F
#define _A5_DIST  0x770
#define _AS5_DIST 0x771
#define _B5_DIST  0x772
#define _C6_DIST  0x773
#define _CS6_DIST 0x774
#define _D6_DIST  0x775
#define _DS6_DIST 0x776
#define _E6_DIST  0x777
#define _F6_DIST  0x778
#define _FS6_DIST 0x779
#define _G6_DIST  0x77A
#define _GS6_DIST 0x77B
#define _A6_DIST  0x77C
#define _AS6_DIST 0x77D
#define _B6_DIST  0x77E
#define _C7_DIST  0x77F

#define _SILENCE  0x800
#define _END      0xFFFF

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

/* Tritone */
#define _4_TRI(x)       x,x+6,x+12,x+18,
#define _8_TRI(x)       _4_TRI(x) _4_TRI(x)
#define _12_TRI(x)      _8_TRI(x) _4_TRI(x)
#define _16_TRI(x)      _12_TRI(x) _4_TRI(x)
#define _20_TRI(x)      _16_TRI(x) _4_TRI(x)
#define _24_TRI(x)      _20_TRI(x) _4_TRI(x)
#define _28_TRI(x)      _24_TRI(x) _4_TRI(x)
#define _32_TRI(x)      _28_TRI(x) _4_TRI(x)
#define _36_TRI(x)      _32_TRI(x) _4_TRI(x)
#define _40_TRI(x)      _36_TRI(x) _4_TRI(x)
#define _44_TRI(x)      _40_TRI(x) _4_TRI(x)
#define _48_TRI(x)      _44_TRI(x) _4_TRI(x)

/* Rock */
#define _8_ROC(x)       x,x+3,x+5,x+7,x+10,x+7,x+5,x+3,
#define _16_ROC(x)      _8_ROC(x) _8_ROC(x)
#define _24_ROC(x)      _8_ROC(x) _16_ROC(x)
#define _32_ROC(x)      _8_ROC(x) _24_ROC(x)
#define _40_ROC(x)      _8_ROC(x) _32_ROC(x)
#define _48_ROC(x)      _8_ROC(x) _40_ROC(x)

/* Ryukyu */
#define _8_RYU(x)       x,x+4,x+5,x+7,x+11,x+7,x+5,x+4,
#define _16_RYU(x)      _8_RYU(x) _8_RYU(x)
#define _24_RYU(x)      _8_RYU(x) _16_RYU(x)
#define _32_RYU(x)      _8_RYU(x) _24_RYU(x)
#define _40_RYU(x)      _8_RYU(x) _32_RYU(x)
#define _48_RYU(x)      _8_RYU(x) _40_RYU(x)

/* Major Enka/ Kyuchou/ Major Pentatnoic */
#define _8_ENK(x)       x,x+2,x+4,x+7,x+9,x+7,x+4,x+2,
#define _16_ENK(x)      _8_ENK(x) _8_ENK(x)
#define _24_ENK(x)      _8_ENK(x) _16_ENK(x)
#define _32_ENK(x)      _8_ENK(x) _24_ENK(x)
#define _40_ENK(x)      _8_ENK(x) _32_ENK(x)
#define _48_ENK(x)      _8_ENK(x) _40_ENK(x)

/* Minor Enka */
#define _8_MEN(x)       x,x+2,x+3,x+7,x+8,x+7,x+3,x+2,
#define _16_MEN(x)      _8_MEN(x) _8_MEN(x)
#define _24_MEN(x)      _8_MEN(x) _16_MEN(x)
#define _32_MEN(x)      _8_MEN(x) _24_MEN(x)
#define _40_MEN(x)      _8_MEN(x) _32_MEN(x)
#define _48_MEN(x)      _8_MEN(x) _40_MEN(x)

/* Dominant */
#define _8_DOM(x)       x,x-5,x,x-5,x,x-5,x,x-5,
#define _16_DOM(x)      _8_DOM(x) _8_DOM(x)
#define _24_DOM(x)      _8_DOM(x) _16_DOM(x)
#define _32_DOM(x)      _8_DOM(x) _24_DOM(x)
#define _40_DOM(x)      _8_DOM(x) _32_DOM(x)
#define _48_DOM(x)      _8_DOM(x) _40_DOM(x)

/* Arpeggios */
#define _24_MAJ_ARP(x)     _6(x) _6(x+4) _6(x+7) _6(x+4)
#define _24_M_ARP(x)       _6(x) _6(x+3) _6(x+7) _6(x+3)
#define _24_MAJ7TH_ARP(x)  _4(x) _4(x+4) _4(x+7) _4(x+11) _4(x+7) _4(x+4)
#define _24_MMAJ7TH_ARP(x) _4(x) _4(x+3) _4(x+7) _4(x+11) _4(x+7) _4(x+3)
#define _24_7TH_ARP(x)     _4(x) _4(x+4) _4(x+7) _4(x+10) _4(x+7) _4(x+4)
#define _24_M7TH_ARP(x)    _4(x) _4(x+3) _4(x+7) _4(x+10) _4(x+7) _4(x+3)
#define _24_ADD9TH_ARP(x)  _4(x) _4(x+4) _4(x+7) _4(x+14) _4(x+7) _4(x+4)
#define _24_9TH_ARP(x)     _3(x) _3(x+4) _3(x+7) _3(x+10) _3(x+14) _3(x+10) _3(x+7) _3(x+4)
#define _24_5TH_ARP(x)     _4(x) _4(x+7) _4(x+14) _4(x+21) _4(x+14) _4(x+7)
#define _24_TRI_ARP(x)     _4(x) _4(x+6) _4(x+12) _4(x+18) _4(x+12) _4(x+6)
#define _24_MIX_ARP(x)     _2(x) _2(x+2) _2(x+4) _2(x+5) _2(x+7) _2(x+9) _2(x+10) _2(x+9) _2(x+7) _2(x+5) _2(x+4) _2(x+2) // Mixolydian, Diatonic on G
#define _24_DOR_ARP(x)     _2(x) _2(x+1) _2(x+3) _2(x+5) _2(x+7) _2(x+8) _2(x+10) _2(x+8) _2(x+7) _2(x+5) _2(x+3) _2(x+1) // Dorian, Diatonic on E
#define _24_PHR_ARP(x)     _2(x) _2(x+2) _2(x+3) _2(x+5) _2(x+7) _2(x+9) _2(x+10) _2(x+9) _2(x+7) _2(x+5) _2(x+3) _2(x+2) // Phrygian, Diatonic on D
#define _24_BLU_ARP(x)     _2(x) _2(x+2) _2(x+3) _2(x+5) _2(x+6) _2(x+7) _2(x+10) _2(x+7) _2(x+6) _2(x+5) _2(x+3) _2(x+2) // Blue-note
#define _24_ROC_ARP(x)     _4(x) _4(x+3) _4(x+5) _4(x+7) _4(x+10) _4(x+7) _4(x+5) _4(x+3) // Rock
#define _24_RYU_ARP(x)     _4(x) _4(x+4) _4(x+5) _4(x+7) _4(x+11) _4(x+7) _4(x+5) _4(x+4) // Ryukyu
#define _24_ENK_ARP(x)     _4(x) _4(x+2) _4(x+4) _4(x+7) _4(x+9) _4(x+7) _4(x+4) _4(x+2) // Major Enka
#define _24_MEN_ARP(x)     _4(x) _4(x+2) _4(x+3) _4(x+7) _4(x+8) _4(x+7) _4(x+3) _4(x+2) // Minor Enka
#define _24_DOM_ARP(x)     _4(x) _4(x-5) _4(x) _4(x-5) _4(x) _4(x-5) _4(x) _4(x-5) // Dominant

#define _48_MAJ_ARP(x)     _12(x) _12(x+4) _12(x+7) _12(x+4)
#define _48_M_ARP(x)       _12(x) _12(x+3) _12(x+7) _12(x+3)
#define _48_MAJ7TH_ARP(x)  _8(x) _8(x+4) _8(x+7) _8(x+11) _8(x+7) _8(x+4)
#define _48_MMAJ7TH_ARP(x) _8(x) _8(x+3) _8(x+7) _8(x+11) _8(x+7) _8(x+3)
#define _48_7TH_ARP(x)     _8(x) _8(x+4) _8(x+7) _8(x+10) _8(x+7) _8(x+4)
#define _48_M7TH_ARP(x)    _8(x) _8(x+3) _8(x+7) _8(x+10) _8(x+7) _8(x+3)
#define _48_ADD9TH_ARP(x)  _8(x) _8(x+4) _8(x+7) _8(x+14) _8(x+7) _8(x+4)
#define _48_9TH_ARP(x)     _6(x) _6(x+4) _6(x+7) _6(x+10) _6(x+14) _6(x+10) _6(x+7) _6(x+4)
#define _48_5TH_ARP(x)     _8(x) _8(x+7) _8(x+14) _8(x+21) _8(x+14) _8(x+7)
#define _48_TRI_ARP(x)     _8(x) _8(x+6) _8(x+12) _8(x+18) _8(x+12) _8(x+6)
#define _48_MIX_ARP(x)     _4(x) _4(x+2) _4(x+4) _4(x+5) _4(x+7) _4(x+9) _4(x+10) _4(x+9) _4(x+7) _4(x+5) _4(x+4) _4(x+2) // Mixolydian, Diatonic on G
#define _48_DOR_ARP(x)     _4(x) _4(x+1) _4(x+3) _4(x+5) _4(x+7) _4(x+8) _4(x+10) _4(x+8) _4(x+7) _4(x+5) _4(x+3) _4(x+1) // Dorian, Diatonic on E
#define _48_PHR_ARP(x)     _4(x) _4(x+2) _4(x+3) _4(x+5) _4(x+7) _4(x+9) _4(x+10) _4(x+9) _4(x+7) _4(x+5) _4(x+3) _4(x+2) // Phrygian, Diatonic on D
#define _48_BLU_ARP(x)     _4(x) _4(x+2) _4(x+3) _4(x+5) _4(x+6) _4(x+7) _4(x+10) _4(x+7) _4(x+6) _4(x+5) _4(x+3) _4(x+2) // Blue-note
#define _48_ROC_ARP(x)     _8(x) _8(x+3) _8(x+5) _8(x+7) _8(x+10) _8(x+7) _8(x+5) _8(x+3) // Rock
#define _48_RYU_ARP(x)     _8(x) _8(x+4) _8(x+5) _8(x+7) _8(x+11) _8(x+7) _8(x+5) _8(x+4) // Ryukyu
#define _48_ENK_ARP(x)     _8(x) _8(x+2) _8(x+4) _8(x+7) _8(x+9) _8(x+7) _8(x+4) _8(x+2) // Major Enka
#define _48_MEN_ARP(x)     _8(x) _8(x+2) _8(x+3) _8(x+7) _8(x+8) _8(x+7) _8(x+3) _8(x+2) // Minor Enka
#define _48_DOM_ARP(x)     _8(x) _8(x-5) _8(x) _8(x-5) _8(x) _8(x-5) _8(x) _8(x-5) // Dominant

/* Decay, Need of Big Volume */
#define _4_DEC(x)       _1(x) _1(x+0x200) _1(x+0x400) _1(x+0x600)
#define _8_DEC(x)       _2(x) _2(x+0x200) _2(x+0x400) _2(x+0x600)
#define _12_DEC(x)      _3(x) _3(x+0x200) _3(x+0x400) _3(x+0x600)
#define _16_DEC(x)      _4(x) _4(x+0x200) _4(x+0x400) _4(x+0x600)
#define _20_DEC(x)      _5(x) _5(x+0x200) _5(x+0x400) _5(x+0x600)
#define _24_DEC(x)      _6(x) _6(x+0x200) _6(x+0x400) _6(x+0x600)
#define _48_DEC(x)      _12(x) _12(x+0x200) _12(x+0x400) _12(x+0x600)

/* Chromatic */
#define _2_CHR(x)       x, x+1,
#define _3_CHR(x)       x, x+1, x+2,
#define _4_CHR(x)       x, x+1, x+2, x+3,
#define _5_CHR(x)       x, x+1, x+2, x+3, x+4,
#define _6_CHR(x)       x, x+1, x+2, x+3, x+4, x+5,
#define _7_CHR(x)       x, x+1, x+2, x+3, x+4, x+5, x+6,
#define _8_CHR(x)       x, x+1, x+2, x+3, x+4, x+5, x+6, x+7,
#define _9_CHR(x)       x, x+1, x+2, x+3, x+4, x+5, x+6, x+7, x+8,
#define _10_CHR(x)      x, x+1, x+2, x+3, x+4, x+5, x+6, x+7, x+8, x+9,
#define _11_CHR(x)      x, x+1, x+2, x+3, x+4, x+5, x+6, x+7, x+8, x+9, x+10,
#define _12_CHR(x)      x, x+1, x+2, x+3, x+4, x+5, x+6, x+7, x+8, x+9, x+10, x+11,

