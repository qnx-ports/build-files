#!/bin/sh

buildver=$1

if [ -z "$buildver" ]; then
  echo "Provide build version string: x.y.z-n"
  exit
fi

tarball="`pwd`/_tarball"
build="_build"
install="$PWD/_install"

mkdir -p $tarball

###
### 7.1 section
###

## 7.1 aarch64

aprefix="$install/aarch64-7.1.0"
atargetlibdir="$build/target/qnx7/aarch64le/usr/lib"
atargetbindir="$build/target/qnx7/aarch64le/usr/bin"
atargetincdir="$build/target/qnx7/aarch64le/usr/include/curl"
astrip="aarch64-unknown-nto-qnx7.1.0-strip"

mkdir -p $atargetlibdir
cp -p $aprefix/lib/libcurl.a $aprefix/lib/libcurl.so* $atargetlibdir
cp -p $aprefix/lib/libcurl.so.12 $atargetlibdir/libcurl.so.12.sym
$astrip $atargetlibdir/libcurl.so.12 $atargetlibdir/libcurl.so

mkdir -p $atargetbindir
cp -p $aprefix/bin/curl $atargetbindir
cp -p $aprefix/bin/curl $atargetbindir/curl.sym
$astrip $atargetbindir/curl

mkdir -p $atargetincdir
cp -p $aprefix/include/curl/*.h $atargetincdir

## 7.1 x86_64

aprefix="$install/x86_64-7.1.0"
atargetlibdir="$build/target/qnx7/x86_64/usr/lib"
atargetbindir="$build/target/qnx7/x86_64/usr/bin"
atargetincdir="$build/target/qnx7/x86_64/usr/include/curl"
astrip="x86_64-pc-nto-qnx7.1.0-strip"

mkdir -p $atargetlibdir
cp -p $aprefix/lib/libcurl.a $aprefix/lib/libcurl.so* $atargetlibdir
cp -p $aprefix/lib/libcurl.so.12 $atargetlibdir/libcurl.so.12.sym
$astrip $atargetlibdir/libcurl.so.12 $atargetlibdir/libcurl.so

mkdir -p $atargetbindir
cp -p $aprefix/bin/curl $atargetbindir
cp -p $aprefix/bin/curl $atargetbindir/curl.sym
$astrip $atargetbindir/curl

mkdir -p $atargetincdir
cp -p $aprefix/include/curl/*.h $atargetincdir

## 7.1 documentation

cp README.md "$build/target/qnx7/"

## build the 8.0 package

cd $build
tar czf curl-$buildver-qnxsdp7.1.tar.gz target/qnx7
mv *tar.gz $tarball
