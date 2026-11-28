#!/bin/sh
# libmodbus test runner for QNX 8.0 targets (also runs on Linux).
#
# Run from the directory holding the test binaries:
#   cd ~/libmodbus_tests && sh qnxtests.sh
#
# Optional RTU loopback test over two serial ports joined by a null-modem
# cable (or an RS-485 pair with auto-direction):
#   SER_SERVER=/dev/ser1 SER_CLIENT=/dev/ser2 sh qnxtests.sh
#
# With only one port (Raspberry Pi 4: /dev/ser1 on GPIO 14/15), run the server
# on another machine wired to it and set just SER_CLIENT:
#   SER_CLIENT=/dev/ser1 sh qnxtests.sh

pass_count=0
fail_count=0
skip_count=0

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/lib:/data/home/qnxuser/lib

record() {
    # $1 = exit code, $2 = test name
    if [ "$1" -eq 0 ]; then
        pass_count=$((pass_count + 1))
        echo "[PASSED]    $2"
    else
        fail_count=$((fail_count + 1))
        echo "*[FAILED]*  $2 (exit $1, see $2.*.log)"
    fi
}

skip() {
    skip_count=$((skip_count + 1))
    echo "[SKIPPED]   $1 ($2)"
}

# Give a background server a second to bind, then check it is still alive.
wait_for_server() {
    sleep 1
    kill -0 "$1" 2>/dev/null
}

# $1 = name, $2 = server command, $3 = client command
run_pair() {
    name=$1
    $2 > "$name.server.log" 2>&1 &
    spid=$!
    if ! wait_for_server $spid; then
        if grep -q "Address family" "$name.server.log" 2>/dev/null; then
            skip "$name" "no IPv6 loopback on this host"
        else
            record 1 "$name"
        fi
        return
    fi
    $3 > "$name.client.log" 2>&1
    rc=$?
    kill $spid 2>/dev/null
    wait $spid 2>/dev/null
    record $rc "$name"
}

echo "== libmodbus tests on $(uname -a)"

./version > version.log 2>&1
record $? version
cat version.log

run_pair unit-tcp       "./unit-test-server tcp"         "./unit-test-client tcp"
run_pair unit-tcppi     "./unit-test-server tcppi ::1"   "./unit-test-client tcppi ::1"
run_pair random-tcp     "./random-test-server"           "./random-test-client"
run_pair bandwidth-tcp  "./bandwidth-server-one tcp"     "./bandwidth-client tcp"
if [ -f bandwidth-tcp.client.log ]; then
    grep -E '^\* [0-9]+ [a-z]+/s' bandwidth-tcp.client.log | sed 's/^/    /'
fi

if [ -n "$SER_SERVER" ] && [ -n "$SER_CLIENT" ]; then
    run_pair unit-rtu "./unit-test-server rtu $SER_SERVER" "./unit-test-client rtu $SER_CLIENT"
    ./modbus-serial-probe "$SER_CLIENT" 115200 N > serial-probe.log 2>&1
    record $? serial-probe
    cat serial-probe.log
elif [ -n "$SER_CLIENT" ]; then
    # One local port: the server runs on another machine
    # (e.g. a Mac with a USB-UART adapter: ./unit-test-server rtu /dev/tty.usbserial-XXXX)
    ./unit-test-client rtu "$SER_CLIENT" > unit-rtu.client.log 2>&1
    record $? unit-rtu-remote
    ./modbus-serial-probe "$SER_CLIENT" 115200 N > serial-probe.log 2>&1
    record $? serial-probe
    cat serial-probe.log
else
    skip unit-rtu "set SER_SERVER and SER_CLIENT (two local ports) or SER_CLIENT only (remote server)"
fi

echo
echo "== Passed: $pass_count  Failed: $fail_count  Skipped: $skip_count"
[ $fail_count -eq 0 ]
