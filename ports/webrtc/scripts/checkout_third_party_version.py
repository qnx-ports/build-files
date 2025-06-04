#!/usr/bin/env python3

"""
generate_patches.py -- utility for checking out specific commit
"""

import argparse
import json
import logging
from pathlib import Path
import os
import subprocess
import sys
import tempfile

_THIS_DIR = os.path.abspath(os.path.dirname(__file__))
_ROOT_DIR = Path(__file__).parents[4]

sys.path.insert(0, os.path.join(_ROOT_DIR, "third_party/depot_tools"))


def main(argv=None):
    logging.basicConfig(level=logging.WARNING)
    parser = argparse.ArgumentParser()
    parser.add_argument("--path", help="Path to the target repository.")
    parser.add_argument("--sha", help="Sha to checkout.")
    parser.add_argument("--message", help="Message to add")
    args = parser.parse_args()

    os.chdir(_ROOT_DIR)
    dep_path = os.path.join(_ROOT_DIR, "DEPS")
    command = ["gclient", "getdep", "-r", args.path, "--deps-file", dep_path]
    result = subprocess.run(
        command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True
    )
    if result.returncode != 0:
        raise Exception(result.stderr)
    head = result.stdout.strip()
    if head == args.sha:
        return 0

    os.chdir(os.path.join(os.path.dirname(_ROOT_DIR), args.path))
    command = ["git", "checkout", args.sha]
    result = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True,
    )
    if result.returncode != 0:
        raise Exception(result.stderr)

    os.chdir(_ROOT_DIR)

    command = [
        "gclient",
        "setdep",
        "-r",
        f"{args.path}@{args.sha}",
        "--deps-file",
        dep_path,
    ]
    result = subprocess.run(
        command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True
    )
    if result.returncode != 0:
        raise Exception(result.stderr)

    command = ["git", "add", "DEPS"]
    result = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True,
    )
    if result.returncode != 0:
        raise Exception(result.stderr)

    command = [
        "git",
        "-c",
        "user.name=dummy",
        "-c",
        "user.email=donotreply@dummy.com",
        "commit",
        "--author=dummy <>",
        "DEPS",
        "-m",
        f"[QNX LOCAL AUTOGEN] Checkout {args.path}@{args.sha}\n\n{args.message}\n\nDo not push this commit; keep it local!",
    ]
    result = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True,
    )
    if result.returncode != 0:
        raise Exception(result.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
