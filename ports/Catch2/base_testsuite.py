"""
More flexible version of bash file: "base_testsuite.sh"
"""

import os
import re
import datetime
from ctest import is_passed
from decode_ctest import decode_ctesttestfile

CATCH2_VERSION = "3.6.0"

#
#    Color definition of terminal outputs
#
RED = "\033[0;31m"
GRN = "\033[0;32m"
BLU = "\033[1;34m"
CLS = "\033[0m"

def adjust_pathes(cmd, prefix, patterns):
    """
    TODO
    """
    result = []

    for i in cmd:
        matched = False
        for pattern in patterns:
            m = re.search(pattern, i)
            if m:
                matched = True
                count = len(m.groups())
                if 2 == count:
                    #pattern has to have two groupes \1 is a prefix part which has to be exchanged by 'prefix'
                    #\2 is a main part which has to be reused
                    result.append(re.sub(pattern, f"\\1{prefix}\\2", i))
                    #result.append(f"{prefix}/{m.group(2)}")
                elif 1 == count:
                    result.append(f"{prefix}{m.group(1)}")
                elif 0 == count:
                    result.append(f"{prefix}{pattern}")
                break
        if not matched:
            result.append(i)
    return result

def run_tests(ctest_pathfilename, skip_re_match):
    """
    Read CTestTestfile.cmake file and run tests defined in it
    """
    # collect all tests information and build list of dictionary with proper information
    ut_tests = decode_ctesttestfile(ctest_pathfilename).values()

    # adjust all pathes to relative deployment on tagret
    for v in ut_tests:
        #adjust system binaries like python
        v["cmd"] = adjust_pathes(
            v["cmd"],
            '',
            [
                r"^/[-a-zA-Z0-9/_]+(python\d*)",
                r"^/[-a-zA-Z0-9/_]+(cmake)",
            ]
        )
        #adjust to local path
        v["cmd"] = adjust_pathes(
            v["cmd"],
            './',
            [
                r"^[-a-zA-Z0-9/_]+/tests/(SelfTest)",
                r"tests/ExtraTests/(\S+)",
                r"^[-a-zA-Z0-9/_]+(tests/TestScripts/\S+\.py)",
                r"^[-a-zA-Z0-9/_]+(tools/scripts/\S+\.py)",
                r"^\s*(-[-\w]+\s)\s*\S+(Misc/[-\w]+\.input)",
                r"^[-a-zA-Z0-9/_]+/(tests)$",
                r"^[-a-zA-Z0-9/_]+/(tests/ExtraTests)$",
            ]
        )

    ut_pass = 0
    ut_fail = 0
    ut_skip = 0

    dt_begin = datetime.datetime.now()
    for v in ut_tests:

        if skip_re_match.search(v["cmd"][0]) is not None:
            ut_skip += 1
            print(f"{BLU}SKIP{CLS}:{v['name']}")
            print(f"\tCMD:'{' '.join(v['cmd'])}'")
            continue

        _ok, _str, _out, _err, _cmd = is_passed(
            v.get("cmd"),
            v.get("pass"),
            v.get("fail"),
            v.get("will_fail", False),
            v.get("env"),
        )

        if _ok:
            ut_pass += 1
            print(f"{GRN}PASS{CLS}:{v['name']}")
        else:
            ut_fail += 1
            print(f"{RED}FAIL{CLS}:{v['name']}")
            print(_str)
            print(f"\tCMD:{' '.join(_cmd)}")
            print(f"\tDict:{v}")
            print(_out)
            print(_err)
    dlt = datetime.datetime.now() - dt_begin
    return dlt, ut_pass, ut_fail, ut_skip


def set_env():
    """
    Setup env for proper running tests
    export LD_LIBRARY_PATH=./lib:${LD_LIBRARY_PATH}
    """
    if os.environ.get("LD_LIBRARY_PATH") is not None:
        os.environ["LD_LIBRARY_PATH"] = f"./lib:{os.environ.get('LD_LIBRARY_PATH')}"
    else:
        os.environ["LD_LIBRARY_PATH"] = "./lib"

# Path to tests binaries e.g.: "./qnx/build/nto-x86_64-o/build/"
TEST_PATH = "./"
#TEST_PATH = "./qnx/build/nto-x86_64-o/build/"

# Match object wich used for skip test execution
skipBins = re.compile(r"(cmake|python[0-9.]*)$", re.I)

if __name__ == "__main__":
    set_env()
    dlt_main,   pass_main,  fail_main,  skip_main = run_tests(
        f"{TEST_PATH}tests/CTestTestfile.cmake",
        skipBins
    )
    print("Extra tests")
    dlt_extra, pass_extra, fail_extra, skip_extra = run_tests(
        f"{TEST_PATH}tests/ExtraTests/CTestTestfile.cmake", skipBins
    )
    print(f"{GRN}======================================================{CLS}")
    print(f"{GRN}Tests suites summary for Catch2 {CATCH2_VERSION}{CLS}")
    print(f"{GRN}======================================================{CLS}")
    print(f"# MAIN  Tests - ALL:{pass_main+fail_main+skip_main} PASS:{pass_main} FAIL:{fail_main} SKIP:{skip_main} [{dlt_main}]")
    print(f"# EXTRA Tests - ALL:{pass_extra+fail_extra+skip_extra} PASS:{pass_extra} FAIL:{fail_extra} SKIP:{skip_extra} [{dlt_extra}]")
    print(f"# TOTAL: {pass_main+fail_main+skip_main+pass_extra+fail_extra+skip_extra} [{dlt_main+dlt_extra}]")
    print(f"# {GRN}PASS{CLS}: {pass_main+pass_extra}")
    print(f"# {RED}FAIL{CLS}: {fail_main+fail_extra}")
    print(f"# {BLU}SKIP{CLS}: {skip_main+skip_extra}")
    print(f"{GRN}======================================================{CLS}")
