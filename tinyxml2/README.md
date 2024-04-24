# Compile the port for QNX

**NOTE**: QNX ports are only supported from a Linux host operating system

Don't forget the source qnxsdp-env.sh in your QNX SDP.

```bash
# Clone the repos
git clone https://gitlab.com/qnx/libs/qnx-ports.git
git clone https://gitlab.com/qnx/libs/tinyxml2.git

# Build
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/tinyxml2" make -C qnx-ports/tinyxml2 install
```
