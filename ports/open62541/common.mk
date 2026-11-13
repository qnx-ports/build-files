ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME=open62541

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../open62541

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

#Set to ON to also build upstream's unit tests and install them with
#qnxtests.sh. They need the check port installed first.
BUILD_TESTING ?= OFF

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#Encryption (SecurityPolicies Basic256Sha256, Aes128/256 ...) with the
#SDP's OpenSSL 3. Set to OFF to build without it.
UA_ENABLE_ENCRYPTION ?= OPENSSL

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install check clean

include $(MKFILES_ROOT)/qtargets.mk

$(NAME)_INSTALL_DIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)
$(NAME)_TESTS_DIR=$($(NAME)_INSTALL_DIR)/bin/$(NAME)_tests

#Headers from INSTALL_ROOT need to be made available by default
#because CMake and pkg-config do not necessary add it automatically
#if the include path is "default"
CFLAGS += -I$(INSTALL_ROOT)/$(PREFIX)/include
CFLAGS += -fPIC
CFLAGS += -ffile-prefix-map=$(QNX_PROJECT_ROOT)=open62541

#The unit tests find check through pkg-config
export PKG_CONFIG_PATH=$($(NAME)_INSTALL_DIR)/lib/pkgconfig

#CMAKE_AR/CMAKE_RANLIB: the SDP's own tools, which also handle the
#link-time optimisation open62541 enables for Release builds
CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_INSTALL_PREFIX=$($(NAME)_INSTALL_DIR) \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DCMAKE_SYSTEM_PROCESSOR=$(CPUVARDIR) \
             -DCMAKE_C_COMPILER_TARGET=gcc_nto$(CPUVARDIR) \
             -DCMAKE_CXX_COMPILER_TARGET=gcc_nto$(CPUVARDIR) \
             -DCMAKE_AR=$(QNX_HOST)/usr/bin/nto$(CPU)-ar \
             -DCMAKE_RANLIB=$(QNX_HOST)/usr/bin/nto$(CPU)-ranlib \
             -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(CXXFLAGS)" \
             -DEXTRA_CMAKE_ASM_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DBUILD_SHARED_LIBS=ON \
             -DUA_ARCHITECTURE=posix \
             -DUA_ENABLE_ENCRYPTION=$(UA_ENABLE_ENCRYPTION) \
             -DOPENSSL_ROOT_DIR=$(QNX_TARGET)/$(CPUVARDIR)/usr \
             -DOPENSSL_INCLUDE_DIR=$(QNX_TARGET)/usr/include \
             -DUA_BUILD_EXAMPLES=ON \
             -DUA_BUILD_UNIT_TESTS=$(BUILD_TESTING)

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

ifndef NO_TARGET_OVERRIDE
$(NAME)_all:
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && $(MAKE) VERBOSE=1 all $(MAKE_ARGS)

install check: $(NAME)_all
	@echo Installing...
	@cd build && $(MAKE) VERBOSE=1 install $(MAKE_ARGS)
ifeq ($(BUILD_TESTING),ON)
	@mkdir -p $($(NAME)_TESTS_DIR)
	@for t in build/bin/tests/check_*; do $(QNX_HOST)/usr/bin/nto$(CPU)-strip -o $($(NAME)_TESTS_DIR)/$${t##*/} $$t; done
	@cp build/tests/*.der build/tests/*.json5 $($(NAME)_TESTS_DIR)/
	@cp $(PROJECT_ROOT)/qnxtests.sh $($(NAME)_TESTS_DIR)/
endif
	@echo Done.

clean:
	rm -rf build
endif
