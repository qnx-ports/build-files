#!/bin/bash

patch_dir=${PWD}/patches
torch_dir=$1

# Function for apply a patch
# $1 arg is the directory
# $2 arg is the patch name
qnx_patch () {
    echo "Applying patch to $1..."
    cd $1
    git apply --whitespace=nowarn ${patch_dir}/$2
    cd -
}

# Apply QNX patches
qnx_patch ${torch_dir}/third_party/foxi foxi.patch
qnx_patch ${torch_dir}/third_party/XNNPACK XNNPACK.patch
qnx_patch ${torch_dir}/third_party/kineto kineto.patch
qnx_patch ${torch_dir}/third_party/googletest googletest.patch
qnx_patch ${torch_dir}/third_party/cpuinfo cpuinfo.patch
qnx_patch ${torch_dir}/third_party/benchmark benchmark.patch

echo "Some of these patches add untracked files to git! If experiencing issues consider using 'git clean -xdff' to clear the untracked files."
