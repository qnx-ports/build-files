# Pre-requisite

* Install Docker on Ubuntu - OPTIONAL
  - https://docs.docker.com/engine/install/ubuntu/
* Install venv - recomended by conan documentation - OPTIONAL
  - https://docs.python.org/3/library/venv.html
* Install Conan2
  - https://docs.conan.io/2/installation.html

# Create a workspace

```bash
# Clone conan recipes
mkdir -p ~/zenohd_workspace && cd ~/zenohd_workspace
git clone https://github.com/qnx-ports/build-files.git
```

# Setup a Docker container - OPTIONAL
```bash
# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container
```

# Setup conan env
```bash
# Setup conan root folder
export CONAN_ROOT=$(realpath ~/zenohd_workspace/build-files/conan)
```

# Install release Zenoh router into conan cache
```bash
#
# <version-number>: 1.2.1
#
conan create --version=1.2.1 $CONAN_ROOT/recipes/zenoh-router/binary
```

# Deploy Zenoh router
```bash
cd ~/zenohd_workspace

mkdir stage_zenohd

export ZENOHD_STAGE=$(realpath ~/zenohd_workspace/stage_zenohd)

# Copy zenohd to stage folder
#
# <version-number>: 1.2.1
#
conan install --requires=zenoh-router/1.2.1 -d=direct_deploy --deployer-folder=$ZENOHD_STAGE
```

# Start Zenoh Router

## Find the proper network segment
```bash
# check available network segmets on Host
ifconfig | grep inet
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        inet 10.162.104.57  netmask 255.255.255.0  broadcast 10.162.104.255
        inet6 fe80::d89d:ef6:d72:f33f  prefixlen 64  scopeid 0x20<link>
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        inet 192.168.122.1  netmask 255.255.255.0  broadcast 192.168.122.255

# check available network segmets on Target
ssh qnxuser@<target_ip>

ifconfig | grep inet
        inet 127.0.0.1 netmask 0xff000000
        inet6 ::1 prefixlen 128
        inet6 fe80::1%lo0 prefixlen 64 scopeid 0x2
        inet6 fe80::5054:ff:fe8c:6633%vtnet0 prefixlen 64 scopeid 0x5
        inet 192.168.122.32 netmask 0xffffff00 broadcast 192.168.122.255
```
According to information we have the same network segment is on **192.168.122.xxx**

## Run Zenoh Router with proper network segment
```bash
# on Host run Zenoh Router
$ZENOHD_STAGE/direct_deploy/zenoh-router/zenohd -l "tcp/192.168.122.1:7447"
```
