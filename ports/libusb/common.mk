ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)
include $(MKFILES_ROOT)/qmacros.mk
NAME=libusb

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../$(NAME)/

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
PREFIX ?= usr/local

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

BUILD_DIR=$(CURDIR)/build

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install check clean

CFLAGS += $(FLAGS)

LDFLAGS += -Wl,--build-id=md5 -lusbdi

include $(MKFILES_ROOT)/qtargets.mk

#Headers from INSTALL_ROOT need to be made available by default
#because CMake and pkg-config do not necessary add it automatically
#if the include path is "default"
CFLAGS += -I$(QNX_TARGET)/$(PREFIX)/include \
          -I$(INSTALL_ROOT)/$(PREFIX)/include \
          -L$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib \
          -D_QNX_SOURCE
		  
QNX_VARIANT = -Vgcc_nto$(CPUVARDIR)

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

$(NAME)_all:
	mkdir -p $(BUILD_DIR)

	cd $(QNX_PROJECT_ROOT) && ./bootstrap.sh

	cd $(BUILD_DIR) && $(QNX_PROJECT_ROOT)/configure \
		--host=aarch64-unknown-nto-qnx \
		CC="qcc $(QNX_VARIANT)" \
		CFLAGS="$(CFLAGS)" \
		LDFLAGS="$(LDFLAGS)"

	cd $(BUILD_DIR) && $(MAKE)

	cd $(BUILD_DIR)/examples && $(MAKE)

	cd $(BUILD_DIR)/tests && $(MAKE)
	
BIN_INSTALL_DIR = $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/bin/libusb_tests

install:
	$(MAKE) -C $(BUILD_DIR) install DESTDIR=$(QNX_TARGET)/$(CPUVARDIR)

	mkdir -p $(BIN_INSTALL_DIR)
	find $(BUILD_DIR)/tests/.libs -maxdepth 1 -type f -perm -111 \
		-exec cp {} $(BIN_INSTALL_DIR)/ \;

	find $(BUILD_DIR)/examples/.libs -maxdepth 1 -type f -perm -111 \
		-exec cp {} $(BIN_INSTALL_DIR)/ \;
clean:
	rm -rf $(BUILD_DIR)