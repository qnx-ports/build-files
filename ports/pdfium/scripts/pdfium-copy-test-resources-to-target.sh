#!/bin/bash

show_usage_only() {
    echo "usage: $(basename ${0}) <BINARY DIR> <TARGET DIR> <IP ADDRESS> [USER] [PASSWORD]"
    exit 1
}

sshpass -V >/dev/zero 2>&1
if [ $? -ne 0 ]; then
    echo "please install sshpass first"
    echo "    apt-get install sshpass"
    exit 1
fi

if [ -z ${QNX_TARGET} ]; then
    echo "Please source qnxsdp-env.sh first"
    exit 1
fi

if [ $# -lt 3 ]; then
    show_usage_only
    exit 1
fi

if [ $# -gt 5 ]; then
    show_usage_only
    exit 1
fi

BINARY_DIR=$(realpath ${1})
if [ ! -d "${BINARY_DIR}" ]; then
    echo "${BINARY_DIR} not found"
    exit 1
fi
NONLINK=$(readlink ${BINARY_DIR})
if [ $? -eq 0 ]; then
    BINARY_DIR=${NONLINK}
fi
TARGET_IP=${3}
if [ -z ${4} ]; then
    USER=root
else
    USER=${4}
fi
if [ -z ${5} ]; then
    PASSWD=root
else
    PASSWD=${5}
fi

RESOURCE_DIR=$(dirname ${BINARY_DIR})
for run in {1..3}; do
    RESOURCE_DIR=$(dirname ${RESOURCE_DIR})
done
RESOURCE_DIR=${RESOURCE_DIR}/testing
if [ ! -d "${RESOURCE_DIR}" ]; then
    echo "${RESOURCE_DIR} not found"
    exit 1
fi

TEST_SCRIPT_FILE=$(dirname ${BINARY_DIR})/scripts/run-all-tests.sh
if [ ! -f "${TEST_SCRIPT_FILE}" ]; then
    echo "${TEST_SCRIPT_FILE} not found"
    exit 1
fi

nc -vz ${TARGET_IP} 22 >/dev/zero 2>&1
if [ $? -ne 0 ]; then
    echo "failed to ssh ${TARGET_IP}"
    exit 1
fi

TARGET_BASE_DIR=${2}
TARGET_DIR="${TARGET_BASE_DIR}/out/cpu"
sshpass -p ${PASSWD} ssh -T ${USER}@${TARGET_IP} ksh <<END
if [ ! -d "${TARGET_DIR}" ]; then
  mkdir -p "${TARGET_DIR}"
fi
END

CURRENT_DIR=${PWD}
cd ${BINARY_DIR}

TMP_DIR=$(mktemp -d -t stripped_binaries_XXXX)

FILES=$(find ./ -type f -maxdepth 1)
for FILE in ${FILES}; do
    echo ${FILE}
    AARCH=$(file "${FILE}" | grep -o "aarch64")
    if [ -z "${AARCH}" ]; then
        AARCH=$(file "${FILE}" | grep -o "x86-64")
    fi
    if [ -z "${AARCH}" ]; then
        continue
    else
        BASE_NAME=$(basename ${FILE})
        if [ "${AARCH}" = "aarch64" ]; then
            ntoaarch64-strip ${FILE} -o ${TMP_DIR}/${BASE_NAME}
        else
            ntox86_64-strip ${FILE} -o ${TMP_DIR}/${BASE_NAME}
        fi
    fi
done

sshpass -p ${PASSWD} scp -r ${RESOURCE_DIR} ${USER}@${TARGET_IP}:${TARGET_BASE_DIR}
sshpass -p ${PASSWD} scp ${BINARY_DIR}/snapshot_blob.bin ${USER}@${TARGET_IP}:${TARGET_DIR}
sshpass -p ${PASSWD} scp ${BINARY_DIR}/icudtl.dat ${USER}@${TARGET_IP}:${TARGET_DIR}
sshpass -p ${PASSWD} scp -r ${BINARY_DIR}/test_fonts ${USER}@${TARGET_IP}:${TARGET_DIR}
sshpass -p ${PASSWD} scp ${TEST_SCRIPT_FILE} ${USER}@${TARGET_IP}:${TARGET_DIR}
sshpass -p ${PASSWD} scp -r ${TMP_DIR}/* ${USER}@${TARGET_IP}:${TARGET_DIR}

rm -fr ${TMP_DIR}

cd ${CURRENT_DIR}
