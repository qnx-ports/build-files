# Compile the port for QNX

**NOTE**: QNX ports are only supported from a Linux host operating system

Don't forget the source qnxsdp-env.sh in your QNX SDP.

```bash
# Clone the repos
git clone https://gitlab.com/qnx/libs/qnx-ports.git
git clone https://gitlab.com/qnx/libs/googletest.git

# Build
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/googletest" make -C qnx-ports/googletest install
```
