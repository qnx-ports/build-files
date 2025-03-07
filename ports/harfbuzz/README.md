# harfbuzz [![Build](https://github.com/qnx-ports/build-files/actions/workflows/harfbuzz.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/harfbuzz.yml)

Supports QNX7.1 and QNX8.0

## naming clarification

In some other package managers, there might be some extra package as "harfbuzz-icu". This is not an extra package of harfbuzz, they are optional features of it. Here is a list of available features built by the script:

+ `harfbuzz-icu`
+ `harfbuzz-cairo`
+ `harfbuzz-gobject`
+ `harfbuzz-subset`

# Dependency warning

You should compile and install its dependencies before proceeding (in order).
+ [`graphite`](https://github.com/qnx-ports/build-files/tree/main/ports/graphite)
+ [`iconv`](https://github.com/qnx-ports/build-files/tree/main/ports/iconv)
+ [`gettext-runtime`](https://github.com/qnx-ports/build-files/tree/main/ports/gettext-runtime)
+ [`icu`](https://github.com/qnx-ports/build-files/tree/main/ports/icu)
+ [`glib`](https://github.com/qnx-ports/build-files/tree/main/ports/glib)
+ [`freetype`](https://github.com/qnx-ports/build-files/tree/main/ports/freetype)
+ [`cairo`](https://github.com/qnx-ports/build-files/tree/main/ports/cairo)

A convinience script `install_all.sh` is provided for easy installation of all required dependencies, execute it just like a regular installation and set INSTALL_ROOT and JLEVEL.
To use the convinence script, please clone the entire `build-files` repository first. 
This convinience script will call `install_all.sh` inside dependencies recursively.

# Compile the port for QNX in a Docker container or Ubuntu host

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace

# Obtain build tools and sources
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/mesonbuild/meson.git
git clone https://github.com/harfbuzz/harfbuzz.git

#checkout to the latest stable 
cd harfbuzz
git checkout 10.2.0
cd ..

# Optionally Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Optionally use the convenience script to install all dependencies
chmod +x ./build-files/ports/harfbuzz/install_all.sh
./build-files/ports/harfbuzz/install_all.sh

# Build harfbuzz
QNX_PROJECT_ROOT="$(pwd)/harfbuzz" JLEVEL=4 make -C build-files/ports/harfbuzz install
```

# Deploy binaries via SSH
Ensure all dependencies are deployed to the target system as well.
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/bin/hb-* $TARGET_USER@$TARGET_IP_ADDRESS:~/bin
scp -r ~/qnx800/target/qnx/aarch64le/usr/local/lib/libharfbuzz* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib
```

If the `~/bin`, `~/lib` directories do not exist, create them with:
```bash
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/bin"
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/lib"
```

# Tests
Below are the test suites available.
+ `hb-api`: some of the unicode tests fail.
+ `hb-fuzzing`: all passed  
+ `hb-threads`: all passed  
+ `hb-shape`: some emoji tests failed
+ `hb-subsets`: some failed, likely caused by locale settings. It should be false negative.

## Running the test suites
Copy the following files from `build-files/ports/harfbuzz` to your current working directory:
+ `run_api_tests.sh`
+ `run_fuzzer_tests.sh`
+ `run_shape_tests.sh`
+ `run_subset_tests.sh`
+ `run_thread_tests.sh`
+ `generate_hb_test.sh`

### Generate test binaries
Set environment `BUILD_TEST=enabled` before building harfbuzz to build tests. Once the test is built, execute the following command to generate a `hb-test` folder that contains all required test files:
```bash
BDIR=path/to/build-files/ports/harfbuzz/nto-aarch64-le/build SRC=path/to/harfbuzz/ OUT=out/ ./generate_hb_test.sh
```
Copy `out/hb-test` to your target:
```bash
scp -r out/hb-test $TARGET_USER@$TARGET_IP_ADDRESS:~
```

### Running different test suites
On your target system, navaigate to `hb-test` you just copied. Each subfolder of `hb-test` will contain a `run_*_tests.sh` script. This is the script you need to execute in order to run tests on QNX. Test resutls will be output to the terminal and in a `tests.result` file inside each subfolder.

`iftb_requirements` for `hb-subset` is skipped because harfbuzz on QNX does not support that.

Make sure you target has python and available and `cd`into the subfoder before running any of these tests.
+ `run_shape_tests.sh`: This required a path contaisn `hb-shape` executable as its argument. It is usually in `~/bin`.
+ `run_subset_tests.sh`: This required a path contains `hb-subset` executable as its argument. It is usually in `~/bin`.
