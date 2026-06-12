# sscep [![Build](https://github.com/qnx-ports/build-files/actions/workflows/sscep.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/sscep.yml)

**Note**: QNX ports are only supported from a **Linux host** operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

To install the library files at a specific location (e.g. `/tmp/staging`) use options `INSTALL_ROOT_nto=<staging-install-folder>` and `USE_INSTALL_ROOT=true` with the build command.

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
cd ~/qnx_workspace
source ~/qnx800/qnxsdp-env.sh

# Clone sscep
git clone https://github.com/qnx-ports/sscep.git

# Optional: if custom openssl version required
git clone --recurse-submodules -b qnx-openssl-3.5.4 https://github.com/qnx-ports/openssl-companion.git
mkdir -p install_ssl
make -C openssl-companion/build/Make install JLEVEL=4 INSTALL_ROOT_nto=$(pwd)/install_ssl USE_INSTALL_ROOT=true

# Build sscep
make -C build-files/ports/sscep install JLEVEL=4 [default SSL path is $(pwd)/install_ssl; USE_IOSOCK=true to enable io-sock; USE_CUSTOM_SSL=true for custom OpenSSL]
```

# Compile the port for QNX on Ubuntu Host

```bash
# Clone the repositories
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/sscep.git

# Optional: if custom openssl version required
git clone --recurse-submodules -b qnx-openssl-3.5.4 https://github.com/qnx-ports/openssl-companion.git
mkdir -p install_ssl
make -C openssl-companion/build/Make install JLEVEL=4 INSTALL_ROOT_nto=$(pwd)/install_ssl USE_INSTALL_ROOT=true

# Build sscep
make -C build-files/ports/sscep install JLEVEL=4 [default SSL path is $(pwd)/install_ssl; USE_IOSOCK=true to enable io-sock; USE_CUSTOM_SSL=true for custom OpenSSL]
```

# How to run application

sscep is a client side application. The repository does not have any tests. specific sscep operations can be tested by either hitting a public SCEP server or setting up a local SCEP server and querying it.

## step-ca SCEP Server Setup

This is to be setup on non-QNX host machine

### 1. Install step-ca and step CLI

Install from the official GitHub tag release.

### 2. Initialize step-ca

```bash
step ca init \
  --name "Test SCEP CA" \
  --dns "192.168.122.1" \
  --address "0.0.0.0:9000" \
  --provisioner "person1@test.com"
```

### 3. Replace Root CA with RSA

```bash
step certificate create "Test SCEP CA Root" \
  $(step path)/certs/root_ca.crt \
  $(step path)/secrets/root_ca_key \
  --kty RSA \
  --size 2048 \
  --not-after 87660h \
  --profile root-ca \
  --force
```

### 4. Replace Intermediate CA with RSA

```bash
step certificate create "Test SCEP CA Intermediate" \
  $(step path)/certs/intermediate_ca.crt \
  $(step path)/secrets/intermediate_ca_key \
  --kty RSA \
  --size 2048 \
  --not-after 43800h \
  --profile intermediate-ca \
  --ca $(step path)/certs/root_ca.crt \
  --ca-key $(step path)/secrets/root_ca_key \
  --force
```

### 5. Add SCEP Provisioner

```bash
step ca provisioner add my_scep \
  --type SCEP \
  --encryption-algorithm-identifier 2
```

### 6. Edit ca.json

Edit `$(step path)/config/ca.json` and add the `insecureAddress` field:

```json
{
  "insecureAddress": "0.0.0.0:8080"
}
```

### 7. Start step-ca

```bash
step-ca $(step path)/config/ca.json
```

## Setup QNX QEMU and test

```bash
TARGET_HOST=<target-ip-address-or-hostname>

# On cross-compile host
scp $QNX_TARGET/x86_64/usr/local/bin/sscep qnxuser@$TARGET_HOST:~/

# On QNX QEMU
export PATH=$PATH:$(pwd)
export SCEP_URL=http://192.168.122.1:8080/scep/my_scep

# getca functionality
sscep getca -u $SCEP_URL -c ca.crt -F sha256 -d

# getcaps functionality
sscep getcaps -u $SCEP_URL -d

# enroll functionality
openssl genrsa -out client.key 204
openssl req -new -key client.key -out client.csr -subj "/CN=qnx-device/O=TestOrg/C=US"
sscep enroll -u $SCEP_URL -c ca.crt -k client.key -r client.csr -l client.crt -E aes256 -S sha256 -d
```

Note: step-ca SCEP server does not support querying `getcrl`, `getcert` and `getnextca` functionality (as seen in their [codebase](https://github.com/smallstep/certificates))
