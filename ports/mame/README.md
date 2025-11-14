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
./build-files/ports/freetype/install_all.sh
QNX_PROJECT_ROOT="$(pwd)/freetype" JLEVEL=4 make -C build-files/ports/freetype install

# Build fontconfig
QNX_PROJECT_ROOT="$(pwd)/fontconfig" JLEVEL=4 make -C build-files/ports/fontconfig install

# Build SDL_ttf
make -C build-files/ports/SDL_ttf JLEVEL=4 install

# Build mame
make -C build-files/ports/mame JLEVEL=4 install
```
