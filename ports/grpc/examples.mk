ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=grpc-examples

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../grpc/examples/cpp/helloworld

BUILD_TESTING ?= ON

# $(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
# by default, unless it was manually re-routed to
# a staging area by setting both INSTALL_ROOT_nto
# and USE_INSTALL_ROOT
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

# choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

# set the following to FALSE if generating .pinfo files is causing problems
GENERATE_PINFO_FILES ?= TRUE

# override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = $(NAME)_all
.PHONY: grpc_all install check clean

CPPFLAGS += $(FLAGS) -D__EXT_QNX -D_QNX_SOURCE $(FORTIFY_DEFS)
CPPFLAGS += -I$(INSTALL_ROOT)/$(PREFIX)/include -I$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin/src -I$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/bin/src
CPPFLAGS += -fstack-protector-strong
# Ignore warnings
CPPFLAGS += -w
# Hack for c++ using qcc
CXXFLAGS += -isystem $(QNX_TARGET)/usr/include/c++/v1/

LDFLAGS += -Wl,-z,relro -Wl,-z,now
# Search paths for all of CMake's find_* functions --
# headers, libraries, etc.
#
# $(QNX_TARGET): for architecture-agnostic files shipped with SDP (e.g. headers)
# $(QNX_TARGET)/$(CPUVARDIR): for architecture-specific files in SDP
# $(INSTALL_ROOT)/$(CPUVARDIR): any packages that may have been installed in the staging area
CMAKE_FIND_ROOT_PATH := $(QNX_TARGET);$(QNX_TARGET)/$(CPUVARDIR);$(INSTALL_ROOT)/$(CPUVARDIR)

# Path to CMake modules; These are CMake files installed by other packages
# for downstreams to discover them automatically. We support discovering
# CMake-based packages from inside SDP or in the staging area.
# Note that CMake modules can automatically detect the prefix they are
# installed in.
CMAKE_MODULE_PATH := $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/cmake;$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/cmake

ifneq ($(wildcard ${QNX_TARGET}/usr/include/vm_sockets.h),)
CPPFLAGS += -DQNX_HAVE_VSOCK
endif

HOST_GRPC_PATH = ${PROJECT_ROOT}/host/linux-x86_64-o/build

HOST_PROTOC_PATH = ${HOST_GRPC_PATH}/third_party/protobuf/protoc

CMAKE_ARGS += -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
              -DCMAKE_INSTALL_PREFIX=$(INSTALL_ROOT) \
              -DCMAKE_INSTALL_BINDIR="$(CPUVARDIR)/$(PREFIX_EXT)/bin" \
              -DCMAKE_INSTALL_INCLUDEDIR="$(PREFIX)/include" \
              -DCMAKE_INSTALL_LIBDIR="$(CPUVARDIR)/$(PREFIX_EXT)/lib" \
              -DCMAKE_MODULE_PATH="$(CMAKE_MODULE_PATH)" \
              -DCMAKE_FIND_ROOT_PATH="$(CMAKE_FIND_ROOT_PATH)" \
              -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
              -DCMAKE_VERBOSE_MAKEFILE=ON \
              -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS) $(CPPFLAGS)" \
              -DEXTRA_CMAKE_CXX_FLAGS="$(CXXFLAGS) $(CPPFLAGS)" \
              -DEXTRA_CMAKE_ASM_FLAGS="$(ASFLAGS)" \
              -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
              -DGENERATE_PINFO_FILES=$(GENERATE_PINFO_FILES) \
              -DCPU=$(CPU) \
              -DEXT=$(EXT) \
              -DCMAKE_CXX_STANDARD=17 \
              -DBUILD_SHARED_LIBS=ON \
              -DgRPC_BUILD_CODEGEN=ON \
              -DgRPC_BUILD_TESTS=$(BUILD_TESTING) \
              -DgRPC_INSTALL_BINDIR="$(CPUVARDIR)/$(PREFIX_EXT)/bin" \
              -DgRPC_INSTALL_INCLUDEDIR="$(PREFIX)/include" \
              -DgRPC_INSTALL_LIBDIR="$(CPUVARDIR)/$(PREFIX_EXT)/lib" \
              -DgRPC_INSTALL_SHAREDIR="$(CPUVARDIR)/$(PREFIX)/local" \
              -DgRPC_INSTALL_CMAKEDIR="$(CPUVARDIR)/$(PREFIX_EXT)/lib/cmake/grpc" \
              -DgRPC_SSL_PROVIDER=package \
              -DOPENSSL_ROOT_DIR=$(QNX_TARGET) \
              -DOPENSSL_INCLUDE_DIR="$(QNX_TARGET)/usr/include/openssl" \
              -DOPENSSL_CRYPTO_LIBRARY="$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX_NET)/usr/lib/libcrypto.so" \
              -DOPENSSL_SSL_LIBRARY="$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX_NET)/usr/lib/libssl.so" \
              -DgRPC_PROTOBUF_PROVIDER=module \
              -DgRPC_ABSL_PROVIDER=module \
              -DgRPC_RE2_PROVIDER=module \
              -DgRPC_BENCHMARK_PROVIDER=module \
              -D_gRPC_CPP_PLUGIN=${HOST_GRPC_PATH}/grpc_cpp_plugin \
              -DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF \
              -DgRPC_BUILD_GRPC_PYTHON_PLUGIN=OFF \
              -DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF \
              -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF \
              -DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF \
              -DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF \
              -DgRPC_BUILD_GRPC_CPP_PLUGIN=ON \
              -DgRPC_DOWNLOAD_ARCHIVES=OFF \
              -D_gRPC_PROTOBUF_PROTOC_EXECUTABLE=$(HOST_PROTOC_PATH) \
              -DRE2_BUILD_TESTING=OFF \
              -DBENCHMARK_ENABLE_TESTING=OFF \
              -DCARES_LIBRARY=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX_NET)/usr/lib/libcares.so \
              -DSOCKET_LIBRARY=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX_NET)/lib/libsocket.so \
			  -D_PROTOBUF_PROTOC=$(HOST_PROTOC_PATH) \
              -D_GRPC_CPP_PLUGIN_EXECUTABLE=${HOST_GRPC_PATH}/grpc_cpp_plugin

# -DEXT is a carryover for supporting armv7le

# -DProtobuf_ROOT=${HOME}/local/lib/cmake/protobuf
CMAKE_ARGS +=   -DBENCHMARK_ENABLE_WERROR=OFF \
                -DBENCHMARK_DOWNLOAD_DEPENDENCIES=OFF \
                -DBENCHMARK_USE_BUNDLED_GTEST=OFF

include $(MKFILES_ROOT)/qtargets.mk

GENERATOR_ARGS ?= -j $(firstword $(JLEVEL) 1)

ifndef NO_TARGET_OVERRIDE

$(NAME)_all: $(NAME)_target

$(NAME)_target:
	@mkdir -p build
	@cd build && \
	cmake $(CONFIG_CMAKE_ARGS) $(CMAKE_ARGS) $(QNX_PROJECT_ROOT) && \
	cmake --build . $(GENERATOR_ARGS)

install check: $(NAME)_all
	@echo Installing...
	@cd build && cmake --build . --target install $(GENERATOR_ARGS)
	@echo Done.

clean_target:
	@rm -rf build

clean iclean spotless: clean_target

uninstall:
endif
