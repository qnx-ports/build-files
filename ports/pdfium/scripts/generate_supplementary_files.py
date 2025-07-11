#!/usr/bin/env python3

"""
generate_patches.py -- utility for generating QNX build structure
"""

import logging
from pathlib import Path
import os
import shutil
import sys

_THIS_DIR = os.path.abspath(os.path.dirname(__file__))
_ROOT_DIR = Path(__file__).parents[4]


def main(argv=None):
    logging.basicConfig(level=logging.WARNING)

    qnx_dir = os.path.dirname(_THIS_DIR)
    cpu_dirs = [
        os.path.basename(d)
        for d in os.listdir(qnx_dir)
        if os.path.isdir(d) and os.path.basename(d).startswith("nto-")
    ]

    if cpu_dirs:
        return 0

    qnx_sdp_root = os.getenv("QNX_TARGET")
    if not qnx_sdp_root:
        raise Exception(
            "QNX SDP environment variables not set, please run qnxsdp-env.sh first"
        )

    usr_inc_path = os.path.join(qnx_sdp_root, "usr/include")

    root_make_file_path = os.path.join(_ROOT_DIR, "Makefile")
    if not os.path.isfile(root_make_file_path):
        with open(root_make_file_path, "a") as file:
            file.write(
                "ifndef QRECURSE\nQRECURSE=recurse.mk\nifdef QCONFIG\nQRDIR=$(dir $(QCONFIG))\nendif\nendif\ninclude $(QRDIR)$(QRECURSE)\n"
            )

    cpu_endians = ["nto-aarch64-le", "nto-x86_64-o"]
    for cpu in cpu_endians:
        variant_path = os.path.join(qnx_dir, cpu)
        if not os.path.isdir(variant_path):
            os.makedirs(variant_path)
            with open(os.path.join(variant_path, "Makefile"), "a") as file:
                file.write("include ../common.mk\n")
    out_dir = os.path.join(_ROOT_DIR, "out")
    obj = Path(out_dir)
    if obj.exists() and not obj.is_symlink():
        if obj.is_file():
            os.remove(out_dir)
        elif obj.is_dir():
            shutil.rmtree(out_dir)
    if not obj.exists():
        os.symlink(qnx_dir, out_dir)
    return 0


if __name__ == "__main__":
    sys.exit(main())
