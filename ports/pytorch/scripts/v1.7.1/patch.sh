#!/bin/bash

patch_dir=$1
torch_dir=$2

# Function for apply a patch
# $1 arg is the directory
# $2 arg is the patch name
qnx_patch () {
    echo Applying $2 in $1
    cd $1
    git apply --whitespace=nowarn ${patch_dir}/$2
    cd - > /dev/null
}

# Apply QNX patches
qnx_patch ${torch_dir}/third_party/cpuinfo cpuinfo.patch
qnx_patch ${torch_dir}/third_party/eigen eigen.patch
qnx_patch ${torch_dir}/third_party/fbgemm/third_party/asmjit asmjit.patch
qnx_patch ${torch_dir}/third_party/foxi foxi.patch
qnx_patch ${torch_dir}/third_party/ideep/mkl-dnn mkl-dnn.patch
qnx_patch ${torch_dir}/third_party/NNPACK NNPACK.patch
qnx_patch ${torch_dir}/third_party/QNNPACK QNNPACK.patch
qnx_patch ${torch_dir}/third_party/sleef sleef.patch
qnx_patch ${torch_dir}/third_party/tbb tbb.patch
qnx_patch ${torch_dir}/third_party/XNNPACK XNNPACK.patch

echo "Some of these patches add untracked files to git! If experiencing issues consider using 'git clean -xdff' to clear the untracked files."
