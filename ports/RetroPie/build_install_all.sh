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

### Directory Paths
RETROARCH_SRC=${PWD}/../../../RetroArch
EMULATIONSTATION_SRC=${PWD}/../../../EmulationStation

LIBRETRO_2048_SRC=${PWD}/../../../libretro-2048
LIBRETRO_SAMPLES_SRC=${PWD}/../../../libretro-samples
LIBRETRO_MRBOOM_SRC=${PWD}/../../../mrboom-libretro
LIBRETRO_RETRO8_SRC=${PWD}/../../../retro8

RARCH_CORE_INFO_SRC=${PWD}/../../../libretro-core-info
RARCH_ASSETS_SRC=${PWD}/../../../retroarch-assets

SDL_SRC=
RAPIDJSON_SRC=
FREEIMAGE_SRC=

# DO NOT TOUCH BELOW HERE
if [[ -z "$TARGET_IP" ]]; then
    TARGET_IP="<example-ip>"
fi

if [[ -z "$TARGET_USER" ]]; then
    TARGET_USER="qnxuser"
fi

TOP_LEVEL_BUILD_DIR=${PWD} 

echo Targeting user $TARGET_USER@$TARGET_IP 
##########################################################################################

if [[ -z "$QNX_TARGET" ]]; then
    echo Missing QNX SDP Environment variables! Make sure to source ~/qnx800/qnxsdp-env.sh or an equivalent!
    exit 1
fi
if [[ -z "$QNX_HOST" ]]; then
    echo Missing QNX SDP Environment variables! Make sure to source ~/qnx800/qnxsdp-env.sh or an equivalent!
    exit 1
fi

##TODO: Check for wayland/weston and req. screen libraries in $QNX_TARGET/$QNX_HOST

########### RetroArch & Assets ###########
if [ ! -d "$RETROARCH_SRC" ]; then
    git clone https:/github.com/qnx-ports/retroarch.git $RETROARCH_SRC
fi
if [ ! -d "$RARCH_ASSETS_SRC" ]; then
    git clone https://github.com/libretro/retroarch-assets $RARCH_ASSETS_SRC
fi
if [ ! -d "$RARCH_CORE_INFO_SRC" ]; then
    git clone https://github.com/libretro/libretro-core-info $RARCH_CORE_INFO_SRC
fi

########### LibRetro Cores ###########
if [ ! -d "$LIBRETRO_SAMPLES_SRC" ]; then
    git clone https://github.com/libretro/libretro-samples.git $LIBRETRO_SAMPLES_SRC
fi
if [ ! -d "$LIBRETRO_2048_SRC" ]; then
    git clone https://github.com/libretro/libretro-2048 $LIBRETRO_2048_SRC
fi
if [ ! -d "$LIBRETRO_MRBOOM_SRC" ]; then
    git clone https://github.com/Javanaise/mrboom-libretro.git $LIBRETRO_MRBOOM_SRC
fi
if [ ! -d "$LIBRETRO_RETRO8_SRC" ]; then
    git clone https://github.com/Jakz/retro8.git $LIBRETRO_RETRO8_SRC
fi

########### Emulation Station & Deps ###########
if [ ! -d "$EMULATIONSTATION_SRC" ]; then
    echo missing emustat
fi
if [ ! -d "$SDL_SRC" ]; then
    echo missing sdl
fi
if [ ! -d "$RAPIDJSON_SRC" ]; then
    echo missing rapidjson
fi
if [ ! -d "$FREEIMAGE_SRC" ]; then
    echo missing freeimage
fi


##########################################################################################
### Build RetroArch
cd ${TOP_LEVEL_BUILD_DIR}/RetroArch
make install

### Build Sample Cores
cd ${TOP_LEVEL_BUILD_DIR}/libretro-cores/test
make install
cd ${TOP_LEVEL_BUILD_DIR}/libretro-cores/2048
make install
cd ${TOP_LEVEL_BUILD_DIR}/libretro-cores/retro8
make install
cd ${TOP_LEVEL_BUILD_DIR}/libretro-cores/mrboom
make install

#PICO-8 Example !! Maybe swap this for an official one
cd $TOP_LEVEL_BUILD_DIR/staging/aarch64le/rarch-shared/content/
curl https://www.lexaloffle.com/bbs/thumbs/pico8_cmyplatonicsolids-0.png --output pico8_cmyplatonicsolids-0.png 
cd $TOP_LEVEL_BUILD_DIR/staging/x86_64/rarch-shared/content/
curl https://www.lexaloffle.com/bbs/thumbs/pico8_cmyplatonicsolids-0.png --output pico8_cmyplatonicsolids-0.png 

##########################################################################################
### Build Emulation Station
# # Dependencies:
# # SDL
# cd ${TOP_LEVEL_BUILD_DIR}/../SDL
# make install
# # FreeImage
# cd ${TOP_LEVEL_BUILD_DIR}/../FreeImage
# make install
# # RapidJson
# cd ${TOP_LEVEL_BUILD_DIR}/../rapidjson
# make install
# #
# #

# # Main Build
# cd ${TOP_LEVEL_BUILD_DIR}/EmulationStation
# make install

##########################################################################################
#SSH installation via calling install.sh
bash TARGET_USER=$TARGET_USER TARGET_IP=$TARGET_IP TARGET_ARCH=$TARGET_ARCH $TOP_LEVEL_BUILD_DIR/install.sh
