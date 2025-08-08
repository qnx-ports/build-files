# libxml2 [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libxml2.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libxml2.yml)

Currently these versions are tested:
+ 2.13.5
+ 2.14.4

Cross-compiled on Ubuntu 24.04 for:
- QNX 8.0 aarch64le on Raspberry Pi 4

Instructions for compiling and running tests are listed below.

*__If you want to run tests__*, make sure to download libxml2 from its source on GNOME or GitHub. 

# Instructions (Ubuntu Only)
## 1. Set up your workspace
1. **Create a working directory.**

Open your terminal, and navigate to an area where you wish to download and build libxml2. I would recommend making a `projects` or `qnx-workspace` folder and working in that directory or a subdirectory within.
```bash
cd ~/<any path>
# Change libxml2-wksp to the name you prefer.
mkdir libxml2-wksp && cd libxml2-wksp
```
2. **Clone `qnx-ports/build-files`.**

This contains  libxml2 qnx build and patch files.
```bash
git clone https://github.com/qnx-ports/build-files.git
ls # make sure build-files is listed in your current directory
```
## 2. Download Source Code
Choose from one of the following options to download the source code.
### From Repository Source (Required for Tests)
1. **Use git to clone the repository.**
```bash
git clone https://github.com/GNOME/libxml2.git
```

2. **(Optional) Checkout your desired version.**

Checkout your desired version. Check https://github.com/GNOME/libxml2.git for branch names or tags per release.
```bash
git checkout <version>
```

### From Tarball
1. **Specify your build target.**

This example targets QNX 8.0.0 on aarch64. For QNX 8.0.0 on x86_64, use `export TARGET=x86_64-pc-nto-qnx8.0.0` instead.
```bash
export TARGET=aarch64-unknown-nto-qnx8.0.0
```

2. **Download the your prefered release tarball.** 

Example: 2.13.5
```bash
curl -O https://download.gnome.org/sources/libxml2/2.13/libxml2-2.13.5.tar.xz
tar xf libxml2-2.13.5.tar.xz
cd libxml2-2.13.5
```
## 3. Apply an appropriate QNX Patch
1. **Locate the correct patchfile.**

Under the `build-files` repo you downloaded, there should be a `ports/libxml2` subfolder. In it are a series of `.patch` files which correspond to different versions of libxml2. \
Locate the appropriate version of the patchvile via its name, `libxml2-VERSION.patch`. If your version is not available, attempt to use the closest available version.

2. **Apply the patch to the source code.**

Apply the patch using the following command:
```bash
# Navigate to the source code's directory
cd <path>/libxml2-wksp/libxml2
# Apply the correct patch, replacing VERSION as needed.
git apply ../build-files/ports/libxml2/libxml2-VERSION.patch
```

## 4. Compilation

There are three options for compilation: You can compile directly using configure and make manually, or you can build recursively in a docker container or in your normal environment. **If running tests, please compile recursively.**

### Recursive Make
1. **Source your QNX Environment.**
```bash
# Source your desired SDP
#  QNX 8.0 will be in the directory ~/qnx800/
#  QNX 7.1 will be in the directory ~/qnx710/
source ~/qnx800/qnxsdp-env.sh
```

2. **(Optional) Download a test suite.**

The standard xml conformance suite is needed when running comprehensive tests. Please locate test suite `20080827` or your desired one from the w3 website: https://www.w3.org/XML/Test/. Then download and unpack it into your `build-files/ports/libxml2` download. \
If this step is not performed, `runxmlconf` test suites will not run on the target.
```bash
cd <path-to-wksp>/libxml2-wksp/build-files/ports/libxml2
curl https://www.w3.org/XML/Test/xmlts20080827.tar.gz | tar -xz
```

3. **Compile via make.**
```bash
# Run Make from your workspace
cd <path-to-your-workspace>
QNX_PROJECT_ROOT=${pwd}/libxml2 make -C build-files/ports/libxml2 install
```

### Recursive Make in Docker Environment

Requires Docker: https://docs.docker.com/engine/install/

1. **Build the Docker image and create a container, then update configure.ac to be compatible.**
```bash
# Start the docker container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Configure libxml to be compatible
cd <your-workspace>
sed -i "s/1.16.3/1.16.1/g" libxml2/configure.ac
```

2. **Source your QNX Environment.**
```bash
# Source your desired SDP
#  QNX 8.0 will be in the directory ~/qnx800/
#  QNX 7.1 will be in the directory ~/qnx710/
source ~/qnx800/qnxsdp-env.sh
```

3. **(Optional) Download a test suite.**

The standard xml conformance suite is needed when running comprehensive tests. Please locate test suite `20080827` or your desired one from the w3 website: https://www.w3.org/XML/Test/. Then download and unpack it into your `build-files/ports/libxml2` download. \
If this step is not performed, `runxmlconf` test suites will not run on the target.
```bash
cd <path-to-wksp>/libxml2-wksp/build-files/ports/libxml2
curl https://www.w3.org/XML/Test/xmlts20080827.tar.gz | tar -xz
```

4. **Compile via make.**
```bash
# Run Make from your workspace
cd <path-to-your-workspace>
QNX_PROJECT_ROOT=${pwd}/libxml2 make -C build-files/ports/libxml2 install
```

### Compiling Directly

1. **Generate Makefile.**

 To activate cross-compiling, we show autotools that build machine has different setup than the host machine.
```bash
cd <path to workspace>/libxml2-wksp/libxml2
./configure \
    --build=x86_64-unknown-linux-gnu \
    --host=$TARGET \
    --prefix=/usr \
    --sysconfdir=/etc \
    --mandir=/usr/share/man \
    --infodir=/usr/share/info \
    --enable-static \
    --with-legacy \
    --with-lzma \
    --with-zlib \
    --with-python=no
```

2. **Compile using Make.**
```bash
make
```

3. **Install compilation products to a folder for transfer to QNX filesystem.**
```bash
make DESTDIR=$OUTPUT_DIR install
```

# Running Tests
This section assumes you installed from source using the recursive makefile structure.
1. Installation via SSH
```bash
# Set up environment variables
# Set to whichever user you will be logging into on the target
TARGET_USER_FOR_INSTALL="qnxuser"
# Set to the target's IP address
TARGET_IP_ADDRESS=<target-ip-address>

# Create needed directories on the target
ssh  $TARGET_USER_FOR_INSTALL@$TARGET_IP_ADDRESS "mkdir -p /data/home/$TARGET_USER_FOR_INSTALL/libxml2/lib"
ssh  $TARGET_USER_FOR_INSTALL@$TARGET_IP_ADDRESS "mkdir -p /data/home/$TARGET_USER_FOR_INSTALL/libxml2/test/.lib"

# Change aarch64 to x86_64 depending on your architecture.
scp $QNX_TARGET/aarch64le/usr/lib/libxml* $TARGET_USER_FOR_INSTALL@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/libxml2/lib
scp -r $QNX_TARGET/aarch64le/usr/local/libxml2_tests/.lib $TARGET_USER_FOR_INSTALL@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/libxml2/test
scp -r $QNX_TARGET/aarch64le/usr/local/libxml2_tests/* $TARGET_USER_FOR_INSTALL@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/libxml2/test
```

2. Running tests
```bash
# Set up LD_LIBRARY_PATH
# ->Replace instances of <user> with the user you installed to (likely qnxuser)
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/<user>/libxml2/lib::/data/home/<user>/libxml2/test/.lib

# Navigate to the test directory and run the suite 
#-> Goes to current user's home directory, change path if installed in another user's home
cd ~/libxml2/test
#-> Add permissions to required files (may be needed):
chmod 764 run_libxml2_tests.sh 
#-> this also logs results to a file called libxml2_tests.out
./runxmlconf # Standard Suite
./run_libxml2_tests.sh &2>1 | tee libxml2_tests.out # Custom script which runs all suites
```
