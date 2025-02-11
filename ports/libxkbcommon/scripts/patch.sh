#!/bin/bash

patch_dir=${PWD}/qnx_patches
libxkbcommon_dir=$1

# Function to apply a patch
# $1 = target directory
# $2 = patch filename
qnx_patch () {
    local target_dir=$1
    local patch_file=$2

    if [[ ! -d "$target_dir" ]]; then
        echo "Error: Directory '$target_dir' does not exist!"
        return 1
    fi

    if [[ ! -f "${patch_dir}/${patch_file}" ]]; then
        echo "Error: Patch file '${patch_dir}/${patch_file}' not found!"
        return 1
    fi

    echo "Applying patch '${patch_file}' to '${target_dir}'..."
    cd "$target_dir" || return 1
    git apply --whitespace=nowarn "${patch_dir}/${patch_file}"
    cd - > /dev/null
}

# Apply QNX patches
qnx_patch "${libxkbcommon_dir}" "001-fix-null-handling.patch"
qnx_patch "${libxkbcommon_dir}" "002-sync-test-data.patch"
qnx_patch "${libxkbcommon_dir}" "003-test-data-path.patch"

echo "Patches applied successfully."
