#!/bin/bash
for arch in aarch64le  armle-v7 x86_64;
do
    rm -fr build_$arch
done
rm -fr logs install build log
