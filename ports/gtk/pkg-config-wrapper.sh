#!/usr/bin/env bash

export PKG_CONFIG_PATH=
export PKG_CONFIG_LIBDIR=${INSTALL_ROOT_WITH_PREFIX}/lib/pkgconfig

PKG_CONFIG_FLAGS=(
  --define-prefix
  # Used by .pc files that wrap libraries shipped with QNX
  --define-variable=qnx_target=${QNX_TARGET}
  --define-variable=cpu_dir=${CPUVARDIR}
)

exec pkg-config "${PKG_CONFIG_FLAGS[@]}" "$@"
