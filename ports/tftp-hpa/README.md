# tftp [![Build](https://github.com/qnx-ports/build-files/actions/workflows/tftp-hpa.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/tftp-hpa.yml)

**WARNING**: tftp is NOT a secure protocol. Use only on local/trusted network!

Currently tested version and SDP combos:
+ 5.2 on QNX 8.0/7.1

# Building tftp-hpa

```bash
# Specify your build target. This example targets QNX 8.0.0 on aarch64
# For QNX x86_64, replace `aarch64` with `x86_64`
# For QNX 7.1.0, replace `qnx8.0.0` with `qnx7.1.0
export TARGET=aarch64-unknown-nto-qnx8.0.0

# Clone tftp-hpa
git clone https://github.com/qnx-ports/tftp-hpa.git

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
