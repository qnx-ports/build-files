#! /bin/bash

TOP_LEVEL_BUILD_DIR=${PWD} 
WKSP=${PWD}/../../../

VERSION=0.1
echo "========================="
echo "[INFO]: Running build_install_all.sh v$VERSION"
echo "        QUIT WITHIN 5 SECONDS BEFORE ALL BUILDS ARE WIPED."
echo "========================="
sleep 6

### Clean muslflt
echo "[INFO]: Cleaning muslflt..."
cd ${TOP_LEVEL_BUILD_DIR}/../muslflt
make clean

### Clean lua
echo "[INFO]: Cleaning lua..."
cd ${TOP_LEVEL_BUILD_DIR}/../lua
make clean

### Clean RetroArch
echo "[INFO]: Cleaning RetroArch..."
cd ${TOP_LEVEL_BUILD_DIR}/RetroArch
make clean

### Clean Sample Cores
echo "[INFO]: Cleaning RetroArch test cores..."
cd ${TOP_LEVEL_BUILD_DIR}/libretro-cores/test
make clean

echo "[INFO]: Cleaning RetroArch 2048 cores..."
cd ${TOP_LEVEL_BUILD_DIR}/libretro-cores/2048
make clean

echo "[INFO]: Cleaning RetroArch retro8 core..."
cd ${TOP_LEVEL_BUILD_DIR}/libretro-cores/retro8
make clean

echo "[INFO]: Cleaning RetroArch fake-08 core..."
cd ${TOP_LEVEL_BUILD_DIR}/libretro-cores/fake-08
make clean

echo "[INFO]: Cleaning RetroArch mrboom core..."
cd ${TOP_LEVEL_BUILD_DIR}/libretro-cores/mrboom
make clean

##########################################################################################
### Build Emulation Station
## Dependencies:
#==============VLC=================

# SDL
echo "[INFO]: Cleaning SDL..."
cd ${TOP_LEVEL_BUILD_DIR}/../SDL
make clean

# FreeImage
echo "[INFO]: Cleaning FreeImage..."
cd ${TOP_LEVEL_BUILD_DIR}/../FreeImage
make clean

# RapidJson
echo "[INFO]: Cleaning rapidjson..."
cd ${TOP_LEVEL_BUILD_DIR}/../rapidjson
make clean

# pugixml
echo "[INFO]: Cleaning pugixml..."
cd ${TOP_LEVEL_BUILD_DIR}/../pugixml
make clean

# nanosvg
echo "[INFO]: Cleaning nanosvg..."
cd ${TOP_LEVEL_BUILD_DIR}/../nanosvg
make clean

# Main Build
echo "[INFO]: Cleaning Emulation Station..."
cd ${TOP_LEVEL_BUILD_DIR}/EmulationStation
make clean

# OpenTTD
echo "[INFO]: Cleaning OpenTTD..."
cd ${TOP_LEVEL_BUILD_DIR}/OpenTTD
make clean

cd ${TOP_LEVEL_BUILD_DIR}
rm -r staging
