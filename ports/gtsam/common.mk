ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

# Prevent qtargets.mk from re-including qmacros.mk
define VARIANT_TAG
endef

NAME=gtsam

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
GTSAM_INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

GTSAM_VERSION = .4.3a0

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = GTSAM_all
.PHONY: GTSAM_all install check clean

#Required for 7.0
FLAGS += -D_QNX_SOURCE
CFLAGS += $(FLAGS)
LDFLAGS += -Wl,--build-id=md5 -lregex -lc++ -lm

include $(MKFILES_ROOT)/qtargets.mk

GTSAM_ROOT = $(PROJECT_ROOT)/../../../gtsam

QNX_TARGET_DATASET_DIR ?= /data/home/root/gtsam/test
PREFIX ?= /usr/local
INSTALL_TESTS?=true

ifdef QNX_PROJECT_ROOT
GTSAM_ROOT=$(QNX_PROJECT_ROOT)
endif

# Add the line below
CMAKE_ARGS = -DCMAKE_NO_SYSTEM_FROM_IMPORTED=TRUE \
             -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_PROJECT_INCLUDE=$(PROJECT_ROOT)/project_hooks.cmake \
             -DCMAKE_SYSTEM_PROCESSOR=$(CPUVARDIR) \
             -DCMAKE_INSTALL_PREFIX=$(GTSAM_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX) \
             -DCMAKE_INSTALL_LIBDIR=$(GTSAM_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib \
             -DINCLUDE_INSTALL_DIR=$(GTSAM_INSTALL_ROOT)/$(PREFIX)/include \
             -DCMAKE_INSTALL_INCLUDEDIR=$(GTSAM_INSTALL_ROOT)/$(PREFIX)/include \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_ASM_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCMAKE_PREFIX_PATH=$(GTSAM_INSTALL_ROOT) \
             -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
             -DCMAKE_AR=$(QNX_HOST)/usr/bin/nto$(CPU)-ar \
             -DCMAKE_RANLIB=${QNX_HOST}/usr/bin/nto${CPU}-ranlib \
             -DQNX_TARGET_DATASET_DIR:STRING=$(QNX_TARGET_DATASET_DIR) 

ifndef BUILD_TESTS 
	CMAKE_ARGS +=" -DGTSAM_BUILD_TESTS"
endif

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

ifndef NO_TARGET_OVERRIDE
GTSAM_all:
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(GTSAM_ROOT)
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)

install check: GTSAM_all
	@echo "Installing..."
	@cd build && make VERBOSE=1 install $(MAKE_ARGS)
	@echo "Copying tests to staging area..."
	@mkdir -p $(GTSAM_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin/gtsam_tests/gtsam_examples/Data/Balbianello
	@if [ $(INSTALL_TESTS) = "true" ] ; then cp build/gtsam/*/tests/test* $(GTSAM_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin/gtsam_tests ; echo "-GTSAM Tests" ; fi
	@if [ $(INSTALL_TESTS) = "true" ] ; then cp build/tests/test* $(GTSAM_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin/gtsam_tests ; echo "-General Tests" ; fi
	@if [ $(INSTALL_TESTS) = "true" ] ; then cp build/gtsam_unstable/*/tests/test* $(GTSAM_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin/gtsam_tests ; echo "-Unstable Tests" ; fi
	@if [ $(INSTALL_TESTS) = "true" ] ; then cp $(PROJECT_ROOT)/run_tests.sh $(GTSAM_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin/gtsam_tests ; echo "-Testing Script" ; fi
	@if [ $(INSTALL_TESTS) = "true" ] ; then cp -r $(GTSAM_ROOT)/examples/Data/* $(GTSAM_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin/gtsam_tests/gtsam_examples/Data ; echo "-General Data" ; fi
	@if [ $(INSTALL_TESTS) = "true" ] ; then cp $(GTSAM_ROOT)/gtsam_unstable/discrete/examples/*.csv $(GTSAM_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin/gtsam_tests ; echo "-.csv Data" ; fi
	@if [ $(INSTALL_TESTS) = "true" ] ; then cp $(GTSAM_ROOT)/gtsam_unstable/discrete/examples/*.xls $(GTSAM_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin/gtsam_tests ; echo "-.xls Data" ; fi
	@if [ $(INSTALL_TESTS) = "true" ] ; then cp $(GTSAM_ROOT)/gtsam/nonlinear/tests/priorFactor.xml $(GTSAM_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin/gtsam_tests ; echo "-priorFactor.xml" ; fi
	@echo "Done." ;

clean iclean spotless:
	@rm -rf build
endif
