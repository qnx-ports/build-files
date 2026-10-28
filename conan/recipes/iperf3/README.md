**NOTE**: QNX ports are only supported from a Linux host operating system


# Pre-requisite

* Install QNX license and SDP installation (~/.qnx and ~/qnx800 by default)
  - https://www.qnx.com/products/everywhere/ (**Non-Commercial Use**)
* Install Docker on Ubuntu - OPTIONAL
  - https://docs.docker.com/engine/install/ubuntu/
* Install venv - recomended by conan documentation - OPTIONAL
  - https://docs.python.org/3/library/venv.html
* Install Conan2
  - https://docs.conan.io/2/installation.html

# Create a workspace

```bash
# Clone conan recipes
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
```

# Setup a Docker container
```bash
# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container
```

# Or setup Ubuntu host
```bash
# Source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh
```

# Update conan setting for QNX8.0
```bash
# Setup conan root folder
export QNX_CONAN_ROOT=$(realpath ~/qnx_workspace/build-files/conan)

# Detect build profile
conan profile detect

# Update conan settings for QNX8.0 support
conan config install $QNX_CONAN_ROOT/tools/qnx-8.0-extension/settings_user.yml
```

# Build and install release iperf3 for QNX into conan cache
```bash
cd ~/qnx_workspace

#
# <profile-name>: nto-7.1-aarch64-gcc, nto-7.1-x86_64-gcc, nto-8.0-aarch64-gcc, nto-8.0-x86_64-gcc
# <version-number>: 3.7
#
# Usage [linux]:
#   conan create --version=<version-number> $QNX_CONAN_ROOT/recipes/iperf3/all
# Usage [QNX]:
#   conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> $QNX_CONAN_ROOT/recipes/iperf3/all
#
conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64-gcc --version=3.7 $QNX_CONAN_ROOT/recipes/iperf3/all
```

## Recipe options

| Option | Default | Description |
| --- | --- | --- |
| `with_tests` | `False` | Also package upstream's unit test programs (`t_timer`, `t_units`, `t_uuid`, `t_api`) under `usr/libexec/iperf3-tests/`. |

```bash
# Build with the unit tests packaged
conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64-gcc --version=3.7 -o 'iperf3/*:with_tests=True' $QNX_CONAN_ROOT/recipes/iperf3/all
```

# Deploy iperf3
```bash
cd ~/qnx_workspace

mkdir stage_iperf3

PATH_2_STAGE=$(realpath ~/qnx_workspace/stage_iperf3)

# deploy iperf3 to the stage folder
conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64-gcc \
    --requires=iperf3/3.7 \
    --deployer=direct_deploy \
    --deployer-folder=$PATH_2_STAGE

# copy iperf3 into SDP
cp -r $PATH_2_STAGE/direct_deploy/iperf3/usr/* $QNX_TARGET/x86_64/usr/
```

The deployed folder `direct_deploy/iperf3/` contains `usr/bin/iperf3` and `usr/lib/libiperf.so.0`.
`iperf3` is linked against `libiperf.so.0` without an RPATH: when running it on a target, copy both files to the
same directory and set `LD_LIBRARY_PATH` to that directory, or install the library into `/usr/lib`.

## Deploy with the unit tests

`with_tests` is part of the package identity: the command above always deploys the package built **without**
the option, even if a package built with `with_tests=True` is also in the conan cache. To deploy the unit tests,
pass the same option to `conan install` that was used for `conan create`:

```bash
conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64-gcc \
    -o 'iperf3/*:with_tests=True' \
    --requires=iperf3/3.7 \
    --deployer=direct_deploy \
    --deployer-folder=$PATH_2_STAGE
```

The deployed folder then also contains `usr/libexec/iperf3-tests/` with `t_timer`, `t_units`, `t_uuid` and `t_api`.
If the package with the option has not been built, `conan install` stops with "Missing prebuilt package".

# Run tests on the target.

Two scripts are provided in `recipes/iperf3/tests`. Both run on the target and need the `iperf3` binary (and
`libiperf.so.0`) in the directory they are started from.

Requirements on the target: a POSIX `sh` (bash/ksh) with the standard `sleep`, `kill` and `head` commands.  
`timeout` is used when the target has it; the scripts fall back to a shell watchdog otherwise.  
`python3` is optional and only used to validate the `-J` output.

* `iperf3_tests.sh [ipv4-host [ipv6-host]]` runs the 25 client commands of upstream's release checklist
  (`test_commands.sh`: basic, UDP, omit, JSON, IPv4/IPv6, parallel streams, reverse mode, zero copy, window size,
  `-n`/`-k` end conditions, CPU affinity, burst, MSS, congestion control) plus 6 variants (more JSON cases,
  `-w 128K`, `-M 500`) that stay inside QNX limits (see Limitations), 31 commands in total. For every command it starts a local server (`iperf3 -s -1`), runs the client with a
  40 s time limit and prints `##### RESULT <name> rc=<exit code>`; `rc=124` means the client hung. The `-J` commands
  also have their output checked with the target's `python3` (the check is skipped when `python3` is not
  installed): it must parse as JSON, contain `start`, `intervals` and `end`, no `error`, and a non-zero byte count.
  Commands that are expected to fail are marked `xrun` (iperf3 rejects the arguments by design) or `xnoqnx` (option
  not supported on QNX). The last line summarises the run, for example
  `31 commands: 23 pass, 1 rejected by iperf3 as expected, 7 unsupported on QNX as expected, 0 unexpected`. Only
  unexpected results count as failures, and the script exits non-zero only for those. A command marked as
  expected to fail that exits 0 is reported as `UNEXPECTED`. The server output of each command is kept in
  `server.<n>.log` and the output of the `-J` commands in `client.<n>.json`, in the current directory.
* `iperf3_unit_tests.sh` runs the four unit test programs of upstream's `make check` (`t_timer`, `t_units`,
  `t_uuid`, `t_api`), prints the exit code of each and exits non-zero if any of them failed. They are only available when the package was built with
  `with_tests=True`. A passing test prints nothing, except `t_uuid`, which prints a cookie.

```bash
# define target IP address
TARGET_HOST=<target-ip-address-or-hostname>

# stage folder from "Deploy with the unit tests"
PATH_2_STAGE=$(realpath ~/qnx_workspace/stage_iperf3)
DEPLOYED=$PATH_2_STAGE/direct_deploy/iperf3/usr

# copy iperf3, its library, the unit tests and the test scripts to your QNX target
ssh qnxuser@$TARGET_HOST mkdir -p /tmp/iperf3t
scp $DEPLOYED/bin/iperf3 $DEPLOYED/lib/libiperf.so.0 qnxuser@$TARGET_HOST:/tmp/iperf3t/
scp $DEPLOYED/libexec/iperf3-tests/t_* qnxuser@$TARGET_HOST:/tmp/iperf3t/
scp $QNX_CONAN_ROOT/recipes/iperf3/tests/iperf3_tests.sh $QNX_CONAN_ROOT/recipes/iperf3/tests/iperf3_unit_tests.sh \
    qnxuser@$TARGET_HOST:/tmp/iperf3t/

# ssh into the target
ssh qnxuser@$TARGET_HOST

# run the iperf3 command tests
cd /tmp/iperf3t
chmod +x iperf3 t_* iperf3_tests.sh iperf3_unit_tests.sh
./iperf3_tests.sh

# run the unit tests
./iperf3_unit_tests.sh
```

# Patches

The recipe applies two patches (listed in `all/conandata.yml`) and runs upstream's shipped `configure` unchanged.

* `all/patches/iperf-3.7-qnx-fix.patch` - changes required to build on QNX: `portable_endian.h` includes
  `<net/netbyte.h>` on QNX and `timer.h` includes `<sys/time.h>` on QNX.
* `all/patches/iperf-3.7-json-udp-bufsize.patch` - not QNX specific: suppresses the "Increasing socket buffer size
  to N" message in JSON mode (`!test->json_output`). Without it the message is printed before the JSON and breaks
  `-u -J` output whenever the default UDP send buffer is smaller than the block size (always the case on QNX
  loopback).

# Limitations on QNX

Tested on QNX 8.0 and QNX 7.1: of the 31 commands of
`iperf3_tests.sh`, 23 pass and the other 8 exit non-zero as expected.

* `-n 5M -t 5` is rejected by iperf3 itself (only one of `-t`, `-n`, `-k` may be given).
* `-Z` (zero copy), `-A` (CPU affinity) and `-C` (congestion control) are not available in this build. With SDP 7.1
  `-C` is reported as "an option you are trying to set is not implemented yet" (the SDP's `netinet/tcp.h` does not
  define `TCP_CONGESTION`, so the option is not compiled in); with SDP 8.0 the option is accepted but the stack
  refuses it ("Supplied congestion control algorithm not supported on this host").
* `-w` is limited by the stack's socket buffer limit. SDP 8.0: `kern.ipc.maxsockbuf` (2 MiB on the targets), `-w 1M`
  works and `-w 8M` fails with "No buffer space available". SDP 7.1: `kern.sbmax` (256 KiB on the target), `-w 128K`
  works and `-w 256K` and larger fail with the same message.
* `-M` is set before the connection is established and is limited by `net.inet.tcp.mssdflt` (536 on both SDPs):
  `-M 500` and `-M 536` work, `-M 537` and `-M 1000` fail with "Invalid argument".
* On SDP 8.0, raising both sysctls on the target (for example `sudo sysctl kern.ipc.maxsockbuf=16777216
  net.inet.tcp.mssdflt=1460`) lifts the `-w 8M` and `-M 1000` limits (checked on an aarch64le target).
