#!/bin/bash

# Check if the user provided the correct number of arguments
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <subdirectory> <target_user> <password> <TARGET_HOST>"
  exit 1
fi

# Define the source directory where the "tests" directory is located
SRC_DIR="$(pwd)/nto-aarch64-le/qt5/$1/tests"

# Define the target directory on the target machine
TARGET_DIR="/data/home/qnxuser/qt-test/$1"

# Define the user on the target machine
TARGET_USER="$2"

# Define your password
PASSWORD="$3"

# Define target IP
TARGET_IP="$4"

# Create the target base directory if it doesn't exist
sshpass -p "$PASSWORD" ssh "$TARGET_USER@$TARGET_IP" "mkdir -p $TARGET_DIR"

# Use scp to transfer the "tests" directory while preserving the directory structure
sshpass -p "$PASSWORD" scp -r "$SRC_DIR"/* "$TARGET_USER@$TARGET_IP:$TARGET_DIR"

# Check if the transfer was successful
if [ $? -eq 0 ]; then
    echo "All files in $SRC_DIR successfully transferred to $TARGET_USER@$TARGET_IP:$TARGET_DIR."
else
    echo "Error transferring files from $SRC_DIR to $TARGET_USER@$TARGET_IP:$TARGET_DIR"
fi
