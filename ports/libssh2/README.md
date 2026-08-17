# libssh2 [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libssh2.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libssh2.yml)

# Compile the port for QNX

**Note**: QNX ports are only supported from a **Linux host** operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/

```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# Source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone libssh2
git clone https://github.com/qnx-ports/libssh2.git
cd libssh2
git checkout qnx-libssh2-1.11.1
cd ..


# Build libssh2
QNX_PROJECT_ROOT="$(pwd)/libssh2" make -C build-files/ports/libssh2/  install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone libssh2
git clone https://github.com/qnx-ports/libssh2.git
cd libssh2
git checkout qnx-release-1.24.1
cd ..


# Build libssh2
QNX_PROJECT_ROOT="$(pwd)/libssh2" make -C build-files/ports/libssh2/  install -j4
```

# libssh2 1.11.1 - QNX Port Validation

After building libssh2 for your QNX target, validation uses the pre-compiled example programs. The build process compiles all examples in the CPU-specific directory (nto-<cpudir>). Deploy and run tests on your target device (RPi/x86 QNX machine).

## Prerequisites
1. Built libssh2 artifacts in `build-files/ports/libssh2/nto-<cpudir>/`
2. SSH server running on target (`sshd`)
3. User account with password authentication on target
4. Write permissions on target `/tmp`

## 1. Deploy to Target Device

```bash
TARGET_HOST=<target-ip-or-hostname>
TARGET_USER=qnxuser

#creating ~/guests directory on target
ssh qnxuser@$TARGET_HOST "mkdir -p ~/guests"

# Copy entire build directory to target
scp -r ./build-files/ports/libssh2/nto-x86_64-o qnxuser@$TARGET_HOST:~/guests/
```
## 2. SSH to Target and Setup Environment
```bash
ssh qnxuser@<TARGET_HOST>
cd ~/guests/nto-x86_64-o/build
```
## 3. Run Validation Tests
```bash
# Execute tree utill
./libssh2_test.sh
```
## 4. Expected Results
```text
===============================================================================
=== Library Verification ===
 Shared library found
 Static library found
Exported symbols: 294

=== SSH Core Tests ===
Testing: Basic Authentication
   PASS

Testing: Command Execution
   PASS

=== Data Transfer Tests ===
Testing: SSH Echo (1.5MB)
   PASS

Testing: SCP Download
   PASS

Testing: SCP Upload
   PASS

=== Non-blocking Tests ===
Testing: SCP Non-blocking Download
   PASS

Testing: SCP Non-blocking Upload
   PASS

=== SFTP Tests ===
Testing: Directory List
   PASS

Testing: Directory List (custom)
   PASS

Testing: Mkdir
   PASS

Testing: Non-blocking
   PASS

Testing: File Operations
   PASS

Testing: Append
   PASS

Testing: Write
   PASS

Testing: Write NB
   PASS

Testing: RW Non-blocking
   PASS

=== Stress Tests ===
10 sequential connections...

real    0m1.524s
user    0m0.284s
sys     0m0.000s
   PASS

==============================
Results: 16 passed, 0 failed
==============================
Log saved: /home/qnxuser/guests/nto-x86_64-o/build/validation_log.txt
```

### Note: 
Individual test/example logs are available at: /home/qnxuser/guests/nto-x86_64-o/build/validation_log.txt