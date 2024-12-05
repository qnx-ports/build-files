### NOTE: Currently only c-ares v1.30.0 is supported. v1.34.3 support is being worked on.

### Tested for QNX 7.1 and 8.0 SDPs
Cross-compiled on Ubuntu 24.04 for:
- QNX 8.0 aarch64le on Raspberry Pi 4
- QNX 8.0 x86_64 on QEMU
- QNX 7.1 x86_64 on VirtualBox 6.1

Instructions for compiling and running tests are listed below.


# Compile c-ares for SDP 7.1/8.0 in a Docker Container
### *Pre-requisites:*

#### `gtest` and `gmock` must be installed on your target.
Go to https://github.com/qnx-ports/build-files/tree/c-ares_files/ports/googletest and follow the instructions, or follow the instructions below which include them in the build process.

### *Steps:*
1. Create a new workspace or navigate to a desired one
```bash
mkdir c-ares_wksp && cd c-ares_wksp
```

2. Clone the  `build_files` repo
```bash
#Pick one:
#Via HTTPS
git clone https://github.com/qnx-ports/build-files.git

#Via SSH
git clone git@github.com:qnx-ports/build-files.git 
```

3. Build the Docker image and crease a container
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

5. Clone the `c-ares` and `googletest` repos to the workspace
```bash
#Navigate back to memory_wksp
#The docker container will put you in your home directory
cd <path-to-workspace>

#Pick one:
#Via HTTPS
git clone https://github.com/qnx-ports/c-ares.git
git clone https://github.com/qnx-ports/googletest.git

#Via SSH
git clone git@github.com:qnx-ports/c-ares.git 
git clone git@github.com:qnx-ports/googletest.git 
```

6. Build the project in your workspace from Step 1
```bash
#build googletest
BUILD_TESTING="OFF" QNX_PROJECT_ROOT="$(pwd)/googletest" make -C build-files/ports/googletest install -j4

#build c-ares
QNX_PROJECT_ROOT="$(PWD)/c-ares" make -C build-files/ports/c-ares install -j4
```



# Compile c-ares for SDP 7.1/8.0 on an Ubuntu Host
### *Pre-requisites:*
#### `autoconf` must be installed on your host system.
```bash
# Ubuntu
sudo apt-get update
sudo apt-get install autoconf
```
#### `gtest` and `gmock` must be installed on your target.
Go to https://github.com/qnx-ports/build-files/tree/c-ares_files/ports/googletest and follow the instructions.

### *Steps:*
1. Create a new workspace or navigate to a desired one
```bash
mkdir c-ares_wksp && cd c-ares_wksp
```

2. Clone the `c-ares` and `build_files` repos
```bash
#Pick one:
#Via HTTPS
git clone https://github.com/qnx-ports/c-ares.git
git clone https://github.com/qnx-ports/memory.git

#Via SSH
git clone git@github.com:qnx-ports/c-ares.git 
git clone git@github.com:qnx-ports/memory.git 
```

3. Source your SDP (Installed from QNX Software Center)
```bash
#QNX 8.0 will be in the directory ~/qnx800/
#QNX 7.1 will be in the directory ~/qnx710/
source ~/qnx800/qnxsdp-env.sh
```

4. Run autoconf in the c-ares directory
```bash
cd c-ares
autoreconf -fi
cd ..
```


5. Build the project in your workspace from Step 1
```bash
QNX_PROJECT_ROOT="$(PWD)/c-ares" make -C build-files/ports/c-ares install -j4
```

**NOTE**: Before rebuilding, you may need to clean the QNX build directories `nto-aarch64-le` and `nto-x86_64-o`. This MUST be done when changing from SDP 7.1 to 8 or vice versa, as it will link against the wrong shared objects and not show an error until testing.
```bash
#From your workspace:
rm -rf build-files/ports/c-ares/nto-*/!(GNUmakefile)
#Removes everything from the nto-aarch64-le and nto-x86_86-o directories except the GNU makefile
#Note: make clean currently does not work.
```

# Running Tests on a Target
Some distributions of QNX have critical directories stored in a read-only partition (`/`, `/system`, `/etc`, etc). Included in these are the default `bin` and `lib` directories. If this is the case, follow the "Installing in home directory" instructions


### Installing in home directory
1. Installation
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>

#Select the home directory to install to (this will install to /data/home/root)
TARGET_USER_FOR_INSTALL="root"

#Create new directories on the target
ssh root@$TARGET_IP_ADDRESS "mkdir -p /data/home/$TARGET_USER_FOR_INSTALL/c-ares/lib"

#If copying to an x86_64 install, change /aarch64le/ to /x86_64/
scp $QNX_TARGET/aarch64le/tests/cares/arestest root@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/c-ares/
scp $QNX_TARGET/aarch64le/usr/lib/libcares* root@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/c-ares/lib

#gmock and gtest must be installed on the target.
#If you did not do so during their build process, tranfer the shared objects over now.
#If copying to an x86_64 install, change /aarch64le/ to /x86_64/
scp $QNX_TARGET/aarch64le/usr/lib/libgtest* root@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/c-ares/lib
scp $QNX_TARGET/aarch64le/usr/lib/libgmock* root@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/c-ares/lib
```

2. Running Tests
```bash
#SSH into target
ssh root@<target-ip-address-or-hostname>

#Export new library path (Change root to whatever you set for TARGET_USER_FOR_INSTALL)
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/root/c-ares/lib

#Run test binary
cd ~/c-ares/            #NOTE: ~ will direct you to the current user's home directory, 
                        #which may be incorrect depending on your choices above. 
                        #Navigate to /data/home to see all user home directories
./arestest
```