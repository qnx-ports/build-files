#!/bin/bash

# Prompt for QNX800 directory, target IP, and password
read -p "Enter the QNX800 folder directory path (e.g., ~/qnx800): " QNX_DIR
read -p "Enter the target IP address: " TARGET_HOST
read -p "Enter the password for the target user: " TARGET_PASSWORD
echo ""

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "Error: sshpass is not installed. Please install it using: sudo apt install sshpass"
    exit 1
fi

# Check if the directory exists
if [ ! -d "$QNX_DIR" ]; then
    echo "Error: The directory $QNX_DIR does not exist."
    exit 1
fi

# Define the target user and base path
TARGET_USER="qnxuser"
TARGET_BASE="/data/home/$TARGET_USER"

# Ensure necessary target directories exist on the target system
sshpass -p "$TARGET_PASSWORD" ssh "$TARGET_USER@$TARGET_HOST" "mkdir -p $TARGET_BASE/lib $TARGET_BASE/bin"

# Transfer weston libraries to the target
echo "Transferring weston libraries..."
sshpass -p "$TARGET_PASSWORD" scp -r $QNX_DIR/target/qnx/aarch64le/usr/lib/libweston* "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
sshpass -p "$TARGET_PASSWORD" scp -r $QNX_DIR/target/qnx/aarch64le/usr/lib/weston "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
sshpass -p "$TARGET_PASSWORD" scp -r $QNX_DIR/target/qnx/aarch64le/usr/libexec "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"

# Transfer weston test libraries to the target
echo "Transferring weston test libraries..."
sshpass -p "$TARGET_PASSWORD" scp $QNX_DIR/target/qnx/aarch64le/usr/lib/test-plugin.so "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib/weston"
sshpass -p "$TARGET_PASSWORD" scp $QNX_DIR/target/qnx/aarch64le/usr/lib/test-ivi-layout.so "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
sshpass -p "$TARGET_PASSWORD" scp $QNX_DIR/target/qnx/aarch64le/usr/lib/weston-test-desktop-shell.so "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"

# Transfer weston executables to the target
echo "Transferring weston executables..."
sshpass -p "$TARGET_PASSWORD" scp $QNX_DIR/target/qnx/aarch64le/usr/sbin/weston "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/bin"
sshpass -p "$TARGET_PASSWORD" scp $QNX_DIR/target/qnx/aarch64le/usr/bin/weston-* "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/bin"

# Transfer weston data to the target
echo "Transferring weston data..."
sshpass -p "$TARGET_PASSWORD" scp -r $QNX_DIR/target/qnx/usr/share/weston "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/"
sshpass -p "$TARGET_PASSWORD" scp -r $QNX_DIR/target/qnx/etc/xdg "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/"

# Transfer wayland libraries to the target
echo "Transferring wayland libraries..."
sshpass -p "$TARGET_PASSWORD" scp -r $QNX_DIR/target/qnx/aarch64le/usr/lib/libwayland* "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"

# Transfer dependency libraries to the target
echo "Transferring dependency libraries..."
for lib in libmemstream libpixman libepoll libtimerfd libsignalfd libeventfd; do
    sshpass -p "$TARGET_PASSWORD" scp $QNX_DIR/target/qnx/aarch64le/usr/lib/${lib}* "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
done

# Transfer xkbcommon dependency
echo "Transferring xkbcommon dependency..."
sshpass -p "$TARGET_PASSWORD" scp $QNX_DIR/target/qnx/aarch64le/usr/lib/libxkbcommon* "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
sshpass -p "$TARGET_PASSWORD" scp -r $QNX_DIR/target/qnx/usr/share/xkb "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/"

# Transfer test data and executables to the target
echo "Transferring test data and executables..."
sshpass -p "$TARGET_PASSWORD" scp -r $QNX_DIR/qnx_workspace/weston/tests/reference "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/"
sshpass -p "$TARGET_PASSWORD" scp $QNX_DIR/target/qnx/aarch64le/usr/lib/weston-test-* "$TARGET_USER@$TARGET_HOST:$TARGET_BASE/lib"
sshpass -p "$TARGET_PASSWORD" scp $QNX_DIR/target/qnx/aarch64le/usr/bin/weston_tests "$TARGET_USER@$TARGET_HOST:$TARGET_BASE"

echo "All transfers completed successfully!"
