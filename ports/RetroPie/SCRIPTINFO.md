# Script Information
This document details the usage of scripts included in this directory, as well as information regaing what they install and where.

**Table of Contents**
- Scripts
  - build_install_all.sh
  - install.sh
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


## Installed File Structure
The following file structure will be installed in the `home` directory (`~/`) of `TARGET_USER` by install.sh. \
You can start RetroArch by navigating to this directory and running `./startup.sh`. You can also install your own content or cores by directly copying them into these folders instead of using RetroArch's menu.

```
retroarch
|startup.sh
|start-ra.sh
|retroarch
|emulationstation
|hid-input-provider
|usb-input-provider
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
|
|-resources
| | (Emulation Station textures, etc)
|
|-lua
| |lua
|
|-OpenTTD

.emulationstation
| | (Emulation Station configuration files)
```