#! /bin/sh

##########################################################################################
### Set Up Needed Environment Variables
# Adjust these as needed
RETROARCH_SRC=${PWD}/../../../RetroArch
EMULATIONSTATION_SRC=${PWD}/../../../EmulationStation

TARGET_IP=<example-ip>
TARGET_USER="qnxuser"

# DO NOT TOUCH
TOP_LEVEL_BUILD_DIR=${PWD} 

##########################################################################################
### Build RetroArch
cd ${TOP_LEVEL_BUILD_DIR}/RetroArch
make install

##########################################################################################
### Build Emulation Station
# Dependancies

# Main Build
cd ${TOP_LEVEL_BUILD_DIR}/EmulationStation
make install