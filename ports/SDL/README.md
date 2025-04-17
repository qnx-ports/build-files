# SDL2 [![Build](https://github.com/qnx-ports/build-files/actions/workflows/SDL.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/SDL.yml)

Simple DirectMedia Layer (SDL for short) is a cross-platform library designed to make it easy to write multi-media software, such as games and emulators.
You can find the latest release and additional information at: https://www.libsdl.org/

QNX supports the following versions, hosted at https://www.github.com/qnx-ports/SDL:
2.0.5: on branch qnx_oldest

### Tested for QNX 7.1 and 8.0 SDPs
Cross-compiled on Ubuntu 24.04 for:
- QNX 8.0: aarch64le, tested on on Raspberry Pi 4
- QNX 7.1: aarch64le

Instructions for compiling are listed below.

# Compile SDL2 for SDP 7.1/8.0 on an Ubuntu Host or in a Docker container
### *Dependencies:*
WIP - Depends on version

### *Steps:*
1. Create a new workspace or navigate to a desired one
```bash
mkdir sdl_wksp && cd sdl_wksp
```

2. Clone `sdl` and `build_files`. 
```bash
#Pick one:
#Via HTTPS
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/SDL.git

#Via SSH
git clone git@github.com:qnx-ports/build-files.git
git clone git@github.com:qnx-ports/SDL.git
```

3. *[Optional]* Check out ideal branch.
```
# Currently, we only support SDL 2.0.5
# SDL 2.30 Support is planned soon!
```

4. *[Optional]* Build the Docker image and create a container
```bash
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh
cd ~/sdl_wksp
```

5. Source your SDP (Installed from QNX Software Center)
```bash
#QNX 8.0 will be in the directory ~/qnx800/
#QNX 7.1 will be in the directory ~/qnx710/
source ~/qnx800/qnxsdp-env.sh
```

6. Build the project in your workspace from Step 1
```bash
# Do not set QNX_BUILD_TESTS to anything if you do not want tests built.
QNX_PROJECT_ROOT="$(pwd)/SDL" make -C build-files/ports/SDL2 install -j4
```

**NOTE**: Clean your build files before rebuilding.
```bash
#From your workspace:
make -C build-files/ports/SDl2 clean
```

build/build/libSDL2*.a
build/build/.libs/libSDL*

build_test/test*