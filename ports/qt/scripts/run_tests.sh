#!/bin/bash

# Check if the user provided an argument for [args]
if [ -z "$1" ]; then
  echo "Usage: $0 <subdirectory>"
  exit 1
fi

# Directory where the test executables are located
TEST_DIR="/data/home/qnxuser/qt-test/$1"

# Output file where the test summary will be stored
RESULT_FILE="/data/home/qnxuser/qt-test/$1/test_results.txt"

# Clear previous test results if the file exists
> $RESULT_FILE

# Define color codes for output
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"  # No Color

# Initialize counters for the final summary
total_pass_count=0
total_xfail_count=0
total_fail_count=0
total_skip_count=0
total_tests=0

# Change to the test directory
cd "$TEST_DIR" || exit 1

# Find all test executables and store them in a temporary file
find . -type f \( -name "tst*" -o -name "q*" \) -perm -u+x > test_executables.txt

# Read the test files from the temporary file
while read -r test_file; do
    # Skip dbus test
    if [[ $(basename "$test_file") == tst_qdbus* ]]; then
        continue
    fi

    # Get the directory of the test file and the filename itself
    test_dir=$(dirname "$test_file")
    test_name=$(basename "$test_file")
    
    # Print the name of the test being run
    full_test_path=$(echo "$TEST_DIR/$test_file" | sed 's|/./|/|g')
    echo "Running test: $full_test_path"


    
    # Change to the test file's directory
    cd "$test_dir" || continue
    
    # Run the test and capture its output
    output=$(./"$test_name" 2>&1)
    
    # Count the number of "PASS", "XFAIL", "FAIL" (excluding XFAIL), and "SKIP"
    pass_count=$(echo "$output" | grep -c "PASS   :")
    xfail_count=$(echo "$output" | grep -c "XFAIL")
    fail_count=$(echo "$output" | grep "FAIL" | grep -vc "XFAIL")  # Count real FAILs, excluding XFAILs
    skip_count=$(echo "$output" | grep -c "SKIP")
    
    # Update total counts
    total_pass_count=$((total_pass_count + pass_count + xfail_count))
    total_xfail_count=$((total_xfail_count + xfail_count))
    total_fail_count=$((total_fail_count + fail_count))
    total_skip_count=$((total_skip_count + skip_count))
    total_tests=$((total_tests + pass_count + fail_count + xfail_count + skip_count))
    
    # Display and log the pass/xfail/fail/skip summary for this test executable
    if [ $fail_count -eq 0 ]; then
       echo -e "${GREEN}Test $test_file: $pass_count PASSED, $xfail_count XFAIL, $fail_count FAILED, $skip_count SKIPPED${NC}"
       echo -e "${GREEN}Test $test_file: $pass_count PASSED, $xfail_count XFAIL, $fail_count FAILED, $skip_count SKIPPED${NC}" >> "$RESULT_FILE"
    else
       echo -e "${RED}Test $test_file: $pass_count PASSED, $xfail_count XFAIL, $fail_count FAILED, $skip_count SKIPPED${NC}"
       echo -e "${RED}Test $test_file: $pass_count PASSED, $xfail_count XFAIL, $fail_count FAILED, $skip_count SKIPPED${NC}" >> "$RESULT_FILE"
    fi

    echo "----------------------------------------" | tee -a "$RESULT_FILE"
    
    # Return to the root test directory
    cd "$TEST_DIR" || exit 1

done < test_executables.txt

# Remove the temporary file
rm -f test_executables.txt

# Output the final summary to the result file with color codes
echo "Test Summary:" >> "$RESULT_FILE"
echo "Total Tests: $total_tests" >> "$RESULT_FILE"
printf "${GREEN}Passed: %d (%.2f%%)${NC}\n" $total_pass_count "$(echo "scale=4; ($total_pass_count * 100) / $total_tests" | bc -l)" >> "$RESULT_FILE"
printf "${RED}Failed: %d (%.4f%%)${NC}\n" $total_fail_count "$(echo "scale=4; ($total_fail_count * 100) / $total_tests" | bc -l)" >> "$RESULT_FILE"
printf "${YELLOW}XFAIL: %d (%.4f%%)${NC}\n" $total_xfail_count "$(echo "scale=4; ($total_xfail_count * 100) / $total_tests" | bc -l)" >> "$RESULT_FILE"
printf "Skipped: %d (%.4f%%)\n" $total_skip_count "$(echo "scale=4; ($total_skip_count * 100) / $total_tests" | bc -l)" >> "$RESULT_FILE"

# Display the final summary on the console
echo -e "\nTest Summary:"
echo "Total Tests: $total_tests"
printf "${GREEN}Passed: %d (%.4f%%)${NC}\n" $total_pass_count "$(echo "scale=4; ($total_pass_count * 100) / $total_tests" | bc -l)"
printf "${RED}Failed: %d (%.4f%%)${NC}\n" $total_fail_count "$(echo "scale=4; ($total_fail_count * 100) / $total_tests" | bc -l)"
printf "${YELLOW}XFAIL: %d (%.4f%%)${NC}\n" $total_xfail_count "$(echo "scale=4; ($total_xfail_count * 100) / $total_tests" | bc -l)"
printf "Skipped: %d (%.4f%%)\n" $total_skip_count "$(echo "scale=4; ($total_skip_count * 100) / $total_tests" | bc -l)"
echo "----------------------------------------"
