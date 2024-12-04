#!/bin/sh

# see cmake/execute_test.cmake on test setup
export FLAGS_undefok="foo,bar"
export FLAGS_weirdo=""
export FLAGS_version="true"
export FLAGS_help="false"

# special test
echo "TEST: gflags_declare"
result=$(./gflags_declare_test --message "Hello gflags!")
# expect Hello gflags!" in output
if [ "$result" = "Hello gflags!" ]; then
    echo "QNXPASS"
else
    overall_rc=1
    echo "QNXFAIL"
fi

# add_gflags_test tests
# WARNING: won't work for regex inputs
overall_rc=0

total_tests=$((0))
total_passed=$((0))
total_failed=$((0))

add_gflags_test(){
    typeset name=$1
    shift
    typeset expected_rc=$1
    shift
    typeset expected_out=$1
    shift
    typeset unexpected_out=$1
    shift
    typeset cmd=$1
    shift
    typeset cmd="./$cmd --test_tmpdir=. --srcdir=. $@ 2>&1"

    echo 
    echo "TEST: $name"
    echo "running command: $cmd"
    output=$(eval $cmd)
    rc=$?
    # echo "result: $result"
    echo "rc: $rc"

    if [ "$rc" != "$expected_rc" ]; then
        echo "QNXFAIL: expected rc = $expected_rc. got rc = $rc"
        overall_rc=1
        total_tests=$(($total_tests+1))
        total_failed=$(($total_failed+1))
        return
    else
        echo "QNXPASS: expected rc = $expected_rc. got rc = $rc"
        total_tests=$(($total_tests+1))
        total_passed=$(($total_passed+1))
    fi

    if [ "$expected_out" != "" ]; then
        case "$output" in
            *"$expected_out"*) echo "QNXPASS: \"$expected_out\" in out"  ; total_tests=$(($total_tests+1));total_passed=$(($total_passed+1));;
            *)                   echo "QNXFAIL: \"$expected_out\" not in \"$output\""; overall_rc=1; total_tests=$(($total_tests+1));total_failed=$(($total_failed+1));return 
        esac
    fi

    if [ "$unexpected_out" != "" ]; then
        case "$output" in
            *"$unexpected_out"*) echo "QNXFAIL: \"$unexpected_out\" in \"$output\""; overall_rc=1;total_tests=$(($total_tests+1));total_failed=$(($total_failed+1)); return  ;;
            *)                     echo "QNXPASS: \"$unexpected_out\" in out"; total_tests=$(($total_tests+1));total_passed=$(($total_passed+1))
        esac
    fi
}

# below tests are copied form test/CMakeLists.txt

SLASH="/"

# First, just make sure the  gflags_unittest  works as-is
add_gflags_test unittest 0 "" "" gflags_unittest

# --help should show all flags, including flags from gflags_reporting
add_gflags_test help-reporting 1 "${SLASH}gflags_reporting.cc:" ""  gflags_unittest  --help

# Make sure that --help prints even very long helpstrings.
add_gflags_test long-helpstring 1 "end of a long helpstring" ""  gflags_unittest  --help

# Make sure --help reflects flag changes made before flag-parsing
add_gflags_test changed_bool1 1 "-changed_bool1 (changed) type: bool default: true" ""  gflags_unittest  --help
add_gflags_test changed_bool2 1 "-changed_bool2 (changed) type: bool default: false currently: true" ""  gflags_unittest  --help
# And on the command-line, too
add_gflags_test changeable_string_var 1 "-changeable_string_var () type: string default: \"1\" currently: \"2\"" ""  gflags_unittest  --changeable_string_var 2 --help

# --nohelp and --help=false should be as if we didn't say anything
add_gflags_test nohelp     0 "PASS" ""  gflags_unittest  --nohelp
add_gflags_test help=false 0 "PASS" ""  gflags_unittest  --help=false

# --helpful is the same as help
add_gflags_test helpful 1 "${SLASH}gflags_reporting.cc:" ""  gflags_unittest  --helpful

# --helpshort should show only flags from the  gflags_unittest  itself
add_gflags_test helpshort 1 "${SLASH}gflags_unittest.cc:" "${SLASH}gflags_reporting.cc:"  gflags_unittest  --helpshort

# --helpshort should show the tldflag we created in the  gflags_unittest  dir
add_gflags_test helpshort-tldflag1 1 "tldflag1" "${SLASH}google.cc:"  gflags_unittest  --helpshort
add_gflags_test helpshort-tldflag2 1 "tldflag2" "${SLASH}google.cc:"  gflags_unittest  --helpshort

# --helpshort should work if the main source file is suffixed with [_-]main
add_gflags_test helpshort-main 1 "${SLASH}gflags_unittest-main.cc:" "${SLASH}gflags_reporting.cc:" gflags_unittest-main --helpshort
add_gflags_test helpshort_main 1 "${SLASH}gflags_unittest_main.cc:" "${SLASH}gflags_reporting.cc:" gflags_unittest_main --helpshort

# --helpon needs an argument
add_gflags_test helpon 1 "'--helpon' is missing its argument; flag description: show help on" ""  gflags_unittest  --helpon
# --helpon argument indicates what file we'll show args from
add_gflags_test helpon=gflags 1 "${SLASH}gflags.cc:" "${SLASH}gflags_unittest.cc:"  gflags_unittest  --helpon=gflags
# another way of specifying the argument
add_gflags_test helpon_gflags 1 "${SLASH}gflags.cc:" "${SLASH}gflags_unittest.cc:"  gflags_unittest  --helpon gflags
# test another argument
add_gflags_test helpon=gflags_unittest 1 "${SLASH}gflags_unittest.cc:" "${SLASH}gflags.cc:"  gflags_unittest  --helpon=gflags_unittest

# helpmatch is like helpon but takes substrings
add_gflags_test helpmatch_reporting 1 "${SLASH}gflags_reporting.cc:" "${SLASH}gflags_unittest.cc:"  gflags_unittest  -helpmatch reporting
add_gflags_test helpmatch=unittest  1 "${SLASH}gflags_unittest.cc:" "${SLASH}gflags.cc:"  gflags_unittest  -helpmatch=unittest

# if no flags are found with helpmatch or helpon, suggest --help
add_gflags_test helpmatch=nosuchsubstring 1 "No modules matched" "${SLASH}gflags_unittest.cc:"  gflags_unittest  -helpmatch=nosuchsubstring
add_gflags_test helpon=nosuchmodule       1 "No modules matched" "${SLASH}gflags_unittest.cc:"  gflags_unittest  -helpon=nosuchmodule

# helppackage shows all the flags in the same dir as this unittest
# --help should show all flags, including flags from google.cc
add_gflags_test helppackage 1 "${SLASH}gflags_reporting.cc:" ""  gflags_unittest  --helppackage

# xml!
add_gflags_test helpxml 1 "${SLASH}gflags_unittest.cc</file>" "${SLASH}gflags_unittest.cc:"  gflags_unittest  --helpxml

# just print the version info and exit
add_gflags_test version-1 0 "gflags_unittest"      "${SLASH}gflags_unittest.cc:"  gflags_unittest  --version
add_gflags_test version-2 0 "version test_version" "${SLASH}gflags_unittest.cc:"  gflags_unittest  --version

# --undefok is a fun flag...
add_gflags_test undefok-1 1 "unknown command line flag 'foo'" ""  gflags_unittest  --undefok= --foo --unused_bool
add_gflags_test undefok-2 0 "PASS" ""  gflags_unittest  --undefok=foo --foo --unused_bool
# If you say foo is ok to be undefined, we'll accept --nofoo as well
add_gflags_test undefok-3 0 "PASS" ""  gflags_unittest  --undefok=foo --nofoo --unused_bool
# It's ok if the foo is in the middle
add_gflags_test undefok-4 0 "PASS" ""  gflags_unittest  --undefok=fee,fi,foo,fum --foo --unused_bool
# But the spelling has to be just right...
add_gflags_test undefok-5 1 "unknown command line flag 'foo'" ""  gflags_unittest  --undefok=fo --foo --unused_bool
add_gflags_test undefok-6 1 "unknown command line flag 'foo'" ""  gflags_unittest  --undefok=foot --foo --unused_bool

# See if we can successfully load our flags from the flagfile
add_gflags_test flagfile.1 0 "gflags_unittest" "${SLASH}gflags_unittest.cc:"  gflags_unittest  "--flagfile=flagfile.1"
add_gflags_test flagfile.2 0 "PASS" ""  gflags_unittest  "--flagfile=flagfile.2"
add_gflags_test flagfile.3 0 "PASS" ""  gflags_unittest  "--flagfile=flagfile.3"

# Also try to load flags from the environment
add_gflags_test fromenv=version      0 "gflags_unittest" "${SLASH}gflags_unittest.cc:"  gflags_unittest  --fromenv=version
add_gflags_test tryfromenv=version   0 "gflags_unittest" "${SLASH}gflags_unittest.cc:"  gflags_unittest  --tryfromenv=version
add_gflags_test fromenv=help         0 "PASS" ""  gflags_unittest  --fromenv=help
add_gflags_test tryfromenv=help      0 "PASS" ""  gflags_unittest  --tryfromenv=help
add_gflags_test fromenv=helpful      1 "helpful not found in environment" ""  gflags_unittest  --fromenv=helpful
add_gflags_test tryfromenv=helpful   0 "PASS" ""  gflags_unittest  --tryfromenv=helpful
add_gflags_test tryfromenv=undefok   0 "PASS" ""  gflags_unittest  --tryfromenv=undefok --foo
add_gflags_test tryfromenv=weirdo    1 "unknown command line flag" ""  gflags_unittest  --tryfromenv=weirdo
add_gflags_test tryfromenv-multiple  0 "gflags_unittest" "${SLASH}gflags_unittest.cc:"  gflags_unittest  --tryfromenv=test_bool,version,unused_bool
add_gflags_test fromenv=test_bool    1 "not found in environment" ""  gflags_unittest  --fromenv=test_bool
add_gflags_test fromenv=test_bool-ok 1 "unknown command line flag" ""  gflags_unittest  --fromenv=test_bool,ok
# Here, the --version overrides the fromenv
add_gflags_test version-overrides-fromenv 0 "gflags_unittest" "${SLASH}gflags_unittest.cc:"  gflags_unittest  --fromenv=test_bool,version,ok

# Make sure -- by itself stops argv processing
add_gflags_test dashdash 0 "PASS" ""  gflags_unittest  -- --help

# And we should die if the flag value doesn't pass the validator
add_gflags_test always_fail 1 "ERROR: failed validation of new value 'true' for flag 'always_fail'" ""  gflags_unittest  --always_fail

echo "Summary: TESTS RUN: $total_tests | PASS: $total_passed | FAIL: $total_failed"

exit $overall_rc
