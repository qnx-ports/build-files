# Foonathan Memory [![Build](https://github.com/qnx-ports/build-files/actions/workflows/memory.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/memory.yml)

### Tested for QNX 7.1 and 8.0 SDPs
Cross-compiled on Ubuntu 24.04 for:
- QNX 8.0 aarch64le on Raspberry Pi 4
- QNX 7.1 x86_64 on VirtualBox 6.1

Instructions for compiling and running tests are listed below.

# Compile memory for SDP 7.1/8.0 on an Ubuntu Host
1. Create a new workspace or navigate to a desired one
```bash
mkdir memory_wksp && cd memory_wksp
```

2. Clone the `memory` and `build_files` repos
```bash
#Pick one:
#Via HTTPS
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/memory.git

#Via SSH
git clone git@github.com:qnx-ports/build-files.git
git clone git@github.com:qnx-ports/memory.git
```

3. Source your SDP (Installed from QNX Software Center)
```bash
#QNX 8.0 will be in the directory ~/qnx800/
#QNX 7.1 will be in the directory ~/qnx710/
source ~/qnx800/qnxsdp-env.sh
```

4. Build the project in your workspace from Step 1
```bash
QNX_PROJECT_ROOT="$(PWD)/memory" make -C build-files/ports/memory install -j4
```

**NOTE**: Before rebuilding, you may need to delete the `/build` subdirectories and their contents in `build-files/ports/memory/nto/aarch64/le` and `build-files/ports/memory/nto/x86_64/so`. This MUST be done when changing from SDP 7.1 to 8 or vice versa, as it will link against the wrong shared objects and not show an error until testing.
```bash
#From your workspace:
make -C build-files/ports/memory clean
```

# Compile memory for SDP 7.1/8.0 in a Docker Container
Requires Docker: https://docs.docker.com/engine/install/

1. Create a new workspace or navigate to a desired one
```bash
mkdir memory_wksp && cd memory_wksp
```

2. Clone the  `build_files` repo
```bash
#Pick one:
#Via HTTPS
git clone https://github.com/qnx-ports/build-files.git

#Via SSH
git clone git@github.com:qnx-ports/build-files.git
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

5. Clone the `memory` repo to the workspace
```bash
#Navigate back to memory_wksp
#The docker container will put you in your home directory
cd <path-to-workspace>

#Pick one:
#Via HTTPS
git clone https://github.com/qnx-ports/memory.git

#Via SSH
git clone git@github.com:qnx-ports/memory.git
```

6. Build the project in your workspace from Step 1
```bash
QNX_PROJECT_ROOT="$(pwd)/memory" make -C build-files/ports/memory install -j4
```

**NOTE**: Before rebuilding, you may need to delete the `/build` subdirectories and their contents in `build-files/ports/memory/nto/aarch64/le` and `build-files/ports/memory/nto/x86_64/so`. This MUST be done when changing from SDP 7.1 to 8 or vice versa, as it will link against the wrong shared objects and not show an error until testing.
```bash
#From your workspace:
make -C build-files/ports/memory clean
```

**NOTE**: Before rebuilding, you may need to delete the `/build` subdirectories and their contents in `build-files/ports/memory/nto/aarch64/le` and `build-files/ports/memory/nto/x86_64/so`. This MUST be done when changing from SDP 7.1 to 8 or vice versa, as it will link against the wrong shared objects and not show an error until testing.
```bash
#From your workspace:
make -C build-files/ports/memory clean
```

# Running Tests on a Target
Some distributions of QNX have critical directories stored in a read-only partition (`/`, `/system`, `/etc`, etc). Included in these are the default `bin` and `lib` directories. If this is the case, follow the "Installing in home directory" instructions

### Installing in /usr/ (default)
1. Installation
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>

#If copying to an x86_64 install, change /aarch64le/ to /x86_64/
scp $QNX_TARGET/aarch64le/usr/bin/foonathan_memory_test qnxuser@$TARGET_IP_ADDRESS:/usr/bin
scp $QNX_TARGET/aarch64le/usr/lib/libfoonathan_memory* qnxuser@$TARGET_IP_ADDRESS:/usr/lib
```

2. Running Tests
```bash
#SSH into target
ssh qnxuser@<target-ip-address-or-hostname>

#Run test binary
cd /usr/bin
chmod 744 foonathan_memory_test
./foonathan_memory_test
```

### Installing in home directory
1. Installation
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>

#Select the home directory to install to (this will install to /data/home/qnxuser)
TARGET_USER_FOR_INSTALL="qnxuser"

#Create new directories on the target
ssh qnxuser@$TARGET_IP_ADDRESS "mkdir -p /data/home/$TARGET_USER_FOR_INSTALL/memory/lib"

#If copying to an x86_64 install, change /aarch64le/ to /x86_64/
scp $QNX_TARGET/aarch64le/usr/bin/foonathan_memory_test qnxuser@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/memory/
scp $QNX_TARGET/aarch64le/usr/lib/libfoonathan_memory* qnxuser@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/memory/lib
```

2. Running Tests
```bash
#SSH into target
ssh qnxuser@<target-ip-address-or-hostname>

#Export new library path (Change qnxuser to whatever you set for TARGET_USER_FOR_INSTALL)
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/memory/lib

#Run test binary
cd ~/memory/            #NOTE: ~ will direct you to the current user's home directory,
                        #which may be incorrect depending on your choices above.
                        #Navigate to /data/home to see all user home directories
chmod 744 foonathan_memory_test
./foonathan_memory_test
```