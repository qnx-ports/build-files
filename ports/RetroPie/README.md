# RetroPie
This section serves as a home for our fork of **RetroPie** - an amalgamation of various emulators combined into one nice package. You can learn more at [the official RetroPie website](https://retropie.org.uk/)!

The main pieces of the Retro*Pie* (forgive my humor) are listed below, alongside their current port and build status.

| | | |
| --- | :---: | :---: |
| RetroArch         | Supported via [Fork](https://github.com/qnx-ports/retroarch) | N/A |
| Emulation Station | In Progress       | N/A |
| RetroPie Menu     | Planned           | N/A |

*Currently we are planning support for QNX 8.0*, which you can get access to from the ***[QNXE Free Non-Commercial License]()***. For RetroPie and dependencies, we only officially support aarch64le architectures (i.e. Raspberry Pi 4/5), however files for x86_64 devices can also be built and installed via the provided build script.

For more specifics on RetroArch and supported Cores, as well as Emulation Station, visit their sections below.

## Build & Install

### Via Script
To successfully build/install RetroPie on a QNX device, follow these steps:
1. **Ensure you have a QNX License.** If not, see how to get one here: [QNXE Free Non-Commercial License]().

2. **Acquire a suitable Target.** If you have a QNXE license and a Raspberry Pi 4, it is recommended you follow the [instructions for setting up our quickstart image](). Your target should have aarch64 or x86_64 architecture and be running QNX 8.0 or newer.

3. **Run build_install_all.sh with your target's ip and username.** Example seen below. You must have ssh installed. 
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
| [2048](LINK TODO) | The game of 2048. Upstream can be built directly. |
| [Retro8](LINK TODO) | A [PICO-8](LINK TODO) implementation for RetroArch. Currently has minor issues. |
| [MrBoom](LINK TODO) | A port of BomberMan for MSDOS to RetroArch. Requires minor patching to build. |
| [libretro-samples](LINK TODO) | Sample and demo apps for LibRetro. |

#### Planned
| Core | Description |
| -- | -- |
| TODO | TODO |

# Emulation Station
Marked TODO

# TODO

##RETROARCH:
Done - replaced w screen system_Requires qt for bps (is this a qt package??)
??check on this_Requires wayland sdp package, need to add .pc files. Reach out to graphics team? - forged them
Done_Need a HAVE_DYLIB fix.

##EMULATIONSTATION:
Freetype satisfied!
FreeImage 3.18.0 Ported
_SDL 2 Requires Work

Curl - in theory exists?

vlc?

RapidJSON complete