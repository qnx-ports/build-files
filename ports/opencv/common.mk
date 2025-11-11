ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=opencv

QNX_WORKSPACE ?= $(PRODUCT_ROOT)/../../
QNX_PROJECT_ROOT ?= $(QNX_WORKSPACE)/opencv
EXTRA_ROOT ?= $(QNX_WORKSPACE)/opencv_extra

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

BUILD_TESTING ?= OFF

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = opencv_all
.PHONY: opencv_all install check clean

CFLAGS += $(FLAGS)
LDFLAGS += -Wl,--build-id=md5

include $(MKFILES_ROOT)/qtargets.mk

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

#Headers from INSTALL_ROOT need to be made available by default
#because CMake and pkg-config do not necessary add it automatically
#if the include path is "default"
CFLAGS += -I$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/include -I$(INSTALL_ROOT)/$(PREFIX)/include \
          -I$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/include -I$(QNX_TARGET)/$(PREFIX)/include \
          -isystem $(QNX_TARGET)/usr/include/c++/v1/ \
          -D_QNX_SOURCE

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
             -DCMAKE_STAGING_PREFIX="$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)" \
             -DCMAKE_PROJECT_INCLUDE=$(PROJECT_ROOT)/project_hooks.cmake \
             -DCMAKE_MODULE_PATH="$(CMAKE_MODULE_PATH)" \
             -DCMAKE_FIND_ROOT_PATH="$(CMAKE_FIND_ROOT_PATH)" \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_ASM_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DBUILD_SHARED_LIBS=1 \
             -DCMAKE_INSTALL_INCLUDEDIR=$(INSTALL_ROOT)/$(PREFIX)/include \
             -DOPENCV_OTHER_INSTALL_PATH=$(INSTALL_ROOT)/$(PREFIX)/share \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DCMAKE_NO_SYSTEM_FROM_IMPORTED=ON \
             -DCPU=$(CPU) \
             -DWITH_QT=OFF \
             -DWITH_GTK=OFF \
             -DBUILD_opencv_gapi=OFF \
             -DBUILD_PERF_TESTS=$(BUILD_TESTING) \
             -DBUILD_TESTS=$(BUILD_TESTING) \
             -DCPUVARDIR=$(CPUVARDIR) \
             -DWITH_JASPER=OFF \
             -DWITH_IPP=OFF \
             -DBUILD_opencv_python3=ON \
             -DBUILD_opencv_python_bindings_generator=ON \
             -DOPENCV_TEST_DATA_INSTALL_PATH="/testdata" \
             -DOPENCV_PYTHON_INSTALL_TARGET=ON \
             -DOPENCV_PYTHON2_SKIP_DETECTION=ON \

ifndef NO_TARGET_OVERRIDE
opencv_all:
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)
	if [ "$(BUILD_TESTING)" = "ON" ]; then
		cp -r $(EXTRA_ROOT)/testdata ./testdata
		cp -r $(QNX_PROJECT_ROOT)/samples/data ./sampledata
	fi

install check: opencv_all
	@echo Installing...
	@cd build && make VERBOSE=1 install all $(MAKE_ARGS)
	@echo Done.

clean iclean spotless:
	rm -rf build

uninstall:
endif
