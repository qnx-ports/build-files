#! /bin/bash

if $(git clone https://github.com/madler/zlib.git); then
cd zlib
git checkout v1.3.1
cd ..
touch build-files/ports/zlib/nto-x86_64-o/Makefile.dnm
fi
QNX_PROJECT_ROOT="$(pwd)/zlib" make -C build-files/ports/zlib clean install


if $(git clone https://github.com/libjpeg-turbo/libjpeg-turbo.git); then
cd libjpeg-turbo
git checkout 3.1.0
cd ..
touch build-files/ports/libjpeg-turbo/nto-x86_64-o/Makefile.dnm
fi
QNX_PROJECT_ROOT="$(pwd)/libjpeg-turbo" make -C build-files/ports/libjpeg-turbo clean install

if $(git clone https://github.com/pnggroup/libpng.git); then
cd libpng
git checkout v1.6.46
cd ..
touch build-files/ports/libpng/nto-x86_64-o/Makefile.dnm
fi
QNX_PROJECT_ROOT="$(pwd)/libpng" make -C build-files/ports/libpng clean install

git clone https://github.com/GNOME/glib.git
QNX_PROJECT_ROOT="$(pwd)/glib" make -C build-files/ports/glib clean install