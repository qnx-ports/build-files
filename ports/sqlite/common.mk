ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=sqlite
SQLITE_VERSION = 3.50.0

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

#A prefix path to use **on the target**. This is
#different from INSTALL_ROOT, which refers to a
#installation destination **on the host machine**.
#This prefix path may be exposed to the source code,
#the linker, or package discovery config files (.pc,
#CMake config modules, etc.). Default is /usr/local
PREFIX ?= /usr/local

ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install check clean

CFLAGS += $(FLAGS)

#Define _QNX_SOURCE 
CFLAGS += -D_QNX_SOURCE -O2 -fPIC
CXXFLAGS += $(CFLAGS)
LDFLAGS += -Wl,--build-id=md5

include $(MKFILES_ROOT)/qtargets.mk

$(NAME)_INSTALL_DIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)

# additional CFLAGS to set
_amalgamation=-DSQLITE_ENABLE_FTS3_PARENTHESIS \
	-DSQLITE_ENABLE_COLUMN_METADATA \
	-DSQLITE_SECURE_DELETE \
	-DSQLITE_ENABLE_UNLOCK_NOTIFY \
	-DSQLITE_ENABLE_RTREE \
	-DSQLITE_ENABLE_GEOPOLY \
	-DSQLITE_USE_URI \
	-DSQLITE_ENABLE_DBSTAT_VTAB \
	-DSQLITE_SOUNDEX \
	-DSQLITE_MAX_VARIABLE_NUMBER=250000

#Config toolchain for qnx
CONFIGURE_CMD = $(QNX_PROJECT_ROOT)/configure
CONFIGURE_ARGS = --host=$(CPU)-*-$(OS) \
                 --prefix=$(INSTALL_ROOT)/$(PREFIX)\
                 --exec-prefix=$($(NAME)_INSTALL_DIR) \
                 --enable-threadsafe \
                 --enable-session \
                 --enable-static \
                 --enable-fts3 \
                 --enable-fts4 \
                 --enable-fts5 \
                 --soname=legacy

CONFIGURE_ENVS = CFLAGS="$(CFLAGS) $(_amalgamation)" \
                 CXXFLAGS="$(CXXFLAGS)" \
                 LDFLAGS="$(LDFLAGS)" \
                 CC="${QNX_HOST}/usr/bin/qcc -Vgcc_$(OS)$(CPUVARDIR)" \
                 CXX="${QNX_HOST}/usr/bin/q++ -Vgcc_$(OS)$(CPUVARDIR)" \
                 AR="${QNX_HOST}/usr/bin/$(OS)$(CPU)-ar" \
                 AS="${QNX_HOST}/usr/bin/qcc -Vgcc_$(OS)$(CPUVARDIR)" \
                 RANDLIB="${QNX_HOST}/usr/bin/$(OS)$(CPU)-ranlib" \


MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

$(NAME)_all:
	@mkdir -p build
	@cd build && $(CONFIGURE_CMD) $(CONFIGURE_ARGS) $(CONFIGURE_ENVS)
	@cd build && make $(MAKE_ARGS)

install check: $(NAME)_all
	@echo Installing...
	@cd build && make install $(MAKE_ARGS)
	@echo Done.

clean iclean spotless:
	rm -rf build

uninstall:

