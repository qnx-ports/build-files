Currently these versions are tested:
+ 2.13.5

# Compiling libxml2 on a Linux host
Upstream version compiles without modification.

```bash
# Specify your build target. This example targets QNX 8.0.0 on aarch64
# For QNX 8.0.0 on x86_64, use `export TARGET=x86_64-pc-nto-qnx8.0.0` instead
export TARGET=aarch64-unknown-nto-qnx8.0.0
# Clone and checkout the latest release of libxml2
# As of writing, it's 2.13.5
git clone https://gitlab.gnome.org/GNOME/libxml2.git
cd libxml2/
git checkout v2.13.5
# Generate Makefile. To activate cross-compiling, we show autotools that build machine has different setup than the host machine
./configure \
    --build=x86_64-unknown-linux-gnu \
    --host=$TARGET \
    --prefix=/usr \
    --sysconfdir=/etc \
    --mandir=/usr/share/man \
    --infodir=/usr/share/info \
    --enable-static \
    --with-legacy \
    --with-lzma \
    --with-zlib \
    --with-python=no
# Actual compiliing
make
# Install compilation products to a folder for transfer to QNX fs
make DESTDIR=$OUTPUT_DIR install
```