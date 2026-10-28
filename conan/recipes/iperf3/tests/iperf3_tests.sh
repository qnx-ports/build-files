#!/bin/sh
# Runs the command list of upstream's test_commands.sh (iperf3 3.7) against a local server
# and records the exit code of every command. Commands expected to exit non-zero are marked: xrun = rejected by iperf3 by design,
# xnoqnx = option not supported on QNX. Only unexpected results count as failures. Run from the directory holding ./iperf3
# (and libiperf.so.0, found via LD_LIBRARY_PATH=.). Usage: ./iperf3_tests.sh [ipv4-host [ipv6-host]]
host=${1:-127.0.0.1}
host6=${2:-::1}
export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
fails=0; n=0; SRV=""; jchk=; npass=0; nxrej=0; nxqnx=0; exp=pass
# run_timeout <seconds> <command...>: like timeout(1) (rc=124 when the time is up), which not every QNX target has
run_timeout() {
    secs=$1; shift
    if command -v timeout >/dev/null 2>&1; then
        timeout $secs "$@"
        return $?
    fi
    "$@" &
    cpid=$!
    ( sleep $secs; kill $cpid ) >/dev/null 2>&1 &
    wpid=$!
    wait $cpid
    rc=$?
    kill $wpid >/dev/null 2>&1
    [ $rc -gt 128 ] && rc=124
    return $rc
}
# json_ok <file>: iperf3 -J output must parse, have start/intervals/end, no "error" key, and a non-zero byte count
json_ok() {
    command -v python3 >/dev/null 2>&1 || { echo "##### no python3, JSON not validated"; return 0; }
    python3 -I -c '
import json, sys
d = json.load(open(sys.argv[1]))
assert "error" not in d, d["error"]
for k in ("start", "intervals", "end"):
    assert k in d, "missing " + k
assert d["intervals"], "no intervals"
e = d["end"]
b = e["sum_sent"]["bytes"] if "sum_sent" in e else e["sum"]["bytes"]
assert b > 0, "no bytes transferred"
' "$1" || { echo "##### JSON check failed: $1"; return 1; }
    echo "##### JSON ok: $1"
}
run() {   # run <name> <iperf3 client args...>; set host6 to override the address used with -6
    name=$1; shift
    h=$host
    case " $* " in *" -6 "*) h=$host6;; esac
    n=$((n+1))
    echo "##### $name: iperf3 $*"
    ./iperf3 -s -1 $SRV > server.$n.log 2>&1 &
    srv=$!
    sleep 1
    if [ -n "$jchk" ]; then
        run_timeout 40 ./iperf3 -c $h "$@" > client.$n.json    # rc=124: client timed out (hang)
        rc=$?
        cat client.$n.json
        [ $rc -ne 0 ] || json_ok client.$n.json || rc=99    # rc=99: -J output is not valid/complete JSON
    else
        run_timeout 40 ./iperf3 -c $h "$@"    # rc=124: client timed out (hang)
        rc=$?
    fi
    sleep 1
    kill $srv 2>/dev/null
    wait $srv 2>/dev/null
    echo "##### RESULT $name rc=$rc"
    case $exp:$rc in
        pass:0) npass=$((npass+1));;
        pass:*) fails=$((fails+1)); echo "##### UNEXPECTED $name: expected rc=0";;
        xrun:0) fails=$((fails+1)); echo "##### UNEXPECTED $name: expected iperf3 to reject this";;
        xrun:*) nxrej=$((nxrej+1));;
        xnoqnx:0) fails=$((fails+1)); echo "##### UNEXPECTED $name: expected iperf3 to fail on QNX (unsupported option)";;
        xnoqnx:*) nxqnx=$((nxqnx+1));;
    esac
    exp=pass; jchk=
}
jrun()   { jchk=1; run "$@"; }       # client prints -J output, which is validated by json_ok
xrun()   { exp=xrun;   run "$@"; }   # iperf3 rejects the arguments by design (rc != 0 expected)
xnoqnx() { exp=xnoqnx; run "$@"; }   # option not supported on QNX (rc != 0 expected)
./iperf3 -v 2>&1 | head -2
run basic            -V -t 5 -T test1
run udp              -u -V -t 5
run omit             -i .3 -O 2 -t 5
jrun json            -i 1 -J -t 5
jrun json-udp        -u -J -t 3
jrun json-udp-l1400  -u -J -t 3 -l 1400
jrun json-reverse    -R -J -t 3
jrun json-parallel   -P 2 -J -t 3
run v4               -4 -t 5
run v4-udp           -4 -u -t 5
run v6               -6 -t 5
run v6-udp           -6 -u -t 5
run parallel3        -P 3 -t 5
run parallel3-udp    -u -P 3 -t 5
run reverse          -P 2 -t 5 -R
run reverse-udp      -u -P 2 -t 5 -R
xnoqnx zerocopy         -Z -t 5
xnoqnx zerocopy-rev     -Z -t 5 -R
xnoqnx window8M         -t 5 -w 8M   # socket buffer limit: kern.ipc.maxsockbuf 2 MiB (SDP 8.0), kern.sbmax 256 KiB (SDP 7.1)
run window128K       -t 5 -w 128K
run bytes5M          -n 5M
run bytes5M-udp      -n 5M -u -b1G
xrun bytes+time       -n 5M -t 5
run blocks1K         -k 1K
run blocks1K-udp     -k 1K -u -b1G
xnoqnx affinity         -A 2/2
xnoqnx affinity-udp     -A 2/2 -u -b1G
run burst            -u -b1G/100
xnoqnx mss1000          -M 1000 -V   # set before connect: capped by net.inet.tcp.mssdflt (536)
run mss500           -M 500 -V
xnoqnx congestion-reno  -C reno -V
echo "##### SUMMARY $n commands: $npass pass, $nxrej rejected by iperf3 as expected, $nxqnx unsupported on QNX as expected, $fails unexpected"
[ $fails -eq 0 ]
