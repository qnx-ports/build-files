# NO HASH-BANG here

#export X_XE_DEST="quser@172.16.175.130"

# remove comment for debugging the configure process:
#export X_XE_DEBUG=1

PREF=/usr
set -x
export BUILDBIN=`pwd`/buildtools/bin
if [ -z $(which waf) ]; then
	if [ -d $BUILDBIN -a -x ${BUILDBIN}/waf ]; then
		export PATH=$PATH:$BUILDBIN
	else
		echo "trouble finding where 'waf' lives ... fix me!"
		exit
	fi
fi

export STAGE=${INSTALL_ROOT_nto:-$(dirname $QCONF_OVERRIDE)/nto}

# when run on Jenkins, we want to install in a different place than on the
# desktop (where we don't want to overwrite our SDP installation)
if [ -n "${JENKINS_URL}" ]; then
	export PKG_QNX_PATH=${QNX_TARGET}
else
	export PKG_QNX_PATH=${STAGE}
fi

export DESTDIR=${STAGE}/x86_64/
export LIBRARY_PATH_OPTS="-L${QNX_TARGET}/x86_64/usr/lib -L${QNX_TARGET}/x86_64/usr/local/lib -L${STAGE}/x86_64/usr/lib -L${STAGE}/usr/lib"
export SMB_LDFLAGS="${LIBRARY_PATH_OPTS} -lsocket -lcrypto -lnettle -lhogweed -lgmp -lregex -lfsnotify -Wl,--build-id=md5"
export SMB_CFLAGS="-I${QNX_TARGET}/usr/include -I${STAGE}/usr/include -D__QNXNTO__ -D__USESRCVERSION"

# this is needed to locate 'native' (ie, linux) binaries for heimdal
export NATIVE_HEIMDAL_PATH=$(realpath $(dirname $0))

OPTIONS="--without-ldb-lmdb --without-winbind --without-ads --without-pam \
--without-quotas --without-dmapi --without-regedit --disable-glusterfs \
--disable-cephfs --disable-spotlight --without-systemd --without-lttng \
--without-ad-dc --fatal-errors --without-libarchive --without-ntvfs-fileserver \
--disable-python --without-json --disable-rpath --without-ldap --with-gpfs=no \
--cross-compile --enable-fhs \
--hostcc=gcc --cross-answers=$(dirname $(dirname $0))/config/x_config_answers.txt --prefix=$PREF"
