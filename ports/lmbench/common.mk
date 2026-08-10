ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)
include $(MKFILES_ROOT)/qmacros.mk

NAME = lmbench

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../$(NAME)

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

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = $(NAME)_all
TARGET_OS=qnx-$(CPU)
BASE=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)
.PHONY: $(NAME)_all install check clean

CFLAGS += $(FLAGS) -O2 -DHAVE_uint=1 -DHAVE_uint64_t=1 -DHAVE_int64_t=1 -DRUSAGE -DNO_RPC -DSYS5
LDFLAGS += -Wl,--build-id=md5 -L$(QNX_TARGET)/$(CPUVARDIR)/usr/lib

include $(MKFILES_ROOT)/qtargets.mk

ifndef NO_TARGET_OVERRIDE
$(NAME)_all:
	echo $(CC) $(AR)
	$(MAKE) -C $(QNX_PROJECT_ROOT)/src all opt \
		O=$(PWD) \
		CC="qcc -Vgcc_nto$(CPUVARDIR)$(ENDIAN)" \
		AR="nto$(CPU)-ar" \
		CFLAGS="$(CFLAGS)" \
		LDFLAGS="$(LDFLAGS)" \
		LDLIBS="-lm -lsocket -l:librpc.so.2"

install:  $(NAME)_all
	mkdir -p $(BASE)/bin/$(TARGET_OS)
	mkdir -p $(INSTALL_ROOT)/$(PREFIX)/scripts
	mkdir -p $(INSTALL_ROOT)/$(PREFIX)/include
	mkdir -p $(BASE)/lib

	find $(PWD) -maxdepth 1 -type f -not -name "*.*" -not -name "Makefile" -exec cp -a {} $(BASE)/bin/$(TARGET_OS)/ \;
	cp -a $(QNX_PROJECT_ROOT)/scripts/* $(INSTALL_ROOT)/$(PREFIX)/scripts/
	cp -a $(QNX_PROJECT_ROOT)/scripts/lmbench $(BASE)/bin/$(TARGET_OS)
	cp -a $(QNX_PROJECT_ROOT)/src/*.h $(INSTALL_ROOT)/$(PREFIX)/include/
	cp -a $(PWD)/lmbench.a $(BASE)/lib/libmbench.a

clean iclean spotless:
	find $(PWD) -maxdepth 1 -type f -not -name "Makefile" -delete

uninstall:
endif
