# Script Information
This document details the usage of scripts included in this directory, as well as information regaing what they install and where.

**Table of Contents**
- Scripts
  - build_install_all.sh
  - install.sh
- Build/Install Manifest
- Install File Structure


## Scripts

### `build_install_all.sh`
**Usage:** From `ports/RetroPie`: `<OPTIONS> ./build_install_all.sh` 

**Options:** 

`TARGET_IP=###.###.###.###` \
Sets the IP that the script will attempt to ssh into for installation. 

`TARGET_USER=<username>` \
Sets the user that the script will attempt to ssh into at the target IP. 

`TARGET_ARCH=<aarch64le|x86_64>` \
Sets the installation target's architecture, either aarch64le or x86_64. 

`TARGET_DIR=/path/to/install/loc/` \
Sets the installation directory on the target. Defaults to ~/retroarch (~ evaluated on target).

`DO_NOT_REBUILD=TRUE` \
By default, build_install_all will rebuild all libraries, binaries, and dependencies with its own options. Set this to 'TRUE' to have it detect whether a rebuild is necessary and skip built projects. Note that its detection is not perfect.

`DO_NOT_INSTALL=TRUE` \
Skips the installation step, but still copies files to the staging directory.

`DO_NOT_BUILD_UNUSED=TRUE` \
Skips builds for architectures other than the targeted one. (i.e., only builds for aarch64le and not x86_64 if $TARGET_ARCH=aarch64le)

---- 

### `install.sh`
**Usage:** From `ports/RetroPie`: `<OPTIONS> ./build_install_all.sh` 

**Options:** 

`TARGET_IP=###.###.###.###` \
Sets the IP that the script will attempt to ssh into for installation. 

`TARGET_USER=<username>` \
Sets the user that the script will attempt to ssh into at the target IP. 

`TARGET_ARCH=<aarch64le|x86_64>` \
Sets the installation target's architecture, either aarch64le or x86_64. 

`TARGET_DIR=/path/to/install/loc/` \
Sets the installation directory on the target. Defaults to ~/retroarch (~ evaluated on target).

## Build/Install Manifest

The following projects are built and installed by build_install_all.sh. They are linked here alongside their license. \
An * before a project's name indicates it being installed from upstream, i.e. a source not under QNX. \
Last Updated 2/27/2025 M/D/Y

|                |Name                                           |License|Description|
|----------------|-----------------------------------------------|-------|-----------|
|*Programs*      |[RetroArch](RetroArch/README.md)               |[GPLv3](https://docs.libretro.com/development/licenses/) |A emulator (libretro) frontend, which serves as the host for many of RetroPie's emulators.|
|                |[Emulation Station](EmulationStation/README.md)|[MIT](https://github.com/Aloshi/EmulationStation/blob/master/LICENSE.md)| A controller-based menu that can start various programs and emulators.|
|*Libretro Cores*|[*mrboom](libretro-cores/mrboom/README.md)      |[MIT](https://github.com/Javanaise/mrboom-libretro/blob/master/LICENSE)| A modernized 'Bomberman' clone with many new features.|
|                |[*retro8](libretro-cores/retro8/README.md)      |[GPLv3](https://github.com/Jakz/retro8/blob/master/LICENSE)|A PICO-8 open source implementation for libretro.|
|                |[*2048](libretro-cores/2048/README.md)          |[Public Domain](https://github.com/libretro/libretro-2048/blob/master/COPYING)|A 2048 implementation for libretro.|
|                |[*samples](libretro-cores/test/)                |[MIT](https://github.com/libretro/libretro-samples/blob/master/license)|A series of tests and samples for libretro.|
|*Content*       |[*retro8: cmy platonic solids](https://www.lexaloffle.com/bbs/?pid=cmyplatonicsolids-0)|UNKNOWN|We do not distribute - this is pulled from its source. We may want to find a more "official" demo though.|
|                |[*RetroArch: Assets](https://github.com/libretro/retroarch-assets)  |[CC-BY-4.0](https://github.com/libretro/retroarch-assets/blob/master/COPYING)|RetroArch's assets for its various GUIs.|
|                |[*RetroArch: Info](https://github.com/libretro/libretro-core-info)                          |[MIT](https://github.com/libretro/libretro-core-info/blob/master/COPYING)|RetroArch's core info files for menu display purposes.|
|*Dependencies*  |[VLC](../vlc/README.md)                        |[GPLv2](https://www.videolan.org/legal.html)|VLC Media Player and Engine, needed for Emulation Station.|
|                |[SDL2](../SDL/README.md)                       |[zlib](https://www.libsdl.org/license.php)|SDL library for display purposes. Needed by Emulation Station.|
|                |[pugixml](../pugixml/README.md)                |[MIT](https://pugixml.org/license.html)|.xml parser, needed by Emulation Station.|
|                |[nanosvg](../nanosvg/README.md)                |[zlib](https://github.com/memononen/nanosvg/blob/master/LICENSE.txt)|.svg parsing library, for vector graphics. Needed by Emulation Station.|
|                |[rapidjson](../rapidjson/README.md)            |[MIT](https://github.com/Tencent/rapidjson/blob/master/license.txt)|.json parser, needed by Emulation Station.|
|                |[FreeImage](../FreeImage/README.md)            |[GPLv3, FIPL](https://freeimage.sourceforge.io/license.html)|Multifaceted image library, needed by Emulation Station.|
|                |[Lua](../lua/README.md)            |[MIT](https://www.lua.org/license.html)|Scripting language, needed by many games.|

## Installed File Structure
The following file structure will be installed in the `home` directory (`~/`) of `TARGET_USER` by install.sh. \
You can start RetroArch by navigating to this directory and running `./startup.sh`. You can also install your own content or cores by directly copying them into these folders instead of using RetroArch's menu.

```
retroarch
|startup.sh
|retroarch
|-data
| |-cores
| | |*libretro*.so (retroarch cores here)
| |
| |-info
| | |*.info (retroarch core info files)
| |
| |-assets
| | |(retroarch assets here)
|
|-lib
| |*.so (dependency library files)
|
|-rarch-shared
| |-content
| | |(core-specific content, e.g. retro8 carts)
```