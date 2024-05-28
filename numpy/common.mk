ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=numpy

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

BUILD_TESTING ?= OFF

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = numpy_all
.PHONY: numpy_all install check clean

LDFLAGS += -Wl,--build-id=md5

include $(MKFILES_ROOT)/qtargets.mk

ifeq ($(CPUVARDIR),aarch64le)
NTO_DIR_NAME=nto-aarch64-le
else
NTO_DIR_NAME=nto-x86_64-o
endif

NTO_NAME=$(CPU)
GCC_NAME=$(CPUVARDIR)

NUMPY_ROOT = $(PROJECT_ROOT)/

NUMPY_VERSION = 1.25.0

EXPORT_PY  = export CC=$(QNX_HOST)/usr/bin/qcc \
             export CXX=$(QNX_HOST)/usr/bin/qcc \
             export CFLAGS="-Vgcc_nto$(GCC_NAME)" \
             export CPPFLAGS="-D_POSIX_THREADS -Wno-implicit-function-declaration -Wno-stringop-overflow -Wno-unused-but-set-variable " \
             export CXXFLAGS=$(CFLAGS) \
             export LDSHARED=$(QNX_HOST)/usr/bin/qcc \
             export LDFLAGS="-shared -L$(QNX_TARGET)/$(CPUVARDIR)/lib:$(QNX_TARGET)/$(CPUVARDIR)/usr/lib" \
             export host_alias=nto$(CPUVARDIR) \
             export AR="$(QNX_HOST)/usr/bin/nto$(NTO_NAME)-ar" \
             export AS="$(QNX_HOST)/usr/bin/nto$(NTO_NAME)-as" \
             export RANLIB="$(QNX_HOST)/usr/bin/nto$(NTO_NAME)-ranlib" \
             export LD_LIBRARY_PATH=$(QNX_HOST)/usr/lib:$(LD_LIBRARY_PATH) \
             export PATH=$(QNX_HOST)/usr/lib:$(QNX_HOST)/usr/bin:$(PATH) \
             export BLAS=None \
             export LAPACK=None \
             export ATLAS=None \
             export NUMPY_VERSION=$(NUMPY_VERSION) \
             export NPY_DISABLE_SVML=1 \
             export SETUPTOOLS_USE_DISTUTILS=stdlib \


BUILD_FLAGS =  --build-temp=$(PROJECT_ROOT)/$(NTO_DIR_NAME)/tmp \
               --build-lib=$(PROJECT_ROOT)/$(NTO_DIR_NAME)/lib \

BUILD_EXT_FLAGS = -I"$(QNX_TARGET)/usr/include:$(QNX_TARGET)/usr/include/python3.11:$(QNX_TARGET)/$(CPUVARDIR)/usr/include:$(QNX_TARGET)/$(CPUVARDIR)/usr/include/python3.11:$(QNX_TARGET)/usr/include/$(CPUVARDIR)/python3.11" \
                  -L"$(QNX_TARGET)/$(CPUVARDIR)/lib:$(QNX_TARGET)/$(CPUVARDIR)/usr/lib" \
                  -lc++ \
                  -b"$(PROJECT_ROOT)/$(NTO_DIR_NAME)/lib" \

ifndef NO_TARGET_OVERRIDE

numpy_all:
	cd $(NUMPY_ROOT) && \
	rm -rf build && \
	$(EXPORT_PY) && python3 $(QNX_PROJECT_ROOT)/setup.py build_ext $(BUILD_EXT_FLAGS) build $(BUILD_FLAGS) dist_info && \
	find $(NUMPY_ROOT)/$(NTO_DIR_NAME) -name "*.cpython-311.so" | xargs rm -rf && \
	find $(NUMPY_ROOT)/$(NTO_DIR_NAME) -name "*.so" | sed  'p;s|\..*so|.cpython-311.so|' | xargs -n2 mv
	cp -rf $(QNX_PROJECT_ROOT)/numpy/typing/tests/data $(NUMPY_ROOT)/$(NTO_DIR_NAME)/lib/numpy/typing/tests
	cp -rf $(QNX_PROJECT_ROOT)/numpy/lib/tests/data $(NUMPY_ROOT)/$(NTO_DIR_NAME)/lib/numpy/lib/tests
	cp -rf $(QNX_PROJECT_ROOT)/numpy/core/tests/data $(NUMPY_ROOT)/$(NTO_DIR_NAME)/lib/numpy/core/tests
	cp -rf $(QNX_PROJECT_ROOT)/numpy/random/tests/data $(NUMPY_ROOT)/$(NTO_DIR_NAME)/lib/numpy/random/tests
	rm -f  $(NUMPY_ROOT)/$(NTO_DIR_NAME)/lib/numpy/fft/tests/test_pocketfft.py # segfault
	rm -f $(NUMPY_ROOT)/$(NTO_DIR_NAME)/lib/numpy/core/tests/test_limited_api.py # Cannot test compiling in QNX
	rm -f $(NUMPY_ROOT)/$(NTO_DIR_NAME)/lib/numpy/typing/tests/test_isfile.py # There are no .pyi files to check for in QNX
	rm -rf $(NUMPY_ROOT)/$(NTO_DIR_NAME)/lib/numpy/distutils/tests
	rm -f $(NUMPY_ROOT)/$(NTO_DIR_NAME)/lib/numpy/core/tests/test_mem_policy.py
	touch $(NUMPY_ROOT)/$(NTO_DIR_NAME)/lib/numpy/py.typed # Needed for test_isfile.py
	cp -r $(QNX_PROJECT_ROOT)/numpy/f2py/src $(NUMPY_ROOT)/$(NTO_DIR_NAME)/lib/numpy/f2py/
	cp -r $(QNX_PROJECT_ROOT)/numpy/f2py/tests/src $(NUMPY_ROOT)/$(NTO_DIR_NAME)/lib/numpy/f2py/tests/

install check: numpy_all
	mkdir -p $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/python3.11/site-packages/
	$(CP_HOST) -rf $(NUMPY_ROOT)/$(NTO_DIR_NAME)/lib/numpy $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/python3.11/site-packages/
	$(CP_HOST) -rf $(QNX_PROJECT_ROOT)/numpy/core/include $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/python3.11/site-packages/numpy/core/
	$(CP_HOST) -rf $(QNX_PROJECT_ROOT)/numpy/random/include $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/python3.11/site-packages/numpy/random/
	$(CP_HOST) $(QNX_PROJECT_ROOT)/build/src*/numpy/core/include/numpy/*.h $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/python3.11/site-packages/numpy/core/include/numpy/
	$(CP_HOST) -rf $(QNX_PROJECT_ROOT)/numpy*dist-info $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/python3.11/site-packages/numpy-$(NUMPY_VERSION).dist-info

clean iclean spotless:
	rm -rf $(NUMPY_ROOT)/build

uninstall quninstall huninstall cuninstall:
	rm -rf $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/python3.11/site-packages/numpy
endif