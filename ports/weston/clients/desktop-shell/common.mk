ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME = weston-desktop-shell

INSTALLDIR = usr/libexec

DIST_ROOT ?= $(PROJECT_ROOT)

EXTRA_INCVPATH += $(DIST_ROOT)/clients
EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol
EXTRA_INCVPATH += $(addsuffix /cairo,$(USE_ROOT_INCLUDE))
include ../../../../../extra_incvpath.mk

EXTRA_SRCVPATH += $(DIST_ROOT)/clients
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol

EXTRA_LIBVPATH += $(PROJECT_ROOT)/../../libs/shared-cairo/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^o\(.*\)$$/a.shared\1/')
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../../libs/weston/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^o\(.*\)$$/so\1/')
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../../libs/toytoolkit/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^o\(.*\)$$/a.shared\1/')

SRCS += desktop-shell.c weston-desktop-shell-protocol.c

LIBS += \
	weston \
	toytoolkitS \
	shared-cairoS \
	cairo \
	pixman-1 \
	xkbcommon \
	wayland-egl \
	wayland-cursor \
	wayland-client \
	EGL \
	epoll \
	timerfd \
	socket \
	jpeg \
	png \
	m

RESOURCES += \
	$(DIST_ROOT)/data/wayland.svg \
	$(DIST_ROOT)/data/wayland.png \
	$(DIST_ROOT)/data/pattern.png \
	$(DIST_ROOT)/data/terminal.png \
	$(DIST_ROOT)/data/border.png \
	$(DIST_ROOT)/data/icon_editor.png \
	$(DIST_ROOT)/data/icon_flower.png \
	$(DIST_ROOT)/data/icon_terminal.png

define PINFO
PINFO DESCRIPTION = Weston Desktop Shell Client
endef

include $(MKFILES_ROOT)/qtargets.mk

POST_INSTALL += $(CP_HOST) $(RESOURCES) $(INSTALL_ROOT_$(OS))/usr/share/weston/;
