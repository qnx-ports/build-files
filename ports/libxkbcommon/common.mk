ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME = libxkbcommon

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
PREFIX ?= /usr/local

#choose Release or Debug
MESON_BUILD_TYPE ?= release

ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install check clean

CFLAGS += $(FLAGS)
CFLAGS += -D_QNX_SOURCE

include $(MKFILES_ROOT)/qtargets.mk

LIBXKBCOMMON_INSTALL_DIR=$(INSTALL_ROOT)

MESON_FLAGS :=  --prefix=/$(CPUVARDIR)/$(PREFIX) \
								--includedir=$(PREFIX)/include \
                --cross-file=../qnx_cross.cfg \
                -Dc_args="$(CFLAGS)" \
                -Ddefault-layout=us \
                -Denable-tools=false \
                -Denable-x11=false \
                -Denable-xkbregistry=false \
                -Denable-docs=false \
                -Ddefault-rules=hidut \
                -Dxkb-config-root=/usr/share/xkb \
                -Dx-locale-root=/usr/share/locale \

NINJA_ARGS ?= -j $(firstword $(JLEVEL) 1)

# Set cross file
qnx_cross.cfg: $(PROJECT_ROOT)/qnx_cross.cfg.in
	cp $(PROJECT_ROOT)/qnx_cross.cfg.in $@
	sed -i "s|QSDP|$(QNX_HOST)|" $@
	sed -i "s|CPU|$(CPU)|" $@
	sed -i "s|INSTALL_DIR|$(LIBXKBCOMMON_INSTALL_DIR)|" $@

$(NAME)_all: qnx_cross.cfg
	@mkdir -p build
	@cd build && meson setup $(MESON_FLAGS) . $(QNX_PROJECT_ROOT)
	@cd build && DESTDIR=$(LIBXKBCOMMON_INSTALL_DIR) \
	ninja install $(NINJA_ARGS)

install check: $(NAME)_all
	@echo Installing...
	@echo Done.

clean iclean spotless:
	rm -rf qnx_cross.cfg
	rm -rf build

uninstall: