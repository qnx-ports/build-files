"""
More flexible version of bash file: "base_testsuite.sh"
"""

import os
import re
import datetime
from os.path import dirname
from ctest import is_passed
from decode_ctest import decode_ctesttestfile

RESTBED_VERSION = "4.8"

#
#    Color definition of terminal outputs
#
RED = "\033[0;31m"
GRN = "\033[0;32m"
BLU = "\033[1;34m"
CLS = "\033[0m"

def adjust_paths(cmd, prefix, patterns):
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
        #adjust to local path
        v["cmd"] = adjust_paths(
            v["cmd"],
            dirname(ctest_pathfilename),
            [
                r"^(/\S+)",
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
    export LD_LIBRARY_PATH=.:${LD_LIBRARY_PATH}
    """
    if os.environ.get("LD_LIBRARY_PATH") is not None:
        os.environ["LD_LIBRARY_PATH"] = f".:{os.environ.get('LD_LIBRARY_PATH')}"
    else:
        os.environ["LD_LIBRARY_PATH"] = "."

# Path to tests binaries e.g.: "./qnx/build/nto-x86_64-o/build/"
TEST_PATH = "./"
#TEST_PATH = "./qnx/build/nto-x86_64-o/build/"

# Match object wich used for skip test execution
skipBins = re.compile(r"(cmake|python[0-9.]*)$", re.I)

if __name__ == "__main__":
    set_env()
    print("Run test/unit")
    dlt_unit,   pass_unit,  fail_unit,  skip_unit = run_tests(
        f"{TEST_PATH}test/unit/CTestTestfile.cmake", skipBins
    )
    ALL_UNIT = pass_unit+fail_unit+skip_unit

    print("Run test/feature")
    dlt_feature, pass_feature, fail_feature, skip_feature = run_tests(
        f"{TEST_PATH}test/feature/CTestTestfile.cmake", skipBins
    )
    ALL_FEATURE = pass_feature+fail_feature+skip_feature

    print("Run test/regression")
    dlt_regression, pass_regression, fail_regression, skip_regression = run_tests(
        f"{TEST_PATH}test/regression/CTestTestfile.cmake", skipBins
    )
    ALL_REGRESSION = pass_regression+fail_regression+skip_regression

    print("Run test/integration")
    dlt_integration, pass_integration, fail_integration, skip_integration = run_tests(
        f"{TEST_PATH}test/integration/CTestTestfile.cmake", skipBins
    )
    ALL_INTEGRATION = pass_integration+fail_integration+skip_integration

    print(f"{GRN}======================================================{CLS}")
    print(f"{GRN}Tests suites summary for Restbed {RESTBED_VERSION}{CLS}")
    print(f"{GRN}======================================================{CLS}")
    print(f"# test/unit        - ALL:{ALL_UNIT} PASS:{pass_unit} FAIL:{fail_unit} SKIP:{skip_unit} [{dlt_unit}]")
    print(f"# test/feature     - ALL:{ALL_FEATURE} PASS:{pass_feature} FAIL:{fail_feature} SKIP:{skip_feature} [{dlt_feature}]")
    print(f"# test/regression  - ALL:{ALL_REGRESSION} PASS:{pass_regression} FAIL:{fail_regression} SKIP:{skip_regression} [{dlt_regression}]")
    print(f"# test/integration - ALL:{ALL_INTEGRATION} PASS:{pass_integration} FAIL:{fail_integration} SKIP:{skip_integration} [{dlt_integration}]")
    print(f"# TOTAL: {ALL_UNIT+ALL_FEATURE+ALL_REGRESSION+ALL_INTEGRATION} [{dlt_unit+dlt_feature+dlt_regression+dlt_integration}]")
    print(f"# {GRN}PASS{CLS}: {pass_unit+pass_feature+pass_regression+pass_integration}")
    print(f"# {RED}FAIL{CLS}: {fail_unit+fail_feature+fail_regression+fail_integration}")
    print(f"# {BLU}SKIP{CLS}: {skip_unit+skip_feature+skip_regression+skip_integration}")
    print(f"{GRN}======================================================{CLS}")
