# QNX RetroPie
This section serves as a home for our fork of **RetroPie** - an amalgamation of various emulators combined into one nice package. You can learn more at [the official RetroPie website](https://retropie.org.uk/)!

**Upstream:** https://github.com/RetroPie \
**Website:** https://retropie.org.uk/ \
**Supports:** QNX 8.0, aarch64 processors. \
\
**Licencing, Dependencies, Accreditations**: Please see [SCRIPTINFO.md](./SCRIPTINFO.md) section "Build/Install Manifest & Licenses" For a full list of upstream projects and links to their respective licenses. The original RetroPie is licensed under [GPL](https://retropie.org.uk/about/legal/).

The main pieces of the Retro*Pie* (forgive my humor) are listed below, alongside their current port and build status.

| | | |
| --- | :---: | :---: |
| RetroArch         | Supported via [Fork](https://github.com/qnx-ports/retroarch) | N/A |
| Emulation Station | Supported via [Fork](https://github.com/qnx-ports/EmulationStation)        | N/A |
| OpenTTD | Supported via [Fork](https://github.com/qnx-ports/OpenTTD)        | N/A |

A Full list of dependencies and their forks can be found later on this page.

*Currently we are planning support for QNX 8.0*, which you can get access to from the ***[QNXE Free Non-Commercial License](https://www.qnx.com/products/everywhere/)***. For RetroPie and dependencies, we only officially support aarch64le architectures (i.e. Raspberry Pi 4/5), however files for x86_64 devices can also be built and installed via the provided build script.

For more specifics on RetroArch and supported Cores, as well as Emulation Station, visit their sections below.

## Build & Install

### Via Script
To successfully build/install RetroPie on a QNX device, follow these steps:

**BEFORE STARTING, Make sure you have the following installed on your Linux (Ideally Ubuntu) Host machine**: 
- bash
- curl
- unzip
- git
- gcc and g++
- autotools, including autopoint and gettext
- nasm 
- yasm

1. **Ensure you have a QNX License.** If not, see how to get one here: [QNXE Free Non-Commercial License](https://www.qnx.com/products/everywhere/). You must also install the Wayland/Weston, Base Graphics, Vulkan SDK, and any board-specific (i.e. Quickstart Image or Raspberry Pi Board Support) packages from [QNX Software Centre](https://www.qnx.com/download/group.html?programid=29178).

2. **Acquire a suitable Target.** If you have a QNXE license and a Raspberry Pi 4, it is recommended you follow the [instructions for setting up our quickstart image](https://gitlab.com/qnx/quick-start-images/raspberry-pi-qnx-8.0-quick-start-image/-/wikis/home). Your target should have aarch64 or x86_64 architecture and be running QNX 8.0 or newer.

3. **Install Software Centre dependencies.** Some dependencies are not installed into your QNX host materials by default. You will need to run qnxsoftwarecentre.
```bash
# Boot up softwarecentre
cd ~/qnx/qnxsoftwarecentre
./qnxsoftwarecentre
```
Install these packages:
- com.qnx.qnx800.target.screen.fonts.engine (Font Support via FreeType and more)
- com.qnx.qnx800.target.screen.screen_utils (Utilities for screen/graphics applications)
- com.qnx.qnx800.target.screen.base.wfd_server (More screen utilities)
- com.qnx.qnx800.target.screen.vulkansc (Vulkan-based rendering support)
- com.qnx.qnx800.target.screen.vulkansc.sdk (Vulkan-based rendering support)

4. **Run build_install_all.sh with your target's ip and username.** Example seen below. More information on the build_install_all script can be found in SCRIPTINFO.md. You must have ssh set up for installation to target. 
```bash
source ~/qnx800/qnxsdp-env.sh
TARGET_IP="###.###.###.###" TARGET_USER="qnxuser" ./build_install_all
``` 
NOTE: Currently only RetroArch and an assortment of cores will be installed. To start RetroArch, navigate to ~/retroarch on your target and run startup.sh via `./startup.sh`.


### Manually
You can also 'pick and choose' what specifically you want built by navigating to the relevant folder and running `make install`. This applies both to applications such as RetroArch and content such as its cores (stored under the libretro-cores section). 

`make install` on any subdirectory will install its relevant files to staging/<architecture> with the correct file structure, the contents of which can then be manually copied to your machine. 
```bash 
scp -r staging/aarch64le/* <hostname>:/install/file/path/
```


# RetroArch

RetroArch is an emulator backend used for most of the gaming related content within RetroPie. \
It works using a "Core" and "Content" system - Think of RetroArch as your TV, displaying content and sound. A "Core" is your game console - whichever you load or "Connect to the TV" handles input and what games you can play. Your "Content" is simply a collection of games or other stuff that you can play on the core.

## Core List
You can build any supported core via the following process. Instructions and details are also included in the README.md files in each subdirectory.
```bash
# 1. Source your QNX SDP installation
source ~/qnx800/qnxsdp-env.sh
# 2. Clone the relevant git repo, linked in the table below, into the same directory where you cloned this repo
git clone <source>
# 3. Navigate to the relevant subdirectory and run make or make install
cd RetroArch && make install
```
#### Supported
| Core | Description |
| -- | -- |
| [2048](https://github.com/libretro/libretro-2048) | The game of 2048. Upstream can be built directly. |
| [Retro8](https://github.com/Jakz/retro8) | A [PICO-8](https://www.lexaloffle.com/pico-8.php) implementation for RetroArch. Currently has minor issues. |
| [Fake08](https://github.com/jtothebell/fake-08/) | A [PICO-8](https://www.lexaloffle.com/pico-8.php) implementation for RetroArch. |
| [MrBoom](https://github.com/Javanaise/mrboom-libretro) | A port of BomberMan for MSDOS to RetroArch. Requires minor patching to build. |
| [libretro-samples](https://github.com/libretro/libretro-samples) | Sample and demo apps for LibRetro. |


# Emulation Station

Emulation Station is a controller friendly, highly customizable frontend which we use to easily tie together all of the different parts of RetroPie.

It's highly customizable via xml files. The presets for RetroPie for QNX can be found in the [configs folder in this directory](configs/emulationstation). These group different games and startup commands under submenus, can can also support video files.

Also important to note - some aspects of Emulation Station are installed under ~/.emulationstation by default, including these configurations and any themes. **Multiple installations of Retropie on one QNX User Profile may collide with each other because of this**.

## Theming

We have a custom, QNX-Specific Emulation Station theme. It is available at [qnx-ports/es-theme-qnx](https://github.com/qnx-ports/es-theme-qnx). 

# Dependency Manifest & Licenses

The following projects are built and installed by build_install_all.sh. They are linked here alongside their license. \
An * before a project's name indicates it being installed from upstream, i.e. a source not under QNX. \
Last Updated 7/18/2025 M/D/Y

|                |Name                                           |License|Description|
|----------------|-----------------------------------------------|-------|-----------|
|*Programs*      |[RetroArch](RetroArch/README.md)               |[GPLv3](https://docs.libretro.com/development/licenses/) |A emulator (libretro) frontend, which serves as the host for many of RetroPie's emulators.|
|                |[Emulation Station](EmulationStation/README.md)|[MIT](https://github.com/Aloshi/EmulationStation/blob/master/LICENSE.md)| A controller-based menu that can start various programs and emulators.|
|*Libretro Cores*|[*mrboom](libretro-cores/mrboom/README.md)      |[MIT](https://github.com/Javanaise/mrboom-libretro/blob/master/LICENSE)| A modernized 'Bomberman' clone with many new features.|
|                |[*retro8](libretro-cores/retro8/README.md)      |[GPLv3](https://github.com/Jakz/retro8/blob/master/LICENSE)|An older PICO-8 open source implementation for libretro.|
|                |[*fake-08](libretro-cores/fake-08/README.md)      |[MIT](https://github.com/jtothebell/fake-08/blob/master/LICENSE.MD)|A modern PICO-8 open source implementation for libretro.|
|                |[*2048](libretro-cores/2048/README.md)          |[Public Domain](https://github.com/libretro/libretro-2048/blob/master/COPYING)|A 2048 implementation for libretro.|
|                |[*samples](libretro-cores/test/)                |[MIT](https://github.com/libretro/libretro-samples/blob/master/license)|A series of tests and samples for libretro.|
|*Content*       |[*fake-08/retro8: cmy platonic solids](https://www.lexaloffle.com/bbs/?pid=cmyplatonicsolids-0)|None, N/A|We do not distribute - this is pulled from its source via CURL.|
|                |[*fake-08/retro8: Celeste Classic](https://www.lexaloffle.com/bbs/?pid=11722)|None, N/A|We do not distribute - this is pulled from its source via CURL.|
|                |[*fake-08/retro8: Celeste Classic 2](https://www.lexaloffle.com/bbs/?pid=86783)|CC4-BY-NC-SA|We do not distribute - this is pulled from its source via CURL.|
|                |[*fake-08/retro8: Just One Boss](https://www.lexaloffle.com/bbs/?pid=49234)|CC4-BY-NC-SA|We do not distribute - this is pulled from its source via CURL.|
|                |[*RetroArch: Assets](https://github.com/libretro/retroarch-assets)  |[CC-BY-4.0](https://github.com/libretro/retroarch-assets/blob/master/COPYING)|RetroArch's assets for its various GUIs.|
|                |[*RetroArch: Info](https://github.com/libretro/libretro-core-info)                          |[MIT](https://github.com/libretro/libretro-core-info/blob/master/COPYING)|RetroArch's core info files for menu display purposes.|
|                |[OpenTTD](OpenTTD/README.md)            |[GPLv2](https://wiki.openttd.org/License)|Transport Tycoon Game.|
|                |[OpenGFX](OpenTTD/README.md)            |[GPLv2](https://github.com/OpenTTD/OpenGFX/blob/master/README.md#50-license)|Graphics for above.|
|                |[es-theme-qnx](https://github.com/qnx-ports/es-theme-qnx) | None |Emulation Station's Theme.|
|*Dependencies*  |[VLC](../vlc/README.md)                        |[GPLv2](https://www.videolan.org/legal.html)|VLC Media Player and Engine, needed for Emulation Station.|
|                |[SDL2](../SDL/README.md)                       |[zlib](https://www.libsdl.org/license.php)|SDL library for display purposes. Needed by Emulation Station.|
|                |[pugixml](../pugixml/README.md)                |[MIT](https://pugixml.org/license.html)|.xml parser, needed by Emulation Station.|
|                |[nanosvg](../nanosvg/README.md)                |[zlib](https://github.com/memononen/nanosvg/blob/master/LICENSE.txt)|.svg parsing library, for vector graphics. Needed by Emulation Station.|
|                |[rapidjson](../rapidjson/README.md)            |[MIT](https://github.com/Tencent/rapidjson/blob/master/license.txt)|.json parser, needed by Emulation Station.|
|                |[FreeImage](../FreeImage/README.md)            |[GPLv3, FIPL](https://freeimage.sourceforge.io/license.html)|Multifaceted image library, needed by Emulation Station.|
|                |[Lua](../lua/README.md)            |[MIT](https://www.lua.org/license.html)|Scripting language, needed by many games.|

