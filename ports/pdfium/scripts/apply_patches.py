#!/usr/bin/env python3

"""
apply_patches.py -- utility for applying normal patches for QNX
"""

import json
import logging
from pathlib import Path
import os
import subprocess
import sys


_THIS_DIR = os.path.abspath(os.path.dirname(__file__))
_ROOT_DIR = Path(__file__).parents[4]

sys.path.insert(0, os.path.join(_ROOT_DIR, "third_party/depot_tools"))


class GitError(Exception):
    pass


def ExecutGitCommand(directory, command):
    command = ["git"] + command
    try:
        logging.info("Executing '%s' in %s", " ".join(command), directory)
        proc = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            cwd=directory,
            shell=False,
        )
        stdout, stderr = tuple(x.decode(encoding="utf_8") for x in proc.communicate())
        stdout = stdout.strip()
        stderr = stderr.strip()
        logging.debug("returncode: %d", proc.returncode)
        logging.debug("stdout: %s", stdout)
        logging.debug("stderr: %s", stderr)
        if proc.returncode != 0:
            raise GitError(
                (
                    "Git command '{}' in {} failed: " "rc={}, stdout='{}' stderr='{}'"
                ).format(" ".join(command), directory, proc.returncode, stdout, stderr)
            )
        return stdout
    except OSError as e:
        raise GitError(
            "Git command 'git {}' in {} failed: {}".format(
                " ".join(command), directory, e
            )
        )


def AppplyPaches(patch_dir):
    files = [
        f for f in os.listdir(patch_dir) if os.path.isfile(os.path.join(patch_dir, f))
    ]

    patch_files = [f for f in files if f.endswith(".patch")]
    patch_files.sort()
    meta_files = [f for f in files if f.endswith(".meta")]
    with open(os.path.join(patch_dir, meta_files[0]), "r") as j:
        data = json.load(j)
    repo_path = data["path"]
    head = ExecutGitCommand(repo_path, ["log", "-1", "--format=format:%H", "--grep", "\[QNX Base]"]).strip()

    result = ExecutGitCommand(repo_path, ["status", ".", "-uno"])
    if "nothing to commit" not in result:
        logging.warning("%s: the local repo is not clean.", repo_path)
        return -1

    result = ExecutGitCommand(repo_path, ["rev-parse", "HEAD"]).strip()
    if result != head:
        logging.warning(
            "%s: unexpected haad sha, have patches been applied already?", repo_path
        )
        return -1

    for f in patch_files:
        ExecutGitCommand(repo_path, ["-c", "user.name=dummy", "-c", "user.email=donotreply@dummy.com", "am", os.path.join(patch_dir, f)])

def main(argv=None):
    logging.basicConfig(level=logging.WARNING)

    os.chdir(_ROOT_DIR)
    patches_dir = os.path.dirname(_THIS_DIR)
    patches_dir = os.path.join(patches_dir, "patches/pdfium")
    AppplyPaches(patches_dir)

if __name__ == "__main__":
    sys.exit(main())
