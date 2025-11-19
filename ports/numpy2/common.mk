ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=numpy2

ifeq ($(QNX_PROJECT_ROOT),)
$(error QNX_PROJECT_ROOT is not set. It should point to the numpy src dir)
endif

# A python wheel tries to indicate what systems it is compatible with.
# Anything that has a native library (ie: isn't a pure python wheel)
# if wants to use the 'machine' name as reported by uname.
# On Linux that will be something like 'x86_64' or 'aarch'.
# So the architecture of the machine.
#
# However QNX is different and returns a more specific identifier for
# the value. For example, 'x86pc' for x86_64 QEMU or 'RaspberryPi4B'
# for a, well, RPI 4B.
#
# This means that for a wheel to install cleanly, without using modifiers,
# it needs to be built with the exact value (in lowercase) reported by
# 'uname -m' on QNX.
#
# This can be achieved by setting a PYHOST_MACHINE_<cpu> variable
# before running the build. The value of the variable should be a
# space separated list of machine names to build wheels for.
# It is CPU specific so that the correct architecture is used to generated
# the wheel.
#
# The value does not have to be lowercase, the makefile will convert it automatically.
#
# So for example, to build a packge for the RPI4B you could use
# PYHOST_MACHINE_aarch64=RaspberryPi4B make
#
# By default the build will always produce a wheel for target's architecutre.
# Continuing the above example where one builds for the RPI4B, two wheels are
# actually produced:
#   numpy-2.3.4-cp311-cp311-qnx_8_0_0_aarch64.whl
#   numpy-2.3.4-cp311-cp311-qnx_8_0_0_raspberrypi4b.whl

# Format of a 'long double' on the target. Normally numpy can discover this
# during the build process by running some code locally. That doesn't work
# so well in a cross-compiled environment. The format depends on the target
# and the values I have below may not be correct. If so, you can override
# it from the command line.
ifeq ($(CPU),aarch64)
  QNX_LONG_DOUBLE ?= IEEE_QUAD_LE
else ifeq ($(CPU),x86_64)
  QNX_LONG_DOUBLE ?= INTEL_EXTENDED_16_BYTES_LE
else
  $(error Unknown CPU for setting LONG_DOUBLE type.)
endif

# this from the command line if required.
# code locally

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
MESON_BUILD_TYPE ?= release

# Discover what version of python I'm being compiled against.
PYVER ?= $(notdir $(firstword $(shell find $(QNX_TARGET)/usr/include -type d -name python*)))
PYVER_WHEEL = cp$(subst .,,$(subst python,,$(PYVER)))

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install check clean

#CFLAGS += $(FLAGS)
#LDFLAGS += -Wl,--build-id=md5 -Wl,--allow-shlib-undefined

PREPEND_C_CXXFLAGS := -lgcc_s
PREPEND_C_CXXFLAGS += $(CFLAGS)
PREPEND_C_CXXFLAGS += -I$(QNX_TARGET)/usr/include/$(CPUVARDIR)/$(PYVER)
PREPEND_C_CXXFLAGS += -I$(QNX_TARGET)//usr/include/$(PYVER)

include $(MKFILES_ROOT)/qtargets.mk

qnx_cross.txt: $(PROJECT_ROOT)/qnx_cross.txt.in
	cp $(PROJECT_ROOT)/qnx_cross.txt.in $@
	sed -i "s|QNX_HOST|$(QNX_HOST)|" $@
	sed -i "s|TARGET_ARCH|$(CPU)|" $@
	sed -i "s|CPUDIR|$(CPUVARDIR)|" $@
	sed -i "s|QNX_TARGET_BIN_DIR|$(QNX_TARGET)/$(CPUVARDIR)|" $@
	# PREPEND_C_CXXFLAGS need to be converted to Meson list format
	sed -i "s|PREPEND_C_CXXFLAGS|$(foreach flag,$(PREPEND_C_CXXFLAGS),'$(flag)',)|" $@
	sed -i "s|QNX_LONG_DOUBLE|$(QNX_LONG_DOUBLE)|" $@

ifndef NO_TARGET_OVERRIDE
venv:
	$(PYVER) -m venv venv
	cp $(QNX_TARGET)/$(CPUVARDIR)/usr/lib/$(PYVER)/_sysconfigdata__qnx_.py venv/lib/$(PYVER)/site-packages
	. venv/bin/activate && pip install build patchelf
	. venv/bin/activate && pip install \
	    `$(PYVER) -c 'import tomllib; print(" ".join(tomllib.load(open("$(QNX_PROJECT_ROOT)/pyproject.toml", "rb"))["build-system"]["requires"]))'`

$(NAME)_all:

# Used to serialize all the numpy variant builds
SERIALIZE :=
# $1 == Value to used to construct _PYTHON_HOST_PLATFORM
define BUILD_NUMPY
$(NAME)_$(1)_build: qnx_cross.txt venv | $(SERIALIZE)
	. venv/bin/activate && \
	cd $(QNX_PROJECT_ROOT) && \
	_PYTHON_SYSCONFIGDATA_NAME=_sysconfigdata__qnx_ \
	_PYTHON_HOST_PLATFORM=qnx_8_0_0_$(1) \
	    $(PYVER) -m build --wheel --no-isolation -Cbuild-dir=$(ROOT_DIR)/build -Csetup-args="--cross-file=$(ROOT_DIR)/qnx_cross.txt"
	mv $(QNX_PROJECT_ROOT)/dist/numpy-*-$(PYVER_WHEEL)-$(PYVER_WHEEL)-qnx_8_0_0_$(1).whl $(ROOT_DIR)
$(NAME)_all : $(NAME)_$(1)_build
SERIALIZE += $(NAME)_$(1)_build
endef

# Always build the variant with CPU name
$(eval $(call BUILD_NUMPY,$(CPU)))

# If there are additional PYHOST's specified, build them here
$(foreach _PYHOST,$(PYHOST_MACHINE_$(CPU)),$(eval $(call BUILD_NUMPY,$(shell echo $(_PYHOST) | tr A-Z a-z))))

install check: $(NAME)_all
	mkdir -p $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/$(PYVER)/site-packages/
	cd $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/$(PYVER)/site-packages/ && unzip -o $(ROOT_DIR)/numpy-*-$(PYVER_WHEEL)-$(PYVER_WHEEL)-qnx_8_0_0_$(CPU).whl

clean iclean spotless:
	rm -f qnx_cross.txt
	rm -rf build
	rm -f *.whl
	rm -rf venv

uninstall:
endif
