Compile the port for QNX

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

**Dependencies** :
# Clone libev
git clone https://github.com/qnx-ports/libev.git

# Build libev
make -C build-files/ports/libev install

# Clone libuv
git clone https://github.com/qnx-ports/libuv.git

# Build libuv
make -C build-files/ports/libuv install -j4

# Clone amqp-cpp
git clone https://github.com/qnx-ports/AMQP-CPP.git
cd AMQP-CPP
git checkout qnx-v4.3.27
cd ..

# Build amqp-cpp
QNX_PROJECT_ROOT="$(pwd)/AMQP-CPP" make -C build-files/ports/amqp-cpp/  install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

**Dependencies** :
# Clone libev
git clone https://github.com/qnx-ports/libev.git

# Build libev
make -C build-files/ports/libev install

# Clone libuv
git clone https://github.com/qnx-ports/libuv.git

# Build libuv
make -C build-files/ports/libuv install -j4

# Clone amqp-cpp
git clone https://github.com/qnx-ports/AMQP-CPP.git
cd AMQP-CPP
git checkout qnx-v4.3.27
cd ..

# Build amqp-cpp
QNX_PROJECT_ROOT="$(pwd)/AMQP-CPP" make -C build-files/ports/amqp-cpp/  install -j4

```

# AMQP-CPP Validation Guide

## Overview

This guide provides step-by-step instructions to validate the AMQP-CPP library on QNX using the pre-built example binaries (`amqpcpp_libev_example` and `amqpcpp_libuv_example`).

---

## Prerequisites

- **Ubuntu Machine (RabbitMQ Server)**: Ubuntu 22.04 (Jammy) or later
- **QNX Target (RPi)**: QNX 7.x or 8.x with aarch64 architecture
- **Network Connection**: Both machines must be able to communicate on the same network
- **Built AMQP-CPP**: Successfully compiled with libev and libuv examples

---

## Part 1: RabbitMQ Server Setup (Ubuntu Machine)

### 1.1 Install RabbitMQ Server

```bash
# Update package list
sudo apt-get update

# Install RabbitMQ (includes Erlang dependencies automatically)
sudo apt-get install -y rabbitmq-server
```

### 1.2 Start and Enable RabbitMQ Service

```bash
# Start the service
sudo systemctl start rabbitmq-server

# Enable on boot
sudo systemctl enable rabbitmq-server

# Verify it's running
sudo systemctl status rabbitmq-server
```

### 1.3 Enable Management Plugin (Optional but Recommended)

```bash
# Enable management plugin for web UI
sudo rabbitmq-plugins enable rabbitmq_management

# Restart to apply changes
sudo systemctl restart rabbitmq-server
```

### 1.4 Create User and Configure Permissions

```bash
# Create custom user with password
sudo rabbitmqctl add_user myuser mypassword

# Set permissions (full access to "/" virtual host)
sudo rabbitmqctl set_permissions -p / myuser ".*" ".*" ".*"

# Verify user and permissions
sudo rabbitmqctl list_users
sudo rabbitmqctl list_permissions -p /
```

**Expected output:**
```
Listing users ...
guest	[administrator]
myuser	[]

Listing permissions for vhost "/" ...
user	configure	write	read
guest	.*	.*	.*
myuser	.*	.*	.*
```

### 1.5 Verify RabbitMQ is Listening

```bash
# Check listening ports (should show 5672 for AMQP and 15672 for management)
sudo ss -tulpn | grep beam

# Alternative command
sudo netstat -tulpn | grep beam
```

**Expected output:**
```
LISTEN  0  128  0.0.0.0:5672  0.0.0.0:*  (AMQP Protocol Port)
LISTEN  0  128  0.0.0.0:15672 0.0.0.0:*  (Management UI Port)
```

### 1.6 Test Local Connection

```bash
# Test AMQP port locally
telnet localhost 5672

# Or test both ports
nc -vz localhost 5672
nc -vz localhost 15672
```

### 1.7 Find Your Ubuntu Machine's IP Address

```bash
# Get IP address
hostname -I

# NOTE: Replace <UBUNTU_IP> below with this IP address.
```

**Note:** Save this IP address for use on the QNX target.

## Part 2: QNX Target Setup and Testing

### 2.1 Update Example Code with RabbitMQ Server Address

Edit the example source file to point to your RabbitMQ server.

**For libev example** (`examples/libev.cpp`):

```cpp
// Find this line in the example:
AMQP::Address address("amqp://guest:guest@localhost/");

// Replace with your RabbitMQ server details:
AMQP::Address address("amqp://myuser:mypassword@<UBUNTU_IP>/");
```

**For libuv example** (`examples/libuv.cpp`):

```cpp
// Same change as above
AMQP::Address address("amqp://myuser:mypassword@<UBUNTU_IP>/");
```

**Then rebuild:**

```bash
cd ~/path/to/amqp-cpp/build-files/ports/amqp-cpp
QNX_PROJECT_ROOT="$(pwd)/AMQP-CPP" make install
```

### 2.2 Copy Example Binaries to Target

From your build machine:

```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Copy libev example (recommended)
scp nto-aarch64-le/build/examples/amqpcpp_libev_example qnxuser@$TARGET_HOST:~/

# Copy libuv example (optional)
scp nto-aarch64-le/build/examples/amqpcpp_libuv_example qnxuser@$TARGET_HOST:~/

# Copy the AMQP-CPP shared library
scp nto-aarch64-le/build/bin/libamqpcpp.so.4.3 qnxuser@$TARGET_HOST:~/
```

### 2.3 Connect to QNX Target

```bash
# SSH into your QNX RPi target
ssh qnxuser@<TARGET_HOST>

# Or use direct connection if available
```

### 2.4 Verify Network Connectivity (On QNX Target)

```bash
# Test connectivity to Ubuntu RabbitMQ server
ping <UBUNTU_IP>

# Test AMQP port connectivity
nc -vz <UBUNTU_IP> 5672

# Or use telnet if nc is not available
telnet <UBUNTU_IP> 5672
```

**Expected output:** Connection should succeed without timeout.

### 2.5 Set Library Path (If Needed)

If libraries are not in standard paths:

```bash
# On QNX target
export LD_LIBRARY_PATH=~/lib:$LD_LIBRARY_PATH

# Or if you copied libamqpcpp.so.4.3 to current directory
export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
```
---

## Part 3: Run Validation Tests

### 3.1 Run Libev Example (Recommended)

On QNX target:

```bash
cd ~
./amqpcpp_libev_example
```

**Expected output:**
```
connected
ready
declared queue amq.gen-xxxxxxxxxxxxxxxxxxxxxx
started consuming with tag amq.ctag-xxxxxxxxxxxxxxxxxx
received 1
received 2
received 3
received 4
consumer amq.ctag-xxxxxxxxxxxxxxxxxx was cancelled
```

### 3.2 Run Libuv Example

On QNX target:

```bash
cd ~
./amqpcpp_libuv_example
```

**Expected output (similar to libev):**
```
connected
declared queue amq.gen-xxxxxxxxxxxxxxxxxxxxxx
```
