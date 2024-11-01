**NOTE**: currently only aarch64le is supported.

Current these versions are tested:
+ 2.82.0

## Compile Glib on a Linux host
You'll need the patched version of glib for QNX, available at https://github.com/qnx-ports/glib . For QNX 7.0.0 use the `qnx700-$VER` branch. For QNX 7.1.0 and 8.0.0, simply use `qnx-$VER` branch.

To build, first enable your SDP, and then copy and edit `qnx$QNXVER.ini` to `qnx_cross.ini` to reflect your SDP location, CPU arch, etc. You can find a template for such file in `resources/meson` in this repo.

Then, run:

``` bash
# Using QNX's fork of glib
https://github.com/qnx-ports/glib.git
cd glib/
# For QNX 7.1.0+, use the generic branch
git checkout qnx-2.82.2
# For QNX 7.0.0, use a special branch instead:
git checkout qnx700-2.82.2
# For QNX 8.0.0
meson setup build-qnx800 --cross-file qnx_cross.ini -Dprefix=/usr -Dxattr=false
meson compile -C build-qnx800
# For installing into your SDP to be used as a dependency
DESTDIR=/sdp/800/target/qnx meson install --no-rebuild -C build-qnx800
# For installing to image, or a clean folder to be transferred to test platform
DESTDIR=/path/to/output meson install --no-rebuild -C build-qnx800
```

And build products will be available in `$TARGET_DIR`
