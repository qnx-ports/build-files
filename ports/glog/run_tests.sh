#! /bin/sh

# Find all tests in the folder. glog tests are suffixed with _unittest
#-> Note that some do not alyways compile depending on SDP/platform
echo "Finding Tests..."
num_tests=$((0))
for test in *_unittest; do
    num_tests=$(($num_tests+1))
    echo "[$num_tests] Found $test"
done
echo "Done Searching. $num_test Test(s) Found."

# Run all tests in the folder, same as above.
#-> Note that we want to run in child processes, so that any failures do not affect future tests
printf "\n\nRunning Tests...\n"
num_completed=$((0))
for test_run in *_unittest; do
    #Status Update
    num_completed=$(($num_completed+1))
    printf "\n=====\n[$num_completed/$num_tests] $test_run\n=====\n\n"

    #Run in separate Process: 
    ./$test_run &
    pid_child_proc=$!
    wait $pid_child_proc
done
printf "\nTesting complete.\n"
