ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=icu

ICU_VERSION = 76.1

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))
ICU_INSTALL_ROOT ?= $(INSTALL_ROOT)
TEST_INSTALL_DIR=$(ICU_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin/icu_tests

#A prefix path to use **on the target**. This is
#different from INSTALL_ROOT, which refers to a
#installation destination **on the host machine**.
#This prefix path may be exposed to the source code,
#the linker, or package discovery config files (.pc,
#CMake config modules, etc.). Default is /usr/local
PREFIX ?= /usr/local

#choose Release or Debug
MAKE_BUILD_TYPE ?= Release
MAKE_BUILD_TEST ?= false

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install check clean

CFLAGS += $(FLAGS) -D_QNX_SOURCE -O3
LDFLAGS += -Wl,--build-id=md5 -Wl,--allow-shlib-undefined

include $(MKFILES_ROOT)/qtargets.mk

#Set config flags
CFLAGS += -fPIC
CXXFLAGS += $(CFLAGS) -std=gnu++17

#Default toolchain for linux (required by icu)
CONFIGURE_CMD = $(QNX_PROJECT_ROOT)/icu4c/source/runConfigureICU Linux 
CONFIGURE_ARGS =
CONFIGURE_ENVS = CXXFLAGS=-std=gnu++17

# config tasks
TEST_BUILD_CMD = echo "No test will be built"
TEST_INSTALL_CMD = echo "No test will be installed"
BIN_INSTALL_CMD = echo "Skip installation"

ifeq ($(OS), nto)
    #Config toolchain for qnx
    CONFIGURE_CMD = $(QNX_PROJECT_ROOT)/icu4c/source/configure
    CONFIGURE_ARGS = --host=$(CPU)-*-$(OS) \
                     --prefix=$(ICU_INSTALL_ROOT)/$(PREFIX) \
                     --exec-prefix=$(ICU_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX) \
                     --with-cross-build=$(PWD)/../linux-x86_64-o/build \
                     --with-data-packaging=auto \
                     --srcdir=$(QNX_PROJECT_ROOT)/icu4c/source
    CONFIGURE_ENVS = CFLAGS="$(CFLAGS)" \
                     CXXFLAGS="$(CXXFLAGS)" \
                     LDFLAGS="$(LDFLAGS)" \
                     CC="${QNX_HOST}/usr/bin/qcc -Vgcc_$(OS)$(CPUVARDIR)" \
                     CXX="${QNX_HOST}/usr/bin/q++ -Vgcc_$(OS)$(CPUVARDIR)" \
                     AR="${QNX_HOST}/usr/bin/$(OS)$(CPU)-ar" \
                     AS="${QNX_HOST}/usr/bin/qcc -Vgcc_$(OS)$(CPUVARDIR)" \
                     RANDLIB="${QNX_HOST}/usr/bin/$(OS)$(CPU)-ranlib" \

    BIN_INSTALL_CMD = make VERBOSE=1 install $(MAKE_ARGS)
    ifeq ($(MAKE_BUILD_TEST), true)
        TEST_BUILD_CMD = make VERBOSE=1 tests $(MAKE_ARGS)
        TEST_INSTALL_CMD = TEST_INSTALL_DIR=$(TEST_INSTALL_DIR) \
                           QNX_PROJECT_ROOT=$(QNX_PROJECT_ROOT) \
                           sh ../../install_test.sh
    endif
endif


MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

ifndef NO_TARGET_OVERRIDE
$(NAME)_all:
	@mkdir -p build
	@cd build && $(CONFIGURE_CMD) $(CONFIGURE_ENVS) $(CONFIGURE_ARGS)
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)
	@cd build && $(TEST_BUILD_CMD)

install check: $(NAME)_all
	@echo Installing...
	@cd build && $(BIN_INSTALL_CMD)
	@cd build && $(TEST_INSTALL_CMD)
	@echo Done.

clean iclean spotless:
	rm -rf build

uninstall:
endif