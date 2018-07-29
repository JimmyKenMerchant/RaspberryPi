/**
 * sts32.h
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

#define STS32_END 0x00,0x00
#define STS32_MAG 16
#define STS32_FAL 16

#define _1LR(x,y) x,y,
#define _2LR(x,y) x,y,x,y,
#define _3LR(x,y) x,y,x,y,x,y,
#define _4LR(x,y) x,y,x,y,x,y,x,y,
#define _5LR(x,y) x,y,x,y,x,y,x,y,x,y,
#define _6LR(x,y) x,y,x,y,x,y,x,y,x,y,x,y,
#define _7LR(x,y) x,y,x,y,x,y,x,y,x,y,x,y,x,y,
#define _8LR(x,y) x,y,x,y,x,y,x,y,x,y,x,y,x,y,x,y,
#define _9LR(x,y) x,y,x,y,x,y,x,y,x,y,x,y,x,y,x,y,x,y,
#define _10LR(x,y) x,y,x,y,x,y,x,y,x,y,x,y,x,y,x,y,x,y,x,y,
#define _11LR(x,y) _10LR(x,y) _1LR(x,y)
#define _12LR(x,y) _10LR(x,y) _2LR(x,y)
#define _13LR(x,y) _10LR(x,y) _3LR(x,y)
#define _14LR(x,y) _10LR(x,y) _4LR(x,y)
#define _15LR(x,y) _10LR(x,y) _5LR(x,y)
#define _16LR(x,y) _10LR(x,y) _6LR(x,y)
#define _17LR(x,y) _10LR(x,y) _7LR(x,y)
#define _18LR(x,y) _10LR(x,y) _8LR(x,y)
#define _19LR(x,y) _10LR(x,y) _9LR(x,y)
#define _20LR(x,y) _10LR(x,y) _10LR(x,y)
#define _21LR(x,y) _20LR(x,y) _1LR(x,y)
#define _22LR(x,y) _20LR(x,y) _2LR(x,y)
#define _23LR(x,y) _20LR(x,y) _3LR(x,y)
#define _24LR(x,y) _20LR(x,y) _4LR(x,y)
#define _25LR(x,y) _20LR(x,y) _5LR(x,y)
#define _26LR(x,y) _20LR(x,y) _6LR(x,y)
#define _27LR(x,y) _20LR(x,y) _7LR(x,y)
#define _28LR(x,y) _20LR(x,y) _8LR(x,y)
#define _29LR(x,y) _20LR(x,y) _9LR(x,y)
#define _30LR(x,y) _20LR(x,y) _10LR(x,y)
#define _31LR(x,y) _30LR(x,y) _1LR(x,y)
#define _32LR(x,y) _30LR(x,y) _2LR(x,y)
#define _33LR(x,y) _30LR(x,y) _3LR(x,y)
#define _34LR(x,y) _30LR(x,y) _4LR(x,y)
#define _35LR(x,y) _30LR(x,y) _5LR(x,y)
#define _36LR(x,y) _30LR(x,y) _6LR(x,y)
#define _37LR(x,y) _30LR(x,y) _7LR(x,y)
#define _38LR(x,y) _30LR(x,y) _8LR(x,y)
#define _39LR(x,y) _30LR(x,y) _9LR(x,y)
#define _40LR(x,y) _30LR(x,y) _10LR(x,y)
#define _41LR(x,y) _40LR(x,y) _1LR(x,y)
#define _42LR(x,y) _40LR(x,y) _2LR(x,y)
#define _43LR(x,y) _40LR(x,y) _3LR(x,y)
#define _44LR(x,y) _40LR(x,y) _4LR(x,y)
#define _45LR(x,y) _40LR(x,y) _5LR(x,y)
#define _46LR(x,y) _40LR(x,y) _6LR(x,y)
#define _47LR(x,y) _40LR(x,y) _7LR(x,y)
#define _48LR(x,y) _40LR(x,y) _8LR(x,y)
#define _49LR(x,y) _40LR(x,y) _9LR(x,y)
#define _50LR(x,y) _40LR(x,y) _10LR(x,y)
#define _51LR(x,y) _50LR(x,y) _1LR(x,y)
#define _52LR(x,y) _50LR(x,y) _2LR(x,y)
#define _53LR(x,y) _50LR(x,y) _3LR(x,y)
#define _54LR(x,y) _50LR(x,y) _4LR(x,y)
#define _55LR(x,y) _50LR(x,y) _5LR(x,y)
#define _56LR(x,y) _50LR(x,y) _6LR(x,y)
#define _57LR(x,y) _50LR(x,y) _7LR(x,y)
#define _58LR(x,y) _50LR(x,y) _8LR(x,y)
#define _59LR(x,y) _50LR(x,y) _9LR(x,y)
#define _60LR(x,y) _50LR(x,y) _10LR(x,y)

#define _A0  28
#define _AS0 29ul
#define _B0  31ul

#define _C1  33ul
#define _CS1 35ul
#define _D1  37ul
#define _DS1 39ul
#define _E1  41ul
#define _F1  44ul
#define _FS1 46ul
#define _G1  49ul
#define _GS1 52ul
#define _A1  55ul
#define _AS1 58ul
#define _B1  62ul

#define _C2  65ul
#define _CS2 69ul
#define _D2  73ul
#define _DS2 78ul
#define _E2  82ul
#define _F2  87ul
#define _FS2 92ul
#define _G2  98ul
#define _GS2 104ul
#define _A2  110ul
#define _AS2 117ul
#define _B2  123ul

#define _C3  131ul
#define _CS3 139ul
#define _D3  147ul
#define _DS3 156ul
#define _E3  165ul
#define _F3  175ul
#define _FS3 185ul
#define _G3  196ul
#define _GS3 208ul
#define _A3  220ul
#define _AS3 233ul
#define _B3  247ul

#define _C4  262ul
#define _CS4 277ul
#define _D4  294ul
#define _DS4 311ul
#define _E4  330ul
#define _F4  349ul
#define _FS4 370ul
#define _G4  392ul
#define _GS4 415ul
#define _A4  440ul
#define _AS4 466ul
#define _B4  494ul

#define _C5  523ul
#define _CS5 554ul
#define _D5  587ul
#define _DS5 622ul
#define _E5  659ul
#define _F5  698ul
#define _FS5 740ul
#define _G5  784ul
#define _GS5 831ul
#define _A5  880ul
#define _AS5 932ul
#define _B5  988ul

#define _C6  1047ul
#define _CS6 1109ul
#define _D6  1175ul
#define _DS6 1245ul
#define _E6  1319ul
#define _F6  1397ul
#define _FS6 1480ul
#define _G6  1568ul
#define _GS6 1661ul
#define _A6  1760ul
#define _AS6 1865ul
#define _B6  1976ul

#define _C7  2093ul
#define _CS7 2217ul
#define _D7  2349ul
#define _DS7 2489ul
#define _E7  2637ul
#define _F7  2794ul
#define _FS7 2960ul
#define _G7  3136ul
#define _GS7 3322ul
#define _A7  3520ul
#define _AS7 3729ul
#define _B7  3951ul

#define _C8  4186ul
