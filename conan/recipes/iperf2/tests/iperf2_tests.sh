#!/bin/sh

function print_test_name {
    printf "##%${#1}s##\n" | tr ' ' '#'
    printf "# ${1} #\n"
    printf "##%${#1}s##\n" | tr ' ' '#'
}

function wait_for_exit {
    server_pid=$1
    timeout=$2
    echo "waiting for exit server:$server_pid ..."
    wait $server_pid
    echo "waiting for resources to be freed ..."
    sleep $timeout
}

function run_any {
    name=$1
    srv_cmd=$2
    cln_cmd=$3
    print_test_name "$name"
    eval "$srv_cmd &"
    srv_pid=$!
    sleep 0.125
    eval "$cln_cmd"
    wait_for_exit $srv_pid 1
}

function run_wait {
    run_any "${2}" "${3}" "${4}"
    echo "waiting more for ${1}sec."
    sleep $1
}

OS=$(uname)
VER=$(./iperf -v 2>&1)
print_test_name "OS:${OS} ${VER}"
run_any "t1_tcp.sh port 5001"               "./iperf -p 5001 -s -P 1 -i 1 -t 12 2>&1" "./iperf -p 5001 -c 127.0.0.1 -P 1 -i 1"
run_any "t2_tcp6.sh port 5002"              "./iperf -p 5002 -s --ipv6_domain -P 1 -i 1 -t 12 2>&1" "./iperf -p 5002 -c "::1" -V -P 1 -i 1"
run_any "t3_udp.sh port 5003"               "./iperf -p 5003 -s -P 1 -u -i 1 -t 12 2>&1" "./iperf -p 5003 -c 127.0.0.1 -P 1 -u -b 10m -i 1"
run_any "t4_udp6.sh port 5004"              "./iperf -p 5004 -s -V -P 1 -u -i 1 -t 12 2>&1" "./iperf -p 5004 -c "::1" -V -P 1 -u -b 10m -i 1"
run_any "t5_f.sh port 5005"                 "./iperf -p 5005 -s -P 1 -u -i 1 -t 12 2>&1" "./iperf -p 5005 -c 127.0.0.1 -P 1 -u -b 1m -i 1 -F Makefile"
run_any "t6_filelong.sh port 5006"          "./iperf -p 5006 -s -P 1 -u -i 1 -t 12 2>&1" "./iperf -p 5006 -c 127.0.0.1 -P 1 -u -b 1m -i 1 --file_input Makefile"
run_any "t7_n.sh port 5007"                 "./iperf -p 5007 -s -P 1 -i 1 -t 12 2>&1" "./iperf -p 5007 -c 127.0.0.1 -P 1 -i 1 -n 1G"
run_any "t8_num.sh port 5008"               "./iperf -p 5008 -s -P 1 -i 1 -t 12 2>&1" "./iperf -p 5008 -c 127.0.0.1 -P 1 -i 1 --num 1G"
run_any "t9_parallel.sh port 5009"          "./iperf -p 5009 -s --parallel 4 -i 1 -t 12 2>&1" "./iperf -p 5009 -c 127.0.0.1 -P 4 -i 1"
run_any "t10_dualtest.sh port 5010"         "./iperf -p 5010 -s -P 1 -i 1 -t 12 2>&1" "./iperf -p 5010 -c 127.0.0.1 -P 1 --dualtest -L 6001 -i 1"
run_any "t11_tradeoff.sh port 5011"         "./iperf -p 5011 -s -P 1 -i 1 -t 12 2>&1" "./iperf -p 5011 -c 127.0.0.1 -P 1 --tradeoff -L 6002 -i 1"
run_any "t12_full_duplex.sh port 5012"      "./iperf -p 5012 -s -P 1 -i 1 -t 12 2>&1" "./iperf -p 5012 -c 127.0.0.1 -P 1 --full-duplex -i 1"
run_any "t13_reverse.sh port 5013"          "./iperf -p 5013 -s -P 1 -i 1 -t 12 2>&1" "./iperf -p 5013 -c 127.0.0.1 -P 1 --reverse -i 1"
run_any "t14_udp_triptimes.sh port 5014"    "./iperf -p 5014 -s -P 1 -u -i 1 -t 12 2>&1" "./iperf -p 5014 -c 127.0.0.1 -P 1 -u -b 10m -i 1 --trip-times"
run_any "t15_udp_enhanced.sh port 5015"     "./iperf -p 5015 -s -P 1 -u -i 1 -t 12 -e 2>&1" "./iperf -p 5015 -c 127.0.0.1 -P 1 -u -b 10m -i 1 -e"
run_any "t16_udp_histograms.sh port 5016"   "./iperf -p 5016 -s -P 1 -u -i 1 -t 12 --histograms 2>&1" "./iperf -p 5016 -c 127.0.0.1 -P 1 -u -b 10m -i 1 --trip-times"

if [ "QNX" = "$OS" ]; then
    echo "Start QNX specific tests..."
    run_any "low-water mark option is not applied"  "./iperf -s -i1 -t12 -l1M -e 2>&1" "./iperf -c 127.0.0.1 -i1 -e"
    run_wait 5 "low-water mark value is not specified" "./iperf -s -i1 -t12 -l1M -e --recvlowat 2>&1" "./iperf -c 127.0.0.1 -i1 -e"
    run_wait 5 "low-water mark value is 0"          "./iperf -s -i1 -t12 -l1M -e --recvlowat=0 2>&1" "./iperf -c 127.0.0.1 -i1 -e"
    run_wait 5 "low-water mark value is -1"         "./iperf -s -i1 -t12 -l1M -e --recvlowat=-1 2>&1" "./iperf -c 127.0.0.1 -i1 -e"
    run_any "low-water mark value is 1Kb"           "./iperf -s -i1 -t12 -l1M -e --recvlowat=1K 2>&1" "./iperf -c 127.0.0.1 -i1 -e"
    run_any "low-water mark value is 16Kb"          "./iperf -s -i1 -t12 -l1M -e --recvlowat=16K 2>&1" "./iperf -c 127.0.0.1 -i1 -e"
    run_any "low-water mark value is 32Kb"          "./iperf -s -i1 -t12 -l1M -e --recvlowat=32K 2>&1" "./iperf -c 127.0.0.1 -i1 -e"
    run_wait 5 "low-water mark value is 1Mb"        "./iperf -s -i1 -t12 -l1M -e --recvlowat=1M 2>&1" "./iperf -c 127.0.0.1 -i1 -e"
    run_wait 5 "low-water mark value is 5Mb"        "./iperf -s -i1 -t12 -l10M -e --recvlowat=5M 2>&1" "./iperf -c 127.0.0.1 -i1 -e"
    run_any "recv-mmsg/send-mmsg default/default 1G"    "./iperf -u -s -i1 -t 12 2>&1" "./iperf -u -c 127.0.0.1 -i1 -b1G"
    run_any "recv-mmsg/send-mmsg default/1 1G"          "./iperf -u -s -i1 -t 12 2>&1" "./iperf -u -c 127.0.0.1 -i1 -b1G --send-mmsg=1"
    run_any "recv-mmsg/send-mmsg 1/default 1G"          "./iperf -u -s -i1 --recv-mmsg=1 -t 12 2>&1" "./iperf -u -c 127.0.0.1 -i1 -b1G"
    run_any "recv-mmsg/send-mmsg 1/1 1G"                "./iperf -u -s -i1 --recv-mmsg=1 -t 12 2>&1" "./iperf -u -c 127.0.0.1 -i1 -b1G --send-mmsg=1"
    run_any "recv-mmsg/send-mmsg 2/2 1G"                "./iperf -u -s -i1 --recv-mmsg=2 -t 12 2>&1" "./iperf -u -c 127.0.0.1 -i1 -b1G --send-mmsg=2"
    run_any "recv-mmsg/send-mmsg 3/3 1G"                "./iperf -u -s -i1 --recv-mmsg=3 -t 12 2>&1" "./iperf -u -c 127.0.0.1 -i1 -b1G --send-mmsg=3"
    run_any "recv-mmsg/send-mmsg 10/10 1G"              "./iperf -u -s -i1 --recv-mmsg=10 -t12 2>&1" "./iperf -u -c 127.0.0.1 -i1 -b1G --send-mmsg=10"
    run_any "recv-mmsg/send-mmsg 1/1 500M"              "./iperf -u -s -i1 --recv-mmsg=1 -t 12 2>&1" "./iperf -u -c 127.0.0.1 -i1 -b500M --send-mmsg=1"
    run_any "recv-mmsg/send-mmsg 2/2 500M"              "./iperf -u -s -i1 --recv-mmsg=2 -t 12 2>&1" "./iperf -u -c 127.0.0.1 -i1 -b500M --send-mmsg=2"
    run_any "recv-mmsg/send-mmsg 3/3 500M"              "./iperf -u -s -i1 --recv-mmsg=3 -t 12 2>&1" "./iperf -u -c 127.0.0.1 -i1 -b500M --send-mmsg=3"
    run_any "recv-mmsg/send-mmsg 10/5 500M"             "./iperf -u -s -i1 --recv-mmsg=10 -t12 2>&1" "./iperf -u -c 127.0.0.1 -i1 -b500M --send-mmsg=5"
    run_any "recv-mmsg/send-mmsg 10/5 500M window 64K"  "./iperf -u -s -w64K -i1 --recv-mmsg=10 -t 12 2>&1" "./iperf -u -c 127.0.0.1 -w64K -i1 -b500M --send-mmsg=5"
    run_any "recv-mmsg/send-mmsg 10/5 10G window 64K"   "./iperf -u -s -w64K -i1 --recv-mmsg=10 -t 12 2>&1" "./iperf -u -c 127.0.0.1  -w64K -i1 -b10G --send-mmsg=5"
else
    echo "skip QNX specific tests for $OS"
fi
