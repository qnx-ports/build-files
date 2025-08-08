#!/bin/sh
if [ $# -gt 1 ]; then
    echo "usage: $(basename $0)"
    exit 1
fi

find_in_list() {
    if [ -z "${1}" ]; then
        return 1
    fi
    for ITEM in ${1}; do
        if [ ${ITEM} = ${2} ]; then
            return 0
        fi
    done
    return 1
}

check_result() {
    for KEY in ' FAILED TESTS' 'Fatal error in:' 'last system error:'; do
        CAPTURE=$(grep "${KEY}" "${2}" | tail -1)
        if [ ! -z "${CAPTURE}" ]; then
            return 1
        fi
    done
    if [ "${1}" = "neteq_speed_test" ]; then
        CAPTURE=$(grep "Runtime = " "${2}" | tail -1)
    else
        CAPTURE=$(grep "\[  PASSED  \]" "${2}" | tail -1)
    fi
    if [ ! -z "${CAPTURE}" ]; then
        return 0
    fi
    return 1
}

RESULT_DIR="${PWD}/result"
if [ ! -f "${RESULT_DIR}" ]; then
    mkdir "${RESULT_DIR}"
fi
STDOUT="${RESULT_DIR}/console_output.txt"

PASSED_TESTS_FILE="${RESULT_DIR}/passed_tests.txt"
PASSED_RESULT="${RESULT_DIR}/passed_result.txt"
if [ -f ${PASSED_TESTS_FILE} ]; then
    PASSED_TESTS=$(<${PASSED_TESTS_FILE})
    PASSED_TESTS="$(echo "${PASSED_TESTS}" | sed ':a;N;$!ba;s/\n/ /g')"
else
    touch ${PASSED_TESTS_FILE}
    rm ${PASSED_RESULT}
    echo $(date) >${PASSED_RESULT}
fi

FAILED_TESTS_FILE="${RESULT_DIR}/failed_tests.txt"
FAILED_RESULT="${RESULT_DIR}/failed_result.txt"
if [ -f ${FAILED_TESTS_FILE} ]; then
    FAILED_TESTS=$(<${FAILED_TESTS_FILE})
    FAILED_TESTS="$(echo "${FAILED_TESTS}" | sed ':a;N;$!ba;s/\n/ /g')"
else
    touch ${FAILED_TESTS_FILE}
    echo $(date) >${FAILED_RESULT}
fi

TESTS="audio_codec_speed_tests audio_decoder_unittests common_audio_unittests common_video_unittests dcsctp_unittests examples_unittests modules_tests neteq_opus_quality_test neteq_pcm16b_quality_test neteq_pcmu_quality_test peerconnection_unittests rtc_pc_unittests rtc_stats_unittests svc_tests system_wrappers_unittests test_packet_masks_metrics test_support_unittests tools_unittests video_codec_perf_tests video_engine_tests voip_unittests webrtc_opus_fec_test webrtc_perf_tests  modules_unittests neteq_speed_test rtc_media_unittests rtc_unittests slow_peer_connection_unittests webrtc_nonparallel_tests"

for TEST in ${TESTS}; do
    TEST_NAME=$(basename "${TEST}")
    find_in_list "${PASSED_TESTS}" "${TEST_NAME}"
    if [ $? -eq 0 ]; then
        echo "${TEST_NAME} has passed already"
        continue
    fi
    find_in_list "${FAILED_TESTS}" "${TEST_NAME}"
    if [ $? -eq 0 ]; then
        echo "${TEST_NAME} was failed before"
        continue
    fi
    echo "run ./${TEST}"
    STDOUT="${RESULT_DIR}/${TEST}_output.txt"
    if [ ! -z $1 ]; then
        echo "Press Y to run"
        read -rs input
        if [ "$input" != "Y" ]; then
            continue
        fi
    fi
    echo ${TEST_NAME} >${STDOUT}
    date >>${STDOUT}
    ./${TEST} 2>&1 | tee -a ${STDOUT}
    check_result ${TEST_NAME} ${STDOUT}
    if [ $? -eq 0 ]; then
        echo ${TEST_NAME} >>${PASSED_TESTS_FILE}
        echo "${TEST_NAME}: ${CAPTURE}" >>${PASSED_RESULT}
    else
        echo ${TEST_NAME} >>${FAILED_TESTS_FILE}
        if [ -z "${CAPTURE}" ]; then
            CAPTURE="something wrong"
        fi
        echo "${TEST_NAME}: ${CAPTURE}" >>${FAILED_RESULT}
    fi
    date >>${STDOUT}
done
