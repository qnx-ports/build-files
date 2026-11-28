#!/bin/sh
# Runs open62541's unit tests on the target, one program per test as CTest
# does, each with CTest's 300 s limit, from this folder (some tests read the
# .der certificates and .json5 configurations installed next to them).
#
# These tests load nodeset files from the build host's source tree through
# paths compiled into them, so they are skipped here; run them on the host.
SKIP="check_client_write_custom_enum check_nodeset_loader_autoid check_nodeset_loader_di check_nodeset_loader_input check_nodeset_loader_parser check_nodeset_loader_plc"

cd "$(dirname "$0")" || exit 1
mkdir -p logs
pass=0 fail=0 skip=0 failed=""
for t in check_*; do
    [ -x "$t" ] || continue
    case " $SKIP " in *" $t "*) skip=$((skip + 1)); continue ;; esac
    if timeout 300 ./"$t" > logs/"$t".log 2>&1; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        failed="$failed $t"
    fi
done
echo "passed: $pass, failed: $fail, skipped: $skip (logs in $(pwd)/logs)"
[ -n "$failed" ] && echo "failed:$failed"
[ "$fail" -eq 0 ]
