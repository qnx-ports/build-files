#!/bin/bash

patch_dir=${PWD}/patches
azure_dir=$1

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
qnx_patch ${azure_dir}/c-utility c-utility.patch
qnx_patch ${azure_dir}/deps/azure-ctest azure-ctest.patch
qnx_patch ${azure_dir}/provisioning_client/deps/utpm utpm.patch

echo "Some of these patches add untracked files to git! If experiencing issues consider using 'git clean -xdff' to clear the untracked files."
