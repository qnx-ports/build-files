## __======= WARNING =======__  
Compiling gtsam can take upwards of 30 minutes depending on your host machine. It also depends on boost, which can take a similar amount of time to compile if you have not done so already. 

Tested cross-compiling on WSL Ubuntu 24.04 for:
- QNX 8.0 aarch64le on Raspberry Pi 4

Instructions for compiling and running tests are listed below.




# Compile gtsam for SDP 7.1/8.0 on an Ubuntu Host

### *Prerequisites:*
#### __`boost` must be installed in $QNX_TARGET__
1. Go to https://github.com/qnx-ports/build-files/tree/c-ares_files/ports/boost and follow the instructions in the README. 

2. __FOR SDP 8.0:__ When building `boost`, set PREFIX to '/usr' for SDP 8.0:
```bash
#Modified build command for boost
PREFIX="/usr" QNX_PROJECT_ROOT="$(pwd)/boost" make -C build-files/ports/boost/ install -j4 
```

### *Steps:* 

1. Create a new workspace or navigate to a desired one
```bash
mkdir gtsam_wksp && cd gtsam_wksp
```

2. Clone the `gtsam` and `build_files` repos
```bash
#Pick one:
#Via HTTPS
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/gtsam.git

#Via SSH
git clone git@github.com:qnx-ports/build-files.git 
git clone git@github.com:qnx-ports/gtsam.git 
```

3. Source your SDP (Installed from QNX Software Center)
```bash
#QNX 8.0 will be in the directory ~/qnx800/
#QNX 7.1 will be in the directory ~/qnx710/
source ~/qnx800/qnxsdp-env.sh
```

4. __OPTIONAL/RECOMMENDED:__ If you know which platforms you are building for (aarch64le/x86_64), it is highly recommended that you only build for the platforms you are using.
```bash
#Blocking unused builds
#4.1 Navigate to <your-workspace>/build-files/ports/gtsam
cd build-files/ports/gtsam
```
```bash
#4.2 List build targets
ls nto-*
# You should see an output like this:
# nto-aarch64
# nto-x86_64
# ...
```
```bash
#4.3 Identify which of the above you will not be using and navigate into its folder. 
#i.e., Raspberry Pi is an aarch64 architecture, thus we would not need x86_64
cd nto-x86_64
```
```bash
#4.4 Mark this folder as "do not make" via an empty Makefile.dnm file
touch Makefile.dnm
cd ..
```
```bash
#4.5 Repeat 4.3 & 4.4 for each unused architecture
#from build-files/ports/gtsam
touch nto-<unused-arhcitecture>/Makefile.dnm
```

5. Build the project in your workspace from Step 1
```bash
#Run this in gtsam_wksp or whatever you named your original directory
#Changing the -j option can improve build time (see make documentation)
QNX_PROJECT_ROOT="$PWD/gtsam" make -C build-files/ports/gtsam install -j4
#To build tests, also define QNX_BUILD_TESTS and QNX_TARGET_DATASET_DIR
QNX_BUILD_TESTS="yes" QNX_TARGET_DATASET_DIR="/data/home/qnxuser/gtsam/test" QNX_PROJECT_ROOT="$PWD/gtsam" make -C build-files/ports/gtsam install -j4
```

**NOTE**: Before rebuilding, you may need to delete the `/build` subdirectories and their contents in `build-files/ports/gtsam/nto-aarch64/le/build` and `build-files/ports/gtsam/nto-x86_64/o/build`. This MUST be done when changing from SDP 7.1 to 8 or vice versa, as it will link against the wrong shared objects and not show an error until testing.
```bash
#From your workspace:
make -C build-files/ports/gtsam clean
```

# Compile gtsam for SDP 7.1/8.0 in a Docker Container

### *Prerequisites:*
#### __`boost` must be installed in $QNX_TARGET__
Instructions for building boost are included in the steps below.

### *Steps:* 


1. Create a new workspace or navigate to a desired one
```bash
mkdir gtsam_wksp && cd gtsam_wksp
```

2. Clone the `gtsam`, `boost` and `build_files` repos
```bash
#Pick one:
#Via HTTPS
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/boost.git
git clone https://github.com/qnx-ports/gtsam.git

#Via SSH
git clone git@github.com:qnx-ports/build-files.git 
git clone git@github.com:qnx-ports/boost.git
git clone git@github.com:qnx-ports/gtsam.git 
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

5. __OPTIONAL/RECOMMENDED:__ If you know which platforms you are building for (aarch64le/x86_64), it is highly recommended that you only build for the platforms you are using.
```bash
#Blocking unused builds
#4.1 Navigate to <your-workspace>/build-files/ports/gtsam
cd build-files/ports/gtsam
```
```bash
#4.2 List build targets
ls nto-*
# You should see an output like this:
# nto-aarch64
# nto-x86_64
# ...
```
```bash
#4.3 Identify which of the above you will not be using and navigate into its folder. 
#i.e., Raspberry Pi is an aarch64 architecture, thus we would not need x86_64
cd nto-x86_64
```
```bash
#4.4 Mark this folder as "do not make" via an empty Makefile.dnm file
touch Makefile.dnm
cd ..
```
```bash
#4.5 Repeat 4.3 & 4.4 for each unused architecture
#from build-files/ports/gtsam
touch nto-<unused-arhcitecture>/Makefile.dnm
```
```bash
#4.6 Repeat 4.1-4.5 for the boost build files
cd build-files/ports/boost
```
6. Build `boost`
```bash
# Checkout and patch your boost repo for QNX
cd <your-workspace>/boost
git checkout boost-1.82.0
git submodule update --init --recursive
cd tools/build && git apply ../../../build-files/ports/boost/tools_qnx.patch

# Build boost (WARNING: This process can take upwards of 20 minutes)
cd ../../..
make -C build-files/ports/boost/ install QNX_PROJECT_ROOT="$(pwd)/boost" -j4
```

7. Build gtsam in your workspace from Step 1
```bash
#Run this in gtsam_wksp or whatever you named your original directory
#Changing the -j option can improve build time (see make documentation)
QNX_PROJECT_ROOT="$PWD/gtsam" make -C build-files/ports/gtsam install -j4
#To build tests, also define QNX_BUILD_TESTS and QNX_TARGET_DATASET_DIR
QNX_BUILD_TESTS="yes" QNX_TARGET_DATASET_DIR="/data/home/qnxuser/gtsam/test" QNX_PROJECT_ROOT="$PWD/gtsam" make -C build-files/ports/gtsam install -j4
```

**NOTE**: Before rebuilding, you may need to delete the `/build` subdirectories and their contents in `build-files/ports/gtsam/nto-aarch64/le/build` and `build-files/ports/gtsam/nto-x86_64/o/build`. This MUST be done when changing from SDP 7.1 to 8 or vice versa, as it will link against the wrong shared objects and not show an error until testing.
```bash
#From your workspace:
make -C build-files/ports/gtsam clean
```

# Running Tests on a Target 
Some distributions of QNX have critical directories stored in a read-only partition (`/`, `/system`, `/etc`, etc). Included in these are the default `bin` and `lib` directories. If this is the case, follow the "Installing in home directory" instructions.

Instructions for compiling and running tests are listed below.

### Installing in home directory
1. Installation
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>

#Select the home directory to install to (this will install to /data/home/qnxuser)
TARGET_USER_FOR_INSTALL="qnxuser"

#Set the prefix you sued when building (if not set, /usr/local)
PREFIX="/usr/local"

#Create new directories on the target
ssh $TARGET_USER_FOR_INSTALL@$TARGET_IP_ADDRESS "mkdir -p /data/home/$TARGET_USER_FOR_INSTALL/gtsam/lib"
ssh $TARGET_USER_FOR_INSTALL@$TARGET_IP_ADDRESS "mkdir -p /data/home/$TARGET_USER_FOR_INSTALL/gtsam/test/gtsam_examples/Data/Balbianello"

#If copying to an x86_64 install, change /aarch64le/ to /x86_64/
scp $QNX_TARGET/aarch64le/$PREFIX/lib/libboost* $TARGET_USER_FOR_INSTALL@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/gtsam/lib
scp $QNX_TARGET/aarch64le/$PREFIX/lib/libmetis* $TARGET_USER_FOR_INSTALL@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/gtsam/lib
scp $QNX_TARGET/aarch64le/$PREFIX/lib/libgtsam* $TARGET_USER_FOR_INSTALL@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/gtsam/lib

#tests and provided test script
scp -r $QNX_TARGET/aarch64le/$PREFIX/bin/gtsam_tests/* $TARGET_USER_FOR_INSTALL@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/gtsam/test
```

2. Running Tests
```bash
#SSH into target
ssh qnxuser@<target-ip-address-or-hostname>

#Export new library path (Change qnxuser to whatever you set for TARGET_USER_FOR_INSTALL)
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/gtsam/lib

#Run test binary
cd ~/gtsam/test         #NOTE: ~ will direct you to the current user's home directory, 
                        #which may be incorrect depending on your choices above. 
                        #Navigate to /data/home to see all user home directories
./run_tests.sh &2>1 | tee gtsam_tests.out
```