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


**Testing**:
for validating the amqp-cpp we need to build libev and libuv and use the prebuild binaries from examples folder. 

```bash
# Update package list
sudo apt-get update

# Install RabbitMQ (includes Erlang dependencies automatically)
sudo apt-get install -y rabbitmq-server

# Start the service
sudo systemctl start rabbitmq-server

# Enable on boot
sudo systemctl enable rabbitmq-server

# Verify it's running
sudo systemctl status rabbitmq-server

# Enable management plugin
sudo rabbitmq-plugins enable rabbitmq_management

# Restart to apply plugin
sudo systemctl restart rabbitmq-server

# Verify listening ports
sudo netstat -tulpn | grep beam

##Create User and Configure
# Create user
sudo rabbitmqctl add_user myuser mypassword

# Set permissions
sudo rabbitmqctl set_permissions -p / myuser ".*" ".*" ".*"

# Verify
sudo rabbitmqctl list_users
sudo rabbitmqctl list_permissions -p /

# Get your Ubuntu IP
hostname -I

##Verify Installation
# Check if RabbitMQ is running
sudo systemctl status rabbitmq-server

# Check listening ports (should show 5672 and 15672)
sudo ss -tulpn | grep beam

# Test local connection
telnet localhost 5672

#Expected output should show:
LISTEN  0  128  0.0.0.0:5672  0.0.0.0:*  (AMQP)
LISTEN  0  128  0.0.0.0:15672 0.0.0.0:*  (Management)

##Once Working, Test from RPi
# From QNX RPi target
ping <ubuntu-ip>
nc -vz <ubuntu-ip> 5672
telnet <ubuntu-ip> 5672

# Then run your AMQP-CPP example with:
# AMQP::Address address("amqp://myuser:mypassword@<ubuntu-ip>/");
# above line need to be updated on examples/libev.cpp or examples/libuv.cpp

```