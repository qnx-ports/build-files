#!/usr/bin/env python3

"""
generate_patches.py -- utility for collecting necessary headers
"""

import json
import logging
from pathlib import Path
import os
import subprocess
import sys

_THIS_DIR = os.path.abspath(os.path.dirname(__file__))
_ROOT_DIR = Path(__file__).parents[4]


def main(argv=None):
    logging.basicConfig(level=logging.WARNING)

    qnx_dir = os.path.dirname(_THIS_DIR)
    public_dir = os.path.join(qnx_dir, "public")
    if os.path.isdir(public_dir):
        return 0

    os.chdir(_ROOT_DIR)

    dirs = [
        "common_audio/include",
        "media/base",
        "media/engine",
        "modules/audio_coding/include",
        "modules/audio_device/include",
        "modules/audio_processing/include",
        "modules/congestion_controller/include",
        "modules/include",
        "modules/rtp_rtcp/include",
        "modules/rtp_rtcp/source",
        "modules/utility/include",
        "modules/video_coding/codecs/h264/include",
        "modules/video_coding/codecs/vp8/include",
        "modules/video_coding/codecs/vp9/include",
        "modules/video_coding/include",
        "pc",
        "rtc_base",
        "system_wrappers/include",
    ]
    output_headers = []
    for dir in dirs:
        headers = [f for f in os.listdir(dir) if f.endswith(".h")]
        for header in headers:
            relative_path = os.path.join(dir, header)
            command = [
                "g++",
                "-M",
                "-I",
                "./",
                "-I",
                "./third_party/abseil-cpp",
                relative_path,
            ]
            result = subprocess.run(
                command,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                universal_newlines=True,
            )
            pos = result.stdout.find(os.path.join(dir, header))
            dep_headers = result.stdout[pos:]
            dep_headers = dep_headers.replace(" \\", "")
            dep_headers = dep_headers.replace("\n", " ")
            dep_headers = dep_headers.split(" ")
            dep_headers = [f.strip() for f in dep_headers if f.strip()]
            dep_headers = [f for f in dep_headers if not f.startswith("/")]
            output_headers = list(set(output_headers + dep_headers))

    os.makedirs(public_dir, exist_ok=True)

    parent_dirs = list(set([os.path.dirname(d) for d in output_headers]))
    for d in parent_dirs:
        os.makedirs(os.path.join(public_dir, d), exist_ok=True)

    for f in output_headers:
        os.symlink(os.path.join(_ROOT_DIR, f), os.path.join(public_dir, f))
    return 0


if __name__ == "__main__":
    sys.exit(main())
