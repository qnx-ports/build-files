#! /bin/sh

#HOW TO RUN:
# 1. Clone qnx-ports/build-files into a **new directory**
# 2. Navigate to this file!
# 3. Edit the environment variables below.
# 3. run `source ~/qnxsdpinstallation/qnxsdp-env.sh`
# 4. run `./build_install_all.sh`

##########################################################################################
### Set Up Needed Environment Variables
# Adjust these as needed
RETROARCH_SRC=${PWD}/../../../RetroArch
EMULATIONSTATION_SRC=${PWD}/../../../EmulationStation
LIBRETRO_2048_SRC=${PWD}/../../../libretro-2048
EMULATIONSTATION_SRC=
SDL_SRC=
RAPIDJSON_SRC=
FREEIMAGE_SRC=
TARGET_ARCH=aarch64le

if [[ -z "${TARGET_IP}" ]]; then
    TARGET_IP="<example-ip>"
fi

if [[ -z "${TARGET_USER}" ]]; then
    TARGET_USER="qnxuser"
fi


# DO NOT TOUCH
TOP_LEVEL_BUILD_DIR=${PWD} 

##########################################################################################

if [ ! -d "$RETROARCH_SRC" ]; then
    echo git clone TODO:: RETROARCH URL
fi

#RARCH ASSETS HERE

#RETRO-8 HERE

#mrboom assets here - need a git port or a patchfile. (prefer patch)

if [ ! -d "$LIBRETRO_SAMPLES_SRC" ]; then
    echo git clone TODO:: RETROARCH URL
fi
if [ ! -d "$LIBRETRO_2048_SRC" ]; then
    echo git clone TODO:: RETROARCH URL
fi
if [ ! -d "$EMULATIONSTATION_SRC" ]; then
    echo git clone TODO:: RETROARCH URL
fi
if [ ! -d "$SDL_SRC" ]; then
    echo git clone TODO:: RETROARCH URL
fi
if [ ! -d "$RAPIDJSON_SRC" ]; then
    echo git clone TODO:: RETROARCH URL
fi
if [ ! -d "$FREEIMAGE_SRC" ]; then
    echo git clone TODO:: RETROARCH URL
fi

# https://github.com/libretro/libretro-core-info


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
#SSH installation
ssh ${TARGET_USER}@${TARGET_IP} "mkdir -p /data/home/${TARGET_USER}/retroarch/"
scp -r ${TOP_LEVEL_BUILD_DIR}/staging/${TARGET_ARCH}/* ${TARGET_USER}@${TARGET_IP}:/data/home/${TARGET_USER}/retroarch/