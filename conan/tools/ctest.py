"""
Fix absolute paths in CTestTestfile.cmake before run ctest
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

def commonsuffixpath(paths):

    parts_list = [[i for i in path.split(os.sep) if 0<len(i)] for path in paths]

    node = ""
    index = -1
    suffix = []
    stop = False
    while not stop:
        for parts in parts_list:
            if 0 >= len(parts)+index+1:
                stop = True
                break
            if 0 == len(node):
                node = parts[index]
            else:
                if node != parts[index]:
                    stop = True
                    break
                else:
                    continue
        if not stop:
            if 0 < len(node):
                suffix.append(node)
                node = ""
                index -= 1
            else:
                stop = True
    suffix.reverse()
    return os.sep.join(suffix)

if __name__ == "__main__":

    ROOT_FN = "CTestTestfile.cmake"

    ctestfilelist = [f"{root}/{ROOT_FN}" for root, dirs, files in os.walk('.') if f"{ROOT_FN}" in files ]
    root_ctestfilelist = ""
    for fn in ctestfilelist:
        print(f"Find {fn} try to fix absolute paths...")

        fin = open(fn, mode="r")
        all_lines = fin.readlines()
        fin.close()

        root_ctestfilelist = os.path.dirname(os.path.abspath(fn))


        src, bld = GetPaths(all_lines)
        if 0 == len(src):
            print("Error: cannot find source path")
            continue
        if 0 == len(bld):
            print("Error: cannot find build path")
            continue
        pyp = GetPythonPath(all_lines)

        com_suffix = commonsuffixpath([bld,root_ctestfilelist])
        if 0 == len(com_suffix):
            print("Error: cannot find common suffix between real and original build paths")
            continue

        com_part = os.path.commonpath([src, bld])
        if 0 == len(com_part):
            print("Error: cannot find common prefix between source and build paths")
            continue

        new_com_part = root_ctestfilelist[:root_ctestfilelist.rfind(com_suffix)].rstrip(os.sep)
        if 0 == len(new_com_part):
            print("Error: cannot detect new common prefix")
            print("No needs to adjusting process")
            continue

        new_src = src.replace(com_part, new_com_part, 1)
        new_bld = bld.replace(com_part, new_com_part, 1)
        print(f"    Old Source path:{src}")
        print(f"    Old Build  path:{bld}")
        print(f"    New Source path:{new_src}")
        print(f"    New Build  path:{new_bld}")

        print(f"Backup original file {fn} to {fn+'.bak'}")
        os.rename(fn, fn+".bak")
        print("Fix all pathes...")
        fout = open(fn, mode="w")
        for l in all_lines:
            l = l.replace(com_part,new_com_part)
            if 0 < len(pyp):
                l = l.replace(pyp,"python")
            fout.write(l)
        fout.close()
