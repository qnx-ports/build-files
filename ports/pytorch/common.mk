ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME=pytorch

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

PYTORCH_VERSION = 2.3.1

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = pytorch_mobile_all
.PHONY: pytorch_mobile_all pytorch_mobile_all_clean sleef_host_tools_all sleef_host_tools_clean protobuf_host_install protobuf_host_tools_clean

FLAGS   += -D_QNX_SOURCE -D__QNXNTO__
LDFLAGS += -Wl,--build-id=md5

include $(MKFILES_ROOT)/qtargets.mk

ifeq ($(CPUVARDIR),aarch64le)
NTO_DIR_NAME=nto-aarch64-le
CMAKE_SYSTEM_PROCESSOR=aarch64
else
NTO_DIR_NAME=nto-x86_64-o
CMAKE_SYSTEM_PROCESSOR=x86_64
endif

BUILD_LITE_INTERPRETER ?= OFF
SELECTED_OP_LIST ?=
BUILD_TESTING ?= OFF
TRACING_BASED ?= OFF
BUILD_CAFFE2 ?= ON
BUILD_PYTHON ?= ON

PREFIX_PATH := $(shell python -c 'import sysconfig, sys; sys.stdout.write(sysconfig.get_path("purelib"))')
PYTHON_EXECUTABLE := $(shell python -c 'import sys; sys.stdout.write(sys.executable)')

PYTORCH_BUILD_FLAGS =   -DUSE_ROCM=OFF \
                        -DUSE_CUDA=OFF \
                        -DUSE_ITT=OFF \
                        -DUSE_GFLAGS=OFF \
                        -DUSE_OPENCV=OFF \
                        -DUSE_LMDB=OFF \
                        -DUSE_LEVELDB=OFF \
                        -DUSE_MPI=OFF \
                        -DUSE_OPENMP=OFF \
                        -DUSE_MKLDNN=OFF \
                        -DUSE_NNPACK=OFF \
                        -DUSE_NUMPY=OFF \
                        -DUSE_BLAS=OFF

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
                -DCAFFE2_CUSTOM_PROTOC_EXECUTABLE=$(PROJECT_ROOT)/host/protobuf/install/bin/protoc \
                -DNATIVE_BUILD_DIR=$(PROJECT_ROOT)/host/sleef \
                -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
                -DBUILD_LITE_INTERPRETER=$(BUILD_LITE_INTERPRETER) \
                -DSELECTED_OP_LIST=$(SELECTED_OP_LIST) \
                -DBUILD_TEST=$(BUILD_TESTING) \
                -DINSTALL_TEST=OFF \
                -DBUILD_BINARY=OFF \
                -DTRACING_BASED=$(TRACING_BASED) \
                -DXNNPACK_ENABLE_ASSEMBLY=OFF \
                -DBUILD_CUSTOM_PROTOBUFF=OFF \
                -DBUILD_SHARED_LIBS=ON \
                -DBUILD_PYTHON=$(BUILD_PYTHON) \
                -DBUILD_CAFFE2=$(BUILD_CAFFE2)

ifeq ($(USE_LIGHTWEIGHT_DISPATCH),ON)
    CMAKE_ARGS +=   -DUSE_LIGHTWEIGHT_DISPATCH=ON \
                    -DSTATIC_DISPATCH_BACKEND=CPU
else
    CMAKE_ARGS += -DUSE_LIGHTWEIGHT_DISPATCH=OFF
endif

ifndef NO_TARGET_OVERRIDE

HOSTCC = gcc
HOSTCMAKE_ARGS =    -DCMAKE_INSTALL_PREFIX="$(PROJECT_ROOT)/host/protobuf/install" \
                    -Dprotobuf_BUILD_TESTS=OFF \
                    -Dprotobuf_BUILD_CONFORMANCE=OFF \
                    -Dprotobuf_BUILD_EXAMPLES=OFF

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

pytorch_mobile_all: sleef_host_tools_all protobuf_host_install
	echo "make pytorch_mobile_all  $(NTO_DIR_NAME)"
	mkdir -p build && \
	cd build && \
	cmake 	"${QNX_PROJECT_ROOT}" \
		-DCMAKE_BUILD_TYPE=Release \
		${CMAKE_ARGS} \
		${PYTORCH_BUILD_FLAGS} \
		-DCMAKE_PREFIX_PATH=$(PREFIX_PATH) \
		-DPYTHON_EXECUTABLE=$(PYTHON_EXECUTABLE) && \
	make all $(MAKE_ARGS)

pytorch_mobile_all_clean:
	echo "make pytorch_mobile_all_clean $(NTO_DIR_NAME)"
	cd $(QNX_PROJECT_ROOT) && \
	python setup.py clean && \
	rm -rf build
	rm -rf $(PROJECT_ROOT)/$(NTO_DIR_NAME)/build

# Sleef tools are needed on the host to autogenerate source code for libsleef
sleef_host_tools_all:
	mkdir -p $(PROJECT_ROOT)/host/sleef/bin
	$(HOSTCC) -o $(PROJECT_ROOT)/host/sleef/bin/mkalias  $(QNX_PROJECT_ROOT)/third_party/sleef/src/libm/mkalias.c
	$(HOSTCC) -o $(PROJECT_ROOT)/host/sleef/bin/mkrename  $(QNX_PROJECT_ROOT)/third_party/sleef/src/libm/mkrename.c
	$(HOSTCC) -o $(PROJECT_ROOT)/host/sleef/bin/mkrename_gnuabi  $(QNX_PROJECT_ROOT)/third_party/sleef/src/libm/mkrename_gnuabi.c
	$(HOSTCC) -o $(PROJECT_ROOT)/host/sleef/bin/mkmasked_gnuabi  $(QNX_PROJECT_ROOT)/third_party/sleef/src/libm/mkmasked_gnuabi.c
	$(HOSTCC) -o $(PROJECT_ROOT)/host/sleef/bin/mkdisp  $(QNX_PROJECT_ROOT)/third_party/sleef/src/libm/mkdisp.c

sleef_host_tools_clean:
	rm -rf $(PROJECT_ROOT)/host/sleef

# Protobuf is needed as a host tool as well as a target dependency.
# It has to be the same version as the dependency included in libtorch thirdparty source code.
protobuf_host_install:
	mkdir -p $(PROJECT_ROOT)/host/protobuf/build
	cd $(PROJECT_ROOT)/host/protobuf/build && \
	cmake $(HOSTCMAKE_ARGS) $(QNX_PROJECT_ROOT)/third_party/protobuf/cmake && \
	make all $(MAKE_ARGS) && \
	make install $(MAKE_ARGS)

protobuf_host_tools_clean:
	rm -rf $(PROJECT_ROOT)/host/protobuf

clean: sleef_host_tools_clean protobuf_host_tools_clean pytorch_mobile_all_clean

install check: pytorch_mobile_all
	cd build && make install $(MAKE_ARGS)

uninstall:
endif
