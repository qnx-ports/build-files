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
#TARGET_DIR=
#DO_NOT_REBUILD=TRUE
#DO_NOT_INSTALL=TRUE
#DO_NOT_BUILD_UNUSED=TRUE
#SKIP_OPENTTD=TRUE


### Directory Paths
RETROARCH_SRC=${PWD}/../../../RetroArch
EMULATIONSTATION_SRC=${PWD}/../../../EmulationStation

LIBRETRO_2048_SRC=${PWD}/../../../libretro-2048
LIBRETRO_SAMPLES_SRC=${PWD}/../../../libretro-samples
LIBRETRO_MRBOOM_SRC=${PWD}/../../../mrboom-libretro
LIBRETRO_RETRO8_SRC=${PWD}/../../../retro8
LIBRETRO_FAKE08_SRC=${PWD}/../../../fake-08

RARCH_CORE_INFO_SRC=${PWD}/../../../libretro-core-info
RARCH_ASSETS_SRC=${PWD}/../../../retroarch-assets

SDL_SRC=${PWD}/../../../SDL
RAPIDJSON_SRC=${PWD}/../../../rapidjson
FREEIMAGE_SRC=${PWD}/../../../FreeImage
PUGIXML_SRC=${PWD}/../../../pugixml
NANOSVG_SRC=${PWD}/../../../nanosvg

LUA_SRC=${PWD}/../../../lua
MUSLFLT_SRC=${PWD}/../../../muslflt

OPENTTD_SRC=${PWD}/../../../OpenTTD

ES_THEME_DIR=${PWD}/staging/emulationstation/themes

HID_INPUT_PROCESSOR=${PWD}/../../../qnx-xinput-screen
USB_INPUT_PROCESSOR=${PWD}/../../../usb-to-screen

# DO NOT TOUCH BELOW HERE
if [[ -z "$TARGET_IP" ]]; then
    TARGET_IP="<example-ip>"
fi

if [[ -z "$TARGET_USER" ]]; then
    TARGET_USER="qnxuser"
fi

if [[ -z "$TARGET_DIR" ]]; then
    TARGET_DIR="~/retropie/"
fi

TOP_LEVEL_BUILD_DIR=${PWD} 
WKSP=${PWD}/../../../


##########################################################################################
VERSION=0.2
echo "========================="
echo "[INFO]: Running build_install_all.sh v$VERSION"
if [ ! "$DO_NOT_INSTALL" = "TRUE" ]; then
    echo "        Installing Targeting user $TARGET_USER@$TARGET_IP for location $TARGET_DIR "
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

if [ ! "$SKIP_OPENTTD" = "TRUE" ]; then
    echo "[WARNING] \$SKIP_OPENTTD is not set to \"TRUE\"."
    echo "          This is not yet ready for release and takes a long time to build!"
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
else
    if [ "$TARGET_ARCH" = "aarch64le" ]; then
        _CHECK_BUILD_ARCH=aarch64-le
        _MUSL_BUILD_ARCH=aarch64/so.le
        _STAGING_ARCH=aarch64le
        _OPPOSITE_ARCH=x86_64-o
    else
        _CHECK_BUILD_ARCH=x86_64-o
        _MUSL_BUILD_ARCH=aarch64/so
        _STAGING_ARCH=x86_64
        _OPPOSITE_ARCH=aarch64-le
    fi
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
if [ ! -d "$LIBRETRO_FAKE08_SRC" ]; then
    echo "[INFO]: Missing RetroArch fake-08 core source. Cloning..."
    git clone https://github.com/jtothebell/fake-08.git $LIBRETRO_FAKE08_SRC
    cd $LIBRETRO_FAKE08_SRC
    git submodule init
    git submodule update --recursive
fi

########### Emulation Station & Deps ###########
if [ ! -d "$EMULATIONSTATION_SRC" ]; then
    echo "[INFO]: Missing EmulationStation source. Cloning..."
    git clone https://github.com/qnx-ports/EmulationStation.git $EMULATIONSTATION_SRC
fi
if [ ! -d "$SDL_SRC" ]; then
    echo "[INFO]: Missing SDL source. Cloning..."
    git clone https://github.com/qnx-ports/SDL.git $SDL_SRC
fi
if [ ! -d "$RAPIDJSON_SRC" ]; then
    echo "[INFO]: Missing rapidjson source. Cloning..."
    git clone https://github.com/qnx-ports/rapidjson.git $RAPIDJSON_SRC
fi
if [ ! -d "$FREEIMAGE_SRC" ]; then
    echo "[INFO]: Missing FreeImage source. Cloning..."
    git clone https://github.com/qnx-ports/FreeImage.git $FREEIMAGE_SRC
fi
if [ ! -d "$PUGIXML_SRC" ]; then
    echo "[INFO]: Missing pugixml source. Cloning..."
    git clone https://github.com/zeux/pugixml.git $PUGIXML_SRC
fi
if [ ! -d "$NANOSVG_SRC" ]; then
    echo "[INFO]: Missing nanosvg source. Cloning..."
    git clone https://github.com/memononen/nanosvg.git $NANOSVG_SRC
fi

########### Additional Deps ###########
if [ ! -d "$LUA_SRC" ]; then
    echo "[INFO]: Missing lua source. Cloning..."
    git clone https://github.com/qnx-ports/lua.git $LUA_SRC
fi

if [ ! -d "$MUSLFLT_SRC" ]; then
    echo "[INFO]: Missing lua source. Cloning..."
    git clone https://github.com/qnx-ports/muslflt.git $MUSLFLT_SRC
fi

########### Other ###########
if [ ! -d "$HID_INPUT_PROCESSOR" ]; then
    echo "[INFO]: Missing hid input to screen. Cloning..."
    git clone https://github.com/JaiXJM-BB/qnx-xinput-screen.git $HID_INPUT_PROCESSOR
fi
if [ ! -d "$USB_INPUT_PROCESSOR" ]; then
    echo "[INFO]: Missing hid input to screen. Cloning..."
    git clone https://gitlab.com/qnx/projects/usb-to-screen.git $USB_INPUT_PROCESSOR
fi

if [ ! -d "$OPENTTD_SRC" -a ! "${SKIP_OPENTTD}" = "TRUE" ]; then
    echo "[INFO]: Missing OpenTTD. Cloning..."
    echo "HEY! WE HAVENT SET UP AN OPENTTD PATH YET! SET SKIP_OPENTTD=TRUE"
    exit 1
fi

##########################################################################################
### Build Muslflt
echo "[INFO]: Building muslflt..."
cd ${TOP_LEVEL_BUILD_DIR}/../muslflt
make install
cd ${TOP_LEVEL_BUILD_DIR}/../muslflt/nto-${_CHECK_BUILD_ARCH}/
cp *.so ${TOP_LEVEL_BUILD_DIR}/staging/${_STAGING_ARCH}/lib/

### Build Lua
if [ ! -d "${TOP_LEVEL_BUILD_DIR}/../lua/nto-${_CHECK_BUILD_ARCH}/build/" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building lua..."
    cd ${TOP_LEVEL_BUILD_DIR}/../lua
    rm nto-${_CHECK_BUILD_ARCH}/Makefile.dnm
    if [ "$DO_NOT_BUILD_UNUSED" = "TRUE" ]; then
        touch nto-${_OPPOSITE_ARCH}/Makefile.dnm
    fi
    make install_rpie
else 
    echo "[SKIP]: Skipping lua - build detected."
fi

##########################################################################################
### Build RetroArch
if [ ! -e "${TOP_LEVEL_BUILD_DIR}/RetroArch/nto-${_CHECK_BUILD_ARCH}/build/retroarch" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building RetroArch..."
    cd ${TOP_LEVEL_BUILD_DIR}/RetroArch
    rm nto-${_CHECK_BUILD_ARCH}/Makefile.dnm
    if [ "$DO_NOT_BUILD_UNUSED" = "TRUE" ]; then
        touch nto-${_OPPOSITE_ARCH}/Makefile.dnm
    fi
    make install
else 
    echo "[SKIP]: Skipping RetroArch - build detected."
fi

### Build Sample Cores
if [ ! -d "${TOP_LEVEL_BUILD_DIR}/libretro-cores/test/nto-${_CHECK_BUILD_ARCH}/build/" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building RetroArch test cores..."
    cd ${TOP_LEVEL_BUILD_DIR}/libretro-cores/test
    rm nto-${_CHECK_BUILD_ARCH}/Makefile.dnm
    if [ "$DO_NOT_BUILD_UNUSED" = "TRUE" ]; then
        touch nto-${_OPPOSITE_ARCH}/Makefile.dnm
    fi
    make install
else 
    echo "[SKIP]: Skipping RetroArch Test Cores - build detected."
fi
if [ ! -e "${TOP_LEVEL_BUILD_DIR}/libretro-cores/2048/nto-${_CHECK_BUILD_ARCH}/build/2048_libretro_qnx.so" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building RetroArch 2048 cores..."
    cd ${TOP_LEVEL_BUILD_DIR}/libretro-cores/2048
    rm nto-${_CHECK_BUILD_ARCH}/Makefile.dnm
    if [ "$DO_NOT_BUILD_UNUSED" = "TRUE" ]; then
        touch nto-${_OPPOSITE_ARCH}/Makefile.dnm
    fi
    make install
else 
    echo "[SKIP]: Skipping RetroArch 2048 Core - build detected."
fi
if [ ! -e "${TOP_LEVEL_BUILD_DIR}/libretro-cores/retro8/nto-${_CHECK_BUILD_ARCH}/build/retro8_libretro_qnx.so" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building RetroArch retro8 core..."
    cd ${TOP_LEVEL_BUILD_DIR}/libretro-cores/retro8
    rm nto-${_CHECK_BUILD_ARCH}/Makefile.dnm
    if [ "$DO_NOT_BUILD_UNUSED" = "TRUE" ]; then
        touch nto-${_OPPOSITE_ARCH}/Makefile.dnm
    fi
    make install
else 
    echo "[SKIP]: Skipping RetroArch retro8 Core - build detected."
fi
if [ ! -e "${TOP_LEVEL_BUILD_DIR}/libretro-cores/fake-08/nto-${_CHECK_BUILD_ARCH}/build/fake08_libretro_qnx.so" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building RetroArch fake-08 core..."
    cd ${TOP_LEVEL_BUILD_DIR}/libretro-cores/fake-08
    rm nto-${_CHECK_BUILD_ARCH}/Makefile.dnm
    if [ "$DO_NOT_BUILD_UNUSED" = "TRUE" ]; then
        touch nto-${_OPPOSITE_ARCH}/Makefile.dnm
    fi
    make install
else 
    echo "[SKIP]: Skipping RetroArch fake-08 Core - build detected."
fi
if [ ! -d "${TOP_LEVEL_BUILD_DIR}/libretro-cores/mrboom/nto-${_CHECK_BUILD_ARCH}/build/" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building RetroArch mrboom core..."
    cd ${TOP_LEVEL_BUILD_DIR}/libretro-cores/mrboom
    rm nto-${_CHECK_BUILD_ARCH}/Makefile.dnm
    if [ "$DO_NOT_BUILD_UNUSED" = "TRUE" ]; then
        touch nto-${_OPPOSITE_ARCH}/Makefile.dnm
    fi
    make install
else 
    echo "[SKIP]: Skipping RetroArch mrboom Core - build detected."
fi

#PICO-8 Example Carts!

## CMY platonic solids (test for lua)
cd $TOP_LEVEL_BUILD_DIR/staging/aarch64le/rarch-shared/content/
curl https://www.lexaloffle.com/bbs/cposts/cm/cmyplatonicsolids-0.p8.png --output pico8_cmyplatonicsolids-0.p8.png 
curl https://www.lexaloffle.com/bbs/cposts/cm/cmyplatonicsolids-0.p8.png --output pico8_cmyplatonicsolids-0.p8
cd $TOP_LEVEL_BUILD_DIR/staging/x86_64/rarch-shared/content/
curl https://www.lexaloffle.com/bbs/cposts/cm/cmyplatonicsolids-0.p8.png --output pico8_cmyplatonicsolids-0.p8.png 
curl https://www.lexaloffle.com/bbs/cposts/cm/cmyplatonicsolids-0.p8.png --output pico8_cmyplatonicsolids-0.p8


## Celeste Classic
cd $TOP_LEVEL_BUILD_DIR/staging/aarch64le/rarch-shared/content/
curl https://www.lexaloffle.com/bbs/cposts/1/15133.p8.png --output celeste.p8.png 
curl https://www.lexaloffle.com/bbs/cposts/1/15133.p8.png --output celeste.p8
cd $TOP_LEVEL_BUILD_DIR/staging/x86_64/rarch-shared/content/
curl https://www.lexaloffle.com/bbs/cposts/1/15133.p8.png --output celeste.p8.png 
curl https://www.lexaloffle.com/bbs/cposts/1/15133.p8.png --output celeste.p8

## Celeste Classic 2
cd $TOP_LEVEL_BUILD_DIR/staging/aarch64le/rarch-shared/content/
curl https://www.lexaloffle.com/bbs/cposts/ce/celeste_classic_2-5.p8.png --output celeste_2.p8.png 
curl https://www.lexaloffle.com/bbs/cposts/ce/celeste_classic_2-5.p8.png --output celeste_2.p8
cd $TOP_LEVEL_BUILD_DIR/staging/x86_64/rarch-shared/content/
curl https://www.lexaloffle.com/bbs/cposts/ce/celeste_classic_2-5.p8.png --output celeste_2.p8.png 
curl https://www.lexaloffle.com/bbs/cposts/ce/celeste_classic_2-5.p8.png --output celeste_2.p8

## Just One Boss
cd $TOP_LEVEL_BUILD_DIR/staging/aarch64le/rarch-shared/content/
curl https://www.lexaloffle.com/bbs/cposts/4/49232.p8.png --output just_one_boss.p8.png 
curl https://www.lexaloffle.com/bbs/cposts/4/49232.p8.png --output just_one_boss.p8
cd $TOP_LEVEL_BUILD_DIR/staging/x86_64/rarch-shared/content/
curl https://www.lexaloffle.com/bbs/cposts/4/49232.p8.png --output just_one_boss.p8.png 
curl https://www.lexaloffle.com/bbs/cposts/4/49232.p8.png --output just_one_boss.p8


#RARCH Configs!
cd $TOP_LEVEL_BUILD_DIR
cp configs/retroarch.cfg staging/aarch64le/rarch-shared/
cp configs/retroarch.cfg staging/x86_64/rarch-shared/

##########################################################################################
### Build Emulation Station
## Dependencies:

# SDL
if [ ! -d "${TOP_LEVEL_BUILD_DIR}/../SDL/nto-${_CHECK_BUILD_ARCH}/build/" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building SDL..."
    cd ${TOP_LEVEL_BUILD_DIR}/../SDL
    rm nto-${_CHECK_BUILD_ARCH}/Makefile.dnm
    if [ "$DO_NOT_BUILD_UNUSED" = "TRUE" ]; then
        touch nto-${_OPPOSITE_ARCH}/Makefile.dnm
    fi
    make install_rpie
else 
    echo "[SKIP]: Skipping SDL2 - build detected."
fi
# FreeImage
if [ ! -d "${TOP_LEVEL_BUILD_DIR}/../FreeImage/nto-${_CHECK_BUILD_ARCH}/build/" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building FreeImage..."
    cd ${TOP_LEVEL_BUILD_DIR}/../FreeImage
    rm nto-${_CHECK_BUILD_ARCH}/Makefile.dnm
    if [ "$DO_NOT_BUILD_UNUSED" = "TRUE" ]; then
        touch nto-${_OPPOSITE_ARCH}/Makefile.dnm
    fi
    make install_rpie
else 
    echo "[SKIP]: Skipping FreeImage - build detected."
fi
# RapidJson
if [ ! -d "${TOP_LEVEL_BUILD_DIR}/../rapidjson/nto-${_CHECK_BUILD_ARCH}/build/" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building rapidjson..."
    cd ${TOP_LEVEL_BUILD_DIR}/../rapidjson
    rm nto-${_CHECK_BUILD_ARCH}/Makefile.dnm
    if [ "$DO_NOT_BUILD_UNUSED" = "TRUE" ]; then
        touch nto-${_OPPOSITE_ARCH}/Makefile.dnm
    fi
    make install
else 
    echo "[SKIP]: Skipping rapidjson - build detected."
fi
# pugixml
if [ ! -d "${TOP_LEVEL_BUILD_DIR}/../pugixml/nto-${_CHECK_BUILD_ARCH}/build/" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building pugixml..."
    cd ${TOP_LEVEL_BUILD_DIR}/../pugixml
    rm nto-${_CHECK_BUILD_ARCH}/Makefile.dnm
    if [ "$DO_NOT_BUILD_UNUSED" = "TRUE" ]; then
        touch nto-${_OPPOSITE_ARCH}/Makefile.dnm
    fi
    make install_rpie
else 
    echo "[SKIP]: Skipping pugixml - build detected."
fi
# nanosvg
if [ ! -d "${TOP_LEVEL_BUILD_DIR}/../nanosvg/nto-${_CHECK_BUILD_ARCH}/build/" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    echo "[INFO]: Building nanosvg..."
    cd ${TOP_LEVEL_BUILD_DIR}/../nanosvg
    rm nto-${_CHECK_BUILD_ARCH}/Makefile.dnm
    if [ "$DO_NOT_BUILD_UNUSED" = "TRUE" ]; then
        touch nto-${_OPPOSITE_ARCH}/Makefile.dnm
    fi
    make install
else 
    echo "[SKIP]: Skipping nanosvg - build detected."
fi

# VLC
    echo "[INFO]: Building VLC..."
    cd ${TOP_LEVEL_BUILD_DIR}/../vlc
    rm nto-${_CHECK_BUILD_ARCH}/Makefile.dnm
    if [ "$DO_NOT_BUILD_UNUSED" = "TRUE" ]; then
        touch nto-${_OPPOSITE_ARCH}/Makefile.dnm
    fi
    make install_rpie


# Main Build
if [ ! -d "${TOP_LEVEL_BUILD_DIR}/EmulationStation/nto-${_CHECK_BUILD_ARCH}/build/" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
    cd ${TOP_LEVEL_BUILD_DIR}/EmulationStation
    rm nto-${_CHECK_BUILD_ARCH}/Makefile.dnm
    if [ "$DO_NOT_BUILD_UNUSED" = "TRUE" ]; then
        touch nto-${_OPPOSITE_ARCH}/Makefile.dnm
    fi
    make install
else
    echo "[SKIP]: Skipping Emulation Station - build detected."
fi

## Themes & config
# Stage Configs
cd ${TOP_LEVEL_BUILD_DIR}
mkdir -p ${TOP_LEVEL_BUILD_DIR}/staging
cp -r ${TOP_LEVEL_BUILD_DIR}/configs/emulationstation ${TOP_LEVEL_BUILD_DIR}/staging/
# Make Theme Dir
if [ ! -d "$ES_THEME_DIR" ]; then
    mkdir -p $ES_THEME_DIR
fi
# Clone Themes
if [ ! -d "$ES_THEME_DIR/es-theme-qnx/_inc" ]; then
    echo "Cloning es-theme-qnx"
    cd $ES_THEME_DIR
    git clone https://github.com/qnx-ports/es-theme-qnx es-theme-qnx
fi
##########################################################################################
#OpenTTD
if [ ! "${SKIP_OPENTTD}" = "TRUE" ]; then
    if [ ! -d "${TOP_LEVEL_BUILD_DIR}/staging/${_STAGING_ARCH}/OpenTTD" -o ! "${DO_NOT_REBUILD}" = "TRUE" ]; then
        echo "[INFO]: Building OpenTTD..."
        cd ${TOP_LEVEL_BUILD_DIR}/OpenTTD
        rm nto-${_CHECK_BUILD_ARCH}/Makefile.dnm
        if [ "$DO_NOT_BUILD_UNUSED" = "TRUE" ]; then
            touch nto-${_OPPOSITE_ARCH}/Makefile.dnm
        fi
        make install_rpie
    fi
    cd ${TOP_LEVEL_BUILD_DIR}/staging
    curl https://cdn.openttd.org/opengfx-releases/7.1/opengfx-7.1-all.zip --output opengfx-7.1-all.zip
    unzip opengfx-7.1-all.zip
    cp opengfx-7.1.tar ${_STAGING_ARCH}/OpenTTD/baseset/
fi

##########################################################################################
#xinput
cd $HID_INPUT_PROCESSOR
make
cd $USB_INPUT_PROCESSOR
make

cd ${TOP_LEVEL_BUILD_DIR}
mkdir -p ${TOP_LEVEL_BUILD_DIR}/staging/aarch64le
mkdir -p ${TOP_LEVEL_BUILD_DIR}/staging/x86_64

cp $HID_INPUT_PROCESSOR/aarch64/le/hid_xinput_to_screen ${TOP_LEVEL_BUILD_DIR}/staging/aarch64le/hid_input_provider
cp $HID_INPUT_PROCESSOR/x86_64/o/hid_xinput_to_screen ${TOP_LEVEL_BUILD_DIR}/staging/x86_64/hid_input_provider

cp $USB_INPUT_PROCESSOR/nto-aarch64-le/usb-to-screen ${TOP_LEVEL_BUILD_DIR}/staging/aarch64le/usb_input_provider
cp $USB_INPUT_PROCESSOR/nto-x86_64-o/usb-to-screen ${TOP_LEVEL_BUILD_DIR}/staging/x86_64/usb_input_provider

##########################################################################################

if [ ! "${DO_NOT_INSTALL}" = "TRUE" ]; then
    #SSH installation via calling install.sh
    cd $TOP_LEVEL_BUILD_DIR
    TARGET_USER=$TARGET_USER TARGET_IP=$TARGET_IP TARGET_ARCH=$TARGET_ARCH TARGET_DIR=$TARGET_DIR ./install.sh
fi
