ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/lib

EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(DIST_ROOT)/libweston
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)/libweston
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol
EXTRA_INCVPATH += $(addsuffix /cairo,$(USE_ROOT_INCLUDE))
EXTRA_INCVPATH += $(addsuffix /pixman-1,$(USE_ROOT_INCLUDE))
EXTRA_INCVPATH += $(addsuffix /libdrm,$(USE_ROOT_INCLUDE))

EXTRA_SRCVPATH += $(DIST_ROOT)/libweston
EXTRA_SRCVPATH += $(DIST_ROOT)/libweston/desktop
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol

EXTRA_SRCVPATH += $(DIST_ROOT)/shared
# Stops build system from setting INCVPATH=$(EXTRA_SRCVPATH)
# Will still append EXTRA_INCVPATH as expected. There is a
# signal.h file in weston source conflicting with OS signal.h
INCVPATH = $(empty)

EXTRA_LIBVPATH += $(PROJECT_ROOT)/../shared/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^so\(.*\)$$/a.shared\1/')

# Hide symbols from static libraries.
LDFLAGS += -Wl,--exclude-libs,ALL
# Report unresolved symbols at build time
LDFLAGS += -Wl,--unresolved-symbols=report-all

SRCS += \
	log.c \
	compositor.c \
	content-protection.c \
	input.c \
	id-number-allocator.c \
	data-device.c \
	screenshooter.c \
	clipboard.c \
	bindings.c \
	animation.c \
	noop-renderer.c \
	auth.c \
	pixman-renderer.c \
	plugin-registry.c \
	timeline.c \
	linux-dmabuf.c \
	matrix.c \
	weston-log.c \
	weston-log-file.c \
	weston-log-flight-rec.c \
	weston-log-wayland.c \
	touch-calibration.c \
	pixel-formats.c \
	linux-sync-file.c \
	linux-explicit-synchronization.c \
	viewporter-protocol.c \
	color.c \
	color-noop.c \
	color-management.c \
	color-properties.c \
	drm-formats.c \
	gl-borders.c \
	vertex-clipping.c \
	$(if $(filter so dll,$(VARIANT_LIST)),epoll-create-stub.c) \
	$(if $(filter so dll,$(VARIANT_LIST)),socketpair-stub.c) \
	presentation-time-protocol.c \
	relative-pointer-unstable-v1-protocol.c \
	pointer-constraints-unstable-v1-protocol.c \
	input-timestamps-unstable-v1-protocol.c \
	linux-dmabuf-unstable-v1-protocol.c \
	linux-explicit-synchronization-unstable-v1-protocol.c \
	text-cursor-position-protocol.c \
	tearing-control-v1-protocol.c \
	weston-content-protection-protocol.c \
	weston-touch-calibration-protocol.c \
	weston-debug-protocol.c \
	xdg-output-unstable-v1-protocol.c \
	single-pixel-buffer-v1-protocol.c \
	color-management-v1-protocol.c \
	tablet-unstable-v2-protocol.c \
	weston-direct-display-protocol.c \
	weston-output-capture-protocol.c \
	libweston-desktop.c \
	output-capture.c \
	client.c \
	seat.c \
	surface.c \
	xwayland.c \
	xdg-shell.c \
	xdg-shell-v6.c \
	xdg-shell-unstable-v6-protocol.c \
	xdg-shell-protocol.c

LIBS += sharedS xkbcommon wayland-server pixman-1 memstream m shared-cairoS png jpeg cairo

define PINFO
PINFO DESCRIPTION = Weston Library
endef

include $(MKFILES_ROOT)/qtargets.mk
