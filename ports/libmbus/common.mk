ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=libmbus

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../libmbus

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

#Set to ON to also install the frame-parsing test programs and frames
#(mbus_parse_hex, generate-xml.sh, test-frames/ ...)
BUILD_TESTING ?= OFF

ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install check clean

CFLAGS += $(FLAGS)
CFLAGS += -D_QNX_SOURCE -O2 -fPIC
CFLAGS += -ffile-prefix-map=$(QNX_PROJECT_ROOT)=libmbus
LDFLAGS += -Wl,--build-id=md5
#socket(), connect() and getaddrinfo() are in libsocket on QNX; configure.ac
#does not look for it, and the library is linked with -no-undefined
MBUS_LIBS = -lsocket

include $(MKFILES_ROOT)/qtargets.mk

$(NAME)_INSTALL_DIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)
$(NAME)_TESTS_DIR=$($(NAME)_INSTALL_DIR)/bin/$(NAME)_tests

QCC = $(QNX_HOST)/usr/bin/qcc -Vgcc_$(OS)$(CPUVARDIR)

#Config toolchain for qnx.
#The git tree has no configure script: it is generated once with autoreconf
#(the qnx-ports Docker image has autotools). The m4 folder that configure.ac
#names is not in git, and aclocal treats its absence as an error.
CONFIGURE_CMD = $(QNX_PROJECT_ROOT)/configure
CONFIGURE_ARGS = --host=$(CPU)-unknown-nto-qnx8.0.0 \
                 --prefix=$(INSTALL_ROOT)/$(PREFIX) \
                 --exec-prefix=$($(NAME)_INSTALL_DIR) \
                 --srcdir=$(QNX_PROJECT_ROOT) \
                 --enable-shared \
                 --disable-static
CONFIGURE_ENVS = CFLAGS="$(CFLAGS)" \
                 LDFLAGS="$(LDFLAGS)" \
                 LIBS="$(MBUS_LIBS)" \
                 CC="$(QCC)" \
                 AR="$(QNX_HOST)/usr/bin/$(OS)$(CPU)-ar" \
                 RANLIB="$(QNX_HOST)/usr/bin/$(OS)$(CPU)-ranlib" \
                 STRIP="$(QNX_HOST)/usr/bin/$(OS)$(CPU)-strip"

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

$(NAME)_all:
	@mkdir -p build
	@if [ ! -x $(QNX_PROJECT_ROOT)/configure ]; then cd $(QNX_PROJECT_ROOT) && mkdir -p m4 && autoreconf -fi; fi
	@cd build && if [ ! -f Makefile ]; then $(CONFIGURE_ENVS) $(CONFIGURE_CMD) $(CONFIGURE_ARGS); fi
	@cd build && $(MAKE) $(MAKE_ARGS)
	@cd build && $(MAKE) -C test $(MAKE_ARGS) mbus_parse mbus_parse_hex

install check: $(NAME)_all
	@echo Installing...
	@cd build && $(MAKE) install $(MAKE_ARGS)
ifeq ($(BUILD_TESTING),ON)
	@mkdir -p $($(NAME)_TESTS_DIR)
	@cp build/test/.libs/mbus_parse build/test/.libs/mbus_parse_hex $(QNX_PROJECT_ROOT)/test/generate-xml.sh $($(NAME)_TESTS_DIR)/
	@cp -r $(QNX_PROJECT_ROOT)/test/test-frames $(QNX_PROJECT_ROOT)/test/error-frames $(QNX_PROJECT_ROOT)/test/unsupported-frames $($(NAME)_TESTS_DIR)/
	@cp $(PROJECT_ROOT)/qnxtests.sh $($(NAME)_TESTS_DIR)/
endif
	@echo Done.

clean iclean spotless:
	rm -rf build

uninstall:
