# MAME

**Repository:** https://github.com/qnx-ports/mame \
**Upstream:** https://github.com/mamedev/mame \
**Website:** https://www.mamedev.org/ \
**Supports:** QNX 8.0 on aarch64le and x86_64

**NOTE** MAME supports excludes MIDI audio.

## Build and Install

As a prerequisite, you must have a QNX SDP 8.0 installation. We do not currently
support QNX SDP 7.1.
```bash
mkdir qnx_workspace
cd qnx_workspace
# Grab source and build files
git clone https://github.com/qnx-ports/build-files
git clone https://github.com/qnx-ports/mame
git clone -b qnx-release-2.0.14 https://github.com/qnx-ports/SDL.git
git clone https://github.com/qnx-ports/SDL_ttf
git clone -b 1.7.0 https://github.com/mesonbuild/meson.git
git clone -b VER-2-13-3 https://gitlab.freedesktop.org/freetype/freetype.git
git clone -b 2.16.0 https://gitlab.freedesktop.org/fontconfig/fontconfig.git

# Optionally build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in a docker container

# Build SDL2
make -C build-files/ports/SDL JLEVEL=4 install

# Build freetype2
chmod +x ./build-files/ports/freetype/install_all.sh
./build-files/ports/freetype/install_all.sh
QNX_PROJECT_ROOT="$(pwd)/freetype" JLEVEL=4 make -C build-files/ports/freetype install

# Build fontconfig
chmod +x ./build-files/ports/fontconfig/install_all.sh
./build-files/ports/fontconfig/install_all.sh
# NOTE: You may need to tweak the required meson version in fontconfig/meson.build before running.
QNX_PROJECT_ROOT="$(pwd)/fontconfig" JLEVEL=4 make -C build-files/ports/fontconfig install

# Build SDL_ttf
make -C build-files/ports/SDL_ttf JLEVEL=4 install

# Build mame
make -C build-files/ports/mame JLEVEL=4 install
```

# How to run MAME

Copy files to the target,

```bash
TARGET_HOST=<target-ip-address-or-hostname>

scp ~/qnx_workspace/build-files/ports/mame/mame.ini qnxuser@$TARGET_HOST:~/

libs=(
$QNX_TARGET/aarch64le/usr/local/lib/libz.so
$QNX_TARGET/aarch64le/usr/local/lib/libbrotlidec.so.1
$QNX_TARGET/aarch64le/usr/local/lib/libfreetype.so.6
$QNX_TARGET/aarch64le/usr/local/lib/libSDL2.so
$QNX_TARGET/aarch64le/usr/local/lib/libSDL2-2.0.so.14
$QNX_TARGET/aarch64le/usr/local/lib/libfreetype.so.6.20.2
$QNX_TARGET/aarch64le/usr/local/lib/libfontconfig.so.1
$QNX_TARGET/aarch64le/usr/local/lib/libbrotlicommon.so.1
$QNX_TARGET/aarch64le/usr/local/lib/libpng16.so.16
$QNX_TARGET/aarch64le/usr/local/lib/libbrotlienc.so
$QNX_TARGET/aarch64le/usr/local/lib/libbrotlicommon.so.1.1.0
$QNX_TARGET/aarch64le/usr/local/lib/libbrotlidec.so.1.1.0
$QNX_TARGET/aarch64le/usr/local/lib/libexpat.so.1
$QNX_TARGET/aarch64le/usr/local/lib/libbrotlidec.so
$QNX_TARGET/aarch64le/usr/local/lib/libz.so.1
$QNX_TARGET/aarch64le/usr/local/lib/libfontconfig.so
$QNX_TARGET/aarch64le/usr/local/lib/libiconv.so
$QNX_TARGET/aarch64le/usr/local/lib/libcharset.so.1.0.0
$QNX_TARGET/aarch64le/usr/local/lib/libiconv.so.2.7.0
$QNX_TARGET/aarch64le/usr/local/lib/libbz2.so.1.0.8
$QNX_TARGET/aarch64le/usr/local/lib/libiconv.so.2
$QNX_TARGET/aarch64le/usr/local/lib/libbrotlienc.so.1
$QNX_TARGET/aarch64le/usr/local/lib/libpng16.so
$QNX_TARGET/aarch64le/usr/local/lib/libbz2.so.1.0
$QNX_TARGET/aarch64le/usr/local/lib/libexpat.so.1.10.0
$QNX_TARGET/aarch64le/usr/local/lib/libz.so.1.3.1
$QNX_TARGET/aarch64le/usr/local/lib/libfontconfig.so.1.15.0
$QNX_TARGET/aarch64le/usr/local/lib/libpng.so
$QNX_TARGET/aarch64le/usr/local/lib/libfreetype.so
$QNX_TARGET/aarch64le/usr/local/lib/libcharset.so.1
$QNX_TARGET/aarch64le/usr/local/lib/libexpat.so
$QNX_TARGET/aarch64le/usr/local/lib/libcharset.so
$QNX_TARGET/aarch64le/usr/local/lib/libpng16.so.16.46.0
$QNX_TARGET/aarch64le/usr/local/lib/libbrotlicommon.so
$QNX_TARGET/aarch64le/usr/local/lib/libbrotlienc.so.1.1.0
$QNX_TARGET/aarch64le/usr/local/lib/libSDL2_ttf.so
)
scp ${libs[@]} qnxuser@$TARGET_HOST:~/lib

scp $QNX_TARGET/aarch64le/usr/local/bin/mame qnxuser@$TARGET_HOST:~/

# Assuming root ssh is enabled.
scp -r $QNX_TARGET/aarch64le/usr/local/share/mame root@$TARGET_HOST:/system/share

# Install any roms you have to $HOME/.mame/roms on the target.
scp *.zip qnxuser@$TARGET_HOST:~/.mame/roms
```

Execute MAME on the target,
```bash
ssh qnxuser@$TARGET_HOST

./mame
```

To view an complete list of commandline options and options you can set in
mame.ini, see https://docs.mamedev.org/commandline/commandline-all.html
