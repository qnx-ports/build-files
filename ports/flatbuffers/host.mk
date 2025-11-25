ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)
include $(MKFILES_ROOT)/qmacros.mk

NAME=flatbuffers

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../flatbuffers

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

# choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

# override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = $(flatbuffers)_all
.PHONY: $(flatbuffers)_all $(flatbuffers)_host install check clean

HOST_CMAKE_ARGS = -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
				  -DCMAKE_INSTALL_PREFIX="$(INSTALL_ROOT)/usr" \
                  -DBUILD_TESTING=OFF \
				  -DFLATBUFFERS_BUILD_TESTS=OFF \
                  -DCMAKE_NO_SYSTEM_FROM_IMPORTED=ON \
                  -DCMAKE_VERBOSE_MAKEFILE=ON

include $(MKFILES_ROOT)/qtargets.mk

ifndef NO_TARGET_OVERRIDE

$(flatbuffers)_all: $(flatbuffers)_host

$(flatbuffers)_host:
	@mkdir -p build
	@cd build && \
	cmake $(CONFIG_CMAKE_ARGS) $(HOST_CMAKE_ARGS) $(QNX_PROJECT_ROOT) && \
	cmake --build . --target flatc

install check: $(flatbuffers)_all
	if [ ! -d "${INSTALL_ROOT}/" ]; then \
		mkdir -p "${INSTALL_ROOT}/"; \
		fi
	if [ -w "${INSTALL_ROOT}/" ]; then \
		cd build && \
		make install; \
		else \
		cd build && \
		sudo make install; \
		fi

clean_host:
	@rm -rf build

clean iclean spotless: clean_host

uninstall:
endif
