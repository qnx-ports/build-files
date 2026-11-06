# QFuse for QNX 8.0

QFuse maps a tested subset of high-level FUSE callbacks to native QNX resource
managers. This recipe builds the static library, headers, pkg-config metadata,
and lifecycle tools for `x86_64` or `aarch64le` on a Linux SDK host. It requires
the developer's own activated QNX SDP 8.0. It stages into a private root rather
than modifying the SDK.

## Build and verify

Install Bash, GNU make, a host C compiler, Python 3, patch and pkg-config. Keep
QFuse and build-files as separate source checkouts:

```sh
mkdir -p ~/qnx_workspace
cd ~/qnx_workspace
git clone https://github.com/gowtham0992/qfuse.git
git -C qfuse checkout e8fcb83
# Use this build-files checkout, containing ports/qfuse.
source ~/qnx800/qnxsdp-env.sh
QNX_PROJECT_ROOT="$PWD/qfuse" make -C build-files/ports/qfuse CPU=x86_64 install verify
QNX_PROJECT_ROOT="$PWD/qfuse" make -C build-files/ports/qfuse CPU=aarch64le install verify
```

Source baseline: [QFuse e8fcb83](https://github.com/gowtham0992/qfuse/tree/e8fcb83).
The project fetches libfuse 3.16.2 fixture files by hash-checked lock file; this
recipe does not import libfuse Git history or distribute the QNX SDK.

`INSTALL_ROOT_nto` defaults to `stage/$(CPU)` beneath this recipe and `PREFIX` to
`/usr/local`. `QFUSE_BUILD_PARENT` defaults to `build/$(CPU)`. Override both with
absolute Linux-native paths when compiling under emulation. `QNX_SDP_ROOT` can
be set if it cannot be derived from sourced `QNX_HOST`. `QFUSE_SOURCE_DIR` is an
alias for `QNX_PROJECT_ROOT`.

The installed pkg-config prefix points at its staging location for subsequent
cross-compilation. Regenerate the package when changing that location. The
manifest uninstaller preserves modified and unrelated files:

```sh
QNX_PROJECT_ROOT="$PWD/qfuse" make -C build-files/ports/qfuse CPU=x86_64 uninstall
```

## Validation and scope

Both architecture recipes were built, staged and checked with the real SDP 8.0.
Installed pkg-config flags compile unchanged upstream hello and passthrough
sources. Passthrough explicitly selects QFuse's optional directory-entry adapter.

The QFuse project's native QEMU evidence covers 51 differential cases on both
architectures, callback stalls and client interruption, management authorization,
permissions, lifecycle and process-death recovery. The current ARM build also
passed native cp/diff over 5,000 files and executes an ELF from an SSHFS mount.
See its [verification guide](https://github.com/gowtham0992/qfuse/blob/main/docs/guide/verification.md).

This is experimental source compatibility, not complete libfuse compatibility.
Mounting requires root. Low-level FUSE, non-root mounts, xattrs and locking are
outside the supported profile. QEMU functional deadlines do not establish
hardware or hard-real-time guarantees. Independent builds and upstream review
are separate from the owner's tests.

SSHFS dependencies and optional bindfs stay in QFuse's separate recipes. No SDK
files, licensed runtime, target images, credentials or binaries accompany this
contribution. Original contribution files are MIT; upstream components retain
their own licenses.
