**WARNING**: tftp is NOT a secure protocol. Use only on local/trusted network!

Currently tested version and SDP combos:
+ 5.2 on QNX 8.0/7.1

# Building tftp-hpa
We will need two patches to make it work:
+ fix-build-gcc-10.patch: fix build on gcc 10+
+ qnx-sa-restart.patch: QNX doesn't have `SA_RESTART`, so we just define it to 0

```bash
# As of writing, the latest version is 5.2
export PKGVER="5.2"
# Specify your build target. This example targets QNX 8.0.0 on aarch64
# For QNX x86_64, replace `aarch64` with `x86_64`
# For QNX 7.1.0, replace `qnx8.0.0` with `qnx7.1.0
export TARGET=aarch64-unknown-nto-qnx8.0.0
# Specify which target is building for. Here we are doing it for QNX8 for aarch64
# Fetch source tarball and unarchive it
curl -O https://www.kernel.org/pub/software/network/tftp/tftp-hpa/tftp-hpa-$PKGVER.tar.gz
tar xf tftp-hpa-$PKGVER.tar.gz
cd tftp-hpa-$PKGVER
# Apply patches
patch -p1 < ../fix-build-gcc-10.patch
patch -p1 < ../qnx-sa-restart.patch
# Genrate build script
./configure \
    --build=x86_64-unknown-linux-gnu \
    --host=$TARGET \
    --prefix=/usr \
    --mandir=/usr/share/man
# Actual compiling
make
# Install result to a temporary folder for transfer to QNX
make INSTALLROOT=$OUTPUT_DIR install
```

# Testing client & server
```sh
# Running tftp server on QNX
# -L: run in foreground, rather than waken up by inetd
# -a: bind on all network interfaces (0.0.0.0)
# -c: allow file creations (if not specified, only overwrite existing files)
# -u: specify user (root, QNX may not have nobody user, which will crash the server)
in.tftpd -L -a 0.0.0.0 -c -u root

# Using the client
tftp
(input QNX IP)
put LOCAL REMOTE
get REMOTE LOCAL
```
