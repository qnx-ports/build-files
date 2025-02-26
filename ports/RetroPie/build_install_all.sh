#!/bin/bash

#HOW TO RUN:
# 1. Clone qnx-ports/build-files into a **new directory**
# 2. Navigate to this file!
# 3. Edit the environment variables below.
# 3. run `source ~/qnxsdpinstallation/qnxsdp-env.sh`
# 4. run `./build_install_all.sh` or `bash ./build_install_all.sh`

##########################################################################################
### Set Up Needed Environment Variables
### Adjust these as needed

### Variables
TARGET_ARCH=aarch64le
#TARGET_IP=
#TARGET_USER=
#DO_NOT_REBUILD=TRUE
#DO_NOT_INSTALL=TRUE

### Directory Paths
RETROARCH_SRC=${PWD}/../../../RetroArch
EMULATIONSTATION_SRC=${PWD}/../../../EmulationStation

LIBRETRO_2048_SRC=${PWD}/../../../libretro-2048
LIBRETRO_SAMPLES_SRC=${PWD}/../../../libretro-samples
LIBRETRO_MRBOOM_SRC=${PWD}/../../../mrboom-libretro
LIBRETRO_RETRO8_SRC=${PWD}/../../../retro8

RARCH_CORE_INFO_SRC=${PWD}/../../../libretro-core-info
RARCH_ASSETS_SRC=${PWD}/../../../retroarch-assets

SDL_SRC=${PWD}/../../../SDL
RAPIDJSON_SRC=${PWD}/../../../rapidjson
FREEIMAGE_SRC=${PWD}/../../../FreeImage
PUGIXML_SRC=${PWD}/../../../pugixml
NANOSVG_SRC=${PWD}/../../../nanosvg

# DO NOT TOUCH BELOW HERE
if [[ -z "$TARGET_IP" ]]; then
    TARGET_IP="<example-ip>"
fi

if [[ -z "$TARGET_USER" ]]; then
    TARGET_USER="qnxuser"
fi

TOP_LEVEL_BUILD_DIR=${PWD} 
WKSP=${PWD}/../../../


##########################################################################################
VERSION=0.1
echo "========================="
echo "[INFO]: Running build_install_all.sh v$VERSION"
if [ ! "$DO_NOT_INSTALL" = "TRUE" ]; then
    echo "        Installing Targeting user $TARGET_USER@$TARGET_IP "
fi
echo "        Target Architecture: $TARGET_ARCH "


if [ "$DO_NOT_REBUILD" = "TRUE" ]; then
    echo "[WARNING]: \$DO_NOT_REBUILD is set to \"TRUE\"." 
    echo "           Script will NOT attempt to build libraries or executables if it thinks they are already built."
fi

if [ "$DO_NOT_INSTALL" = "TRUE" ]; then 
    echo "[WARNING]: \$DO_NOT_INSTALL is set to \"TRUE\"." 
    echo "           Script will NOT attempt to install liraries from staging/$TARGET_ARCH."
fi

echo "========================="

if [[ -z "$QNX_TARGET" ]]; then
    echo "[FATAL]: Missing QNX SDP Environment variables! Make sure to source ~/qnx800/qnxsdp-env.sh or an equivalent!"
    exit 1
fi
if [[ -z "$QNX_HOST" ]]; then
    echo "[FATAL]: Missing QNX SDP Environment variables! Make sure to source ~/qnx800/qnxsdp-env.sh or an equivalent!"
    exit 1
fi
if [ ! "$TARGET_ARCH" = "aarch64le" -a ! "$TARGET_ARCH" = "x86_64" ]; then
    echo "[FATAL]: Invalid Architecture '$TARGET_ARCH'! Allowed: 'aarch64le' 'x86_64'"
    exit 1
fi
sleep 7

##########################################################################################

##TODO: Check for wayland/weston and req. screen libraries in $QNX_TARGET/$QNX_HOST

########### RetroArch & Assets ###########
if [ ! -d "$RETROARCH_SRC" ]; then
    echo "[INFO]: Missing RetroArch source. Cloning..."
    git clone https://github.com/qnx-ports/RetroArch.git $RETROARCH_SRC
fi
if [ ! -d "$RARCH_ASSETS_SRC" ]; then
    echo "[INFO]: Missing RetroArch assets. Cloning..."
    git clone https://github.com/libretro/retroarch-assets $RARCH_ASSETS_SRC
fi
if [ ! -d "$RARCH_CORE_INFO_SRC" ]; then
    echo "[INFO]: Missing RetroArch core information. Cloning..."
    git clone https://github.com/libretro/libretro-core-info $RARCH_CORE_INFO_SRC
fi

########### LibRetro Cores ###########
if [ ! -d "$LIBRETRO_SAMPLES_SRC" ]; then  
    echo "[INFO]: Missing RetroArch core samples. Cloning..."
    git clone https://github.com/libretro/libretro-samples.git $LIBRETRO_SAMPLES_SRC
fi
if [ ! -d "$LIBRETRO_2048_SRC" ]; then
    echo "[INFO]: Missing RetroArch 2048 core source . Cloning..."
    git clone https://github.com/libretro/libretro-2048 $LIBRETRO_2048_SRC
fi
if [ ! -d "$LIBRETRO_MRBOOM_SRC" ]; then
    echo "[INFO]: Missing RetroArch mrboom core source. Cloning..."
    git clone https://github.com/Javanaise/mrboom-libretro.git $LIBRETRO_MRBOOM_SRC
    cd $LIBRETRO_MRBOOM_SRC
    git submodule init
    git submodule update --recursive

fi
if [ ! -d "$LIBRETRO_RETRO8_SRC" ]; then
    echo "[INFO]: Missing RetroArch retro8 core source. Cloning..."
    git clone https://github.com/Jakz/retro8.git $LIBRETRO_RETRO8_SRC
fi

########### Emulation Station & Deps ###########
if [ ! -d "$EMULATIONSTATION_SRC" ]; then
    echo "[INFO]: Missing EmulationStation source. Cloning..."
    git clone git@github.com:qnx-ports/EmulationStation.git $EMULATIONSTATION_SRC
fi
if [ ! -d "$SDL_SRC" ]; then
    echo "[INFO]: Missing SDL source. Cloning..."
    git clone git@github.com:qnx-ports/SDL.git $SDL_SRC
fi
if [ ! -d "$RAPIDJSON_SRC" ]; then
    echo "[INFO]: Missing rapidjson source. Cloning..."
    git clone git@github.com:qnx-ports/rapidjson.git $RAPIDJSON_SRC
fi
if [ ! -d "$FREEIMAGE_SRC" ]; then
    echo "[INFO]: Missing FreeImage source. Cloning..."
    git clone git@github.com:qnx-ports/FreeImage.git $FREEIMAGE_SRC
fi
if [ ! -d "$PUGIXML_SRC" ]; then
    echo "[INFO]: Missing pugixml source. Cloning..."
    git clone https://github.com/zeux/pugixml.git $PUGIXML_SRC
fi
if [ ! -d "$NANOSVG_SRC" ]; then
    echo "[INFO]: Missing nanosvg source. Cloning..."
    git clone https://github.com/memononen/nanosvg.git $NANOSVG_SRC
fi


##########################################################################################


### Build RetroArch
if [ ! -e "${TOP_LEVEL_BUILD_DIR}/RetroArch/nto-aarch64-le/build/retroarch" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building RetroArch..."
    cd ${TOP_LEVEL_BUILD_DIR}/RetroArch
    make install
else 
    echo "[SKIP]: Skipping RetroArch - build detected."
fi

### Build Sample Cores
if [ ! -d "${TOP_LEVEL_BUILD_DIR}/libretro-cores/test/nto-aarch64-le/build/" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building RetroArch test cores..."
    cd ${TOP_LEVEL_BUILD_DIR}/libretro-cores/test
    make install
else 
    echo "[SKIP]: Skipping RetroArch Test Cores - build detected."
fi
if [ ! -e "${TOP_LEVEL_BUILD_DIR}/libretro-cores/2048/nto-aarch64-le/build/2048_libretro_qnx.so" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building RetroArch 2048 cores..."
    cd ${TOP_LEVEL_BUILD_DIR}/libretro-cores/2048
    make install
else 
    echo "[SKIP]: Skipping RetroArch 2048 Core - build detected."
fi
if [ ! -e "${TOP_LEVEL_BUILD_DIR}/libretro-cores/retro8/nto-aarch64-le/build/retro8_libretro_qnx.so" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building RetroArch retro8 core..."
    cd ${TOP_LEVEL_BUILD_DIR}/libretro-cores/retro8
    make install
else 
    echo "[SKIP]: Skipping RetroArch retro8 Core - build detected."
fi
if [ ! -d "${TOP_LEVEL_BUILD_DIR}/libretro-cores/mrboom/nto-aarch64-le/build/" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building RetroArch mrboom core..."
    cd ${TOP_LEVEL_BUILD_DIR}/libretro-cores/mrboom
    make install
else 
    echo "[SKIP]: Skipping RetroArch mrboom Core - build detected."
fi

#PICO-8 Example !! Maybe swap this for an official one
cd $TOP_LEVEL_BUILD_DIR/staging/aarch64le/rarch-shared/content/
curl https://www.lexaloffle.com/bbs/thumbs/pico8_cmyplatonicsolids-0.png --output pico8_cmyplatonicsolids-0.png 
cd $TOP_LEVEL_BUILD_DIR/staging/x86_64/rarch-shared/content/
curl https://www.lexaloffle.com/bbs/thumbs/pico8_cmyplatonicsolids-0.png --output pico8_cmyplatonicsolids-0.png 

##########################################################################################
### Build Emulation Station
## Dependencies:
#==============VLC=================
# SDL
if [ ! -d "${TOP_LEVEL_BUILD_DIR}/../SDL/nto-aarch64-le/build/" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building SDL..."
    cd ${TOP_LEVEL_BUILD_DIR}/../SDL
    make install
else 
    echo "[SKIP]: Skipping SDL2 - build detected."
fi
# FreeImage
if [ ! -d "${TOP_LEVEL_BUILD_DIR}/../FreeImage/nto-aarch64-le/build/" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building FreeImage..."
    cd ${TOP_LEVEL_BUILD_DIR}/../FreeImage
    make install
else 
    echo "[SKIP]: Skipping FreeImage - build detected."
fi
# RapidJson
if [ ! -d "${TOP_LEVEL_BUILD_DIR}/../rapidjson/nto-aarch64-le/build/" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building rapidjson..."
    cd ${TOP_LEVEL_BUILD_DIR}/../rapidjson
    make install
else 
    echo "[SKIP]: Skipping rapidjson - build detected."
fi
# pugixml
if [ ! -d "${TOP_LEVEL_BUILD_DIR}/../pugixml/nto-aarch64-le/build/" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building pugixml..."
    cd ${TOP_LEVEL_BUILD_DIR}/../pugixml
    make install
else 
    echo "[SKIP]: Skipping pugixml - build detected."
fi
# nanosvg
if [ ! -d "${TOP_LEVEL_BUILD_DIR}/../nanosvg/nto-aarch64-le/build/" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building nanosvg..."
    cd ${TOP_LEVEL_BUILD_DIR}/../nanosvg
    make install
else 
    echo "[SKIP]: Skipping nanosvg - build detected."
fi

# # Main Build
# cd ${TOP_LEVEL_BUILD_DIR}/EmulationStation
# make install

##########################################################################################

if [ ! "${DO_NOT_INSTALL}" = "TRUE" ]; then
    #SSH installation via calling install.sh
    cd $TOP_LEVEL_BUILD_DIR
    TARGET_USER=$TARGET_USER TARGET_IP=$TARGET_IP TARGET_ARCH=$TARGET_ARCH ./install.sh
fi
