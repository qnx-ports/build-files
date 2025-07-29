# clapack [![Build](https://github.com/qnx-ports/build-files/actions/workflows/clapack.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/clapack.yml)

### Tested so far:
Cross-compiled on Ubuntu 24.04 via WSL for:
- QNX 8.0 aarch64le on Raspberry Pi 4

Instructions for compiling and running tests are listed below.

# Compile CLAPACK for SDP 7.1/8.0 on Ubuntu Host or in a Docker Container
1. Create new workspace or navigate to a desired one
```bash
mkdir clapack_wksp && cd clapack_wksp
```

2. Clone `build_files` and `clapack`
```bash
#Pick one:
#Via HTTPS
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/clapack.git

#Via SSH
git clone git@github.com:qnx-ports/build-files.git
git clone git@github.com:qnx-ports/clapack.git
```

3. Build the Docker image and create a container
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

5. Build the project in your workspace from Step 1
```bash
#Default:
make -C build-files/ports/clapack install

#If you cloned clapack to somewhere else, you can specify the correct path to the directory as such:
QNX_PROJECT_ROOT=/path/to/clapack make -C build-files/ports/clapack install

#By default, tests are built for the shell /bin/sh . If you have mounted the target IFS's differently, you can specify the path to your desired shell as follows:
TEST_TARGET_SHELL=/path/to/sh make -C build-files/ports/clapack install
```


**NOTE**: Before rebuilding, you may need to delete the `/build` subdirectories and their contents in the `build-files/ports/clapack/*/*` subfolders. This should be done when changing from SDP 7.1 to 8 or vice versa.
```bash
#From your workspace:
make -C build-files/ports/clapack clean
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

#Depending on how you set PREFIX, CLAPACK may have installed in different places (usr/local, usr)
#Set $PREFIX to accomodate for this. The default is /usr/local
PREFIX=/usr/local

#Create new directories on the target
ssh qnxuser@$TARGET_IP_ADDRESS "mkdir -p /data/home/$TARGET_USER_FOR_INSTALL/clapack/lib"
ssh qnxuser@$TARGET_IP_ADDRESS "mkdir -p /data/home/$TARGET_USER_FOR_INSTALL/clapack/test"

#If copying to an x86_64 install, change /aarch64le/ to /x86_64/
scp $QNX_TARGET/aarch64le/$PREFIX/bin/clapack_tests/* qnxuser@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/clapack/test
scp $QNX_TARGET/aarch64le/$PREFIX/lib/libf2c.so* qnxuser@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/clapack/lib
scp $QNX_TARGET/aarch64le/$PREFIX/lib/liblapack.so* qnxuser@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/clapack/lib
scp $QNX_TARGET/aarch64le/$PREFIX/lib/libblas.so* qnxuser@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/clapack/lib
scp $QNX_TARGET/aarch64le/$PREFIX/lib/libopenblas.so* qnxuser@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/clapack/lib
scp $QNX_TARGET/aarch64le/$PREFIX/lib/libtmglib.so* qnxuser@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/clapack/lib
```

2. Running Tests
```bash
#SSH into target
ssh qnxuser@<target-ip-address-or-hostname>

#Export new library path (Change qnxuser to whatever you set for TARGET_USER_FOR_INSTALL)
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/clapack/lib

#Change to test directory (Change qnxuser to whatever you set for TARGET_USER_FOR_INSTALL)
cd /data/home/qnxuser/clapack/test

#Note: as tests are .sh files, you may need to give them permissions
chmod 744 *.sh

#Run one test
./<test-name>.sh
```
Running all tests for clapack takes some time, but can be done through a simple shell script.

Copy the following into a .sh file located in the same directory as your tests, and use `chmod` to give it proper permissions.
```bash
#! /bin/sh
echo "Finding tests..."
for f in *.sh; do
    echo "$f"
done

echo "Running tests..."
for f in *.sh; do
    echo "Running $f"
    bash "$f"
done

echo "Complete"
```
Note that each individual test script is composed of hundreds to thousands of tests, of which not all will pass. That is expected for floating point within a certain margin of error. If a test script exceeds its margin of error, it will exit with a positive error code.