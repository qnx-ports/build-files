#! /bin/bash

export PKG_CONFIG_PATH=${QNX_TARGET_SYS_DIR}/lib/pkgconfig
exec pkg-config --define-prefix "$@"