"""
Fix absolute paths in CTestTestfile.cmake before run ctest
"""

import re
import os

"""
replace all oldstr string to the newstr one in file
"""
def replaceinfile(oldstr, newstr, fileName):
    try:
        with open(fileName, 'r', encoding='utf-8') as f:
            filedata = f.read()
    except Exception:
        print(f"WRONG file format: {fileName}")
        return

    filedata = filedata.replace(oldstr, newstr)

    with open(fileName, 'w', encoding='utf-8') as f:
        f.write(filedata)

"""
extract actual python path from file
"""
def getpythonpath(filename):
    python_path = ""
    python_ptrn = re.compile(r'(([\s]*python|/[\w/]*/python)(\d+\.?\d*)?)"', re.IGNORECASE)
    with open(filename, 'r', encoding='utf-8') as f:
        for l in f.readlines():
            m = python_ptrn.search(l)
            if None is not m:
                python_path = m.group(1)
                break
    return python_path

"""
extract source and build paths from file
"""
def getpaths(filename):
    source_path = ""
    build_path = ""
    source_ptrn = re.compile(r'Source\s+directory\s*:\s*(/[-/\w\.]+)', re.IGNORECASE)
    build_ptrn = re.compile(r'Build\s+directory\s*:\s*(/[-/\w\.]+)', re.IGNORECASE)
    with open(filename, 'r', encoding='utf-8') as f:
        for l in f.readlines():
            if 0 == len(source_path):
                m = source_ptrn.search(l)
                if None is not m:
                    source_path = m.group(1)
            if 0 == len(build_path):
                m = build_ptrn.search(l)
                if None is not m:
                    build_path = m.group(1)
            if len(source_path)>0 and len(build_path)>0:
                break
    return source_path, build_path

"""
return path to the top CTestTestfile.cmake
"""
def getrootCTestTestfile(root):
    l = [os.path.join(r, "CTestTestfile.cmake") for r,d,f in os.walk(root) if "CTestTestfile.cmake" in f]
    rootCTest = ""
    for nextCTestFile in l:
        if len(rootCTest) == 0:
            rootCTest = nextCTestFile
        elif len(rootCTest) > len(nextCTestFile):
            rootCTest = nextCTestFile
    return rootCTest

"""
build dict with pairs (pattern->list of paths)
"""
def getfilesmap(root, glob):
    res = {}
    for ent in glob:
        res[ent] = [os.path.join(r, file) for r,d,f in os.walk(root) for file in f if file.endswith(ent)]
    return res

"""
fix python path to the specified pythonname in file
"""
def fixpythonname(pythonname, files):
    for f in files:
        oldpythonname = getpythonpath(f)
        if len(oldpythonname)>0:
            replaceinfile(oldpythonname, pythonname, f)

"""
fix oldpath to newpath in file
"""
def fixpaths(oldpath, newpath, files):
    for f in files:
        replaceinfile(oldpath, newpath, f)

if __name__ == "__main__":
    currentpath = os.getcwd()
    src, bld = getpaths(getrootCTestTestfile(currentpath))
    commonpath = os.path.commonpath([src, bld])
    glob = ["CTestTestfile.cmake", ".cmake", ".tcl", ".txt", ".yaml"]
    filesmap = getfilesmap(currentpath, glob)

    print(f"Fix python paths in CTestTestfile.cmake [{len(filesmap['CTestTestfile.cmake'])}]")
    fixpythonname("python3", filesmap["CTestTestfile.cmake"])

    print(f"Fix src/build paths in *.cmake [{len(filesmap['.cmake'])}]")
    fixpaths(commonpath, currentpath, filesmap[".cmake"])

    print(f"Fix src/build paths in *.tcl [{len(filesmap['.tcl'])}]")
    fixpaths(commonpath, currentpath, filesmap[".tcl"])

    print(f"Fix src/build paths in *.txt [{len(filesmap['.txt'])}]")
    fixpaths(commonpath, currentpath, filesmap[".txt"])

    print(f"Fix src/build paths in *.yaml [{len(filesmap['.yaml'])}]")
    fixpaths(commonpath, currentpath, filesmap[".yaml"])
