muslflt
===

This repository is a port of parts of [musl libc](http://musl.libc.org/) for use on QNX with OSG-ported projects. The port includes:

1. string-to-float and float-to-string conversion functions (`*printf`, `strto{f,d,ld}`); and
2. The entire `libm` portion. (fenv.h math.h complex.h)

Linking to this library enables math and floating point conversion behavior on QNX that is consistent with other UNIX-like platforms (Linux, \*BSD, macOS).

Only code relevant to these features have been included here. This is not a full fork of `musl` and none of the changes are upstreamable, since `musl` is intended to be a Linux-only libc implementation.

# Compile the port for QNX in a Docker container

**NOTE**: QNX ports are only supported from a Linux host operating system

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# Clone boost
cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/muslflt.git && cd muslflt


# Build muslflt
make -C build-files/ports/muslflt/ install QNX_PROJECT_ROOT="$(pwd)/muslflt" -j$(nproc)
```

# Compile the port for QNX
```bash
# Clone the build-files and boost repos
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git
git clone https://gitlab.com/qnx/ports/muslflt.git

# Build muslflt
make -C build-files/ports/muslflt/ install QNX_PROJECT_ROOT="$(pwd)/muslflt" -j$(nproc)
```

If `INSTALL_ROOT_nto` is omitted, the library will be installed into your SDP directory. `PREFIX` defaults to `/usr/local` if not specified to be consistent with other OSG ports.

To ensure symbols from this library is preferred over those in `libc`, it is recommended to statically link this library into your binary with

```
LDFLAGS="-Wl,--whole-archive -lmuslflt -Wl,--no-whole-archive"
```

with appropriate `-L` flags added if necessary.

**IMPORTANT**: Some basic libraries such as: `libstdc++.so` has dependency to `libm.so`

# Test instruction

Building the library also produces a `muslflt_tests` output. This binary can be run directly to execute test cases collected from a few OSS projects known to fail on stock QNX libc. Currently this only includes test cases for float/string conversion.

Tests can be added to `tests.cpp`. Note that since muslflt overrides the `s*printf` and `strto{f,d,ld}` family of functions, you should not depend on the correctness of these functions for your tests to run. Avoid these functions unless you are testing them (i.e. try to test the correctness of only one function in one tests case).

Run `TARGET_IP_ADDRESS=<target-ip-address>` to set the target ip address for the following commands.
```bash
# Make sure /data/home/qnxuser/lib and /data/home/qnxuser/bin exist on the QNX target
# scp library and test to your QNX target
scp $QNX_TARGET/aarch64le/usr/local/lib/libmuslflt.so* qnxuser@$TARGET_IP_ADDRESS:/data/home/qnxuser/lib
scp $QNX_TARGET/aarch64le/usr/local/bin/muslflt_tests qnxuser@$TARGET_IP_ADDRESS:/data/home/qnxuser/bin

# ssh into your QNX target
ssh qnxuser@$TARGET_IP_ADDRESS

# Create a symbolic link for libm.so.3 to make muslflt_tests use libmuslflt.so
cd /data/home/qnxuser/lib
ln -sf muslflt.so.1 libm.so.3

# Work around not being able to replace libm.so.3 at /proc/boot by setting LD_LIBRARY_PATH to point at /data/home/qnxuser/lib
# Note: setting export LD_LIBRARY_PATH=/data/home/qnxuser/lib:$LD_LIBRARY_PATH to search for libm.so.3 first in /data/home/qnxuser/lib does not work.
unset LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/data/home/qnxuser/lib:$LD_LIBRARY_PATH

# Run muslflt_test
cd /data/home/qnxuser/bin
./muslflt_tests
```

Caveats
===

Unfortunately, it is not possible for this library to override every function that can perform floating-point conversion. The main example is `fprintf` and `printf`, because we cannot override them due to libc-internal structures. However, the fix is usually simple -- just switch them to use `snprintf` to a temporary buffer, and then write to `stdout` or a `FILE`.

In addition, when the original versions of overridden functions are required for whatever reason (e.g. some functions in the program depends on the original broken behavior), one must use `dlsym()` from `dlfcn.h` in order to access them beneath the override. Examples of how to do this can be found in `test.cpp` inside this repository.
