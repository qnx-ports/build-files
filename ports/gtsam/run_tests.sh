#! /bin/sh

num_tests=$((0))
for f in test*; do
        echo "Found $f"
        num_tests=$(($num_tests+1))
done

echo "Found $num_tests tests.\nRunning Tests..."

num_comp=$((1))
for f in test*; do
        echo "\n($num_comp/$num_tests) $f"
        num_comp=$((num_comp+1))
        ./$f
done

echo "Testing Complete"