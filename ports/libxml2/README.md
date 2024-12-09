### Tested for QNX 7.1 and 8.0 SDPs
Cross-compiled on Ubuntu 24.04 for:
- QNX 8.0 aarch64le on Raspberry Pi 4

Instructions for compiling and running tests are listed below.

*__If you want to run tests__*, follow the compiling from source instructions (or use the recursive makefile directory provided in this repo with the tarball).

# Compile libxml2 from tarball for SDP 7.1/8.0
1. Specify your build target. This example targets QNX 8.0.0 on aarch64. For QNX 8.0.0 on x86_64, use `export TARGET=x86_64-pc-nto-qnx8.0.0` instead.
```bash
export TARGET=aarch64-unknown-nto-qnx8.0.0
```

2. Download the latest release tarball. As of writing, it's 2.13.5
```bash
curl -O https://download.gnome.org/sources/libxml2/2.13/libxml2-2.13.5.tar.xz
tar xf libxml2-2.13.5.tar.xz
cd libxml2-2.13.5
```

3. Generate Makefile. To activate cross-compiling, we show autotools that build machine has different setup than the host machine.
```bash
./configure \
    --build=x86_64-unknown-linux-gnu \
    --host=$QNX_TARGET \
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

4. Actual compiliing
```bash
make
```

5. Install compilation products to a folder for transfer to QNX filesystem
```bash
make DESTDIR=$OUTPUT_DIR install
```

# Compile libxml2 from source for SDP 7.1/8.0 in a Docker Container
Requires Docker: https://docs.docker.com/engine/install/

1. Create a new workspace or navigate to an existing one
```bash
mkdir libxml2_wksp && cd libxml2_wksp
```

2. Clone the `build-files` and `libxml2` repos
```bash
#Currently from gnome; changes in qnx-ports one are not ready
#Via HTTPS
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/GNOME/libxml2.git

#Via SSH
git clone git@github.com:qnx-ports/build-files.git 
git clone git@github.com:GNOME/libxml2.git
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
# Navigate back to your workspace
cd <path-to-your-workspace>
# Build
QNX_PROJECT_ROOT="$(pwd)/libxml2" make -C build-files/ports/libxml2 install -j4
```


# Compile libxml2 from source for SDP 7.1/8.0 on an Ubuntu Host
Requires Docker: https://docs.docker.com/engine/install/

1. Create a new workspace or navigate to an existing one
```bash
mkdir libxml2_wksp && cd libxml2_wksp
```

2. Clone the `build-files` and `libxml2` repos
```bash
#Via HTTPS
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/libxml2.git

#Via SSH
git clone git@github.com:qnx-ports/build-files.git 
git clone git@github.com:qnx-ports/libxml2.git
```

3. Source your SDP (Installed from QNX Software Center)
```bash
#QNX 8.0 will be in the directory ~/qnx800/
#QNX 7.1 will be in the directory ~/qnx710/
source ~/qnx800/qnxsdp-env.sh
```

4. Build the project in your workspace from Step 1
```bash
# Navigate back to your workspace
cd <path-to-your-workspace>
# Build
QNX_PROJECT_ROOT="$(pwd)/libxml2" make -C build-files/ports/libxml2 install -j4
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
./run_libxml2_tests.sh &2>1 | tee libxml2_tests.out
```
