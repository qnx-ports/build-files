# glib [![Build](https://github.com/qnx-ports/build-files/actions/workflows/glib.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/glib.yml)

**NOTE**: currently only aarch64le is supported.

Current these versions are tested:
+ `glib/main` (Recommanded)
+ `qnx-ports/qnx-2.82.0`

See test reports in `tests/`.

## GTK compatibility
If you decide to use GTK on QNX, you should consider installing glib from [GTK repo](https://github.com/qnx-ports/build-files/tree/main/ports/gtk) rather than saprately form here. This glib port is not throughly tested with GTK and unepxected behaviours might occur.

## Compile Glib for SDP 7.1/8.0 on a Linux host
You'll need the patched version of glib for QNX, available at https://github.com/qnx-ports/glib . For QNX 7.0.0 use the `qnx700-$VER` branch. For QNX 7.1.0 and 8.0.0, simply use `qnx-$VER` branch.

If you decide to compile from the `glib/main`, you will also need to apply patch to `meson.build`. `glib/main` provides some additional file system mounting features offer by `gio` compared to `qnx-ports/qnx-2.82.0`

To build, first enable your SDP, and then use the cross compile config file available inside this repo under `/resources/meson`, then use meson setup to generate build script, meson compile to do the actual compiling, and finally meson install to install it to your SDP (as dependency for other project or development), or an empty folder so you can transfer it to an actual QNX system.

Here's a detailed instruction:

``` bash
# Define some variables we will use later
export QNX_VERSION=800
export QNX_ARCH=aarch64le
# Assuming your build-files repo is at ~/workspace/build-files
cd ~/workspace
# Using QNX's fork of glib
git clone https://github.com/qnx-ports/glib.git
# Or using gib/main
git clone https://gitlab.gnome.org/GNOME/glib.git

# Navigate into ./glib
cd glib/
# patch meson.build if using glib/main
git apply --whitespace=nowarn ../build-files/ports/glib/001-meson-build.patch

# Generate build script
meson setup build-qnx$QNX_VERSION --cross-file ~/workspace/build-files/resources/$QNX_ARCH/qnx$QNX_VERSION.ini -Dprefix=/usr -Dxattr=false
meson compile -C build-qnx$QNX_VERSION
# For installing into your SDP to be used as a dependency
DESTDIR=/sdp/800/target/qnx meson install --no-rebuild -C build-qnx$QNX_VERSION
# For installing to image, or a clean folder to be transferred to test platform
DESTDIR=/path/to/output meson install --no-rebuild -C build-qnx$QNX_VERSION
```

And build products will be available in `$TARGET_DIR`

## Compile Glib for SDP 7.0
For QNX 7.0, the general steps are the same but you'll need a special branch. Also by default images of QNX 7.0 uses `/system` as `/usr`, so there are some slight changes.

```bash
# Define some variables we will use later
export QNX_VERSION=700
export QNX_ARCH=aarch64le
# Assuming your build-files repo is at ~/workspace/build-files, we will be cloning glib parallel to it
cd ~/workspace
# Using QNX's fork of glib
git clone https://github.com/qnx-ports/glib.git

# Navigate into ./glib
cd glib/

# For QNX 7.0.0, use a special branch for it
git checkout qnx700-2.82.2
# Generate build script. Notice the prefix here is /system
meson setup build-qnx$QNX_VERSION --cross-file ~/workspace/build-files/resources/$QNX_ARCH/qnx$QNX_VERSION.ini -Dprefix=/system -Dxattr=false
meson compile -C build-qnx$QNX_VERSION
# For installing into your SDP to be used as a dependency
DESTDIR=/sdp/700/target/qnx meson install --no-rebuild -C build-qnx$QNX_VERSION
# For installing to image, or a clean folder to be transferred to test platform
DESTDIR=/path/to/output meson install --no-rebuild -C build-qnx$QNX_VERSION
```
