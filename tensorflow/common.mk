ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../

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

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = tflite_all
.PHONY: tflite_all


FLAGS += -D_QNX_SOURCE -funsafe-math-optimizations -DFARMHASH_LITTLE_ENDIAN -D__LITTLE_ENDIAN__

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_INSTALL_PREFIX=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX) \
             -DCMAKE_INSTALL_PREFIX=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX) \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DCMAKE_INSTALL_LIBDIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib \
             -DCMAKE_INSTALL_INCLUDEDIR=$(INSTALL_ROOT)/$(PREFIX)/include/tensorflow \
             -DEXTRA_CMAKE_C_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(FLAGS)" \
             -DCPUVARDIR=$(CPUVARDIR) \
             -DTFLITE_ENABLE_XNNPACK=OFF \
             -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
             -DTFLITE_ENABLE_INSTALL=ON \
             -DBUILD_SHARED_LIBS=ON \
             -DTFLITE_KERNEL_TEST=ON \
             -DTFLITE_HOST_TOOLS_DIR=$(TFLITE_HOST_TOOLS_DIR) \
             -DQNX_PATCH_DIR=$(QNX_PATCH_DIR) \
             -DOVERRIDABLE_FETCH_CONTENT_cpuinfo_GIT_REPOSITORY=https://gitlab.com/qnx/libs/cpuinfo \
             -DOVERRIDABLE_FETCH_CONTENT_cpuinfo_GIT_TAG=qnx \
             -DOVERRIDABLE_FETCH_CONTENT_ruy_GIT_REPOSITORY=https://gitlab.com/qnx/libs/ruy \
             -DOVERRIDABLE_FETCH_CONTENT_ruy_GIT_TAG=qnx \
             -DOVERRIDABLE_FETCH_CONTENT_abseil-cpp_GIT_REPOSITORY=https://gitlab.com/qnx/libs/abseil-cpp.git \
             -DOVERRIDABLE_FETCH_CONTENT_abseil-cpp_GIT_TAG=qnx_20230802.1 \
             -DOVERRIDABLE_FETCH_CONTENT_farmhash_GIT_REPOSITORY=https://gitlab.com/qnx/libs/farmhash.git \
             -DOVERRIDABLE_FETCH_CONTENT_farmhash_GIT_TAG=qnx \
             -DOVERRIDABLE_FETCH_CONTENT_eigen_GIT_REPOSITORY=https://gitlab.com/qnx/libs/eigen.git \
             -DOVERRIDABLE_FETCH_CONTENT_eigen_GIT_TAG=qnx_v3.4.1 \

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)


include $(MKFILES_ROOT)/qtargets.mk

ifndef NO_TARGET_OVERRIDE
tflite_all:
	@mkdir -p build
	cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)/tensorflow/lite/
	cd build && make all $(MAKE_ARGS)

install check: tflite_all
	cd build && make install $(MAKE_ARGS)

clean iclean spotless:
	rm -fr build

uninstall:
endif
