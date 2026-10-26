#!/bin/sh
# Runs the four unit tests of upstream's `make check` (t_timer t_units t_uuid t_api) and records the exit code of each.
# Built with `-o iperf3/*:with_tests=True` (package dir usr/libexec/iperf3-tests/). Run from the directory holding the t_* binaries
# and libiperf.so.0 (found via LD_LIBRARY_PATH=.). Usage: ./iperf3_unit_tests.sh
export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
# run_timeout <seconds> <command...>: like timeout(1) (rc=124 when the time is up), which not every QNX target has
run_timeout() {
    secs=$1; shift
    if command -v timeout >/dev/null 2>&1; then
        timeout $secs "$@"
        return $?
    fi
    "$@" &
    cpid=$!
    ( sleep $secs; kill $cpid ) >/dev/null 2>&1 &
    wpid=$!
    wait $cpid
    rc=$?
    kill $wpid >/dev/null 2>&1
    [ $rc -gt 128 ] && rc=124
    return $rc
}
fails=0; n=0
for t in t_timer t_units t_uuid t_api; do
    n=$((n+1)); echo "##### $t"
    run_timeout 120 ./$t > $t.log 2>&1; rc=$?
    cat $t.log | tail -15
    echo "##### RESULT $t rc=$rc"
    [ $rc -eq 0 ] || fails=$((fails+1))
done
echo "##### SUMMARY $n tests, $fails with non-zero exit"
[ $fails -eq 0 ]
