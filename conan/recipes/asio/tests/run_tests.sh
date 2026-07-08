#!/bin/sh

# Colors
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"   # No Color / reset

PASS_COUNT=0
FAIL_COUNT=0
TOTAL=0

echo "Running tests in $(pwd)..."
echo

# Start time
START=$(date +%s 2>/dev/null)

# Find all executable files in src/tests (not directories)
for test in $(find src/tests -type f -perm -111); do
    TOTAL=$((TOTAL + 1))

    # Run test
    RESULT=$(${test} 2>&1)

    if [ $? -eq 0 ]; then
        PASS_COUNT=$((PASS_COUNT + 1))
        echo "${GREEN}PASS${NC}:$test"
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        echo "${RED}FAIL${NC}:$test"
        echo "${RESULT}"
    fi
done

END=$(date +%s 2>/dev/null)
ELAPSED=$((END - START))

echo
echo "==========================================================================="
echo "Testsuite asio summary"
echo "==========================================================================="
echo "# TOTAL: $TOTAL TIME: ${ELAPSED}sec."
echo "# ${GREEN}PASS${NC}:  $PASS_COUNT"
echo "# ${RED}FAIL${NC}:  $FAIL_COUNT"
echo "==========================================================================="

# Exit with failure if any test failed
[ "$FAIL_COUNT" -eq 0 ]
