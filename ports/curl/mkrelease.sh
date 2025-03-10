#!/bin/bash

set -eu

# Check if SOURCE_ROOT is set
if [ -z "$SOURCE_ROOT" ]; then
  echo "Please provide the SOURCE_ROOT path."
  exit 1
fi

# Export the SOURCE variable to make it available to the called script
export SOURCE_ROOT

. "./setup"

if [ -z "$QNX710" ]; then
    echo "Set QNX710 in the setup file"
    exit
fi

if [ -z "$QNX800" ]; then
    echo "Set QNX800 in the setup file"
    exit
fi


# remove previous curl release leftovers
rm -rf build-* _install _tarball

curlver=$(grep '#define LIBCURL_VERSION ' $SOURCE_ROOT/include/curl/curlver.h | sed 's/[^0-9.]//g')
echo $curlver
buildver="$curlver"

echo "Create QNX curl release $buildver"

# install everything here
mkdir _install

# Check if the directory $HOME/qnx710 exists
if [ ! -d "$QNX710" ]; then
    echo "Directory $QNX710 does not exist. Please ensure that the QNX710 directory is available."
else
    # make dedicated build dirs for every build

    mkdir build-71-aarch64
    mkdir build-71-x86_64

    #
    # SDK 7.1 builds
    #

    . "$QNX710/qnxsdp-env.sh" 2>&1 > /dev/null

    ## 7.1 for aarch64
    pushd build-71-aarch64 >/dev/null
    echo "7.1 aarch64"
    echo " - configure"
    sh ../conf/7.1-aarch64 >configure.log 2>&1
    echo " - build"
    make -sj >make.log 2>&1
    echo " - install"
    make install >make-install.log 2>&1
    popd > /dev/null

    ## 7.1 for x86_64
    pushd build-71-x86_64 > /dev/null
    echo "7.1 x86_64"
    echo " - configure"
    sh ../conf/7.1-x86_64 >configure.log 2>&1
    echo " - build"
    make -sj >make.log 2>&1
    echo " - install"
    make install >make-install.log  2>&1
    popd> /dev/null

    # generate the tarballs
    sh mkpkg-71.sh $buildver
fi

# Check if the directory $HOME/qnx800 exists
if [ ! -d "$QNX800" ]; then
    echo "Directory $QNX800 does not exist. Please ensure that the QNX800 directory is available."
else
    mkdir build-80-aarch64
    mkdir build-80-x86_64

    #
    # SDK 8.0 builds
    #

    . $QNX800/qnxsdp-env.sh 2>&1 > /dev/null

    ## 8.0 for aarch64
    pushd build-80-aarch64 > /dev/null
    echo "8.0 aarch64"
    echo " - configure"
    sh ../conf/8.0-aarch64 >configure.log 2>&1
    echo " - build"
    make -sj >make.log 2>&1
    echo " - install"
    make install >make-install.log  2>&1
    popd > /dev/null

    ## 8.0 for x86_64
    pushd build-80-x86_64 > /dev/null
    echo "8.0 x86_64"
    echo " - configure"
    sh ../conf/8.0-x86_64 >configure.log 2>&1
    echo " - build"
    make -sj >make.log 2>&1
    echo " - install"
    make install >make-install.log  2>&1
    popd > /dev/null

    # generate the tarballs
    sh mkpkg-8.sh $buildver
fi




