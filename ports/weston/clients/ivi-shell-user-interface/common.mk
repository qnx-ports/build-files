ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME = weston-ivi-shell-user-interface

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

SRCS += ivi-shell-user-interface.c ivi-application-protocol.c ivi-hmi-controller-protocol.c

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
	$(DIST_ROOT)/data/background.png \
	$(DIST_ROOT)/data/tiling.png \
	$(DIST_ROOT)/data/fullscreen.png \
	$(DIST_ROOT)/data/panel.png \
	$(DIST_ROOT)/data/random.png \
	$(DIST_ROOT)/data/sidebyside.png \
	$(DIST_ROOT)/data/home.png \
	$(DIST_ROOT)/data/icon_ivi_clickdot.png \
	$(DIST_ROOT)/data/icon_ivi_flower.png \
	$(DIST_ROOT)/data/icon_ivi_simple-egl.png \
	$(DIST_ROOT)/data/icon_ivi_simple-shm.png \
	$(DIST_ROOT)/data/icon_ivi_smoke.png

define PINFO
PINFO DESCRIPTION = Weston IVI Shell Client
endef

include $(MKFILES_ROOT)/qtargets.mk

POST_INSTALL += $(CP_HOST) $(RESOURCES) $(INSTALL_ROOT_$(OS))/usr/share/weston/;
