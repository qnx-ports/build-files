"""
Adjust absolute paths in CTestTestfile.cmake to relative paths
"""

import re
import os

def GetPaths(lines):
    source_path = ""
    build_path = ""
    source_ptrn = re.compile(r'Source\s+directory\s*:\s*(/[-/\w\.]+)', re.IGNORECASE)
    build_ptrn = re.compile(r'Build\s+directory\s*:\s*(/[-/\w\.]+)', re.IGNORECASE)
    for l in lines:
        if 0 == len(source_path):
            m = source_ptrn.search(l)
            if None != m:
                source_path = m.group(1)
        if 0 == len(build_path):
            m = build_ptrn.search(l)
            if None != m:
                build_path = m.group(1)
        if len(source_path)>0 and len(build_path)>0:
            break
    return source_path, build_path

def GetPythonPath(lines):
    python_path = ""
    python_ptrn = re.compile(r'"(([\s]*python|.*/python)(\d+\.?\d*)?)"', re.IGNORECASE)
    for l in lines:
        if 0 == len(python_path):
            m = python_ptrn.search(l)
            if None != m:
                python_path = m.group(1)
                break
    return python_path

if __name__ == "__main__":

    ROOT_FN = "CTestTestfile.cmake"

    ctestfilelist = [f"{root}/{ROOT_FN}" for root, dirs, files in os.walk('.') if f"{ROOT_FN}" in files ]
    for fn in ctestfilelist:
        print(f"Find {fn} try to fix absolute paths...")

        fin = open(fn, mode="r")
        all_lines = fin.readlines()
        fin.close()

        src, bld = GetPaths(all_lines)
        pyp = GetPythonPath(all_lines)

        print(f"    Source path:{src}")
        print(f"    Build  path:{bld}")
        print(f"    Python path:{pyp}")

        if 0 == len(src) or 0 == len(bld):
            print("Error: cannot find absolute paths")
            continue

        com_part = os.path.commonpath([src, bld])

        strip_src = src.replace(com_part, "")
        strip_bld = bld.replace(com_part, "")
        split_bld = [i for i in strip_bld.split(os.sep) if len(i) >0]

        level = len(split_bld)
        rel = os.sep.join([".."] * level)
        rel_src = rel + strip_src
        rel_bld = rel + strip_bld
        rel_pyp = "python"
        print(f"    Source  new:{rel_src}")
        print(f"    Build   new:{rel_bld}")
        print(f"    Python  new:{rel_pyp}")

        print(f"Backup original file {fn} to {fn+'.bak'}")
        os.rename(fn, fn+".bak")
        print("Fix all pathes...")
        fout = open(fn, mode="w")
        for l in all_lines:
            if 0 < len(com_part):
                l = l.replace(com_part,rel)
            if 0 < len(pyp):
                l = l.replace(pyp,rel_pyp)
            fout.write(l)
        fout.close()
