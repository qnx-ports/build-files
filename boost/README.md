# Compile the port for QNX

**NOTE**: QNX ports are only supported from a Linux host operating system

Don't forget the source qnxsdp-env.sh in your QNX SDP.

```bash
# Clone the qnx-ports and boost repos
git clone https://gitlab.com/qnx/libs/qnx-ports.git
git clone https://gitlab.com/qnx/libs/boost.git

cd boost
git submodule update --init --recursive
cd tools/build && git apply ../../../qnx-ports/boost/tools_qnx.patch && cd -
cd ../

# Build
make -C qnx-ports/boost/ install QNX_PROJECT_ROOT="$(pwd)/boost" -j$(nproc)

./qnx-ports/boost/build_and_install_tests.sh
```

Currently, when numpy is installed on your host system, the build fails:

```console
/usr/local/lib/python3.8/dist-packages/numpy/core/include/numpy/npy_endian.h:13:14: fatal error: endian.h: No such file or directory
   13 |     #include <endian.h>
```

The workaround is to run `sudo pip3 uninstall numpy` or `pip3 uninstall numpy` to uninstall numpy
