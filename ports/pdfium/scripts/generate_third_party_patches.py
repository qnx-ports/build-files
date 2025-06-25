#!/usr/bin/env python3

"""
generate_patches.py -- utility for generating QNX-specific patches
"""

import json
import logging
from pathlib import Path
import os
import shutil
import subprocess
import sys
import tempfile

_THIS_DIR = os.path.abspath(os.path.dirname(__file__))
_ROOT_DIR = Path(__file__).parents[4]

sys.path.insert(0, os.path.join(_ROOT_DIR, "third_party/depot_tools"))


class GitError(Exception):
    pass


def GeneratePaches(patch_dir, repo_dir, sha):
    repo_dir_flat = repo_dir.replace("/", "_")
    output_dir = os.path.join(patch_dir, repo_dir_flat)
    os.makedirs(output_dir)
    data = {'path': repo_dir}
    with open(os.path.join(output_dir, repo_dir_flat + '.meta'), 'w') as f:
        json.dump(data, f)
    # git format-patch HEAD~${COUNT} -o ${OUTPUT_DIR}/${DIR_NAME}
    command = ["git", "format-patch", "-N", sha, "-o", output_dir]
    result = subprocess.run(
        command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True
    )
    if result.returncode != 0:
        raise Exception(result.stderr)
    return 0

def GenerateLabeledPaches(patch_dir, sha):
    output_dir = os.path.join(patch_dir, 'pdfium')
    output_dir2 = os.path.join(patch_dir, 'pdfium2')
    os.makedirs(output_dir)
    os.makedirs(output_dir2)
    data = {'path': '.'}
    with open(os.path.join(output_dir, 'pdfium.meta'), 'w') as f:
        json.dump(data, f)
    with open(os.path.join(output_dir2, 'pdfium2.meta'), 'w') as f:
        json.dump(data, f)

    command = ["git", "log",  "--format=format:%H", "--grep", "\[QNX LOCAL PATCH]", "--reverse"]
    result = subprocess.run(
        command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True
    )
    if result.returncode != 0:
        raise Exception(result.stderr)
    labeledshas = result.stdout.strip()

    command = ["git", "log",  "--format=format:%H", "--grep", "\[QNX LOCAL AUTOGEN]", "--reverse"]
    result = subprocess.run(
        command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True
    )
    if result.returncode != 0:
        raise Exception(result.stderr)
    autogenshas = result.stdout.strip()

    command = ["git", "rev-list", "--reverse", sha + '..HEAD']
    result = subprocess.run(
        command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True
    )
    if result.returncode != 0:
        raise Exception(result.stderr)
    shas = result.stdout.strip()

    if not shas:
        return 0;
    shas = shas.split("\n")
    i = 0
    j = 0
    for sha in shas:
        if sha in labeledshas:
            j += 1
            command = ["git", "format-patch", "-k", sha, "-1", "--start-number", str(j), "-o", output_dir2]
        elif sha not in autogenshas:
            i += 1
            command = ["git", "format-patch", sha, "-1", "--start-number", str(i), "-o", output_dir]
        result = subprocess.run(
            command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True
        )
        if result.returncode != 0:
            raise Exception(result.stderr)
    return 0

def main(argv=None):
    logging.basicConfig(level=logging.WARNING)

    os.chdir(_ROOT_DIR)

    temp_patch_dir = tempfile.TemporaryDirectory()
    repos = [os.path.dirname(f) for f in Path(".").rglob(".git") if f.is_dir()]
    for repo in repos:
        if (not repo):
            command = ["git", "log", "-1", "--format=format:%H", "--grep", "\[QNX Base]"]
            result = subprocess.run(
                command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True
            )
            if result.returncode != 0:
                raise Exception(result.stderr)
            GenerateLabeledPaches(temp_patch_dir.name, result.stdout.strip())
            continue
        if (
            repo == "qnx_build"
            or repo == "third_party/dragonbox/src"
            or repo == "third_party/llvm-libc/src"
            or repo == "third_party/highway/src"
            or repo == "third_party/simdutf"
        ):
            continue
        repo = repo.strip()
        command = [
            "gclient",
            "getdep",
            "-r",
            repo,
            "--deps-file",
            os.path.join(_ROOT_DIR, "DEPS"),
        ]
        result = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
        )
        if result.returncode != 0:
            raise Exception(result.stderr)
        sync_sha = result.stdout.strip()
        os.chdir(os.path.join(_ROOT_DIR, repo))
        command = ["git", "cat-file", "-e", sync_sha]
        result = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
        )
        if result.returncode != 0:
            raise Exception(result.stderr)
        if result.stdout.strip():
            raise Exception(
                "The base object: " + sync_sha + " was not found from " + repo
            )
        command = ["git", "rev-parse", "HEAD"]
        result = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
        )
        if result.returncode != 0:
            raise Exception(result.stderr)
        if result.stdout.strip() == sync_sha:
            continue
        GeneratePaches(temp_patch_dir.name, repo, sync_sha)

    os.chdir(_ROOT_DIR)

    patches_dir = os.path.dirname(_THIS_DIR)
    patches_dir = os.path.join(patches_dir, "patches")
    for f in os.listdir(patches_dir):
        fpath = os.path.join(patches_dir, f)
        if os.path.isdir(fpath):
            shutil.rmtree(fpath)
        else:
            os.remove(fpath)
    Path(os.path.join(patches_dir, "Makefile.dnm")).touch()

    file_names = os.listdir(temp_patch_dir.name)
    for file_name in file_names:
        shutil.move(os.path.join(temp_patch_dir.name, file_name), patches_dir)
    temp_patch_dir.cleanup()

    return 0


if __name__ == "__main__":
    sys.exit(main())
