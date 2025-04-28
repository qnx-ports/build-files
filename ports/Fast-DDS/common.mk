ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME=Fast-DDS

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
FAST-DDS_INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

# These commands require GNU Make
FAST-DDS_CMAKE_VERSION = $(shell bash -c "grep VERSION $(PROJECT_ROOT)/../CMakeLists.txt | grep fastrtps ")
FAST-DDS_VERSION = .$(subst $\",,$(word 3,$(FAST-DDS_CMAKE_VERSION)))

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release
TESTING=OFF

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = Fast-DDS_all
.PHONY: Fast-DDS_all install check clean

CFLAGS += $(FLAGS)
LDFLAGS += -Wl,--build-id=md5

include $(MKFILES_ROOT)/qtargets.mk

FAST-DDS_DIST_DIR = $(PRODUCT_ROOT)/../../$(NAME)

ASIO_ROOT = $(PRODUCT_ROOT)/../../$(NAME)/thirdparty/asio/asio
FOONATHAN_MEMORY_ROOT =  $(PRODUCT_ROOT)/../../$(NAME)/foonathan_memory_vendor
FASTCDR_ROOT =  $(PRODUCT_ROOT)/../../$(NAME)/thirdparty/fastcdr
GOOGLETEST_ROOT =  $(PRODUCT_ROOT)/../../$(NAME)/googletest
TINYXML2_ROOT =  $(PRODUCT_ROOT)/../../$(NAME)/thirdparty/tinyxml2

STRICT_REALTIME ?= ON

#Search paths for all of CMake's find_* functions --
#headers, libraries, etc.
#
#$(QNX_TARGET): for architecture-agnostic files shipped with SDP (e.g. headers)
#$(QNX_TARGET)/$(CPUVARDIR): for architecture-specific files in SDP
#$(INSTALL_ROOT)/$(CPUVARDIR): any packages that may have been installed in the staging area
CMAKE_FIND_ROOT_PATH := $(QNX_TARGET);$(QNX_TARGET)/$(CPUVARDIR);$(INSTALL_ROOT)/$(CPUVARDIR)

#Path to CMake modules; These are CMake files installed by other packages
#for downstreams to discover them automatically. We support discovering
#CMake-based packages from inside SDP or in the staging area.
#Note that CMake modules can automatically detect the prefix they are
#installed in.
CMAKE_MODULE_PATH := $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/cmake;$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/cmake

CMAKE_ARGS += -DBUILD_SHARED_LIBS=ON \
             -DCMAKE_NO_SYSTEM_FROM_IMPORTED=TRUE \
             -DCMAKE_PROJECT_INCLUDE=$(PROJECT_ROOT)/project_hooks.cmake \
             -DCMAKE_FIND_ROOT_PATH="$(CMAKE_FIND_ROOT_PATH)" \
             -DCMAKE_MODULE_PATH="$(CMAKE_MODULE_PATH)" \
             -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_INSTALL_INCLUDEDIR=$(FAST-DDS_INSTALL_ROOT)/usr/include \
             -DCMAKE_INSTALL_PREFIX=$(FAST-DDS_INSTALL_ROOT)/$(CPUVARDIR)/usr \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_ASM_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCPUVARDIR=$(CPUVARDIR) \
             -DCMAKE_PREFIX_PATH=$(FAST-DDS_INSTALL_ROOT) \
             -DCMAKE_MODULE_PATH=$(PWD)/cmake \
             -DCMAKE_INSTALL_BINDIR=$(FAST-DDS_INSTALL_ROOT)/$(CPUVARDIR)/usr/bin \
             -DCMAKE_INSTALL_LIBDIR=$(FAST-DDS_INSTALL_ROOT)/$(CPUVARDIR)/usr/lib \
             -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
             -DINCLUDE_INSTALL_DIR=$(FAST-DDS_INSTALL_ROOT)/usr/include \
             -DLIB_INSTALL_DIR=$(FAST-DDS_INSTALL_ROOT)/$(CPUVARDIR)/usr/lib \
			 -G Ninja \

FAST-DDS_CMAKE_ARGS = $(CMAKE_ARGS) \
                     -DQNX_INSTALL_ROOT=$(FAST-DDS_INSTALL_ROOT) \
                     -DSECURITY=ON \
                     -DCOMPILE_EXAMPLES=ON \
                     -DEPROSIMA_BUILD_TESTS=$(TESTING) \
                     -DSTRICT_REALTIME=$(STRICT_REALTIME) \

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

CONFIGURE_ASIO = $(ASIO_ROOT)/configure --exec-prefix $(FAST-DDS_INSTALL_ROOT)/$(CPUVARDIR) --prefix $(FAST-DDS_INSTALL_ROOT)

MAKE_ARGS_ASIO = CXX=$(QNX_HOST)/usr/bin/q++ CC=$(QNX_HOST)/usr/bin/qcc

ifndef NO_TARGET_OVERRIDE
dependencies:
	@cd $(ASIO_ROOT) && aclocal && autoconf && automake --add-missing
	@cd $(ASIO_ROOT) && $(CONFIGURE_ASIO) && make install $(MAKE_ARGS_ASIO) $(MAKE_ARGS)
	@rm -rf $(FAST-DDS_INSTALL_ROOT)/usr/include/asio $(FAST-DDS_INSTALL_ROOT)/usr/include/asio.hpp
	@mkdir -p $(FAST-DDS_INSTALL_ROOT)/usr/include
	@mv $(FAST-DDS_INSTALL_ROOT)/include/asio.hpp $(FAST-DDS_INSTALL_ROOT)/usr/include
	@mv $(FAST-DDS_INSTALL_ROOT)/include/asio $(FAST-DDS_INSTALL_ROOT)/usr/include

	@mkdir -p build/build_fastcdr
	@cd build/build_fastcdr && cmake $(CMAKE_ARGS) $(FASTCDR_ROOT)
	@cd build/build_fastcdr && ninja install $(MAKE_ARGS)

	@mkdir -p build/build_foonathan_memory
	@cd build/build_foonathan_memory && cmake $(CMAKE_ARGS) $(FOONATHAN_MEMORY_ROOT)
	@cd build/build_foonathan_memory && ninja install $(MAKE_ARGS)

	@mkdir -p build/build_googletest
	@cd build/build_googletest && cmake $(CMAKE_ARGS) $(GOOGLETEST_ROOT)
	@cd build/build_googletest && ninja install $(MAKE_ARGS)

	@mkdir -p build/build_tinyxml2
	@cd build/build_tinyxml2 && cmake $(CMAKE_ARGS) $(TINYXML2_ROOT)
	@cd build/build_tinyxml2 && ninja install $(MAKE_ARGS)
#	@cp $(FAST-DDS_INSTALL_ROOT)/$(CPUVARDIR)/usr/lib/cmake/tinyxml2/tinyxml2Config.cmake $(FAST-DDS_INSTALL_ROOT)/$(CPUVARDIR)/usr/lib/cmake/tinyxml2/TinyXML2Config.cmake

Fast-DDS_all: dependencies
	@mkdir -p build/build_fast-dds
	@cd build/build_fast-dds && cmake $(FAST-DDS_CMAKE_ARGS) $(FAST-DDS_DIST_DIR) 
	@cd build/build_fast-dds && ninja install $(MAKE_ARGS)

install check: Fast-DDS_all
	@echo Done.

clean iclean spotless:
	@rm -rf build

endif
