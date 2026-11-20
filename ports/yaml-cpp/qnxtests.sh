#!/bin/sh
# QNX test runner for yaml-cpp: 1 tests, generated from CTest by PortPilot.
# Run from anywhere: sh qnxtests.sh   (set TIMEOUT_SCALE=3 on QEMU)
here=$(cd "$(dirname "$0")" && pwd); cd "$here" || exit 1
export LD_LIBRARY_PATH="$here${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
S=${TIMEOUT_SCALE:-1}; mkdir -p logs; pass=0; fail=0; tmo=0

run() {  # run <name> <timeout> <cmd...>
  n=$1; to=$(( $2 * S )); shift 2; s=$(date +%s)
  "$@" > "logs/$n.out" 2>&1 </dev/null & p=$!
  # watchdog: polls each second, so no stray sleep outlives the test (a leftover
  # 'sleep $to' kept the ssh session open for the full timeout)
  ( i=0; while [ $i -lt $to ]; do sleep 1; kill -0 $p 2>/dev/null || exit 0;
    i=$((i+1)); done; kill -9 $p ) >/dev/null 2>&1 </dev/null & w=$!
  wait $p; rc=$?; kill $w 2>/dev/null; e=$(( $(date +%s) - s ))
  if [ $rc -eq 137 ] && [ $e -ge $to ]; then tmo=$((tmo+1)); fail=$((fail+1))
    echo "QNXTEST $n TIMEOUT rc=$rc secs=$e limit=$to"
    if [ $pass -eq 0 ] && [ $tmo -ge ${ABORT_AFTER_TIMEOUTS:-3} ]; then  # all hang: stop
      echo "QNXTEST-ABORT the first $tmo tests timed out: the programs probably hang"
      echo "QNXTEST-SUMMARY pass=$pass fail=$fail timeout=$tmo total=$((pass+fail))"
      exit 2; fi; return; fi
  [ -n "$INVERT" ] && { [ $rc -eq 0 ] && rc=1 || rc=0; }  # CTest WILL_FAIL
  if [ $rc -eq 0 ]; then pass=$((pass+1)); echo "QNXTEST $n PASS rc=0 secs=$e"
  else fail=$((fail+1)); echo "QNXTEST $n FAIL rc=$rc secs=$e (see logs/$n.out)"; fi
}

run yaml-cpp::test 60 ./yaml-cpp-tests

echo "QNXTEST-SUMMARY pass=$pass fail=$fail timeout=$tmo total=$((pass+fail))"
[ $fail -eq 0 ]
