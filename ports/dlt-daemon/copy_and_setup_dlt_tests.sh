#!/bin/bash

# === CONFIGURATION ===
QNX_USER="qnxuser"
QNX_IP="10.123.2.81"
QNX_PASSWORD="qnxuser"
TARGET_PATH="/data/home/qnxuser/tests"

# === Target architecture: Change this to "nto-x86_64-o" or "nto-aarch64-le"
ARCH="nto-aarch64-le"

# === Paths on the host (use ARCH variable) ===
BASE_DIR="${ARCH}/build"
TEST_BIN_DIR="${BASE_DIR}/tests"
DAEMON_BIN_DIR="${BASE_DIR}/src/daemon"
DAEMON_LIB="${BASE_DIR}/src/lib/libdlt.so.2"
GTEST_LIB="${BASE_DIR}/lib"

echo "==> Creating target directory on QNX (if needed)..."
sshpass -p "$QNX_PASSWORD" ssh -o StrictHostKeyChecking=no ${QNX_USER}@${QNX_IP} "mkdir -p ${TARGET_PATH}"

echo "==> Copying test binaries..."
sshpass -p "$QNX_PASSWORD" scp ${TEST_BIN_DIR}/gtest_* ${QNX_USER}@${QNX_IP}:${TARGET_PATH}/
sshpass -p "$QNX_PASSWORD" scp ${TEST_BIN_DIR}/dlt_env_ll_unit_test ${QNX_USER}@${QNX_IP}:${TARGET_PATH}/

echo "==> Copying supporting text files..."
sshpass -p "$QNX_PASSWORD" scp ${TEST_BIN_DIR}/testfile.dlt ${QNX_USER}@${QNX_IP}:${TARGET_PATH}/../
sshpass -p "$QNX_PASSWORD" scp ${TEST_BIN_DIR}/testfile_filetransfer.txt ${QNX_USER}@${QNX_IP}:${TARGET_PATH}/../
sshpass -p "$QNX_PASSWORD" scp ${TEST_BIN_DIR}/testfilter.txt ${QNX_USER}@${QNX_IP}:${TARGET_PATH}/../

echo "==> Copying dlt-daemon and libdlt_daemon.so..."
sshpass -p "$QNX_PASSWORD" scp ${DAEMON_BIN_DIR}/dlt-daemon ${QNX_USER}@${QNX_IP}:${TARGET_PATH}/
sshpass -p "$QNX_PASSWORD" scp ${DAEMON_BIN_DIR}/libdlt_daemon.so ${QNX_USER}@${QNX_IP}:${TARGET_PATH}/

echo "==> Copying dependency libraries..."
sshpass -p "$QNX_PASSWORD" scp ${DAEMON_LIB} ${QNX_USER}@${QNX_IP}:${TARGET_PATH}/
sshpass -p "$QNX_PASSWORD" scp ${GTEST_LIB}/libgtest_main.so.1.13.0 ${QNX_USER}@${QNX_IP}:${TARGET_PATH}/
sshpass -p "$QNX_PASSWORD" scp ${GTEST_LIB}/libgtest.so.1.13.0 ${QNX_USER}@${QNX_IP}:${TARGET_PATH}/

echo "==> Copying test runner script (if available)..."
if [ -f run_dlt_test_cases.sh ]; then
    sshpass -p "$QNX_PASSWORD" scp run_dlt_test_cases.sh ${QNX_USER}@${QNX_IP}:${TARGET_PATH}/
fi

echo ""
echo " All files copied to target (${QNX_IP}:${TARGET_PATH})"

