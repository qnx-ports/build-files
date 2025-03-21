"""
Decoding CTests from CMakeLists.txt
"""

import re
import sys

'''
    group(1) is test name
    group(2) is the rest of string
'''
name_add_test = re.compile(r'add_test\s*\(\s*([^\s]+)(.*)')

'''
    group(1) is option content
    group(2) is the rest of string
'''
arg = re.compile(r'\s+"(.*?[^\\])"(.*)')

def add_test(ln):
    name = ""
    cmd = []
    m = name_add_test.search(ln)
    if m is not None:
        name = m.group(1)
        rest = m.group(2)
        m = arg.search(rest)
        while m is not None:
            cmd.append(m.group(1))
            rest = m.group(2)
            m = arg.search(rest)
    return name, cmd

'''
    group(1) is test name
'''
name_set_tests_properties = re.compile(r'set_tests_properties\s*\(\s*([^\s]+)')

'''
    group(1) is property content
'''
property_pass      = re.compile(r'PASS_REGULAR_EXPRESSION\s+"((.*\n?)*?.*?[^\\])"')
property_fail      = re.compile(r'FAIL_REGULAR_EXPRESSION\s+"((.*\n?)*?.*?[^\\])"')
property_will_fail = re.compile(r'WILL_FAIL\s+"(.*?[^\\])"')
property_env       = re.compile(r'ENVIRONMENT\s+"(.*?[^\\])"')


#multiline regex PASS_REGULAR_EXPRESSION\s+\"((.*\n?)*?)\"
def set_tests_properties(ln):
    _name = ""
    _pass = None
    _fail = None
    _will_fail =False
    _env = None

    m = name_set_tests_properties.search(ln)
    if m is not None:
        _name = m.group(1)
    m = property_pass.search(ln)
    if m is not None:
        _pass = m.group(1)
    m = property_fail.search(ln)
    if m is not None:
        _fail = m.group(1)
    m = property_will_fail.search(ln)
    if m is not None:
        _will_fail = True
    m = property_env.search(ln)
    if m is not None:
        _env = m.group(1)
    return _name, _pass, _fail, _will_fail, _env

begin_of_function = re.compile(r'\s*\w+\(')
end_of_function = re.compile(r'\)\s*\n')

def consolidate_functions(_file):
    result = []
    begin_was_found = False
    buf = ""
    for line in _file:
        #print(line)
        if begin_was_found:
            buf +=line
            if end_of_function.search(line) is not None:
                begin_was_found = False
                #print(f'BUFF>{buf}<BUFF')
                result.append(buf)
                buf = ""
        elif begin_of_function.search(line) is not None:
            buf = line
            begin_was_found = True
            if end_of_function.search(line) is not None:
                begin_was_found = False
                #print(f'BUFF>{buf}<BUFF')
                result.append(buf)
                buf = ""
    return result

def decode_ctesttestfile(fn):
    tests_list = {}
    f = open(fn)
    func_list = consolidate_functions(f)
    f.close()
    for line in func_list:
        _name, _cmd = add_test(line)
        if 0 < len(_name) and  0 < len(_cmd):
            tests_list[_name] = {"name": _name, "cmd" : _cmd}
            continue
        _name, _pass, _fail, _will_fail, _env = set_tests_properties(line)
        if _name in tests_list:
            tests_list[_name].update({"pass": _pass, "fail": _fail, "will_fail": _will_fail, "env": _env})
    return tests_list

if __name__ == "__main__":
    print(sys.argv)
    if 1<len(sys.argv):
        filename = sys.argv[1]
        print(f"Start decoding file:{filename}")
        tests_dict = decode_ctesttestfile(filename).values()
        for i in tests_dict:
            print(i)
    else:
        print("Error: missed filename parameter")
