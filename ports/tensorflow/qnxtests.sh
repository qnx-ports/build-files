#!/bin/bash

for test in $(ls | grep _test) ; do
    ./$test
done
