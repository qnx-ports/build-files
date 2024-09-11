**NOTE**: currently only aarch64le is supported.

## Compile Glib in a Docker container
```bash
git clone https://github.com/qnx-ports/build-files.git

# Prepare container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
cd ~/qnx_workspace

# Clone glib
git clone https://github.com/qnx-ports/glib.git

# Clone meson for building gtk
git clone https://github.com/mesonbuild/meson && cd meson
git checkout 110642dd7
cd -

# Build glib and install it to your SDP
make install -C build-files/ports/glib QNX_PROJECT_ROOT="$(pwd)/glib"
```

## Compile Glib on a Linux host
To build, first enable your SDP, and then copy and edit `qnx_cross.cfg.in` to `qnx_cross.ini` to reflect your SDP location, CPU arch, etc.

Then, run:

``` bash
# For QNX 8.0.0
meson setup --cross-file qnx_cross.ini build -Dprefix=$TARGET_DIR -Dxattr=false
cd build && ninja && ninja install
```

And build products will be available in `$TARGET_DIR`
