# Compile the port for QNX

**NOTE**: QNX ports are only supported from a **Linux host** operating system

## Install dependencies

```bash
sudo apt install automake pkg-config libtool
```

## Generate GNU build tool ./configure and all needed Makefiles

```bash
cd lighttpd1.4
./autogen.sh
cd -
````

## Setup QNX SDP environment

```bash
source <path-to-sdp>/qnxsdp-env.sh
```

## Build and install lighttpd binaries to SDP

```bash
QNX_PROJECT_ROOT="$(pwd)/lighttpd1.4" JLEVEL=$(nproc) make -C qnx-ports/lighttpd1.4  install
```

**All binary files have to be installed to SDP**

* $QNX_TARGET/x86_64/usr/local/lib/mod_*.so
* $QNX_TARGET/x86_64/usr/local/sbin/lighttpd
* $QNX_TARGET/x86_64/usr/local/sbin/lighttpd-angel
* $QNX_TARGET/aarch64le/usr/local/lib/mod_*.so
* $QNX_TARGET/aarch64le/usr/local/sbin/lighttpd
* $QNX_TARGET/aarch64le/usr/local/sbin/lighttpd-angel

## Build and install lighttpd binaries to specific path

```bash
QNX_PROJECT_ROOT="$(pwd)/lighttpd1.4" JLEVEL=$(nproc) make -C qnx-ports/lighttpd1.4  install USE_INSTALL_ROOT=true INSTALL_ROOT_nto=<full-path>
```

**All binary files have to be installed to specific path**

* \<full-path\>/x86_64/usr/local/lib/mod_*.so
* \<full-path\>/x86_64/usr/local/sbin/lighttpd
* \<full-path\>/x86_64/usr/local/sbin/lighttpd-angel
* \<full-path\>/aarch64le/usr/local/lib/mod_*.so
* \<full-path\>/aarch64le/usr/local/sbin/lighttpd
* \<full-path\>/aarch64le/usr/local/sbin/lighttpd-angel

## Running the Test Suite

### Install test dependencies

Install com.qnx.qnx800.target.utils.perl QNX package to your SDP

### Build and install all lighttpd tests

```bash
QNX_PROJECT_ROOT="$(pwd)/lighttpd1.4" JLEVEL=$(nproc) CPULIST=x86_64 make -C qnx/build check
```

or

```bash
QNX_PROJECT_ROOT="$(pwd)/lighttpd1.4" JLEVEL=$(nproc) CPULIST=x86_64 make -C qnx/build check USE_INSTALL_ROOT=true INSTALL_ROOT_nto=<full-path>
```

### Run the tests

Copy the tests to the target

```bash
scp $QNX_TARGET/aarch64le/usr/local/bin/lighttpd_tests root@target:/data/lighttpd
```

Run the tests on the target:

```bash
cd /data/lighttpd
./base_testsuite.sh
```

### Test execution summary

```text
...
==========================================
Unit tests summary for lighttpd 1.4.73
==========================================
# TOTAL: 3
# PASS: 3
# FAIL: 0
==========================================
...
All tests successful.
Files=4, Tests=221,  1 wallclock secs ( 0.04 usr  0.00 sys +  0.43 cusr  0.00 csys =  0.47 CPU)
Result: PASS
```
