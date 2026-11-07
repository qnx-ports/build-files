# QFuse for QNX 8.0

QFuse maps a tested subset of high-level FUSE callbacks to native QNX resource
managers. This recipe builds `libfuse3.a`, the public SDK headers/pkg-config
metadata, `qfuse-mount` and `qfuse-unmount` using QNX's standard
`recurse.mk`/`common.mk`/`qtargets.mk` system. It supports x86_64 and aarch64le
with the developer's activated QNX SDP 8.0 on a Linux host.

## Build and verify

Install Python 3, GNU make and pkg-config. Keep QFuse and build-files as separate
source checkouts and source your own SDK:

```sh
mkdir -p ~/qnx_workspace
cd ~/qnx_workspace
git clone https://github.com/gowtham0992/qfuse.git
git -C qfuse checkout 096aa6d1a53f41ddbad2425ffb86b3a76435d665
# Use the build-files checkout containing this recipe.
source ~/qnx800/qnxsdp-env.sh
make -C build-files/ports/qfuse QNX_PROJECT_ROOT="$PWD/qfuse" \
  INSTALL_ROOT_nto="$PWD/qfuse-stage" install verify
```

This builds both architectures. Select `CPULIST=aarch64` or `CPULIST=x86_64`
for one architecture; QNX infers `CPU` from its variant directories. The previous
wrapper's `CPU=aarch64le` selection is replaced by `CPULIST=aarch64`.

The `prepare` component verifies the project's pinned public libfuse fixture
files and generates the minimal option parser/configuration. The library and
lifecycle tools compile directly through QNX make rules. Small Python helpers
verify/prepare public sources and install SDK metadata. Source preparation is
shared with the project's callback tests. Original upstream hello/passthrough sources are not
rewritten.

By default `INSTALL_ROOT_nto` is this recipe's private `stage` directory and
`PREFIX` is `/usr/local`. Results are staged beneath
`stage/aarch64le/usr/local` and `stage/x86_64/usr/local`. Set an absolute private
staging root outside the SDK. The recipe preserves that root across recursive
SDK configuration and rejects staging inside the licensed SDP. Builds default to their native variant directories;
use a Linux-native checkout when running SDK tools under emulation. Normal Linux
SDK hosts need no Docker or emulator wrapper.

`verify` links unchanged upstream hello and passthrough using only installed
pkg-config metadata, and checks the lifecycle tools' ELF architecture. Passthrough
explicitly selects the optional directory-entry adapter. The installed `.pc`
prefix points to its host staging location for subsequent cross-compilation.

## Header installation and safe removal

`hinstall` stages public headers and metadata without requiring staged target
binaries. Full `install` adds the library and tools. The final package manifest
records only QFuse-owned files. The root uninstall target preserves modified and
unrelated files, and should be run separately from build/install targets:

```sh
make -C build-files/ports/qfuse QNX_PROJECT_ROOT="$PWD/qfuse" \
  INSTALL_ROOT_nto="$PWD/qfuse-stage" CPULIST=aarch64 uninstall
```

## CI, validation and limits

The accompanying `qfuse.yml` is intended for build-files' `.github/workflows`.
It builds both CPU profiles on the repository's existing licensed QNX 8.0 SDK
runner, with read-only repository permissions and a pinned QFuse source revision.
It uploads no SDK, runtime, images or binaries. Running that upstream job depends
on maintainer approval/runner availability; the author's local native recipe
checks do not substitute for it or for independent-user reproduction.

Both CPU profiles have been built, staged and checked with the real SDK. The
project's native QEMU gates compare 51 cases on both architectures, plus
permissions, callback cancellation, namespace isolation, FIFO writer ordering,
management and lifecycle. ARM also passed native cp/diff over 5,000 files.
The project tests SSHFS reads/writes, concurrent namespace operations and
persisted remount separately. See its verification guide for qualified evidence.

This is experimental source compatibility with root management and a tested
high-level API subset. An optional target-specific enforcing policy can run
SSHFS as a dedicated non-root service UID; see the project security guide.
Low-level FUSE, ordinary unprivileged mounting, xattrs and locking are outside
the supported profile. Conflicting paths and shared backend dependencies
can still block callbacks; client cancellation does not roll back writes or
forcibly cancel foreign code. QEMU functional tests establish no hardware,
hard-real-time or safety guarantee.

SSHFS dependencies and optional bindfs remain in separate project recipes.
No SDK files, licensed runtime, target images, credentials or compiled binaries
are included. Original contribution files are MIT; upstream components retain
their own licenses.
