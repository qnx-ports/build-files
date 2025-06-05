#! /bin/sh

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/lib

cd test

echo "Searching for tests..."
num_tests=$((0))
for f in test*; do
        echo "Found $f"
        num_tests=$(($num_tests+1))
done

echo "Search Complete. Found $num_tests test files.\nTesting..."

num_comp=$((1))

for f in test*; do
        echo "\n($num_comp/$num_tests) $f:"
        num_comp=$(($num_comp+1))
        ./$f
done

echo "Testing Complete"