# Compile the port for QNX

**NOTE**: QNX ports are only supported from a Linux host operating system

Don't forget the source qnxsdp-env.sh in your QNX SDP.

```bash
# Clone the repos
git clone https://gitlab.com/qnx/libs/qnx-ports.git
git clone https://gitlab.com/qnx/libs/opencv.git

# Build
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/opencv" make -C qnx-ports/opencv install -j$(nproc)
```

# How to run tests

scp libraries and tests to the target.
```bash
scp -r $QNX_TARGET/aarch64le/usr/local/bin/opencv_tests root@<target-ip-address>:/
scp $QNX_TARGET/aarch64le/usr/local/lib/libg* root@<target-ip-address>:/usr/lib
```

Run tests on the target.
```bash
# ssh into the target
ssh root@<target-ip-address>

# Run unit tests
cd /opencv_tests
chmod +x *
./gmock-actions_test
```
