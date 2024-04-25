# Compile the port for QNX

**NOTE**: QNX ports are only supported from a Linux host operating system

Don't forget the source qnxsdp-env.sh in your QNX SDP.

```bash
# Clone the repos
git clone https://gitlab.com/qnx/libs/qnx-ports.git
git clone https://gitlab.com/qnx/libs/tinyxml2.git

# Build
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/tinyxml2" make -C qnx-ports/tinyxml2 install -j$(nproc)
```

# How to run tests

scp libraries and tests to the target.
```bash
scp -r $QNX_TARGET/aarch64le/usr/local/bin/tinyxml2_tests root@<target-ip-address>:/
scp $QNX_TARGET/aarch64le/usr/local/lib/libtiny* root@<target-ip-address>:/usr/lib
```

Run tests on the target.
```bash
# ssh into the target
ssh root@<target-ip-address>

# Run xmltest
cd /tinyxml2_tests
./xmltest
```
