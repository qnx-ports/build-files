#!/bin/bash

# Use environment variables if set, otherwise fallback to defaults
QNX_TARGET="${QNX_TARGET}"    # Default to ~/qnx800 if not set
TARGET_HOST="${TARGET_HOST:?Error: TARGET_HOST is not set}"
TARGET_USER="${TARGET_USER:-qnxuser}" # Default to 'qnxuser' if not set
TARGET_PASSWORD="${TARGET_PASSWORD:-qnxuser}"

echo "Using QNX directory: $QNX_TARGET"
echo "Target IP: $TARGET_HOST"
echo "Target User: $TARGET_USER"
echo ""

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "Error: sshpass is not installed. Please install it using: sudo apt install sshpass"
    exit 1
fi

# Define the target base path
TARGET_BASE="/data/home/$TARGET_USER"

# Ensure necessary target directories exist on the target system
sshpass -p "$TARGET_PASSWORD" ssh "$TARGET_USER@$TARGET_HOST" "mkdir -p $TARGET_BASE/lib $TARGET_BASE/bin"

# Transfer weston libraries to the target
echo "Transferring weston libraries..."
sshpass -p "$TARGET_PASSWORD" scp -r $QNX_TARGET/aarch64le/usr/lib/libweston* "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
sshpass -p "$TARGET_PASSWORD" scp -r $QNX_TARGET/aarch64le/usr/lib/weston "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
sshpass -p "$TARGET_PASSWORD" scp -r $QNX_TARGET/aarch64le/usr/libexec "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"

# Transfer weston test libraries to the target
echo "Transferring weston test libraries..."
sshpass -p "$TARGET_PASSWORD" scp $QNX_TARGET/aarch64le/usr/lib/test-plugin.so "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
sshpass -p "$TARGET_PASSWORD" scp $QNX_TARGET/aarch64le/usr/lib/test-ivi-layout.so "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
sshpass -p "$TARGET_PASSWORD" scp $QNX_TARGET/aarch64le/usr/lib/weston-test-desktop-shell.so "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"

# Transfer weston executables to the target
echo "Transferring weston executables..."
sshpass -p "$TARGET_PASSWORD" scp $QNX_TARGET/aarch64le/usr/sbin/weston "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/bin"
sshpass -p "$TARGET_PASSWORD" scp $QNX_TARGET/aarch64le/usr/bin/weston-* "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/bin"

# Transfer weston data to the target
echo "Transferring weston data..."
sshpass -p "$TARGET_PASSWORD" scp -r $QNX_TARGET/usr/share/weston "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/"
sshpass -p "$TARGET_PASSWORD" scp -r $QNX_TARGET/etc/xdg "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/"

# Transfer wayland libraries to the target
echo "Transferring wayland libraries..."
sshpass -p "$TARGET_PASSWORD" scp -r $QNX_TARGET/aarch64le/usr/lib/libwayland* "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"

# Transfer dependency libraries to the target
echo "Transferring dependency libraries..."
for lib in libmemstream libepoll libtimerfd libsignalfd libeventfd; do
    sshpass -p "$TARGET_PASSWORD" scp $QNX_TARGET/aarch64le/usr/lib/${lib}* "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
done

# Transfer pixman dependency
echo "Transferring pixman dependency..."
if ls $QNX_TARGET/aarch64le/usr/local/lib/libpixman* 1> /dev/null 2>&1; then
    sshpass -p "$TARGET_PASSWORD" scp $QNX_TARGET/aarch64le/usr/local/lib/libpixman* "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
else
    sshpass -p "$TARGET_PASSWORD" scp $QNX_TARGET/aarch64le/usr/lib/libpixman* "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
fi

# Transfer cairo dependancy
echo "Transferring cairo dependency..."
if ls $QNX_TARGET/aarch64le/usr/local/lib/libcairo* 1> /dev/null 2>&1; then
    sshpass -p "$TARGET_PASSWORD" scp $QNX_TARGET/aarch64le/usr/local/lib/libcairo* "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
else
    sshpass -p "$TARGET_PASSWORD" scp $QNX_TARGET/aarch64le/usr/lib/libcairo* "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
fi

# Transfer xkbcommon dependency
echo "Transferring xkbcommon dependency..."

if ls $QNX_TARGET/aarch64le/usr/local/lib/libxkbcommon* 1> /dev/null 2>&1; then
    sshpass -p "$TARGET_PASSWORD" scp $QNX_TARGET/aarch64le/usr/local/lib/libxkbcommon* "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
else
    sshpass -p "$TARGET_PASSWORD" scp $QNX_TARGET/aarch64le/usr/lib/libxkbcommon* "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
fi
sshpass -p "$TARGET_PASSWORD" scp -r $QNX_TARGET/usr/share/X11/xkb "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/"

# Transfer libz dependency
echo "Transferring libz dependency..."
if ls $QNX_TARGET/aarch64le/usr/local/lib/libz* 1> /dev/null 2>&1; then
    sshpass -p "$TARGET_PASSWORD" scp $QNX_TARGET/aarch64le/usr/local/lib/libz* "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
else
    sshpass -p "$TARGET_PASSWORD" scp $QNX_TARGET/aarch64le/usr/lib/libz* "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
fi

# Transfer test data and executables to the target
echo "Transferring test data and executables..."
sshpass -p "$TARGET_PASSWORD" scp -r ~/qnx_workspace/weston/tests/reference "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/"
sshpass -p "$TARGET_PASSWORD" scp $QNX_TARGET/aarch64le/usr/lib/weston-test-* "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
sshpass -p "$TARGET_PASSWORD" scp -r $QNX_TARGET/aarch64le/usr/bin/weston_tests "$TARGET_USER@$TARGET_HOST:$TARGET_BASE"
