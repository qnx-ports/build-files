#!/bin/sh

echo "t1_tcp.sh port 5001"
./iperf -p 5001 -s -P 1 -i 1 -t 12 2>&1 | ./iperf -p 5001 -c 127.0.0.1 -P 1 -i 1

echo "t2_tcp6.sh port 5002"
./iperf -p 5002 -s --ipv6_domain -P 1 -i 1 -t 12 2>&1 | ./iperf -p 5002 -c "::1" -V -P 1 -i 1

echo "t3_udp.sh port 5003"
./iperf -p 5003 -s -P 1 -u -i 1 -t 12 2>&1 | ./iperf -p 5003 -c 127.0.0.1 -P 1 -u -b 10m -i 1

echo "t4_udp6.sh port 5004"
./iperf -p 5004 -s -V -P 1 -u -i 1 -t 12 2>&1 | ./iperf -p 5004 -c "::1" -V -P 1 -u -b 10m -i 1

echo "t5_f.sh port 5005"
./iperf -p 5005 -s -P 1 -u -i 1 -t 12 2>&1 | ./iperf -p 5005 -c 127.0.0.1 -P 1 -u -b 1m -i 1 -F Makefile

echo "t6_filelong.sh port 5006"
./iperf -p 5006 -s -P 1 -u -i 1 -t 12 2>&1 | ./iperf -p 5006 -c 127.0.0.1 -P 1 -u -b 1m -i 1 --file_input Makefile

echo "t7_n.sh port 5007"
./iperf -p 5007 -s -P 1 -i 1 -t 12 2>&1 | ./iperf -p 5007 -c 127.0.0.1 -P 1 -i 1 -n 1G

echo "t8_num.sh port 5008"
./iperf -p 5008 -s -P 1 -i 1 -t 12 2>&1 | ./iperf -p 5008 -c 127.0.0.1 -P 1 -i 1 --num 1G

echo "t9_parallel.sh port 5009"
./iperf -p 5009 -s --parallel 4 -i 1 -t 12 2>&1 | ./iperf -p 5009 -c 127.0.0.1 -P 4 -i 1

echo "t10_dualtest.sh port 5010"
./iperf -p 5010 -s -P 1 -i 1 -t 12 2>&1 | ./iperf -p 5010 -c 127.0.0.1 -P 1 --dualtest -L 6001 -i 1

echo "t11_tradeoff.sh port 5011"
./iperf -p 5011 -s -P 1 -i 1 -t 12 2>&1 | ./iperf -p 5011 -c 127.0.0.1 -P 1 --tradeoff -L 6002 -i 1

echo "t12_full_duplex.sh port 5012"
./iperf -p 5012 -s -P 1 -i 1 -t 12 2>&1 | ./iperf -p 5012 -c 127.0.0.1 -P 1 --full-duplex -i 1

echo "t13_reverse.sh port 5013"
./iperf -p 5013 -s -P 1 -i 1 -t 12 2>&1 | ./iperf -p 5013 -c 127.0.0.1 -P 1 --reverse -i 1

echo "t14_udp_triptimes.sh port 5014"
./iperf -p 5014 -s -P 1 -u -i 1 -t 12 2>&1 | ./iperf -p 5014 -c 127.0.0.1 -P 1 -u -b 10m -i 1 --trip-times

echo "t15_udp_enhanced.sh port 5015"
./iperf -p 5015 -s -P 1 -u -i 1 -t 12 -e 2>&1 | ./iperf -p 5015 -c 127.0.0.1 -P 1 -u -b 10m -i 1 -e

echo "t16_udp_histograms.sh port 5016"
./iperf -p 5016 -s -P 1 -u -i 1 -t 12 --histograms 2>&1 | ./iperf -p 5016 -c 127.0.0.1 -P 1 -u -b 10m -i 1 --trip-times

OS=$(uname)

if [ "QNX" = "$OS" ]; then
    echo "Start QNX specific tests..."
    echo "recv-mmsg/send-mmsg default/default 1G"
    ./iperf -u -s -i1                -t 12  2>&1 | ./iperf -u -c 127.0.0.1 -i1 -b1G
    echo "recv-mmsg/send-mmsg default/1 1G"
    ./iperf -u -s -i1                -t 12  2>&1 | ./iperf -u -c 127.0.0.1 -i1 -b1G --send-mmsg=1
    echo "recv-mmsg/send-mmsg 1/default 1G"
    ./iperf -u -s -i1 --recv-mmsg=1  -t 12  2>&1 | ./iperf -u -c 127.0.0.1 -i1 -b1G
    echo "recv-mmsg/send-mmsg 1/1 1G"
    ./iperf -u -s -i1 --recv-mmsg=1  -t 12  2>&1 | ./iperf -u -c 127.0.0.1 -i1 -b1G --send-mmsg=1
    echo "recv-mmsg/send-mmsg 2/2 1G"
    ./iperf -u -s -i1 --recv-mmsg=2  -t 12  2>&1 | ./iperf -u -c 127.0.0.1 -i1 -b1G --send-mmsg=2
    echo "recv-mmsg/send-mmsg 3/3 1G"
    ./iperf -u -s -i1 --recv-mmsg=3  -t 12  2>&1 | ./iperf -u -c 127.0.0.1 -i1 -b1G --send-mmsg=3
    echo "recv-mmsg/send-mmsg 10/10 1G"
    ./iperf -u -s -i1 --recv-mmsg=10 -t 12  2>&1 | ./iperf -u -c 127.0.0.1 -i1 -b1G --send-mmsg=10
    echo "recv-mmsg/send-mmsg 1/1 500M"
    ./iperf -u -s -i1 --recv-mmsg=1  -t 12  2>&1 | ./iperf -u -c 127.0.0.1 -i1 -b500M --send-mmsg=1
    echo "recv-mmsg/send-mmsg 2/2 500M"
    ./iperf -u -s -i1 --recv-mmsg=2  -t 12  2>&1 | ./iperf -u -c 127.0.0.1 -i1 -b500M --send-mmsg=2
    echo "recv-mmsg/send-mmsg 3/3 500M"
    ./iperf -u -s -i1 --recv-mmsg=3  -t 12  2>&1 | ./iperf -u -c 127.0.0.1 -i1 -b500M --send-mmsg=3
    echo "recv-mmsg/send-mmsg 10/5 500M"
    ./iperf -u -s -i1 --recv-mmsg=10 -t 12  2>&1 | ./iperf -u -c 127.0.0.1 -i1 -b500M --send-mmsg=5
    echo "recv-mmsg/send-mmsg 10/5 500M window 64K"
    ./iperf -u -s -w64K -i1 --recv-mmsg=10 -t 12  2>&1 | ./iperf -u -c 127.0.0.1  -w64K -i1 -b500M --send-mmsg=5
    echo "recv-mmsg/send-mmsg 10/5 10G window 64K"
    ./iperf -u -s -w64K -i1 --recv-mmsg=10 -t 12  2>&1 | ./iperf -u -c 127.0.0.1  -w64K -i1 -b10G --send-mmsg=5
else
    echo "skip QNX specific tests for $OS"
fi
