#!/bin/bash
if [[ -z "$TARGET_USER" ]]; then
    echo "Missing TARGET_USER definition"
    exit 1
fi
if [[ -z "$TARGET_IP" ]]; then
    echo "Missing TARGET_IP definition"
    exit 1
fi
if [[ -z "$TARGET_ARCH" ]]; then
    echo "Missing TARGET_ARCH definition, assuming aarch64le"
    TARGET_ARCH=aarch64le
fi
if [[ -z "$TARGET_DIR" ]]; then
    echo "Missing TARGET_DIR definition, assuming ~/retropie"
    TARGET_DIR="~/retropie"
fi

TOP_LEVEL_BUILD_DIR=${PWD}


ssh ${TARGET_USER}@${TARGET_IP} "mkdir -p $TARGET_DIR"
ssh ${TARGET_USER}@${TARGET_IP} "mkdir -p ~/.emulationstation"

#ssh ${TARGET_USER}@${TARGET_IP} "cd $TARGET_DIR && mkdir -p data/cores"
#ssh ${TARGET_USER}@${TARGET_IP} "cd $TARGET_DIR && mkdir -p data/assets"
#ssh ${TARGET_USER}@${TARGET_IP} "cd $TARGET_DIR && mkdir -p data/info"

#ssh ${TARGET_USER}@${TARGET_IP} "cd $TARGET_DIR && mkdir -p lib"
#ssh ${TARGET_USER}@${TARGET_IP} "cd $TARGET_DIR && mkdir -p rarch-shared"
#ssh ${TARGET_USER}@${TARGET_IP} "cd $TARGET_DIR && mkdir -p tmp"

scp -pr ${TOP_LEVEL_BUILD_DIR}/staging/${TARGET_ARCH}/* ${TARGET_USER}@${TARGET_IP}:$TARGET_DIR
scp ${TOP_LEVEL_BUILD_DIR}/configs/es_systems.cfg ${TARGET_USER}@${TARGET_IP}:~/.emulationstation/
scp ${TOP_LEVEL_BUILD_DIR}/configs/es_input.cfg ${TARGET_USER}@${TARGET_IP}:~/.emulationstation/
