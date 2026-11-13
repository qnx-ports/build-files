# net-snmp [![Build](https://github.com/qnx-ports/build-files/actions/workflows/net-snmp.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/net-snmp.yml)

Supports QNX 8.0 (aarch64le, x86_64). Built from upstream [net-snmp/net-snmp](https://github.com/net-snmp/net-snmp) `v5.9.5.2` (latest stable release; 5.10 is at release candidate 1) with no source patches. It builds the library, the command-line tools (`snmpget`, `snmpwalk`, `snmpset`, `snmpbulkwalk`, `snmptrap`, `snmpusm`, ...) and the trap receiver `snmptrapd`. SNMPv3 security uses the SDP's OpenSSL 3: USM with HMAC-SHA-1/224/256/384/512 authentication and AES-128 privacy (tested on the target: HMAC-SHA-256 with AES-128).

**NOTE**: QNX ports are only supported from a Linux host operating system.

Use `$(nproc)` instead of `4` after `JLEVEL=` if you want to use all cores.

## What the recipe sets, and why

| Setting | Why |
| --- | --- |
| `LDFLAGS += -lregex` | `regcomp()` is in `libregex` on QNX. `configure` finds it and adds it to `LIBS`, but not to the libraries' own link line, and `libnetsnmp` is linked with `-no-undefined`, so the link fails without it. Reported for QNX 7.1 in [net-snmp#937](https://github.com/net-snmp/net-snmp/issues/937); fixed in configure by [net-snmp#1176](https://github.com/net-snmp/net-snmp/pull/1176) (open). |
| `--disable-agent --without-kmem-usage` | The agent (`snmpd`) is left out: several of its default MIB modules use BSD kernel interfaces QNX does not have (e.g. `hz` in `mibII/tcp.c`). `--without-kmem-usage` because QNX 8.0 has `kvm_openfiles()`/`kvm_read()` in `libsocket` but no `libkvm` and no `kvm_open()`; configure looks only in `libkvm`, so `agent/kernel.c` (linked into `snmptrapd`) falls back to `kvm_open()`. With [net-snmp#1176](https://github.com/net-snmp/net-snmp/pull/1176) master needs neither `-lregex` nor this option. |
| `--prefix=/usr/local` at configure, `DESTDIR` at install | net-snmp compiles its MIB, configuration and persistent-state paths into the library. Configuring with the target paths keeps them right on the target. `make install` writes to `build/stage` with `DESTDIR`, and the recipe copies headers and MIBs to `$QNX_TARGET/usr/local` and programs and libraries to `$QNX_TARGET/<cpu>/usr/local`, so libtool's install-time relink keeps `RPATH` at `/usr/local/lib`. The install step runs without `-j`: in parallel, `snmptrapd` can be linked while libtool is relinking `libnetsnmptrapd`. |
| `--with-persistent-directory=/data/var/net-snmp` | QNX images keep `/var` read-only or small; the tools keep engine boots and keys made by `snmpusm` there. Change with `PERSISTENT_DIR=`. |
| `-ffile-prefix-map` | Source file names in assertion messages without the build host's folders. |

## Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container
source ~/qnx800/qnxsdp-env.sh

# Clone net-snmp
cd ~/qnx_workspace
git clone --depth 1 --branch v5.9.5.2 https://github.com/net-snmp/net-snmp.git

# Build and install net-snmp
QNX_PROJECT_ROOT="$(pwd)/net-snmp" JLEVEL=4 make -C build-files/ports/net-snmp install
```

## Compile the port for QNX on Ubuntu host
```bash
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone --depth 1 --branch v5.9.5.2 https://github.com/net-snmp/net-snmp.git

source ~/qnx800/qnxsdp-env.sh

QNX_PROJECT_ROOT="$(pwd)/net-snmp" JLEVEL=4 make -C build-files/ports/net-snmp install
```

To build only one architecture, run make in its folder, e.g. `make -C build-files/ports/net-snmp/nto-aarch64-le install`.

Installed files:

| What | Where |
| --- | --- |
| Headers | `$QNX_TARGET/usr/local/include/net-snmp/` |
| Libraries | `$QNX_TARGET/<cpu>/usr/local/lib/libnetsnmp*.so*` |
| Tools | `$QNX_TARGET/<cpu>/usr/local/bin/snmp*`, `$QNX_TARGET/<cpu>/usr/local/sbin/snmptrapd` |
| MIB files | `$QNX_TARGET/usr/local/share/snmp/mibs/` (copy to `/usr/local/share/snmp/mibs` on the target for names instead of numbers) |
| pkg-config | `$QNX_TARGET/<cpu>/usr/local/lib/pkgconfig/netsnmp.pc` |

## Deploy binaries via SSH
```bash
TARGET_HOST=<target-ip-address-or-hostname>

ssh qnxuser@$TARGET_HOST "mkdir -p ~/lib ~/bin"
scp $QNX_TARGET/aarch64le/usr/local/lib/libnetsnmp.so* qnxuser@$TARGET_HOST:~/lib
scp $QNX_TARGET/aarch64le/usr/local/bin/snmpget $QNX_TARGET/aarch64le/usr/local/bin/snmpwalk qnxuser@$TARGET_HOST:~/bin
```

On the target, keep the passphrases off the command line (other users can see command lines) in a private
`snmp.conf`, and without MIB files ask for numeric output:
```bash
umask 077 && mkdir -p ~/snmpconf && cat > ~/snmpconf/snmp.conf    # type these lines, then Ctrl-D:
defSecurityName <user>
defSecurityLevel authPriv
defAuthType SHA-256
defAuthPassphrase <auth pass>
defPrivType AES
defPrivPassphrase <priv pass>

SNMPCONFPATH=~/snmpconf SNMP_PERSISTENT_DIR=~/snmpconf LD_LIBRARY_PATH=~/lib MIBS= ~/bin/snmpwalk -v3 -On <agent> 1.3.6.1.2.1.1
```

## Tested

On a Raspberry Pi 4 with QNX 8.0 (aarch64le), against an independent SNMPv3 agent (pysnmp 7.1.32 on Linux, UPS-MIB of RFC 1628):

| Test | Result |
| --- | --- |
| `snmpwalk`, `snmpget` with authPriv (HMAC-SHA-256, AES-128) | all objects read, engine id discovered |
| `snmpset` of a writable INTEGER | written and read back |
| `snmpset` outside the object's range, and of a read-only object | `wrongValue`, `notWritable` as expected |
| A program linking `libnetsnmp` (single-session API, synchronous GET and SET, keys from passphrases with `generate_Ku`) | polls 9 objects every 5 to 30 s; recovers after the agent restarts |
