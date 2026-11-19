ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=bacnet-stack

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../bacnet-stack

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

#A prefix path to use **on the target**. This is
#different from INSTALL_ROOT, which refers to a
#installation destination **on the host machine**.
#Default is /usr/local
PREFIX ?= /usr/local

#Data link for the applications and the library. QNX 8.0 support in
#bacnet-stack (ports/bsd, selected by BACNET_PORT=qnx) covers BACnet/IP only.
BACDL ?= bip

ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install check clean

include $(MKFILES_ROOT)/qtargets.mk

$(NAME)_INSTALL_DIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)

#bacnet-stack builds in its source tree; copy it per architecture so the
#aarch64le and x86_64 builds don't share object files
SRC_COPY = build/src

QNX_MAKE_ARGS = BACNET_PORT=qnx BACDL=$(BACDL) \
                CC="$(QNX_HOST)/usr/bin/qcc -Vgcc_$(OS)$(CPUVARDIR)" \
                AR="$(QNX_HOST)/usr/bin/$(OS)$(CPU)-ar"

#Several applications compile the same object files (e.g. bacserv and
#bacmini both build src/bacnet/basic/object/device.o), so a parallel build
#races on them: build with -j1 whatever JLEVEL says
$(NAME)_all:
	@mkdir -p $(SRC_COPY)
	@cd $(QNX_PROJECT_ROOT) && tar cf - --exclude=.git --exclude='*.o' --exclude='*.a' . | (cd $(CURDIR)/$(SRC_COPY) && tar xf -)
	$(MAKE) -j1 -C $(SRC_COPY) $(QNX_MAKE_ARGS) apps

install check: $(NAME)_all
	@echo Installing...
	$(MAKE) -j1 -C $(SRC_COPY)/apps $(QNX_MAKE_ARGS) DESTDIR= bindir=$($(NAME)_INSTALL_DIR)/bin install
	@mkdir -p $($(NAME)_INSTALL_DIR)/lib $(INSTALL_ROOT)/$(PREFIX)/include
	install -m 0644 $(SRC_COPY)/apps/lib/libbacnet.a $($(NAME)_INSTALL_DIR)/lib/
	cd $(SRC_COPY)/src && find bacnet -name '*.h' -exec install -D -m 0644 {} $(INSTALL_ROOT)/$(PREFIX)/include/{} \;
	@echo Done.

clean iclean spotless:
	rm -rf build

uninstall:
