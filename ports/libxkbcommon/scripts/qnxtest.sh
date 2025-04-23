#!/bin/bash

set -e # Exit immediately if any command fails (including segmentation faults)

echo "Running all tests in $TEST_DIR..."

# All Test Pass
./test-atom
./test-buffercomp
./test-compose
./test-context
./test-filecomp
./test-keysym
./test-log
./test-merge-modes
./test-messages
./test-rules-file
./test-rules-file-includes
./test-stringcomp
./test-utf8
./test-utils

# These tests were skipped because they are linux evdev specific test
#./test-keymap
#./test-keyseq
#./test-modifiers
#./test-state
#./test-rulescomp
echo "All tests pass."
