ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=grpc

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

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = grpc_all
.PHONY: grpc_all install check clean

CFLAGS += $(FLAGS) -D__EXT_QNX -D_QNX_SOURCE
CFLAGS += -I$(INSTALL_ROOT)/$(PREFIX)/include
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

HOST_PROTOC_PATH ?= $(PROJECT_ROOT)/../protobuf/host_protoc

ifneq ($(wildcard ${QNX_TARGET}/usr/include/vm_sockets.h),)
CFLAGS += -DQNX_HAVE_VSOCK
endif

HOST_GRPC_PATH = ${PROJECT_ROOT}/host_grpc

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_SYSTEM_PROCESSOR=$(CPUVARDIR) \
             -DCMAKE_CXX_COMPILER_TARGET=gcc_nto$(CPUVARDIR) \
             -DCMAKE_C_COMPILER_TARGET=gcc_nto$(CPUVARDIR) \
             -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
             -DCMAKE_STAGING_PREFIX="$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)" \
             -DCMAKE_MODULE_PATH="$(CMAKE_MODULE_PATH)" \
             -DCMAKE_FIND_ROOT_PATH="$(CMAKE_FIND_ROOT_PATH)" \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_ASM_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCPU=$(CPU) \
             -DCMAKE_CXX_STANDARD=17 \
             -DBUILD_SHARED_LIBS=ON \
             -DCMAKE_NO_SYSTEM_FROM_IMPORTED=ON \
             -DgRPC_BUILD_CODEGEN=ON \
             -DgRPC_BUILD_TESTS="ON" \
             -DgRPC_INSTALL_INCLUDEDIR=$(INSTALL_ROOT)/${PREFIX}/grpc \
             -DgRPC_INSTALL_SHAREDIR=$(INSTALL_ROOT)/${PREFIX}/share/grpc \
             -DgRPC_PROTOBUF_PROVIDER=package \
             -DgRPC_ABSL_PROVIDER=package \
             -DgRPC_BENCHMARK_PROVIDER=package \
             -DHOST_GRPC_PATH=${HOST_GRPC_PATH} \
             -DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF \
             -DgRPC_BUILD_GRPC_PYTHON_PLUGIN=OFF \
             -DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF \
             -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF \
             -DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF \
             -DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF \
             -DgRPC_BUILD_GRPC_CPP_PLUGIN=ON \
             -DHOST_PROTOC_PATH=$(HOST_PROTOC_PATH)

#-DProtobuf_ROOT=${HOME}/local/lib/cmake/protobuf
CMAKE_ARGS +=   -DBENCHMARK_ENABLE_WERROR=OFF \
                -DBENCHMARK_DOWNLOAD_DEPENDENCIES=OFF \
                -DBENCHMARK_USE_BUNDLED_GTEST=OFF

HOST_CMAKE_ARGS = -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
                  -DgRPC_BUILD_TEST="OFF" \
                  -DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF \
                  -DgRPC_BUILD_GRPC_PYTHON_PLUGIN=OFF \
                  -DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF \
                  -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF \
                  -DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF \
                  -DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF \
                  -DgRPC_BUILD_GRPC_CPP_PLUGIN=ON \
                  -DCMAKE_NO_SYSTEM_FROM_IMPORTED=ON

include $(MKFILES_ROOT)/qtargets.mk

GENERATOR_ARGS ?= -j $(firstword $(JLEVEL) 1)

ifndef NO_TARGET_OVERRIDE

grpc_all: grpc_host grpc_target

grpc_host:
	mkdir -p $(HOST_GRPC_PATH)
	cd $(HOST_GRPC_PATH) && \
	cmake $(CONFIG_CMAKE_ARGS) $(HOST_CMAKE_ARGS) $(QNX_PROJECT_ROOT) && \
	cmake --build . --target grpc_cpp_plugin $(GENERATOR_ARGS)

grpc_target: grpc_host
	@mkdir -p build
	@cd build && cmake $(CONFIG_CMAKE_ARGS) $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && cmake --build . $(GENERATOR_ARGS)

install check: grpc_all
	@echo Installing...
	@cd build && cmake --build . --target install $(GENERATOR_ARGS)
	@echo Done.

clean_host:
	@rm -rf $(HOST_GRPC_PATH)

clean_target:
	@rm -rf build

clean iclean spotless: clean_host clean_target

uninstall:
endif
