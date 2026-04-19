#!/bin/bash
BUILD_DIR="${1:-.}"
if [ ! -f "${BUILD_DIR}/CTestTestfile.cmake" ]; then
    echo "#!/bin/sh"
    echo "echo 'No CTest tests found. Build with BUILD_TESTING=ON first.'"
    exit 0
fi
cat <<'HEADER'
#!/bin/sh
PASSED=0; FAILED=0; TOTAL=0; TEST_NUM=0
run_test() {
    TEST_NUM=$((TEST_NUM + 1)); TOTAL=$((TOTAL + 1)); NAME="$1"; shift
    if "$@" > /dev/null 2>&1; then echo "Test #${TEST_NUM}: ${NAME}: passed"; PASSED=$((PASSED + 1))
    else echo "Test #${TEST_NUM}: ${NAME}: failed"; FAILED=$((FAILED + 1)); fi
}
echo "Running whisper.cpp tests..."
HEADER
cd "${BUILD_DIR}"
grep -r "add_test" CTestTestfile.cmake */CTestTestfile.cmake 2>/dev/null | \
    sed -n 's/.*add_test(\([^ ]*\) \(.*\))/run_test "\1" \2/p' | sed 's/)$//'
cat <<'FOOTER'
echo "Total: ${TOTAL}  Passed: ${PASSED}  Failed: ${FAILED}"
[ ${FAILED} -gt 0 ] && exit 1
FOOTER
