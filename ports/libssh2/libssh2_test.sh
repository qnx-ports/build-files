#!/bin/sh

HOST="127.0.0.1"
USER="qnxuser"
PASS="password"     # update the password to match the password of the user on the target system
BUILD_DIR="$HOME/oss/lib_test/ssh2/test/nto-x86_64-o/build"
PASS_COUNT=0
FAIL_COUNT=0
LOG_FILE="$BUILD_DIR/validation_log.txt"

# Clear log file
> "$LOG_FILE"

run_test() {
    echo "Testing: $1"
    echo "=== $1 ===" >> "$LOG_FILE"
    if eval "$2" 2>&1 | tee -a "$LOG_FILE" | grep -q "all done"; then
        echo "   PASS"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "   FAIL"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    echo "" >> "$LOG_FILE"
    echo ""
}

cd "$BUILD_DIR/example" || exit 1

# Setup test files
echo "test file content" > /tmp/test_scp.txt
echo "This is a test file for SCP write" > /tmp/test_scp_write.txt
echo "upload test" > /tmp/upload_test.txt
echo "test content" > /tmp/sftp_testfile.txt
dd if=/dev/zero of=/tmp/small_test.bin bs=1024 count=10 2>/dev/null
mkdir -p /tmp/sftp_test_dir
echo "file1 content" > /tmp/sftp_test_dir/file1.txt
echo "file2 content" > /tmp/sftp_test_dir/file2.txt

# Library checks
echo "=== Library Verification ===" | tee -a "$LOG_FILE"
[ -f "$BUILD_DIR/src/libssh2.so.1.0.1" ] && echo " Shared library found" | tee -a "$LOG_FILE" || echo " Shared library missing" | tee -a "$LOG_FILE"
[ -f "$BUILD_DIR/src/libssh2.a" ] && echo " Static library found" | tee -a "$LOG_FILE" || echo " Static library missing" | tee -a "$LOG_FILE"
SYM_COUNT=$(nm -D "$BUILD_DIR/src/libssh2.so.1.0.1" 2>/dev/null | grep " T " | wc -l)
echo "Exported symbols: $SYM_COUNT" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# SSH Core
echo "=== SSH Core Tests ===" | tee -a "$LOG_FILE"
run_test "Basic Authentication" "./ssh2 $HOST $USER $PASS"
run_test "Command Execution" "./ssh2_exec $HOST $USER $PASS 'uname -a'"

# Data Transfer
echo "=== Data Transfer Tests ===" | tee -a "$LOG_FILE"
run_test "SSH Echo (1.5MB)" "./ssh2_echo $HOST $USER $PASS"
run_test "SCP Download" "./scp $HOST $USER $PASS /tmp/test_scp.txt /tmp/test_scp_dest.txt"
run_test "SCP Upload" "./scp_write $HOST $USER $PASS /tmp/test_scp_write.txt"

# Non-blocking
echo "=== Non-blocking Tests ===" | tee -a "$LOG_FILE"
run_test "SCP Non-blocking Download" "./scp_nonblock $HOST $USER $PASS /tmp/test_scp.txt /tmp/test_scp_nb.txt"
run_test "SCP Non-blocking Upload" "./scp_write_nonblock $HOST $USER $PASS /tmp/upload_test.txt"

# SFTP
echo "=== SFTP Tests ===" | tee -a "$LOG_FILE"
run_test "Directory List" "./sftpdir $HOST $USER $PASS ."
run_test "Directory List (custom)" "./sftpdir $HOST $USER $PASS /tmp/sftp_test_dir"
run_test "Mkdir" "./sftp_mkdir $HOST $USER $PASS"
run_test "Non-blocking" "./sftp_nonblock $HOST $USER $PASS"
run_test "File Operations" "./sftp $HOST $USER $PASS"
run_test "Append" "./sftp_append $HOST $USER $PASS /tmp/sftp_testfile.txt"
run_test "Write" "./sftp_write $HOST $USER $PASS /tmp/small_test.bin"
run_test "Write NB" "./sftp_write_nonblock $HOST $USER $PASS /tmp/small_test.bin"
run_test "RW Non-blocking" "./sftp_RW_nonblock $HOST $USER $PASS /tmp/sftp_rw_test.txt"

# Stress tests
echo "=== Stress Tests ===" | tee -a "$LOG_FILE"
echo "10 sequential connections..." | tee -a "$LOG_FILE"
time for i in $(seq 1 10); do
    ./ssh2_exec $HOST $USER $PASS "echo conn_$i" > /dev/null 2>&1
done && echo "   PASS" | tee -a "$LOG_FILE" || echo "   FAIL" | tee -a "$LOG_FILE"

# Summary
echo "==============================" | tee -a "$LOG_FILE"
echo "Results: $PASS_COUNT passed, $FAIL_COUNT failed" | tee -a "$LOG_FILE"
echo "Log saved: $LOG_FILE"

# Cleanup
rm -f /tmp/test_scp.txt /tmp/test_scp_dest.txt /tmp/test_scp_nb.txt /tmp/upload_test.txt /tmp/download_test.txt /tmp/nb_test.txt /tmp/test_scp_write.txt /tmp/sftp_testfile.txt /tmp/small_test.bin /tmp/sftp_rw_test.txt
rm -rf /tmp/sftp_test_dir /tmp/sftp_newdir