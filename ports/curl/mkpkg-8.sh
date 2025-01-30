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
### 8.0 section
###

# start a clean slate
rm -rf $build

## 8.0 aarch64

aprefix="$install/aarch64-8.0.0"
atargetlibdir="$build/target/qnx/aarch64le/usr/lib"
atargetbindir="$build/target/qnx/aarch64le/usr/bin"
atargetincdir="$build/target/qnx/aarch64le/usr/include/curl"
astrip="aarch64-unknown-nto-qnx8.0.0-strip"

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

## 8.0 x86_64

xprefix="$install/x86_64-8.0.0"
xtargetlibdir="$build/target/qnx/x86_64/usr/lib"
xtargetbindir="$build/target/qnx/x86_64/usr/bin"
xtargetincdir="$build/target/qnx/x86_64/usr/include/curl"
xstrip="x86_64-pc-nto-qnx8.0.0-strip"

mkdir -p $xtargetlibdir
cp -p $xprefix/lib/libcurl.a $xprefix/lib/libcurl.so* $xtargetlibdir
cp -p $xprefix/lib/libcurl.so.12 $xtargetlibdir/libcurl.so.12.sym
$xstrip $xtargetlibdir/libcurl.so.12 $xtargetlibdir/libcurl.so

mkdir -p $xtargetbindir
cp -p $xprefix/bin/curl $xtargetbindir
cp -p $xprefix/bin/curl $xtargetbindir/curl.sym
$xstrip $xtargetbindir/curl

mkdir -p $xtargetincdir
cp -p $xprefix/include/curl/*.h $xtargetincdir

## 8.0 documentation

cp README-QNX.md "$build/target/qnx/"

## build the 8.0 package

cd $build
tar czf curl-$buildver-qnxsdp8.0.tar.gz target/qnx
mv *tar.gz $tarball
