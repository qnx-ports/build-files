Current these versions are tested:
+ 1.18.0

# Compile pixman on a Linux host
## Prepare dependencies
We will need the font engine package from software center. We will also need to add the missing pkg-config files so that meson can actually find them, without manually hack the build script. Copy everything from `resources/pkgconfig/$SDP_VERSION/$ARCH` to your QNX_TARGET's `usr/lib/pkgconfig` folder.

We will also need these from this repository:
+ pixman
+ glib

Build them and install them into the SDP target.

**Note**: you might want a copy of the target since this will install arch-dependent files to the root of the target folder (since meson don't use the multiarch file hierarchy as SDP) and might cause trouble down the line.

## Build it!
```bash
git clone https://gitlab.freedesktop.org/cairo/cairo.git
cd cairo/
git checkout 1.18.0
# We use QNX SDP 8.0.0 as an example here. 7.1.0 should work as well.
# tests are disabled for now
meson setup build-qnx800 --cross-file ../qnx800.ini -Dprefix=/usr -Dtests=disabled
meson compile -C build-qnx800
# For installing into your SDP to be used as a dependency
DESTDIR=/path/to/qnx800/target/qnx meson install --no-rebuild -C build-qnx800
# For installing to image, or a clean folder to be transferred to test platform
DESTDIR=/path/to/output meson install --no-rebuild -C build-qnx800
```
