### Tested for QNX 7.1 and 8.0 SDPs
Cross-compiled on Ubuntu 24.04 for:
- QNX 8.0 aarch64le on Raspberry Pi 4

NOTE: NOT ALL TESTS ARE CURRENTLY PASSING
Instructions for compiling and running tests are listed below.

# Compile libxml2 for SDP 7.1/8.0 in a Docker Container
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
cd <path-to-your-workspace.
# Build
QNX_PROJECT_ROOT="$(pwd)/libxml2" make -C build-files/ports/libxml2 install -j4
```


# Compile libxml2 for SDP 7.1/8.0 on an Ubuntu Host
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

3. Source your SDP (Installed from QNX Software Center)
```bash
#QNX 8.0 will be in the directory ~/qnx800/
#QNX 7.1 will be in the directory ~/qnx710/
source ~/qnx800/qnxsdp-env.sh
```

4. Build the project in your workspace from Step 1
```bash
# Navigate back to your workspace
cd <path-to-your-workspace.
# Build
QNX_PROJECT_ROOT="$(pwd)/libxml2" make -C build-files/ports/libxml2 install -j4
```

# Running Tests
--TODO--

