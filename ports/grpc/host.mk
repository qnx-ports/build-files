ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=grpc

DIST_BASE ?= $(PRODUCT_ROOT)/../

# choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

# override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = grpc_all
.PHONY: grpc_all grpc_host install check clean

HOST_CMAKE_ARGS = -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
                  -DgRPC_BUILD_TEST="OFF" \
                  -DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF \
                  -DgRPC_BUILD_GRPC_PYTHON_PLUGIN=OFF \
                  -DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF \
                  -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF \
                  -DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF \
                  -DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF \
                  -DgRPC_BUILD_GRPC_CPP_PLUGIN=ON \
                  -DgRPC_DOWNLOAD_ARCHIVES=OFF \
                  -DCMAKE_NO_SYSTEM_FROM_IMPORTED=ON \
                  -DCMAKE_VERBOSE_MAKEFILE=ON

include $(MKFILES_ROOT)/qtargets.mk

ifndef NO_TARGET_OVERRIDE

grpc_all: grpc_host

grpc_host:
	@mkdir -p build
	@cd build && \
	cmake $(CONFIG_CMAKE_ARGS) $(HOST_CMAKE_ARGS) $(DIST_BASE) && \
	cmake --build . --target protoc grpc_cpp_plugin $(GENERATOR_ARGS)

clean_host:
	@rm -rf build

clean iclean spotless: clean_host

install check: grpc_all

uninstall:
endif
