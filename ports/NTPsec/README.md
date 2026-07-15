# NTPsec [![Build](https://github.com/qnx-ports/build-files/actions/workflows/ntpsec.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/ntpsec.yml)

# Compile the port for QNX

**Note**: QNX ports are only supported from a **Linux host** operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Compile the port for QNX in a Docker container

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

# Source SDP environment
# for 7.1
source ~/qnx710/qnxsdp-env.sh
# for 8.0
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# clone ntpsec
git clone https://github.com/qnx-ports/ntpsec.git

# Build ntpsec
QNX_PROJECT_ROOT="$(pwd)/ntpsec" make -C build-files/ports/NTPsec clean
QNX_PROJECT_ROOT="$(pwd)/ntpsec" make -C build-files/ports/NTPsec install

```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Source SDP environment
# for 7.1
source ~/qnx710/qnxsdp-env.sh
# for 8.0
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# clone ntpsec
git clone https://github.com/qnx-ports/ntpsec.git

# Build ntpsec
QNX_PROJECT_ROOT="$(pwd)/ntpsec" make -C build-files/ports/NTPsec clean
QNX_PROJECT_ROOT="$(pwd)/ntpsec" make -C build-files/ports/NTPsec install
```

# Test NTPsec on Target

```bash
export TARGET_HOST=<target-ip-address-or-hostname>
mkdir ntpsec
mkdir -p ~/ntpsec/bin
mkdir -p ~/ntpsec/lib
mkdir -p ~/ntpsec/etc

# Copy the dependency libraries for testing
scp $QNX_TARGET/x86-64/usr/local/sbin/ntpd   qnxuser@$TARGET_HOST:~/ntpsec/bin
scp $QNX_TARGET/x86-64/usr/local/bin/ntpq  qnxuser@$TARGET_HOST:~/ntpsec/bin
scp $QNX_TARGET/x86-64/usr/local/lib/libffi.so  qnxuser@$TARGET_HOST:~/ntpsec/lib
scp $QNX_TARGET/x86-64/usr/local/lib/libntpc.so   qnxuser@$TARGET_HOST:~/ntpsec/lib
scp $QNX_TARGET/x86-64/usr/local/lib/libntpc.so.1.1.0   qnxuser@$TARGET_HOST:~/ntpsec/lib
scp $QNX_TARGET/x86-64/usr/local/lib/libffi.so.6   qnxuser@$TARGET_HOST:~/ntpsec/lib
scp $QNX_TARGET/x86-64/usr/local/lib/libntpc.so.1   qnxuser@$TARGET_HOST:~/ntpsec/lib

Prepare configure file and copy certificates and keys into ~/ntpsec/etc
```
# Run ntpd daemon and track

```bash
./ntpd -n -d -c < path to ntpsec.conf >
./ntpq 
```
# Expect result after functional test:

```bash
./ntpd -n -d -c < path to ntpsec.conf >
2026-07-15T11:03:29 ntpd[1515522]: INIT: ntpd ntpsec-1.2.4+NTPsec_1_2_4-dirty: Starting
2026-07-15T11:03:29 ntpd[1515522]: INIT: Command line: ./ntpd -n -d -c /data/var/etc/ntp.conf
2026-07-15T11:03:29 ntpd[1515522]: INIT: setrlimit(RLIMIT_CORE, [18446744073709551613, 18446744073709551613]) failed
2026-07-15T11:03:29 ntpd[1515522]: CONFIG: readconfig: parsing file: /data/var/etc/ntp.conf
2026-07-15T11:03:29 ntpd[1515522]: INIT: Using SO_TS_CLOCK(ns)
2026-07-15T11:03:29 ntpd[1515522]: IO: Listen and drop on 0 v6wildcard [::]:123
2026-07-15T11:03:29 ntpd[1515522]: IO: Listen and drop on 1 v4wildcard 0.0.0.0:123
2026-07-15T11:03:29 ntpd[1515522]: IO: Listen normally on 2 lo0 127.0.0.1:123
2026-07-15T11:03:29 ntpd[1515522]: IO: Listen normally on 3 lo0 [::1]:123
2026-07-15T11:03:29 ntpd[1515522]: IO: Listen normally on 4 lo0 [fe80::1%1]:123
2026-07-15T11:03:29 ntpd[1515522]: IO: Listen normally on 5 wm0 [fe80::5054:ff:fe6e:9f03%17]:123
2026-07-15T11:03:29 ntpd[1515522]: IO: Listen normally on 6 wm0 192.168.122.15:123
2026-07-15T11:03:29 ntpd[1515522]: IO: Listening on routing socket on fd #23 for interface updates
2026-07-15T11:03:29 ntpd[1515522]: INIT: MRU 10922 entries, 13 hash bits, 65536 bytes
2026-07-15T11:03:29 ntpd[1515522]: INIT: OpenSSL 1.1.1zg  7 Apr 2026, 1010120f
2026-07-15T11:03:29 ntpd[1515522]: NTSc: Using system default root certificates.
2026-07-15T11:03:30 ntpd[1515522]: DNS: dns_probe: time.cloudflare.com, cast_flags:1, flags:21801
2026-07-15T11:03:30 ntpd[1515522]: NTSc: DNS lookup of time.cloudflare.com took 0.058 sec
2026-07-15T11:03:30 ntpd[1515522]: NTSc: connecting to time.cloudflare.com:4460 => 162.159.200.1:4460
2026-07-15T11:03:30 ntpd[1515522]: NTSc: Using file /data/var/tmp/ca-certificates.crt for root certificates.
2026-07-15T11:03:30 ntpd[1515522]: NTSc: set cert host: time.cloudflare.com
2026-07-15T11:03:30 ntpd[1515522]: NTSc: Using TLSv1.3, TLS_AES_256_GCM_SHA384 (256)
2026-07-15T11:03:30 ntpd[1515522]: NTSc: certificate subject name: /CN=time.cloudflare.com
2026-07-15T11:03:30 ntpd[1515522]: NTSc: certificate issuer name: /C=US/ST=Texas/L=Houston/O=SSL Corp/CN=SSL.com SSL Intermediate CA ECC R2
2026-07-15T11:03:30 ntpd[1515522]: NTSc: SAN:DNS time.cloudflare.com, www.time.cloudflare.com
2026-07-15T11:03:30 ntpd[1515522]: NTSc: certificate is valid.
2026-07-15T11:03:30 ntpd[1515522]: NTSc: Good ALPN from time.cloudflare.com
2026-07-15T11:03:30 ntpd[1515522]: NTSc: read 816 bytes
2026-07-15T11:03:30 ntpd[1515522]: NTSc: Got 8 cookies, length 96, aead=15.
2026-07-15T11:03:30 ntpd[1515522]: NTSc: NTS-KE req to time.cloudflare.com took 0.319 sec, OK
2026-07-15T11:03:30 ntpd[1515522]: DNS: dns_check: processing time.cloudflare.com, 1, 21801
2026-07-15T11:03:30 ntpd[1515522]: DNS: Server taking: 162.159.200.1
2026-07-15T11:03:30 ntpd[1515522]: DNS: dns_take_status: time.cloudflare.com=>good, 0
2026-07-15T06:43:53 ntpd[1515522]: CLOCK: time stepped by -15776.039892
2026-07-15T06:43:53 ntpd[1515522]: INIT: MRU 10922 entries, 13 hash bits, 65536 bytes
```
