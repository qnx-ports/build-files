# libmodbus [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libmodbus.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libmodbus.yml)

Supports QNX 8.0 (aarch64le, x86_64). Built from upstream [stephane/libmodbus](https://github.com/stephane/libmodbus) `v3.2.0` with no source patches: upstream `configure.ac` already detects `*nto-qnx*` and links `-lsocket`.

**NOTE**: QNX ports are only supported from a Linux host operating system.

Use `$(nproc)` instead of `4` after `JLEVEL=` if you want to use all cores.

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

# Clone libmodbus
cd ~/qnx_workspace
git clone https://github.com/stephane/libmodbus.git
cd libmodbus && git checkout v3.2.0 && cd ..

# Build and install libmodbus (plus test binaries)
BUILD_TESTING=ON QNX_PROJECT_ROOT="$(pwd)/libmodbus" JLEVEL=4 make -C build-files/ports/libmodbus install
```

## Compile the port for QNX on Ubuntu host
```bash
sudo apt install autoconf automake libtool

mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/stephane/libmodbus.git
cd libmodbus && git checkout v3.2.0 && cd ..

source ~/qnx800/qnxsdp-env.sh

BUILD_TESTING=ON QNX_PROJECT_ROOT="$(pwd)/libmodbus" JLEVEL=4 make -C build-files/ports/libmodbus install
```

To build only one architecture, run make in its folder, e.g. `make -C build-files/ports/libmodbus/nto-aarch64-le install`.
`BUILD_TESTING=ON` also installs the test binaries, `modbus-serial-probe` and `qnxtests.sh`; leave it out (default `OFF`) to install only the library, headers and pkg-config file.

Installed files:

| What | Where |
| --- | --- |
| Headers | `$QNX_TARGET/usr/local/include/modbus/` |
| Library | `$QNX_TARGET/<cpu>/usr/local/lib/libmodbus.so*` |
| pkg-config | `$QNX_TARGET/<cpu>/usr/local/lib/pkgconfig/libmodbus.pc` |
| Tests (`BUILD_TESTING=ON`) | `$QNX_TARGET/<cpu>/usr/local/bin/libmodbus_tests/` |

## Deploy binaries via SSH
```bash
TARGET_HOST=<target-ip-address-or-hostname>

scp $QNX_TARGET/aarch64le/usr/local/lib/libmodbus.so* qnxuser@$TARGET_HOST:~/lib
scp -r $QNX_TARGET/aarch64le/usr/local/bin/libmodbus_tests qnxuser@$TARGET_HOST:~/
```

If `~/lib` does not exist, create it with `ssh qnxuser@$TARGET_HOST "mkdir -p ~/lib"`.

## Tests

`qnxtests.sh` runs upstream's test programs as server/client pairs on the target:

| Test | What it covers |
| --- | --- |
| `version` | Library loads, header and runtime versions match |
| `unit-tcp` | Full upstream unit suite over TCP on 127.0.0.1:1502 |
| `unit-tcppi` | Same suite over IPv6 (`::1`); skipped when IPv6 loopback is absent |
| `random-tcp` | Random read/write cross-check |
| `bandwidth-tcp` | Throughput; prints points/s and registers/s |
| `unit-rtu` | Full unit suite over RTU (needs two serial ports) |
| `serial-probe` | Which RTU features the serial driver supports |

```bash
ssh qnxuser@$TARGET_HOST
cd ~/libmodbus_tests
sh qnxtests.sh

# RTU: join two ports with a null-modem cable (or an auto-direction RS-485 pair)
SER_SERVER=/dev/ser1 SER_CLIENT=/dev/ser2 sh qnxtests.sh
```

`modbus-serial-probe` can also be run alone against one port, optionally reading registers from a real device:
```bash
./modbus-serial-probe /dev/ser1 19200 E            # capabilities only
./modbus-serial-probe /dev/ser1 19200 E 1 0 4      # + read 4 holding registers from slave 1
```

## QNX notes

- RS-485: `modbus_rtu_set_serial_mode(ctx, MODBUS_RTU_RS485)` uses the Linux-only `TIOCSRS485` ioctl and is compiled out on QNX. Use a transceiver with automatic direction control, or manual RTS control via `modbus_rtu_set_rts()` if the probe reports `TIOCM_RTS` as OK. `modbus_rtu_set_rts()` itself returns 0 even when the driver ignores RTS, so the probe drives the line and reads it back. On a Raspberry Pi 4 `/dev/ser1` (GPIO 14/15) the probe reports RTS as `FAIL (Input/output error)`, so use an auto-direction transceiver there.
- Baud rates above 115200 depend on which `B*` constants the QNX `termios.h` defines; custom rates (termios2) are Linux-only.
- Port 502 needs root. The tests use 1502.
- libmodbus 3.2.0 adds `modbus_proxy()` for bridging an RTU and a TCP backend in one process.
- Serial flow control: QNX SDP 8.0 Known Issues 2967436 reports serial transfer errors with software flow control (XON/XOFF) on AArch64. libmodbus RTU does not enable it; keep it off (`stty -ixon -ixoff` if a port was configured by hand).

## Known test result on QNX 8.0

Raspberry Pi 4B, QNX 8.0.0, aarch64le, built with SDP 8.0 `qcc` (gcc 12.2.0), 2026-11-07:

| Test | Result |
| --- | --- |
| version, unit-tcppi, random-tcp, bandwidth-tcp | PASS |
| unit-tcp (IPv4) | FAIL at `2/2 Adapted byte timeout (7ms > 5ms)` (unit-test-client.c line 755), every run |

The failure is in the test, not the library port. For that check, `unit-test-server` sends the reply one byte per `send()` 5 ms apart, on a socket without `TCP_NODELAY`. QNX's IPv4 stack applies Nagle's algorithm and holds each byte until the previous one is acknowledged, so the gap exceeds the 7 ms byte timeout. With `TCP_NODELAY` set on that socket the suite passes (10/10 runs). The fix to the test server is upstream PR [stephane/libmodbus#892](https://github.com/stephane/libmodbus/pull/892); until it lands, `qnxtests.sh` on a v3.2.0 checkout reports this one failure.
