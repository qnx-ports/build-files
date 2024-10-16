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

You'll need to add some missing pkg-config files to the SDP, so meson can find dependencies. See `/resouces` in this repository.

Then, run:

``` bash
# For QNX 8.0.0
meson setup build-qnx800 --cross-file qnx_cross.ini -Dprefix=/usr -Dxattr=false
meson compile -C build-qnx800
# For installing into your SDP to be used as a dependency
DESTDIR=/sdp/800/target/qnx meson install --no-rebuild -C build-qnx800
# For installing to image, or a clean folder to be transferred to test platform
DESTDIR=/path/to/output meson install --no-rebuild -C build-qnx800
```

And build products will be available in `$TARGET_DIR`
