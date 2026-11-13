ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=libmodbus

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../libmodbus

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

#Set to ON to also install the test binaries, modbus-serial-probe and
#qnxtests.sh (they are always built)
BUILD_TESTING ?= OFF

ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install check clean

CFLAGS += $(FLAGS)

#_QNX_SOURCE exposes the BSD/POSIX extensions libmodbus relies on
#(TIOCMGET/TIOCM_RTS, SOCK_CLOEXEC, accept4, ...)
CFLAGS += -D_QNX_SOURCE -O2 -fPIC
LDFLAGS += -Wl,--build-id=md5

include $(MKFILES_ROOT)/qtargets.mk

$(NAME)_INSTALL_DIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)
$(NAME)_TESTS_DIR=$($(NAME)_INSTALL_DIR)/bin/$(NAME)_tests

QCC = $(QNX_HOST)/usr/bin/qcc -Vgcc_$(OS)$(CPUVARDIR)

#Config toolchain for qnx.
#configure.ac matches host_os against *nto-qnx* and then links -lsocket.
CONFIGURE_CMD = $(QNX_PROJECT_ROOT)/configure
CONFIGURE_ARGS = --host=$(CPU)-unknown-nto-qnx \
                 --prefix=$(INSTALL_ROOT)/$(PREFIX) \
                 --exec-prefix=$($(NAME)_INSTALL_DIR) \
                 --srcdir=$(QNX_PROJECT_ROOT) \
                 --enable-shared \
                 --disable-static
CONFIGURE_ENVS = CFLAGS="$(CFLAGS)" \
                 LDFLAGS="$(LDFLAGS)" \
                 CC="$(QCC)" \
                 AR="$(QNX_HOST)/usr/bin/$(OS)$(CPU)-ar" \
                 RANLIB="$(QNX_HOST)/usr/bin/$(OS)$(CPU)-ranlib" \
                 STRIP="$(QNX_HOST)/usr/bin/$(OS)$(CPU)-strip"

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

#Test programs built by libmodbus (tests/Makefile.am, noinst_PROGRAMS)
TEST_PROGRAMS = unit-test-server unit-test-client \
                random-test-server random-test-client \
                bandwidth-server-one bandwidth-server-many-up bandwidth-client \
                proxy-test-server proxy-test-client \
                version

$(NAME)_all:
	@mkdir -p build
	@if [ ! -x $(QNX_PROJECT_ROOT)/configure ]; then cd $(QNX_PROJECT_ROOT) && ./autogen.sh; fi
	@cd build && if [ ! -f Makefile ]; then $(CONFIGURE_ENVS) $(CONFIGURE_CMD) $(CONFIGURE_ARGS); fi
	@grep -q -- "-lsocket" build/src/Makefile || { echo "ERROR: configure did not detect QNX (no -lsocket)"; exit 1; }
	@cd build && $(MAKE) $(MAKE_ARGS)
	$(QCC) $(CFLAGS) -I$(QNX_PROJECT_ROOT)/src -Ibuild/src \
		$(PROJECT_ROOT)/probe/modbus-serial-probe.c \
		-Lbuild/src/.libs -lmodbus -o build/modbus-serial-probe

install check: $(NAME)_all
	@echo Installing...
	@cd build && $(MAKE) install $(MAKE_ARGS)
ifeq ($(BUILD_TESTING),ON)
	@mkdir -p $($(NAME)_TESTS_DIR)
	@for t in $(TEST_PROGRAMS); do \
		if [ -f build/tests/.libs/$$t ]; then cp build/tests/.libs/$$t $($(NAME)_TESTS_DIR)/; \
		else cp build/tests/$$t $($(NAME)_TESTS_DIR)/; fi; \
	done
	@cp build/modbus-serial-probe $($(NAME)_TESTS_DIR)/
	@cp $(PROJECT_ROOT)/qnxtests.sh $($(NAME)_TESTS_DIR)/
endif
	@echo Done.

clean iclean spotless:
	rm -rf build

uninstall:
