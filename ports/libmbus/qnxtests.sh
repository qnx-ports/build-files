#!/bin/sh
# Run libmbus's frame-parsing tests on the target, from the folder the port installed them in
# (BUILD_TESTING=ON): every frame in test-frames/ must parse to the XML upstream recorded (raw and normalized), and
# the frames in error-frames/ and unsupported-frames/ must fail the same way they do on Linux (30 and 12 files).
#   cd /usr/local/bin/libmbus_tests && LD_LIBRARY_PATH=/usr/local/lib sh qnxtests.sh
set -u
cd "$(dirname "$0")"
pass=0 fail=0
check() {   # <folder> <expected number of files that do not parse>
    rm -f failing_tests.txt new_tests.txt
    out=$(sh generate-xml.sh "$1" ./mbus_parse_hex 2>&1)
    rc=$?
    failing=$( [ -f failing_tests.txt ] && wc -l < failing_tests.txt || echo 0)
    if [ "$rc" -eq "$2" ] && [ "$failing" -eq 0 ]; then
        echo "PASS $1 ($(ls "$1"/*.hex | wc -l) frames, $rc expected parse failures)"
        pass=$((pass + 1))
    else
        echo "FAIL $1 (parse failures $rc, expected $2; XML differences in $failing files)"
        echo "$out" | tail -20
        fail=$((fail + 1))
    fi
    # unsupported frames without a recorded XML get one written; remove it again
    [ -f new_tests.txt ] && while read -r n; do rm -f "$1/$n.xml"; done < new_tests.txt
    rm -f failing_tests.txt new_tests.txt
}
check test-frames 0
check error-frames 30
check unsupported-frames 12
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
