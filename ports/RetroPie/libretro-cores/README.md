# libretro cores
libretro is a generic API for sound, graphics, and input that it tailored for emulation. Emulators compatible with libretro provide their outputs and inputs in the form of libretro's generic functions, which can then be called from an application to arbitrarily work with any emulator which provides the same functions.

To make this behaviour work, emulators are compiled into shared object (.so) library files, which can be loaded from a host application. These shared objects are known as 'libretro cores'.

## QNX Conversion
Because they are generic and do not directly access audio, video, or input, compatibility for QNX is often not difficult to implement. The provided patchfile `libretro-generic.patch` is able to convert most libretro cores' makefiles into qnx-compatible versions. Apply it to a libretro core repository as you would any other.

## Running a libretro core
To do this, you will need an application capable of running libretro cores. RetroArch is the official one, and has a version compatible with qnx available. See [its README](../RetroArch/README.md) for more info.