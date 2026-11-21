ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=net-snmp

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../net-snmp

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

#A prefix path to use **on the target**. This is
#different from INSTALL_ROOT, which refers to a
#installation destination **on the host machine**.
#Default is /usr/local
PREFIX ?= /usr/local

#Where the tools keep persistent state (engine boots, keys made by snmpusm) on the target
PERSISTENT_DIR ?= /data/var/net-snmp

ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install check clean

CFLAGS += $(FLAGS)

#_QNX_SOURCE exposes the BSD/POSIX extensions net-snmp relies on
CFLAGS += -D_QNX_SOURCE -O2 -fPIC
#source file names in assertion messages without the build host's folders
CFLAGS += -ffile-prefix-map=$(QNX_PROJECT_ROOT)=net-snmp
#regcomp() and friends live in libregex on QNX; configure adds -lregex to LIBS
#but not to the libraries' own link line (LNETSNMPLIBS), and libnetsnmp is
#linked with -no-undefined
LDFLAGS += -Wl,--build-id=md5 -lregex

include $(MKFILES_ROOT)/qtargets.mk

$(NAME)_INSTALL_DIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)

QCC = $(QNX_HOST)/usr/bin/qcc -Vgcc_$(OS)$(CPUVARDIR)

#Config toolchain for qnx.
#Library, command-line tools (snmpget, snmpwalk, snmpset, snmptrap, ...) and
#snmptrapd. The agent (snmpd) is left out: some of its default MIB modules
#use BSD kernel interfaces QNX does not have. --without-kmem-usage because
#QNX 8.0 has kvm_openfiles()/kvm_read() in libsocket, no libkvm and no
#kvm_open(), and configure only looks in libkvm (net-snmp#1176 fixes this
#and the -lregex link on master). SNMPv3 security through the SDP's
#OpenSSL 3 (USM with HMAC-SHA-2 and AES-128). The standard MIB files are
#installed under $(PREFIX)/share/snmp/mibs.
#net-snmp compiles its MIB, configuration and persistent-state paths into the
#library, so configure with the paths on the target and redirect only the
#installation (prefix and exec_prefix given to make install).
CONFIGURE_CMD = $(QNX_PROJECT_ROOT)/configure
CONFIGURE_ARGS = --host=$(CPU)-unknown-nto-qnx8.0.0 \
                 --prefix=$(PREFIX) \
                 --exec-prefix=$(PREFIX) \
                 --srcdir=$(QNX_PROJECT_ROOT) \
                 --with-defaults \
                 --with-default-snmp-version=3 \
                 --disable-agent \
                 --without-kmem-usage \
                 --disable-embedded-perl \
                 --without-perl-modules \
                 --disable-manuals \
                 --disable-scripts \
                 --with-openssl=$(QNX_TARGET)/usr \
                 --with-logfile=none \
                 --with-persistent-directory=$(PERSISTENT_DIR) \
                 --enable-shared \
                 --disable-static
CONFIGURE_ENVS = CFLAGS="$(CFLAGS)" \
                 LDFLAGS="$(LDFLAGS)" \
                 CC="$(QCC)" \
                 AR="$(QNX_HOST)/usr/bin/$(OS)$(CPU)-ar" \
                 RANLIB="$(QNX_HOST)/usr/bin/$(OS)$(CPU)-ranlib" \
                 STRIP="$(QNX_HOST)/usr/bin/$(OS)$(CPU)-strip"

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

$(NAME)_all:
	@mkdir -p build
	@cd build && if [ ! -f Makefile ]; then $(CONFIGURE_ENVS) $(CONFIGURE_CMD) $(CONFIGURE_ARGS); fi
	@cd build && $(MAKE) $(MAKE_ARGS)

#Install into build/stage with DESTDIR, then copy: headers and MIBs to
#$(INSTALL_ROOT), programs and libraries to the CPU folder. Installing with
#other prefix/exec_prefix values would make libtool relink snmptrapd and
#libnetsnmptrapd with the host install folder in their RPATH.
#Install runs serially: libtool relinks libnetsnmptrapd during install, and
#a parallel make links snmptrapd against it while it is being rewritten.
install check: $(NAME)_all
	@echo Installing...
	@rm -rf build/stage
	@cd build && $(MAKE) install DESTDIR=$(CURDIR)/build/stage
	@mkdir -p $(INSTALL_ROOT)/$(PREFIX) $($(NAME)_INSTALL_DIR)
	@cp -R build/stage/$(PREFIX)/include build/stage/$(PREFIX)/share $(INSTALL_ROOT)/$(PREFIX)/
	@cp -R -P build/stage/$(PREFIX)/bin build/stage/$(PREFIX)/sbin build/stage/$(PREFIX)/lib $($(NAME)_INSTALL_DIR)/
	@echo Done.

clean iclean spotless:
	rm -rf build

uninstall:
