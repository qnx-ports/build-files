#!/bin/bash

# Directory containing the test binaries
TEST_DIR=.

# Move to the test directory
cd "$TEST_DIR" || { echo "Failed to enter test directory: $TEST_DIR"; exit 1; }

# Create a log file to store the results
LOG_FILE="results.log"
echo "Running all tests in $TEST_DIR" > "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"

# Initialize counters for passed, failed, and skipped tests
PASSED_COUNT=0
FAILED_COUNT=0
SKIPPED_COUNT=0

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No color

# Loop through each test binary
for TEST in test_*; do
    if [[ -x "$TEST" ]]; then
        # Run the test and capture output and exit code
        OUTPUT=$(./"$TEST" 2>&1)
        EXIT_CODE=$?

        if [[ -n "$OUTPUT" ]]; then
            # If there is output, log it
            echo "$OUTPUT" >> "$LOG_FILE"
            if [[ $EXIT_CODE -eq 0 ]]; then
                echo -e "${GREEN}Test $TEST: PASSED${NC}" | tee -a "$LOG_FILE"
                ((PASSED_COUNT++))
            else
                echo -e "${RED}Test $TEST: FAILED${NC}" | tee -a "$LOG_FILE"
                ((FAILED_COUNT++))
            fi
        fi

        echo "-----------------------------------------" >> "$LOG_FILE"
    else
        echo "Skipping $TEST (not executable)" | tee -a "$LOG_FILE"
        ((SKIPPED_COUNT++))
    fi
done

# Final summary
echo "=========================================" >> "$LOG_FILE"
echo "Test Summary:" >> "$LOG_FILE"
echo "Passed: $PASSED_COUNT" >> "$LOG_FILE"
echo "Failed: $FAILED_COUNT" >> "$LOG_FILE"
echo "Skipped: $SKIPPED_COUNT" >> "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"

# Print summary to console
echo "========================================="
echo -e "${GREEN}Passed: $PASSED_COUNT${NC}"
echo -e "${RED}Failed: $FAILED_COUNT${NC}"
echo "Skipped: $SKIPPED_COUNT"
echo "========================================="
echo "All tests completed. Results saved in $LOG_FILE"
