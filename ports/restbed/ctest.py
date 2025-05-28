"""
CTests basic output parser
"""

import subprocess
import re
import os

#remove colorized of outputs
ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')

def match_re(str_re, stdout, stderr):
    #print(str_re)
    out = stdout + stderr
    return re.search(str_re, out) is not None

def clean_back_slash(_str):
    result = _str.replace("\\\\", "\\")
    result = result.replace('\\"', '"')
    return result

def is_passed(_cmd, _pass_re=None, _fail_re=None, _will_fail=False, _env=None):
    """
    Execute tests and parse output, checks exitcode, setups ENVIRONMENT
        _cmd: command with parameters.
        _pass_re: regexp to pars output.
            CTest property: PASS_REGULAR_EXPRESSION

        _fail_re: regexp to pars output.
            CTest property: FAIL_REGULAR_EXPRESSION

        _will_fail: If true, inverts the pass / fail test criteria.
            CTest property: WILL_FAIL

        _env: Specify environment variables that should be defined for running a test.
            CTest property: ENVIRONMENT "MYVAR1=value1;MYVAR2=value2"
    """

    if _env is not None:
        cust_env = dict(e.split("=") for e in _env.split(";"))
        _env = os.environ.copy()
        _env.update(cust_env)

    #
    #   Adjust backslash
    #
    _cmd = [_cmd[0]] + [ clean_back_slash(i) for i in _cmd[1:]] #skip first item: path to executable

    comp_proc = subprocess.run(
        _cmd, capture_output=True, shell=False, text=True, env=_env, check=False
    )

    status_str = ""
    passed = False

    if _fail_re is not None: #FAIL_REGULAR_EXPRESSION takes precedence over PASS_REGULAR_EXPRESSION
        _fail_re = clean_back_slash(_fail_re)
        if match_re(_fail_re, comp_proc.stdout, comp_proc.stderr):
            status_str = f"FAIL_REGULAR_EXPRESSION:{_fail_re} was matched"
            passed = False
        else:
            status_str = f"FAIL_REGULAR_EXPRESSION:{_fail_re} was not matched"
            passed = True
    elif _pass_re is not None: #PASS_REGULAR_EXPRESSION takes precedence over return code
        _pass_re = clean_back_slash(_pass_re)
        if match_re(_pass_re, comp_proc.stdout, comp_proc.stderr):
            status_str = f"PASS_REGULAR_EXPRESSION:{_pass_re} was matched"
            passed = True
        else:
            status_str = f"PASS_REGULAR_EXPRESSION:{_pass_re} was not matched"
            passed = False
    else:
        status_str = f"Return code: {comp_proc.returncode}"
        passed = 0 == comp_proc.returncode

    if _will_fail:
        if passed:
            status_str = f"WILL_FAIL expects failed test, but {status_str}"
            passed = False
        else:
            status_str = "WILL_FAIL inverts the status"
            passed = True

    if passed:
        status_str = f"PASS - {status_str}"
    else:
        status_str = f"FAIL - {status_str}"

    return passed, status_str, comp_proc.stdout, comp_proc.stderr, _cmd

if __name__ == "__main__":
    test_list_0 = [
        {
            "name": "Test color output",
            "cmd": ["ls", "-l", "--color"],
            #"cmd": ["ls", "-l"],
            "pass": ".*domusers"
        }
    ]
    for v in test_list_0:
        passed, err_str, out, err, cmd = is_passed(
                    v.get("cmd"),
                    v.get("pass"),
                    v.get("fail"),
                    v.get("will_fail", False),
                    v.get("env")
                )

        print( f"{passed and 'PASS' or 'FAIL'}:{v.get('name', 'noname test')} : {err_str}")
        print(err_str)
        print(f"\tCMD:{' '.join(cmd)}")
        if not passed:
            print(out)
            print(err)

    unittests_list = [
        {
            "name": "Code(0) patter(<undef>) --  expected  true",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh"],
            "env": "PR_CODE=0",
        },
        {
            "name": "Code(2) patter(<undef>) --  expected false",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh"],
            "env": "PR_CODE=2",
        },
        {
            "name": "Code(0) patter(Failed:fAiLeD Ok) --  expected false",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh"],
            "fail": "fAiLeD\\s+Ok",
            "env": "PR_STR=fAiLeD Ok;PR_CODE=0",
        },
        {
            "name": "Code(1) patter(Failed:fAiLeD Ok) --  expected false",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh"],
            "fail": "fAiLeD\\s+Ok",
            "env": "PR_STR=fAiLeD Ok;PR_CODE=1",
        },
        {
            "name": "Code(0) patter(Passed:Passed 12) --  expected  true",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh"],
            "pass": "Passed\\s+\\d+",
            "env": "PR_STR=Passed 12;PR_CODE=0",
        },
        {
            "name": "Code(1) patter(Passed:Passed 12) --  expected  true",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh"],
            "pass": "Passed \\d\\d",
            "env": "PR_STR=Passed 12;PR_CODE=1",
        },
        {
            "name": "Code(0) patter(Passed-yes and Failed) --  expected  true",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh"],
            "pass": "Passed\\s+\\d+",
            "fail": "fAiLeD\\s+Ok",
            "env": "PR_STR=Passed 12;PR_CODE=0",
        },
        {
            "name": "Code(0) patter(Passed and Failed-yes) --  expected false",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh"],
            "pass": "Passed\\s+\\d+",
            "fail": "fAiLeD\\s+Ok",
            "env": "PR_STR=fAiLeD Ok;PR_CODE=0",
        },
        {
            "name": "Code(1) patter(Passed-yes and Failed) --  expected  true",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh"],
            "pass": "Passed\\s+\\d+",
            "fail": "fAiLeD\\s+Ok",
            "env": "PR_STR=Passed 12;PR_CODE=1",
        },
        {
            "name": "Code(1) patter(Passed and Failed-yes) --  expected false",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh"],
            "pass": "Passed\\s+\\d+",
            "fail": "fAiLeD\\s+Ok",
            "env": "PR_STR=fAiLeD Ok;PR_CODE=1",
        },
        {
            "name": "Will failed Code(0) patter(<undef>) --  expected false",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh"],
            "env": "PR_CODE=0",
            "will_fail": True,
        },
        {
            "name": "Will failed Code(2) patter(<undef>) --  expected  true",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh"],
            "env": "PR_CODE=2",
            "will_fail": True,
        },
        {
            "name": "Will failed Code(0) patter(Failed:fAiLeD Ok) --  expected  true",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh"],
            "fail": "fAiLeD\\s+Ok",
            "env": "PR_STR=fAiLeD Ok;PR_CODE=0",
            "will_fail": True,
        },
        {
            "name": "Will failed Code(1) patter(Failed:fAiLeD Ok) --  expected  true",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh"],
            "fail": "fAiLeD\\s+Ok",
            "env": "PR_STR=fAiLeD Ok;PR_CODE=1",
            "will_fail": True,
        },
        {
            "name": "Will failed Code(0) patter(Passed:Passed 12) --  expected false",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh"],
            "pass": "Passed\\s+\\d+",
            "env": "PR_STR=Passed 12;PR_CODE=0",
            "will_fail": True,
        },
        {
            "name": "Will failed Code(1) patter(Passed:Passed 12) --  expected false",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh"],
            "pass": "Passed \\d\\d",
            "env": "PR_STR=Passed 12;PR_CODE=1",
            "will_fail": True,
        },
        {
            "name": "Will failed Code(0) patter(Passed-yes and Failed) --  expected false",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh"],
            "pass": "Passed\\s+\\d+",
            "fail": "fAiLeD\\s+Ok",
            "env": "PR_STR=Passed 12;PR_CODE=0",
            "will_fail": True,
        },
        {
            "name": "Will failed Code(0) patter(Passed and Failed-yes) --  expected  true",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh", "-help", 'Tata Matata'],
            "pass": "Passed\\s+\\d+",
            "fail": "fAiLeD\\s+Ok",
            "env": "PR_STR=fAiLeD Ok;PR_CODE=0",
            "will_fail": True,
        },
        {
            "name": "Will failed Code(1) patter(Passed-yes and Failed) --  expected false",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh"],
            "pass": "Passed\\s+\\d+",
            "fail": "fAiLeD\\s+Ok",
            "env": "PR_STR=Passed 12;PR_CODE=1",
            "will_fail": True,
        },
        {
            "name": "Will failed Code(1) patter(Passed and Failed-yes) --  expected  true",
            "cmd": ["./qnx/test/if_PR1_0_or_1.sh"],
            "pass": "Passed\\s+\\d+",
            "fail": "fAiLeD\\s+Ok",
            "env": "PR_STR=fAiLeD Ok;PR_CODE=1",
            "will_fail": True,
        },
    ]

    for v in unittests_list:
        passed, err_str, out, err, cmd = is_passed(
                    v.get("cmd"),
                    v.get("pass"),
                    v.get("fail"),
                    v.get("will_fail", False),
                    v.get("env"),
                )
        print( f"{passed and 'PASS' or 'FAIL'}:{v.get('name', 'noname test')} : {err_str}")
        print(err_str)
        print(f"\tCMD:{' '.join(cmd)}")
        if not passed:
            print(out)
            print(err)
