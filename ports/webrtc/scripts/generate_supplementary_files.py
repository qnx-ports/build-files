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

    has_iopkt = os.path.isdir(os.path.join(usr_inc_path, "io-pkt"))
    has_iosock = os.path.isdir(os.path.join(usr_inc_path, "io-sock"))
    has_ioaudio = os.path.isfile(os.path.join(usr_inc_path, "sys/asound.h"))
    has_iosnd = os.path.isdir(os.path.join(usr_inc_path, "alsa"))

    root_make_file_path = os.path.join(_ROOT_DIR, "Makefile")
    if not os.path.isfile(root_make_file_path):
        with open(root_make_file_path, "a") as file:
            file.write(
                "ifndef QRECURSE\nQRECURSE=recurse.mk\nifdef QCONFIG\nQRDIR=$(dir $(QCONFIG))\nendif\nendif\ninclude $(QRDIR)$(QRECURSE)\n"
            )

    cpu_endians = ["nto-aarch64-le", "nto-x86_64-o"]
    net_variants = []
    if has_iopkt is True:
        net_variants.append("iopkt")
    if has_iosock is True:
        net_variants.append("iosock")
    if not net_variants:
        raise Exception("No socket libirary found")
    audio_variants = []
    if has_ioaudio is True:
        audio_variants.append("ioaudio")
    if has_iosnd is True:
        audio_variants.append("iosnd")
    if not audio_variants:
        raise Exception("No audio libirary found")
    for cpu in cpu_endians:
        for net_var in net_variants:
            for audio_var in audio_variants:
                variant = cpu + "-" + net_var + "-" + audio_var
                variant_path = os.path.join(qnx_dir, variant)
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
