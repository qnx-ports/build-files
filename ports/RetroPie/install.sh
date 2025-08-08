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

scp -pr ${TOP_LEVEL_BUILD_DIR}/staging/${TARGET_ARCH}/* ${TARGET_USER}@${TARGET_IP}:$TARGET_DIR
scp ${TOP_LEVEL_BUILD_DIR}/target_scripts/uninstall.sh ${TARGET_USER}@${TARGET_IP}:$TARGET_DIR
# if [ ! -f ${TOP_LEVEL_BUILD_DIR}/staging/startup.sh ]; then
#     scp ${TOP_LEVEL_BUILD_DIR}/target_scripts/backup.sh ${TARGET_USER}@${TARGET_IP}:$TARGET_DIR/startup.sh
# fi
scp -pr ${TOP_LEVEL_BUILD_DIR}/staging/emulationstation/* ${TARGET_USER}@${TARGET_IP}:~/.emulationstation/
