# pixman [![Build](https://github.com/qnx-ports/build-files/actions/workflows/pixman.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/pixman.yml)

Current these versions are tested:
+ 0.43.4

# Compile pixman on a Linux host
To build, first enable your SDP, and then copy and edit qnx cross compile config found in `/resouces/meson` to reflect your SDP location, target CPU arch, etc.

Then, run:

```bash
# Using the official pixman repository
git clone https://gitlab.freedesktop.org/pixman/pixman.git
cd pixman/
# Using a release, rather than master branch
git checkout pixman-0.43.4
# We use QNX SDP 8.0.0 as an example here. 7.1.0 should work as well.
# openmp is disabled since SDP doesn't fully support it yet
meson setup build-qnx800 --cross-file ../qnx800.ini -Dprefix=/usr -Dopenmp=disabled
# Compile it
meson compile -C build-qnx800
# For installing into your SDP to be used as a dependency
DESTDIR=/path/to/qnx800/target/qnx meson install --no-rebuild -C build-qnx800
# For installing to image, or a clean folder to be transferred to test platform
DESTDIR=/path/to/output meson install --no-rebuild -C build-qnx800
```
