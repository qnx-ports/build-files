#!/bin/bash

build_dir=`pwd`
project_dir=$1
target_dir=$2

exec &> llama-test.sh

ctest -N -V | awk -v bdir=$build_dir -v tdir=$target_dir -v pdir=$project_dir '
BEGIN {
    print "#/bin/sh\n\n"
    print "LD_LIBRARY_PATH=`pwd`/bin\n"
    print "exec 3>&1"
    print "exec >llama-test.log 2>&1\n"
    print "total=0"
    print "passed=0\n"
}
/^[0-9]+: Test command: / {
    gsub(/^[0-9]+: Test command: /, "", $0);
    #print $0
    gsub(bdir "/", "", $0) 
    gsub(tdir "/", "", $0)
    gsub(pdir "/", "", $0)
    testcmd = $0
}
/Test\W+#/ {
    gsub(/^\W+/, "", $0)
    print "echo " "\""$0"\""
    print "echo -n " "\""$0"\": >&3"
    print testcmd
    print "if [ $? -eq 0 ]; then"
    print "    echo passed >&3"
    print "    ((passed++))"
    print "else"
    print "    echo failed >&3"
    print "fi"
    print "((total++))\n"
    testcmd = ""
}
END {
    print "echo Total test: $total >&3"
    print "echo Passed: $passed >&3"
}
'
