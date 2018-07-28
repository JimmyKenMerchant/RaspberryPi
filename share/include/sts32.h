/**
 * sts32.h
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

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
#define _AS0 29ull
#define _B0  31ull

#define _C1  33ull
#define _CS1 35ull
#define _D1  37ull
#define _DS1 39ull
#define _E1  41ull
#define _F1  44ull
#define _FS1 46ull
#define _G1  49ull
#define _GS1 52ull
#define _A1  55ull
#define _AS1 58ull
#define _B1  62ull

#define _C2  65ull
#define _CS2 69ull
#define _D2  73ull
#define _DS2 78ull
#define _E2  82ull
#define _F2  87ull
#define _FS2 92ull
#define _G2  98ull
#define _GS2 104ull
#define _A2  110ull
#define _AS2 117ull
#define _B2  123ull

#define _C3  131ull
#define _CS3 139ull
#define _D3  147ull
#define _DS3 156ull
#define _E3  165ull
#define _F3  175ull
#define _FS3 185ull
#define _G3  196ull
#define _GS3 208ull
#define _A3  220ull
#define _AS3 233ull
#define _B3  247ull

#define _C4  262ull
#define _CS4 277ull
#define _D4  294ull
#define _DS4 311ull
#define _E4  330ull
#define _F4  349ull
#define _FS4 370ull
#define _G4  392ull
#define _GS4 415ull
#define _A4  440ull
#define _AS4 466ull
#define _B4  494ull

#define _C5  523ull
#define _CS5 554ull
#define _D5  587ull
#define _DS5 622ull
#define _E5  659ull
#define _F5  698ull
#define _FS5 740ull
#define _G5  784ull
#define _GS5 831ull
#define _A5  880ull
#define _AS5 932ull
#define _B5  988ull

#define _C6  1047ull
#define _CS6 1109ull
#define _D6  1175ull
#define _DS6 1245ull
#define _E6  1319ull
#define _F6  1397ull
#define _FS6 1480ull
#define _G6  1568ull
#define _GS6 1661ull
#define _A6  1760ull
#define _AS6 1865ull
#define _B6  1976ull

#define _C7  2093ull
#define _CS7 2217ull
#define _D7  2349ull
#define _DS7 2489ull
#define _E7  2637ull
#define _F7  2794ull
#define _FS7 2960ull
#define _G7  3136ull
#define _GS7 3322ull
#define _A7  3520ull
#define _AS7 3729ull
#define _B7  3951ull

#define _C8  4186ull
