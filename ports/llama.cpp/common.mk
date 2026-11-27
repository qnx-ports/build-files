ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)
include $(MKFILES_ROOT)/qmacros.mk

# Prevent qtargets.mk from re-including qmacros.mk
define VARIANT_TAG
endef

NAME=llama.cpp

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../llama.cpp

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

#A prefix path to use **on the target**. Default is /usr/local
PREFIX ?= /usr/local

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = llama.cpp_all
.PHONY: llama.cpp_all install check clean

CFLAGS += $(FLAGS)
LDFLAGS += -Wl,--build-id=md5

include $(MKFILES_ROOT)/qtargets.mk

CMAKE_FIND_ROOT_PATH := $(QNX_TARGET);$(QNX_TARGET)/$(CPUVARDIR);$(INSTALL_ROOT)/$(CPUVARDIR)
CMAKE_MODULE_PATH := $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/cmake;$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/cmake

# ggml selects its CPU backend sources from CMAKE_SYSTEM_PROCESSOR and does not know QNX's "aarch64le".
ifeq ($(CPUVARDIR),aarch64le)
SYSTEM_PROCESSOR = aarch64
CPU_ARGS =
else
SYSTEM_PROCESSOR = $(CPUVARDIR)
# x86_64 targets: AVX2/FMA/F16C baseline (any x86-64-v3 CPU). Set GGML_X86_FLAGS to override.
GGML_X86_FLAGS ?= -DGGML_AVX=ON -DGGML_AVX2=ON -DGGML_FMA=ON -DGGML_F16C=ON
CPU_ARGS = $(GGML_X86_FLAGS)
endif

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_SYSTEM_PROCESSOR=$(SYSTEM_PROCESSOR) \
             -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
             -DCMAKE_STAGING_PREFIX="$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)" \
             -DCMAKE_MODULE_PATH="$(CMAKE_MODULE_PATH)" \
             -DCMAKE_FIND_ROOT_PATH="$(CMAKE_FIND_ROOT_PATH)" \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_ASM_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCPUVARDIR=$(CPUVARDIR) \
             -DCPU=$(CPU) \
             -DBUILD_SHARED_LIBS=ON \
             -DGGML_NATIVE=OFF \
             -DGGML_OPENMP=OFF \
             -DLLAMA_CURL=OFF \
             -DLLAMA_OPENSSL=OFF \
             -DLLAMA_BUILD_TESTS=OFF \
             -DLLAMA_BUILD_EXAMPLES=OFF \
             -DLLAMA_BUILD_TOOLS=ON \
             -DLLAMA_BUILD_SERVER=ON \
             $(CPU_ARGS)

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

ifndef NO_TARGET_OVERRIDE
# Apply the QNX patch to the llama.cpp checkout once (skipped if it is already applied).
patch:
	@cd $(QNX_PROJECT_ROOT) && if git apply --reverse --check $(PROJECT_ROOT)/qnx.patch 2>/dev/null; \
		then echo "qnx.patch already applied"; else git apply $(PROJECT_ROOT)/qnx.patch && echo "qnx.patch applied"; fi

llama.cpp_all: patch
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && make all $(MAKE_ARGS)

install check: llama.cpp_all
	@cd build && make install $(MAKE_ARGS)

clean iclean spotless:
	@rm -rf build
endif
