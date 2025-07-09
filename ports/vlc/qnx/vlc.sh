#!/bin/sh
dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)

LD_LIBRARY_PATH=${dir}/../lib:${LD_LIBRARY_PATH} \
VLC_LIB_PATH=${dir}/../lib/vlc \
VLC_DATA_PATH=${dir}/../share \
${dir}/vlc $*

