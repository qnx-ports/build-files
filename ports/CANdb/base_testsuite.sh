#!/bin/sh

#
#    Color definition of terminal outputs
#
red="\033[0;31m"
grn="\033[0;32m"
cls="\033[0m"

### Setup env for proper running tests ###
export LD_LIBRARY_PATH=./lib:${LD_LIBRARY_PATH}

### Find all unittests ###
unittests_list=$(find . -type f -name '*_tests')

### Run all unittests ###
ut_pass=0
ut_fail=0
number=0
for v in ${unittests_list}; do
   number=$((number+1))
   ${v}
   if [ 0 -eq $? ]; then
      ut_pass=$((ut_pass+1))
      echo "${grn}PASS${cls}:${v}"
   else
      ut_fail=$((ut_fail+1))
      echo "${red}FAIL${cls}:${v}"
   fi
done

echo "${grn}==========================================${cls}"
echo "${grn}Tests suites summary for CANdb${cls}"
echo "${grn}==========================================${cls}"
echo "# TOTAL: ${number}"
echo "# ${grn}PASS${cls}: ${ut_pass}"
echo "# ${red}FAIL${cls}: ${ut_fail}"
echo "${grn}==========================================${cls}"
