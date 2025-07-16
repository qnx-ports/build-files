ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME=XNNPACK

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../XNNPACK

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
ALL_DEPENDENCIES = xnnpack_all
.PHONY: xnnpack_all xnnpack_all_clean

FLAGS   += -D_QNX_SOURCE -D__QNXNTO__
LDFLAGS += -Wl,--build-id=md5 -lang-c++

include $(MKFILES_ROOT)/qtargets.mk

ifeq ($(CPUVARDIR),aarch64le)
NTO_DIR_NAME=nto-aarch64-le
CMAKE_SYSTEM_PROCESSOR=aarch64
else
NTO_DIR_NAME=nto-x86_64-o
CMAKE_SYSTEM_PROCESSOR=x86_64
endif

XNNPACK_VERSION = main

CMAKE_ARGS =    -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
                -DCMAKE_SYSTEM_PROCESSOR=$(CMAKE_SYSTEM_PROCESSOR) \
                -DCMAKE_ASM_COMPILER_TARGET=gcc_nto$(CPUVARDIR) \
                -DCMAKE_C_COMPILER_TARGET=gcc_nto$(CPUVARDIR) \
                -DCMAKE_CXX_COMPILER_TARGET=gcc_nto$(CPUVARDIR) \
                -DCMAKE_INSTALL_PREFIX=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX) \
                -DCMAKE_INSTALL_LIBDIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib \
                -DCMAKE_INSTALL_INCLUDEDIR=$(INSTALL_ROOT)/$(PREFIX)/include \
                -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
                -DBUILD_QNX_ASM_FLAGS="$(FLAGS)" \
                -DBUILD_QNX_C_FLAGS="$(FLAGS)" \
                -DBUILD_QNX_CXX_FLAGS="$(FLAGS)" \
                -DBUILD_QNX_LINKER_FLAGS="$(LDFLAGS)" \
                -DCMAKE_VERBOSE_MAKEFILE=1 \
                -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
                -DXNNPACK_BUILD_TESTS=OFF \
                -DXNNPACK_ENABLE_ASSEMBLY=OFF \
                -DXNNPACK_BUILD_BENCHMARKS=OFF \
                -DXNNPACK_ENABLE_AVXVNNIINT8=OFF \

ifndef NO_TARGET_OVERRIDE

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

xnnpack_all:
	echo "make xnnpack_all  $(NTO_DIR_NAME)"
	mkdir -p build && \
	cd build && \
	cmake 	"${QNX_PROJECT_ROOT}" \
		${CMAKE_ARGS} && \
	make all $(MAKE_ARGS)

xnnpack_all_clean:
	echo "make xnnpack_all_clean $(NTO_DIR_NAME)"
	cd $(QNX_PROJECT_ROOT) && \
	rm -rf build
	rm -rf $(PROJECT_ROOT)/$(NTO_DIR_NAME)/build

clean: xnnpack_all_clean

install check: xnnpack_all
	cd build && make install $(MAKE_ARGS)

uninstall:
endif
