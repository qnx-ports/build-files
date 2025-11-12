#/bin/sh

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/lib

for test_file in ./g3log_tests/test_*; do
  if [ -x "$test_file" ]; then
    echo "Running $test_file"
    "$test_file"
  fi
done
