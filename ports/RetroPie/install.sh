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

TOP_LEVEL_BUILD_DIR=${PWD}


ssh ${TARGET_USER}@${TARGET_IP} "mkdir -p ~/retroarch/"

ssh ${TARGET_USER}@${TARGET_IP} "cd ~/retroarch && mkdir -p data/cores"
ssh ${TARGET_USER}@${TARGET_IP} "cd ~/retroarch && mkdir -p data/assets"
ssh ${TARGET_USER}@${TARGET_IP} "cd ~/retroarch && mkdir -p data/info"

ssh ${TARGET_USER}@${TARGET_IP} "cd ~/retroarch && mkdir -p lib"
ssh ${TARGET_USER}@${TARGET_IP} "cd ~/retroarch && mkdir -p rarch-shared"
ssh ${TARGET_USER}@${TARGET_IP} "cd ~/retroarch && mkdir -p tmp"

scp -pr ${TOP_LEVEL_BUILD_DIR}/staging/${TARGET_ARCH}/* ${TARGET_USER}@${TARGET_IP}:/data/home/${TARGET_USER}/retroarch/
