#!/bin/sh

TEST_DIR=$(pwd)

export LD_LIBRARY_PATH="$TEST_DIR:$LD_LIBRARY_PATH"

PASS=0
FAIL=0

run_test()
{
    TEST="$1"

    echo ""
    echo "========================================"
    echo "Running: $TEST"
    echo "========================================"

    if [ -x "$TEST" ]; then
        ./"$TEST"
    else
        sh ./"$TEST"
    fi

    RESULT=$?

    if [ "$RESULT" -eq 0 ]; then
        echo "PASS: $TEST"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $TEST (exit code: $RESULT)"
        FAIL=$((FAIL + 1))
    fi
}

echo "========================================"
echo " DLT-daemon 3.0 Test Suite"
echo "========================================"
echo "Test directory : $TEST_DIR"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo "========================================"

# Shell-based tests first
run_test gtest_dlt_user.sh
echo "Waiting 10 seconds..."
sleep 10

run_test gtest_dlt_daemon_gateway.sh
echo "Waiting 10 seconds..."
sleep 10

run_test gtest_dlt_daemon_offline_log.sh
echo "Waiting 10 seconds..."
sleep 10

# Unit tests
run_test dlt_env_ll_unit_test
run_test gtest_dlt_common
run_test gtest_dlt_common_v2
run_test gtest_dlt_daemon
run_test gtest_dlt_daemon_v2
run_test gtest_dlt_daemon_common
run_test gtest_dlt_daemon_common_v2
run_test gtest_dlt_daemon_event_handler
run_test gtest_dlt_daemon_gateway
run_test gtest_dlt_daemon_offline_log
run_test gtest_dlt_daemon_multiple_files_logging
run_test gtest_dlt_user
run_test gtest_dlt_user_v2

echo ""
echo "========================================"
echo " DLT TEST SUMMARY"
echo "========================================"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "========================================"

if [ "$FAIL" -eq 0 ]; then
    echo "All tests passed."
    exit 0
else
    echo "Some tests failed."
    exit 1
fi