#!/usr/bin/env bash

if [[ -z $1 ]]; then
        echo "please specify a command for 'waf', eg 'configure', 'build', 'wafdocs', 'dist' ... "
        exit 1
fi
CMD=$1
shift

. $(realpath $(dirname $0))/samba_common_settings.sh

PKG_CONFIG_PATH=${PKG_QNX_PATH}/x86_64/usr/lib/pkgconfig \
	CC=ntox86_64-gcc \
	LDFLAGS="${SMB_LDFLAGS}" \
	CFLAGS="${SMB_CFLAGS}" \
	waf $CMD $OPTIONS  $*
