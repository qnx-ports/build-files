#!/bin/bash

for test in $(find ./ -type f) ; do
    chmod +x $test
    $test | tee test.result
done