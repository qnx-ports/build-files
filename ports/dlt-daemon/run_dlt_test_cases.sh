#!/bin/sh

cd /data/home/qnxuser/tests || exit 1

export PATH="$PATH:$(pwd)"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$(pwd)"

if [ -x ./gtest_dlt_daemon_gateway.sh ]; then
  ./gtest_dlt_daemon_gateway.sh
fi

if [ -x ./gtest_dlt_daemon_offline_log.sh ]; then
  ./gtest_dlt_daemon_offline_log.sh
fi

TESTS="
gtest_dlt_common
gtest_dlt_user
gtest_dlt_daemon_common
dlt_env_ll_unit_test
gtest_dlt_daemon_gateway
gtest_dlt_daemon_offline_log
gtest_dlt_daemon_event_handler
gtest_dlt_daemon_multiple_files_logging
"

for test in $TESTS; do
  if [ -x "./$test" ]; then
    ./"$test"
  fi
done

