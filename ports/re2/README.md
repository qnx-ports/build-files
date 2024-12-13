# re2 [![Build](https://github.com/qnx-ports/build-files/actions/workflows/re2.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/re2.yml)

### Tested for QNX 7.1 and 8.0 SDPs
Cross-compiled on Ubuntu 24.04 for:
- QNX 8.0 aarch64le on Raspberry Pi 4
- QNX 7.1: x86_64 on qemu VM

Instructions for compiling and running tests are listed below.


# Compile re2 for SDP 7.1/8.0 on an Ubuntu Host or in a Docker container
### *Dependencies:*
The following libraries are required. Information on installing these can be found in https://github.com/qnx-ports/build-files, though their installation is included in the steps below.
- `googletest`, https://github.com/qnx-ports/googletest
- `benchmark`, https://github.com/qnx-ports/benchmark
- `muslflt`, https://github.com/qnx-ports/muslflt
- `abseil-cpp`, https://github.com/qnx-ports/abseil-cpp

If building in a Docker Container, Docker is required:
https://docs.docker.com/engine/install/

### *Steps:*
1. Create a new workspace or navigate to a desired one
```bash
mkdir re2_wksp && cd re2_wksp
```

2. Clone `re2`, `build_files`, and the required libraries. You can skip dependancies you already have installed in $QNX_TARGET.
```bash
#Pick one:
#Via HTTPS
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/googletest.git
git clone https://github.com/qnx-ports/benchmark.git
git clone https://github.com/qnx-ports/muslflt.git
git clone https://github.com/qnx-ports/abseil-cpp.git
git clone https://github.com/qnx-ports/re2.git

#Via SSH
git clone git@github.com:qnx-ports/build-files.git
git clone git@github.com:qnx-ports/googletest.git
git clone git@github.com:qnx-ports/benchmark.git
git clone git@github.com:qnx-ports/muslflt.git
git clone git@github.com:qnx-ports/abseil-cpp.git
git clone git@github.com:qnx-ports/re2.git
```

3. *Optional* Build the Docker image and create a container
```bash
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh
```

4. Source your SDP (Installed from QNX Software Center)
```bash
#QNX 8.0 will be in the directory ~/qnx800/
#QNX 7.1 will be in the directory ~/qnx710/
source ~/qnx800/qnxsdp-env.sh
```

5. Build dependencies in order in your workspace from Step 1. Skip those you already have installed.
```bash
#1. googletest
BUILD_TESTING="OFF" QNX_PROJECT_ROOT="$(pwd)/googletest" make -C build-files/ports/googletest install -j$(nproc)
#2. benchmark
QNX_PROJECT_ROOT="$(pwd)/benchmark" make -C build-files/ports/benchmark install -j$(nproc)
#3. muslflt
QNX_PROJECT_ROOT="$(pwd)/muslflt" make -C build-files/ports/muslflt/ install -j$(nproc)
#4. abseil-cpp
BUILD_TESTING="OFF" QNX_PROJECT_ROOT="$(pwd)/abseil-cpp" make -C build-files/ports/abseil-cpp install -j$(nproc)
```


6. Build the project in your workspace from Step 1
```bash
# Do not set QNX_BUILD_TESTS to anything if you do not want tests built.
# With Tests
OSLIST=nto QNX_BUILD_TESTS="yes" QNX_PROJECT_ROOT="$(pwd)/re2" make -C build-files/ports/re2 install -j$(nproc)
# Without Tests
OSLIST=nto QNX_PROJECT_ROOT="$(pwd)/re2" make -C build-files/ports/re2 install -j$(nproc)
```

**NOTE**: Before rebuilding, you may need to delete the `/build` subdirectories and their contents in `build-files/ports/re2/nto-aarch64-le` and `build-files/ports/re2/nto-x86_64-o`. This MUST be done when changing from SDP 7.1 to 8 or vice versa, as it will link against the wrong shared objects and not show an error until testing.
```bash
#From your workspace:
make -C build-files/ports/re2 clean
```

# Running Tests on a Target
Some distributions of QNX have critical directories stored in a read-only partition (`/`, `/system`, `/etc`, etc). Included in these are the default `bin` and `lib` directories. If this is the case, follow the "Installing in home directory" instructions



### Installing in home directory
1. Installation
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>

#Select the home directory to install to (this will install to /data/home/qnxuser)
TARGET_USER_FOR_INSTALL="qnxuser"

#Create new directories on the target
ssh qnxuser@$TARGET_IP_ADDRESS "mkdir -p /data/home/$TARGET_USER_FOR_INSTALL/re2/lib"
ssh qnxuser@$TARGET_IP_ADDRESS "mkdir -p /data/home/$TARGET_USER_FOR_INSTALL/re2/test"

#If copying to an x86_64 install, change /aarch64le/ to /x86_64/
#Dependencies
scp $QNX_TARGET/aarch64le/usr/local/lib/libabsl* qnxuser@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/re2/lib
scp $QNX_TARGET/aarch64le/usr/local/lib/libbenchmark* qnxuser@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/re2/lib
scp $QNX_TARGET/aarch64le/usr/local/lib/libgmock* qnxuser@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/re2/lib
scp $QNX_TARGET/aarch64le/usr/local/lib/libgtest* qnxuser@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/re2/lib
scp $QNX_TARGET/aarch64le/usr/local/lib/libmuslflt* qnxuser@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/re2/lib

#re2
scp $QNX_TARGET/aarch64le/usr/local/lib/libre2* qnxuser@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/re2/lib

#Tests
scp $QNX_TARGET/aarch64le/usr/local/bin/re2_tests/libtesting* qnxuser@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/re2/lib
scp $QNX_TARGET/aarch64le/usr/local/bin/re2_tests/*_test qnxuser@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/re2/test

#Testing Script (replace path-to-your-workspace with the one you cloned build-files into)
scp <path-to-your-workspace>/build-files/ports/re2/run_tests.sh qnxuser@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/re2/test
```

2. Running Tests
```bash
#SSH into target
ssh qnxuser@<target-ip-address-or-hostname>

#Export new library path (Change qnxuser to whatever you set for TARGET_USER_FOR_INSTALL)
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/re2/lib

#Run test binary
cd ~/re2/test           #NOTE: ~ will direct you to the current user's home directory,
                        #which may be incorrect depending on your choices above.
                        #Navigate to /data/home to see all user home directories
./run_tests.sh &2>1 | tee re2_test.out
```