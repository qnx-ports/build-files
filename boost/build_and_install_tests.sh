#!/bin/bash

if [ -z "$QNX_TARGET" ]; then
    echo "Please source qnxsdp-env.sh script!"
    exit
fi

if [ -z "$PREFIX" ]; then
    PREFIX="/usr/local"
fi

# Copy test binaries to QNX_TARGET
copy_test_binaries() {
    test_folder_path="./qnx-ports/boost/$1/build/boost/bin.v2/boost_tests"
    mkdir -p $test_folder_path

    # Find test binaries and copy to $test_folder_path
    for lib in "./qnx-ports/boost/$1/build/boost/bin.v2/libs"/* ; do
        lib_name=$(basename $lib)
        for test_folder in "$lib/test"/* ; do
            for f in $(find $test_folder -type f);
            do
                if [[ -x "$f" ]]
                then
                    mkdir -p $test_folder_path/$lib_name
                    cp $f $test_folder_path/$lib_name
                fi
            done
        done
    done

    # Install binaries
    if [[ $1 == "nto-aarch64-le" ]]; then
        cp -rf $test_folder_path "$QNX_TARGET/aarch64le/$PREFIX/bin"

        echo "Installing tests in $QNX_TARGET/aarch64le/$PREFIX/bin"
    fi

    if [[ $1 == "nto-x86_64-o" ]]; then
        cp -rf $test_folder_path "$QNX_TARGET/x86_64/$PREFIX/bin"

        echo "Installing tests in $QNX_TARGET/x86_64/$PREFIX/bin"
    fi

    mkdir -p $test_folder_path/libs

    for f in $(find ./qnx-ports/boost/$1/build/boost/bin.v2/libs -type f -name *.so*);
    do
        cp -f $f $test_folder_path/libs
    done
}

# Build all tests under libs
echo "Start building tests for Boost"

for lib in "./qnx-ports/boost/nto-x86_64-o/build/boost/bin.v2/libs"/* ; do
    QNX_PROJECT_ROOT="$(pwd)/boost" make -C qnx-ports/boost/ test."$(basename $lib)" -i -j4
done

# Copy test binaries to QNX_TARGET
copy_test_binaries "nto-aarch64-le"
copy_test_binaries "nto-x86_64-o"
